# APIs السوق

## Base URL
```
/api/v1/marketplace/
```

---

## GET /api/v1/marketplace/services/

**جلب الخدمات المتاحة**

### Query Parameters
- `category`: lesson_plan/course/workshop/consultation/tutoring/digital_product
- `min_price`: الحد الأدنى للسعر
- `max_price`: الحد الأقصى للسعر
- `rating`: الحد الأدنى للتقييم
- `search`: بحث بالعنوان
- `ordering`: -created_at/price/rating/-order_count
- `page`: رقم الصفحة

### Response (200)
```json
{
  "count": 100,
  "results": [
    {
      "id": 1,
      "title": "خطة درس متكاملة في الرياضيات",
      "slug": "math-lesson-plan",
      "category": "lesson_plan",
      "provider": {
        "id": 5,
        "name_ar": "أحمد محمد",
        "rating": 4.8
      },
      "price": 5,
      "currency": "USD",
      "thumbnail": "https://...",
      "rating": 4.7,
      "review_count": 50,
      "order_count": 120
    }
  ]
}
```

---

## GET /api/v1/marketplace/services/{slug}/

**جلب تفاصيل الخدمة**

### Response (200)
```json
{
  "id": 1,
  "title": "خطة درس متكاملة في الرياضيات",
  "slug": "math-lesson-plan",
  "description": "...",
  "category": "lesson_plan",
  "provider": {
    "id": 5,
    "name_ar": "أحمد محمد",
    "avatar": "https://...",
    "rating": 4.8,
    "services_count": 10
  },
  "price": 5,
  "currency": "USD",
  "thumbnail": "https://...",
  "images": ["https://..."],
  "rating": 4.7,
  "review_count": 50,
  "order_count": 120,
  "reviews": [
    {
      "id": 1,
      "reviewer": {"name_ar": "محمد", "avatar": "..."},
      "rating": 5,
      "comment": "خدمة ممتازة"
    }
  ],
  "created_at": "2025-01-01T00:00:00Z"
}
```

---

## POST /api/v1/marketplace/orders/

**إنشاء طلب شراء**

### Request
```json
{
  "service": 1,
  "notes": "أحتاج خطة درس للصف الثالث"
}
```

### Response (201)
```json
{
  "id": 1,
  "order_number": "ORD-2025-001",
  "amount": 5,
  "currency": "USD",
  "platform_fee": 0.5,
  "provider_amount": 4.5,
  "status": "pending",
  "message": "تم إنشاء الطلب. يرجى إتمام الدفع."
}
```

---

## GET /api/v1/marketplace/orders/my-orders/

**طلباتي (كمشتري)**

### Response (200)
```json
{
  "count": 5,
  "results": [
    {
      "id": 1,
      "order_number": "ORD-2025-001",
      "service": {"title": "...", "thumbnail": "..."},
      "amount": 5,
      "status": "completed",
      "created_at": "2025-01-15T10:00:00Z"
    }
  ]
}
```

---

## PUT /api/v1/marketplace/orders/{id}/complete/

**إكمال الطلب (للمزود)**

### Response (200)
```json
{
  "message": "تم إكمال الطلب."
}
```

---

## POST /api/v1/marketplace/orders/{id}/rate/

**تقييم الطلب**

### Request
```json
{
  "rating": 5,
  "comment": "خدمة ممتازة وسريعة"
}
```

---

## APIs المزود

### POST /api/v1/marketplace/services/
**إضافة خدمة جديدة**

### PUT /api/v1/marketplace/services/{id}/
**تحديث الخدمة**

### GET /api/v1/marketplace/provider/dashboard/
**لوحة تحكم المزود**
