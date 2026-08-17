# نماذج المدوّنة — الحالة الفعلية

> **حالة التنفيذ:** مكتمل ✅

---

## نموذج التصنيف (BlogCategory) ✅

```python
class BlogCategory(models.Model):
    name_en = models.CharField(max_length=200)
    name_ar = models.CharField(max_length=200)
    slug = models.SlugField(unique=True, allow_unicode=True)
    description = models.TextField(blank=True, default='')
    icon = models.CharField(max_length=50, blank=True, default='')
    order = models.IntegerField(default=0)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
```

---

## نموذج المقال (BlogPost) ✅

```python
class BlogPost(models.Model):
    title_en = models.CharField(max_length=300)
    title_ar = models.CharField(max_length=300)
    slug = models.SlugField(unique=True, allow_unicode=True, max_length=300)
    excerpt_en = models.TextField(max_length=1000, blank=True, default='')
    excerpt_ar = models.TextField(max_length=1000, blank=True, default='')
    content_en = models.TextField(blank=True, default='')  # HTML — يدعم RichTextEditor
    content_ar = models.TextField(blank=True, default='')  # HTML — يدعم RichTextEditor
    
    category = models.ForeignKey(BlogCategory, on_delete=models.SET_NULL, null=True, blank=True)
    tags = models.CharField(max_length=500, blank=True, default='')  # Comma-separated
    featured_image_url = models.URLField(max_length=500, blank=True, default='')
    
    author_name_en = models.CharField(max_length=200, default='Afaq Tech Team')
    author_name_ar = models.CharField(max_length=200, default='فريق آفاق تكنولوجي')
    author_avatar_url = models.URLField(max_length=500, blank=True, default='')
    
    read_time = models.IntegerField(default=3)  # دقائق
    views = models.IntegerField(default=0)
    is_published = models.BooleanField(default=False)
    is_featured = models.BooleanField(default=False)
    published_at = models.DateTimeField(null=True, blank=True)
    related_service = models.CharField(max_length=200, blank=True, default='')
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
```

---

## ملخص العلاقات

```
BlogCategory (1)
    └── BlogPost (N) — category FK
```

### ملاحظات
- **لا يوجد** نموذج BlogTag منفصل — الوسوم مخزنة كـ string مفصولة بفواصل
- **لا يوجد** نموذج BlogComment — التعليقات مُخطط لها مستقبلاً
- **لا يوجد** حقل `status` — يُستخدم `is_published` بدلاً منه
- **لا يوجد** حقل `translation_of` — المحتوى ثنائي اللغة في نفس السطر (title_en/title_ar, content_en/content_ar)
- **لا يوجد** حقل `language` — المحتوى عربي + إنجليزي في نفس الوقت
- **لا يوجد** SEO fields منفصلة — تُستخدم الحقول الأساسية
