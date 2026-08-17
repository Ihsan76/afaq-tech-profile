# نماذج المستخدمين — مُنفّذ ✅

## نموذج المستخدم المخصص — مُنفّذ ✅

```python
from django.contrib.auth.models import AbstractUser
from django.db import models

class User(AbstractUser):
    class Role(models.TextChoices):
        STUDENT = 'student', 'طالب'
        TEACHER = 'teacher', 'معلم'
        CONTENT_CREATOR = 'creator', 'منشئ محتوى'
        ADMIN = 'admin', 'مدير'

    class SubscriptionPlan(models.TextChoices):
        FREE = 'free', 'مجاني'
        BASIC = 'basic', 'أساسي'
        PRO = 'pro', 'برو'
        ENTERPRISE = 'enterprise', 'مؤسسي'

    PLAN_LEVELS = {'free': 0, 'basic': 1, 'pro': 2, 'enterprise': 3}

    email = models.EmailField(unique=True)
    translations = models.JSONField('الترجمات', default=dict, blank=True)
    role = models.CharField('الدور', max_length=20, choices=Role.choices, default=Role.STUDENT)
    subscription_plan = models.CharField('باقة الاشتراك', max_length=20, choices=SubscriptionPlan.choices, default=SubscriptionPlan.FREE)

    ui_language = models.CharField('لغة الواجهة', max_length=5, default='ar')
    input_language = models.CharField('لغة الإدخال', max_length=5, default='ar')
    output_language = models.CharField('لغة الإخراج', max_length=5, default='ar')
    source_locale = models.CharField(max_length=10, default='jo')

    is_verified = models.BooleanField('موثق', default=False)
    phone = models.CharField('الهاتف', max_length=20, blank=True)
    avatar = models.URLField('الصورة', blank=True)
    timezone = models.CharField('المنطقة الزمنية', max_length=50, default='Asia/Amman')

    # Gamification
    points = models.IntegerField('النقاط', default=0)
    badges = models.JSONField('الشارات', default=list, blank=True)
    lessons_created_count = models.IntegerField('عدد الخطط المنشأة', default=0)

    objects = UserManager()
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = []
```

---

## ملاحظات مهمة

### ما هو مُنفّذ ✅
- نموذج User مع `translations` (JSON) بدلاً من `name_ar`/`name_en` منفصلين
- Custom UserManager (إنشاء مستخدمين بالبريد الإلكتروني)
- JWT auth (register, login, refresh, profile)
- Forgot password / Reset password
- حقل `subscription_plan` (free/basic/pro/enterprise)
- **Gamification**: `points`, `badges` (JSON list), `lessons_created_count`
- `/me/stats/` endpoint: يعيد النقاط، الشارات، إحصائيات الخطط

### ما هو غير مُنفّذ ❌
- UserProfile (ملف شخصي إضافي)
- LoginAttempt (تتبع محاولات الدخول)
- UserSession (تتبع الجلسات)
- Email verification
- Change password

---

## الحقول الرئيسية

| الحقل | النوع | الافتراضي | الوصف |
|-------|-------|-----------|-------|
| `email` | EmailField (unique) | — | البريد الإلكتروني (USERNAME_FIELD) |
| `translations` | JSONField | {} | الاسم بالعربية/الإنجليزية والترجمات |
| `role` | CharField | student | الدور (student/teacher/creator/admin) |
| `subscription_plan` | CharField | free | الباقة (free/basic/pro/enterprise) |
| `ui_language` | CharField | ar | لغة الواجهة |
| `input_language` | CharField | ar | لغة الإدخال |
| `output_language` | CharField | ar | لغة المخرجات |
| `source_locale` | CharField | jo | البلد/المنهاج |
| `is_verified` | BooleanField | False | هل الحساب موثّق |
| `phone` | CharField | '' | رقم الهاتف |
| `avatar` | URLField | '' | رابط الصورة |
| `timezone` | CharField | Asia/Amman | المنطقة الزمنية |
| `points` | IntegerField | 0 | نقاط gamification |
| `badges` | JSONField | [] | قائمة الشارات |
| `lessons_created_count` | IntegerField | 0 | عدد الخطط المنشأة |

---

## الأدوار (4)

| الدور | الكود | الوصف |
|-------|-------|-------|
| طالب | `student` | المستخدم الافتراض |
| معلم | `teacher` | المعلمون |
| منشئ محتوى | `creator` | منشئو المحتوى |
| مدير | `admin` | المديرون |

---

## خطط الاشتراك (4)

| الباقة | الكود | الوصف |
|--------|-------|-------|
| مجاني | `free` | الباقة الافتراضية |
| أساسي | `basic` | ميزات إضافية |
| برو | `pro` | جميع الميزات |
| مؤسسي | `enterprise` | مخصص للمؤسسات |

---

## ملخص

> نموذج User مع JSONField للترجمات (بدلاً من name_ar/name_en)، يدعم 4 أدوار و4 خطط اشتراك. يتضمن 3 حقول Gamification (نقاط، شارات، عدد الخطط) مع endpoint إحصائي.  
> يوجد الآن تطبيق `gamification` منفصل بنماذج كاملة: Badge (5 فئات نادرة)، Achievement، Challenge (يومي/أسبوعي/شهري)، UserStreak، Level، PointsTransaction، Leaderboard.
