# نماذج الأكاديمية (المنهاج)

## نموذج اللغة المدعومة

> **ملاحظة**: اللغة المدعومة مُنفّذة فعلياً في `apps/core` باسم `Language` (مع `TranslationKey`) — انظر [12-languages.md](12-languages.md). ما يلي نموذج التصميم الأصلي (`SupportedLanguage`) للتوثيق.

```python
class SupportedLanguage(models.Model):
    """اللغات المدعومة في المنصة"""
    
    code = models.CharField(max_length=5, unique=True, help_text='ISO 639-1 code')
    name_native = models.CharField(max_length=50, help_text='الاسم باللغة الأصلية')
    name_en = models.CharField(max_length=50, help_text='الاسم بالإنجليزية')
    is_rtl = models.BooleanField(default=False)
    is_active = models.BooleanField(default=True)
    is_default = models.BooleanField(default=False)
    order = models.IntegerField(default=0)
    
    # معلومات إضافية
    flag_emoji = models.CharField(max_length=10, blank=True)
    date_format = models.CharField(max_length=20, default='YYYY-MM-DD')
    number_format = models.CharField(max_length=20, default='1,234.56')
    
    class Meta:
        verbose_name = 'لغة مدعومة'
        verbose_name_plural = 'اللغات المدعومة'
        ordering = ['order', 'name_en']
    
    def __str__(self):
        return f"{self.name_native} ({self.code})"
```

---

## نموذج المرحلة الدراسية

```python
class Grade(models.Model):
    """المرحلة الدراسية"""
    
    name_ar = models.CharField(max_length=100, verbose_name='الاسم بالعربية')
    name_en = models.CharField(max_length=100, verbose_name='الاسم بالإنجليزية')
    level = models.IntegerField(help_text='1=روضة، 2=ابتدائي، ...')
    order = models.IntegerField(default=0)
    is_active = models.BooleanField(default=True)
    
    class Meta:
        verbose_name = 'مرحلة دراسية'
        verbose_name_plural = 'المراحل الدراسية'
        ordering = ['order']
    
    def __str__(self):
        return self.name_ar
```

---

## نموذج المادة الدراسية

```python
class Subject(models.Model):
    """المادة الدراسية"""
    
    name_ar = models.CharField(max_length=100, verbose_name='الاسم بالعربية')
    name_en = models.CharField(max_length=100, verbose_name='الاسم بالإنجليزية')
    icon = models.CharField(max_length=50, blank=True)
    color = models.CharField(max_length=7, blank=True)
    is_active = models.BooleanField(default=True)
    
    class Meta:
        verbose_name = 'مادة دراسية'
        verbose_name_plural = 'المواد الدراسية'
    
    def __str__(self):
        return self.name_ar
```

---

## نموذج المنهاج الدراسي

```python
class Curriculum(models.Model):
    """المنهاج الدراسي"""
    
    name_ar = models.CharField(max_length=255, verbose_name='الاسم بالعربية')
    name_en = models.CharField(max_length=255, blank=True)
    country = models.CharField(max_length=100, default='سوريا')
    language = models.ForeignKey('SupportedLanguage', on_delete=models.SET_NULL, 
                                 null=True, blank=True, verbose_name='لغة المنهاج')
    year = models.IntegerField(verbose_name='السنة الدراسية')
    description = models.TextField(blank=True)
    is_active = models.BooleanField(default=True)
    
    class Meta:
        verbose_name = 'منهاج'
        verbose_name_plural = 'المناهج'
    
    def __str__(self):
        return f"{self.name_ar} - {self.year}"
```

---

## نموذج الوحدة الدراسية

```python
class Unit(models.Model):
    """الوحدة في المنهج"""
    
    curriculum = models.ForeignKey(Curriculum, on_delete=models.CASCADE, related_name='units')
    subject = models.ForeignKey(Subject, on_delete=models.CASCADE, related_name='units')
    grade = models.ForeignKey(Grade, on_delete=models.CASCADE, related_name='units')
    
    name_ar = models.CharField(max_length=255, verbose_name='اسم الوحدة')
    name_en = models.CharField(max_length=255, blank=True)
    order = models.IntegerField(default=0)
    
    class Meta:
        verbose_name = 'وحدة دراسية'
        verbose_name_plural = 'الوحدات الدراسية'
        ordering = ['order']
    
    def __str__(self):
        return self.name_ar
```

---

## نموذج الدرس

```python
class Lesson(models.Model):
    """الدرس الفرعي"""
    
    unit = models.ForeignKey(Unit, on_delete=models.CASCADE, related_name='lessons')
    
    name_ar = models.CharField(max_length=255, verbose_name='اسم الدرس')
    name_en = models.CharField(max_length=255, blank=True)
    order = models.IntegerField(default=0)
    
    # معلومات إضافية
    objectives = models.JSONField(default=list, blank=True)
    keywords = models.JSONField(default=list, blank=True)
    
    class Meta:
        verbose_name = 'درس'
        verbose_name_plural = 'الدروس'
        ordering = ['order']
    
    def __str__(self):
        return self.name_ar
```

---

---

## نموذج وثيقة المنهاج — مُنفّذ ✅ (جديد)

```python
class CurriculumDocument(models.Model):
    """ملف مرفوع لمنهاج دراسي"""

    curriculum = models.ForeignKey(Curriculum, on_delete=models.SET_NULL, null=True, blank=True)
    subject = models.ForeignKey(Subject, on_delete=models.SET_NULL, null=True, blank=True)
    title = models.CharField(max_length=255)
    file = models.FileField(upload_to='curricula/')
    extracted_text = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
```

> يُستخدم في `generate_lesson_plan`: يُستخرج النص من الملف ويُحقن في سياق الـ AI لتحسين جودة الخطة.

---

## ملخص العلاقات

```
Curriculum
    ├── Unit (1:N)
    │   ├── Subject (M:1)
    │   ├── Grade (M:1)
    │   └── Lesson (1:N)
    │       └── objectives, keywords
    └── ...

Subject ←→ User (ManyToMany via profile)
Grade ←→ User (ManyToMany via profile)

CurriculumDocument
    ├── Curriculum (M:1, optional)
    └── Subject (M:1, optional)
```
