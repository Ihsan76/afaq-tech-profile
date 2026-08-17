# آفاق تكنولوجي — ملف المنصة الشامل

## نظرة عامة

**آفاق تكنولوجي** منصة رقمية متكاملة تقدم خدمات تعليمية ورقمية للمؤسسات والأفراد. تشمل المنصة:
- **المنصة التعليمية**: خطط دروس بالـ AI، أكاديمية الدورات، مناهج دراسية
- **الخدمات الرقمية**: تصميم مواقع، إدارة تواصل اجتماعي، صفحات هبوط، نماذج إلكترونية، كتب إلكترونية
- **نظام إدارة المحتوى**: بناء صفحات بصرياً (مثل WordPress/Elementor)

> **مبدأ أساسي**: جميع المنتجات والخدمات في المنصة **ديناميكية** — يمكن إضافتها أو تعديلها أو إيقافها في أي وقت من لوحة التحكم بدون تدخل تقني.

---

## ⚠️ قواعد AI Agent

**يجب على كل AI Agent قراءة ملف [AGENTS.md](AGENTS.md) والالتزام به قبل أي عمل على المشروع.**

---

## الهيكل الجديد للمنصة

```
الصفحة الرئيسية (/) — منصة آفاق تكنولوجي
├── PlatformHero — تعريف المنصة
├── PlatformStats — إحصائيات
├── ServicesShowcase — 8 خدمات رقمية
├── PortfolioShowcase — معرض الأعمال
├── PlatformHowItWorks — كيف نعمل
├── Testimonials — شهادات المستخدمين
├── PricingSection — باقات الخدمات
├── FAQSection — أسئلة شائعة
└── CTAFooter — تواصل معنا

صفحة الأكاديمية (/academy) — الدورات والتعليم غير المنهجي
├── Hero — تعريف الأكاديمية
├── Stats — إحصائيات الدورات
├── Features — ميزات الأكاديمية
├── HowItWorks — كيف تعمل الدورات
├── Demo — عرض تجريبي
├── Testimonials — شهادات المتدربين
├── PricingSection — باقات الدورات
├── FAQSection — أسئلة شائعة
└── CTAFooter — سجّل الآن

صفحة المناهج الدراسية (/curriculum) — المنهج المدرسي/الجامعي
├── GradeShowcase — عرض المراحل الدراسية
├── SubjectsGrid — شبكة المواد الدراسية
└── Partners — الشركاء التعليميون
```

---

## الخدمات الرئيسية (8 خدمات)

```
1. تصميم المواقع الإلكترونية
2. إدارة صفحات التواصل الاجتماعي
3. تصميم صفحات الهبوط
4. النماذج الإلكترونية
5. الكتب الإلكترونية
6. المنصة التعليمية (أكاديمية آفاق)
7. الحملات الإعلانية
8. الهوية البصرية والاستشارات
```

---

## المحتويات

### الجزء الأول: الهوية والرؤية
- [00. الملخص التنفيذي](part-01-identity/00-executive-summary.md)
- [01. هوية المنصة](part-01-identity/01-platform-identity.md)
- [02. المؤسس](part-01-identity/02-founder.md)
- [03. الأهداف الاستراتيجية](part-01-identity/03-strategic-goals.md)
- [04. الجمهور المستهدف](part-01-identity/04-target-audience.md)
- [05. الميزة التنافسية](part-01-identity/05-competitive-advantage.md)

### الجزء الثاني: النطاق والمنتجات
- [01. خطط الدروس بالـ AI](part-02-products/01-ai-lesson-plans.md)
- [02. الأكاديمية](part-02-products/02-academy.md)
- [03. لوحة تحكم الطالب](part-02-products/03-student-dashboard.md)
- [04. الأدوات الرقمية](part-02-products/04-digital-tools.md)
- [05. خدمات المؤسسات](part-02-products/05-enterprise-services.md)
- [06. نظام الدفع](part-02-products/06-payment-system.md)
- [07. خدمات إضافية](part-02-products/07-additional-services.md)
- [08. خريطة المنتجات](part-02-products/08-product-map.md)
- [09. الخدمات الرقمية والتقنية](part-02-products/09-digital-services.md)
- [10. نظام Gamification](part-02-products/10-gamification.md)

