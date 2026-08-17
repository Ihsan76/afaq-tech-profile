# شاشات الصفحة الرئيسية

> **ملاحظة:** الصفحات الثلاث الرئيسية (الرئيسية، الأكاديمية، المناهج) أصبحت **ديناميكية** — كل صفحة تُجلب من قاعدة البيانات عبر `DynamicPage.tsx` وتُعرض بواسطة `BlockRenderer.tsx`. المكونات تقبل `content` prop للobreasing من DB مع fallback على الترجمات.

---

## شاشة الصفحة الرئيسية — منصة آفاق تكنولوجي (Public)

### التدفق
```
/ (page.tsx)
  └─→ <DynamicPage slug="homepage">  ← يجلب الصفحة من API
        └─→ <BlockRenderer>          ← يُرتب البلوكات حسب order
              ├── PlatformHero      ← content من DB أو fallback i18n
              ├── PlatformStats
              ├── ServicesShowcase
              ├── PortfolioShowcase
              ├── PlatformHowItWorks
              ├── Testimonials
              ├── PricingSection
              ├── FAQSection
              └── CTAFooter
```

### العناصر
- **Navbar**: شعار + قوائم ديناميكية (من API `/pages/menu/header/`) + محوّل اللغة + محوّل الثيمات
- **Platform Hero**:
  - عنوان رئيسي: "آفاق تكنولوجي"
  - وصف فرعي: "منصتك الرقمية المتكاملة"
  - أزرار CTA: "تواصل معنا" + "اكتشف خدماتنا"
  - تقويم ثقة (مشاريع، مستخدمين، خدمات، خبرة)
- **Platform Stats**: إحصائيات المنصة (+150 مشروع، +500 مستخدم، 8 خدمات، +5 سنوات)
- **Services Showcase**: شبكة 8 خدمات رقمية
- **Portfolio Showcase**: معرض الأعمال (مشاريع مكتملة)
- **Platform How It Works**: كيف نعمل (4 خطوات)
- **Testimonials**: شهادات المستخدمين
- **Pricing Section**: باقات المنصة (الانطلاقة، النمو، الريادة)
- **FAQ Section**: أسئلة شائعة عن المنصة
- **CTA Footer**: دعوة للتواصل
- **Footer**: روابط + تواصل + حقوق

### المكونات (مكتملة ✅ — مع دعم content override)
| المكون | الملف | الحالة |
|--------|-------|--------|
| DynamicPage | `components/DynamicPage.tsx` | ✅ |
| BlockRenderer | `components/landing/BlockRenderer.tsx` | ✅ |
| PlatformHero | `components/landing/PlatformHero.tsx` | ✅ |
| PlatformStats | `components/landing/PlatformStats.tsx` | ✅ |
| ServicesShowcase | `components/landing/ServicesShowcase.tsx` | ✅ |
| PortfolioShowcase | `components/landing/PortfolioShowcase.tsx` | ✅ |
| PlatformHowItWorks | `components/landing/PlatformHowItWorks.tsx` | ✅ |
| Testimonials | `components/landing/Testimonials.tsx` | ✅ |
| PricingSection | `components/landing/PricingSection.tsx` | ✅ |
| FAQSection | `components/landing/FAQSection.tsx` | ✅ |
| CTAFooter | `components/landing/CTAFooter.tsx` | ✅ |

### بلوكات الصفحة الرئيسية (22 بلوك من seed_pages.py)
```
1.  platform_hero          — بطل الصفحة
2.  platform_stats         — إحصائيات المنصة
3.  platform_how_it_works  — كيف تعمل المنصة
4.  services_showcase      — 8 خدمات رقمية
5.  portfolio              — معرض الأعمال
6.  portfolio              — معرض الأعمال (قسم 2)
7.  testimonials           — شهادات العملاء
8.  pricing                — باقات الأسعار
9.  faq                    — أسئلة شائعة
```

---

## شاشة الأكاديمية (/academy) — الدورات والتعليم غير المنهجي

