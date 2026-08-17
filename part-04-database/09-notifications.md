# نماذج الإشعارات

## نموذج الإشعار

```python
from django.db import models
from django.conf import settings

class Notification(models.Model):
    """إشعار المستخدم"""
    
    class Type(models.TextChoices):
        SYSTEM = 'system', 'إشعار نظام'
        PAYMENT = 'payment', 'إشعار دفع'
        COURSE = 'course', 'إشعار دورة'
        AI = 'ai', 'إشعار AI'
        MARKETPLACE = 'marketplace', 'إشعار سوق'
        BLOG = 'blog', 'إشعار مدوّنة'
    
    class Priority(models.TextChoices):
        LOW = 'low', 'منخفض'
        MEDIUM = 'medium', 'متوسط'
        HIGH = 'high', 'عالي'
    
    # المستخدم
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='notifications')
    
    # المحتوى
    type = models.CharField(max_length=15, choices=Type.choices)
    title = models.CharField(max_length=255, verbose_name='العنوان')
    message = models.TextField(verbose_name='الرسالة')
    
    # الأولوية
    priority = models.CharField(max_length=10, choices=Priority.choices, default=Priority.MEDIUM)
    
    # الارتباط
    reference_type = models.CharField(max_length=50, blank=True)  # 'order', 'course', etc.
    reference_id = models.IntegerField(null=True, blank=True)
    action_url = models.URLField(blank=True)
    
    # الحالة
    is_read = models.BooleanField(default=False)
    read_at = models.DateTimeField(null=True, blank=True)
    
    # Metadata
    metadata = models.JSONField(default=dict, blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name = 'إشعار'
        verbose_name_plural = 'الإشعارات'
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.user.name_ar} - {self.title}"
    
    def mark_as_read(self):
        self.is_read = True
        self.read_at = timezone.now()
        self.save()
```

---

## نموذج إعدادات الإشعارات

```python
class NotificationSetting(models.Model):
    """إعدادات إشعارات المستخدم"""
    
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='notification_settings')
    
    # القنوات
    email_enabled = models.BooleanField(default=True)
    push_enabled = models.BooleanField(default=True)
    in_app_enabled = models.BooleanField(default=True)
    sms_enabled = models.BooleanField(default=False)
    
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
    
    class Meta:
        verbose_name = 'إعداد إشعارات'
        verbose_name_plural = 'إعدادات الإشعارات'
    
    def __str__(self):
        return f"إعدادات {self.user.name_ar}"
```

---

## نموذج النشرة البريدية

```python
class Newsletter(models.Model):
    """النشرة البريدية"""
    
    email = models.EmailField(unique=True)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True)
    
    is_active = models.BooleanField(default=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    unsubscribed_at = models.DateTimeField(null=True, blank=True)
    
    class Meta:
        verbose_name = 'نشرة بريدية'
        verbose_name_plural = 'النشرات البريدية'
    
    def __str__(self):
        return self.email
```

---

## ملخص العلاقات

```
User
    ├── Notification (1:N)
    ├── NotificationSetting (1:1)
    └── Newsletter (M:1, optional)
```
