# قائمة التحقق الشاملة (Checklist)

## ما قبل البدء

### الحسابات والخدمات
- [x] إنشاء حساب GitHub + مستودع المشروع ✅
- [x] إنشاء حساب Vercel + ربط المستودع ✅
- [x] إنشاء حساب **Render** + إنشاء الخدمة (`afaq-api-42we`) ✅
- [x] إنشاء حساب Cloudflare + إضافة الدومين (`afaq.app`) ✅
- [x] إنشاء حساب Supabase ✅
- [x] إنشاء حساب Upstash (Redis) ✅
- [x] إنشاء حساب Resend (بريد إلكتروني) ✅
- [ ] إنشاء حساب Twilio (رسائل نصية — اختياري)
- [x] إنشاء حساب Sentry (مراقبة أخطاء) ✅
- [ ] إنشاء حساب Stripe/Paymob (دفع — اختياري للمVP)
- [x] إنشاء حساب Google Cloud + Gemini API Key ✅
- [ ] إنشاء حساب OpenAI (اختياري — احتياطي)
- [x] شراء الدومين afaq.app — حي ومنشور، NS عند Cloudflare ✅

### بيئة التطوير
- [x] تثبيت Docker + Docker Compose ✅
- [x] تثبيت Python 3.12+ ✅
- [x] تثبيت Node.js 20+ ✅
- [x] تثبيت PostgreSQL 16+ — **غير مطلوب محلياً**: قاعدة البيانات عبر Supabase المستضافة (Transaction Pooler)، ولا توجد خدمة postgres في `docker-compose.yml` ✅
- [x] تثبيت Redis — حاوية docker محلية `afaq_redis` (redis:7-alpine على 6379) ✅
- [ ] إعداد Git hooks (pre-commit) — مقترح كتحسين كفاءة، لم يُنفَّذ بعد
- [ ] إعداد IDE (VS Code + extensions) — بيئة شخصية، غير قابلة للتحقق من الكود

---

## المرحلة 0: البنية التحتية (أسبوع 1-2)

### Backend
- [x] إنشاء مشروع Django + DRF ✅
- [x] إعداد Docker + docker-compose ✅
- [x] إعداد PostgreSQL + اتصال ✅
- [x] إعداد Redis + اتصال — `CACHES` → django-redis على `REDIS_URL`؛ dev محلي، prod عبر compose ✅
- [x] إعداد Celery + Redis — **غير مطلوب حالياً**: لا مهام خلفية (توليد الذكاء متزامن/streaming)؛ Redis محجوب إقليمياً في الإنتاج ✅
- [x] إعداد CORS headers ✅
- [x] إعداد JWT (SimpleJWT) ✅
- [ ] إعداد Logging (JSON format) — logging مفعل (console verbose) لكن الصيغة ليست JSON بعد
- [x] إعداد Sentry ✅
- [x] إعداد Health check endpoint — `GET /api/v1/core/health/` (view عادي بلا throttle → سريع ~0.45s)؛ مستخدم في Docker HEALTHCHECK + `KeepAlive` + المراقب الخارجي ✅
- [x] إعداد Environment variables ✅

### Frontend
- [x] إنشاء مشروع Next.js 16+ (App Router) ✅
- [x] إعداد TypeScript ✅
- [x] إعداد Tailwind CSS ✅
- [x] إعداد shadcn/ui — **غير مستخدم**: مكونات مخصصة بـ Tailwind ✅
- [x] إعداد next-intl (تعدد اللغات) ✅
- [x] إعداد ESLint + Prettier ✅
- [x] إعداد Docker (الفرونت) — `frontend/Dockerfile` + خدمة `frontend` في `docker-compose.yml` موجودان ✅ (النشر الفعلي عبر Vercel build، لا Docker)

### DevOps
- [x] إعداد GitHub Actions (CI) — `.github/workflows/ci.yml`: Backend (ruff + pytest + django check) + Frontend (eslint + tsc + build) ✅
- [x] إعداد linting (Ruff + ESLint) — `backend/ruff.toml` (E/F/W/I/UP/B/C4/SIM) + ESLint ✅
- [x] إعداد اختبارات أساسية — `backend/tests/` (12 اختباراً: auth + academics + curriculum resolve) عبر `config.settings.testing` (SQLite + locmem) ✅
- [x] إعداد Docker build — docker-compose + Dockerfile للباكند والفرونت ✅
- [ ] إعداد Branch protection — إعدادات GitHub بيد المالك

