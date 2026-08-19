# نظام التفرعات الأكاديمية (Academic Tracks) — المحدث

> **تاريخ الإنشاء**: 20 أغسطس 2026
> **الحالة**: مكتمل ✅

---

## المشكلة

المرحلة الثانوية (الصف 11-12) في مختلف الدول لها تخصصات/شعب دراسية تختلف المواد والمناهج بينها. والنظام التقليدي (صف مسطّح بدون تخصصات) لا يدعم اختلاف التسميات، الأنظمة، أو تعديلها من سنة لأخرى.

**مثال: الأردن / السعودية (الإصلاحات الحديثة)**
- العلوم والتكنولوجيا والهندسة (Scientific, Technology & Engineering)
- العلوم الإنسانية والاجتماعية (Humanities & Social Sciences)
- الأعمال (Business)
- الصحي (Health)

---

## الحل المعماري المحدث

### 1. نموذج `AcademicTrack` (محدّث ليدعم الدولة والسنة)
```python
apps/academics/models.py

class AcademicTrack(models.Model):
    grade = models.ForeignKey(Grade, on_delete=models.CASCADE, related_name='tracks', verbose_name='الصف')
    country = models.CharField('الدولة', max_length=100, db_index=True, default='السعودية')
    year = models.IntegerField('السنة', db_index=True, default=2026)
    translations = models.JSONField('الترجمات', default=dict, blank=True)
    code = models.CharField('الرمز', max_length=50, help_text='رمز فريد للحقل مثل scientific_engineering')
    is_active = models.BooleanField('نشط', default=True)
    order = models.IntegerField('الترتيب', default=0)

    class Meta:
        verbose_name = 'تخصص أكاديمي'
        verbose_name_plural = 'التخصصات الأكاديمية'
        unique_together = [['country', 'year', 'grade', 'code']]
        indexes = [
            models.Index(fields=['country', 'year']),
        ]
        ordering = ['country', 'year', 'grade', 'order', 'id']
```

### 2. التعديلات على النماذج المرتبطة
| النموذج | الحقل الجديد | التفاصيل |
|---------|-------------|----------|
| `Grade` | `has_tracks = BooleanField(default=False)` | يحدد إذا كان الصف يدعم التخصصات |
| `Section` | `track = FK → AcademicTrack (nullable)` | الشعبة تابعة للتخصص |
| `Curriculum` | `track = FK → AcademicTrack (nullable)` | المنهج خاص بالتخصص |
| `SchoolSubjectPeriod` | `track = FK → AcademicTrack (nullable)` | المواد تختلف حسب التخصص |

---

## واجهة الإدارة (Admin UI)
- المسار: `/admin/grades/tracks`
- الميزات:
  - إدارة التخصصات لكل صف ودولة وسنة.
  - تفعيل/تعطيل التخصصات (`has_tracks`).
  - نموذج متعدد اللغات (9 لغات)، الكود، والترتيب.

---

## بيانات البدء (Seeding)
- `seed_academics.py`: يزرع التخصصات الأربعة الأساسية لصفوف المرحلة الثانوية (11-12) محددة بالدولة (`country`) والسنة (`year`).
- `seed_curricula.py`: يربط المناهج بالمسارات التخصصية (مثل مسار العلوم والهندسة، الأدبي، التجاري، الصحي).
- `seed_school_data.py`: ينشئ أقساماً (Sections) لكل تخصص في المرحلة الثانوية.

---

## المراحل التنفيذية — المنجزة بالكامل ✅

| # | المحتوى | الحالة |
|---|---------|--------|
| 1 | توثيق الخطة | ✅ |
| 2 | إنشاء AcademicTrack model + migration 0010/0011 + seed data | ✅ |
| 3 | إضافة has_tracks إلى Grade + track FK | ✅ |
| 4 | تحديث serializers و views (مع دعم تصفية country و year) | ✅ |
| 5 | تحديث seed_school_data.py و seed_curricula.py | ✅ |
| 6 | واجهة إدارة التخصصات (`/admin/grades/tracks`) | ✅ |
| 7 | اختبارات الـ Backend و Frontend (TypeScript / Pytest 90 passed) | ✅ |
