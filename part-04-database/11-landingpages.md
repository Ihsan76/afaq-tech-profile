# نماذج صفحات الموقع (Pages App)

> **ملاحظة مهمة:** نموذج `Page`/`PageBlock` في تطبيق `pages` هو النموذج الفعلي المُنفّذ. نموذج `LandingPage`/`LandingBlock` القديم أُلغي واستُبدل بالنموذج الموحد.

---

## نموذج الصفحة (Page) — مُنفّذ ✅

```python
class Page(models.Model):
    """صفحة في الموقع — يمكن أن تكون رئيسية أو مخصصة"""

    class Template(models.TextChoices):
        DEFAULT = 'default', 'افتراضي'
        LANDING = 'landing', 'صفحة هبوط'
        ABOUT = 'about', 'من نحن'
        CONTACT = 'contact', 'تواصل معنا'
        CUSTOM = 'custom', 'مخصص'

    slug = models.SlugField(unique=True, max_length=100)
    title_en = models.CharField(max_length=200)
    title_ar = models.CharField(max_length=200)
    description_en = models.TextField(blank=True, default='')
    description_ar = models.TextField(blank=True, default='')
    template = models.CharField(max_length=20, choices=Template.choices, default=Template.DEFAULT)

    # SEO
    meta_title_en = models.CharField(max_length=200, blank=True, default='')
    meta_title_ar = models.CharField(max_length=200, blank=True, default='')
    meta_description_en = models.TextField(blank=True, default='')
    meta_description_ar = models.TextField(blank=True, default='')

    # Navigation
    show_in_nav = models.BooleanField(default=False)
    nav_order = models.IntegerField(default=0)
    parent_page = models.ForeignKey('self', null=True, blank=True, related_name='children')
    nav_icon = models.CharField(max_length=10, blank=True, default='')

    # Settings
    layout_config = models.JSONField(default=dict, blank=True)
    is_published = models.BooleanField(default=True)
    is_homepage = models.BooleanField(default=False)
    theme_overrides = models.JSONField(default=dict, blank=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['nav_order', 'slug']

    def __str__(self):
        return f"{self.title_ar} ({self.slug})"
```

---

## نموذج البلوك (PageBlock) — مُنفّذ ✅

```python
class PageBlock(models.Model):
    """بلوك داخل صفحة"""

    class BlockType(models.TextChoices):
        # بلوكات المنصة
        PLATFORM_HERO = 'platform_hero', 'بطل الصفحة (المنصة)'
        PLATFORM_STATS = 'platform_stats', 'إحصائيات (المنصة)'
        PLATFORM_HOW_IT_WORKS = 'platform_how_it_works', 'كيف تعمل (المنصة)'
        SERVICES_SHOWCASE = 'services_showcase', 'عرض الخدمات'

        # بلوكات عامة
        HERO = 'hero', 'بطل الصفحة'
        STATS = 'stats', 'إحصائيات'
        FEATURES = 'features', 'الميزات'
        HOW_IT_WORKS = 'how_it_works', 'كيف يعمل'
        DEMO = 'demo', 'عرض توضيحي'
        TESTIMONIALS = 'testimonials', 'شهادات'
        PRICING = 'pricing', 'التسعير'
        FAQ = 'faq', 'أسئلة شائعة'
        CTA = 'cta', 'دعوة للعمل'

        # بلوكات المحتوى
        TEXT = 'text', 'نص'
        IMAGE = 'image', 'صورة'
        VIDEO = 'video', 'فيديو'
        GALLERY = 'gallery', 'معرض صور'
        CONTACT = 'contact', 'تواصل معنا'
        FORM = 'form', 'نموذج'
        CUSTOM_HTML = 'custom_html', 'HTML مخصص'

        # بلوكات التخطيط
        SPACER = 'spacer', 'مسافة'
        DIVIDER = 'divider', 'فاصل'

        # بلوكات إضافية
        SERVICES = 'services', 'خدمات'
        PORTFOLIO = 'portfolio', 'معرض أعمال'
        TEAM = 'team', 'الفريق'
        PARTNERS = 'partners', 'الشركاء'

        # بلوكات التعليم
        GRADE_SHOWCASE = 'grade_showcase', 'عرض الصفوف'
        SUBJECTS_GRID = 'subjects_grid', 'شبكة المواد'

        # بلوكات جديدة (11)
        ACCORDION = 'accordion', 'أقسام قابلة للطي'
        TABS = 'tabs', 'تبويبات'
        TIMELINE = 'timeline', 'خط زمني'
        COUNTDOWN = 'countdown', 'عداد تنازلي'
        NEWSLETTER = 'newsletter', 'اشتراك بريد'
        MAP = 'map', 'خريطة'
        TABLE = 'table', 'جدول بيانات'
        ICON_LIST = 'icon_list', 'قائمة أيقونات'
        LOGO_CAROUSEL = 'logo_carousel', 'كاروسيل شعارات'
        DOWNLOAD = 'download', 'تحميل ملف'
        CODE = 'code', 'بلوك كود'

    # المجموع: 39 نوع بلوك

    page = models.ForeignKey(Page, on_delete=models.CASCADE, related_name='blocks')
    block_type = models.CharField(max_length=30, choices=BlockType.choices)

    title_en = models.CharField(max_length=200, blank=True, default='')
    title_ar = models.CharField(max_length=200, blank=True, default='')
    subtitle_en = models.CharField(max_length=500, blank=True, default='')
    subtitle_ar = models.CharField(max_length=500, blank=True, default='')

    content = models.JSONField(default=dict, blank=True)
    styles = models.JSONField(default=dict, blank=True)
    layout = models.JSONField(default=dict, blank=True)
    animation = models.JSONField(default=dict, blank=True)

    is_active = models.BooleanField(default=True)
    order = models.IntegerField(default=0)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['page', 'order']

    def __str__(self):
        return f"{self.page.title_ar} — {self.get_block_type_display()}"
```