---

## المرحلة 1: المستخدمون (أسبوع 3-4)

### نموذج المستخدم
- [x] نموذج User المخصص (AbstractUser) ✅
- [x] حقول اللغة الأربعة (ui_language, input_language, output_language, source_locale) ✅
- [x] UserManager مخصص ✅
- [ ] نموذج UserProfile — غير منفّذ (بيانات إضافية في حقول User/JSON)
- [x] نموذج LoginAttempt — موجود في `apps/users/models.py` (حماية brute-force) ✅
- [ ] نموذج UserSession — غير منفّذ
- [x] الهجرات (migrations) ✅
- [x] Seed data (بيانات أولية) — مستخدم admin + seed_translations + seed بيانات المناهج/السوق ✅

### APIs المصادقة
- [x] POST /api/v1/auth/register/ ✅
- [x] POST /api/v1/auth/login/ ✅
- [x] POST /api/v1/auth/refresh/ ✅
- [x] POST /api/v1/auth/logout/ ✅
- [x] POST /api/v1/auth/password-reset/ ✅
- [x] POST /api/v1/auth/password-reset/confirm/ ✅
- [x] GET /api/v1/auth/profile/ ✅
- [x] PUT /api/v1/auth/profile/ ✅
- [x] Rate limiting على APIs الدخول ✅
- [x] POST /api/v1/auth/verify-email/ ✅
- [x] POST /api/v1/auth/verify-email/confirm/ ✅
- [x] GET /api/v1/auth/google/ ✅
- [x] GET /api/v1/auth/google/callback/ ✅

### الواجهة الأمامية
- [x] شاشة تسجيل الدخول ✅
- [x] شاشة التسجيل ✅
- [x] شاشة التحقق من البريد — `frontend/src/app/[locale]/verify-email/page.tsx` ✅
- [x] شاشة إعادة تعيين كلمة المرور ✅
- [x] صفحة الملف الشخصي / لوحة التحكم ✅
- [x] مكون LanguageSwitcher ✅
- [x] حفظ اللغة في localStorage + cookie — **البديل المعتمد**: تُحفظ في مسار URL (segment) بدل localStorage/cookie (أفضل للـ SEO) ✅

### الأمان
- [x] تشفير كلمات المرور (Argon2id) ✅
- [x] JWT RS256 ✅
- [x] Brute force protection (5 محاولات / 15 دقيقة) ✅
- [x] CSRF protection (Bearer header — غير سارية) ✅
- [x] تأكيد البريد الإلكتروني (رمز عبر Resend) ✅
- [x] Google OAuth (تدفق كامل — ينتظر client ID/secret) ✅
- [x] Input validation — عبر DRF serializers (settings/translations) ✅

---

## المرحلة 2: الأكاديمية (أسبوع 5-6)

### النماذج
- [x] نموذج Grade (المراحل الدراسية) ✅
- [x] نموذج Subject (المواد) ✅
- [x] نموذج Curriculum (المناهج) ✅
- [x] نموذج Unit (الوحدات) ✅
- [x] الهجرات (migrations) ✅
- [x] نموذج Language (في `apps/core`) ✅
- [x] نموذج TranslationKey (1305 مفتاحاً في `apps.core`) ✅
- [x] Seed data (مناهج + مواد + مراحل) — seed_curricula + 46 وحدة ✅

### APIs
- [x] GET /api/v1/academics/grades/ ✅
- [x] GET /api/v1/academics/subjects/ ✅
- [x] GET /api/v1/academics/curricula/ ✅
- [x] GET /api/v1/academics/curricula/{id}/units/ ✅
- [x] CRUD للمناهج (Admin) ✅

### الواجهة الأمامية
- [x] شاشة اختيار المرحلة ✅
- [x] شاشة اختيار المادة ✅
- [x] شاشة عرض المناهج ✅
- [x] شاشة إدارة المناهج (Admin) ✅

---

## المرحلة 3: خطط الدروس (أسبوع 7-8)

### النماذج
- [x] نموذج LessonPlan ✅
- [x] نموذج AIRun (سجلات AI) ✅
- [x] نموذج LessonPlanRefinement (تعديل تفاعلي) ✅
- [x] حقل `is_public` + `likes_count` + `clones_count` + `downloads_count` + `original_plan` للماركت بليس ✅
- [x] نموذج CurriculumDocument (رفع ملفات المنهاج مع استخراج النص) ✅

