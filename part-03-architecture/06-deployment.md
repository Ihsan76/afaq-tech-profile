# النشر والبنية التحتية

## فلسفة التكلفة

> **مبدأ أساسي:** في مرحلة **البناء والاختبار** نستخدم خدمات مجانية بالكامل دون إنقاص من الكفاءة. عند **الإطلاق والنشر** نرقّي للخدمات المدفوعة حسب الحاجة.

---

## بيئات النشر

| البيئة | الاستخدام | URL |
|--------|-----------|-----|
| **Development** | تطوير محلي (Docker) | localhost |
| **Staging** | اختبار قبل النشر | staging.afaq.app |
| **Production** | النشر النهائي | afaq.app |

---

## الحالة الحالية — النشر الحي (أغسطس 2026)

> **تم نشر المنصة فعلياً** — تعمل عبر الإنترنت بلا VPN ولا خادم محلي ولا تونل.

```
الإنترنت → Cloudflare (edge — وسيط)
  ├─ afaq.app / www.afaq.app → Vercel (Next.js 16, root frontend/)
  ├─ api.afaq.app             → Render (Django + Gunicorn, service afaq-api-42we)
DNS: Cloudflare (الـ NS انتقل من Namecheap)
DB: Supabase (Transaction Pooler) | Redis: Upstash
```

### ما تم إنجازه
- **Backend على Render** (Docker، port 10000): health `/api/v1/core/health/` → 200، القوائم `/api/v1/pages/menu/header/` → 200، الدخول الصحيح 200 والخاطئ 401.
- **Frontend على Vercel** (Hobby): `afaq.app` → 308 → `www.afaq.app` → 200 (`/ar` و `/en`). كان الدومين مرتبطاً بحساب Vercel آخر — حُل بسجل TXT عند `_vercel`.
- **Cloudflare وسيط إلزامي**: بعض الشبكات تحجب **عناوين Vercel نفسها** (مؤكد بفحص direct + `--resolve`). وضعنا Cloudflare Proxied أمام الفرونت والـ API فيتجاوز الحظر (المتصفح يتصل بـ Cloudflare وهو يجلب من Vercel/Render).
- **DNS**: الـ NS انتقل من Namecheap إلى Cloudflare (`teagan`/`kellen.ns.cloudflare.com`). السجلات: CNAME `@` و`www` → `92117e5bf0e3e63c.vercel-dns-017.com`، CNAME `api` → `<service>.onrender.com`، MX×5 + TXT SPF (بريد Namecheap يستمر). الويب Proxied، والبريد DNS-only.
- **نقل Custom Domain في Render (درس مهم)**: تغيير CNAME وحده **لا ينقل الربط** — يجب حذف الدومين من الخدمة القديمة وإضافته للجديدة في لوحة Render ثم انتظار الشهادة (~2 دقيقة؛ علاماتها HTTPS=TLS fail و HTTP=409 ثم 200).
- **SSL**: Cloudflare Universal SSL + الوضع **Full (strict)**.
- **HSTS**: مفعّل من الخوادم (Vercel وDjango) — لا حاجة لتفعيله من Cloudflare.
- **Keep-alive**: مكوّن `KeepAlive` في الفرونت يرسل ping للصحة كل 10 دقائق أثناء فتح الموقع؛ **مراقب خارجي فعّال** (cron-job.org/UptimeRobot) على `https://api.afaq.app/api/v1/core/health/` كل 1–5 دقائق لضمان 24/7 (الخدمة المجانية تنام بعد 15 دقيقة).
- **`DJANGO_SECRET_KEY`**: لا يُدوَّر بعد النشر — مفاتيح AI في Supabase مشفّرة به.

### الأداء (أغسطس 2026)
- **Upstash (Redis) محجوب إقليمياً** — غير قابل للوصول من بيئة التطوير **ولا من Render** (تأكد بقياس: connect timeout على المنفذ 6379). كان هذا يضيف **+2 ثانية** على كل endpoint (الـ throttle ينتظر `socket_connect_timeout` ثم يسقط صامتاً). الحل:
  - الكاش في الإنتاج = `LocMemCache` (في `production.py`) — بلا شبكة، يكفي لخدمة أحادية.
  - خفض `socket_connect_timeout`/`socket_timeout` إلى **0.3s** في `base.py` كتأمين لو أُعيد ربط Redis لاحقاً.
  - النتيجة: menu/translations من **2.5–3.2s ← ~0.3–0.5s**.
