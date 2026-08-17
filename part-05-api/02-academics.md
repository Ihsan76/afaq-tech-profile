# APIs الأكاديمية

## Base URL
```
/api/v1/academics/
```

---

## GET /api/v1/academics/grades/

**جلب المراحل الدراسية**

### Response (200)
```json
{
  "count": 12,
  "results": [
    {
      "id": 1,
      "name_ar": "صف الأول",
      "name_en": "Grade 1",
      "level": 2,
      "order": 1
    }
  ]
}
```

---

## GET /api/v1/academics/subjects/

**جلب المواد الدراسية**

### Response (200)
```json
{
  "count": 15,
  "results": [
    {
      "id": 1,
      "name_ar": "رياضيات",
      "name_en": "Mathematics",
      "icon": "calculator",
      "color": "#3B82F6"
    }
  ]
}
```

---

## GET /api/v1/academics/curricula/

**جلب المناهج الدراسية**

### Query Parameters
- `country`: سوريا، لبنان، ...
- `year`: 2025

### Response (200)
```json
{
  "count": 5,
  "results": [
    {
      "id": 1,
      "name_ar": "المنهاج السوري",
      "country": "سوريا",
      "year": 2025,
      "is_active": true
    }
  ]
}
```

---

## GET /api/v1/academics/curricula/{id}/units/

**جلب وحدات المنهج**

### Response (200)
```json
[
  {
    "id": 1,
    "name_ar": "الوحدة الأولى: الأعداد",
    "subject": {"id": 1, "name_ar": "رياضيات"},
    "grade": {"id": 3, "name_ar": "صف الثالث"},
    "order": 1,
    "lessons_count": 8
  }
]
```

---

## GET /api/v1/academics/units/{id}/lessons/

**جلب دروس الوحدة**

### Response (200)
```json
[
  {
    "id": 1,
    "name_ar": "الدرس الأول: العد",
    "order": 1,
    "objectives": ["يعرف الأعداد", "يعد من 1 إلى 100"],
    "keywords": ["عد", "أعداد"]
  }
]
```

---

## APIs المدير (Admin)

### POST /api/v1/academics/grades/
### PUT /api/v1/academics/grades/{id}/
### DELETE /api/v1/academics/grades/{id}/

### POST /api/v1/academics/subjects/
### PUT /api/v1/academics/subjects/{id}/
### DELETE /api/v1/academics/subjects/{id}/

### POST /api/v1/academics/curricula/
### POST /api/v1/academics/units/
### POST /api/v1/academics/lessons/

### POST /api/v1/academics/import/
**استيراد من CSV/Excel**