### APIs
- [x] POST /api/v1/lesson-plans/generate/ ✅
- [x] GET /api/v1/lesson-plans/ ✅
- [x] GET /api/v1/lesson-plans/{id}/ ✅
- [x] DELETE /api/v1/lesson-plans/{id}/delete/ ✅
- [x] POST /api/v1/lesson-plans/{id}/duplicate/ ✅
- [x] POST /api/v1/lesson-plans/{id}/refine/ (تعديل تفاعلي عبر AI) ✅
- [x] POST /api/v1/lesson-plans/{id}/worksheet/ ✅
- [x] POST /api/v1/lesson-plans/{id}/homework/ ✅
- [x] POST /api/v1/lesson-plans/{id}/toggle-public/ ✅
- [x] POST /api/v1/lesson-plans/{id}/clone/ ✅
- [x] POST /api/v1/lesson-plans/{id}/like/ ✅
- [x] GET /api/v1/lesson-plans/marketplace/ ✅
- [x] GET /api/v1/lesson-plans/smart-prompts/ ✅
- [x] GET /api/v1/auth/me/stats/ (نقاط/شارات/مستوى/سلسلة — ليست `/users/me/stats/`) ✅
- [x] تصدير PDF (WeasyPrint — RTL, Noto Naskh Arabic, worksheet/homework page breaks) ✅

### الذكاء الاصطناعي
- [x] إعداد Gemini API ✅
- [x] قوالب الاستعلامات (بـ 9 لغات، عبر DB) ✅
- [x] تسجيل استعلامات AI (AIRun) ✅
- [x] Semantic Caching (SHA256 + Redis) ✅
- [x] **Redis فعلي**: django-redis + CACHES في `config/settings/base.py` يربط `REDIS_URL` (تطوير: حاوية docker محلية `afaq_redis` على 6379). **ملاحظة (أغسطس 2026)**: Upstash محجوب إقليمياً — غير قابل للوصول من بيئة التطوير **ولا من Render** (تأكد بالقياس: connect timeout). لذلك في الإنتاج استُبدل الكاش بـ `LocMemCache` (في `production.py`) وخُفّض `socket_connect_timeout`/`socket_timeout` إلى 0.3s في `base.py` كتأمين لأي عودة مستقبلية. هذا الإصلاح أزال تأخير +2 ثانية كان يُحرقه throttle على كل endpoint. ✅
- [x] PromptBuilderService (اختيار القالب حسب السياق) ✅
- [x] Curriculum Injection (إدراج نصوص المنهاج) ✅
- [x] **الربط التلقائي بالمنهاج الرسمي** (تمايز): نموذج Unit أصبح يتضمن `subject` + `outcomes` + `content`؛ سكربت `seed_curricula.py` (مناهج السعودية + الأردن، 46 وحدة بنواتج تعلم)؛ endpooint `GET /academics/curricula/resolve/?grade=&subject=`؛ حقن الوحدات ونواتج التعلم تلقائياً في توليد الخطة (وحدة محددة أو تلقائية)؛ منتقي وحدة في `lesson-plans/new`؛ إصلاح قالب AR الافتراضي ليتضمن `curriculum_context` ✅
- [x] Refinement (تعديل الخطة) ✅
- [x] Worksheet/Homework generation ✅
- [x] Smart Prompts (4 اقتراحات) ✅
- [x] Provider Router الرسمي (BaseProvider ABC — Gemini/OpenAI/Ollama) ✅
- [x] CircuitBreaker + TokenBucket rate limiting + semantic caching ✅
- [x] **ترحيل Gemini إلى `google.genai`** (الحزمة الحديثة) — استبدال `google.generativeai` (المُهملة) في `router.py`/`services.py`/`views.py`؛ Client بدل configure/GenerativeModel، `chats.create` + `send_message_stream` للدردشة، `models.list` للنماذج، وتحديث `requirements.txt` → `google-genai`. مجاني (نفس free tier). ✅

### الواجهة الأمامية
- [x] شاشة إنشاء خطة درس ✅
- [x] شاشة عرض خطة الدرس ✅
- [x] شاشة تعديل خطة الدرس (عبر Refinement modal) ✅
- [x] شاشة قائمة الخطط ✅
- [x] شاشة سوق الخطط (Marketplace) ✅
- [x] طباعة مع إخفاء nav/footer (CSS @media print) ✅
- [x] طباعة ورقة العمل بنافذة منفصلة ✅
- [x] FadeIn animations (4 صفحات) ✅
- [x] 9 لغات لمفاتيح السوق ✅
- [x] تصدير PDF (مع locale param, عناوين عربية/إنجليزية) ✅