### التدفق
```
/academy (page.tsx)
  └─→ <DynamicPage slug="academy">
        └─→ <BlockRenderer>
              ├── HeroSection
              ├── StatsBar
              ├── FeaturesSection
              ├── HowItWorks
              ├── DemoShowcase
              ├── Testimonials
              ├── PricingSection
              ├── FAQSection
              └── CTAFooter
```

### العناصر
- **Navbar**: (نفس الصفحة الرئيسية — قوائم ديناميكية)
- **Hero**: تعريف الأكاديمية + إحصائيات
- **Stats**: إحصائيات الدورات (+20 دورة، +500 متدرب)
- **Features**: ميزات الأكاديمية
- **How It Works**: كيف تعمل الدورات
- **Demo**: عرض تجريبي
- **Testimonials**: شهادات المتدربين
- **Pricing**: باقات الدورات
- **FAQ**: أسئلة شائعة
- **CTA**: سجّل الآن
- **Footer**

### المكونات (مكتملة ✅ — مع دعم content override)
| المكون | الملف | الحالة |
|--------|-------|--------|
| HeroSection | `components/landing/HeroSection.tsx` | ✅ |
| StatsBar | `components/landing/StatsBar.tsx` | ✅ |
| FeaturesSection | `components/landing/FeaturesSection.tsx` | ✅ |
| HowItWorks | `components/landing/HowItWorks.tsx` | ✅ |
| DemoShowcase | `components/landing/DemoShowcase.tsx` | ✅ |
| Testimonials | `components/landing/Testimonials.tsx` | ✅ |
| PricingSection | `components/landing/PricingSection.tsx` | ✅ |
| FAQSection | `components/landing/FAQSection.tsx` | ✅ |
| CTAFooter | `components/landing/CTAFooter.tsx` | ✅ |

### بلوكات الأكاديمية (9 بلوكات من seed_pages.py)
```
1.  hero                  — بطل الأكاديمية
2.  stats                 — إحصائيات الدورات
3.  features              — ميزات الأكاديمية
4.  how_it_works          — كيف تعمل الدورات
5.  demo                  — عرض تجريبي
6.  testimonials          — شهادات المتدربين
7.  pricing               — باقات الدورات
8.  faq                   — أسئلة شائعة
9.  cta                   — دعوة للتسجيل
```

---

## شاشة المناهج الدراسية (/curriculum)

### التدفق
```
/curriculum (page.tsx)
  └─→ <DynamicPage slug="curriculum">
        └─→ <BlockRenderer>
              ├── GradeShowcase
              ├── SubjectsGrid
              └── PartnersBar
```

### العناصر
- **Navbar**: (نفس الصفحة الرئيسية)
- **GradeShowcase**: عرض المراحل الدراسية (ابتدائي، متوسط، ثانوي، جامعي)
- **SubjectsGrid**: شبكة المواد الدراسية
- **Partners**: الشركاء التعليميون (مدارس، وزارات)
- **Footer**

### المكونات (مكتملة ✅ — مع دعم content override)
| المكون | الملف | الحالة |
|--------|-------|--------|
| GradeShowcase | `components/landing/GradeShowcase.tsx` | ✅ |
| SubjectsGrid | `components/landing/SubjectsGrid.tsx` | ✅ |
| PartnersBar | `components/landing/PartnersBar.tsx` | ✅ |

### بلوكات المناهج (3 بلوكات من seed_pages.py)
```
1.  grade_showcase        — عرض المراحل الدراسية
2.  subjects_grid         — شبكة المواد الدراسية
3.  partners              — الشركاء التعليميون
```

---

## نمط Override المحتوى

كل مكون يقبل `content` prop اختياري. عند وجوده، يُظهر بيانات DB بدلاً من الترجمات:

```tsx
// مثال في PlatformHero
const title = content?.title_en || t("landing.platformHero.title");
const subtitle = content?.subtitle_en || t("landing.platformHero.subtitle");
```

- إذا لم يكن هناك `content` (صفحة جديدة بدون بلوكات) → يُظهر الترجمات (fallback)
- إذا كان هناك `content` → يُظهر البيانات من قاعدة البيانات (مع دعم RTL/LTR)