- **ترجمات مصفّاة باللغة**: `TranslationPublicSerializer` يفلتر `?locale=` (كان يعيد كل اللغات **561KB** — الآن ~56KB)؛ الفرونت يمرّر `{ locale }` في `TranslationProvider`.
- **لا N+1**: `select_related('category')` في `BlogPostPublicListView`/`EbookListView` + `annotate(_posts_count)` لتصنيفات المدوّنة.
- **إزالة طوفان الـ prefetch**: حذف `usePrefetch`/`useEffect` التي كانت تُطلق طلب تفاصيل لكل مقال بالتوازي بعد 600ms من تحميل القائمة (`blog/page.tsx`، `BlogListBlock.tsx`).
- **Gemini**: الترحيل إلى الحزمة الحديثة `google-genai` (`from google import genai`) بدل `google.generativeai` (المُهملة) — مجاني (نفس free tier).

### مشكلتان قيد المتابعة
1. **Google Safe Browsing flag**: `www.afaq.app` و`api.afaq.app` مُدرجان "unsafe" (تصنيف قديم من مرحلة البناء — المحتوى الحالي نظيف). تحققت الملكية عبر Search Console (TXT `google-site-verification`) + طلبات مراجعة مقدمة — الرفع عادة خلال 1–3 أيام.
2. **برودة Render المجاني**: ينام بعد 15 دقيقة خمول — يعالج بالـ keep-alive والمراقب الخارجي أعلاه.

---

## مزودو الخدمات

### المرحلة 1: البناء والاختبار (مجاني بالكامل)

| المكون | الخدمة | الحد المجاني | ملاحظات |
|--------|--------|-------------|---------|
| **Frontend** | Vercel (Hobby) | 100GB bandwidth | مثالي للمطورين |
| **Backend** | Render (Free) | 750 hrs/شهر (ينام بعد 15 دقيقة خمول) | Docker + auto-deploy |
| **Database** | Supabase (Free) | 500MB + 50K row | PostgreSQL مكتمل |
| **Redis** | Upstash (Free) | 10K commands/يوم | كافٍ للتطوير |
| **Storage** | Cloudflare R2 (Free) | 10GB storage + 1M requests | S3-compatible |
| **CDN** | Cloudflare (Free) | محدود | كافٍ للبداية |
| **DNS** | Cloudflare (Free) | — | — |
| **Email** | Resend (Free) | 100/يوم + 3000/شهر | كافٍ لـ MVP |
| **AI** | Gemini (Free) | 15 RPM + 1M tokens/يوم | كافٍ للتطوير |
| **Search** | PostgreSQL full-text | — | بدون Elasticsearch |
| **Monitoring** | Sentry (Free) | 5K errors/شهر | كافٍ للبداية |
| **Analytics** | Vercel Analytics (Free) | — | — |
| **CI/CD** | GitHub Actions (Free) | 2000 min/شهر | كافٍ |
| **Uptime** | UptimeRobot (Free) | 50 monitors | — |
| **Error Tracking** | Sentry (Free) | 5K events/شهر | — |
| **الإجمالي** | | **~$0/شهر** | |

> **المحلي (Development):** Docker + PostgreSQL + Redis — بدون أي تكلفة.

### المرحلة 2: الإطلاق الأولي (Hobby/Free tier)

| المكون | الخدمة | التكلفة | متى نرقّي؟ |
|--------|--------|---------|-----------|
| **Backend** | Railway (Hobby) | $5/شهر | عند تجاوز $5 credit |
| **Database** | Supabase (Pro) | $25/شهر | عند تجاوز 500MB |
| **Redis** | Upstash (Pro) | $10/شهر | عند تجاوز 10K cmd/يوم |
| **Storage** | Cloudflare R2 (Pay-as-you-go) | $0.015/GB | عند تجاوز 10GB |
| **AI** | Gemini (Pay-as-you-go) | $0.075/1M tokens | عند تجاوز الحد المجاني |
| **Email** | Resend (Pro) | $20/شهر | عند تجاوز 100/يوم |
| **Monitoring** | Sentry (Team) | $26/شهر | عند تجاوز 5K errors |
| **الإجمالي** | | **~$86/شهر** | |