---

## المرحلة 4: لوحة التحكم (أسبوع 9-10)

### لوحة تحكم المعلم
- [x] إحصائيات سريعة ✅
- [x] آخر الخطط المولّدة ✅
- [x] إنشاء خطة جديدة ✅
- [x] إدارة الحساب ✅

### لوحة تحكم الطالب
- [x] الدورات المسجل بها ✅
- [x] التقدم في التعلم ✅
- [x] الإحصائيات ✅

### لوحة تحكم المدير
- [x] إدارة المستخدمين ✅
- [x] إدارة المناهج ✅
- [x] إدارة المنتجات (السوق: تصنيفات/خدمات/طلبات/مراجعات) ✅
- [x] مراقبة AI (سجلات AIRun + فلاتر + إحصائيات) ✅
- [x] التقارير (إحصائيات منصة شاملة في صفحة /admin) ✅

---

## المرحلة 5: التكامل الأساسي (أسبوع 11-14)

### Page Builder ✅
- [x] نموذج Page + PageBlock (40 نوع) ✅
- [x] نموذج MenuItem + PageTemplate + SiteSettings ✅
- [x] APIs الصفحات والبلوكات ✅
- [x] BlockRenderer.tsx (29 كمبوننت مربوط) ✅
- [x] BlockEditorPanel (محرر محتوى البلوكات + RichTextEditor) ✅
- [x] DynamicPage (عرض ديناميكي) ✅
- [x] 6 ثيمات + ThemeSwitcher ✅
- [x] 14 صفحة مُهيأة + 62 بلوك ✅
- [x] 12 مكون جديد (Accordion, Tabs, Timeline, Countdown, Newsletter, Map, Table, IconList, LogoCarousel, Download, Code, BlogList) ✅

### i18n
- [x] إعداد next-intl (10 لغات) ✅
- [x] ترجمة واجهة المستخدم — messages لـ10 لغات (1018 مفتاح) ✅
- [ ] ترجمة رسائل الخطأ — رسائل الواجهة مُترجمة؛ أخطاء DRF الإنجليزية دون ترجمة po
- [x] RTL/LTR تلقائي ✅
- [x] اللغة الافتراضية: الإنجليزية للزوار — `defaultLocale = "en"` في `i18n/config.ts` ✅
- [ ] كشف اللغة من Accept-Language — لا middleware حالياً؛ يقع على "en"

### SEO
- [x] hreflang tags — `alternates.languages` في `[locale]/layout.tsx` ✅
- [x] sitemap.xml لكل لغة — `src/app/sitemap.ts` (كل اللغات: صفحات ثابتة + CMS عبر menu عام + curriculum grades + blog + ebooks)؛ أُصلح endpoint مسؤول 401 ✅
- [x] Open Graph tags — `src/app/layout.tsx` ✅
- [x] JSON-LD structured data — Organization + WebSite schema ✅
- [x] robots.txt — `src/app/robots.ts` ✅
- [ ] صفحات "use client" لا تصدّر `generateMetadata` — تحتاج فصل server wrapper لتحسين SSR/SEO (CSR حالياً)

### الأمان
- [x] HTTPS everywhere — SECURE_SSL_REDIRECT + HSTS preload + شهادات Cloudflare ✅
- [ ] CSP headers — غير مفعل بعد
- [x] Rate limiting (API) — DRF throttle: DEFAULT_THROTTLE_CLASSES/RATES + استثناء health ✅
- [x] Input sanitization — DRF validation + Django template escaping ✅
- [x] SQL injection protection (ORM) — ضمني عبر Django ORM parameterized ✅
- [x] XSS protection — ضمني عبر Django/React escaping ✅

---

## المرحلة 6: النشر (أسبوع 15-16)

### Frontend — ✅ مُنجز (Vercel)
- [x] إعداد Vercel (Next.js، root `frontend/`) ✅
- [x] ربط الدومين (`afaq.app` + `www` + TXT `_vercel` للملكية) ✅
- [x] إعداد SSL (Cloudflare Universal SSL + Full strict) ✅
- [x] إعداد DNS (نقل الـ NS إلى Cloudflare + CNAME `@`/`www` → `92117e5bf0e3e63c.vercel-dns-017.com`) ✅
- [ ] اختبار PWA — لا PWA بعد (Service Worker قيد المستقبل)

