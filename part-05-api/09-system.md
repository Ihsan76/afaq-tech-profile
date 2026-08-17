# APIs النظام

## Base URL
```
/api/v1/
```

---

## GET /api/v1/health/

**فحص صحة النظام**

### Response (200)
```json
{
  "status": "healthy",
  "timestamp": "2025-01-15T10:00:00Z",
  "version": "1.0.0",
  "services": {
    "database": "ok",
    "redis": "ok",
    "ai": "ok"
  }
}
```

---

## GET /api/v1/config/

**إعدادات الواجهة**

### Response (200)
```json
{
  "app_name": "آفاق تكنولوجي",
  "version": "1.0.0",
  "supported_languages": ["ar", "en"],
  "default_language": "ar",
  "ai_providers": ["gemini", "openai", "claude"],
  "payment_providers": ["stripe", "paypal"]
}
```

---

## POST /api/v1/upload/

**رفع ملف**

### Request
```
Content-Type: multipart/form-data
file: <binary>
usage_type: avatar/course_thumbnail/blog_image
```

### Response (200)
```json
{
  "id": 1,
  "url": "https://storage.afaq.app/media/2025/01/file.jpg",
  "file_type": "image",
  "file_size": 1024000,
  "width": 800,
  "height": 600
}
```

---

## POST /api/v1/notifications/mark-read/

**تحديد الإشعارات كمقروءة**

### Request
```json
{
  "notification_ids": [1, 2, 3]
}
```

### Response (200)
```json
{
  "message": "تم تحديد الإشعارات كمقروءة."
}
```

---

## GET /api/v1/notifications/

**جلب الإشعارات**

### Response (200)
```json
{
  "count": 25,
  "unread_count": 5,
  "results": [
    {
      "id": 1,
      "type": "ai",
      "title": "تم توليد خطة الدرس",
      "message": "خطة درس رياضيات جاهزة",
      "is_read": false,
      "action_url": "/teacher/lesson-plans/1",
      "created_at": "2025-01-15T10:00:00Z"
    }
  ]
}
```

---

## POST /api/v1/newsletter/subscribe/

**الاشتراك في النشرة البريدية**

### Request
```json
{
  "email": "user@example.com"
}
```

### Response (201)
```json
{
  "message": "تم الاشتراك بنجاح."
}
```

---

## POST /api/v1/newsletter/unsubscribe/

**إلغاء الاشتراك**

### Request
```json
{
  "email": "user@example.com"
}
```

---

## POST /api/v1/contact/

**نموذج التواصل**

### Request
```json
{
  "name": "محمد أحمد",
  "email": "user@example.com",
  "subject": "استفسار",
  "message": "أريد معرفة المزيد عن المنصة"
}
```

### Response (201)
```json
{
  "message": "تم إرسال رسالتك. سنتواصل معك قريباً."
}
```

---

## GET /api/v1/landing-pages/{slug}/

**جلب صفحة هبوط**

### Response (200)
```json
{
  "id": 1,
  "title": "آفاق للمعلم",
  "blocks": [
    {
      "block_type": "hero",
      "title": "المساعد الذكي للمعلم",
      "content": "...",
      "data": {
        "cta_text": "ابدأ الآن",
        "cta_url": "/register"
      }
    },
    {
      "block_type": "features",
      "data": [
        {"icon": "...", "title": "...", "description": "..."}
      ]
    }
  ]
}
```

---

## POST /api/v1/landing-pages/{slug}/forms/{form_id}/submit/

**تقديم نموذج صفحة هبوط**

### Request
```json
{
  "email": "lead@example.com",
  "name": "عميل محتمل",
  "phone": "+962791234567"
}
```

### Response (201)
```json
{
  "message": "شكراً لتواصلك معنا."
}
```