### المرحلة 3: التوسع (Production)

| المكون | الخدمة | التكلفة/شهر |
|--------|--------|-------------|
| **Frontend** | Vercel (Pro) | $20 |
| **Backend** | Railway (Pro) | $20-50 |
| **Database** | Supabase (Pro) | $25-75 |
| **Redis** | Upstash (Pro) | $10-30 |
| **Storage** | Cloudflare R2 (Standard) | $10-50 |
| **CDN** | Cloudflare (Pro) | $20 |
| **Email** | Resend (Pro) | $20-50 |
| **AI** | Gemini + OpenAI (Pay-as-you-go) | $50-200 |
| **Monitoring** | Sentry + Grafana Cloud | $30-60 |
| **Search** | Elasticsearch (self-hosted) | $0 |
| **الإجمالي** | | **$205-555** |

---

## مقارنة الخدمات المجانية

### قواعد البيانات

| الخدمة | الحد المجاني | SQL | ملاحظات |
|--------|-------------|-----|---------|
| **Supabase** | 500MB + 50K rows | PostgreSQL | الأفضل — ميزات كثيرة |
| **Neon** | 512MB + 100 hrs compute | PostgreSQL | جيد للتطوير |
| **Railway PostgreSQL** | $5 credit | PostgreSQL | ينفد بسرعة |
| **Turso** | 500DB + 9GB storage | SQLite | بديل خفيف |

### Redis / Cache

| الخدمة | الحد المجاني | ملاحظات |
|--------|-------------|---------|
| **Upstash** | 10K cmd/يوم | الأفضل — serverless |
| **Redis Cloud** | 30MB | كافٍ للتطوير |
| **Railway Redis** | $5 credit | ينفد بسرعة |

### التخزين (Object Storage)

| الخدمة | الحد المجاني | ملاحظات |
|--------|-------------|---------|
| **Cloudflare R2** | 10GB + 1M requests | S3-compatible — الأفضل |
| **Cloudinary** | 25GB + 25K transformations | ممتاز للصور |
| **AWS S3** | 5GB لـ 12 شهر | ينتهي بعد سنة |
| **Backblaze B2** | 10GB | بديل رخيص |

### الذكاء الاصطناعي

| الخدمة | الحد المجاني | ملاحظات |
|--------|-------------|---------|
| **Gemini** | 15 RPM + 1M tokens/يوم | الأفضل — مجاني بالكامل |
| **Ollama** | غير محدود (محلي) | بدون إنترنت |
| **Groq** | 30 RPM | سريع جداً |
| **OpenAI** | لا يوجد مجاني | مدفوع فقط |
| **Claude** | لا يوجد مجاني | مدفوع فقط |

### البريد الإلكتروني

| الخدمة | الحد المجاني | ملاحظات |
|--------|-------------|---------|
| **Resend** | 100/يوم + 3000/شهر | الأفضل |
| **Brevo** | 300/يوم | بديل جيد |
| **EmailJS** | 200/شهر | للنماذج فقط |

### المراقبة

| الخدمة | الحد المجاني | ملاحظات |
|--------|-------------|---------|
| **Sentry** | 5K events/شهر | الأفضل للأخطاء |
| **UptimeRobot** | 50 monitors | ممتاز |
| **BetterStack** | 5 monitors | بديل حديث |
| **Grafana Cloud** | 10K metrics | للأداء |

---

## إعداد Docker (للتطوير المحلي)

### docker-compose.yml

```yaml
version: '3.8'
services:
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: afaq_dev
      POSTGRES_USER: afaq
      POSTGRES_PASSWORD: dev_secret
    volumes:
      - pgdata:/var/lib/postgresql/data
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
    ports:
      - "8000:8000"
    depends_on:
      - db
      - redis
    env_file:
      - .env

  frontend:
    build: ./frontend
    volumes:
      - ./frontend:/app
      - /app/node_modules
    ports:
      - "3000:3000"
    depends_on:
      - backend

volumes:
  pgdata:
```

### Dockerfile — Backend