### Backend — ✅ مُنجز (Render)
- [x] إعداد **Render** (Docker، service `afaq-api-42we`، port 10000) ✅
- [x] إعداد PostgreSQL (Production — Supabase Transaction Pooler) ✅
- [x] إعداد Redis (Production — Upstash) ✅
- [x] إعداد Environment variables (من `backend/.env` + Upstash + `DJANGO_SECRET_KEY` ثابت) ✅
- [x] اختبار Health check (`/api/v1/core/health/` → 200) ✅
- [x] **نقل Custom Domain** `api.afaq.app` من الخدمة القديمة للجديدة في لوحة Render (خطوة حرجة) ✅
- [x] Keep-alive خارجي (cron-job.org/UptimeRobot كل 1–5 دقائق) لضمان 24/7 — **مُنجز**: مراقب خارجي أُنشئ على `https://api.afaq.app/api/v1/core/health/` ✅

### CDN — ✅ مُنجز (Cloudflare)
- [x] إعداد Cloudflare (zone `afaq.app` + وسيط Proxied أمام Vercel/Render) ✅
- [ ] إعداد Cache rules — مؤجلة بقرار المستخدم (قيد المراجعة)
- [ ] إعداد WAF rules
- [ ] إعداد Page rules

### Monitoring
- [x] إعداد Sentry ✅
- [x] إعداد Uptime monitoring (cron-job.org/UptimeRobot) — مراقب خارجي فعّال على health ✅
- [ ] إعداد Error alerts

### الأمان — قيد المتابعة
- [ ] **مراقبة رفع Google Safe Browsing flag** لـ `www.afaq.app` و`api.afaq.app` (طلبات مراجعة مقدمة)
- [ ] اختبار التنبيهات

### Backup
- [ ] إعداد pg_dump يومي
- [ ] إعداد S3/R2 للنسخ الاحتياطي
- [ ] اختبار الاستعادة

---

## ما بعد الإطلاق (MVP)

### المراقبة
- [ ] مراقبة أداء API — المراقبة الخارجية (up/down) منجزة؛ القياسات البرمجية قيد العمل
- [x] مراقبة أخطاء Sentry — sentry_sdk مفعل في `settings/base.py` + `sentry-sdk` في requirements ✅
- [x] مراقبة وقت التشغيل — عبر cron-job.org (مراقب خارجي كل 1–5 دقائق على health) ✅
- [ ] مراقبة استطاعات Core Web Vitals

### التحسين
- [x] تحسين سرعة التحميل — **منفّذ (أغسطس 2026)**، انظر قسم «تحسينات الأداء» أدناه ✅
- [ ] تحسين SEO
- [ ] تحسين معدل التحويل
- [ ] إصلاح الأخطاء

### تحسينات الأداء المنفذة (أغسطس 2026)
- [x] **إزالة تأخير Redis**: الكاش في الإنتاج → `LocMemCache` (لأن Upstash محجوب إقليمياً من Render أيضاً) + خفض `socket_connect_timeout` إلى 0.3s — أزال +2 ثانية كان throttle ينتظرها على كل endpoint (المقاس: menu/translations كانت 2.5–3.2s ← أصبحت ~0.3–0.5s). ✅
- [x] **فلترة الترجمات باللغة**: `TranslationPublicSerializer` يرجع قيم اللغة المطلوبة فقط (`?locale=ar` → `{ar:...}` بدل كل اللغات) — الحمولة انخفضت من **561KB إلى ~56KB**؛ الفرونت يمرّر `{ locale }` في `TranslationProvider`. ✅
- [x] **إصلاح N+1 في المدوّنة والكتب**: `select_related('category')` في `BlogPostPublicListView` و`EbookListView` + `annotate(_posts_count)` لتصنيفات المدوّنة. ✅
- [x] **إزالة طوفان الـ prefetch**: حذف `usePrefetch`/`useEffect` التي كانت تُطلق طلب تفاصيل لكل مقال بالتوازي بعد 600ms من تحميل القائمة (في `blog/page.tsx` و`BlogListBlock.tsx`) — كانت تُغرق Gunicorn أحادي الخدمة. ✅
- [x] **بطاقات كتب إلكترونية محسّنة**: غلاف افتراضي بتدرج لوني + عنوان الكتاب بدل الأيقونة `📚`، وحركة hover للغلافات الموجودة. ✅

