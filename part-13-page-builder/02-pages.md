# نظام الصفحات (Page System)

## نظرة عامة

نموذج الصفحة (Page) هو الوحدة الأساسية في نظام إدارة المحتوى. كل صفحة في الموقع تمثل سجلاً في قاعدة البيانات يمكن تعديله من لوحة الإدارة.

> **حالة التنفيذ:** مكتمل ✅

---

## نموذج الصفحة (Page)

```python
class Page(models.Model):
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
```

---

## الحقول الرئيسية

| الحقل | النوع | الوصف |
|-------|-------|-------|
| `slug` | SlugField (unique) | المعرف الفريد للصفحة في الرابط |
| `title_en` | CharField | العنوان بالإنجليزية |
| `title_ar` | CharField | العنوان بالعربية |
| `description_en` | TextField | الوصف بالإنجليزية |
| `description_ar` | TextField | الوصف بالعربية |
| `template` | CharField | قالب الصفحة (default, landing, about, contact, custom) |
| `meta_title_en/ar` | CharField | عنوان SEO |
| `meta_description_en/ar` | TextField | وصف SEO |
| `show_in_nav` | BooleanField | هل تظهر بالقائمة |
| `nav_order` | IntegerField | ترتيب الظهور بالقائمة |
| `parent_page` | FK self | الصفحة الأب (للقوائم الفرعية) |
| `nav_icon` | CharField | أيقونة القائمة |
| `layout_config` | JSONField | إعدادات التخطيط |
| `is_published` | BooleanField | هل الصفحة منشورة |
| `is_homepage` | BooleanField | هل هي الصفحة الرئيسية (واحدة فقط) |
| `theme_overrides` | JSONField | تخصيص الثيم لهذه الصفحة |

---

## API Endpoints

### عام (Public)

#### GET `/api/v1/pages/<slug>/`
جلب صفحة حسب slug مع جميع بلوكاتها النشطة.

```json
{
  "id": 1,
  "slug": "homepage",
  "title_en": "Afaq Tech Platform",
  "title_ar": "منصة آفاق تكنولوجي",
  "blocks": [...]
}
```

### إدارة (Admin)

| Method | Endpoint | الوصف |
|--------|----------|-------|
| GET | `/api/v1/pages/admin/pages/` | قائمة جميع الصفحات |
| POST | `/api/v1/pages/admin/pages/create/` | إنشاء صفحة جديدة |
| GET | `/api/v1/pages/admin/pages/<pk>/` | تفاصيل صفحة |
| PUT | `/api/v1/pages/admin/pages/<pk>/` | تحديث صفحة |
| DELETE | `/api/v1/pages/admin/pages/<pk>/delete/` | حذف صفحة |

---

## الصفحات المُهيأة (Seeded) — 14 صفحة + 62 بلوك

| الصفحة | Slug | البلوكات | is_homepage |
|--------|------|----------|-------------|
| منصة آفاق تكنولوجي | `homepage` | 9 بلوكات | ✅ |
| أكاديمية آفاق | `academy` | 9 بلوكات | ❌ |
| المنهاج الدراسي | `curriculum` | 4 بلوكات | ❌ |
| من نحن | `about` | 3 بلوكات | ❌ |
| تواصل معنا | `contact` | 2 بلوكات | ❌ |
| سياسة الخصوصية | `privacy-policy` | 1 بلوك | ❌ |
| شروط الاستخدام | `terms-of-service` | 1 بلوك | ❌ |
| تصميم المواقع | `services/web-design` | 4 بلوكات | ❌ |
| إدارة التواصل الاجتماعي | `services/social-media` | 4 بلوكات | ❌ |
| صفحات الهبوط | `services/landing-pages` | 4 بلوكات | ❌ |
| النماذج الإلكترونية | `services/electronic-forms` | 4 بلوكات | ❌ |
| الكتب الإلكترونية | `services/ebooks` | 4 بلوكات | ❌ |
| الهوية البصرية والاستشارات | `services/brand-identity` | 4 بلوكات | ❌ |

> **ملاحظة**: صفحات الخدمات تستخدم `services_showcase` block مع محتوى مخصص لكل خدمة.

---

## معمارية العرض الديناميكي

```
المستخدم يزور /en/homepage
    │
    ▼
page.tsx → <DynamicPage slug="homepage" />
    │
    ├── API: GET /api/v1/pages/homepage/
    │   → { slug, title, blocks: [
    │       { block_type: "platform_hero", content: {...} },
    │       { block_type: "platform_stats", content: {...} },
    │       ...
    │     ]}
    │
    └── <BlockRenderer blocks={blocks} />
         ├── platform_hero → <PlatformHero content={...} />
         ├── platform_stats → <PlatformStats content={...} />
         └── ...

Fallback: إذا فشل الاتصال → fallbackBlocks ثابتة في الكود
```

---

## ملخص

> الصفحة هي الوحدة الأساسية في نظام CMS. كل لها slug فريد، بلوكات مرتبطة، إعدادات SEO، وخيارات ظهور بالقوائم. العرض يتم عبر DynamicPage → BlockRenderer بشكل ديناميكي.