---

## نموذج عنصر القائمة (MenuItem) — مُنفّذ ✅

```python
class MenuItem(models.Model):
    """عنصر في قائمة التنقل"""

    class MenuPosition(models.TextChoices):
        HEADER = 'header', 'القائمة العلوية'
        FOOTER = 'footer', 'تذييل الصفحة'
        SIDEBAR = 'sidebar', 'الشريط الجانبي'

    menu = models.CharField(max_length=20, choices=MenuPosition.choices, default=MenuPosition.HEADER)

    class ServiceContext(models.TextChoices):
        ACADEMY = 'academy', 'الأكاديمية'
        SCHOOL = 'school', 'آفاق مدرستي'
        CURRICULUM = 'curriculum', 'المناهج'
        LESSON_PLANS = 'lesson-plans', 'خطط الدروس'
        EBOOKS = 'ebooks', 'الكتب الإلكترونية'
        DASHBOARD = 'dashboard', 'ساحة العمل'
        PROFILE = 'profile', 'الملف الشخصي'
        GAMIFICATION = 'gamification', 'التلعيب'
        SUBSCRIPTIONS = 'subscriptions', 'الاشتراكات'
        ADMIN = 'admin', 'لوحة الإدارة'

    class RequiredRole(models.TextChoices):
        USER = 'user', 'مستخدم عام'
        INSTRUCTOR = 'instructor', 'مدرب'
        ADMIN = 'admin', 'مدير'
        SUPPORT = 'support', 'دعم'
        FINANCE = 'finance', 'مالية'
        DEVELOPER = 'developer', 'مطور'

    # اختيار متعدد (Multi-select) — فارغة = الكل/للجميع، مهاجرة 0015 حوّلت البيانات
    service_context = ArrayField(models.CharField(...), default=list, blank=True)
    required_role = ArrayField(models.CharField(...), default=list, blank=True)

    translations = models.JSONField(default=dict, blank=True)
    url = models.CharField(max_length=500, blank=True, default='')
    page = models.ForeignKey(Page, on_delete=models.SET_NULL, null=True, blank=True, related_name='menu_items')
    icon = models.CharField(max_length=10, blank=True, default='')
    parent = models.ForeignKey('self', null=True, blank=True, related_name='children')
    order = models.IntegerField(default=0)
    is_active = models.BooleanField(default=True)
    open_in_new = models.BooleanField(default=False)
    css_class = models.CharField(max_length=200, blank=True, default='')
    badge = models.CharField(max_length=50, blank=True, default='')

    class Meta:
        ordering = ['menu', 'order']

    @property
    def resolved_url(self):
        if self.page:
            return f"/{self.page.slug}"
        return self.url or '#'
```

