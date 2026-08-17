# نماذج السوق (Marketplace)

## نموذج الخدمة

```python
class Service(models.Model):
    """الخدمة المقدمة في السوق"""
    
    class Category(models.TextChoices):
        LESSON_PLAN = 'lesson_plan', 'خطة درس'
        COURSE = 'course', 'دورة'
        WORKSHOP = 'workshop', 'ورشة عمل'
        CONSULTATION = 'consultation', 'استشارة'
        TUTORING = 'tutoring', 'دروس خصوصية'
        DIGITAL_PRODUCT = 'digital_product', 'منتج رقمي'
    
    class Status(models.TextChoices):
        DRAFT = 'draft', 'مسودة'
        ACTIVE = 'active', 'نشط'
        PAUSED = 'paused', 'متوقف'
        ARCHIVED = 'archived', 'مؤرشف'
    
    # معلومات أساسية
    title = models.CharField(max_length=255, verbose_name='العنوان')
    slug = models.SlugField(unique=True, allow_unicode=True)
    description = models.TextField(verbose_name='الوصف')
    
    # المزود
    provider = models.ForeignKey('users.User', on_delete=models.CASCADE, related_name='services')
    
    # التصنيف
    category = models.CharField(max_length=20, choices=Category.choices)
    
    # التسعير
    price = models.DecimalField(max_digits=10, decimal_places=2)
    currency = models.CharField(max_length=3, default='USD')
    
    # الوسائط
    thumbnail = models.ImageField(upload_to='services/thumbnails/', blank=True, null=True)
    images = models.JSONField(default=list, blank=True)
    
    # التقييمات
    rating = models.DecimalField(max_digits=3, decimal_places=2, default=0)
    review_count = models.IntegerField(default=0)
    
    # الحالة
    status = models.CharField(max_length=15, choices=Status.choices, default=Status.DRAFT)
    is_featured = models.BooleanField(default=False)
    
    # الإحصائيات
    order_count = models.IntegerField(default=0)
    view_count = models.IntegerField(default=0)
    
    # Metadata
    metadata = models.JSONField(default=dict, blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name = 'خدمة'
        verbose_name_plural = 'الخدمات'
        ordering = ['-created_at']
    
    def __str__(self):
        return self.title
```

---

## نموذج الطلب

```python
class Order(models.Model):
    """طلب شراء خدمة"""
    
    class Status(models.TextChoices):
        PENDING = 'pending', 'قيد الانتظار'
        PAID = 'paid', 'مدفوع'
        IN_PROGRESS = 'in_progress', 'قيد التنفيذ'
        COMPLETED = 'completed', 'مكتمل'
        CANCELLED = 'cancelled', 'ملغي'
        REFUNDED = 'refunded', 'مسترد'
    
    # معلومات الطلب
    order_number = models.CharField(max_length=50, unique=True)
    service = models.ForeignKey(Service, on_delete=models.CASCADE, related_name='orders')
    buyer = models.ForeignKey('users.User', on_delete=models.CASCADE, related_name='orders')
    provider = models.ForeignKey('users.User', on_delete=models.CASCADE, related_name='provider_orders')
    
    # التسعير
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    currency = models.CharField(max_length=3, default='USD')
    platform_fee = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    provider_amount = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    
    # الحالة
    status = models.CharField(max_length=15, choices=Status.choices, default=Status.PENDING)
    
    # معلومات إضافية
    notes = models.TextField(blank=True)
    requirements = models.JSONField(default=dict, blank=True)
    
    # التوقيت
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    paid_at = models.DateTimeField(null=True, blank=True)
    completed_at = models.DateTimeField(null=True, blank=True)
    
    class Meta:
        verbose_name = 'طلب'
        verbose_name_plural = 'الطلبات'
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.order_number} - {self.service.title}"
    
    def calculate_fees(self):
        self.platform_fee = self.amount * 0.10  # 10% platform fee
        self.provider_amount = self.amount - self.platform_fee
        self.save()
```

---

## نموذج التقييم

```python
class ServiceReview(models.Model):
    """تقييم الخدمة"""
    
    service = models.ForeignKey(Service, on_delete=models.CASCADE, related_name='reviews')
    order = models.OneToOneField(Order, on_delete=models.CASCADE, related_name='review')
    reviewer = models.ForeignKey('users.User', on_delete=models.CASCADE, related_name='service_reviews')
    
    rating = models.IntegerField(verbose_name='التقييم')  # 1-5
    comment = models.TextField(verbose_name='التعليق', blank=True)
    
    # من المزود
    provider_response = models.TextField(blank=True)
    provider_responded_at = models.DateTimeField(null=True, blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name = 'تقييم'
        verbose_name_plural = 'التقييمات'
        unique_together = ['service', 'reviewer']
    
    def __str__(self):
        return f"{self.reviewer.name_ar} - {self.rating}★"
```

---

## ملخص العلاقات

```
Service
    ├── User (provider)
    ├── Order (1:N)
    │   ├── User (buyer)
    │   └── ServiceReview (1:1)
    └── ServiceReview (1:N)
```
