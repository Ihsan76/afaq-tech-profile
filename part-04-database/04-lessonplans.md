# نماذج خطط الدروس — مُنفّذة ✅

## نموذج خطة الدرس — مُنفّذ ✅

```python
from django.db import models
from django.conf import settings

class LessonPlan(models.Model):
    """خطة الدرس المولّدة بالذكاء الاصطناعي"""
    
    class Status(models.TextChoices):
        DRAFT = 'draft', 'مسودة'
        PUBLISHED = 'published', 'منشور'
        ARCHIVED = 'archived', 'أرشيف'

    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='lesson_plans')
    title = models.CharField('العنوان', max_length=255)
    subject = models.ForeignKey('academics.Subject', on_delete=models.SET_NULL, null=True, related_name='lesson_plans')
    grade = models.ForeignKey('academics.Grade', on_delete=models.SET_NULL, null=True, related_name='lesson_plans')
    plan_data = models.JSONField('بيانات الخطة')
    generated_by = models.CharField('مولّد بواسطة', max_length=10, default='ai')
    ai_model_used = models.CharField('نموذج AI المستخدم', max_length=100, blank=True)
    status = models.CharField('الحالة', max_length=15, choices=Status.choices, default=Status.DRAFT)

    # Marketplace & Community
    is_public = models.BooleanField('مشاركة عامة (Marketplace)', default=False)
    likes_count = models.IntegerField('عدد الإعجابات', default=0)
    clones_count = models.IntegerField('عدد الاستنساخات', default=0)
    downloads_count = models.IntegerField('عدد التحميلات', default=0)
    original_plan = models.ForeignKey('self', on_delete=models.SET_NULL, null=True, blank=True, related_name='clones')

    created_at = models.DateTimeField('تاريخ الإنشاء', auto_now_add=True)
    updated_at = models.DateTimeField('تاريخ التحديث', auto_now=True)

    class Meta:
        verbose_name = 'خطة درس'
        verbose_name_plural = 'خطط الدروس'
        ordering = ['-created_at']

    def __str__(self):
        return self.title
```

### حقل plan_data — الهيكل الفعلي

```json
{
    "objectives": ["هدف تعليمي 1", "هدف تعليمي 2"],
    "materials_needed": ["سبورة", "أقلام"],
    "introduction": "نص المقدمة والتمهيد",
    "main_activity": [
        {"step": 1, "title": "عنوان الخطوة", "description": "الشرح", "duration_minutes": 15}
    ],
    "assessment": "وصف أسلوب التقييم",
    "homework": "وصف الواجب",
    "estimated_duration": 45,
    "teaching_methods": ["طريقة1", "طريقة2"],
    "tags": ["tag1"],
    "worksheet": {
        "title": "ورقة عمل",
        "instructions": "التعليمات",
        "exercises": [
            {"question": "سؤال", "options": ["أ", "ب", "ج", "د"], "answer": "أ"}
        ]
    },
    "homework_assignment": {
        "homework_title": "الواجب المنزلي",
        "instructions": "...",
        "tasks": [{"task_number": 1, "description": "..."}]
    }
}
```

---

## نموذج التعديل التفاعلي — مُنفّذ ✅ (جديد)

```python
class LessonPlanRefinement(models.Model):
    """تعديل خطة درس عبر محادثة AI"""

    lesson_plan = models.ForeignKey(LessonPlan, on_delete=models.CASCADE, related_name='refinements')
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    user_prompt = models.TextField('طلب التعديل')
    ai_response = models.TextField('رد الذكاء الاصطناعي')
    created_at = models.DateTimeField('تاريخ التعديل', auto_now_add=True)

    class Meta:
        verbose_name = 'تعديل تفاعلي للخطة'
        verbose_name_plural = 'تعديلات خطط الدروس التفاعلية'
        ordering = ['created_at']
```

---

## ما هو مُنفّذ ✅

- نموذج `LessonPlan` مع حقل `is_public` + `likes_count` + `clones_count` + `downloads_count`
- نموذج `LessonPlanRefinement` (تعديل عبر AI)
- توليد ورقة عمل (`worksheet` داخل `plan_data`)
- توليد واجب منزلي (`homework_assignment` داخل `plan_data`)
- سوق مجتمعي (مشاركة، إعجاب، استنساخ)
- جرّ النقاط والشارات عند إنشاء خطة
- صلاحيات: المالك أو المدير فقط (للحذف/التعديل/المشاركة)

## ما هو غير مُنفّذ ❌

- `LessonPlanAttachment` — مرفقات (PDF, images)
- `LessonPlanVersion` — نسخ احتياطية للخطة
- تصدير PDF/Word عبر API مخصص

---

## ملخص العلاقات

```
User (1) ──── (N) LessonPlan
                   │
                   ├── Subject (M:1)
                   ├── Grade (M:1)
                   │
                   ├── LessonPlanRefinement (1:N)
                   └── original_plan → LessonPlan (self)
```
