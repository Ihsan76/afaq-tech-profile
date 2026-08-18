# خطة هندسة لوحة تحكم المديرية (Directorate Dashboard)

> تاريخ التوثيق: 18 أغسطس 2026
> الغرض: توثيق التصميم الهندسي والمعماري للوحة تحكم متابعة عدة مدارس دفعة واحدة (Directorate Dashboard).

---

## 1. الفكرة والهدف
توفير لوحة تحكم شاملة لمديرية تعليمية (تعليم المنطقة/المديرية) لمتابعة:
- **عدة مدارس** (5-50 مدرسة) دفعة واحدة
- **KPIs مركبة** (إجمالي الطلاب، المعلمين، معدل الحضور، نسب النجاح)
- **مقارنة أداء المدارس** (ترتيب، مقارنة، تحليلات)
- **تنبيهات ذكية** (المدارس المتأخرة، المشاكل المستجدة)

---

## 2. نموذج البيانات

### أ. نموذج المديرية (`apps/schools/models.py`)
```python
class Directorate(models.Model):
    """مديرية تعليمية تدير عدة مدارس"""
    name = models.CharField(max_length=200)
    name_ar = models.CharField(max_length=200)
    name_en = models.CharField(max_length=200)
    region = models.CharField(max_length=100)
    director = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, related_name='directed_directorates')
    schools = models.ManyToManyField(School, related_name='directorates')
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name_plural = 'directorates'
```

### ب. نموذج الإحصائيات المركبة
```python
class DirectorateStats(models.Model):
    """إحصائيات يومية مركبة للمديرية"""
    directorate = models.ForeignKey(Directorate, on_delete=models.CASCADE, related_name='stats')
    date = models.DateField()
    total_schools = models.IntegerField(default=0)
    active_schools = models.IntegerField(default=0)  # مدارس بها نشاط اليوم
    total_students = models.IntegerField(default=0)
    total_teachers = models.IntegerField(default=0)
    attendance_rate = models.FloatField(default=0)  # معدل الحضور الإجمالي
    average_grades = models.FloatField(default=0)   # متوسط الدرجات الإجمالي
    assignments_pending = models.IntegerField(default=0)
    incidents_count = models.IntegerField(default=0)

    class Meta:
        unique_together = [['directorate', 'date']]
        ordering = ['-date']
```

---

## 3. نقطة النهاية (API Endpoints)

```
GET  /api/v1/schools/directorates/                    # قائمة المديريات
GET  /api/v1/schools/directorates/<id>/dashboard/      # لوحة تحكم المديرية
GET  /api/v1/schools/directorates/<id>/stats/          # إحصائيات مركبة
GET  /api/v1/schools/directorates/<id>/schools/        # قائمة المدارس مع KPIs
GET  /api/v1/schools/directorates/<id>/comparison/     # مقارنة أداء المدارس
GET  /api/v1/schools/directorates/<id>/alerts/         # تنبيهات المديرية
```

### استجابة Dashboard:
```json
{
    "directorate": "مديرية تعليم الرياض",
    "summary": {
        "total_schools": 45,
        "active_schools": 42,
        "total_students": 12500,
        "total_teachers": 850,
        "attendance_rate": 94.2,
        "average_grades": 78.5
    },
    "schools": [
        {
            "id": 1,
            "name": "مدرسة الأمل",
            "students": 350,
            "teachers": 25,
            "attendance_rate": 96.1,
            "average_grades": 82.3,
            "status": "excellent"
        }
    ],
    "alerts": [
        {
            "type": "warning",
            "school": "مدرسة النور",
            "message": "معدل الحضور انخفض 5% هذا الأسبوع"
        }
    ]
}
```

---

## 4. الواجهة الأمامية (Frontend)

### الصفحة الرئيسية: `/directorate/dashboard`
```
┌─────────────────────────────────────────────────────┐
│  Directorate Dashboard - مديرية تعليم الرياض        │
├─────────────────────────────────────────────────────┤
│  [إجمالي المدارس] [إجمالي الطلاب] [الحضور] [المتوسط]  │
│     45 مدرسة      12,500 طالب   94.2%   78.5%       │
├─────────────────────────────────────────────────────┤
│  [خريطة المدارس]  [رسم بياني: الحضور]  [تنبيهات]   │
│                                                     │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐      │
│  │مدرسة │ │مدرسة │ │مدرسة │ │مدرسة │ │مدرسة │      │
│  │الأمل │ │النور │ │السلام│ │ال钔ى │ │الفجر │      │
│  │ 96%  │ │ 89%  │ │ 92%  │ │ 95%  │ │ 91%  │      │
│  └──────┘ └──────┘ └──────┘ └──────┘ └──────┘      │
├─────────────────────────────────────────────────────┤
│  [جدول المدارس] — ترتيب حسب الأداء                   │
│  1. مدرسة الأمل    96.1%  82.3  excellent           │
│  2. مدرسة المدى    95.0%  81.1  excellent           │
│  3. مدرسة السلام   92.0%  79.4  good                │
│  4. مدرسة الفجر    91.0%  78.2  good                │
│  5. مدرسة النور    89.0%  75.8  needs_attention     │
└─────────────────────────────────────────────────────┘
```

---

## 5. الصلاحيات (RBAC)
| الدور | الصلاحيات |
|-------|----------|
| `directorate_admin` | رؤية كل مدارس المديرية + تقارير مقارنة |
| `admin` | إنشاء/تعديل المديريات + تعيين المديرين |
| `school_admin` | رؤية مدرسته فقط (لا يصل للوحة المديرية) |

---

## 6. التكامل مع النظام الحالي
- **الحضور**: جلب `Attendance` من كل المدارس المرتبطة بالمديرية
- **الدرجات**: جلب `GradeEntry` من كل المدارس
- **الواجبات**: جلب `AssignmentSubmission` من كل المدارس
- **تنبيهات WhatsApp**: جلب `WhatsAppNotificationLog` من كل المدارس
- **التقارير الأسبوعية**: جلب `WeeklyReport` من كل المدارس
