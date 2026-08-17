# خطة تصميم صفحات الموقع — آفاق تكنولوجي

## نظرة عامة

المنصة ت gồm 3 صفحات رئيسية:

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

## الملفات المتأثرة

### ملفات جديدة (إنشاء)
| الملف | الوصف |
|-------|-------|
| `src/app/[locale]/page.tsx` | الصفحة الرئيسية (منصة آفاق تكنولوجي) |
| `src/app/[locale]/academy/page.tsx` | صفحة الأكاديمية (الدورات) |
| `src/app/[locale]/curriculum/page.tsx` | صفحة المناهج الدراسية |
| `src/components/landing/PlatformHero.tsx` | بطل الصفحة الرئيسية (المنصة) |
| `src/components/landing/PlatformStats.tsx` | إحصائيات المنصة |
| `src/components/landing/ServicesShowcase.tsx` | عرض 8 خدمات |
| `src/components/landing/PortfolioShowcase.tsx` | معرض الأعمال |
| `src/components/landing/PlatformHowItWorks.tsx` | كيف نعمل |
| `src/components/landing/Testimonials.tsx` | شهادات العملاء |
| `src/components/landing/PricingSection.tsx` | باقات الأسعار |
| `src/components/landing/FAQSection.tsx` | الأسئلة الشائعة |
| `src/components/landing/CTAFooter.tsx` | دعوة للعمل |
| `src/components/landing/HeroSection.tsx` | بطل الأكاديمية |
| `src/components/landing/StatsBar.tsx` | إحصائيات الأكاديمية |
| `src/components/landing/FeaturesSection.tsx` | ميزات الأكاديمية |
| `src/components/landing/HowItWorks.tsx` | كيف تعمل الدورات |
| `src/components/landing/DemoShowcase.tsx` | عرض تجريبي |
| `src/components/landing/GradeShowcase.tsx` | عرض المراحل الدراسية |
| `src/components/landing/SubjectsGrid.tsx` | شبكة المواد |
| `src/components/landing/PartnersBar.tsx` | الشركاء التعليميون |

### ملفات معدلة
| الملف | التغيير |
|-------|---------|
| `src/i18n/messages/en.json` | إضافة ~130+ مفتاح ترجمة (company, services, curriculum) |
| `src/i18n/messages/ar.json` | إضافة ~130+ مفتاح ترجمة |
| `src/components/Navbar.tsx` | إضافة رابط Curriculum + theme switcher dropdown |
| `src/components/NavbarWrapper.tsx` | إخفاء Navbar في صفحات Auth فقط |
| `src/app/globals.css` | CSS variables + animations + .btn-primary utility |
| `src/app/[locale]/admin/widgets/page.tsx` | إضافة 5 أنواع company widgets |
| `backend/apps/pages/` | نموذج جديد (Page, PageBlock, MenuItem, PageTemplate, SiteSettings) |

---

## التصميم التفصيلي — الصفحة الرئيسية (المنصة)

### 1. Platform Hero — `PlatformHero.tsx`

**الهدف:** أول انطباع — تعريف "آفاق تكنولوجي" كمنصة رقمية شاملة

**التصميم:**
- **خلفية:** تدرج متحرك (gradient animation) يستخدم `--color-primary` و `--color-secondary`
- **تأثير الجسيمات:** نقاط متحركة صغيرة (CSS particles) تتحرك في الخلفية
- **الشعار:** أيقونة "آ" كبيرة مع تأثير glow متحرك
- **العنوان الرئيسي:** "آفاق تكنولوجي" بخط كبير مع تأثير gradient text
- **العنوان الفرعي:** "منصتك الرقمية المتكاملة — نحول أفكارك إلى واقع رقمي"
- **أزرار CTA:**
  - "تواصل معنا" (زر رئيسي gradient)
  - "اكتشف خدماتنا" (زر ثانوي outline)
- **تقويم الثقة:** أيقونات + أرقام (مشاريع مكتملة، مستخدمين سعداء، خبرة)

**الأبعاد:** `min-h-screen` مع flex centering

---

### 2. Platform Stats — `PlatformStats.tsx`

**الهدف:** بناء الثقة بالأرقام

**التصميم:**
- شريط أفقي على الخلفية `--color-surface`
- 4 أعمدة بإحصائيات:
  - **+150** مشروع مكتمل
  - **+500** مستخدم نشط
  - **8** خدمات رقمية
  - **+5** سنوات خبرة
- الأرقام تظهر بتأثير عدّاد (counting animation) عند التمرير

**الأبعاد:** `py-12` مع `max-w-6xl mx-auto`

