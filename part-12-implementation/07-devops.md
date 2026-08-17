# DevOps والبنية التحتية (DevOps & Infrastructure)

## نظرة عامة

> **فلسفة التكلفة:** في مرحلة **البناء والاختبار** نستخدم خدمات مجانية بالكامل (Supabase Free, Upstash Free, Vercel Hobby, Railway $5 credit, Gemini Free). عند **الإطلاق** نرقّي تدريجياً حسب الحمل الفعلي.

البنية التحتية الكاملة للمنصة على السحابة مع Docker.

---

## المكونات

```
┌─────────────────────────────────────────────────────────────────┐
│                    Infrastructure Stack                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────┐    ┌──────────────────┐                   │
│  │  Cloudflare      │    │  Vercel          │                   │
│  │  (CDN + WAF)     │───►│  (Frontend)      │                   │
│  └──────────────────┘    └──────────────────┘                   │
│                                 │                               │
│                                 ▼                               │
│                          ┌──────────────────┐                   │
│                          │  Railway         │                   │
│                          │  (Backend)       │                   │
│                          └──────────────────┘                   │
│                                 │                               │
│              ┌──────────────────┼──────────────────┐            │
│              ▼                  ▼                   ▼            │
│     ┌──────────────────┐ ┌──────────────────┐ ┌──────────────┐ │
│     │  Supabase        │ │  Upstash         │ │  Elastic     │ │
│     │  (PostgreSQL)    │ │  (Redis)         │ │  (Search)    │ │
│     └──────────────────┘ └──────────────────┘ └──────────────┘ │
│                                                                  │
│  ┌──────────────────┐    ┌──────────────────┐                   │
│  │  Cloudflare R2   │    │  Resend          │                   │
│  │  (Storage)       │    │  (Email)         │                   │
│  └──────────────────┘    └──────────────────┘                   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Cloudflare Configuration

```javascript
// cloudflare/wrangler.toml

name = "afaq-tech"
compatibility_date = "2024-01-01"

# Pages (Frontend)
[[pages]]
name = "afaq-frontend"
production_branch = "main"

# Functions
[functions]
compatibility_date = "2024-01-01"
node_compat = true

# Environment variables
[vars]
NEXT_PUBLIC_API_URL = "https://api.afaq.app"
NEXT_PUBLIC_WS_URL = "wss://ws.afaq.app"

# Routes
[[routes]]
pattern = "afaq.app/*"
zone_name = "afaq.app"
```

---

## Railway Configuration

```json
// railway.json

{
  "$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder": "DOCKERFILE",
    "dockerfilePath": "backend/Dockerfile"
  },
  "deploy": {
    "startCommand": "gunicorn config.wsgi:application --bind 0.0.0.0:$PORT --workers 4",
    "healthcheckPath": "/health/",
    "healthcheckTimeout": 10,
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 3
  }
}
```

```toml
# railway.toml (Backend Service)

[build]
builder = "dockerfile"
dockerfilePath = "backend/Dockerfile"

[deploy]
startCommand = "gunicorn config.wsgi:application --bind 0.0.0.0:$PORT --workers 4"
healthcheckPath = "/health/"
healthcheckTimeout = 10

[environment]
DATABASE_URL = "${{PostgreSQL.DATABASE_URL}}"
REDIS_URL = "${{Redis.REDIS_URL}}"
SECRET_KEY = "${{SECRET_KEY}}"
ENVIRONMENT = "production"
```

---

## Supabase Configuration

```sql
-- Supabase PostgreSQL Extensions

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";

-- Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
  ON users FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON users FOR UPDATE
  USING (auth.uid() = id);
```

---

## Docker Compose (Production-like)

```yaml
# docker-compose.prod.yml

version: '3.8'