### الجزء الثالث: المعمارية التقنية
- [01. نظرة عامة](part-03-architecture/01-overview.md)
- [02. الواجهة الأمامية](part-03-architecture/02-frontend.md)
- [03. الخلفية](part-03-architecture/03-backend.md)
- [04. قاعدة البيانات](part-03-architecture/04-database.md)
- [05. طبقة الذكاء الاصطناعي](part-03-architecture/05-ai-layer.md)
- [06. النشر والبنية التحتية](part-03-architecture/06-deployment.md)
- [07. الأمان](part-03-architecture/07-security.md)
- [08. دليل تعدد اللغات (i18n)](part-03-architecture/08-i18n.md)
- [09. SEO متعدد اللغات](part-03-architecture/09-seo-i18n.md)
- [10. استراتيجية الكاش](part-03-architecture/10-caching-i18n.md)
- [11. إمكانية الوصول](part-03-architecture/11-accessibility.md)
- [12. نظام الثيمات](part-03-architecture/12-theming.md)
- [13. البحث المتقدم](part-03-architecture/13-search.md)
- [14. التوافق مع اللوائح (GDPR/CCPA/COPPA)](part-03-architecture/14-compliance.md)
- [15. النسخ الاحتياطي والاستعادة](part-03-architecture/15-backup-recovery.md)
- [16. الوضع غير المتصل / PWA](part-03-architecture/16-offline-support.md)
- [17. المراقبة والتنبيهات](part-03-architecture/17-monitoring.md)
- [18. خط أنابيب CI/CD](part-03-architecture/18-cicd.md)
- [19. WebSocket والتواصل اللحظي](part-03-architecture/19-websockets.md)
- [20. أعلام الميزات](part-03-architecture/20-feature-flags.md)

### الجزء الرابع: نموذج قاعدة البيانات
- [01. المستخدمون](part-04-database/01-users.md)
- [02. الأكاديمية](part-04-database/02-academics.md)
- [03. الذكاء الاصطناعي](part-04-database/03-ai.md)
- [04. خطط الدروس](part-04-database/04-lessonplans.md)
- [05. الدورات](part-04-database/05-courses.md)
- [06. المدوّنة](part-04-database/06-blog.md)
- [07. السوق](part-04-database/07-marketplace.md)
- [08. الدفع](part-04-database/08-payments.md)
- [09. الإشعارات](part-04-database/09-notifications.md)
- [10. الوسائط](part-04-database/10-media.md)
- [11. صفحات الموقع (Pages App)](part-04-database/11-landingpages.md)
- [12. إدارة اللغات](part-04-database/12-languages.md)
- [13. الثيمات](part-04-database/13-themes.md)

### الجزء الخامس: واجهات البرمجة API
- [01. APIs المصادقة](part-05-api/01-auth.md)
- [02. APIs الأكاديمية](part-05-api/02-academics.md)
- [03. APIs خطط الدروس](part-05-api/03-lessonplans.md)
- [04. APIs الدورات](part-05-api/04-courses.md)
- [05. APIs المدوّنة](part-05-api/05-blog.md)
- [06. APIs السوق](part-05-api/06-marketplace.md)
- [07. APIs الدفع](part-05-api/07-payments.md)
- [08. APIs الإدارة](part-05-api/08-admin.md)
- [09. APIs النظام](part-05-api/09-system.md)
- [10. معالجة الأخطاء متعددة اللغات](part-05-api/10-errors-i18n.md)

### الجزء السادس: شاشات المستخدم
- [01. المصادقة](part-06-screens/01-auth.md)
- [02. الصفحة الرئيسية ولوحة التحكم](part-06-screens/02-home-dashboard.md)
- [03. شاشات المعلم](part-06-screens/03-teacher.md)
- [04. شاشات الطالب](part-06-screens/04-student.md)
- [05. شاشات الإدارة](part-06-screens/05-admin.md)
- [06. المدوّنة](part-06-screens/06-blog.md)
- [07. السوق](part-06-screens/07-marketplace.md)
- [08. الدفع](part-06-screens/08-payments.md)
- [09. الإعدادات](part-06-screens/09-settings.md)
- [10. الملف الشخصي](part-06-screens/10-profile.md)