---

### 3. Services Showcase — `ServicesShowcase.tsx`

**الهدف:** عرض 8 الخدمات الرقمية

**التصميم:**
- عنوان القسم: "خدماتنا الرقمية"
- شبكة بطاقات (grid 4 أعمدة / 2 في الموبايل):
  1. **🌐 تصميم المواقع** — مواقع احترافية متجاوبة
  2. **📱 إدارة التواصل الاجتماعي** — إدارة محتوى وتفاعل
  3. **📄 صفحات الهبوط** — صفحات عالية التحويل
  4. **📋 النماذج الإلكترونية** — نماذج تفاعلية ذكية
  5. **📚 الكتب الإلكترونية** — إنتاج رقمي احترافي
  6. **🎓 المنصة التعليمية** — أكاديمية دورات + AI
  7. **📢 الحملات الإعلانية** — إدارة حملات إعلانية
  8. **🎨 الهوية البصرية** — تصميم شعارات + استشارات

**كل بطاقة:**
- أيقونة كبيرة في دائرة ملونة
- عنوان الخدمة
- وصف قصير (سطرين)
- زر "اعرف المزيد"

**الأبعاد:** `py-20` مع `max-w-6xl mx-auto`

---

### 4. Platform How It Works — `PlatformHowItWorks.tsx`

**الهدف:** شرح كيف تعمل المنصة (4 خطوات)

**التصميم:**
- عنوان القسم: "كيف نعمل؟"
- 4 خطوات متتالية بتصميم timeline:
  1. **تواصل معنا** — أرسل لنا تفاصيل مشروعك
  2. **التخطيط** — نحلل احتياجاتك ونضع خطة عمل
  3. **التنفيذ** — ننفذ المشروع بأعلى جودة
  4. **الدعم** — نقدم دعم مستمر بعد التسليم

**كل خطوة:**
- رقم دائري ملون (1، 2، 3، 4)
- عنوان
- وصف قصير
- سهم يربط بالخطوة التالية

**الأبعاد:** `py-20` مع خلفية `--color-surface-alt`

---

### 5. Demo Showcase — `DemoShowcase.tsx`

**الهدف:** عرض المنصة بشكل بصري (بدون صور حقيقية — CSS mockup)

**التصميم:**
- عنوان القسم: "المنصة قيد الإنشاء" أو "شاهد كيف تعمل"
- محاكاة (mockup) للمنصة:
  - إطار متصفح بسيط (div بحدود مستديرة)
  - شريط عناوين المتصفح (dots ملونة)
  - محتوى تجريبي: نموذج إدخال + نتيجة خطة درس
- النص: "قريباً — ستجرب المنصة بنفسك"

**الأبعاد:** `py-20` مع `max-w-4xl mx-auto`

---

### 6. Testimonials — `Testimonials.tsx`

**الهدف:** بناء الثقة بشهادات حقيقية (مُلهم من ibtdi.com)

**التصميم:**
- عنوان القسم: "ماذا يقول المعلمون؟"
- 3 شهادات في بطاقات:
  1. "المنصة وفّرت علي ساعات من العمل" — معلم رياضيات
  2. "خطط الدروس بالذكاء الاصطناعي مذهلة" — معلم علوم
  3. "أفضل أداة للمعلمين في المنطقة" — معلم لغة عربية
- كل شهادة: اقتباس + اسم + مسمى + نجوم (⭐⭐⭐⭐⭐)
- تصميم: بطاقات بخلفية `--color-surface` مع حدود `--color-border`

**الأبعاد:** `py-20` مع `max-w-5xl mx-auto`

---

### 7. Pricing Section — `PricingSection.tsx`

**الهدف:** عرض باقات المنصة

**التصميم:**
- عنوان القسم: "اختر الخطة المناسبة"
- 3 باقات:
  1. **الانطلاقة** — $300/شهر
     - صفحة هبوط
     - منصة تواصل اجتماعي واحدة
     - 12 منشور/شهر
     - 500$ ميزانية إعلانية
  2. **النمو** — $800/شهر ⭐ (الأكثر شعبية)
     - موقع إلكتروني
     - 3 منصات تواصل اجتماعي
     - 30 منشور/شهر
     - حملة إعلانية واحدة
  3. **الريادة** — $2000/شهر
     - موقع متكامل
     - جميع منصات التواصل
     - 60 منشور + فيديو
     - حملات إعلانية متعددة

**كل باقة:**
- عنوان + سعر
- قائمة المميزات مع ✓
- زر CTA

**الأبعاد:** `py-20` مع `max-w-5xl mx-auto`

