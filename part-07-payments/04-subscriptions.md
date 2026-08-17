# الاشتراكات والباقات (Subscriptions & Plans)

## نظرة عامة
تطبيق `apps/subscriptions` يدير الباقات والاشتراكات في المنصة بنظام مرن ومتعدد اللغات وبوابة دفع موحّدة (Stripe Checkout & MyFatoorah).

---

## النماذج (Models)

### 1. Plan (الباقة)
- **الحقول**:
  - `code`: كود الباقة (free, basic, pro, school, enterprise)
  - `name`: ترجمات JSON (ar, en, ...)
  - `description`: وصف الباقة
  - `price`: السعر (Decimal)
  - `currency`: العملة (افتراضي JOD)
  - `duration_days`: مدة الباقة بالأيام (مثلاً 30 للشهر، 365 للسنة)
  - `features`: قائمة ميزات الباقة
  - `is_active`: حالة التفعيل

### 2. Subscription (الاشتراك)
- **الحقول**:
  - `user`: مستخدم (FK)
  - `plan`: الباقة (FK)
  - `status`: الحالة (pending, active, expired, cancelled)
  - `start_date`: تاريخ البدء
  - `end_date`: تاريخ الانتهاء
  - `payment_provider`: مزوّد الدفع (stripe, myfatoorah)
  - `payment_session_id` / `payment_transaction_id`: معرّفات الدفع

---

## تدفق الشراء والاشتراك

```python
class SubscriptionService:
    @staticmethod
    def purchase_subscription(user, plan_id, request=None, locale='ar'):
        """شراء اشتراك أو تفعيله"""
        plan = Plan.objects.get(pk=plan_id)
        
        # إنشاء الاشتراك بحالة pending
        subscription = Subscription.objects.create(
            user=user,
            plan=plan,
            status='pending',
            start_date=timezone.now(),
            end_date=timezone.now() + timedelta(days=plan.duration_days)
        )
        
        if plan.price <= 0:
            subscription.status = 'active'
            subscription.save()
            user.subscription_plan = plan.code
            user.save(update_fields=['subscription_plan'])
            return {'status': 'active', 'message': 'تم تفعيل الباقة المجانية'}
            
        # استخدام بوابة الدفع الموحّدة (Stripe أو MyFatoorah)
        checkout_data = PaymentRegistry.get_provider().create_checkout(
            amount=plan.price,
            currency=plan.currency,
            success_url=f"/{locale}/subscriptions?session_id={{CHECKOUT_SESSION_ID}}",
            cancel_url=f"/{locale}/subscriptions",
            metadata={'kind': 'subscription', 'subscription_id': subscription.id},
            user=user
        )
        
        subscription.payment_provider = checkout_data.get('provider')
        subscription.payment_session_id = checkout_data.get('session_id')
        subscription.save()
        
        return checkout_data
```

---

## الـ Webhook ومعالجة التفعيل
عند إتمام الدفع بنجاح عبر Stripe أو MyFatoorah، يتحقق الـ Webhook من الـ metadata (النوع `subscription` ومعرّف الاشتراك)، ثم يستدعي دالة التفعيل لتحديث حالة الاشتراك إلى `active` وتحديث `user.subscription_plan = plan.code`.
