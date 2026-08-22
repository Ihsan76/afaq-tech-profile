# خطة هندسة تكامل Google Classroom

> تاريخ التوثيق: 18 أغسطس 2026
> آخر تحديث: 22 أغسطس 2026
> الحالة: ✅ المدير مكتمل — 📋 المعلم والطالب قيد التخطيط
> **للشرح التفصيلي والاستخدام**: راجع [05-google-classroom-guide.md](./05-google-classroom-guide.md)

---

## 1. الفكرة والهدف
تكامل مع Google Classroom لتوفير:
- **استيراد الطلاب والمعلمين** من Google Classroom إلى المنصة.
- **تصدير الدرجات** من المنصة إلى Google Classroom.
- **مزامنة الواجبات** بين المنصة و Google Classroom.
- **نشر المحتوى التعليمي** من المنصة إلى Google Classroom.

---

## 2. المكونات التقنية

### أ. OAuth 2.0 للمصادقة
```python
# backend/apps/schools/services/google_classroom.py
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build

SCOPES = [
    'https://www.googleapis.com/auth/classroom.courses.readonly',
    'https://www.googleapis.com/auth/classroom.coursework.students',
    'https://www.googleapis.com/auth/classroom.rosters.readonly',
    'https://www.googleapis.com/auth/classroom.student-submissions.students.readonly',
]

class GoogleClassroomService:
    def __init__(self, user):
        self.user = user
        self.credentials = self._get_credentials()
        self.service = build('classroom', 'v1', credentials=self.credentials)

    def _get_credentials(self):
        """جلب بيانات اعتماد المستخدم من قاعدة البيانات"""
        token = GoogleClassroomToken.objects.get(user=self.user)
        return Credentials(
            token=token.access_token,
            refresh_token=token.refresh_token,
            token_uri='https://oauth2.googleapis.com/token',
            client_id=settings.GOOGLE_CLASSROOM_CLIENT_ID,
            client_secret=settings.GOOGLE_CLASSROOM_CLIENT_SECRET,
        )

    def list_courses(self):
        """قائمة الدورات في Google Classroom"""
        results = self.service.courses().list().execute()
        return results.get('courses', [])

    def list_students(self, course_id):
        """قائمة الطلاب في دورة محددة"""
        results = self.service.courses().students().list(courseId=course_id).execute()
        return results.get('students', [])

    def create_coursework(self, course_id, title, description, due_date):
        """إنشاء واجب في Google Classroom"""
        coursework = {
            'title': title,
            'description': description,
            'dueDate': due_date,
            'workType': 'ASSIGNMENT',
        }
        return self.service.courses().courseWork().create(
            courseId=course_id, body=coursework
        ).execute()

    def export_grades(self, course_id, coursework_id, grades):
        """تصدير الدرجات إلى Google Classroom"""
        for student_id, grade in grades.items():
            self.service.courses().courseWork().studentSubmissions().patch(
                courseId=course_id,
                courseWorkId=coursework_id,
                id=student_id,
                updateMask='draftGrade',
                body={'draftGrade': grade}
            ).execute()
```

### ب. نموذج التخزين (`apps/schools/models.py`)
```python
class GoogleClassroomToken(models.Model):
    """تخزين بيانات اعتماد Google Classroom لكل مستخدم"""
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='google_classroom_token')
    access_token = models.TextField()
    refresh_token = models.TextField()
    token_expiry = models.DateTimeField()
    classroom_id = models.CharField(max_length=100, blank=True)  # معرف الدورة في Google Classroom
    synced_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

class GoogleClassroomSyncLog(models.Model):
    """سجل المزامنة مع Google Classroom"""
    SYNC_TYPES = [
        ('import_students', 'استيراد الطلاب'),
        ('import_teachers', 'استيراد المعلمين'),
        ('export_grades', 'تصدير الدرجات'),
        ('sync_assignments', 'مزامنة الواجبات'),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='classroom_sync_logs')
    sync_type = models.CharField(max_length=30, choices=SYNC_TYPES)
    course_id = models.CharField(max_length=100)
    status = models.CharField(max_length=20, choices=[
        ('success', 'نجاح'),
        ('partial', 'جزئي'),
        ('failed', 'فشل'),
    ])
    details = models.JSONField(default=dict)
    synced_at = models.DateTimeField(auto_now_add=True)
```