---

### 8. FAQ Section — `FAQSection.tsx`

**الهدف:** الإجابة على الأسئلة الشائعة

**التصميم:**
- عنوان القسم: "الأسئلة الشائعة"
- 5-6 أسئلة بتصميم accordion:
  1. هل المنصة مجانية؟
  2. كيف يعمل الذكاء الاصطناعي؟
  3. هل تدعم المنصة جميع المناهج؟
  4. كيف يمكنني التواصل مع الدعم؟
  5. هل يمكنني استخدام المنصة بدون تسجيل؟

**الأبعاد:** `py-20` مع `max-w-3xl mx-auto`

---

### 9. CTA Footer — `CTAFooter.tsx`

**الهدف:** دعوة أخيرة للعمل

**التصميم:**
- خلفية gradient (primary → secondary)
- عنوان: "ابدأ رحلتك التعليمية اليوم"
- نص: "انضم إلى آلاف المعلمين الذين يستخدمون الذكاء الاصطناعي لتحسين تجربة التدريس"
- زر CTA: "إنشاء حساب مجاني"
- أيقونات الثقة: نجوم + تقييم

**الأبعاد:** `py-20` مع `rounded-3xl mx-4 mb-8`

---

## التصميم التفصيلي — صفحة الأكاديمية

### 1. Academy Hero — `AcademyHero.tsx`

**التصميم:**
- خلفية gradient خفيفة
- عنوان: "أكاديمية آفاق"
- فرعي: "استكشف المواد والمناهج الدراسية لجميع المراحل"
- إحصائيات صغيرة: عدد المواد، عدد المناهج، عدد الصفوف

### 2. Grade Showcase — `GradeShowcase.tsx`

**التصميم:**
- عنوان: "اختر المرحلة الدراسية"
- شبكة بطاقات للصفوف (يتم جلبها من API)
- كل بطاقة: أيقونة + اسم الصف + عدد المواد

### 3. Subjects Grid — `SubjectsGrid.tsx`

**التصميم:**
- عنوان: "المواد الدراسية"
- شبكة أيقونات للمواد
- كل مادة: أيقونة + اسم المادة + عدد الوحدات

### 4. Partners Bar — `PartnersBar.tsx`

**التصميم:**
- شريط الشركاء (مدارس، وزارات)
- شعارات بسيطة (placeholder)
- نص: "شركاؤنا في النجاح"

---

## هيكل المكونات

```
src/components/landing/
├── PlatformHero.tsx           # بطل الصفحة الرئيسية (المنصة)
├── PlatformStats.tsx          # إحصائيات المنصة
├── ServicesShowcase.tsx       # عرض 8 خدمات
├── PortfolioShowcase.tsx      # معرض الأعمال
├── PlatformHowItWorks.tsx     # كيف نعمل
├── HeroSection.tsx            # بطل الأكاديمية
├── StatsBar.tsx               # إحصائيات الأكاديمية
├── FeaturesSection.tsx        # ميزات الأكاديمية
├── HowItWorks.tsx             # كيف تعمل الدورات
├── DemoShowcase.tsx           # عرض تجريبي
├── Testimonials.tsx           # شهادات (shared)
├── PricingSection.tsx         # الأسعار (shared)
├── FAQSection.tsx             # الأسئلة الشائعة (shared)
├── CTAFooter.tsx              # الدعوة النهائية (shared)
├── GradeShowcase.tsx          # عرض المراحل الدراسية
├── SubjectsGrid.tsx           # شبكة المواد
├── PartnersBar.tsx            # الشركاء التعليميون
└── WidgetRenderer.tsx         # محرر البلوكات
```

---

## نظام الترجمة

### مفاتيح جديدة في `en.json` و `ar.json`

#### الصفحة الرئيسية (المنصة)
```json
{
  "landing": {
    "platformHero": {
      "title": "آفاق تكنولوجي",
      "subtitle": "منصتك الرقمية المتكاملة",
      "cta": "تواصل معنا",
      "secondaryCta": "اكتشف خدماتنا"
    },
    "platformStats": {
      "projects": "+150 مشروع مكتمل",
      "users": "+500 مستخدم نشط",
      "services": "8 خدمات رقمية",
      "experience": "+5 سنوات خبرة"
    },
    "services": {
      "title": "خدماتنا الرقمية",
      "webDesign": "تصميم المواقع",
      "socialMedia": "إدارة التواصل الاجتماعي",
      "landingPages": "صفحات الهبوط",
      "forms": "النماذج الإلكترونية",
      "ebooks": "الكتب الإلكترونية",
      "academy": "المنصة التعليمية",
      "ads": "الحملات الإعلانية",
      "branding": "الهوية البصرية"
    },
    "platformHowItWorks": {
      "title": "كيف نعمل؟",
      "step1": "تواصل معنا",
      "step2": "التخطيط",
      "step3": "التنفيذ",
      "step4": "الدعم"
    },
    "pricingTitle": "اختر الخطة المناسبة",
    "planStarter": "الانطلاقة",
    "planGrowth": "النمو",
    "planEnterprise": "الريادة"
  }
}
```