### الجزء السابع: نظام الدفع
- [01. نظرة عامة](part-07-payments/01-overview.md)
- [02. تكامل Stripe](part-07-payments/02-stripe.md)
- [03. المحفظة والمعاملات](part-07-payments/03-wallet.md)
- [04. الاشتراكات](part-07-payments/04-subscriptions.md)
- [05. رسوم السوق](part-07-payments/05-marketplace-fees.md)
- [06. السحب للمزودين](part-07-payments/06-payouts.md)

### الجزء الثامن: تكامل الذكاء الاصطناعي
- [01. نظرة عامة](part-08-ai/01-overview.md)
- [02. المزودون](part-08-ai/02-providers.md)
- [03. قوالب الاستعلامات](part-08-ai/03-prompts.md)
- [04. التوجيه الذكي](part-08-ai/04-routing.md)
- [05. التتبع والسجلات](part-08-ai/05-logging.md)
- [06. تحسين التكلفة](part-08-ai/06-cost-optimization.md)

### الجزء التاسع: تطبيق الموبايل
- [01. نظرة عامة](part-09-mobile/01-overview.md)
- [02. الشاشات](part-09-mobile/02-screens.md)
- [03. التكامل مع Backend](part-09-mobile/03-integration.md)
- [04. النشر](part-09-mobile/04-deployment.md)

### الجزء العاشر: المحتوى والإعلام
- [01. إدارة المحتوى](part-10-content/01-management.md)
- [02. إدارة الوسائط](part-10-content/02-media.md)
- [03. الإشعارات](part-10-content/03-notifications.md)
- [04. التحليلات](part-10-content/04-analytics.md)
- [05. سير عمل الترجمة](part-10-content/05-translation-workflow.md)
- [06. خدمات البريد والرسائل](part-10-content/06-email-sms.md)
- [07. رفع الملفات والتخزين](part-10-content/07-file-uploads.md)
- [08. تحليل المنافسين واستراتيجية المحتوى](part-10-content/08-competitive-analysis.md)

### الجزء الحادي عشر: التوسع المستقبلي
- [01. الرؤية المستقبلية](part-11-future/01-vision.md)
- [02. التوسع التقني](part-11-future/02-scaling.md)
- [03. الميزات المستقبلية](part-11-future/03-features.md)
- [04. نموذج الأعمال](part-11-future/04-business.md)

### الجزء الثاني عشر: خطة التنفيذ
- [00. دليل ما قبل البدء](part-12-implementation/00-quickstart.md)
- [01. نظرة عامة](part-12-implementation/01-overview.md)
- [02. خطة MVP](part-12-implementation/02-mvp.md)
- [03. الميزات الإضافية](part-12-implementation/03-features.md)
- [04. الاختبارات](part-12-implementation/04-testing.md)
- [05. المخاطر](part-12-implementation/05-risks.md)
- [06. اختبارات i18n](part-12-implementation/06-testing-i18n.md)
- [07. DevOps والبنية التحتية](part-12-implementation/07-devops.md)
- [08. تحسين الأداء](part-12-implementation/08-performance.md)

### الجزء الثالث عشر: نظام إدارة الموقع (WordPress-like)
- [01. نظرة عامة](part-13-page-builder/01-overview.md)
- [02. نظام الصفحات](part-13-page-builder/02-pages.md)
- [03. نظام البلوكات (40 نوع)](part-13-page-builder/03-blocks.md)
- [04. محرر الصفحة (Page Builder)](part-13-page-builder/04-page-builder.md)
- [05. نظام القوائم](part-13-page-builder/05-menus.md)
- [06. نظام القوالب](part-13-page-builder/06-templates.md)
- [07. إعدادات الموقع](part-13-page-builder/07-site-settings.md)
- [08. إدارة الصلاحيات](part-13-page-builder/08-permissions.md)

### الملاحق
- [00. قواعد AI Agent](AGENTS.md) ⭐
- [01. معجم المصطلحات](appendices/01-glossary.md)
- [02. قائمة التحقق](appendices/02-checklist.md)

