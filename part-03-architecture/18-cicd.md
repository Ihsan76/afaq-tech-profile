# خط أنابيب CI/CD

## نظرة عامة

> **مجاني أثناء البناء:** GitHub Actions (2000 min/شهر مجاناً) — كافٍ لـ MVP.

أتمتة الاختبار والبناء والنشر باستخدام GitHub Actions.

---

## المكونات

```
┌─────────────────────────────────────────────────────────────────┐
│                      CI/CD Pipeline                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐   │
│  │  Code    │──►│  Lint &  │──►│  Test    │──►│  Build   │   │
│  │  Push    │   │  Format  │   │          │   │          │   │
│  └──────────┘   └──────────┘   └──────────┘   └──────────┘   │
│                                                       │         │
│                                                       ▼         │
│                                              ┌──────────┐       │
│                                              │  Deploy  │       │
│                                              │  (Staging│       │
│                                              │  /Prod)  │       │
│                                              └──────────┘       │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## GitHub Actions Workflow

```yaml
# .github/workflows/ci.yml

name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  PYTHON_VERSION: '3.12'
  NODE_VERSION: '20'
  POSTGRES_VERSION: '16'
  REDIS_VERSION: '7'

jobs:
  # ─── فحص الكود ──────────────────────────────────────
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: ${{ env.PYTHON_VERSION }}
      
      - name: Install Python dependencies
        run: |
          pip install ruff mypy
          pip install -r requirements/dev.txt
      
      - name: Run Ruff (Python linter)
        run: ruff check .
      
      - name: Run Ruff format check
        run: ruff format --check .
      
      - name: Run MyPy
        run: mypy . --ignore-missing-imports
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
      
      - name: Install Node.js dependencies
        run: npm ci
      
      - name: Run ESLint
        run: npm run lint
      
      - name: Run Prettier
        run: npm run format:check

  # ─── اختبارات Python ────────────────────────────────
  test-python:
    runs-on: ubuntu-latest
    needs: lint
    
    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_DB: afaq_test
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
      
      redis:
        image: redis:7
        ports:
          - 6379:6379
    
    env:
      DATABASE_URL: postgres://postgres:postgres@localhost:5432/afaq_test
      REDIS_URL: redis://localhost:6379/0
      SECRET_KEY: test-secret-key
      ENVIRONMENT: testing
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: ${{ env.PYTHON_VERSION }}
          cache: 'pip'
      
      - name: Install dependencies
        run: |
          pip install -r requirements/dev.txt
      
      - name: Run migrations
        run: python manage.py migrate
      
      - name: Run tests
        run: |
          pytest \
            --cov=. \
            --cov-report=xml \
            --cov-report=html \
            --junitxml=junit.xml \
            -v
      
      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage.xml
          fail_ci_if_error: false

  # ─── اختبارات JavaScript ─────────────────────────────
  test-js:
    runs-on: ubuntu-latest
    needs: lint
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run tests
        run: npm test -- --coverage
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage/lcov.info
          fail_ci_if_error: false

  # ─── بناء Docker ─────────────────────────────────────
  build:
    runs-on: ubuntu-latest
    needs: [test-python, test-js]
    if: github.ref == 'refs/heads/main'
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}
      
      - name: Build and push Backend
        uses: docker/build-push-action@v5
        with:
          context: ./backend
          push: true
          tags: afaq/backend:${{ github.sha }},afaq/backend:latest
          cache-from: type=gha
          cache-to: type=gha,mode=max
      
      - name: Build and push Frontend
        uses: docker/build-push-action@v5
        with:
          context: ./frontend
          push: true
          tags: afaq/frontend:${{ github.sha }},afaq/frontend:latest
          cache-from: type=gha
          cache-to: type=gha,mode=max

  # ─── النشر على Staging ──────────────────────────────
  deploy-staging:
    runs-on: ubuntu-latest
    needs: build
    if: github.ref == 'refs/heads/main'
    environment: staging
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Deploy to Staging
        run: |
          # نشر على Railway Staging
          npm install -g @railway/cli
          railway login --token ${{ secrets.RAILWAY_TOKEN }}
          railway up --environment staging
      
      - name: Run smoke tests
        run: |
          curl -f https://staging.afaq.app/health/ || exit 1
      
      - name: Notify Slack
        if: success()
        uses: slackapi/slack-github-action@v1
        with:
          payload: |
            {
              "text": "✅ Staging deployment successful: ${{ github.sha }}"
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}

  # ─── النشر على Production ───────────────────────────
  deploy-production:
    runs-on: ubuntu-latest
    needs: deploy-staging
    if: github.ref == 'refs/heads/main'
    environment: production
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Deploy to Production
        run: |
          # نشر على Railway Production
          npm install -g @railway/cli
          railway login --token ${{ secrets.RAILWAY_TOKEN }}
          railway up --environment production
      
      - name: Deploy Frontend to Vercel
        uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          vercel-args: '--prod'
      
      - name: Run smoke tests
        run: |
          curl -f https://afaq.app/health/ || exit 1
      
      - name: Create GitHub Release
        uses: actions/create-release@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          tag_name: v${{ github.run_number }}
          release_name: Release v${{ github.run_number }}
          draft: false
          prerelease: false
      
      - name: Notify Slack
        if: success()
        uses: slackapi/slack-github-action@v1
        with:
          payload: |
            {
              "text": "🚀 Production deployment successful: v${{ github.run_number }}"
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
```

---

## Docker Configuration

```dockerfile
# backend/Dockerfile

FROM python:3.12-slim as builder

WORKDIR /app

# تثبيت المكتبات
COPY requirements/ .
RUN pip install --no-cache-dir -r production.txt

# ─── مرحلة التشغيل ─────────────────────────────────────

FROM python:3.12-slim

WORKDIR /app

# نسخ المكتبات
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# نسخ الكود
COPY . .

# المستخدم غير الجذر
RUN adduser --disabled-password --gecos '' appuser
USER appuser

# المنفذ
EXPOSE 8000

# الأوامر
CMD ["gunicorn", "config.wsgi:application", "--bind", "0.0.0.0:8000", "--workers", "4"]
```

```dockerfile
# frontend/Dockerfile

FROM node:20-alpine as builder

WORKDIR /app

# تثبيت المكتبات
COPY package*.json ./
RUN npm ci

# بناء التطبيق
COPY . .
RUN npm run build

# ─── مرحلة التشغيل ─────────────────────────────────────

FROM node:20-alpine

WORKDIR /app

# نسخ ملفات التشغيل
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

# المستخدم غير الجذر
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs
USER nextjs

# المنفذ
EXPOSE 3000

# متغير البيئة
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

# التشغيل
CMD ["node", "server.js"]
```

---

## Docker Compose (للتطوير المحلي)

```yaml
# docker-compose.yml

version: '3.8'

services:
  # ─── قاعدة البيانات ────────────────────────────────
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: afaq_dev
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5

  # ─── Redis ─────────────────────────────────────────
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 5s
      retries: 5

  # ─── Elasticsearch ─────────────────────────────────
  elasticsearch:
    image: elasticsearch:8.11.0
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
    ports:
      - "9200:9200"
    volumes:
      - es_data:/usr/share/elasticsearch/data

  # ─── Backend ───────────────────────────────────────
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    command: python manage.py runserver 0.0.0.0:8000
    volumes:
      - ./backend:/app
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgres://postgres:postgres@postgres:5432/afaq_dev
      - REDIS_URL=redis://redis:6379/0
      - ELASTICSEARCH_URL=http://elasticsearch:9200
      - SECRET_KEY=dev-secret-key
      - ENVIRONMENT=development
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
      elasticsearch:
        condition: service_started

  # ─── Frontend ──────────────────────────────────────
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    command: npm run dev
    volumes:
      - ./frontend:/app
      - /app/node_modules
      - /app/.next
    ports:
      - "3000:3000"
    environment:
      - NEXT_PUBLIC_API_URL=http://localhost:8000/api/v1
    depends_on:
      - backend

volumes:
  postgres_data:
  redis_data:
  es_data:
```

---

## Scripts

```bash
#!/bin/bash
# scripts/setup-dev.sh

set -e

echo "Setting up development environment..."

# تثبيت المكتبات
pip install -r requirements/dev.txt
npm install

# إعداد قاعدة البيانات
docker-compose up -d postgres redis elasticsearch
sleep 5

# تطبيق الهجرات
python manage.py migrate

# تحميل البيانات الأولية
python manage.py loaddata initial_data

# إنشاء مستخدم المدير
python manage.py createsuperuser --noinput

echo "Development environment ready!"
```

```bash
#!/bin/bash
# scripts/deploy.sh

set -e

ENVIRONMENT=$1

if [ -z "$ENVIRONMENT" ]; then
  echo "Usage: ./scripts/deploy.sh [staging|production]"
  exit 1
fi

echo "Deploying to $ENVIRONMENT..."

# بناء Docker
docker build -t afaq/backend:$ENVIRONMENT ./backend
docker build -t afaq/frontend:$ENVIRONMENT ./frontend

# رفع إلى Docker Hub
docker push afaq/backend:$ENVIRONMENT
docker push afaq/frontend:$ENVIRONMENT

# نشر على Railway
railway up --environment $ENVIRONMENT

echo "Deployment to $ENVIRONMENT complete!"
```

---

## ملخص

> **خط أنابيب CI/CD** يشمل: فحص الكود (Ruff/ESLint/Prettier)، اختبارات Python + JavaScript، بناء Docker، نشر تلقائي على Staging ثم Production، إشعارات Slack، وإصدارات GitHub. يدعم Docker Compose للتطوير المحلي.
