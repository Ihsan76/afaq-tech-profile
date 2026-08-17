# APIs الدورات التدريبية

## Base URL
```
/api/v1/courses/
```

---

## GET /api/v1/courses/

**جلب الدورات المتاحة**

### Query Parameters
- `subject`: معرف المادة
- `grade`: معرف المرحلة
- `price`: free/paid
- `search`: بحث بالعنوان
- `ordering`: -created_at/price/rating
- `page`: رقم الصفحة

### Response (200)
```json
{
  "count": 50,
  "results": [
    {
      "id": 1,
      "title": "أساسيات الرياضيات",
      "slug": "math-basics",
      "description": "دورة شاملة في أساسيات الرياضيات",
      "instructor": {
        "id": 5,
        "name_ar": "أحمد محمد",
        "avatar": "https://..."
      },
      "subject": {"id": 1, "name_ar": "رياضيات"},
      "price": 0,
      "currency": "USD",
      "thumbnail": "https://...",
      "rating": 4.5,
      "review_count": 120,
      "enrollment_count": 500,
      "is_free": true
    }
  ]
}
```

---

## GET /api/v1/courses/{slug}/

**جلب تفاصيل الدورة**

### Response (200)
```json
{
  "id": 1,
  "title": "أساسيات الرياضيات",
  "slug": "math-basics",
  "description": "...",
  "short_description": "...",
  "instructor": {
    "id": 5,
    "name_ar": "أحمد محمد",
    "bio": "...",
    "avatar": "https://..."
  },
  "subject": {"id": 1, "name_ar": "رياضيات"},
  "grade": {"id": 3, "name_ar": "صف الثالث"},
  "price": 0,
  "currency": "USD",
  "thumbnail": "https://...",
  "promo_video": "https://...",
  "chapters": [
    {
      "id": 1,
      "title": "الفصل الأول: المقدمة",
      "lessons": [
        {
          "id": 1,
          "title": "مقدمة في الرياضيات",
          "lesson_type": "video",
          "video_duration": 600,
          "is_preview": true
        }
      ]
    }
  ],
  "rating": 4.5,
  "review_count": 120,
  "enrollment_count": 500,
  "is_enrolled": false,
  "created_at": "2025-01-01T00:00:00Z"
}
```

---

## POST /api/v1/courses/{id}/enroll/

**التسجيل في الدورة**

### Response (201)
```json
{
  "id": 1,
  "status": "active",
  "progress": 0,
  "message": "تم التسجيل بنجاح."
}
```

---

## GET /api/v1/courses/my-courses/

**جلب دوراتي المسجلة**

### Response (200)
```json
{
  "count": 3,
  "results": [
    {
      "id": 1,
      "course": {
        "id": 1,
        "title": "أساسيات الرياضيات",
        "thumbnail": "https://..."
      },
      "status": "active",
      "progress": 45,
      "last_accessed": "2025-01-15T10:00:00Z"
    }
  ]
}
```

---

## POST /api/v1/courses/{id}/lessons/{lesson_id}/complete/

**إكمال درس**

### Response (200)
```json
{
  "progress": 50,
  "completed_lessons": 5,
  "total_lessons": 10,
  "message": "تم تسجيل الإكمال."
}
```

---

## POST /api/v1/courses/{id}/rate/

**تقييم الدورة**

### Request
```json
{
  "rating": 5,
  "review": "دورة ممتازة ومفيدة جداً"
}
```

### Response (201)
```json
{
  "message": "شكراً لتقييمك."
}
```

---

## APIs المدرب (Instructor)

### POST /api/v1/courses/
**إنشاء دورة جديدة**

### PUT /api/v1/courses/{id}/
**تحديث الدورة**

### POST /api/v1/courses/{id}/chapters/
**إضافة فصل**

### POST /api/v1/courses/{id}/chapters/{chapter_id}/lessons/
**إضافة درس**
