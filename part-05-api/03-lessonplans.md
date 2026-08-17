# APIs خطط الدروس — مُنفّذة ✅

## Base URL
```
/api/v1/lesson-plans/
```

---

## GET /api/v1/lesson-plans/ — مُنفّذ ✅

**جلب خطط الدروس (للمستخدم الحالي فقط)**

### Headers
```
Authorization: Bearer <access_token>
```

### Response (200)
```json
{
  "count": 25,
  "results": [
    {
      "id": 1,
      "title": "خطة درس: الأعداد الطبيعية",
      "subject": 1,
      "grade": 3,
      "plan_data": {},
      "generated_by": "ai",
      "ai_model_used": "gemini-2.0-flash",
      "status": "draft",
      "is_public": false,
      "created_at": "2025-01-15T10:30:00Z",
      "updated_at": "2025-01-15T10:30:00Z"
    }
  ]
}
```

---

## POST /api/v1/lesson-plans/generate/ — مُنفّذ ✅

**توليد خطة درس بالذكاء الاصطناعي**  
منح +10 نقاط وشارة "pro_creator" بعد 5 خطط.

### Request
```json
{
  "title": "الأعداد الطبيعية",
  "prompt": "التركيز على العمليات الأساسية",
  "subject": 1,
  "grade": 3,
  "language": "ar",
  "model_id": null
}
```

### Response (201)
```json
{
  "id": 1,
  "title": "خطة درس: الأعداد الطبيعية",
  "subject": 1,
  "grade": 3,
  "plan_data": {
    "objectives": ["هدف1", "هدف2"],
    "materials_needed": ["سبورة", "أقلام"],
    "introduction": "نص المقدمة",
    "main_activity": [{"step": 1, "title": "...", "description": "...", "duration_minutes": 15}],
    "assessment": "وصف التقييم",
    "homework": "وصف الواجب",
    "estimated_duration": 45,
    "teaching_methods": ["طريقة1"],
    "tags": ["tag1"]
  },
  "generated_by": "ai",
  "ai_model_used": "gemini-2.0-flash",
  "status": "draft",
  "is_public": false,
  "subject_name": "رياضيات",
  "grade_name": "الصف الثالث",
  "user_name": "أحمد",
  "created_at": "2025-01-15T10:30:00Z",
  "updated_at": "2025-01-15T10:30:00Z"
}
```

> **ملاحظة:** `subject_name` و `grade_name` و `user_name` محسوبة آنياً حسب لغة الطلب (`request.LANGUAGE_CODE`).

---

## GET /api/v1/lesson-plans/{id}/ — مُنفّذ ✅

**جلب تفاصيل خطة درس**

### Response (200)
```json
{
  "id": 1,
  "title": "خطة درس: الأعداد الطبيعية",
  "subject": 1,
  "grade": 3,
  "plan_data": { "...": "..." },
  "generated_by": "ai",
  "ai_model_used": "gemini-2.0-flash",
  "status": "draft",
  "is_public": false,
  "subject_name": "رياضيات",
  "grade_name": "الصف الثالث",
  "user_name": "أحمد",
  "created_at": "2025-01-15T10:30:00Z",
  "updated_at": "2025-01-15T10:30:00Z"
}
```

---

## DELETE /api/v1/lesson-plans/{id}/delete/ — مُنفّذ ✅

**حذف خطة درس (المالك أو المشرف فقط)**

### Headers
```
Authorization: Bearer <access_token>
```

### Response (204)
```json
{
  "detail": "تم حذف الخطة بنجاح"
}
```

---

## POST /api/v1/lesson-plans/{id}/duplicate/ — مُنفّذ ✅

**نسخ خطة درس**

### Response (201)
```json
{
  "id": 2,
  "title": "خطة درس: الأعداد الطبيعية (نسخة)",
  "...": "..."
}
```

---

## POST /api/v1/lesson-plans/{id}/refine/ — مُنفّذ ✅ (جديد)

**تعديل خطة درس عبر الذكاء الاصطناعي (محادثة)**  
المالك أو المشرف فقط. يُنشئ سجل `LessonPlanRefinement`.

