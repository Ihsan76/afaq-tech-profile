# رسوم السوق

## نموذج الرسوم

### للمشتري
- **رسوم الخدمة**: لا توجد (تُضاف للسعر)
- **رسوم مزود الدفع**: 2.9% + $0.30 (يتحملها المشتري)

### للمزود
- **رسوم المنصة**: 10% من كل صفقة
- **رسوم السحب**: $2 لكل سحب

---

## حساب الرسوم

```python
class FeeCalculator:
    
    PLATFORM_FEE_RATE = Decimal('0.10')  # 10%
    WITHDRAWAL_FEE = Decimal('2.00')  # $2
    PAYMENT_PROVIDER_FEE_RATE = Decimal('0.029')  # 2.9%
    PAYMENT_PROVIDER_FIXED_FEE = Decimal('0.30')  # $0.30
    
    @classmethod
    def calculate_order_fees(cls, amount):
        """حساب رسوم الطلب"""
        platform_fee = amount * cls.PLATFORM_FEE_RATE
        provider_amount = amount - platform_fee
        
        return {
            'amount': amount,
            'platform_fee': platform_fee,
            'provider_amount': provider_amount,
            'total_with_payment_fees': amount + (amount * cls.PAYMENT_PROVIDER_FEE_RATE + cls.PAYMENT_PROVIDER_FIXED_FEE)
        }
    
    @classmethod
    def calculate_withdrawal_fee(cls, amount):
        """حساب رسوم السحب"""
        return {
            'amount': amount,
            'withdrawal_fee': cls.WITHDRAWAL_FEE,
            'net_amount': amount - cls.WITHDRAWAL_FEE
        }
```

---

## أمثلة

### شراء خدمة بـ $10
```
سعر الخدمة:           $10.00
رسوم المنصة (10%):     $1.00
رسوم الدفع (2.9%+0.30): $0.59
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
الإجمالي للمشتري:      $10.59
الأرباح للمزود:        $9.00
```

### سحب $100
```
المبلغ:                $100.00
رسوم السحب:            $2.00
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
صافي السحب:           $98.00
```

---

## جدول المقارنة

| الميزة | مجاني | أساسي | محترف | فريق |
|--------|-------|-------|-------|------|
| رسم المنصة | 10% | 10% | 8% | 5% |
| حد الخدمات | 0 | 5 | غير محدود | غير محدود |
| حد السحب/شهر | - | $500 | $2000 | غير محدود |
| أولوية السحب | - | عادي | سريع | فوري |