---

## 3. نقاط النهاية (API Endpoints)

```
GET  /api/v1/schools/google-classroom/courses/          # قائمة الدورات
POST /api/v1/schools/google-classroom/import/students/   # استيراد الطلاب
POST /api/v1/schools/google-classroom/import/teachers/   # استيراد المعلمين
POST /api/v1/schools/google-classroom/export/grades/     # تصدير الدرجات
POST /api/v1/schools/google-classroom/sync/assignments/  # مزامنة الواجبات
GET  /api/v1/schools/google-classroom/sync/status/       # حالة المزامنة
GET  /api/v1/schools/google-classroom/sync/logs/         # سجلات المزامنة
```

### استجابة قائمة الدورات:
```json
{
    "courses": [
        {
            "id": "123456789",
            "name": "فيزياء 101",
            "section": "A",
            "description": "مقدمة في الفيزياء",
            "enrollmentCount": 35,
            "courseState": "ACTIVE"
        }
    ],
    "synced": true,
    "lastSync": "2026-08-18T10:30:00Z"
}
```

---

## 4. واجهة المستخدم (Frontend)

### صفحة التكامل: `/school/admin/integrations`
```
┌─────────────────────────────────────────────────────┐
│  تكامل Google Classroom                             │
├─────────────────────────────────────────────────────┤
│  الحالة: ✅ متصل بحساب Google                       │
│  آخر مزامنة: 18/08/2026 10:30 ص                     │
├─────────────────────────────────────────────────────┤
│  الدورات المتاحة:                                   │
│  ┌─────────────────────────────────────────────────┐│
│  │ ☑ فيزياء 101 (35 طالب)     [استيراد] [تصدير]  ││
│  │ ☐ رياضيات 201 (28 طالب)    [استيراد] [تصدير]  ││
│  │ ☑ كيمياء 101 (32 طالب)     [استيراد] [تصدير]  ││
│  └─────────────────────────────────────────────────┘│
│                                                     │
│  [استيراد المحدد]  [تصدير الدرجات]  [مزامنة الواجبات]│
├─────────────────────────────────────────────────────┤
│  سجل المزامنة:                                      │
│  • 18/08 10:30 — استيراد 35 طالب (فيزياء 101) ✅    │
│  • 18/08 10:25 — تصدير 30 درجة (كيمياء 101) ✅     │
│  • 17/08 14:00 — مزامنة 5 واجبات (فيزياء 101) ✅   │
└─────────────────────────────────────────────────────┘
```

---

## 5. التكامل مع النظام الحالي

### أ. استيراد الطلاب
1. المستخدم يختار دورة من Google Classroom
2. النظام يستعلم عن قائمة الطلاب عبر API
3. يُنشئ/يربط حسابات المستخدمين في المنصة
4. يُسجّل السجل في `GoogleClassroomSyncLog`

### ب. تصدير الدرجات
1. المستخدم يختار دورة + واجب من المنصة
2. النظام يجلب الدرجات من `GradeEntry`
3. يُرسل الدرجات إلى Google Classroom عبر API
4. يُسجّل السجل في `GoogleClassroomSyncLog`

### ج. مزامنة الواجبات
1. المستخدم يختار واجباً من المنصة
2. النظام يُنشئ نظيراً في Google Classroom
3. يُ链接 الواجبين (Foreign Key في `Assignment.google_classroom_id`)
4. عند تسليم الطالب في Google Classroom → يُنسّق تلقائياً

---

## 6. حدود وقيود
- **API Quota**: Google Classroom API quota = 10,000 وحدة/يوم
- **الحد الأقصى للطلاب**: 1,000 طالب لكل دورة
- **الملفات المرفقة**: حد أقصى 20MB لكل ملف
- **الAtualization**: مزامنة كل 15 دقيقة (أو يدوياً)
- **الأمان**: OAuth 2.0 فقط، لا كلمات مرور مخزنة
