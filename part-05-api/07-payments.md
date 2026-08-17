# APIs الدفع

## Base URL
```
/api/v1/payments/
```

---

## GET /api/v1/payments/wallet/

**جلب رصيد المحفظة**

### Headers
```
Authorization: Bearer <access_token>
```

### Response (200)
```json
{
  "balance_usd": 25.50,
  "balance_jod": 18.00,
  "earned_usd": 150.00,
  "pending_payout_usd": 30.00
}
```

---

## POST /api/v1/payments/wallet/topup/

**شحن المحفظة**

### Request
```json
{
  "amount": 20,
  "currency": "USD",
  "provider": "stripe"
}
```

### Response (201)
```json
{
  "transaction_id": "TXN-2025-001",
  "client_secret": "pi_xxx...",
  "message": "يرجى إتمام الدفع."
}
```

---

## GET /api/v1/payments/transactions/

**سجل المعاملات**

### Query Parameters
- `type`: payment/refund/wallet_topup/subscription/payout
- `status`: pending/completed/failed
- `from_date`: تاريخ البداية
- `to_date`: تاريخ النهاية
- `page`: رقم الصفحة

### Response (200)
```json
{
  "count": 50,
  "results": [
    {
      "id": 1,
      "transaction_id": "TXN-2025-001",
      "type": "payment",
      "amount": 15,
      "currency": "USD",
      "provider": "stripe",
      "status": "completed",
      "created_at": "2025-01-15T10:00:00Z"
    }
  ]
}
```

---

## GET /api/v1/payments/transactions/{id}/

**تفاصيل المعاملة**

### Response (200)
```json
{
  "id": 1,
  "transaction_id": "TXN-2025-001",
  "type": "payment",
  "amount": 15,
  "currency": "USD",
  "provider": "stripe",
  "provider_ref": "pi_xxx",
  "status": "completed",
  "order": {
    "id": 1,
    "order_number": "ORD-2025-001"
  },
  "metadata": {},
  "created_at": "2025-01-15T10:00:00Z"
}
```

---

## POST /api/v1/payments/webhook/stripe/

**Webhook من Stripe**

### Request
```json
{
  "type": "payment_intent.succeeded",
  "data": {
    "object": {
      "id": "pi_xxx",
      "amount": 1500,
      "status": "succeeded"
    }
  }
}
```

---

## GET /api/v1/payments/subscriptions/

**الاشتراكات المتاحة**

### Response (200)
```json
[
  {
    "id": "free",
    "name": "مجاني",
    "price_usd": 0,
    "billing_period": "monthly",
    "features": [
      "50 طلب AI يومياً",
      "خطة درس واحدة يومياً",
      "لوحة تحكم أساسية"
    ]
  },
  {
    "id": "basic",
    "name": "أساسي",
    "price_usd": 5,
    "billing_period": "monthly",
    "features": [
      "100 طلب AI يومياً",
      "خطط دروس غير محدودة",
      "تصدير PDF"
    ]
  }
]
```

---

## POST /api/v1/payments/subscriptions/subscribe/

**الاشتراك في باقة**

### Request
```json
{
  "plan": "pro",
  "billing_period": "yearly",
  "payment_method": "stripe"
}
```

### Response (201)
```json
{
  "subscription_id": "SUB-2025-001",
  "plan": "pro",
  "status": "active",
  "expires_at": "2026-01-15T00:00:00Z",
  "message": "تم الاشتراك بنجاح."
}
```

---

## POST /api/v1/payments/subscriptions/cancel/

**إلغاء الاشتراك**

### Response (200)
```json
{
  "message": "تم إلغاء الاشتراك. سيكون نشطاً حتى تاريخ الانتهاء.",
  "expires_at": "2025-02-15T00:00:00Z"
}
```

---

## POST /api/v1/payments/refund/

**طلب استرداد**

### Request
```json
{
  "transaction_id": "TXN-2025-001",
  "reason": "الخدمة لم تلبي التوقعات"
}
```

### Response (200)
```json
{
  "message": "تم تقديم طلب الاسترداد. سيتم مراجعته خلال 24 ساعة."
}
```