#### الأكاديمية (الدورات)
```json
{
  "landing": {
    "academyHero": {
      "title": "أكاديمية آفاق",
      "subtitle": "تعلم مهارات جديدة مع دورات احترافية"
    },
    "academyStats": {
      "courses": "+20 دورة",
      "students": "+500 متدرب",
      "rating": "4.8/5 تقييم"
    }
  }
}
```

#### المناهج الدراسية
```json
{
  "landing": {
    "curriculum": {
      "title": "المناهج الدراسية",
      "subtitle": "مناهج شاملة لكل المراحل"
    }
  }
}
```

---

## المتغيرات المطلوبة من globals.css (موجودة بالفعل)

```
--color-primary, --color-primary-hover, --color-primary-light
--color-secondary, --color-secondary-hover
--color-accent, --color-accent-light
--color-success, --color-success-light
--color-background, --color-surface, --color-surface-alt
--color-text, --color-text-secondary, --color-text-muted
--color-border, --color-border-light
--font-heading, --font-body
--btn-primary-bg, --btn-primary-color
--btn-outline-bg, --btn-outline-color, --btn-outline-border
--btn-shadow, --card-shadow
--card-radius, --card-border
```

**ملاحظة:** لا حاجة لإضافة متغيرات جديدة — النظام الحالي كافٍ.

---

## الأنيميشن المطلوبة

### في globals.css (إضافة)
```css
@keyframes countUp {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

@keyframes fadeInUp {
  from { opacity: 0; transform: translateY(30px); }
  to { opacity: 1; transform: translateY(0); }
}

@keyframes slideInLeft {
  from { opacity: 0; transform: translateX(-30px); }
  to { opacity: 1; transform: translateX(0); }
}

@keyframes gradientShift {
  0% { background-position: 0% 50%; }
  50% { background-position: 100% 50%; }
  100% { background-position: 0% 50%; }
}

.animate-fade-in-up {
  animation: fadeInUp 0.6s ease-out forwards;
}

.animate-count-up {
  animation: countUp 0.8s ease-out forwards;
}

.animate-gradient {
  background-size: 200% 200%;
  animation: gradientShift 3s ease infinite;
}
```

---

## الترتيب التنفيذى

### المرحلة 1: الأساس (مكتمل ✅)
1. ✅ إنشاء ملف `globals.css` — CSS variables + animations + utilities
2. ✅ إنشاء `PlatformHero.tsx` — بطل الصفحة الرئيسية
3. ✅ إنشاء `PlatformStats.tsx` — إحصائيات المنصة
4. ✅ إنشاء `ServicesShowcase.tsx` — عرض 8 خدمات
5. ✅ تحديث `page.tsx` — تجميع الصفحة الرئيسية

### المرحلة 2: المحتوى (مكتمل ✅)
6. ✅ إنشاء `PlatformHowItWorks.tsx` — كيف نعمل
7. ✅ إنشاء `PortfolioShowcase.tsx` — معرض الأعمال
8. ✅ إنشاء `Testimonials.tsx` — شهادات المستخدمين
9. ✅ تحديث `en.json` و `ar.json` — 130+ مفتاح ترجمة

### المرحلة 3: التحويل (مكتمل ✅)
10. ✅ إنشاء `PricingSection.tsx` — باقات المنصة
11. ✅ إنشاء `FAQSection.tsx` — أسئلة شائعة
12. ✅ إنشاء `CTAFooter.tsx` — تواصل معنا

### المرحلة 4: الأكاديمية (مكتمل ✅)
13. ✅ إنشاء `HeroSection.tsx` — بطل الأكاديمية
14. ✅ إنشاء `StatsBar.tsx` — إحصائيات الدورات
15. ✅ إنشاء `FeaturesSection.tsx` — ميزات الأكاديمية
16. ✅ تحديث `academy/page.tsx` — تجميع صفحة الأكاديمية

