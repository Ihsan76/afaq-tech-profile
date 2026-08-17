# نظام القوالب (Template System)

## نظرة عامة

نظام القوالب يوفر بلوكات افتراضية جاهزة يمكن تطبيقها على صفحات جديدة بسرعة.

> **حالة التنفيذ:** مكتمل ✅

---

## نموذج القالب (PageTemplate)

```python
class PageTemplate(models.Model):
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
    category = models.CharField(max_length=20, choices=Category.choices)
    default_blocks = models.JSONField(default=list, blank=True)
    default_layout = models.JSONField(default=dict, blank=True)
    is_active = models.BooleanField(default=True)
```

---

## فئات القوالب (5)

| الفئة | الوصف | الاستخدام |
|-------|-------|-----------|
| `landing` | صفحة هبوط | صفحات التسويق والتحويل |
| `business` | صفحة أعمال | صفحات الشركات والخدمات |
| `education` | صفحة تعليمية | صفحات المدارس والأكاديميات |
| `portfolio` | معرض أعمال | عرض المشاريع والتصميمات |
| `custom` | مخصص | قوالب مخصصة |

---

## الحقول الرئيسية

| الحقل | الوصف |
|-------|-------|
| `name_en/ar` | اسم القالب بالإنجليزية والعربية |
| `slug` | معرف فريد للقالب |
| `description_en/ar` | وصف القالب |
| `thumbnail` | صورة مصغرة للقالب |
| `category` | فئة القالب |
| `default_blocks` | JSON array — البلوكات الافتراضية للقالب |
| `default_layout` | JSON object — التخطيط الافتراضي |
| `is_active` | هل القالب متاح |

---

## مثال على default_blocks

```json
[
  {
    "block_type": "hero",
    "title_en": "Hero Section",
    "title_ar": "قسم البطل",
    "content": {
      "heading_en": "Welcome",
      "heading_ar": "مرحباً"
    },
    "order": 0
  },
  {
    "block_type": "features",
    "title_en": "Features",
    "title_ar": "الميزات",
    "content": {
      "items": [
        {"icon": "🚀", "title_en": "Fast", "title_ar": "سريع"},
        {"icon": "🔒", "title_en": "Secure", "title_ar": "آمن"}
      ]
    },
    "order": 1
  },
  {
    "block_type": "cta",
    "title_en": "Call to Action",
    "title_ar": "دعوة للعمل",
    "order": 2
  }
]
```

---

## تدفق تطبيق القالب

```
المدير يختار قالباً من لوحة الإدارة
    │
    ▼
النظام يجلب default_blocks من القالب
    │
    ▼
يُنشئ بلوكات جديدة في الصفحة المرتبطة
    │
    ▼
يمكن للمدير تعديل البلوكات بحرية بعد التطبيق
```

---

## API Endpoints

### عام (Public)

#### GET `/api/v1/pages/templates/list/`
جلب جميع القوالب النشطة.

```json
[
  {
    "id": 1,
    "name_en": "Landing Page",
    "name_ar": "صفحة هبوط",
    "slug": "landing",
    "category": "landing",
    "description_en": "Modern landing page template",
    "description_ar": "قالب صفحة هبوط عصري",
    "default_blocks": [...]
  }
]
```

### إدارة (Admin)

| Method | Endpoint | الوصف |
|--------|----------|-------|
| GET | `/api/v1/pages/admin/templates/` | جميع القوالب |
| POST | `/api/v1/pages/admin/templates/create/` | إنشاء قالب |
| PUT | `/api/v1/pages/admin/templates/<pk>/` | تعديل قالب |
| DELETE | `/api/v1/pages/admin/templates/<pk>/delete/` | حذف قالب |

---

## ملخص

> نظام القوالب يوفر بلوكات افتراضية جاهزة في 5 فئات. يمكن تطبيق قالب على صفحة جديدة ثم تعديل البلوكات بحرية. كل قالب يحتوي default_blocks كـ JSON array.
