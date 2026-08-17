# الخلفية (Backend)

## التقنية الأساسية

| العنصر | الإصدار | السبب |
|--------|---------|-------|
| **Django** | 5.x | Mature ecosystem, ORM, Admin |
| **DRF** | latest | REST API toolkit |
| **SimpleJWT** | latest | JWT authentication |
| **drf-spectacular** | latest | OpenAPI docs |
| **django-filter** | latest | Query filtering |
| **Celery** | 5.x | Async tasks |
| **Redis** | 7.x | Caching, Celery broker |
| **psycopg2** | latest | PostgreSQL adapter |
| **Python** | 3.12+ | Modern features |

---

## بنية الملفات

```
backend/
├── config/
│   ├── settings/
│   │   ├── base.py           # الإعدادات الأساسية
│   │   ├── development.py    # بيئة التطوير
│   │   ├── production.py     # بيئة النشر
│   │   └── testing.py        # بيئة الاختبار
│   ├── urls.py               # URLs الرئيسية
│   ├── wsgi.py
│   └── asgi.py
├── core/
│   ├── models.py             # نماذج مشتركة
│   ├── permissions.py        # الصلاحيات الأساسية
│   ├── pagination.py         # التقسيم
│   ├── filters.py            # الفلاتر الأساسية
│   ├── exceptions.py         # الأخطاء المخصصة
│   └── utils.py              # أدوات مساعدة
├── users/
│   ├── models.py             # نموذج المستخدم
│   ├── serializers.py
│   ├── views.py
│   ├── urls.py
│   ├── admin.py
│   └── managers.py
├── academics/
│   ├── models.py             # المناهج والمراحل
│   ├── serializers.py
│   ├── views.py
│   └── urls.py
├── ai/
│   ├── models.py             # AI runs, stats
│   ├── services.py           # AI Service Layer
│   ├── providers/            # Multi-provider
│   │   ├── base.py
│   │   ├── gemini.py
│   │   ├── openai.py
│   │   ├── claude.py
│   │   └── ollama.py
│   ├── prompts/              # Prompt templates
│   │   ├── lesson_plan.py
│   │   ├── quiz.py
│   │   └── assistant.py
│   ├── serializers.py
│   ├── views.py
│   └── urls.py
├── lessonplans/
│   ├── models.py
│   ├── serializers.py
│   ├── views.py
│   └── urls.py
├── courses/
│   ├── models.py
│   ├── serializers.py
│   ├── views.py
│   └── urls.py
├── blog/
│   ├── models.py
│   ├── serializers.py
│   ├── views.py
│   └── urls.py
├── marketplace/
│   ├── models.py
│   ├── serializers.py
│   ├── views.py
│   └── urls.py
├── payments/
│   ├── models.py
│   ├── serializers.py
│   ├── views.py
│   └── urls.py
├── notifications/
│   ├── models.py
│   ├── serializers.py
│   ├── views.py
│   └── urls.py
├── media/
│   ├── models.py
│   ├── serializers.py
│   ├── views.py
│   └── urls.py
├── landingpages/
│   ├── models.py
│   ├── serializers.py
│   ├── views.py
│   └── urls.py
├── manage.py
├── requirements/
│   ├── base.txt
│   ├── development.txt
│   ├── production.txt
│   └── testing.txt
└── Dockerfile
```

---

## ترتيب تثبيت التطبيقات

```python
# config/settings/base.py
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    # Apps
    'core',
    'users',
    'academics',
    'ai',
    'lessonplans',
    'courses',
    'blog',
    'marketplace',
    'payments',
    'notifications',
    'media',
    'landingpages',
    # Third party
    'rest_framework',
    'rest_framework_simplejwt',
    'django_filters',
    'drf_spectacular',
]
```

---

## المصادقة

### JWT Configuration

```python
from datetime import timedelta

SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(minutes=30),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=7),
    'ROTATE_REFRESH_TOKENS': True,
    'BLACKLIST_AFTER_ROTATION': True,
    'AUTH_HEADER_TYPES': ('Bearer',),
    'USER_ID_FIELD': 'id',
    'USER_ID_CLAIM': 'user_id',
}
```

### DRF Configuration

```python
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ),
    'DEFAULT_PERMISSION_CLASSES': (
        'rest_framework.permissions.IsAuthenticated',
    ),
    'DEFAULT_PAGINATION_CLASS': 'core.pagination.StandardResultsPagination',
    'PAGE_SIZE': 20,
    'DEFAULT_FILTER_BACKENDS': (
        'django_filters.rest_framework.DjangoFilterBackend',
        'rest_framework.filters.SearchFilter',
        'rest_framework.filters.OrderingFilter',
    ),
    'DEFAULT_SCHEMA_CLASS': 'drf_spectacular.openapi.AutoSchema',
}
```