---

## ملخص تقني سريع (الحالة الفعلية أغسطس 2026)

| العنصر | التفاصيل |
|--------|----------|
| **Frontend** | Next.js 16+ / TypeScript / Tailwind CSS v4 |
| **Backend** | Django 5.x / DRF / Python 3.12+ |
| **Database** | PostgreSQL 15+ (Supabase Transaction Pooler) |
| **Cache** | LocMemCache في الإنتاج (Upstash/Redis محجوب إقليمياً) |
| **AI** | Gemini (google-genai) / OpenAI / Ollama |
| **Payment** | Stripe Checkout + MyFatoorah (واجهة مزوّدات موحّدة — منفّذ) + **محفظة أرباح (Wallet)** للمزوّدين |
| **Paid Content** | دورات وكتب مدفوعة: شراء مدى الحياة (`CoursePurchase`/`EbookPurchase`) + مستوى وصول للباقة (`access_level` free/basic/pro/enterprise) + رسوم منصة 10% (منفّذ) |
| **Subscriptions** | apps/subscriptions — Plan + Subscription + Organization (منفّذ) |
| **Schools (SIS)** | apps/schools — SIS core مع دورة عام دراسي + تصدير جدول + FAQ Copilot + مساحات عمل (انظر afaq-school-profile) |
| **Mobile** | React Native (Expo) — مخطط |
| **Deployment** | Vercel + Render + Cloudflare (حي — أغسطس 2026) |
| **Storage** | Cloudflare R2 + CDN (مخطط) |
| **Email** | Resend |
| **Monitoring** | Sentry + cron-job.org (مراقب خارجي 24/7) |
| **i18n** | 10 لغات في DB + 1305 مفتاح ترجمة — تعديل مباشر من الأدمن، بدون إعادة نشر |
| **PWA** | Service Worker يدوي (`public/sw.js`): نطاق تنقّل فقط + كاش cache-first مع تحديث خلفي دوري (TTL 5د) + إشعارات push — إصلاح صور الدورات (أغسطس 2026) |
| **Page Builder** | Visual drag & drop like WordPress/Elementor |
| **Theme System** | 6 ثيمات + CSS variables + real-time switching |
| **Block Types** | **40 نوع بلوك** |
| **Rich Text Editor** | TipTap — في BlockEditorPanel و Blog admin |
| **Blog System** | BlogCategory + BlogPost + APIs + Admin panels |
| **Django Admin** | Custom submit_line.html مع زر رجوع |
| **Pages Seeded** | 16 صفحة (homepage, academy, curriculum, about, contact, ai-chat, privacy, terms + 8 صفحات خدمات) |
| **Blocks Seeded** | 68 بلوك |

### إنجازات المدارس (أغسطس 2026)

- [x] دورة العام الدراسي: `promote` (ترفيع مع ترحيل المعلمين + تتبع التخرج + `dry_run`) + `archive` + `stats` ✅
- [x] أسماء مستخدمين فريدة تلقائية (`student.{national_id}@student.local` / `teacher.{national_id}@teacher.local`) ✅
- [x] تصدير الجدول الدراسي إلى PDF (WeasyPrint) و Excel (openpyxl) ✅
- [x] FAQ Copilot: رد آلي عبر AI مع بحث قاعدة بيانات أولاً ✅
- [x] إشعارات غياب الواتساب: `send_absence_alerts` + Biometric Webhook + `notify_absence` ✅
- [x] صفحة frontend لدورة العام الدراسي: معالج 3 خطوات (اختيار → معاينة → تأكيد) ✅
- [x] شاشات 4 أدوار: `/school`, `/teacher`, `/parent`, `/student` مع KPIs وأفعال سريعة ✅
- [x] نافذة إعارة المكتبة: `borrower` + `borrower_role` + `borrower_name` مع بحث متعدد الأدوار ✅
- [x] `is_admin()` يدعم `school_admin` و `developer` و `school_librarian` و `school_accountant` و `school_transport_officer` ✅
- [x] **المرحلة 1**: تلميع وبنود تفاصيل لوحات الأدوار (`/teacher/*`, `/parent/*`, `/student/*`) ✅
- [x] **المرحلة 2**: التحقق من تفاصيل صفحات الإدارة المدرسية المساعدة (الرسوم `/school/fees`، النقل `/school/transport`، والإعلانات) ✅

