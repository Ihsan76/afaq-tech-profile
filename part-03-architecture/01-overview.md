# نظرة عامة على المعمارية

## المخطط العام

```
+-------------------+     +-------------------+     +-------------------+
|                   |     |                   |     |                   |
|   Frontend        |     |    Backend        |     |    Database       |
|   (Next.js)       |<--->|   (Django+DRF)    |<--->|  (PostgreSQL)     |
|                   |     |                   |     |                   |
+-------------------+     +-------------------+     +-------------------+
                                  |
                                  v
                         +-------------------+
                         |                   |
                         |   AI Services     |
                         |   (Multi-Provider)|
                         |                   |
                         +-------------------+
                                  |
                    +-------------+-------------+
                    |             |             |
               +----+----+  +----+----+  +----+----+
               | Gemini  |  | OpenAI  |  | Claude  |
               +---------+  +---------+  +---------+
                    |
               +----+----+  +---------+
               | Ollama  |  | Custom  |
               +---------+  +---------+
```

---

## المبادئ المعمارية

### 1. الفصل بين الاهتمامات (Separation of Concerns)
- الواجهة الأمامية مسؤولة عن العرض والتفاعل فقط
- الخلفية مسؤولة عن المنطق وأمن البيانات
- طبقة AI مستقلة وقابلة للتطوير

### 2. API First
- جميع الوظائف متاحة عبر API
- الواجهة الأمامية عميل فقط
- يسمح بتطوير تطبيقات متعددة (ويب، موبايل، خارجي)

### 3. Versioning
- جميع APIs تبدأ من `/api/v1/`
- إمكانية إصدار إضافات دون كسر الموجود
- وثائق API محدثة تلقائياً

### 4. Modularity
- كل وحدة (app) مستقلة وقابلة للتطوير
- واجهات واضحة بين الوحدات
- سهولة الاختبار والتثبيت

### 5. Scalability
- بنية قابلة للتوسع أفقياً (إضافة خوادم)
- قاعدة بيانات قابلة للتوسع (replication, partitioning)
- caching where needed

### 6. Security First
- الأمان من البناء الأولي
- تشفير البيانات المخزونة والمنقولة
- حماية من الهجمات الشائعة

### 7. Multi-Language First
تعدد اللغات مدمج في بنية المنصة من البداية:

```
المستوى 1: لغة الواجهة (ui_language)
├── 9+ لغات مدعومة
├── RTL/LTR تلقائي
├── خطوط مناسبة لكل لغة
└── تنسيق أرقام وتواريخ

المستوى 2: لغة الإدخال (input_language)
├── ما يكتبه المستخدم
├── محتوى المحادثة مع AI
└── التعليقات والردود

المستوى 3: لغة المخرجات (output_language)
├── خطط الدروس المولّدة
├── ردود المساعد الذكي
├── التقييمات والاختبارات
└── الملخصات

المستوى 4: لغة المحتوى (content_language)
├── الدورات التعليمية
├── المقالات
├── وصف الخدمات
└── المناهج

المستوى 5: لغة النظام (system_language)
├── إشعارات النظام
├── رسائل الخطأ
├── الفواتير
└── التقارير
```

**اللغات المدعومة:**

| اللغة | الكود | RTL | الحالة |
|-------|-------|-----|--------|
| العربية | ar | ✓ | متوفر |
| English | en | ✗ | متوفر |
| Français | fr | ✗ | متوفر |
| Türkçe | tr | ✗ | قادم |
| اردو | ur | ✓ | قادم |
| Español | es | ✗ | قادم |
| Deutsch | de | ✗ | قادم |
| Bahasa Indonesia | id | ✗ | قادم |
| বাংলা | bn | ✗ | قادم |

**المبدأ الأساسي:** المستخدم يختار لغة الواجهة ولغة المخرجات بشكل مستقل — يمكن استخدام واجهة عربية مع مخرجات بالإنجليزية أو الفرنسية.

**كشف اللغة التلقائي:**
- عند أول زيارة (زائر): كشف لغة المتصفح + أقرب لغة مدعومة
- إذا لم تُدعم اللغة: استخدام الإنجليزية كافتراضي
- عند تسجيل الدخول: استخدام `ui_language` من الحساب

> التفاصيل الكاملة في [08-i18n.md](08-i18n.md)

---

## مكونات النظام

### المكون 1: الواجهة الأمامية (Frontend)

| العنصر | التفاصيل |
|--------|----------|
| **الإطار** | Next.js 14+ (App Router) |
| **لغة البرمجة** | TypeScript |
| **تنسيق الأنماط** | Tailwind CSS |
| **مكتبة المكونات** | shadcn/ui |
| **إدارة الحالة** | React Server Components + Client State |
| **ترجمة النصوص** | next-intl |
| **الفحص** | ESLint + Prettier |
| **الاختبارات** | Vitest + Testing Library |

### المكون 2: الخلفية (Backend)

| العنصر | التفاصيل |
|--------|----------|
| **الإطار** | Django 5.x |
| **واجهة البرمجة** | Django REST Framework |
| **لغة البرمجة** | Python 3.12+ |
| **المصادقة** | JWT (SimpleJWT) |
| **التحقق من صحة البيانات** | DRF Serializers |
| **البحث** | django-filter |
| **التوثيق** | drf-spectacular (OpenAPI) |
| **المهام** | Celery + Redis (مستقبلاً) |
| **الفحص** | Ruff + Black |
| **الاختبارات** | pytest + factory_boy |