### المرحلة 5: المناهج (مكتمل ✅)
17. ✅ إنشاء `GradeShowcase.tsx` — عرض المراحل
18. ✅ إنشاء `SubjectsGrid.tsx` — شبكة المواد
19. ✅ إنشاء `PartnersBar.tsx` — الشركاء
20. ✅ إنشاء `curriculum/page.tsx` — صفحة المناهج

### المرحلة 6: النظام الديناميكي (مكتمل ✅)
21. ✅ إنشاء `WidgetRenderer.tsx` — محرر البلوكات
22. ✅ تحديث `admin/widgets/page.tsx` — إدارة البلوكات
23. ✅ إنشاء `seed_widgets.py` — 21 widget (9 homepage + 9 academy + 3 curriculum)

### المرحلة 7: نظام الصفحة (مكتمل ✅)
24. ✅ ربط pages app في Django (INSTALLED_APPS, urls.py, admin)
25. ✅ إنشاء Admin Layout موحد (collapsible sidebar)
26. ✅ بناء Page Builder UI (drag & drop reorder, 28 block types)
27. ✅ ربط Navbar بالقوائم الديناميكية (من API)
28. ✅ إنشاء DynamicPage.tsx + BlockRenderer.tsx (rendering من API)
29. ✅ تحديث 16 مكون landing بـ content override prop
20. ✅ تحويل 3 صفحات للنظام الديناميكي (/page.tsx, /academy/page.tsx, /curriculum/page.tsx)
21. ✅ إنشاء seed_pages.py (3 صفحات، 22 بلوك، محتوى ثنائي اللغة كامل)
22. ✅ إنشاء 5 نماذج backend (Page, PageBlock, MenuItem, PageTemplate, SiteSettings)
23. ✅ إنشاء 16 API endpoint (public + admin)
24. ✅ إنشاء BlockType migration (28 نوع + max_length fix 20→30)

### المرحلة 8: التحسينات (مخطط 📋)
30. 📋 صفحة ديناميكية عامة — إنشاء أي slug جديد تلقائياً (بدون hardcoded route)
31. 📋 Footer يجلب القوائم من API
32. 📋 Page Builder — خصائص CSS لكل بلوك (padding, margin, bg color)
33. 📋 Page Builder — معاينة حية realtime أثناء التعديل
34. 📋 Page Builder — تاريخ المراجعات (revisions)
35. 📋 SEO — og:image, structured data من DB
36. 📋 Page Templates — إنشاء صفحة من قالب جاهز (one-click)

---

## ملاحظات تقنية

- **لا صور حقيقية:** جميع التصميمات CSS-only مع أيقونات emoji
- **RTL Support:** جميع الصفحات تدعم الاتجاه من اليمين لليسار
- **Theme Compatible:** كل الألوان من CSS variables — يعمل مع 6 ثيمات
- **Responsive:** جميع المكونات responsive (mobile-first)
- **Performance:** لا مكتبات خارجية — كل شيء native React + Tailwind
- **i18n:** كل النصوص عبر `useTranslations()` — دعم 9 لغات
- **Dynamic Pages:** الصفحات تُجلب من API — لا hardcoded في الكود (فقط fallback)

---

## نظام العرض الديناميكي ✅

### الملفات الأساسية
```
frontend/src/components/DynamicPage.tsx    ← يجلب صفحة من /api/pages/<slug>/
frontend/src/components/landing/BlockRenderer.tsx  ← يُرتب البلوكات حسب block_type
```

### تدفق العرض
```
page.tsx (/  أو /academy أو /curriculum)
  └─→ <DynamicPage slug="...">
        ├─→ fetch(`http://localhost:8003/api/v1/pages/${slug}/`)
        ├─→ parse response → { blocks: [...] }
        └─→ <BlockRenderer blocks={blocks}>
              └─→ map block_type → component
                    └─→ component({ content: block.content, ... })
```

### المكونات التي تدعم content override (16 مكون)
```
PlatformHero, PlatformStats, PlatformHowItWorks, ServicesShowcase,
PortfolioShowcase, HeroSection, StatsBar, FeaturesSection, HowItWorks,
DemoShowcase, Testimonials, PricingSection, FAQSection, CTAFooter,
GradeShowcase, SubjectsGrid, PartnersBar
```

### نظام Override
```tsx
// كل مكون يقبل content?: any
export default function PlatformHero({ content }: { content?: any }) {
  const t = useTranslations("landing");
  const title = content?.title_en || t("landing.platformHero.title");
  // ...
}
```

### BLE (Backend) seed
```
backend/seed_pages.py → ينشئ 3 صفحات + 22 بلوك + محتوى ثنائي اللغة
backend/apps/pages/ → 5 نماذج + 16 API endpoint + admin registered
```