---

## الإنجازات الفعلية (يوليو 2026 — الأساس)

### Backend — ✅ مكتمل
- [x] Django + DRF مع **14 تطبيقاً** (users, academics, lessonplans, ai, core, themes, pages, blog, marketplace, gamification, courses, ebooks, subscriptions, schools)
- [x] JWT auth + Custom UserManager (email-based)
- [x] User model مع 4 أبعاد لغوية + هاتف + صورة + timezone
- [x] Academics CRUD (grades, subjects, curricula, units)
- [x] Theme model مع **35+ حقل** (flat model) + 6 ثيمات مُهيأة
- [x] Page, PageBlock (40 نوع), MenuItem, PageTemplate, SiteSettings models
- [x] BlogCategory, BlogPost مع APIs عامة وإدارية
- [x] **54+ API endpoint** عبر 16 route في pages + 6 routes في blog
- [x] Seed scripts: themes (6), menus (8), pages (16 صفحات + 68 بلوك), blog (5 تصنيفات + 7 مقالات)
- [x] Django admin مع زر رجوع مخصص (submit_line.html)

### Frontend — ✅ مكتمل
- [x] Next.js 16 + TypeScript + Tailwind CSS v4 + next-intl (10 لغات)
- [x] Auth screens (login, register, forgot-password, reset-password)
- [x] Zustand auth store
- [x] LanguageSwitcher (custom dropdown — 10 لغات)
- [x] ThemeSwitcher في Navbar (dropdown + color dots + checkmark)
- [x] Admin CRUD pages (grades, subjects, curricula)
- [x] Admin themes page مع live preview
- [x] Profile page مع theme switcher
- [x] **35 landing component** (بلوكات + renderers + BlogListBlock)
- [x] Page Builder (محرر بصري للصفحات مع BlockEditorPanel + RichTextEditor)
- [x] Menu Manager (إدارة القوائم header/footer/sidebar)
- [x] Template System (قوالب جاهزة)
- [x] Blog admin page (`/admin/blog`) مع CRUD كامل + RichTextEditor
- [x] **12 مكون جديد**: Accordion, Tabs, Timeline, Countdown, Newsletter, Map, Table, IconList, LogoCarousel, Download, Code, BlogList

### الصفحة الرئيسية — ✅ مكتمل
- [x] PlatformHero + PlatformStats + ServicesShowcase (8 خدمات)
- [x] PortfolioShowcase + PlatformHowItWorks
- [x] Testimonials + PricingSection + FAQSection + CTAFooter

### الأكاديمية — ✅ مكتمل
- [x] Hero, Stats, Features, HowItWorks, Demo
- [x] Testimonials, Pricing, FAQ, CTA

### المناهج الدراسية — ✅ مكتمل
- [x] GradeShowcase, SubjectsGrid, Partners

### صفحات إضافية — ✅ مكتمل
- [x] About, Contact, Privacy Policy, Terms of Service
- [x] 8 صفحات خدمات (web-design, social-media, landing-pages, forms, ebooks, ad-campaigns, brand-identity + education-platform عبر الـCMS) — تُعرض CMS-first مع fallback i18n

### المدوّنة — ✅ مكتمل
- [x] BlogListBlock في صفحة HomePage
- [x] صفحات عامة: `/blog` (قائمة) + `/blog/[slug]` (تفاصيل)
- [x] Blog admin panel في الفرونت (`/admin/blog`) — CRUD كامل مع RichTextEditor
- [x] Django admin في الباك إند مع زر رجوع مخصص
- [x] 5 تصنيفات + 7 مقالات مُهيأة

