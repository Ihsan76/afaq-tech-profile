# المحفظة والمعاملات

## المحفظة

### نموذج المحفظة

```python
class Wallet(models.Model):
    user = models.OneToOneField('users.User', on_delete=models.CASCADE, related_name='wallet')
    
    balance_usd = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    balance_jod = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    
    earned_usd = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    pending_payout_usd = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    
    updated_at = models.DateTimeField(auto_now=True)
    
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

## المعاملات

### إنشاء معاملة

```python
class TransactionService:
    
    @staticmethod
    def create_transaction(user, type, amount, currency='USD', provider='stripe', **kwargs):
        """إنشاء معاملة جديدة"""
        transaction = Transaction.objects.create(
            transaction_id=generate_transaction_id(),
            user=user,
            type=type,
            amount=amount,
            currency=currency,
            provider=provider,
            status='pending',
            **kwargs
        )
        return transaction
    
    @staticmethod
    def complete_transaction(transaction_id):
        """إكمال معاملة"""
        transaction = Transaction.objects.get(transaction_id=transaction_id)
        transaction.status = 'completed'
        transaction.completed_at = timezone.now()
        transaction.save()
        
        # تحديث المحفظة
        if transaction.type == 'wallet_topup':
            wallet = transaction.user.wallet
            wallet.add(transaction.amount)
        
        return transaction
    
    @staticmethod
    def refund_transaction(transaction_id, reason=''):
        """استرداد معاملة"""
        transaction = Transaction.objects.get(transaction_id=transaction_id)
        
        # إنشاء معاملة استرداد
        refund = Transaction.objects.create(
            transaction_id=generate_transaction_id(),
            user=transaction.user,
            type='refund',
            amount=transaction.amount,
            currency=transaction.currency,
            provider=transaction.provider,
            status='completed',
            metadata={'original_transaction': transaction_id, 'reason': reason}
        )
        
        # خصم من المحفظة
        wallet = transaction.user.wallet
        wallet.deduct(transaction.amount)
        
        return refund
```

---

## توليد رقم المعاملة

```python
import uuid
from datetime import datetime

def generate_transaction_id():
    """توليد رقم معاملة فريد"""
    timestamp = datetime.now().strftime('%Y%m%d')
    unique = uuid.uuid4().hex[:8].upper()
    return f"TXN-{timestamp}-{unique}"
```

---

## سجل المعاملات

### API

```python
class TransactionListView(generics.ListAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = TransactionSerializer
    
    def get_queryset(self):
        queryset = Transaction.objects.filter(user=self.request.user)
        
        # فلترة حسب النوع
        type = self.request.query_params.get('type')
        if type:
            queryset = queryset.filter(type=type)
        
        # فلترة حسب الحالة
        status = self.request.query_params.get('status')
        if status:
            queryset = queryset.filter(status=status)
        
        # فلترة حسب التاريخ
        from_date = self.request.query_params.get('from_date')
        to_date = self.request.query_params.get('to_date')
        if from_date:
            queryset = queryset.filter(created_at__gte=from_date)
        if to_date:
            queryset = queryset.filter(created_at__lte=to_date)
        
        return queryset.order_by('-created_at')
```

---

## الإشعارات

```python
def send_payment_notification(user, transaction):
    """إرسال إشعار الدفع"""
    if transaction.status == 'completed':
        Notification.objects.create(
            user=user,
            type='payment',
            title='تم الدفع بنجاح',
            message=f'تم {transaction.get_type_display()} بقيمة {transaction.amount} {transaction.currency}',
            action_url='/settings/billing'
        )
    elif transaction.status == 'failed':
        Notification.objects.create(
            user=user,
            type='payment',
            title='فشل الدفع',
            message='لم يتم إتمام عملية الدفع. يرجى المحاولة مرة أخرى.',
            priority='high'
        )
```
