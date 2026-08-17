# نماذج الوسائط

## نموذج الملفات

```python
from django.db import models
from django.conf import settings

class MediaFile(models.Model):
    """الملفات المرفوعة"""
    
    class FileType(models.TextChoices):
        IMAGE = 'image', 'صورة'
        VIDEO = 'video', 'فيديو'
        DOCUMENT = 'document', 'مستند'
        AUDIO = 'audio', 'صوت'
        OTHER = 'other', 'أخرى'
    
    class UsageType(models.TextChoices):
        AVATAR = 'avatar', 'صورة شخصية'
        COURSE_THUMBNAIL = 'course_thumbnail', 'صورة دورة'
        BLOG_IMAGE = 'blog_image', 'صورة مقال'
        SERVICE_IMAGE = 'service_image', 'صورة خدمة'
        LESSON_ATTACHMENT = 'lesson_attachment', 'مرفق خطة درس'
        GENERAL = 'general', 'عام'
    
    # معلومات الملف
    file = models.FileField(upload_to='media/%Y/%m/')
    original_name = models.CharField(max_length=255)
    file_type = models.CharField(max_length=15, choices=FileType.choices)
    usage_type = models.CharField(max_length=20, choices=UsageType.choices, default=UsageType.GENERAL)
    
    # الأبعاد
    file_size = models.IntegerField(default=0)  # in bytes
    width = models.IntegerField(null=True, blank=True)
    height = models.IntegerField(null=True, blank=True)
    duration = models.IntegerField(null=True, blank=True)  # for video/audio, in seconds
    
    # MIME type
    mime_type = models.CharField(max_length=100)
    
    # معلومات التحسين
    is_optimized = models.BooleanField(default=False)
    variants = models.JSONField(default=dict, blank=True)
    # {"thumbnail": "url", "medium": "url", "large": "url"}
    
    # المرجع
    uploaded_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True)
    reference_type = models.CharField(max_length=50, blank=True)
    reference_id = models.IntegerField(null=True, blank=True)
    
    # Metadata
    alt_text = models.CharField(max_length=255, blank=True)
    metadata = models.JSONField(default=dict, blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name = 'ملف وسائط'
        verbose_name_plural = 'ملفات الوسائط'
        ordering = ['-created_at']
    
    def __str__(self):
        return self.original_name
    
    @property
    def size_display(self):
        if self.file_size < 1024:
            return f"{self.file_size} B"
        elif self.file_size < 1024 * 1024:
            return f"{self.file_size / 1024:.1f} KB"
        else:
            return f"{self.file_size / (1024 * 1024):.1f} MB"
```

---

## نموذج السجل (Audit Log)

```python
class AuditLog(models.Model):
    """سجل التدقيق للعمليات الحساسة"""
    
    class Action(models.TextChoices):
        CREATE = 'create', 'إنشاء'
        UPDATE = 'update', 'تعديل'
        DELETE = 'delete', 'حذف'
        LOGIN = 'login', 'دخول'
        LOGOUT = 'logout', 'خروج'
        PAYMENT = 'payment', 'دفع'
        EXPORT = 'export', 'تصدير'
    
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True)
    
    action = models.CharField(max_length=15, choices=Action.choices)
    resource_type = models.CharField(max_length=50)
    resource_id = models.IntegerField()
    
    # التفاصيل
    description = models.TextField(blank=True)
    old_value = models.JSONField(null=True, blank=True)
    new_value = models.JSONField(null=True, blank=True)
    
    # السياق
    ip_address = models.GenericIPAddressField(null=True, blank=True)
    user_agent = models.TextField(blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name = 'سجل تدقيق'
        verbose_name_plural = 'سجلات التدقيق'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['resource_type', 'resource_id']),
            models.Index(fields=['user', 'action']),
        ]
    
    def __str__(self):
        return f"{self.user} - {self.action} - {self.resource_type}"
```

---

## ملخص العلاقات

```
MediaFile
    ├── User (uploaded_by)
    ├── reference_type + reference_id (polymorphic)
    └── variants (JSON)

AuditLog
    ├── User (optional)
    ├── resource_type + resource_id (polymorphic)
    └── old_value, new_value (JSON)
```