### إصلاحات أغسطس 2026
- [x] **إصلاح صور الدورات (كاش الـ SW)**: `sw.js` يعترض التنقّل فقط (`mode !== "navigate"`) — الصور الخارجية (يوتيوب/Supabase) تُجلب من الشبكة دائماً؛ كاش التنقّل cache-first مع تحديث خلفي دوري (TTL 5 دقائق عبر `x-sw-cached-at`)؛ ترقية الكاش إلى `afaq-tech-v2` (تفريغ v1 القديم عند التفعيل)؛ `Cache-Control: no-cache` لـ `/sw.js` في `next.config.ts`؛ SWR `revalidateOnFocus`+`revalidateOnReconnect` في `src/lib/useApi.ts` — كانت الصور لا تُحمّل إلا بعد Ctrl+Shift+R. ✅
- [x] **القوائم متعددة الاختيار (Multi-select)**: `service_context` و `required_role` في `MenuItem` أصبحا `ArrayField` (مهاجرة 0015 بتحويل البيانات: قيمة مفردة ← مصفوفة، `all` ← الكل) + `ChoiceListField` في serializers + فلترة `MenuPublicView` بـ `__contains` (فارغة = الكل، تُعرض أولاً) + مكوّن `MultiSelectDropdown` في `/admin/menus` (الكل محدد افتراضياً + أزرار تحديد/إلغاء + شارات "كل الصفحات/كل الأدوار") + `roleAllowed` في `ContextualSidebar` يدعم مصفوفات الأدوار + `seed_menus.py` بمصفوفات + ترجمات 10 لغات (`selectAll`/`deselectAll`/`allPages`/`noSelection`). ✅
- [x] **المحتوى المدفوع ومحفظة الأرباح (أغسطس 2026)**: دورات وكتب بشراء مدى الحياة (`CoursePurchase`/`EbookPurchase`)، توزيع أرباح المدربين/المؤلفين بخصم رسوم المنصة 10% عبر نموذج `Wallet` و `WalletTransaction` ودالة `credit_earnings()`، مع حماية بـ 402/403. ✅
- [x] **تنظيم لوحة الإدارة (أغسطس 2026)**: إعادة هيكلة قائمة الإدارة الجانبية وبطاقات الصفحة الرئيسية `/admin` إلى 5 أقسام رئيسية متكاملة (المحتوى والإعدادات، التعليم والأكاديمية، السوق والذكاء الاصطناعي، التواصل والمدونة، المستخدمون والمالية) ومنع تداخل `ContextualSidebar` في مسارات الإدارة. ✅
- [x] **إصلاح تعديل المستخدمين**: معالجة حقل `national_id` الفارغ بتحويله تلقائياً إلى `NULL` لتجنب خطأ انتهاك قيد التفرد (`UniqueConstraint`) في قاعدة البيانات عند التعديل من لوحة الإدارة. ✅

### جمع الملاحظات
- [ ] نموذج ملاحظات
- [ ] صفحة اقتراحات
- [ ] مراجعة تقييمات المستخدمين

---

## المراحل التالية (بعد MVP)

### المرحلة 7: الدورات
- [x] نموذج Course + Enrollment — Course/CourseCategory/Chapter/Lesson/Enrollment موجودة في `apps/courses/models.py` ✅
- [x] APIs الدورات — قائمة/تفاصيل/تسجيل/إكمال دروس/MyEnrollments في `apps/courses/urls.py` ✅
- [x] شاشات الدورات — `academy/courses` + `[slug]/learn` + `admin/courses` ✅

### المرحلة 8: المدوّنة ✅
- [x] نموذج BlogCategory + BlogPost ✅
- [x] APIs المدوّنة (عامة + إدارية) ✅
- [x] شاشات المدوّنة (قائمة + تفاصيل + إدارة) ✅
- [x] 5 تصنيفات + 7 مقالات مُهيأة ✅
- [x] RichTextEditor (TipTap) في Blog admin ✅
- [x] Django admin مع زر رجوع مخصص ✅

