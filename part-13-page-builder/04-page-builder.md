# محرر الصفحة (Page Builder)

## نظرة عامة

محرر الصفحة هو واجهة_admin تسمح للمدير ببناء وتعديل صفحات الموقع بصرياً — مشابه لـ WordPress/Elementor.

> **حالة التنفيذ:** مكتمل ✅

---

## تخطيط الواجهة

```
┌─────────────────────────────────────────────────────────────┐
│  Admin Layout (sidebar + header)                            │
├─────────────────────────────────────────────────────────────┤
│  Page Editor                                                │
│  ┌──────────────────────────┬──────────────────────────────┐│
│  │ Block List (Sidebar)     │ Live Preview                 ││
│  │                          │                              ││
│  │ [+ Add Block]            │  ┌────────────────────────┐  ││
│  │                          │  │ PlatformHero           │  ││
│  │ [☰] platform_hero  ✏️ 🗑│  │ (معاينة حية)           │  ││
│  │ [☰] platform_stats  ✏️🗑│  │                        │  ││
│  │ [☰] services_showcase✏️🗑│  │                        │  ││
│  │ ...                      │  └────────────────────────┘  ││
│  │                          │                              ││
│  │ [⚙️ Page Settings]       │  ┌────────────────────────┐  ││
│  │                          │  │ PlatformStats          │  ││
│  │                          │  │ (معاينة حية)           │  ││
│  │                          │  └────────────────────────┘  ││
│  └──────────────────────────┴──────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

---

## الميزات الرئيسية

### 1. إضافة بلوكات (+ Add Block)
- زر "إضافة بلوك" في أعلى القائمة
- يفتح modal مع **39 نوع بلوك**
- كل نوع يظهر بأيقونة + اسم بالإنجليزية والعربية
- النقر على النوع يضيف بلوكاً جديداً للصفحة

### 2. إدارة البلوكات
- **سحب وإفلات** لإعادة ترتيب البلوكات
- **تفعيل/إيقاف** كل بلوك (toggle)
- **تعديل** — يفتح BlockEditorPanel
- **حذف** — بتأكيد

### 3. BlockEditorPanel
محرر متخصص لكل نوع بلوك:

#### Content tab
- حقول محددة حسب نوع البلوك
- مثال لـ `platform_hero`: heading_en/ar, subtitle_en/ar, cta_text_en/ar, cta_link, badges
- مثال لـ `accordion`: items (title_en/ar, content_en/ar, icon)
- مثال لـ `countdown`: target_date, label_en/ar

#### Styles tab
- **Background**: لون خلفية، صورة خلفية، تدرج
- **Text**: لون النص، حجم الخط، محاذاة
- **Spacing**: padding (top, right, bottom, left), margin
- **Border**: لون الحدود، سمك، شكل الزوايا
- **Custom CSS**: كود CSS مخصص

### 4. معاينة حية (Live Preview)
- كل تعديل يظهر فوراً في المعاينة
- PageBlockPreview يعرض البلوك كما سيبدو في الموقع
- يدعم 17 نوع من البلوكات للمعاينة

### 5. إعدادات الصفحة (Page Settings)
- **General**: العنوان (EN/AR)، الوصف (EN/AR)، القالب
- **SEO**: meta_title (EN/AR)، meta_description (EN/AR)
- **Navigation**: show_in_nav، nav_order، parent_page، nav_icon
- **Publish**: is_published، is_homepage
- **Theme**: theme_overrides (تخصيص ثيم للصفحة)

---

## تدفق الحفظ

```
المدير يعدّل محتوى البلوك في BlockEditorPanel
    │
    ▼
البيانات تُجمع في content JSON
    │
    ▼
PUT /api/v1/pages/admin/pages/<page_id>/blocks/<block_id>/
    │
    ▼
الباك إند يحفظ في قاعدة البيانات
    │
    ▼
الصفحة تتحدث فوراً عند التحميل التالي
```

---

## مثال على تعديل بلوك

### طلب PUT
```json
{
  "content": {
    "heading_en": "Smart Digital Solutions for Your Business",
    "heading_ar": "حلول رقمية ذكية لأعمالك",
    "subtitle_en": "We transform ideas into innovative digital reality",
    "subtitle_ar": "نحول أفكارك إلى واقع رقمي مبتكر",
    "cta_text_en": "Start Free",
    "cta_text_ar": "ابدأ مجاناً",
    "cta_link": "/register",
    "badges": [
      {"text_en": "100% Free", "text_ar": "مجاني تماماً"},
      {"text_en": "Free Consultation", "text_ar": "استشارة مجانية"}
    ]
  },
  "styles": {
    "background": "linear-gradient(135deg, #667eea 0%, #764ba2 100%)",
    "textColor": "#ffffff"
  }
}
```

---

## هيكل الملفات

```
src/app/[locale]/admin/pages/
├── page.tsx                      # قائمة الصفحات + إنشاء
└── [pageId]/
    └── page.tsx                  # محرر الصفحة

src/components/admin/
└── BlockEditorPanel.tsx          # محرر محتوى البلوك (881 سطر)

src/components/landing/
├── BlockRenderer.tsx             # مُرتجع البلوكات (28 نوع)
├── PageBlockPreview.tsx          # معاينة حية (17 نوع)
└── [32 landing component]        # الكمبوننتات الفعلية
```

---

## ملخص

> المحرر يوفر تجربة بناء صفحات بصرياً كاملة — من إضافة البلوكات (39 نوع) إلى تخصيص المحتوى والستايلات، مع معاينة حية وحفظ مباشر في قاعدة البيانات.
