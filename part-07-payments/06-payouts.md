# السحب للمزودين

## تدفق السحب

```
المزود → طلب سحب → فحص الرصيد → خصم الرسوم → معالجة الدفع → تأكيد → إشعار
```

---

## إعداد السحب

```python
class PayoutService:
    
    MINIMUM_PAYOUT = Decimal('10.00')  # الحد الأدنى للسحب: $10
    PAYOUT_FEE = Decimal('2.00')  # رسوم السحب: $2
    
    @classmethod
    def request_payout(cls, user, amount):
        """طلب سحب"""
        wallet = user.wallet
        
        # فحص الحد الأدنى
        if amount < cls.MINIMUM_PAYOUT:
            raise ValueError(f"الحد الأدنى للسحب هو ${cls.MINIMUM_PAYOUT}")
        
        # فحص الرصيد الكافي
        if wallet.pending_payout_usd < amount:
            raise ValueError("الرصيد غير كافٍ")
        
        # حساب الصافي
        net_amount = amount - cls.PAYOUT_FEE
        
        # إنشاء معاملة سحب
        transaction = Transaction.objects.create(
            transaction_id=generate_transaction_id(),
            user=user,
            type='payout',
            amount=amount,
            currency='USD',
            provider='stripe',
            status='pending',
            metadata={
                'net_amount': str(net_amount),
                'fee': str(cls.PAYOUT_FEE)
            }
        )
        
        # خصم من المحفظة
        wallet.pending_payout_usd -= amount
        wallet.save()
        
        return transaction
    
    @classmethod
    def process_payout(cls, transaction_id):
        """معالجة السحب"""
        transaction = Transaction.objects.get(transaction_id=transaction_id)
        
        # تحويل عبر Stripe Connect
        try:
            transfer = stripe.Transfer.create(
                amount=int(transaction.amount * 100),
                currency='usd',
                destination=transaction.user.stripe_account_id,
                transfer_group=transaction_id
            )
            
            transaction.status = 'completed'
            transaction.completed_at = timezone.now()
            transaction.provider_ref = transfer.id
            transaction.save()
            
            return True
        except Exception as e:
            transaction.status = 'failed'
            transaction.metadata['error'] = str(e)
            transaction.save()
            return False
```

---

## Stripe Connect للمزودين

```python
class StripeConnectService:
    
    @staticmethod
    def create_connected_account(user):
        """إنشاء حساب مزود"""
        try:
            account = stripe.Account.create(
                type='express',
                email=user.email,
                capabilities={
                    'card_payments': {'requested': True},
                    'transfers': {'requested': True},
                },
                metadata={'user_id': user.id}
            )
            
            user.stripe_account_id = account.id
            user.save()
            
            return account
        except Exception as e:
            raise Exception(f"Failed to create account: {str(e)}")
    
    @staticmethod
    def create_account_link(account_id):
        """إنشاء رابط التأكيد"""
        try:
            account_link = stripe.AccountLink.create(
                account=account_id,
                refresh_url=f'{settings.FRONTEND_URL}/settings/billing',
                return_url=f'{settings.FRONTEND_URL}/settings/billing',
                type='account_onboarding',
            )
            return account_link.url
        except Exception as e:
            raise Exception(f"Failed to create link: {str(e)}")
```

---

## إعدادات السحب

```python
class PayoutSettings(models.Model):
    """إعدادات السحب للمزود"""
    
    user = models.OneToOneField('users.User', on_delete=models.CASCADE)
    
    # Stripe
    stripe_account_id = models.CharField(max_length=255, blank=True)
    stripe_onboarding_complete = models.BooleanField(default=False)
    
    # إعدادات
    auto_payout = models.BooleanField(default=False)
    auto_payout_threshold = models.DecimalField(max_digits=10, decimal_places=2, default=50)
    auto_payout_schedule = models.CharField(max_length=10, default='weekly')
    # weekly, biweekly, monthly
    
    # حدود
    minimum_payout = models.DecimalField(max_digits=10, decimal_places=2, default=10)
    maximum_payout = models.DecimalField(max_digits=10, decimal_places=2, default=10000)
    
    class Meta:
        verbose_name = 'إعداد سحب'
        verbose_name_plural = 'إعدادات السحب'
```

---

## جدول السحوبات

```python
class PayoutSchedule(models.Model):
    """جدول السحوبات"""
    
    user = models.ForeignKey('users.User', on_delete=models.CASCADE)
    
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    fee = models.DecimalField(max_digits=10, decimal_places=2, default=2)
    net_amount = models.DecimalField(max_digits=10, decimal_places=2)
    
    status = models.CharField(max_length=15, choices=[
        ('scheduled', 'مجدول'),
        ('processing', 'قيد المعالجة'),
        ('completed', 'مكتمل'),
        ('failed', 'فشل')
    ])
    
    scheduled_date = models.DateField()
    processed_date = models.DateField(null=True, blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name = 'سحب مجدول'
        verbose_name_plural = 'السحب المجدولة'
```