---

## السلوك المشترك

- **ديناميكي**: الصفحات تُجلب من API `/pages/<slug>/` — لا hardcoded content في الصفحة
- دعم RTL/LTR حسب اللغة
- تصميم متجاوب (Mobile-first)
- SEO محسّن (meta title/description من DB)
- تبديل الثيمات realtime (6 ثيمات)
- تبديل اللغة realtime (9 لغات)
- Fallback blocks: إذا فشل الاتصال بالـ API، تُظهر الصفحة الكتل الافتراضية (hardcoded fallback)

---

## شاشة لوحة التحكم العامة (Admin)

### العناصر
- **Header**: شعار + بحث + إشعارات + ملف شخصي
- **Sidebar**: قائمة تنقل حسب الدور (تصغير/توسيع)
- **Main Content**: محتوى الشاشة الحالية
- **Footer**: معلومات المنصة

### التنقل في لوحة تحكم المدير
```
📊 الرئيسية (إحصائيات عامة)
📄 الصفحات (إدارة صفحات الموقع)
🧩 البلوكات (إدارة محتوى الصفحات)
🎨 الثيمات (إدارة الألوان والتصميم)
📋 القوائم (إدارة القوائم)
📝 القوالب (قوالب صفحات جاهزة)
⚙️ الإعدادات (معلومات الموقع)

---Education---
📚 المواد الدراسية
📖 المناهج الدراسية
📁 الوحدات الدراسية

---Users---
👥 المستخدمون
🔑 الصلاحيات

---AI---
🤖 مراقبة AI

---Finance---
💳 المدفوعات
📊 التقارير
```

### السلوك
- Sidebar قابل للطي (collapsible)
- حفظ حالة Sidebar في localStorage
- تحديث الإشعارات بشكل حي (real-time)
- إعادة توجيه حسب الدور

---

## تخطيط لوحة التحكم (Admin)

```
+----------------------------------------------------------+
| Logo    [Search...]              🔔 3   👤 Admin  ▼      |
+----------------------------------------------------------+
|         |                                               |
| 📊 Home |                                               |
| 📄 Pages|           Main Content Area                   |
| 🧩 Block|                                               |
| 🎨 Theme|   (Page Builder / Widget Editor / Settings)   |
| 📋 Menu |                                               |
| 📝 Templ|                                               |
| ⚙️ Set  |                                               |
|─────────|                                               |
| 📚 Acad |                                               |
| 👥 Users|                                               |
| 🤖 AI   |                                               |
| 💳 Pay  |                                               |
|         |                                               |
+----------------------------------------------------------+
```

---

## التخطيط حسب الدور

### المعلم
```
📊 الرئيسية (إحصائيات، آخر الخطط)
📝 خطط الدروس (إنشاء، تعديل، عرض)
🎓 الأكاديمية (المنهاج، الدورات)
📚 الدورات (إنشاء دورة)
🛒 السوق (بيع خدمات)
📝 المدوّنة (كتابة مقالات)
💳 الدفع (المحفظة، المعاملات)
⚙️ الإعدادات
```

### الطالب
```
📊 الرئيسية (تقدم، إحصائيات)
📚 دوراتي
🤖 المساعد الذكي
🎯 اختباراتي
📊 تقدمي
⚙️ الإعدادات
```

### المدير
```
📊 الرئيسية (إحصائيات عامة)
📄 الصفحات (إدارة صفحات الموقع)
🧩 البلوكات (إدارة محتوى الصفحات)
🎨 الثيمات (إدارة الألوان والتصميم)
📋 القوائم (إدارة القوائم)
📝 القوالب (قوالب صفحات جاهزة)
⚙️ الإعدادات (معلومات الموقع)
📚 المواد الدراسية
📖 المناهج الدراسية
📁 الوحدات الدراسية
👥 المستخدمون
🔑 الصلاحيات
🤖 مراقبة AI
💳 المدفوعات
📊 التقارير
```