### المرحلة 9: السوق — منفّذ جزئياً ✅
- [x] مشاركة الخطط (is_public, toggle-public) ✅
- [x] إعجاب (likes_count) ✅
- [x] استنساخ (clones_count, original_plan) ✅
- [x] سوق الخطط العامة (MarketplaceListView) ✅
- [x] بطاقات مع subject_name, grade_name, user_name, likes, clones ✅
- [x] ترجمة 9 لغات للسوق ✅
- [x] نموذج Service (خدمات مدفوعة) — Service/ServiceCategory/ServiceAvailability موجودة ✅
- [x] Orders + Reviews — Order + Review في `apps/marketplace/models.py` ✅
- [x] لوحة تحكم المزود — `admin/marketplace` + صفحة إنشاء خدمة ✅

### المرحلة 9: السوق — منفّذ بالكامل ✅
- [x] نموذج ServiceCategory + Service (عناوين/أوصاف متعددة اللغات JSON) ✅
- [x] نموذج ServiceAvailability (جلسات/تيار مستمر) ✅
- [x] نموذج Order (مع حالات: pending, confirmed, cancelled, completed) ✅
- [x] نموذج Review ✅
- [x] 10 API endpoints: categories, services, availability, orders, reviews ✅
- [x] 4 صفحات أمامية: قائمة، تفاصيل مع حجز، طلبات، إنشاء خدمة ✅
- [x] 9 لغات في حقول العناوين/الأوصاف ✅
- [x] Admin مسجل ✅
- [x] CurriculumDocument: استخراج النص من PDF/TXT + endpoint POST documents/pk/extract/ ✅

### المرحلة 10: الدفع
- [x] تكامل Stripe/Paymob — **واجهة مزوّدات موحّدة لأوردرات السوق** (إنشاء الطلب → `checkout_url` → Stripe Checkout أو MyFatoorah → عودة إلى orders → webhook → `paid`+`confirmed`؛ إعادة دفع عبر `orders/<id>/checkout/`؛ `PAYMENT_PROVIDER=auto|stripe|myfatoorah`) 🔶 (المحفظة والسحب مؤجلة) — ينقص فقط مفاتيح الحساب في Render
- [ ] نموذج Wallet (محفظة)
- [x] نموذج Subscription + Plan — تطبيق `apps/subscriptions` (Plan, Subscription, Organization, OrganizationMembership, SeatPurchase) + باقات free/pro/school/enterprise تُزرع عبر data migrations ✅
- [x] APIs الاشتراكات — `plans/`, `current/`, `purchase/`, `usage/`, `organizations/*` + admin plans؛ صفحة `/subscriptions` ✅
- [ ] رسوم السوق (Marketplace Fees)
- [ ] السحب للمزوّدين (Payouts)

### المرحلة 11: Gamification — منفّذ (باك إند) ✅
- [x] نقاط (PointsManager + PointsTransaction) ✅
- [x] شارات (BadgeCategory, Badge, UserBadge, 5 فئات نادرة) ✅
- [x] إنجازات (Achievement, UserAchievement — فردي/تدريجي/سري) ✅
- [x] تحديات (Challenge, ChallengeParticipant — يومي/أسبوعي/شهري/خاص) ✅
- [x] سلاسل يومية (UserStreak مع مكافآت 3-7-14-30 يوم) ✅
- [x] لوحة متصدرين (Leaderboard — نقاط/خطط/سلاسل/شارات) ✅
- [x] مستويات (Level مع نقاط مطلوبة) ✅
- [x] 16 نشاطاً في PointsManager ✅
- [x] 16 API endpoint تحت `/api/v1/gamification/` ✅
- [x] AliAdmin (جميع النماذج في Django Admin) ✅
- [x] ربط مع إنشاء الخطة: PointsManager + BadgeAwarder + AchievementManager + ChallengeManager ✅
- [x] الهجرات (migrations) ✅
- [x] واجهة أمامية — صفحة `/gamification` (نقاط، شارات، إنجازات، تحديات، سلسلة، مستوى) ✅