```dockerfile
FROM python:3.12-slim
WORKDIR /app
RUN apt-get update && apt-get install -y gcc libpq-dev
COPY requirements/ /app/requirements/
RUN pip install --no-cache-dir -r requirements/production.txt
COPY . /app/
EXPOSE 8000
CMD ["gunicorn", "config.wsgi:application", "--bind", "0.0.0.0:8000"]
```

### Dockerfile — Frontend

```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build
EXPOSE 3000
CMD ["npm", "start"]
```

---

## متغيرات البيئة

### Backend (.env) — التطوير المحلي

```bash
# Django
DJANGO_SETTINGS_MODULE=config.settings.development
SECRET_KEY=dev-secret-key-change-in-production
DEBUG=1
ALLOWED_HOSTS=localhost,127.0.0.1

# Database (محلي عبر Docker)
DATABASE_URL=postgres://afaq:dev_secret@localhost:5432/afaq_dev

# Redis (محلي عبر Docker)
REDIS_URL=redis://localhost:6379/0

# AI (مجاني)
GEMINI_API_KEY=your-free-gemini-key

# Storage (مجاني — Cloudflare R2)
R2_ACCOUNT_ID=your-account-id
R2_ACCESS_KEY_ID=your-key
R2_SECRET_ACCESS_KEY=your-secret
R2_BUCKET_NAME=afaq-media-dev
R2_ENDPOINT_URL=https://your-account-id.r2.cloudflarestorage.com

# Email (مجاني — Resend)
RESEND_API_KEY=your-free-resend-key
DEFAULT_FROM_EMAIL=noreply@afaq.app
```

### Backend (.env) — النشر (Production)

```bash
# Django
DJANGO_SETTINGS_MODULE=config.settings.production
SECRET_KEY=your-production-secret-key
DEBUG=0
ALLOWED_HOSTS=afaq.app,staging.afaq.app
CORS_ORIGINS=https://afaq.app,https://staging.afaq.app

# Database (Supabase)
DATABASE_URL=postgres://user:pass@db.supabase.co:5432/postgres

# Redis (Upstash)
REDIS_URL=redis://default:pass@upstash.io:6379

# AI
GEMINI_API_KEY=your-key
OPENAI_API_KEY=your-key  # اختياري — احتياطي

# Storage (Cloudflare R2)
R2_ACCOUNT_ID=your-account-id
R2_ACCESS_KEY_ID=your-key
R2_SECRET_ACCESS_KEY=your-secret
R2_BUCKET_NAME=afaq-media
R2_ENDPOINT_URL=https://your-account-id.r2.cloudflarestorage.com

# Email (Resend)
RESEND_API_KEY=your-key
DEFAULT_FROM_EMAIL=noreply@afaq.app

# الدفع (مزوّدات متعددة — أغسطس 2026)
PAYMENT_PROVIDER=auto           # auto | stripe | myfatoorah (auto = أول مهيّأ، أولوية stripe ثم myfatoorah)

# Stripe
STRIPE_SECRET_KEY=sk_test_...    # أو sk_live_...
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...  # من لوحة Stripe → Developers → Webhooks

# MyFatoorah (موصى بها للتاجر الأردني/الخليج)
MYFATOORAH_API_TOKEN=...         # API Token من لوحة MyFatoorah
MYFATOORAH_BASE_URL=             # فارغ = Test (apitest.myfatoorah.com)؛ Live: https://api.myfatoorah.com
MYFATOORAH_WEBHOOK_SECRET=...    # Secret Key لـ Webhook V2 (من صفحة Webhook في البوابة)
MYFATOORAH_PAYMENT_METHOD_ID=0   # 0 = صفحة فواتير بكل طرق الدفع المفعّلة
```

> **Webhooks (سجّلها في كل لوحة):**
> - Stripe: `https://api.afaq.app/api/v1/marketplace/payments/webhook/stripe/` مع حدث `checkout.session.completed`.
> - MyFatoorah: `https://api.afaq.app/api/v1/marketplace/payments/webhook/myfatoorah/` (Webhook V2، توقيع `Myfatoorah-Signature` = HMAC-SHA256 base64). فعّل **Secure Key** في صفحة Webhook البوابة واجعل `MYFATOORAH_WEBHOOK_SECRET` تطابقه.
> - بدون أي مفاتيح يعمل النظام بلا دفع (الطلبات تُنشأ `payment_status=pending` وتظهر "الدفع غير متاح").
> - **ملاحظة**: Stripe غير متاح للتاجر الأردني (يلزم كيان أمريكي) — MyFatoorah هي البوابة الفعلية للأردن/الخليج.

