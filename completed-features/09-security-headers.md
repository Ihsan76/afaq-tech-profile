# خطة هندسة تأمين HTTP Headers (CSP & Security)

> تاريخ التوثيق: 18 أغسطس 2026
> الغرض: توثيق التصميم الهندسي والمعماري لتأمين HTTP Headers في منصة آفاق تكنولوجي.

---

## 1. الفكرة والهدف
تأمين التطبيق ضد هجمات XSS، Clickjacking، MIME sniffing، وغيرها عبر HTTP Security Headers.

---

## 2. HTTP Headers المطلوبة

### أ. Content Security Policy (CSP)
```python
# backend/apps/core/middleware.py
class SecurityHeadersMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        response = self.get_response(request)

        # CSP Policy
        csp_directives = {
            'default-src': ["'self'"],
            'script-src': ["'self'", "'nonce-{request.csp_nonce}'", "https://www.googletagmanager.com"],
            'style-src': ["'self'", "'unsafe-inline'", "https://fonts.googleapis.com"],
            'img-src': ["'self'", "data:", "https:", "blob:"],
            'font-src': ["'self'", "https://fonts.gstatic.com"],
            'connect-src': ["'self'", "https://api.afaq.app", "https://*.supabase.co"],
            'frame-src': ["'none'"],
            'object-src': ["'none'"],
            'base-uri': ["'self'"],
            'form-action': ["'self'"],
            'frame-ancestors': ["'none'"],
            'upgrade-insecure-requests': [],
        }

        csp_value = '; '.join(
            f"{directive} {' '.join(values)}" if values else directive
            for directive, values in csp_directives.items()
        )

        response['Content-Security-Policy'] = csp_value
        return response
```

### ب. Headers أخرى
```python
# X-Frame-Options (Clickjacking Protection)
response['X-Frame-Options'] = 'DENY'

# X-Content-Type-Options (MIME Sniffing Protection)
response['X-Content-Type-Options'] = 'nosniff'

# X-XSS-Protection (Legacy XSS Protection)
response['X-XSS-Protection'] = '1; mode=block'

# Referrer Policy
response['Referrer-Policy'] = 'strict-origin-when-cross-origin'

# Permissions Policy (Feature Policy)
response['Permissions-Policy'] = 'camera=(), microphone=(self), geolocation=()'

# Strict-Transport-Security (HSTS)
response['Strict-Transport-Security'] = 'max-age=31536000; includeSubDomains; preload'

# X-DNS-Prefetch-Control
response['X-DNS-Prefetch-Control'] = 'on'
```

---

## 3. التكامل مع Next.js (Frontend Headers)

### أ. `next.config.ts`
```typescript
const securityHeaders = [
    {
        key: 'Content-Security-Policy',
        value: [
            "default-src 'self'",
            "script-src 'self' 'unsafe-eval' 'unsafe-inline' https://www.googletagmanager.com",
            "style-src 'self' 'unsafe-inline' https://fonts.googleapis.com",
            "img-src 'self' data: https: blob:",
            "font-src 'self' https://fonts.gstatic.com",
            "connect-src 'self' https://api.afaq.app https://*.supabase.co",
            "frame-src 'none'",
            "object-src 'none'",
            "base-uri 'self'",
            "form-action 'self'",
            "frame-ancestors 'none'",
        ].join('; '),
    },
    { key: 'X-Frame-Options', value: 'DENY' },
    { key: 'X-Content-Type-Options', value: 'nosniff' },
    { key: 'Referrer-Policy', value: 'strict-origin-when-cross-origin' },
    { key: 'Permissions-Policy', value: 'camera=(), microphone=(self), geolocation=()' },
];

module.exports = {
    async headers() {
        return [
            {
                source: '/(.*)',
                headers: securityHeaders,
            },
        ];
    },
};
```

---

## 4. Nonce-based CSP للنصوص

### أ. توليد Nonce في Django
```python
import secrets
import base64

class CSPNonceMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        nonce = base64.b64encode(secrets.token_bytes(16)).decode('ascii')
        request.csp_nonce = nonce
        response = self.get_response(request)
        response['Content-Security-Policy'] = response.get('Content-Security-Policy', '').replace(
            "'nonce-{nonce}'", f"'nonce-{nonce}'"
        )
        return response
```

### ب. استخدام Nonce في القوالب
```html
<!-- Django Template -->
<script nonce="{{ request.csp_nonce }}">
    // هذا الكود سيعمل مع CSP
</script>

<!-- Next.js -->
<script nonce={nonce} src="/script.js" />
```

---

## 5. اختبار Headers

### أ. اختبار محلي
```bash
# اختبار CSP
curl -I http://localhost:3000/ | grep -i "content-security-policy"

# اختبار جميع Headers
curl -I http://localhost:3000/
```

### ب. اختبار عبر CI
```yaml
# .github/workflows/security.yml
- name: Security Headers Check
  run: |
    npx @next/csp-validator
    npx helmet-csp-validator
```

### ج. أدوات الاختبار
| الأداة | الرابط |
|--------|--------|
| SecurityHeaders.com | https://securityheaders.com |
| Mozilla Observatory | https://observatory.mozilla.org |
| CSP Evaluator | https://csp-evaluator.withgoogle.com |

---

## 6. الحماية ضد XSS
- **CSP nonce**: كل script يحصل على nonce فريد لكل request
- **Input Sanitization**: تنظيف جميع المدخلات عبر `bleach` في الخلفية
- **Output Encoding**: استخدام `markupsafe.escape()` في القوالب
- **HttpOnly Cookies**: JWT tokens في httpOnly cookies (وليس localStorage)
