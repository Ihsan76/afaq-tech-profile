# خطة MVP — الشهور 1-2

## الأسبوع 1-2: الإعداد

### البنية التحتية
```
- إعداد Docker + docker-compose
- إعداد PostgreSQL
- إعداد Django + DRF
- إعداد Next.js
- إعداد GitHub Actions
- إعداد بيئة التطوير
```

### الملفات الأساسية
```
config/
├── settings/
│   ├── base.py
│   ├── development.py
│   └── production.py
├── urls.py
├── wsgi.py
└── asgi.py

core/
├── models.py
├── permissions.py
├── pagination.py
├── exceptions.py
└── utils.py
```

---

## الأسبوع 3-4: المستخدمون

### النماذج
```python
# users/models.py
class User(AbstractUser):
    class Role(models.TextChoices):
        STUDENT = 'student', 'طالب'
        TEACHER = 'teacher', 'معلم'
        CONTENT_CREATOR = 'creator', 'منشئ محتوى'
        ADMIN = 'admin', 'مدير'

    email = models.EmailField(unique=True)
    name_ar = models.CharField(max_length=255)
    name_en = models.CharField(max_length=255, blank=True)
    role = models.CharField(max_length=20, choices=Role.choices, default=Role.STUDENT)

    # 4 أبعاد اللغة
    ui_language = models.CharField(max_length=5, default='ar')
    input_language = models.CharField(max_length=5, default='ar')
    output_language = models.CharField(max_length=5, default='ar')
    source_locale = models.CharField(max_length=10, default='jo')

    is_verified = models.BooleanField(default=False)

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['name_ar', 'username']
```

> **ملاحظة:** النموذج الكامل يشمل حقولاً إضافية (phone, avatar, timezone, email_verified_at, last_login_ip, created_at, updated_at) ونموذج UserProfile منفصل —详见 [04-database/01-users.md](../part-04-database/01-users.md).

### APIs
```
POST /api/v1/auth/register/
POST /api/v1/auth/login/
POST /api/v1/auth/refresh/
GET  /api/v1/auth/profile/
PUT  /api/v1/auth/profile/
```

### الواجهة الأمامية
```
- شاشة تسجيل الدخول
- شاشة التسجيل
- شاشة التحقق من البريد
- شاشة إعادة تعيين كلمة المرور
```

---

## الأسبوع 5-6: الأكاديمية

### النماذج
```python
# academics/models.py
class Grade(models.Model):
    name_ar = models.CharField(max_length=100)
    level = models.IntegerField()

class Subject(models.Model):
    name_ar = models.CharField(max_length=100)

class Curriculum(models.Model):
    name_ar = models.CharField(max_length=255)
    country = models.CharField(max_length=100)
    year = models.IntegerField()
```

### APIs
```
GET /api/v1/academics/grades/
GET /api/v1/academics/subjects/
GET /api/v1/academics/curricula/
GET /api/v1/academics/curricula/{id}/units/
```

---

## الأسبوع 7-8: خطط الدروس

### النماذج
```python
# lessonplans/models.py
class LessonPlan(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    title = models.CharField(max_length=255)
    subject = models.ForeignKey(Subject, on_delete=models.SET_NULL, null=True)
    grade = models.ForeignKey(Grade, on_delete=models.SET_NULL, null=True)
    plan_data = models.JSONField()
    generated_by = models.CharField(max_length=10)
    ai_model_used = models.CharField(max_length=100)
    status = models.CharField(max_length=15)
```

### APIs
```
POST /api/v1/lesson-plans/generate/
GET  /api/v1/lesson-plans/
GET  /api/v1/lesson-plans/{id}/
PUT  /api/v1/lesson-plans/{id}/
DELETE /api/v1/lesson-plans/{id}/
POST /api/v1/lesson-plans/{id}/duplicate/
```

### الواجهة الأمامية
```
- شاشة إنشاء خطة درس
- شاشة عرض خطة الدرس
- شاشة تعديل خطة الدرس
- شاشة قائمة الخطط
```

---

## الأسبوع 9-10: AI + لوحة التحكم

### AI
```python
# ai/services.py
class AIService:
    def generate(self, user, feature, prompt, **kwargs):
        # توليد
        response = await self.router.route(prompt, feature)
        
        # تسجيل
        AIRun.objects.create(...)
        
        return response
```

### لوحة تحكم المعلم
```
- إحصائيات سريعة
- آخر الخطط
- إنشاء خطة جديدة
```

### لوحة تحكم المدير
```
- إدارة المستخدمين
- إدارة المناهج
- مراقبة AI
```

---

## الأسبوع 11-12: النشر

### النشر
```
- إعداد Vercel (Frontend)
- إعداد Railway (Backend)
- إعداد Cloudflare (CDN)
- إعداد Sentry (Monitoring)
- اختبارات النشر
```

### التحسين
```
- تحسين SEO
- تحسين الأداء
- إصلاح الأخطاء
- اختبارات شاملة
```

---

## جدول التنفيذ

| الأسبوع | المهمة | الحالة |
|---------|--------|--------|
| 1-2 | البنية التحتية | ✅ |
| 3-4 | المستخدمون | ✅ |
| 5-6 | الأكاديمية | ✅ |
| 7-8 | خطط الدروس | ✅ |
| 9-10 | AI + لوحة التحكم | ✅ |
| 11-12 | Page Builder + الثيمات | ✅ |
| 13 | المدوّنة (Blog) | ✅ |
| 14 | صفحات إضافية + تحسينات | ✅ |

---

## الموارد المطلوبة

### المطور
- 40 ساعة/أسبوع
- 12 أسبوع = 480 ساعة

### التكلفة (مجاني بالكامل أثناء البناء والاختبار)
| البند | الخدمة | التكلفة |
|-------|--------|---------|
| Domain | Namecheap | $12/سنة (~$1/شهر) |
| Frontend | Vercel (Hobby) | مجاني |
| Backend | Railway ($5 credit) | مجاني |
| Database | Supabase (Free) | مجاني |
| Redis | Upstash (Free) | مجاني |
| Storage | Cloudflare R2 (Free) | مجاني |
| AI | Gemini (Free) | مجاني |
| Email | Resend (Free) | مجاني |
| Monitoring | Sentry (Free) | مجاني |
| CI/CD | GitHub Actions (Free) | مجاني |
| **الإجمالي** | | **~$1/شهر** (Domain فقط) |

> **ملاحظة:** جميع الخدمات مجانية أثناء البناء والاختبار. عند الإطلاق، يتم الترقية تدريجياً حسب الحمل الفعلي —详见 [06-deployment.md](../part-03-architecture/06-deployment.md).
