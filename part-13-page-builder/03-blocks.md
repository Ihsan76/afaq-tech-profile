# نظام البلوكات (Block System)

## نظرة عامة

البلوكات (PageBlock) هي الوحدات البنائية للصفحات. كل بلوك يمثل قسماً من الصفحة يمكن تخصيص محتواه وستايله من لوحة الإدارة.

> **حالة التنفيذ:** مكتمل ✅ — **40 نوع بلوك**

---

## نموذج البلوك (PageBlock)

```python
class PageBlock(models.Model):
    page = models.ForeignKey(Page, on_delete=models.CASCADE, related_name='blocks')
    block_type = models.CharField(max_length=30, choices=BlockType.choices)

    title_en = models.CharField(max_length=200, blank=True, default='')
    title_ar = models.CharField(max_length=200, blank=True, default='')
    subtitle_en = models.CharField(max_length=500, blank=True, default='')
    subtitle_ar = models.CharField(max_length=500, blank=True, default='')

    content = models.JSONField(default=dict, blank=True)    # المحتوى الديناميكي
    styles = models.JSONField(default=dict, blank=True)     # الأنماط المخصصة
    layout = models.JSONField(default=dict, blank=True)     # التخطيط
    animation = models.JSONField(default=dict, blank=True)  # الأنيميشن

    is_active = models.BooleanField(default=True)
    order = models.IntegerField(default=0)
```

---

## أنواع البلوكات — 40 نوع

### بلوكات المنصة (Platform) — 4
| النوع | العرض | الوصف | الكمبوننت |
|-------|-------|-------|-----------|
| `platform_hero` | بطل الصفحة (المنصة) | تعريف المنصة + أزرار CTA + badges | PlatformHero |
| `platform_stats` | إحصائيات (المنصة) | أرقام المنصة (مشاريع، مستخدمين، خدمات، خبرة) | PlatformStats |
| `platform_how_it_works` | كيف تعمل (المنصة) | خطوات العمل (3 خطوات) | PlatformHowItWorks |
| `services_showcase` | عرض الخدمات | 8 خدمات رقمية | ServicesShowcase |

### بلوكات الأكاديمية (Academy) — 7
| النوع | العرض | الوصف | الكمبوننت |
|-------|-------|-------|-----------|
| `hero` | بطل الصفحة | بطل عام لأي صفحة | HeroSection |
| `stats` | إحصائيات | أرقام وإحصائيات | StatsBar |
| `features` | الميزات | شبكة ميزات (6) | FeaturesSection |
| `how_it_works` | كيف يعمل | شرح آلية التعلم | HowItWorks |
| `demo` | عرض توضيحي | Demo للمنصة | DemoShowcase |
| `grade_showcase` | عرض الصفوف | المراحل الدراسية (من API) | GradeShowcase |
| `subjects_grid` | شبكة المواد | المواد الدراسية | SubjectsGrid |

### بلوكات التسويق (Marketing) — 6
| النوع | العرض | الوصف | الكمبوننت |
|-------|-------|-------|-----------|
| `testimonials` | شهادات | آراء العملاء/المتدربين (كاروسيل) | Testimonials |
| `pricing` | التسعير | باقات الأسعار (3 باقات) | PricingSection |
| `faq` | أسئلة شائعة | الأسئلة المتكررة (أكورديون) | FAQSection |
| `cta` | دعوة للعمل | زر + نص CTA | CTAFooter |
| `portfolio` | معرض أعمال | مشاريع مكتملة | PortfolioShowcase |
| `partners` | الشركاء | شعارات الشركاء | PartnersBar |

### بلوكات المحتوى (Content) — 6
| النوع | العرض | الوصف | الكمبوننت |
|-------|-------|-------|-----------|
| `text` | نص | محتوى نصي عام | (افتراضي) |
| `image` | صورة | صورة مع وصف | (افتراضي) |
| `video` | فيديو | فيديو مدمج | (افتراضي) |
| `gallery` | معرض صور | مجموعة صور | (افتراضي) |
| `custom_html` | HTML مخصص | كود HTML مخصص | (افتراضي) |
| `blog_list` | مقالات المدوّنة | عرض أحدث المقالات من API | BlogListBlock |

### بلوكات التخطيط (Layout) — 2
| النوع | العرض | الوصف | الكمبوننت |
|-------|-------|-------|-----------|
| `spacer` | مسافة | فراغ رأسي | (افتراضي) |
| `divider` | فاصل | خط فاصل | (افتراضي) |

### بلوكات إضافية (Additional) — 4
| النوع | العرض | الوصف | الكمبوننت |
|-------|-------|-------|-----------|
| `services` | خدمات | عرض خدمات (عام) | (افتراضي) |
| `team` | الفريق | أعضاء الفريق | (افتراضي) |
| `contact` | تواصل معنا | نموذج اتصال | (افتراضي) |
| `form` | نموذج | نموذج مخصص | (افتراضي) |