> **الباقات والاشتراكات (apps/subscriptions — أغسطس 2026):**
> - الباقات (free/pro/school/enterprise) تُزرع تلقائياً عند أي deploy عبر data migration `0002_seed_plans` — لا حاجة لخطوة يدوية. تعديل الأسعار/الميزات من Django Admin `/admin/subscriptions/plan/`. (في التطوير: `cd backend && ./venv/bin/python seed_plans.py` لإعادة الزرع يدوياً.)
> - نفس الـ webhooks أعلاه تعالج أيضاً اشتراكات الباقات: يُعرف النوع من metadata Stripe (`kind=subscription`) أو `UserDefinedField="subscription:<id>"` في MyFatoorah — يفعّل الاشتراك ويرفع `subscription_plan` للمستخدم فوراً.
> - واجهات: `GET /api/v1/subscriptions/plans/` (عام) + `GET /current/` و`POST /purchase/` (مصادقة) + `admin/plans/` (مدير). عودة المشتري إلى `/subscriptions/?session_id=…|paymentId=…`.

### Frontend (.env.local)

```bash
NEXT_PUBLIC_API_URL=http://localhost:8000/api/v1  # محلي
# NEXT_PUBLIC_API_URL=https://afaq.app/api/v1    # نشر
NEXT_PUBLIC_APP_URL=http://localhost:3000
# NEXT_PUBLIC_APP_URL=https://afaq.app
```

---

## إعداد Vercel (Frontend)

```json
{
  "buildCommand": "npm run build",
  "outputDirectory": ".next",
  "framework": "nextjs",
  "regions": ["fra1"],
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        {"key": "X-Content-Type-Options", "value": "nosniff"},
        {"key": "X-Frame-Options", "value": "DENY"},
        {"key": "X-XSS-Protection", "value": "1; mode=block"}
      ]
    }
  ]
}
```

---

## إعداد Render (Backend)

```yaml
# render.yaml (اختياري) — أو الإعداد من اللوحة
services:
  - type: web
    name: afaq-api
    rootDir: backend
    runtime: docker
    healthCheckPath: /api/v1/core/health/
    envVars:
      - key: DJANGO_SETTINGS_MODULE
        value: config.settings.production
```
- **Health Check Path**: `/api/v1/core/health/`
- **Port**: 10000 (مضبوط في Dockerfile/entrypoint)
- **فرع**: master (auto-deploy)

---

## CI/CD

```yaml
# .github/workflows/ci.yml — الفحص الآلي عند كل push
name: CI
on:
  push:
    branches: [master]
  pull_request:

jobs:
  backend-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Django check + Ruff
        working-directory: backend
        run: |
          pip install -r requirements.txt
          ruff check apps tests config --exclude "*migrations*"
          python manage.py check
```

> **النشر تلقائي عند الدفع إلى `master`**: Vercel يعيد بناء الفرونت، وRender يعيد نشر الباكند (متصلان بالمستودع GitHub مباشرة) — لا حاجة لـ Actions للنشر. عيّن متغيرات البيئة في لوحة كل خدمة.

---

## المراقبة

| الأداة | الاستخدام | المجاني؟ |
|--------|-----------|---------|
| **Sentry** | Error tracking | ✓ (5K events/شهر) |
| **Railway Metrics** | CPU, Memory, Network | ✓ |
| **Vercel Analytics** | Web vitals, page views | ✓ |
| **UptimeRobot** | Uptime monitoring | ✓ (50 monitors) |
| **Google Analytics** | User behavior | ✓ |

---

## ملخص

> **القاعدة الذهبية:** ابدأ مجاناً → رقّي عند الحاجة.
>
> - **التطوير:** Docker محلي — $0
> - **الاختبار:** Vercel Free + Railway $5 credit + Supabase Free + Upstash Free + Gemini Free — **$0-5/شهر**
> - **الإطلاق:** رقّي تدريجياً حسب الحمل — **$50-200/شهر**
> - **التوسع:** باقات Pro — **$200-500/شهر**