### المرحلة 11ب: المدارس SIS (afaq-school-profile) — منفّذ جزئياً ✅🔶
- [x] تطبيق `apps/schools` (15 موديل) — School/`manager`، AcademicYear، Section، StudentEnrollment، TeacherAssignment، SchoolAnnouncement (`is_emergency`)، FamilyLink، AnnouncementReadReceipt، ParentTeacherTicket، WhatsAppNotificationLog، UserAISetting، WeeklyReport، FAQ، SupportRequest، Attachment ✅
- [x] أدوار RBAC — `school_admin` (عبر `School.manager`) + أدوار student/teacher/parent/creator ✅
- [x] استيراد مدارس الأردن الرسمية `opendata.gov.jo` (7,296 مدرسة) + bulk import/export ✅
- [x] واتساب: `send_whatsapp_alert` (WhatsApp Cloud API + mock fallback) + `WhatsAppNotificationLog` + إعلانات طارئة ✅
- [x] صوت: `voice/transcribe/` + `voice/synthesize/` (Gemini STT + mock TTS) + `analytics/` (ساعات الذروة) + `weekly-summary/` ✅
- [x] واجهة `/school-followup` + إعلانات بتأكيد قراءة + تذاكر ولي الأمر/المعلم + مرفقات بمراجعة إدارية ✅
- [x] دورة العام الدراسي: `promote` (ترفيع مع ترحيل المعلمين + تتبع التخرج + `dry_run`) + `archive` + `stats` ✅
- [x] أسماء مستخدمين فريدة تلقائية (`student.{national_id}@student.local` / `teacher.{national_id}@teacher.local`) ✅
- [x] تصدير الجدول الدراسي إلى PDF (WeasyPrint) و Excel (openpyxl) ✅
- [x] FAQ Copilot: رد آلي عبر AI مع بحث قاعدة بيانات أولاً ✅
- [x] إشعارات غياب الواتساب: `send_absence_alerts` + Biometric Webhook + `notify_absence` ✅
- [x] شاشات 4 أدوار (`/school`, `/teacher`, `/parent`, `/student`) مع KPIs وأفعال سريعة ✅
- [x] نافذة إعارة المكتبة مع `borrower_role` وبحث متعدد الأدوار ✅
- [ ] لوحة تحكم المديرية (Directorate) — غير منفّذ

### المرحلة 12: PWA + Offline
- [x] Service Worker — **منفّذ (أغسطس 2026)**: `public/sw.js` يدوي — نطاق تنقّل فقط + cache-first مع تحديث خلفي دوري (TTL 5 دقائق) + كاش v2 + `Cache-Control: no-cache` لـ `/sw.js`؛ إصلاح صور الدورات التي كانت لا تُحمّل إلا بعد Ctrl+Shift+R ✅
- [ ] IndexedDB
- [ ] مزامنة المحتوى
- [x] إشعارات الدفع — **منفّذ**: `pushManager` في `src/store/notifications.ts` + معالجا push/notificationclick في `sw.js` + endpoints `/notifications/push/*` ✅

### المرحلة 13: WebSocket
- [ ] Django Channels
- [ ] الإشعارات الفورية
- [ ] المحادثات
- [ ] الحصص المباشرة

### المرحلة 14: البحث المتقدم
- [ ] Elasticsearch — بديل مقبول: PostgreSQL Full-Text Search
- [ ] إكمال تلقائي
- [ ] فلاتر متقدمة

### المرحلة 15: الموبايل
- [ ] React Native (Expo)
- [ ] شاشات أساسية
- [ ] Push notifications

### المرحلة 16: التوافق مع اللوائح
- [ ] GDPR compliance
- [ ] CCPA compliance
- [ ] COPPA compliance
- [ ] سياسة خصوصية

---

## فحوصات نهائية قبل الإطلاق

### الأداء
- [ ] Time to First Byte < 200ms
- [ ] First Contentful Paint < 1.5s
- [ ] Largest Contentful Paint < 2.5s
- [ ] Cumulative Layout Shift < 0.1
- [ ] Lighthouse score > 90

### الأمان
- [x] HTTPS everywhere — SECURE_SSL_REDIRECT + HSTS preload + شهادات Cloudflare ✅
- [x] No mixed content — الكل عبر HTTPS + HSTS ✅
- [ ] CSP headers correct — لا CSP بعد
- [ ] No sensitive data in logs — يُتحقق دورياً؛ LOGGING لا يطبع مفاتيح
- [x] API rate limiting active — DRF throttle مفعل ✅

### التوافق
- [ ] اختبار على Chrome, Firefox, Safari
- [ ] اختبار على Mobile (iOS + Android)
- [ ] اختبار RTL layout — RTL مدعوم (`localeRtl`: ar/ur/fa) دون اختبار شامل
- [ ] اختبار 9 لغات — 10 لغات مدعومة دون اختبار شامل

### البيانات
- [ ] Backup working
- [ ] Restore tested
- [ ] Data encryption verified
- [ ] No test data in production