### Request
```json
{
  "prompt": "اجعل الأنشطة أكثر تفاعلية للطلاب الصغار",
  "language": "ar",
  "model_id": null
}
```

### Response (200)
```json
{
  "id": 1,
  "title": "خطة درس: الأعداد الطبيعية",
  "plan_data": { "...": "البيانات المحدّثة" },
  "...": "..."
}
```

---

## POST /api/v1/lesson-plans/{id}/worksheet/ — مُنفّذ ✅ (جديد)

**توليد ورقة عمل للخطة (المالك أو المشرف فقط)**  
يُخزّن في `plan_data.worksheet`.

### Response (200)
```json
{
  "...": "...",
  "plan_data": {
    "...": "...",
    "worksheet": {
      "title": "ورقة عمل",
      "instructions": "أجب عن الأسئلة التالية",
      "exercises": [
        {"question": "ما هو مجموع 2+2؟", "options": ["3", "4", "5", "6"], "answer": "4"}
      ]
    }
  }
}
```

---

## POST /api/v1/lesson-plans/{id}/homework/ — مُنفّذ ✅ (جديد)

**توليد واجب منزلي للخطة (المالك أو المشرف فقط)**  
يُخزّن في `plan_data.homework_assignment`.

### Response (200)
```json
{
  "...": "...",
  "plan_data": {
    "...": "...",
    "homework_assignment": {
      "homework_title": "الواجب المنزلي",
      "instructions": "حل التمارين التالية",
      "tasks": [
        {"task_number": 1, "description": "حل المسألة الأولى"}
      ]
    }
  }
}
```

---

## POST /api/v1/lesson-plans/{id}/toggle-public/ — مُنفّذ ✅ (جديد)

**تبديل المشاركة العامة (المالك أو المشرف فقط)**  
إذا كانت الخطة `draft` وتم تفعيل المشاركة → تُنشر تلقائياً.

### Response (200)
```json
{
  "is_public": true,
  "status": "published"
}
```

---

## POST /api/v1/lesson-plans/{id}/clone/ — مُنفّذ ✅ (جديد)

**استنساخ خطة من السوق**  
يزيد `clones_count` للخطة الأصلية.

### Response (201)
```json
{
  "id": 2,
  "title": "خطة درس: الأعداد الطبيعية (مستنسخة)",
  "...": "..."
}
```

---

## POST /api/v1/lesson-plans/{id}/like/ — مُنفّذ ✅ (جديد)

**إعجاب بخطة في السوق**  
يزيد `likes_count`.

### Response (200)
```json
{
  "likes_count": 10
}
```

---

## GET /api/v1/lesson-plans/marketplace/ — مُنفّذ ✅ (جديد)

**جلب الخطط العامة (السوق)**  
يعيد الخطط ذات `is_public=True` و `status=published` مرتبة حسب `-likes_count`.

### Response (200)
```json
{
  "count": 10,
  "results": [
    {
      "id": 1,
      "title": "خطة درس: الأعداد الطبيعية",
      "subject": 1,
      "grade": 3,
      "plan_data": {},
      "generated_by": "ai",
      "ai_model_used": "gemini-2.0-flash",
      "status": "published",
      "is_public": true,
      "likes_count": 15,
      "clones_count": 5,
      "created_at": "2025-01-15T10:30:00Z",
      "subject_name": "رياضيات",
      "grade_name": "الصف الثالث",
      "user_name": "أحمد"
    }
  ]
}
```

---

## GET /api/v1/lesson-plans/smart-prompts/ — مُنفّذ ✅ (جديد)

**جلب اقتراحات prompts سريعة للمعلم**  
يعيد 4 قوالب جاهزة.

### Response (200)
```json
[
  {"title": "مقدمة تفاعلية وعصف ذهني", "prompt": "صمم خطة درس تركز على العصف الذهني..."},
  {"title": "التعلم باللعب والتجارب العملية", "prompt": "أدمج أنشطة تفاعلية وألعاب تعليمية..."},
  {"title": "تقييم تكويني واستقصائي", "prompt": "ركز على الأسئلة الاستقصائية..."},
  {"title": "مهارات التفكير العليا والنقاش", "prompt": "ركز على مهارات التفكير الناقد..."}
]
```
