# نظام إدارة المنصة (WordPress-like)

## نظرة عامة

نظام إدارة محتوى ديناميكي يشبه WordPress يسمح لإدارة المنصة ببناء وتعديل صفحات الموقع بصرياً بدون الحاجة لتعديل الكود.

> **حالة التنفيذ:** المرحلة 1-3 مكتملة ✅ — Backend Models + APIs + Admin UI + Dynamic Rendering

---

## المكونات الرئيسية

### 1. نظام الصفحات (Page System) ✅
- إنشاء صفحات جديدة بسهولة
- تعيين قالب لكل صفحة (default, landing, about, contact, custom)
- إعدادات SEO لكل صفحة (meta_title, meta_description بالإنجليزية والعربية)
- التحكم في الظهور بالقائمة (show_in_nav, nav_order, parent_page)
- صفحة رئيسية واحدة فقط (is_homepage)
- theme_overrides — تخصيص ثيم لكل صفحة

### 2. نظام البلوكات (Block System) ✅
- **28 نوع بلوك** جاهز (تم إضافة 6 أنواع للمنصة والتعليم)
- سحب وإفلات لترتيب البلوكات (drag & drop reorder)
- تخصيص كل بلوك (content JSON + styles + layout + animation)
- تفعيل/إيقاف كل بلوك
- معاينة حية عبر BlockRenderer

### 3. محرر الصفحة (Page Builder) ✅
- واجهة سحب وإفلات (drag & drop)
- مكتبة بلوكات (28 نوع في modal)
- إدارة بلوكات (إضافة/تعديل/حذف/إعادة ترتيب/تفعيل)
- Sidebar + Main preview layout

### 4. نظام القوائم (Menu Manager) ✅
- قوائم علوية وتذييلية وشريط جانبي (header/footer/sidebar)
- سحب وإفلات لترتيب العناصر
- قوائم فرعية (sub-menus عبر parent)
- ربط بالصفحات الداخلية (ForeignKey to Page)
- شارات (badge: "جديد", "مميز")
- فتح في نافذة جديدة (open_in_new)

### 5. نظام القوالب (Template System) ✅
- قوالب صفحات جاهزة (landing, business, education, portfolio, custom)
- بلوكات افتراضية لكل قالب (default_blocks JSON)
- تخطيط افتراضي (default_layout JSON)
- إنشاء/تعديل/حذف من Admin

### 6. إعدادات الموقع (Site Settings) ✅
- معلومات الموقع (اسم بالإنجليزية والعربية، وصف)
- التواصل (بريد، هاتف، واتساب)
- وسائل التواصل الاجتماعي (Facebook, Twitter, Instagram, LinkedIn, YouTube)
- نص التذييل + حقوق النشر
- إعدادات مخصصة (custom_settings JSON)

---

## النماذج (Backend Models) — مُنفّذة ✅

### Page
```python
class Page(models.Model):
    slug = models.SlugField(unique=True, max_length=100)
    title_en = models.CharField(max_length=200)
    title_ar = models.CharField(max_length=200)
    description_en = models.TextField(blank=True)
    description_ar = models.TextField(blank=True)
    template = models.CharField(choices=TEMPLATES)  # default, landing, about, contact, custom
    show_in_nav = models.BooleanField(default=False)
    nav_order = models.IntegerField(default=0)
    nav_icon = models.CharField(max_length=10, blank=True)
    parent_page = models.ForeignKey('self', null=True)
    layout_config = models.JSONField(default=dict)
    is_published = models.BooleanField(default=True)
    is_homepage = models.BooleanField(default=False)
    theme_overrides = models.JSONField(default=dict)
    meta_title_en = models.CharField(max_length=200, blank=True)
    meta_title_ar = models.CharField(max_length=200, blank=True)
    meta_description_en = models.TextField(blank=True)
    meta_description_ar = models.TextField(blank=True)
```

### PageBlock
```python
class PageBlock(models.Model):
    page = models.ForeignKey(Page, related_name='blocks')
    block_type = models.CharField(max_length=30, choices=BLOCK_TYPES)
    title_en = models.CharField(max_length=200, blank=True)
    title_ar = models.CharField(max_length=200, blank=True)
    subtitle_en = models.CharField(max_length=500, blank=True)
    subtitle_ar = models.CharField(max_length=500, blank=True)
    content = models.JSONField(default=dict)
    styles = models.JSONField(default=dict)
    layout = models.JSONField(default=dict)
    animation = models.JSONField(default=dict)
    is_active = models.BooleanField(default=True)
    order = models.IntegerField(default=0)
```