services:
  # ─── Backend ───────────────────────────────────────
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    environment:
      - DATABASE_URL=${DATABASE_URL}
      - REDIS_URL=${REDIS_URL}
      - SECRET_KEY=${SECRET_KEY}
      - ENVIRONMENT=production
      - CORS_ALLOWED_ORIGINS=${CORS_ALLOWED_ORIGINS}
    ports:
      - "8000:8000"
    deploy:
      replicas: 2
      resources:
        limits:
          cpus: '1'
          memory: 1G
        reservations:
          cpus: '0.5'
          memory: 512M
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health/"]
      interval: 30s
      timeout: 10s
      retries: 3

  # ─── Nginx ─────────────────────────────────────────
  nginx:
    image: nginx:alpine
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
    ports:
      - "80:80"
      - "443:443"
    depends_on:
      - backend

  # ─── Celery Worker ─────────────────────────────────
  celery-worker:
    build:
      context: ./backend
      dockerfile: Dockerfile
    command: celery -A config worker -l info -c 4
    environment:
      - DATABASE_URL=${DATABASE_URL}
      - REDIS_URL=${REDIS_URL}
    depends_on:
      - backend
      - redis

  # ─── Celery Beat ───────────────────────────────────
  celery-beat:
    build:
      context: ./backend
      dockerfile: Dockerfile
    command: celery -A config beat -l info
    environment:
      - DATABASE_URL=${DATABASE_URL}
      - REDIS_URL=${REDIS_URL}
    depends_on:
      - backend
      - redis

  # ─── PostgreSQL ────────────────────────────────────
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: afaq_production
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  # ─── Redis ─────────────────────────────────────────
  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
    ports:
      - "6379:6379"

  # ─── Elasticsearch ─────────────────────────────────
  elasticsearch:
    image: elasticsearch:8.11.0
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
      - "ES_JAVA_OPTS=-Xms1g -Xmx1g"
    volumes:
      - es_data:/usr/share/elasticsearch/data
    ports:
      - "9200:9200"

volumes:
  postgres_data:
  redis_data:
  es_data:
```

---

## Nginx Configuration

```nginx
# nginx/nginx.conf

events {
    worker_connections 1024;
}

http {
    # upstream
    upstream backend {
        server backend:8000;
    }

    # compression
    gzip on;
    gzip_types text/plain application/json application/javascript text/css;
    gzip_min_length 1000;

    # rate limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=auth:10m rate=5r/m;

    # server
    server {
        listen 80;
        server_name api.afaq.app;

        # redirect to HTTPS
        return 301 https://$server_name$request_uri;
    }

    server {
        listen 443 ssl http2;
        server_name api.afaq.app;

        # SSL
        ssl_certificate /etc/nginx/ssl/fullchain.pem;
        ssl_certificate_key /etc/nginx/ssl/privkey.pem;
        ssl_protocols TLSv1.2 TLSv1.3;

        # API
        location /api/ {
            limit_req zone=api burst=20 nodelay;
            
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # Auth (rate limited)
        location /api/v1/auth/ {
            limit_req zone=auth burst=5 nodelay;
            
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }

        # WebSocket
        location /ws/ {
            proxy_pass http://backend;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_read_timeout 86400;
        }

        # Health check
        location /health/ {
            proxy_pass http://backend;
        }
    }
}
```

---

## Terraform (infrastructure as code)

> **ملاحظة:** المثال التالي يستخدم AWS كخيار متقدم. للـ MVP والتوسع الأولي، يُفضل استخدام **Cloudflare R2** (S3-compatible) بدلاً من AWS S3 لتقليل التكلفة والتعقيد.

```hcl
# infrastructure/main.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "afaq-terraform-state"
    key    = "production/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}

# ─── S3 Bucket ────────────────────────────────────────
resource "aws_s3_bucket" "media" {
  bucket = "afaq-media-${var.environment}"
}

resource "aws_s3_bucket_cors_configuration" "media_cors" {
  bucket = aws_s3_bucket.media.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST"]
    allowed_origins = ["https://afaq.app", "https://*.afaq.app"]
    max_age_seconds = 3600
  }
}

# ─── CloudFront ───────────────────────────────────────
resource "aws_cloudfront_distribution" "media" {
  origin {
    domain_name = aws_s3_bucket.media.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.media.id}"
  }

  enabled = true

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.media.id}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# ─── Route53 ──────────────────────────────────────────
resource "aws_route53_zone" "main" {
  name = "afaq.app"
}

resource "aws_route53_record" "api" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "api.afaq.app"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.media.domain_name
    zone_id                = aws_cloudfront_distribution.media.hosted_zone_id
    evaluate_target_health = false
  }
}
```

---

## ملخص

> **DevOps والبنية التحتية** تشمل: Cloudflare (CDN + WAF)، Railway (Backend)، Vercel (Frontend)، Supabase (PostgreSQL)، Upstash (Redis)، Docker Compose، Nginx، Terraform (IaC)، وإعدادات SSL.