### إدارة اللغات والترجمات — ✅ مكتمل
- [x] `Language` (10 لغات) + `TranslationKey` (923 مفتاحاً) + `FeatureFlag` في `apps/core`
- [x] 14 API endpoint (عامة + إدارية) للغات والترجمات
- [x] `seed_languages.py` + `manage.py seed_translations` (bulk upsert من ملفات الواجهة)
- [x] `TranslationProvider` يدمج قيم DB الحية فوق رسائل next-intl الثابتة
- [x] صفحة `/admin/translations` (إدارة المفاتيح والقيم لكل اللغات: بحث + فلترة + إضافة/تعديل/حذف)
- [x] صفحة `/admin/languages` مع تبويب "ترجمات اللغة" داخل نافذة تعديل اللغة
- [x] `useLanguages()` + `useAdminLanguages()` (hooks بمهاجعة fallback للثابتة)
- [x] بريد المنصة: `@afaq.app`

---

## إنجازات إضافية (أغسطس 2026 — الإطلاق والتوسع)

### 🚀 الإطلاق الحي — ✅ مكتمل
- [x] **المنصة حية**: `afaq.app`/`www.afaq.app` (Vercel) + `api.afaq.app` (Render) خلف Cloudflare (NS منقولة، SSL Full strict)
- [x] **مراقب خارجي 24/7** على `api.afaq.app/api/v1/core/health/` (cron-job.org/UptimeRobot) — يُبقي Render حياً
- [x] طلبات مراجعة **Google Safe Browsing** مقدمة لرفع flag عن `www.` و`api.` (قيد المتابعة)

### 🔐 تحصين المصادقة — ✅ مكتمل
- [x] JWT **RS256** (مفاتيح RSA في `.env`) + **Argon2id** + blacklist logout
- [x] تأكيد البريد عبر Resend (نموذج `EmailVerification`) + **brute-force lockout** (5 محاولات/15د)
- [x] Rate limiting على endpoints الدخول + Google OAuth جاهز (ينتظر Client ID/Secret)

### 📊 لوحة تحكم المدير (المرحلة 4) — ✅ مكتمل
- [x] إحصائيات `/core/admin/stats/` في `/admin` + إدارة السوق `/admin/marketplace` + مراقبة AI `/admin/ai-runs`

### 🏪 السوق + الدورات + التلعيب + المحتوى المدفوع — ✅ (Backend + شاشات)
- [x] السوق: Service/Order/Review + 4 صفحات أمامية (marketplace, services/create, orders, admin)
- [x] الدورات: Course/Chapter/Lesson/Enrollment + شاشات `academy/courses` + `[slug]/learn`
- [x] **الدورات والكتب المدفوعة (أغسطس 2026)**: `access_level` (free/basic/pro/enterprise) + `is_free`/`price` + `platform_fee_percent`؛ شراء مدى الحياة (`CoursePurchase`/`EbookPurchase`) عبر نفس واجهة الدفع الموحّدة؛ `activate_course_purchase` / `activate_ebook_purchase` يمنحان وصول مدى الحياة ويضيفان أرباح المدرب/المؤلف للمحفظة بعد خصم رسوم المنصة (10%)؛ قفل عبر 402/403؛ واجهة الفرونت مع زر "اشترِ الآن" وبنرات الدفع.
- [x] Gamification: 12 موديل + 16 API + 16 نشاطاً + **واجهة أمامية** `/gamification` (نقاط/شارات/إنجازات/تحديات/سلسلة/مستوى)

### ⚡ الأداء (قياسات قبل ← بعد) — ✅ مكتمل
- [x] بطء Redis: كل endpoint كان ينتظر 2s لمهلة Upstash المحجوب → **LocMemCache** + مهلات 0.3s (menu 2.5s ← ~0.4s)
- [x] الترجمات: 561KB ← **~56KB** (فلترة بـ `?locale=`)
- [x] إصلاح N+1 في المدوّنة/الكتب + إزالة طوفان `usePrefetch` + بطاقات كتب بغلاف افتراضي

### 🤖 Gemini — ✅ محدّث
- [x] ترحيل `google.generativeai` (المُهملة) → **`google-genai`** (`from google import genai`) في `apps/ai`

