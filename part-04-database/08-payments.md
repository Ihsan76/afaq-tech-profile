# نماذج الدفع

## نموذج المعاملة

```python
class Transaction(models.Model):
    """المعاملة المالية"""
    
    class Type(models.TextChoices):
        PAYMENT = 'payment', 'دفعة'
        REFUND = 'refund', 'استرداد'
        WALLET_TOPUP = 'wallet_topup', 'شحن المحفظة'
        SUBSCRIPTION = 'subscription', 'اشتراك'
        PAYOUT = 'payout', 'صرف للمزود'
    
    class Status(models.TextChoices):
        PENDING = 'pending', 'قيد الانتظار'
        COMPLETED = 'completed', 'مكتمل'
        FAILED = 'failed', 'فشل'
        CANCELLED = 'cancelled', 'ملغي'
    
    class Provider(models.TextChoices):
        STRIPE = 'stripe', 'Stripe'
        PAYPAL = 'paypal', 'PayPal'
        PAYMOB = 'paymob', 'Paymob'
        WIDGET = 'widget', 'Widget'
        WALLET = 'wallet', 'المحفظة'
    
    # معلومات المعاملة
    transaction_id = models.CharField(max_length=100, unique=True)
    user = models.ForeignKey('users.User', on_delete=models.CASCADE, related_name='transactions')
    
    # النوع والمبلغ
    type = models.CharField(max_length=15, choices=Type.choices)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    currency = models.CharField(max_length=3, default='USD')
    
    # المزود
    provider = models.CharField(max_length=20, choices=Provider.choices)
    provider_ref = models.CharField(max_length=255, blank=True)
    provider_response = models.JSONField(default=dict, blank=True)
    
    # الحالة
    status = models.CharField(max_length=15, choices=Status.choices, default=Status.PENDING)
    
    # الارتباط
    order = models.ForeignKey('marketplace.Order', on_delete=models.SET_NULL, null=True, blank=True)
    subscription = models.ForeignKey('Subscription', on_delete=models.SET_NULL, null=True, blank=True)
    
    # Metadata
    metadata = models.JSONField(default=dict, blank=True)
    
    # التوقيت
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    completed_at = models.DateTimeField(null=True, blank=True)
    
    class Meta:
        verbose_name = 'معاملة'
        verbose_name_plural = 'المعاملات'
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.transaction_id} - {self.amount} {self.currency}"
```

---

## نموذج المحفظة

```python
class Wallet(models.Model):
    """محفظة المستخدم"""
    
    user = models.OneToOneField('users.User', on_delete=models.CASCADE, related_name='wallet')
    
    balance_usd = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    balance_jod = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    
    # الأرباح (للمزودين)
    earned_usd = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    pending_payout_usd = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name = 'محفظة'
        verbose_name_plural = 'المحافظ'
    
    def __str__(self):
        return f"{self.user.name_ar} - ${self.balance_usd}"
    
    def can_afford(self, amount):
        return self.balance_usd >= amount
    
    def deduct(self, amount):
        if self.can_afford(amount):
            self.balance_usd -= amount
            self.save()
            return True
        return False
    
    def add(self, amount):
        self.balance_usd += amount
        self.save()
```

---

## نموذج المعاملات اليومية

```python
class DailyTransaction(models.Model):
    """إحصائيات المعاملات اليومية"""
    
    date = models.DateField(unique=True)
    
    # عدد المعاملات
    total_transactions = models.IntegerField(default=0)
    successful_transactions = models.IntegerField(default=0)
    failed_transactions = models.IntegerField(default=0)
    
    # المبالغ
    total_revenue = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    total_refunds = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    net_revenue = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    
    # حسب النوع
    breakdown = models.JSONField(default=dict)
    # {"payment": {"count": 10, "amount": 500}, "refund": {"count": 2, "amount": 50}}
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name = 'معاملة يومية'
        verbose_name_plural = 'المعاملات اليومية'
    
    def __str__(self):
        return f"{self.date} - ${self.net_revenue}"
```

---

## نموذج اشتراك

```python
class Subscription(models.Model):
    """اشتراك المستخدم"""
    
    class Plan(models.TextChoices):
        FREE = 'free', 'مجاني'
        BASIC = 'basic', 'أساسي'
        PRO = 'pro', 'محترف'
        TEAM = 'team', 'فريق'
    
    class Status(models.TextChoices):
        ACTIVE = 'active', 'نشط'
        CANCELLED = 'cancelled', 'ملغي'
        EXPIRED = 'expires', 'منتهي'
        PAUSED = 'paused', 'متوقف'
    
    user = models.OneToOneField('users.User', on_delete=models.CASCADE, related_name='subscription')
    
    plan = models.CharField(max_length=10, choices=Plan.choices, default=Plan.FREE)
    status = models.CharField(max_length=15, choices=Status.choices, default=Status.ACTIVE)
    
    # التسعير
    price_usd = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    billing_period = models.CharField(max_length=10, default='monthly')  # monthly/yearly
    
    # الحدود
    ai_daily_limit = models.IntegerField(default=50)
    storage_limit_mb = models.IntegerField(default=500)
    
    # التوقيت
    started_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField(null=True, blank=True)
    cancelled_at = models.DateTimeField(null=True, blank=True)
    
    # التجديد
    auto_renew = models.BooleanField(default=True)
    last_billing_date = models.DateTimeField(null=True, blank=True)
    
    class Meta:
        verbose_name = 'اشتراك'
        verbose_name_plural = 'الاشتراكات'
    
    def __str__(self):
        return f"{self.user.name_ar} - {self.get_plan_display()}"
    
    @property
    def is_active(self):
        if self.status != self.Status.ACTIVE:
            return False
        if self.expires_at and self.expires_at < timezone.now():
            return False
        return True
```

---

## ملخص العلاقات

```
User
    ├── Transaction (1:N)
    ├── Wallet (1:1)
    └── Subscription (1:1)

Transaction
    ├── Order (M:1, optional)
    ├── Subscription (M:1, optional)
    └── Provider info (JSON)
```
