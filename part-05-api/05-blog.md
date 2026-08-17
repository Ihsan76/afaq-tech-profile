# APIs المدوّنة — الحالة الفعلية

> **حالة التنفيذ:** مكتمل ✅

## Base URL
```
/api/v1/blog/
```

---

## APIs العامة (AllowAny)

### GET /api/v1/blog/posts/
**جلب المقالات المنشورة**

#### Response (200)
```json
{
  "count": 7,
  "results": [
    {
      "id": 1,
      "title_en": "Welcome to Afaq Tech Platform",
      "title_ar": "مرحباً بكم في منصة آفاق تكنولوجي",
      "slug": "welcome-afaq-tech",
      "excerpt_en": "Introducing Afaq Tech...",
      "excerpt_ar": "تعريف بمنصة آفاق تكنولوجي...",
      "category": 1,
      "category_name": { "en": "Platform News", "ar": "أخبار المنصة" },
      "is_featured": true,
      "read_time": 3,
      "views": 42,
      "published_at": "2026-07-27T10:00:00Z",
      "author_name_en": "Afaq Tech Team",
      "author_name_ar": "فريق آفاق تكنولوجي"
    }
  ]
}
```

### GET /api/v1/blog/posts/{slug}/
**جلب تفاصيل المقال**

#### Response (200)
```json
{
  "id": 1,
  "title_en": "Welcome to Afaq Tech Platform",
  "title_ar": "مرحباً بكم في منصة آفاق تكنولوجي",
  "slug": "welcome-afaq-tech",
  "excerpt_en": "...",
  "excerpt_ar": "...",
  "content_en": "<h2>Welcome to Afaq Tech</h2>...",
  "content_ar": "<h2>مرحباً بكم في آفاق تكنولوجي</h2>...",
  "category": 1,
  "category_name": { "en": "Platform News", "ar": "أخبار المنصة" },
  "tags": "announcement,launch,platform",
  "featured_image_url": "",
  "author_name_en": "Afaq Tech Team",
  "author_name_ar": "فريق آفاق تكنولوجي",
  "author_avatar_url": "",
  "read_time": 3,
  "views": 43,
  "is_featured": true,
  "is_published": true,
  "published_at": "2026-07-27T10:00:00Z",
  "related_service": "",
  "created_at": "2026-07-27T10:00:00Z",
  "updated_at": "2026-07-27T10:00:00Z"
}
```

### GET /api/v1/blog/categories/
**جلب التصنيفات**

#### Response (200)
```json
[
  { "id": 1, "name_en": "Platform News", "name_ar": "أخبار المنصة", "slug": "platform-news", "icon": "📢" },
  { "id": 2, "name_en": "Tutorials", "name_ar": "الدروس التعليمية", "slug": "tutorials", "icon": "📚" },
  { "id": 3, "name_en": "AI & Education", "name_ar": "الذكاء الاصطناعي والتعليم", "slug": "ai-education", "icon": "🤖" },
  { "id": 4, "name_en": "Digital Marketing", "name_ar": "التسويق الرقمي", "slug": "digital-marketing", "icon": "📈" },
  { "id": 5, "name_en": "Web Development", "name_ar": "تطوير المواقع", "slug": "web-development", "icon": "💻" }
]
```

---

## APIs الإدارية (IsAdminUser)

### GET /api/v1/blog/admin/posts/
**جلب جميع المقالات (بما في ذلك المسودات)**

### POST /api/v1/blog/admin/posts/create/
**إنشاء مقال جديد**

#### Request
```json
{
  "title_en": "New Post",
  "title_ar": "مقال جديد",
  "slug": "new-post",
  "content_en": "<p>Content here...</p>",
  "content_ar": "<p>المحتوى هنا...</p>",
  "category": 1,
  "tags": "tag1,tag2",
  "is_published": true,
  "is_featured": false,
  "read_time": 5
}
```

### PUT /api/v1/blog/admin/posts/{id}/
**تحديث مقال**

### DELETE /api/v1/blog/admin/posts/{id}/
**حذف مقال**

### GET /api/v1/blog/admin/categories/
**جلب جميع التصنيفات**

---

## ملاحظات التنفيذ
- **المحتوى ثنائي اللغة**: title_en + title_ar, content_en + content_ar في نفس السطر
- **Rich Text Editor**: محتوى المقال (content_en/content_ar) يدعم HTML من TipTap editor
- **Views count**: يزداد تلقائياً عند جلب تفاصيل المقال
- **Slug**: فريد — يُولّد تلقائياً من العنوان الإنجليزي
- **Related Service**: رابط صفحة الخدمة المرتبطة (اختياري)