### MenuItem
```python
class MenuItem(models.Model):
    menu = models.CharField(choices=POSITIONS)    # header, footer, sidebar
    translations = models.JSONField(default=dict) # ترجمات متعددة (ar/en/fr/...)
    # اختيار متعدد (Multi-select، أغسطس 2026): مصفوفة فارغة = الكل/للجميع
    service_context = ArrayField(models.CharField(...), default=list)  # 10 سياقات
    required_role = ArrayField(models.CharField(...), default=list)    # 6 أدوار
    url = models.CharField(max_length=500)
    page = models.ForeignKey(Page, null=True)
    icon = models.CharField(max_length=10)
    parent = models.ForeignKey('self', null=True)
    order = models.IntegerField(default=0)
    is_active = models.BooleanField(default=True)
    open_in_new = models.BooleanField(default=False)
    css_class = models.CharField(max_length=200, blank=True)
    badge = models.CharField(max_length=50, blank=True)
```

### PageTemplate
```python
class PageTemplate(models.Model):
    name_en = models.CharField(max_length=100)
    name_ar = models.CharField(max_length=100)
    slug = models.SlugField(unique=True)
    category = models.CharField(choices=CATEGORIES)  # landing, business, education, portfolio, custom
    default_blocks = models.JSONField(default=list)
    default_layout = models.JSONField(default=dict)
    is_active = models.BooleanField(default=True)
```

### SiteSettings
```python
class SiteSettings(models.Model):
    site_name_en = models.CharField(max_length=200)
    site_name_ar = models.CharField(max_length=200)
    site_description_en = models.TextField(blank=True)
    site_description_ar = models.TextField(blank=True)
    logo_url = models.URLField(blank=True)
    favicon_url = models.URLField(blank=True)
    email = models.EmailField(blank=True)
    phone = models.CharField(max_length=50, blank=True)
    whatsapp = models.CharField(max_length=50, blank=True)
    facebook_url = models.URLField(blank=True)
    twitter_url = models.URLField(blank=True)
    instagram_url = models.URLField(blank=True)
    linkedin_url = models.URLField(blank=True)
    youtube_url = models.URLField(blank=True)
    footer_text_en = models.TextField(blank=True)
    footer_text_ar = models.TextField(blank=True)
    copyright_text = models.CharField(max_length=200, blank=True)
    custom_settings = models.JSONField(default=dict)
```

---

## أنواع البلوكات (28 نوع)

### بلوكات المنصة (Platform)
| النوع | الوصف | الاستخدام |
|-------|-------|-----------|
| `platform_hero` | بطل الصفحة (المنصة) | الصفحة الرئيسية — تعريف المنصة |
| `platform_stats` | إحصائيات (المنصة) | الصفحة الرئيسية — أرقام المنصة |
| `platform_how_it_works` | كيف تعمل (المنصة) | الصفحة الرئيسية — خطوات العمل |
| `services_showcase` | عرض الخدمات | الصفحة الرئيسية — 8 خدمات رقمية |

### بلوكات الأكاديمية (Academy)
| النوع | الوصف | الاستخدام |
|-------|-------|-----------|
| `hero` | بطل الصفحة | صفحة الأكاديمية / المناهج |
| `stats` | إحصائيات | أرقام الدورات والطلاب |
| `features` | الميزات | ميزات الأكاديمية |
| `how_it_works` | كيف يعمل | شرح آلية التعلم |
| `demo` | عرض توضيحي | Demo للمنصة |
| `grade_showcase` | عرض الصفوف | المراحل الدراسية (من API) |
| `subjects_grid` | شبكة المواد | المواد الدراسية |

### بلوكات التسويق (Shared)
| النوع | الوصف | الاستخدام |
|-------|-------|-----------|
| `testimonials` | شهادات | آراء العملاء/المتدربين |
| `pricing` | التسعير | باقات الأسعار |
| `faq` | أسئلة شائعة | الأسئلة المتكررة |
| `cta` | دعوة للعمل | زر CTA |
| `portfolio` | معرض أعمال | مشاريع مكتملة |
| `partners` | الشركاء | شعارات الشركاء |

### بلوكات المحتوى
| النوع | الوصف | الاستخدام |
|-------|-------|-----------|
| `text` | نص | محتوى نصي عام |
| `image` | صورة | صورة مع وصف |
| `video` | فيديو | فيديو مدمج |
| `gallery` | معرض صور | مجموعة صور |
| `custom_html` | HTML مخصص | كود مخصص |