### بلوكات جديدة (New) — 11
| النوع | العرض | الوصف | الكمبوننت |
|-------|-------|-------|-----------|
| `accordion` | أقسام قابلة للطي | أقسام قابلة للطي مع عنوان + محتوى | AccordionSection |
| `tabs` | تبويبات | تبويبات مع عنوان + محتوى | TabsSection |
| `timeline` | خط زمني | خط زمني مع تاريخ + عنوان + وصف | TimelineSection |
| `countdown` | عداد تنازلي | عداد تنازلي مع تاريخ هدف | CountdownSection |
| `newsletter` | اشتراك بريد | نموذج اشتراك بريد إلكتروني | NewsletterSection |
| `map` | خريطة | خريطة Google Maps عبر iframe | MapSection |
| `table` | جدول بيانات | جدول ديناميكي مع رؤوس ثنائية اللغة | TableSection |
| `icon_list` | قائمة أيقونات | قائمة مع أيقونات + نص | IconListSection |
| `logo_carousel` | كاروسيل شعارات | كاروسيل متحرك للشعارات | LogoCarouselSection |
| `download` | تحميل ملف | بطاقات تحميل ملفات | DownloadSection |
| `code` | بلوك كود | كود مُنسّق مع تلوين句法 | CodeSection |

---

## نمط Content Overrides

جميع الكمبوننتات تتلقى `content` prop وتستخدمها كبديل عن i18n:

```tsx
export default function PlatformHero({ content }: { content?: Record<string, any> }) {
  const t = useTranslations("landing");
  const c = content || {};

  // إذا وُجد محتوى من الباك إند → استخدمه
  // وإلا → استخدم الترجمة الافتراضية
  const heading = locale === "ar"
    ? (c.heading_ar || c.heading_en || t("platformHeroTitle"))
    : (c.heading_en || t("platformHeroTitle"));

  return <h1>{heading}</h1>;
}
```

**الفائدة:** يمكن تعديل أي نص في الصفحة من الباك إند بدون تعديل الكود.

---

## API Endpoints

### إدارة البلوكات

| Method | Endpoint | الوصف |
|--------|----------|-------|
| GET | `/api/v1/pages/admin/pages/<page_id>/blocks/` | جلب بلوكات صفحة |
| POST | `/api/v1/pages/admin/pages/<page_id>/blocks/` | إضافة بلوك |
| PUT | `/api/v1/pages/admin/pages/<page_id>/blocks/<pk>/` | تعديل بلوك |
| DELETE | `/api/v1/pages/admin/pages/<page_id>/blocks/<pk>/delete/` | حذف بلوك |
| PUT | `/api/v1/pages/admin/pages/<page_id>/blocks/reorder/` | إعادة ترتيب |

### مثال على طلب إضافة بلوك
```json
{
  "block_type": "platform_hero",
  "title_en": "Hero Section",
  "title_ar": "قسم البطل",
  "content": {
    "heading_en": "Smart Digital Solutions",
    "heading_ar": "حلول رقمية ذكية",
    "subtitle_en": "We turn your ideas into digital reality",
    "subtitle_ar": "نحول أفكارك إلى واقع رقمي",
    "cta_text_en": "Get Started",
    "cta_text_ar": "ابدأ الآن",
    "cta_link": "/register"
  },
  "is_active": true,
  "order": 0
}
```

---

## المكونات ال frontend

### BlockRenderer.tsx
يربط `block_type` بالكمبوننت المناسب:
```
platform_hero → <PlatformHero />
platform_stats → <PlatformStats />
services_showcase → <ServicesShowcase />
hero → <HeroSection />
stats → <StatsBar />
blog_list → <BlogListBlock />
... (29 نوع مربوط)
```

### PageBlockPreview.tsx
معاينة حية في محرر الصفحة — يدعم 17 نوع.

### BlockEditorPanel.tsx (881 سطر)
محرر محتوى البلوك — لكل نوع:
- **Content tab**: حقول محددة حسب النوع (عناوين، أزرار، عناصر، إلخ)
- **Styles tab**: خلفية، نص، تباعد، حدود، CSS مخصص

---

## ملخص

> نظام البلوكات يوفر 40 نوعاً متنوعاً لبناء صفحات مرنة. كل بلوك له محتوى JSON ديناميكي، وأنيميشن اختياري. الكمبوننتات تدعم Content Overrides — يمكن تعديلها من الباك إند بدون تغيير الكود. بلوك `blog_list` يجلب المقالات تلقائياً من API المدوّنة.