---

## نموذج القالب (PageTemplate) — مُنفّذ ✅

```python
class PageTemplate(models.Model):
    """قالب صفحة جاهز"""

    class Category(models.TextChoices):
        LANDING = 'landing', 'صفحة هبوط'
        BUSINESS = 'business', 'صفحة أعمال'
        EDUCATION = 'education', 'صفحة تعليمية'
        PORTFOLIO = 'portfolio', 'معرض أعمال'
        CUSTOM = 'custom', 'مخصص'

    name_en = models.CharField(max_length=100)
    name_ar = models.CharField(max_length=100)
    slug = models.SlugField(unique=True, max_length=100)
    description_en = models.TextField(blank=True, default='')
    description_ar = models.TextField(blank=True, default='')
    thumbnail = models.URLField(blank=True, default='')
    category = models.CharField(max_length=20, choices=Category.choices, default=Category.CUSTOM)
    default_blocks = models.JSONField(default=list, blank=True)
    default_layout = models.JSONField(default=dict, blank=True)
    is_active = models.BooleanField(default=True)

    class Meta:
        ordering = ['category', 'name_ar']
```

---

## نموذج إعدادات الموقع (SiteSettings) — مُنفّذ ✅

```python
class SiteSettings(models.Model):
    """إعدادات الموقع العامة — Singleton"""

    site_name_en = models.CharField(max_length=200, default='Afaq Tech')
    site_name_ar = models.CharField(max_length=200, default='آفاق تكنولوجي')
    site_description_en = models.TextField(blank=True, default='')
    site_description_ar = models.TextField(blank=True, default='')
    logo_url = models.URLField(blank=True, default='')
    favicon_url = models.URLField(blank=True, default='')
    email = models.EmailField(blank=True, default='')
    phone = models.CharField(max_length=50, blank=True, default='')
    whatsapp = models.CharField(max_length=50, blank=True, default='')
    facebook_url = models.URLField(blank=True, default='')
    twitter_url = models.URLField(blank=True, default='')
    instagram_url = models.URLField(blank=True, default='')
    linkedin_url = models.URLField(blank=True, default='')
    youtube_url = models.URLField(blank=True, default='')
    footer_text_en = models.TextField(blank=True, default='')
    footer_text_ar = models.TextField(blank=True, default='')
    copyright_text = models.CharField(max_length=200, blank=True, default='')
    custom_settings = models.JSONField(default=dict, blank=True)
    is_active = models.BooleanField(default=True, primary_key=True)

    class Meta:
        verbose_name = 'إعدادات الموقع'

    def save(self, *args, **kwargs):
        self.pk = 1
        super().save(*args, **kwargs)

    @classmethod
    def load(cls):
        obj, _ = cls.objects.get_or_create(pk=1)
        return obj
```

---

## ملخص العلاقات

```
Page (صفحة)
    ├── PageBlock (1:N) — بلوكات الصفحة
    │   ├── block_type — نوع البلوك (39 نوع)
    │   ├── content (JSON) — المحتوى الديناميكي
    │   ├── styles (JSON) — الأنماط المخصصة
    │   ├── layout (JSON) — التخطيط
    │   └── animation (JSON) — الأنيميشن
    ├── MenuItem (1:N) — عناصر القائمة المرتبطة
    ├── children (self-N:N) — الصفحات الفرعية
    └── theme_overrides (JSON) — تخصيص الثيم

PageTemplate (قالب)
    ├── default_blocks (JSON) — البلوكات الافتراضية
    └── default_layout (JSON) — التخطيط الافتراضي

SiteSettings (إعدادات — Singleton)
    └── custom_settings (JSON) — إعدادات مخصصة
```

---

## النسخة القديمة (مُلغي ❌)

> النماذج التالية **لم تُنفّذ** واستُبدلت بالنموذج الموحد في تطبيق `pages`:

- `LandingPage` → استُبدل بـ `Page` مع `template='landing'`
- `LandingBlock` → استُبدل بـ `PageBlock`
- `LandingForm` → لم تُنفّذ بعد (مخطط)
- `FormSubmission` → لم تُنفّذ بعد (مخطط)