### بلوكات التخطيط
| النوع | الوصف | الاستخدام |
|-------|-------|-----------|
| `spacer` | مسافة | فراغ رأسي |
| `divider` | فاصل | خط فاصل |

### بلوكات إضافية
| النوع | الوصف | الاستخدام |
|-------|-------|-----------|
| `services` | خدمات | عرض الخدمات (عام) |
| `team` | الفريق | أعضاء الفريق |
| `contact` | تواصل معنا | نموذج اتصال |
| `form` | نموذج | نموذج مخصص |

---

## الصفحات المُهيأة (Seeded Pages)

| الصفحة | Slug | البلوكات | الحالة |
|--------|------|----------|--------|
| منصة آفاق تكنولوجي | `homepage` | 9 بلوكات (platform_hero → cta) | ✅ |
| أكاديمية آفاق | `academy` | 9 بلوكات (hero → cta) | ✅ |
| المنهاج الدراسي | `curriculum` | 4 بلوكات (hero → partners) | ✅ |

### محتوى كل صفحة:
```
homepage (منصة آفاق تكنولوجي):
  [0] platform_hero — عنوان + وصف + أزرار CTA + badges
  [1] platform_stats — 4 إحصائيات (مشاريع، مستخدمين، خدمات، خبرة)
  [2] services_showcase — 8 خدمات رقمية
  [3] portfolio — 3 مشاريع
  [4] platform_how_it_works — 3 خطوات
  [5] testimonials — 3 شهادات
  [6] pricing — 3 باقات
  [7] faq — 5 أسئلة
  [8] cta — دعوة للعمل

academy (أكاديمية آفاق):
  [0] hero — تعريف الأكاديمية
  [1] stats — إحصائيات الدورات
  [2] features — 6 ميزات
  [3] how_it_works — 3 خطوات
  [4] demo — عرض توضيحي
  [5] testimonials — 3 شهادات
  [6] pricing — 3 باقات
  [7] faq — 5 أسئلة
  [8] cta — دعوة للعمل

curriculum (المنهاج الدراسي):
  [0] hero — تعريف المناهج
  [1] grade_showcase — 3 مراحل (ابتدائي، متوسط، ثانوي)
  [2] subjects_grid — 8 مواد
  [3] partners — 4 شركاء
```

---

## API Endpoints (مُنفّذة ✅)

```
# الصفحات — عام
GET    /api/v1/pages/<slug>/                    # جلب صفحة بالـ slug (مع بلوكاتها)

# الصفحات — إدارة
GET    /api/v1/pages/admin/pages/               # قائمة الصفحات
POST   /api/v1/pages/admin/pages/create/        # إنشاء صفحة
GET    /api/v1/pages/admin/pages/<pk>/          # تفاصيل صفحة
PUT    /api/v1/pages/admin/pages/<pk>/          # تعديل صفحة
DELETE /api/v1/pages/admin/pages/<pk>/delete/   # حذف صفحة

# البلوكات — إدارة
GET    /api/v1/pages/admin/pages/<page_id>/blocks/           # بلوكات الصفحة
POST   /api/v1/pages/admin/pages/<page_id>/blocks/create/    # إضافة بلوك
PUT    /api/v1/pages/admin/pages/<page_id>/blocks/<pk>/      # تعديل بلوك
DELETE /api/v1/pages/admin/pages/<page_id>/blocks/<pk>/delete/ # حذف بلوك
PUT    /api/v1/pages/admin/pages/<page_id>/blocks/reorder/   # إعادة ترتيب

# القوائم — عام
GET    /api/v1/pages/menu/<menu_type>/           # جلب قائمة (header/footer/sidebar)

# القوائم — إدارة
GET    /api/v1/pages/admin/menus/               # قائمة العناصر
POST   /api/v1/pages/admin/menus/create/        # إضافة عنصر
PUT    /api/v1/pages/admin/menus/<pk>/          # تعديل عنصر
DELETE /api/v1/pages/admin/menus/<pk>/delete/   # حذف عنصر
PUT    /api/v1/pages/admin/menus/reorder/       # إعادة ترتيب

# القوالب — عام
GET    /api/v1/pages/templates/list/            # القوالب المتاحة

# القوالب — إدارة
GET    /api/v1/pages/admin/templates/           # جميع القوالب
POST   /api/v1/pages/admin/templates/create/    # إنشاء قالب
PUT    /api/v1/pages/admin/templates/<pk>/      # تعديل قالب
DELETE /api/v1/pages/admin/templates/<pk>/delete/ # حذف قالب

# الإعدادات — عام
GET    /api/v1/pages/settings/                  # إعدادات الموقع

# الإعدادات — إدارة
PUT    /api/v1/pages/admin/settings/            # تحديث الإعدادات
```

