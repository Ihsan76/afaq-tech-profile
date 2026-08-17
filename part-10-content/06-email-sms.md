# خدمات البريد الإلكتروني والرسائل النصية (Email & SMS)

## نظرة عامة

> **مجاني أثناء البناء:** Resend (100/يوم مجاناً) كافٍ لـ MVP. Twilio (رسائل) اختياري — يمكن تأجيله للإطلاق.

ن system لإرسال الرسائل_EMAIL_transaction و SMS مع دعم تعدد اللغات.

---

## المكونات

```
┌─────────────────────────────────────────────────────────────────┐
│                    Email & SMS Services                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────┐    ┌──────────────────┐                   │
│  │  Email Templates │    │  SMS Templates   │                   │
│  │  (multi-lang)    │    │  (multi-lang)    │                   │
│  └──────────────────┘    └──────────────────┘                   │
│          │                       │                               │
│          ▼                       ▼                               │
│  ┌──────────────────┐    ┌──────────────────┐                   │
│  │  Resend          │    │  Twilio          │                   │
│  │  (Email)         │    │  (SMS)           │                   │
│  └──────────────────┘    └──────────────────┘                   │
│          │                       │                               │
│          ▼                       ▼                               │
│  ┌──────────────────┐    ┌──────────────────┐                   │
│  │  Celery          │    │  Rate Limiter    │                   │
│  │  (Async)         │    │  (Anti-spam)     │                   │
│  └──────────────────┘    └──────────────────┘                   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Django Models

```python
# communications/models.py

from django.db import models