### المكون 3: قاعدة البيانات

| العنصر | التفاصيل |
|--------|----------|
| **نظام إدارة** | PostgreSQL 16+ |
| **ORM** | Django ORM |
| **الحالة** | psycopg2-binary |
| **الهجرة** | Django Migrations |
| **النسخ الاحتياطي** | pg_dump + cron |
| **الأداء** | فهارس محسّنة |

### المكون 4: طبقة الذكاء الاصطناعي

| العنصر | التفاصيل |
|--------|----------|
| **المزودون** | Gemini, OpenAI, Claude, Ollama, Custom |
| **المعمارية** | Provider Pattern |
| **التوجيه** | Provider Router + Fallback |
| **القوالب** | Prompt Template Engine |
| **التتبع** | AIRun logging |
| **المراقبة** | Stats + Health checks |

### المكون 5: بنية النشر

| العنصر | التفاصيل |
|--------|----------|
| **الحاويات** | Docker + docker-compose |
| **Frontend** | Vercel |
| **Backend** | Railway |
| **قاعدة البيانات** | Railway (PostgreSQL) |
| **التخزين** | Cloudflare R2 أو S3 |
| **CDN** | Cloudflare |
| **المراقبة** | Sentry + logging |

---

## بيئة التطوير

### docker-compose.yml

```yaml
version: '3.8'

services:
  db:
    image: postgres:16
    environment:
      POSTGRES_DB: afaq_dev
      POSTGRES_USER: afaq
      POSTGRES_PASSWORD: dev_secret
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  backend:
    build: ./backend
    command: python manage.py runserver 0.0.0.0:8000
    volumes:
      - ./backend:/app
      - pip_cache:/usr/local/lib/python3.12/site-packages
    ports:
      - "8000:8000"
    depends_on:
      - db
      - redis
    environment:
      - DATABASE_URL=postgres://afaq:dev_secret@db:5432/afaq_dev
      - REDIS_URL=redis://redis:6379/0
      - SECRET_KEY=dev-secret-key-change-in-production
      - DEBUG=1

  frontend:
    build: ./frontend
    volumes:
      - ./frontend:/app
      - /app/node_modules
    ports:
      - "3000:3000"
    depends_on:
      - backend
    environment:
      - NEXT_PUBLIC_API_URL=http://backend:8000/api/v1

volumes:
  postgres_data:
  pip_cache:
```

### Dockerfile — Backend

```dockerfile
FROM python:3.12-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements/ /app/requirements/
RUN pip install --no-cache-dir -r requirements/development.txt

# Copy project
COPY . /app/

EXPOSE 8000

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
```

### Dockerfile — Frontend

```dockerfile
FROM node:20-alpine

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm install

# Copy project
COPY . .

EXPOSE 3000

CMD ["npm", "run", "dev"]
```

---

## بيئة النشر (Production)

### الخيار المُوصى به

| المكون | الخدمة | التكلفة الشهرية |
|--------|--------|-----------------|
| Frontend | Vercel | مجاني (Free tier) |
| Backend | Railway | $5-20 |
| Database | Railway PostgreSQL | $5-20 |
| Storage | Cloudflare R2 | $5-10 |
| CDN | Cloudflare | مجاني |
| Domain | Namecheap | ~$1/شهر |
| Email | Resend | مجاني (100/يوم) |
| Monitoring | Sentry | مجاني (Free tier) |
| **الإجمالي** | | **$15-50/شهر** |

### إعداد النشر

```yaml
# railway.yml
services:
  - name: afaq-backend
    buildCommand: pip install -r requirements/production.txt
    startCommand: gunicorn config.wsgi:application
    envVars:
      - DATABASE_URL
      - SECRET_KEY
      - ALLOWED_HOSTS
      - CORS_ORIGINS

  - name: afaq-frontend
    buildCommand: npm run build
    startCommand: npm start
    envVars:
      - NEXT_PUBLIC_API_URL
```

---

## أمن المعلومات

### طبقات الحماية

```
المستخدم → HTTPS → CDN → Frontend → API Gateway → Backend → Database
              |         |         |           |          |
           TLS 1.3   WAF    CORS+CSRF   Auth+Rate    Encrypted
                                   Limit    at Rest
```

### التشفير

| النوع | الطريقة |
|-------|---------|
| البيانات المخزنة | AES-256 |
| البيانات المنقولة | TLS 1.3 |
| كلمات المرور | Argon2id |
| JWT tokens | RS256 |
| API keys | Encrypted at rest |

### الحماية من الهجمات

| الهجوم | الحماية |
|--------|---------|
| SQL Injection | Django ORM (parametrized queries) |
| XSS | Output encoding + CSP headers |
| CSRF | CSRF tokens + SameSite cookies |
| Brute Force | Rate limiting + account lockout |
| DDoS | Cloudflare + rate limiting |
| Man-in-the-Middle | HTTPS everywhere |

---

## ملخص المعمارية

> **آفاق تكنولوجي** مبنية على معمارية **three-tier** واضحة: واجهة أمامية (Next.js) + خلفية (Django+DRF) + قاعدة بيانات (PostgreSQL)، مع طبقة **AI مستقلة** تدعم عدة مصادر. المعمارية مصممة لل**قابلية للتوسع** و**الأمان** و**سهولة الصيانة** من البداية.
