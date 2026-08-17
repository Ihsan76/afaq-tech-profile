# الإشعارات

## أنواع الإشعارات

### حسب القناة
| القناة | الاستخدام | الإعداد |
|--------|-----------|---------|
| **In-App** | إشعارات داخل التطبيق | افتراضي |
| **Email** | إشعارات بريدية | اختياري |
| **Push** | إشعارات الموبايل | اختياري |
| **SMS** | رسائل نصية | للمدفوعات فقط |

### حسب النوع
| النوع | الأولوية | القناة |
|-------|----------|--------|
| **نظام** | متوسط | In-App |
| **دفع** | عالي | In-App + Email |
| **AI** | منخفض | In-App |
| **دورة** | متوسط | In-App + Email |
| **سوق** | متوسط | In-App + Email |
| **مدوّنة** | منخفض | In-App |

---

## إعدادات الإشعارات

```python
class NotificationSetting(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    
    # القنوات
    email_enabled = models.BooleanField(default=True)
    push_enabled = models.BooleanField(default=True)
    in_app_enabled = models.BooleanField(default=True)
    
    # حسب النوع
    system_notifications = models.BooleanField(default=True)
    payment_notifications = models.BooleanField(default=True)
    course_notifications = models.BooleanField(default=True)
    ai_notifications = models.BooleanField(default=True)
    marketplace_notifications = models.BooleanField(default=True)
    blog_notifications = models.BooleanField(default=False)
    
    # أوقات الصمت
    quiet_hours_start = models.TimeField(null=True, blank=True)
    quiet_hours_end = models.TimeField(null=True, blank=True)
```

---

## إرسال الإشعارات

```python
class NotificationService:
    
    @staticmethod
    def send(user, type, title, message, priority='medium', action_url=''):
        """إرسال إشعار"""
        # إنشاء الإشعار
        notification = Notification.objects.create(
            user=user,
            type=type,
            title=title,
            message=message,
            priority=priority,
            action_url=action_url
        )
        
        # فحص إعدادات المستخدم
        settings = NotificationSetting.objects.get_or_create(user=user)[0]
        
        # إرسال In-App
        if settings.in_app_enabled:
            # سيتم جلسلها عبر API
            pass
        
        # إرسال Email
        if settings.email_enabled and settings.should_send_email(type):
            NotificationService._send_email(user, notification)
        
        # إرسال Push
        if settings.push_enabled and settings.should_send_push(type):
            NotificationService._send_push(user, notification)
        
        return notification
    
    @staticmethod
    def _send_email(user, notification):
        """إرسال بريد إلكتروني"""
        from django.core.mail import send_mail
        
        send_mail(
            subject=notification.title,
            message=notification.message,
            from_email='noreply@afaq.app',
            recipient_list=[user.email],
            fail_silently=True,
        )
    
    @staticmethod
    def _send_push(user, notification):
        """إرسال Push Notification"""
        # Firebase Cloud Messaging
        # ...
        pass
```

---

## الإشعارات المسبقة

### للطالب
- "لديك درس جديد في {course}"
- "تم نشر نتيجة الاختبار"
- "معلمك أضاف ملاحظات جديدة"

### للمعلم
- "تم شراء خدمة جديدة"
- "طالب جديد سجّل في دورتك"
- "تقييم جديد على خدمتك"

### للمدير
- "مستخدم جديد قد سجّل"
- "طلب استرداد مالي"
- "تنبيه أداء AI"

---

## النشرة البريدية

```python
class NewsletterService:
    
    @staticmethod
    def subscribe(email):
        """الاشتراك في النشرة"""
        newsletter, created = Newsletter.objects.get_or_create(
            email=email,
            defaults={'is_active': True}
        )
        return newsletter
    
    @staticmethod
    def send_newsletter(subject, content, recipients=None):
        """إرسال النشرة"""
        if recipients is None:
            recipients = Newsletter.objects.filter(is_active=True)
        
        for subscriber in recipients:
            send_mail(
                subject=subject,
                message=content,
                from_email='newsletter@afaq.app',
                recipient_list=[subscriber.email],
                fail_silently=True,
            )
```