### 🏫 المدارس SIS (أغسطس 2026) — ✅ (المرحلتان 1-2 من afaq-school-profile)
- [x] تطبيق `apps/schools` (15 موديل): School (`manager` FK), AcademicYear, Section, StudentEnrollment, TeacherAssignment, SchoolAnnouncement (`is_emergency` + واتساب), FamilyLink, AnnouncementReadReceipt, ParentTeacherTicket, WhatsAppNotificationLog, UserAISetting, WeeklyReport, FAQ, SupportRequest, Attachment
- [x] استيراد مدارس الأردن الرسمية (`opendata.gov.jo`) — 7,296 مدرسة + bulk import/export (Excel/CSV)
- [x] واجهة `/school-followup` (متابعة مدرسية) + دور `school_admin` عبر `School.manager`
- [x] صوت: `voice/transcribe/` + `voice/synthesize/` (Gemini STT + mock) + `analytics/` (ساعات الذروة) + `weekly-summary/`
- [ ] متبقي: دورة العام الدراسي (ترفيع/أرشفة/تحويلات)، FAQ Copilot، تقارير أسبوعية آلية كاملة

### 🧩 خدمات + واجهة (أغسطس 2026) — ✅ مكتمل
- [x] صفحات `/services/[slug]` **هجينة CMS-first**: بلوكات الـCMS عبر BlockRenderer + fallback مطابق بصرياً من i18n (7 خدمات) — تحقّق: CMS يعمل/متوقف، slug مجهول
- [x] إصلاح الروابط: `resolveLink()` يمنع بادئة locale للروابط المطلقة (`mailto:`/`http:`/`tel:`/`#`) — كان الزر على صفحة التواصل ينتج `/armailto:...`
- [x] إدارة مستخدمين محسّنة في `/admin/users` (ترقيم صفحات + بحث + فلتر مدرسة + فرز) + جداول إدارية متجاوبة (mobile)

### 📝 قائمة التحقق
- [x] `appendices/02-checklist.md` محدّثة بالكامل (229 بند منجز مقابل 69 معلّقاً — كُلٌّ بتوثيق من الكود)
- [x] `part-12-implementation/01-overview.md` أُعيدت كتابتها بالحالة الفعلية + تقييم مُحدّث في `03-evaluation.md`

### 🛠️ إصلاحات أغسطس 2026 (تم اعتمادها)
- [x] **إصلاح صور الدورات (كاش الـ Service Worker)**: كان لا يمكن تحميل صور الدورات إلا بعد Ctrl+Shift+R. السبب: الـ SW كان يعترض كل طلبات GET (بما فيها الصور الخارجية) ويخدم نسخاً قديمة من كاش لا يُمسح. الحل: `sw.js` يعترض **التنقّل فقط** (الصور/الملفات/`/api/` تمر من الشبكة مباشرة)، كاش التنقّل **cache-first للسرعة + تحديث خلفي دوري** (TTL 5 دقائق عبر `x-sw-cached-at`)، ترقية الكاش إلى `afaq-tech-v2` (تفريغ v1 عند التفعيل)، `Cache-Control: no-cache` لـ `/sw.js`، وSWR `revalidateOnFocus`+`revalidateOnReconnect` في `src/lib/useApi.ts`. إشعارات push محفوظة. ✅
- [x] **القوائم متعددة الاختيار (Menus Multi-select)**: `service_context` و `required_role` في `MenuItem` → `ArrayField` (مهاجرة 0015 بتحويل البيانات) + `ChoiceListField` + فلترة `MenuPublicView` بـ `__contains` + مكوّن `MultiSelectDropdown` في `/admin/menus` + دعم مصفوفات الأدوار في `ContextualSidebar` + `seed_menus.py` + ترجمات 10 لغات. المصفوفة الفارغة = الكل/للجميع (لا خيار "all"). ✅

---

## للبدء

1. اقرأ **[AGENTS.md](AGENTS.md)** — قواعد AI Agent الإلزامية
2. اقرأ الملفات الأساسية (الجزء الأول والثاني)
3. افهم المعمارية التقنية (الجزء الثالث)
4. افهم نظام Page Builder (الجزء الثالث عشر)
5. أطلق وحسّن بناءً على ملاحظات المستخدمين

---

*آخر تحديث: أغسطس 2026*