class EmailTemplate(models.Model):
    """قالب البريد الإلكتروني"""
    
    name = models.CharField(max_length=100, unique=True)
    subject_ar = models.CharField(max_length=255)
    subject_en = models.CharField(max_length=255)
    subject_fr = models.CharField(max_length=255, blank=True)
    
    # المحتوى HTML
    body_ar = models.TextField()
    body_en = models.TextField()
    body_fr = models.TextField(blank=True)
    
    # المتغيرات
    variables = models.JSONField(default=list, blank=True)
    # مثال: ['user_name', 'course_name', 'reset_link']
    
    is_active = models.BooleanField(default=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name = 'قالب بريد'
        verbose_name_plural = 'قوالب البريد'
    
    def get_subject(self, language: str = 'ar') -> str:
        """جلب الموضوع حسب اللغة"""
        return getattr(self, f'subject_{language}', self.subject_en)
    
    def get_body(self, language: str = 'ar') -> str:
        """جلب المحتوى حسب اللغة"""
        return getattr(self, f'body_{language}', self.body_en)


class SMSTemplate(models.Model):
    """قالب الرسائل النصية"""
    
    name = models.CharField(max_length=100, unique=True)
    body_ar = models.TextField()
    body_en = models.TextField()
    body_fr = models.TextField(blank=True)
    
    variables = models.JSONField(default=list, blank=True)
    
    is_active = models.BooleanField(default=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name = 'قالب رسالة نصية'
        verbose_name_plural = 'قوالب الرسائل النصية'


class EmailLog(models.Model):
    """سجل البريد الإلكتروني"""
    
    class Status(models.TextChoices):
        PENDING = 'pending', 'قيد الانتظار'
        SENT = 'sent', 'تم الإرسال'
        DELIVERED = 'delivered', 'تم التسليم'
        OPENED = 'opened', 'تم الفتح'
        FAILED = 'failed', 'فاشل'
        BOUNCED = 'rejected', 'مرتد'
    
    template = models.ForeignKey(EmailTemplate, on_delete=models.SET_NULL, null=True)
    recipient_email = models.EmailField()
    recipient_name = models.CharField(max_length=255, blank=True)
    
    subject = models.CharField(max_length=255)
    body = models.TextField()
    
    status = models.CharField(max_length=15, choices=Status.choices, default=Status.PENDING)
    
    # بيانات إضافية
    metadata = models.JSONField(default=dict, blank=True)
    
    # التتبع
    sent_at = models.DateTimeField(null=True, blank=True)
    delivered_at = models.DateTimeField(null=True, blank=True)
    opened_at = models.DateTimeField(null=True, blank=True)
    error_message = models.TextField(blank=True)
    
    # المعرف الخارجي
    external_id = models.CharField(max_length=255, blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name = 'سجل بريد'
        verbose_name_plural = 'سجلات البريد'
        ordering = ['-created_at']


class SMSLog(models.Model):
    """سجل الرسائل النصية"""
    
    class Status(models.TextChoices):
        PENDING = 'pending', 'قيد الانتظار'
        SENT = 'sent', 'تم الإرسال'
        DELIVERED = 'delivered', 'تم التسليم'
        FAILED = 'failed', 'فاشل'
    
    template = models.ForeignKey(SMSTemplate, on_delete=models.SET_NULL, null=True)
    recipient_phone = models.CharField(max_length=20)
    recipient_name = models.CharField(max_length=255, blank=True)
    
    body = models.TextField()
    
    status = models.CharField(max_length=15, choices=Status.choices, default=Status.PENDING)
    
    external_id = models.CharField(max_length=255, blank=True)
    error_message = models.TextField(blank=True)
    
    sent_at = models.DateTimeField(null=True, blank=True)
    delivered_at = models.DateTimeField(null=True, blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name = 'سجل رسالة نصية'
        verbose_name_plural = 'سجلات الرسائل النصية'
        ordering = ['-created_at']
```

---

## Email Service

```python
# communications/services.py

import resend
from django.conf import settings
from django.template.loader import render_to_string
from celery import shared_task
from .models import EmailTemplate, SMSTemplate, EmailLog, SMSLog


class EmailService:
    """خدمة البريد الإلكتروني"""
    
    def __init__(self):
        resend.api_key = settings.RESEND_API_KEY
    
    @classmethod
    def send_email(
        cls,
        template_name: str,
        recipient_email: str,
        recipient_name: str,
        context: dict,
        language: str = 'ar',
        metadata: dict = None,
    ) -> EmailLog:
        """إرسال بريد إلكتروني"""
        
        try:
            template = EmailTemplate.objects.get(name=template_name, is_active=True)
        except EmailTemplate.DoesNotExist:
            raise ValueError(f"Template '{template_name}' not found")
        
        # تجهيز السياق
        subject = template.get_subject(language)
        body = template.get_body(language)
        
        # استبدال المتغيرات
        for key, value in context.items():
            subject = subject.replace(f'{{{{{key}}}}}', str(value))
            body = body.replace(f'{{{{{key}}}}}', str(value))
        
        # إنشاء السجل
        log = EmailLog.objects.create(
            template=template,
            recipient_email=recipient_email,
            recipient_name=recipient_name,
            subject=subject,
            body=body,
            metadata=metadata or {},
        )
        
        # الإرسال غير المتزامن
        cls._send_async.delay(log.id)
        
        return log
    
    @classmethod
    @shared_task(bind=True, max_retries=3)
    def _send_async(cls, log_id: int):
        """إرسال غير متزامن"""
        
        log = EmailLog.objects.get(id=log_id)
        
        try:
            result = resend.Emails.send({
                "from": f"آفاق تكنولوجي <{settings.DEFAULT_FROM_EMAIL}>",
                "to": [log.recipient_email],
                "subject": log.subject,
                "html": log.body,
                "reply_to": settings.SUPPORT_EMAIL,
            })
            
            log.status = EmailLog.Status.SENT
            log.external_id = result.get('id', '')
            log.sent_at = timezone.now()
            log.save()
            
        except Exception as e:
            log.status = EmailLog.Status.FAILED
            log.error_message = str(e)
            log.save()
            
            # إعادة المحاولة
            raise cls.retry(countdown=60 * (2 ** self.request.retries))


class SMSService:
    """خدمة الرسائل النصية"""
    
    def __init__(self):
        from twilio.rest import Client
        self.client = Client(
            settings.TWILIO_ACCOUNT_SID,
            settings.TWILIO_AUTH_TOKEN
        )
    
    @classmethod
    def send_sms(
        cls,
        template_name: str,
        recipient_phone: str,
        context: dict,
        language: str = 'ar',
    ) -> SMSLog:
        """إرسال رسالة نصية"""
        
        try:
            template = SMSTemplate.objects.get(name=template_name, is_active=True)
        except SMSTemplate.DoesNotExist:
            raise ValueError(f"Template '{template_name}' not found")
        
        body = getattr(template, f'body_{language}', template.body_en)
        
        # استبدال المتغيرات
        for key, value in context.items():
            body = body.replace(f'{{{{{key}}}}}', str(value))
        
        # إنشاء السجل
        log = SMSLog.objects.create(
            template=template,
            recipient_phone=recipient_phone,
            body=body,
        )
        
        # الإرسال
        cls._send_async.delay(log.id)
        
        return log
    
    @classmethod
    @shared_task(bind=True, max_retries=3)
    def _send_async(cls, log_id: int):
        """إرسال غير متزامن"""
        
        log = SMSLog.objects.get(id=log_id)
        
        try:
            from twilio.rest import Client
            client = Client(
                settings.TWILIO_ACCOUNT_SID,
                settings.TWILIO_AUTH_TOKEN
            )
            
            message = client.messages.create(
                body=log.body,
                from_=settings.TWILIO_PHONE_NUMBER,
                to=log.recipient_phone,
            )
            
            log.status = SMSLog.Status.SENT
            log.external_id = message.sid
            log.sent_at = timezone.now()
            log.save()
            
        except Exception as e:
            log.status = SMSLog.Status.FAILED
            log.error_message = str(e)
            log.save()
            
            raise cls.retry(countdown=60 * (2 ** self.request.retries))
```

---

## القوالب الجاهزة

```python
# communications/seed_templates.py

DEFAULT_EMAIL_TEMPLATES = [
    {
        'name': 'welcome',
        'subject_ar': 'مرحباً بك في آفاق تكنولوجي',
        'subject_en': 'Welcome to Afaq Technology',
        'body_ar': '''
            <h1>مرحباً {user_name}!</h1>
            <p>نرحب بك في منصة آفاق تكنولوجي.</p>
            <p>منصتك التعليمية الذكية جاهزة للبدء.</p>
            <a href="{dashboard_url}" style="background:#3B82F6;color:white;padding:10px 20px;border-radius:5px;text-decoration:none;">
                ابدأ الآن
            </a>
        ''',
        'body_en': '''
            <h1>Welcome {user_name}!</h1>
            <p>Welcome to Afaq Technology platform.</p>
            <p>Your smart learning platform is ready to go.</p>
            <a href="{dashboard_url}" style="background:#3B82F6;color:white;padding:10px 20px;border-radius:5px;text-decoration:none;">
                Get Started
            </a>
        ''',
        'variables': ['user_name', 'dashboard_url'],
    },
    {
        'name': 'password_reset',
        'subject_ar': 'إعادة تعيين كلمة المرور',
        'subject_en': 'Password Reset',
        'body_ar': '''
            <h1>إعادة تعيين كلمة المرور</h1>
            <p>مرحباً {user_name}،</p>
            <p>تلقينا طلباً لإعادة تعيين كلمة المرور.</p>
            <a href="{reset_url}" style="background:#EF4444;color:white;padding:10px 20px;border-radius:5px;text-decoration:none;">
                إعادة التعيين
            </a>
            <p>إذا لم تطلب هذا، تجاهل هذا البريد.</p>
        ''',
        'body_en': '''
            <h1>Password Reset</h1>
            <p>Hello {user_name},</h1>
            <p>We received a request to reset your password.</p>
            <a href="{reset_url}" style="background:#EF4444;color:white;padding:10px 20px;border-radius:5px;text-decoration:none;">
                Reset Password
            </a>
            <p>If you didn't request this, ignore this email.</p>
        ''',
        'variables': ['user_name', 'reset_url'],
    },
    {
        'name': 'course_enrollment',
        'subject_ar': 'تم التسجيل في الدورة {course_name}',
        'subject_en': 'Enrolled in {course_name}',
        'body_ar': '''
            <h1>تم التسجيل بنجاح!</h1>
            <p>مرحباً {user_name}،</p>
            <p>لقد تم تسجيلك في الدورة: <strong>{course_name}</strong></p>
            <a href="{course_url}" style="background:#10B981;color:white;padding:10px 20px;border-radius:5px;text-decoration:none;">
                ابدأ التعلم
            </a>
        ''',
        'body_en': '''
            <h1>Enrollment Successful!</h1>
            <p>Hello {user_name},</p>
            <p>You've been enrolled in: <strong>{course_name}</strong></p>
            <a href="{course_url}" style="background:#10B981;color:white;padding:10px 20px;border-radius:5px;text-decoration:none;">
                Start Learning
            </a>
        ''',
        'variables': ['user_name', 'course_name', 'course_url'],
    },
    {
        'name': 'payment_receipt',
        'subject_ar': 'إيصال الدفع - الطلب #{order_id}',
        'subject_en': 'Payment Receipt - Order #{order_id}',
        'body_ar': '''
            <h1>إيصال الدفع</h1>
            <p>مرحباً {user_name}،</p>
            <p>تم استلام الدفع بنجاح:</p>
            <table style="width:100%;border-collapse:collapse;">
                <tr><td>المبلغ:</td><td>{amount} {currency}</td></tr>
                <tr><td>التاريخ:</td><td>{date}</td></tr>
                <tr><td>رقم الطلب:</td><td>{order_id}</td></tr>
            </table>
        ''',
        'body_en': '''
            <h1>Payment Receipt</h1>
            <p>Hello {user_name},</p>
            <p>Payment received successfully:</p>
            <table style="width:100%;border-collapse:collapse;">
                <tr><td>Amount:</td><td>{amount} {currency}</td></tr>
                <tr><td>Date:</td><td>{date}</td></tr>
                <tr><td>Order ID:</td><td>{order_id}</td></tr>
            </table>
        ''',
        'variables': ['user_name', 'amount', 'currency', 'date', 'order_id'],
    },
]

DEFAULT_SMS_TEMPLATES = [
    {
        'name': 'verification_code',
        'body_ar': 'كود التحقق الخاص بك هو: {code}. صالح لمدة 5 دقائق.',
        'body_en': 'Your verification code is: {code}. Valid for 5 minutes.',
        'variables': ['code'],
    },
    {
        'name': 'password_reset',
        'body_ar': 'كود إعادة تعيين كلمة المرور: {code}.',
        'body_en': 'Password reset code: {code}.',
        'variables': ['code'],
    },
]
```

---

## Rate Limiting

```python
# communications/rate_limit.py

from django.core.cache import cache
from datetime import timedelta


class EmailRateLimiter:
    """محدد معدل البريد الإلكتروني"""
    
    LIMITS = {
        'per_minute': 5,
        'per_hour': 50,
        'per_day': 500,
    }
    
    @classmethod
    def can_send(cls, email: str) -> bool:
        """هل يمكن الإرسال؟"""
        
        for period, limit in cls.LIMITS.items():
            key = f"email_rate:{period}:{email}"
            count = cache.get(key, 0)
            
            if count >= limit:
                return False
        
        return True
    
    @classmethod
    def record_send(cls, email: str):
        """تسجيل إرسال"""
        
        for period, limit in cls.LIMITS.items():
            key = f"email_rate:{period}:{email}"
            
            if period == 'per_minute':
                timeout = 60
            elif period == 'per_hour':
                timeout = 3600
            else:
                timeout = 86400
            
            cache.set(key, cache.get(key, 0) + 1, timeout)
```

---

## ملخص

> **خدمات البريد والرسائل** تدعم: Resend للبريد، Twilio للرسائل، قوالب متعددة اللغات، إرسال غير متزامن عبر Celery، rate limiting، وسجلات مفصلة.