---

## هيكل الملفات (Frontend) — مُنفّذ ✅

```
src/app/[locale]/admin/
├── layout.tsx                    # Admin Layout موحد (sidebar + header) ✅
├── page.tsx                      # Dashboard رئيسي (6 محتوى + 3 تعليم) ✅
├── pages/
│   ├── page.tsx                  # قائمة الصفحات + إنشاء ✅
│   └── [pageId]/
│       └── page.tsx              # محرر الصفحة (Page Builder) ✅
├── menus/
│   └── page.tsx                  # إدارة القوائم (header/footer/sidebar tabs) ✅
├── templates/
│   └── page.tsx                  # إدارة القوالب (grid + CRUD) ✅
├── themes/
│   └── page.tsx                  # إدارة الثيمات ✅
├── widgets/
│   └── page.tsx                  # إدارة الويدجتات ✅
├── settings/
│   └── page.tsx                  # إعدادات الموقع ✅
├── grades/                       # إدارة المراحل ✅
├── subjects/                     # إدارة المواد ✅
└── curricula/                    # إدارة المناهج ✅

src/components/landing/
├── BlockRenderer.tsx             # مُرتجع البلوكات — يربط block_type بالكمبوننت ✅
├── WidgetRenderer.tsx            # المُرتجع القديم (مُهمّل) ✅
├── PlatformHero.tsx              # بطل الصفحة الرئيسية (content overrides) ✅
├── PlatformStats.tsx             # إحصائيات المنصة (content overrides) ✅
├── PlatformHowItWorks.tsx        # كيف تعمل (content overrides) ✅
├── ServicesShowcase.tsx          # عرض الخدمات (content overrides) ✅
├── PortfolioShowcase.tsx         # معرض الأعمال (content overrides) ✅
├── HeroSection.tsx               # بطل الأكاديمية (content overrides) ✅
├── StatsBar.tsx                  # إحصائيات الأكاديمية (content overrides) ✅
├── FeaturesSection.tsx           # الميزات (content overrides) ✅
├── HowItWorks.tsx                # كيف يعمل (content overrides) ✅
├── DemoShowcase.tsx              # العرض التوضيحي (content overrides) ✅
├── Testimonials.tsx              # الشهادات (content overrides) ✅
├── PricingSection.tsx            # الأسعار (content overrides) ✅
├── FAQSection.tsx                # الأسئلة الشائعة (content overrides) ✅
├── CTAFooter.tsx                 # الدعوة للعمل (content overrides) ✅
├── GradeShowcase.tsx             # عرض المراحل (content overrides) ✅
├── SubjectsGrid.tsx              # شبكة المواد (content overrides) ✅
└── PartnersBar.tsx               # الشركاء (content overrides) ✅

src/components/
└── DynamicPage.tsx               # الصفحة الديناميكية — تجلب slug من API وتعمل render ✅

src/app/[locale]/
├── page.tsx                      # الصفحة الرئيسية → DynamicPage slug="homepage" ✅
├── academy/page.tsx              # الأكاديمية → DynamicPage slug="academy" ✅
└── curriculum/page.tsx           # المناهج → DynamicPage slug="curriculum" ✅
```

---

## معمارية Dynamic Rendering

```
┌──────────────────────────────────────────────────────────┐
│  User visits /en/homepage                                │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  page.tsx → <DynamicPage slug="homepage" />              │
│       │                                                  │
│       ├── API: GET /api/v1/pages/homepage/               │
│       │   → { slug, title, blocks: [                     │
│       │       { block_type: "platform_hero", content },  │
│       │       { block_type: "platform_stats", content }, │
│       │       ...                                        │
│       │     ]}                                           │
│       │                                                  │
│       └── <BlockRenderer blocks={blocks} />              │
│            │                                             │
│            ├── platform_hero → <PlatformHero content={} />│
│            ├── platform_stats → <PlatformStats content={} />│
│            ├── services_showcase → <ServicesShowcase /> │
│            └── ...                                       │
│                                                          │
│  Fallback: إذا فشل الاتصال → fallbackBlocks ثابتة       │
└──────────────────────────────────────────────────────────┘
```

