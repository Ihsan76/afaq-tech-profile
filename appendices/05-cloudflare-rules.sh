#!/usr/bin/env bash
# =============================================================================
# Cloudflare rules for afaq-tech (Zone 92f3598d49be3c4339a351c5e46c62a9)
# Phases: http_ratelimit, http_request_firewall_custom, http_request_cache_settings
#
# Safe pattern (per Cloudflare docs): GET the entry point ruleset first, then
# POST rules one-by-one to /rulesets/{id}/rules (appends, never replaces).
# PUT is avoided because it replaces ALL existing rules in the ruleset.
#
# Free-plan constraints (learned during deploy, Aug 2026):
#   - Create rulesets via POST /zones/{zone}/rulesets (NOT the phase entrypoint
#     path, which rejects POST with 10405)
#   - http_ratelimit: period only 10, mitigation_timeout only 10,
#     characteristics MUST include cf.colo.id, operators limited to
#     eq/contains/in (no matches/starts_with without Advanced plan)
#   - WAF custom rules: action_parameters.response (custom block page) is
#     plan-gated -> use plain "action": "block"
#   - Only ONE http_ratelimit rule allowed per zone on Free
#   - Token needs Account Rulesets Edit AND the account included in resources
#
# Idempotent: re-running skips rules whose description already exists.
#
# Prereqs:
#   - API token with: Zone > WAF Edit, Zone > Cache Rules Edit,
#     Zone > Config Rules/Transform Rules Edit (or a scoped "Edit" on rulesets)
#   - ADMIN_ALLOW_IP: your office/static IP (or CIDR) allowed into /admin/*
# =============================================================================

set -euo pipefail

ZONE_ID="92f3598d49be3c4339a351c5e46c62a9"
CF_AUTH_TOKEN="${CF_AUTH_TOKEN:-}"          # export before running
ADMIN_ALLOW_IP="${ADMIN_ALLOW_IP:-}"        # e.g. 1.2.3.4 or 1.2.3.0/24
API="https://api.cloudflare.com/client/v4"

[[ -n "$CF_AUTH_TOKEN" ]] || { echo "Set CF_AUTH_TOKEN first"; exit 1; }
[[ -n "$ADMIN_ALLOW_IP" ]] || { echo "Set ADMIN_ALLOW_IP first"; exit 1; }

jq_check() { command -v jq >/dev/null || { echo "jq is required"; exit 1; }; }
jq_check

request() { # request METHOD URL DATA
  local method="$1" url="$2" data="${3:-}"
  if [[ -n "$data" ]]; then
    curl -sS -X "$method" "$url" \
      -H "Authorization: Bearer $CF_AUTH_TOKEN" \
      -H "Content-Type: application/json" \
      --data "$data"
  else
    curl -sS -X "$method" "$url" \
      -H "Authorization: Bearer $CF_AUTH_TOKEN"
  fi
}

# Returns ruleset id for a phase (creates the entry point if it doesn't exist)
ensure_ruleset() { # ensure_ruleset PHASE
  local phase="$1"
  local out id
  out="$(request GET "$API/zones/$ZONE_ID/rulesets/phases/$phase/entrypoint")"
  id="$(jq -r '.result.id // empty' <<<"$out")"
  if [[ -z "$id" ]]; then
    echo "  [create] phase $phase" >&2
    out="$(request POST "$API/zones/$ZONE_ID/rulesets" \
      "{\"name\":\"Default\",\"kind\":\"zone\",\"phase\":\"$phase\",\"rules\":[]}")"
    id="$(jq -r '.result.id // empty' <<<"$out")"
  fi
  if [[ -z "$id" ]]; then
    echo "  [ERROR] could not get/create ruleset for $phase" >&2; echo "$out" >&2; exit 1
  fi
  echo "$id"
}

