# الأمان

## مبادئ الأمان

### Defense in Depth
طبقة حماية متعددة: CDN → Firewall → API Gateway → Backend → Database

### Principle of Least Privilege
كل مستخدم/خدمة يحصل على أقل صلاحيات مطلوبة فقط

### Secure by Default
جميع الإعدادات آمنة بشكل افتراضي، لا يحتاج المستخدم لتفعيل يدوي

---

## الحماية على مستوى الشبكة

```
المستخدم
    ↓ HTTPS (TLS 1.3)
Cloudflare CDN + WAF
    ↓ HTTPS
Frontend (Vercel)
    ↓ HTTPS
Backend (Railway)
    ↓ TCP (内部)
Database (PostgreSQL)
```

### Headers الأمان

```python
# middleware.py
SECURE_HSTS_SECONDS = 31536000
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_CONTENT_TYPE_NOSNIFF = True
SECURE_BROWSER_XSS_FILTER = True
X_FRAME_OPTIONS = 'DENY'
CSRF_COOKIE_SECURE = True
SESSION_COOKIE_SECURE = True
```

---

## المصادقة والتفويض

### JWT Flow

```
1. User → Login (email + password)
2. Backend → Validate credentials
3. Backend → Return access_token (30min) + refresh_token (7days)
4. Frontend → Store tokens securely
5. Frontend → Send access_token in Authorization header
6. Backend → Validate token on each request
7. Frontend → Refresh token when expired
```

### كلمات المرور

```python
# Argon2id (Django default since 3.1)
PASSWORD_HASHERS = [
    'django.contrib.auth.hashers.Argon2PasswordHasher',
    'django.contrib.auth.hashers.PBKDF2PasswordHasher',
]
```

### إدارة الصلاحيات

```python
# permissions.py
class IsTeacher(BasePermission):
    def has_permission(self, request, view):
        return request.user.role == 'teacher'

class IsStudent(BasePermission):
    def has_permission(self, request, view):
        return request.user.role == 'student'

class IsAdmin(BasePermission):
    def has_permission(self, request, view):
        return request.user.role == 'admin'
```

---

## حماية API

### Rate Limiting

```python
# settings.py
REST_FRAMEWORK = {
    'DEFAULT_THROTTLE_CLASSES': [
        'rest_framework.throttling.AnonRateThrottle',
        'rest_framework.throttling.UserRateThrottle',
    ],
    'DEFAULT_THROTTLE_RATES': {
        'anon': '100/hour',
        'user': '1000/hour',
    }
}
```

### CORS

```python
CORS_ALLOWED_ORIGINS = [
    "https://afaq.app",
    "https://staging.afaq.app",
]
CORS_ALLOW_CREDENTIALS = True
```

### Input Validation

```python
# DRF serializers handle validation automatically
class LessonPlanSerializer(serializers.ModelSerializer):
    class Meta:
        model = LessonPlan
        fields = ['title', 'subject', 'grade', 'plan_data']
    
    def validate_title(self, value):
        if len(value) < 3:
            raise serializers.ValidationError("العنوان قصير جداً")
        return value
```

---

## حماية قاعدة البيانات

### SQL Injection
Django ORM يستخدم parametrized queries تلقائياً

### ORM Safety
```python
# آمن
LessonPlan.objects.filter(user=request.user)

# خطر — لا تفعل
LessonPlan.objects.raw(f"SELECT * FROM lessonplans WHERE user_id = {user_id}")
```

### Encryption at Rest
```python
# حقول مشفرة
from django_cryptography.fields import encrypt

class Payment(models.Model):
    card_number = encrypt(models.CharField(max_length=19))
```

---

## حماية الملفات

### Upload Validation

```python
ALLOWED_IMAGE_TYPES = ['image/jpeg', 'image/png', 'image/webp']
MAX_UPLOAD_SIZE = 10 * 1024 * 1024  # 10MB

def validate_file(file):
    if file.content_type not in ALLOWED_IMAGE_TYPES:
        raise ValidationError("نوع الملف غير مدعوم")
    if file.size > MAX_UPLOAD_SIZE:
        raise ValidationError("الملف كبير جداً")
```

### Storage Security
```python
# Cloudflare R2 / S3
AWS_S3_FILE_OVERWRITE = False
AWS_DEFAULT_ACL = 'private'
```

---

## حماية من الهجمات الشائعة

| الهجوم | الحماية |
|--------|---------|
| SQL Injection | Django ORM (parametrized queries) |
| XSS | Output encoding + CSP headers |
| CSRF | CSRF tokens + SameSite cookies |
| Brute Force | Rate limiting + account lockout |
| DDoS | Cloudflare + rate limiting |
| MITM | HTTPS everywhere |
| Session Hijacking | Secure + HttpOnly cookies |
| Clickjacking | X-Frame-Options: DENY |

---

## Account Lockout

```python
# إعدادات الأقفال
AUTH_LOCKOUT_ATTEMPTS = 5
AUTH_LOCKOUT_DURATION = 30  # دقائق

class LoginAttempt(models.Model):
    email = models.EmailField()
    ip_address = models.GenericIPAddressField()
    timestamp = models.DateTimeField(auto_now_add=True)
    success = models.BooleanField(default=False)
```

---

## التدقيق والمراقبة

```python
# logging settings
LOGGING = {
    'version': 1,
    'handlers': {
        'file': {
            'class': 'logging.FileHandler',
            'filename': 'security.log',
        },
    },
    'loggers': {
        'django.security': {
            'handlers': ['file'],
            'level': 'WARNING',
        },
    },
}
```

### الأحداث المُسجَّلة
- محاولات تسجيل دخول فاشلة
- تغيير كلمة المرور
- تغيير الصلاحيات
- عمليات الدفع
- طلبات AI عالية الاستهلاك

---

## ملخص

> الأمان مبني من البداية عبر **Defense in Depth**: HTTPS + WAF + JWT + Rate Limiting + ORM + Encryption. كل طلب مُدَقَّق. الملفات مُحقَّقة قبل الرفع. كلمات المرور Argon2id. التدقيق شامل.