---

## نمط Content Overrides

جميع الكمبوننتات تتلقى `content` prop وتستخدمها كبديل عن i18n:

```tsx
// مثال: PlatformHero
export default function PlatformHero({ content }: { content?: Record<string, any> }) {
  const t = useTranslations("landing");
  const c = content || {};

  // إذا يوجد محتوى من الباك إند → استخدمه
  // وإلا → استخدم الترجمة الافتراضية
  const heading = locale === "ar"
    ? (c.heading_ar || c.heading_en || t("platformHeroTitle"))
    : (c.heading_en || t("platformHeroTitle"));

  return <h1>{heading}</h1>;
}
```

**الفائدة:** يمكن تعديل أي نص في الصفحة من الباك إند بدون تعديل الكود.

---

## مثال على بلوك Hero (من الباك إند)

```json
{
  "id": 1,
  "block_type": "platform_hero",
  "title_en": "Hero Section",
  "title_ar": "قسم البطل",
  "content": {
    "heading_en": "حلول رقمية ذكية لنجاح أعمالك",
    "heading_ar": "حلول رقمية ذكية لنجاح أعمالك",
    "subtitle_en": "نحول أفكارك إلى واقع رقمي مبتكر",
    "subtitle_ar": "نحول أفكارك إلى واقع رقمي مبتكر",
    "cta_text_en": "ابدأ مجاناً",
    "cta_text_ar": "ابدأ مجاناً",
    "cta_link_en": "/register",
    "cta_link_ar": "/register",
    "badges": [
      {"text_en": "مجاني تماماً", "text_ar": "مجاني تماماً"},
      {"text_en": "استشارة مجانية", "text_ar": "استشارة مجانية"}
    ]
  },
  "styles": {},
  "layout": {},
  "animation": {},
  "is_active": true,
  "order": 0
}
```

---

## الصلاحيات

### Admin (المدير) — مُنفّذ ✅
- صلاحيات كاملة على جميع الصفحات والبلوكات
- إنشاء/تعديل/حذف الصفحات
- إدارة البلوكات (إضافة/تعديل/حذف/إعادة ترتيب/تفعيل)
- إدارة القوائم (إضافة/تعديل/حذف/إعادة ترتيب)
- إدارة القوالب
- إدارة الثيمات
- إدارة الإعدادات

### Public (عام) — مُنفّذ ✅
- عرض الصفحات المنشورة فقط
- جلب القوائم النشطة
- جلب الإعدادات العامة

---

## مراحل التنفيذ

### المرحلة 1: الأساس ✅ مكتمل
1. ✅ Backend Models (Page, PageBlock, MenuItem, PageTemplate, SiteSettings)
2. ✅ Backend APIs (16 endpoint)
3. ✅ Admin Layout الموحد (sidebar + header)

### المرحلة 2: البلوكات ✅ مكتمل
4. ✅ Block Types (28 نوع — 6 جديدة للمنصة والتعليم)
5. ✅ Block Editor (إضافة/حذف/إعادة ترتيب/تفعيل)
6. ✅ Block Library (modal مع جميع الأنواع)
7. ✅ Live Preview (معاينة في المحرر)

### المرحلة 3: القوائم والقوالب ✅ مكتمل
8. ✅ Menu Manager (header/footer/sidebar tabs)
9. ✅ Template System (grid + CRUD)
10. ✅ Site Settings (معلومات + تواصل + تذييل)

### المرحلة 4: التكامل الديناميكي ✅ مكتمل
11. ✅ DynamicPage component (جلب slug من API)
12. ✅ BlockRenderer (ربط block_type بالكمبوننت)
13. ✅ Content overrides (16 كمبوننت يدعم content prop)
14. ✅ Seed script (3 صفحات + 22 بلوك مع محتوى كامل)
15. ✅ Fallback system (بلوكات ثابتة عند فشل الاتصال)

### المرحلة 5: التحسينات (مخطط 📋)
16. 📋 Property Panel (تعديل خصائص البلوك من الواجهة)
17. 📋 Live Preview realtime (معاينة مباشرة أثناء التعديل)
18. 📋 Revision History (سجل التعديلات)
19. 📋 Role Permissions (محرر vs مساهم)
20. 📋 Footer dynamic (ربط بالتذييل من الباك إند)