add_rule() { # add_rule RULESET_ID JSON  (skips if a rule with the same description exists)
  local rsid="$1" data="$2" desc out
  desc="$(jq -r '.description // "rule"' <<<"$data")"
  out="$(request GET "$API/zones/$ZONE_ID/rulesets/$rsid")"
  if jq -e --arg d "$desc" '.result.rules[]?.description == $d' <<<"$out" >/dev/null; then
    echo "  [skip] $desc (already exists)"
    return 0
  fi
  out="$(request POST "$API/zones/$ZONE_ID/rulesets/$rsid/rules" "$data")"
  if ! jq -e '.success == true' <<<"$out" >/dev/null; then
    echo "  [ERROR] rule not added:" >&2
    echo "$out" >&2
    exit 1
  fi
  echo "  [ok] $desc"
}

# =============================================================================
# 1) RATE LIMIT — brute force protection on auth endpoints
# =============================================================================
echo "== http_ratelimit =="
RL_RS="$(ensure_ruleset http_ratelimit)"
add_rule "$RL_RS" '{
  "description": "RL: auth endpoints brute force (10 req/10s per IP, 10s block)",
  "expression": "(http.request.uri.path contains \"/api/v1/auth/\")",
  "action": "block",
  "enabled": true,
  "ratelimit": {
    "characteristics": ["ip.src", "cf.colo.id"],
    "period": 10,
    "requests_per_period": 10,
    "requests_to_origin": false,
    "mitigation_timeout": 10
  }
}'

# =============================================================================
# 2) WAF CUSTOM RULE — hide Django admin & user-admin API from the public
# =============================================================================
echo "== http_request_firewall_custom =="
WAF_RS="$(ensure_ruleset http_request_firewall_custom)"
add_rule "$WAF_RS" "{
  \"description\": \"WAF: block /admin and /api/v1/auth/admin from public\",
  \"expression\": \"(starts_with(http.request.uri.path, \\\"/admin/\\\") or starts_with(http.request.uri.path, \\\"/api/v1/auth/admin/\\\")) and not ip.src in { $ADMIN_ALLOW_IP }\",
  \"action\": \"block\",
  \"enabled\": true
}"

# =============================================================================
# 3) CACHE RULES — order matters (first match wins)
# =============================================================================
echo "== http_request_cache_settings =="
CACHE_RS="$(ensure_ruleset http_request_cache_settings)"

# 3a) API is dynamic — never cache
add_rule "$CACHE_RS" '{
  "description": "Cache: bypass API (dynamic)",
  "expression": "(http.host eq \"api.afaq.app\" and starts_with(http.request.uri.path, \"/api/\"))",
  "action": "set_cache_settings",
  "enabled": true,
  "action_parameters": { "cache": false }
}'

# 3b) robots.txt / sitemap.xml — no cache (always fresh for search engines)
add_rule "$CACHE_RS" '{
  "description": "Cache: bypass robots.txt and sitemap.xml",
  "expression": "(http.host eq \"www.afaq.app\" and (http.request.uri.path eq \"/robots.txt\" or http.request.uri.path eq \"/sitemap.xml\"))",
  "action": "set_cache_settings",
  "enabled": true,
  "action_parameters": { "cache": false }
}'

# 3c) Next.js hashed static assets — long edge TTL (safe: content-addressed)
add_rule "$CACHE_RS" '{
  "description": "Cache: Next.js static assets 1 year",
  "expression": "(http.host eq \"www.afaq.app\" and starts_with(http.request.uri.path, \"/_next/static/\"))",
  "action": "set_cache_settings",
  "enabled": true,
  "action_parameters": {
    "cache": true,
    "edge_ttl": { "mode": "override_origin", "default": 31536000 }
  }
}'

# 3d) Django static (api.afaq.app/static/*) — 1 day
add_rule "$CACHE_RS" '{
  "description": "Cache: Django static 1 day",
  "expression": "(http.host eq \"api.afaq.app\" and starts_with(http.request.uri.path, \"/static/\"))",
  "action": "set_cache_settings",
  "enabled": true,
  "action_parameters": {
    "cache": true,
    "edge_ttl": { "mode": "override_origin", "default": 86400 }
  }
}'

echo
echo "All rules deployed."
