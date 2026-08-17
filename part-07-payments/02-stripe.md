# تكامل Stripe

## الإعداد

```python
# settings.py
STRIPE_PUBLIC_KEY = env('STRIPE_PUBLIC_KEY')
STRIPE_SECRET_KEY = env('STRIPE_SECRET_KEY')
STRIPE_WEBHOOK_SECRET = env('STRIPE_WEBHOOK_SECRET')
STRIPE_CURRENCY = 'usd'
```

---

## إنشاء Payment Intent

```python
# services/stripe_service.py
import stripe
from django.conf import settings

stripe.api_key = settings.STRIPE_SECRET_KEY

class StripeService:
    
    @staticmethod
    def create_payment_intent(amount: int, currency: str = 'usd', metadata: dict = None):
        """
        إنشاء Payment Intent
        amount: المبلغ بال센تات (1000 = $10)
        """
        try:
            intent = stripe.PaymentIntent.create(
                amount=amount,
                currency=currency,
                metadata=metadata or {},
                automatic_payment_methods={'enabled': True},
            )
            return {
                'client_secret': intent.client_secret,
                'payment_intent_id': intent.id
            }
        except stripe.error.StripeError as e:
            raise Exception(f"Stripe error: {str(e)}")
    
    @staticmethod
    def create_subscription(price_id: str, customer_email: str):
        """إنشاء اشتراك"""
        try:
            # إنشاء عميل
            customer = stripe.Customer.create(
                email=customer_email,
            )
            
            # إنشاء الاشتراك
            subscription = stripe.Subscription.create(
                customer=customer.id,
                items=[{'price': price_id}],
                payment_behavior='default_incomplete',
                expand=['latest_invoice.payment_intent'],
            )
            
            return {
                'subscription_id': subscription.id,
                'client_secret': subscription.latest_invoice.payment_intent.client_secret
            }
        except stripe.error.StripeError as e:
            raise Exception(f"Stripe error: {str(e)}")
    
    @staticmethod
    def cancel_subscription(subscription_id: str):
        """إلغاء اشتراك"""
        try:
            stripe.Subscription.delete(subscription_id)
            return True
        except stripe.error.StripeError as e:
            raise Exception(f"Stripe error: {str(e)}")
    
    @staticmethod
    def create_refund(payment_intent_id: str):
        """استرداد المبلغ"""
        try:
            refund = stripe.Refund.create(
                payment_intent=payment_intent_id,
            )
            return refund
        except stripe.error.StripeError as e:
            raise Exception(f"Stripe error: {str(e)}")
```

---

## Webhook

```python
# views/webhook.py
from django.http import HttpResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST
import stripe
from django.conf import settings

@csrf_exempt
@require_POST
def stripe_webhook(request):
    payload = request.body
    sig_header = request.META.get('HTTP_STRIPE_SIGNATURE')
    
    try:
        event = stripe.Webhook.construct_event(
            payload, sig_header, settings.STRIPE_WEBHOOK_SECRET
        )
    except ValueError:
        return HttpResponse(status=400)
    except stripe.error.SignatureVerificationError:
        return HttpResponse(status=400)
    
    # معالجة الأحداث
    if event['type'] == 'payment_intent.succeeded':
        handle_payment_success(event['data']['object'])
    elif event['type'] == 'payment_intent.payment_failed':
        handle_payment_failure(event['data']['object'])
    elif event['type'] == 'invoice.paid':
        handle_invoice_paid(event['data']['object'])
    elif event['type'] == 'customer.subscription.deleted':
        handle_subscription_deleted(event['data']['object'])
    
    return HttpResponse(status=200)

def handle_payment_success(payment_intent):
    """معالجة الدفع الناجح"""
    from payments.models import Transaction
    
    transaction = Transaction.objects.get(
        provider_ref=payment_intent['id']
    )
    transaction.status = 'completed'
    transaction.completed_at = timezone.now()
    transaction.save()
    
    # تحديث المحفظة
    if transaction.type == 'wallet_topup':
        wallet = transaction.user.wallet
        wallet.balance_usd += transaction.amount
        wallet.save()
    
    # إشعار
    Notification.objects.create(
        user=transaction.user,
        type='payment',
        title='تم الدفع بنجاح',
        message=f'تم دفع {transaction.amount} {transaction.currency}'
    )

def handle_payment_failure(payment_intent):
    """معالجة فشل الدفع"""
    from payments.models import Transaction
    
    transaction = Transaction.objects.get(
        provider_ref=payment_intent['id']
    )
    transaction.status = 'failed'
    transaction.save()
    
    # إشعار
    Notification.objects.create(
        user=transaction.user,
        type='payment',
        title='فشل الدفع',
        message='لم يتم إتمام عملية الدفع. يرجى المحاولة مرة أخرى.'
    )
```

---

## URLs

```python
# urls.py
urlpatterns = [
    path('webhook/stripe/', webhook.stripe_webhook, name='stripe-webhook'),
]
```
