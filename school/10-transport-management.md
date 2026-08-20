# إدارة النقل المدرسي والحافلات (Transport Management CRUD)

> **تاريخ الإنشاء:** 20 أغسطس 2026
> **الحالة:** جاهز للتنفيذ ✅

---

## 1. ملخص المشروع
بناء واجهة إدارة متكاملة لإدارة النقل المدرسي تشمل الحافلات، خطوط السير، المحطات/نقاط التجمع، وتخصيص الطلاب. الواجهة الحالية (`/school/transport`) محدودة (إضافة حافلة فقط) وتحتاج تطوير شامل.

---

## 2. المشاكل الحالية
1. **صلاحيات القائمة الجانبية**: `/school/transport/map` ظاهرة لمدير المدرسة بدلاً من مسؤول النقل فقط
2. **إدارة الحافلات**: لا يوجد تعديل أو حذف (فقط إضافة وعرض)
3. **خطوط السير**: لا توجد إدارة (إضافة، تعديل، حذف، تحديد المحطات)
4. **المحطات/نقاط التجمع**: غير موجودة في قاعدة البيانات أو الواجهة

---

## 3. المكونات المطلوبة

### أ. Backend

#### نموذج جديد: `BusStop`
```python
class BusStop(models.Model):
    route = ForeignKey(BusRoute, related_name='stops')
    name = CharField(max_length=255)          # اسم المحطة
    latitude = DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    longitude = DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    order = PositiveIntegerField(default=0)   # ترتيب المحطة في الخط
    is_active = BooleanField(default=True)
```

#### endpoints جديدة
| المسار | الوصف |
|---|---|
| `GET/POST /api/v1/schools/bus-stops/` | إضافة وعرض محطات الخط |
| `PUT/DELETE /api/v1/schools/bus-stops/<id>/` | تعديل / حذف محطة |

### ب. Frontend — شاشة `/school/transport`
1. **إدارة الحافلات (Buses CRUD)**: جدول + إضافة/تعديل/حذف مع تأكيد
2. **إدارة خطوط السير (Routes CRUD)**: إضافة خط جديد (مرتبط بحافلة)، تعديل، حذف
3. **إدارة المحطات (Stops CRUD)**: إضافة نقاط تجمع لكل خط سير مع تحديد الموقع
4. **إدارة التخصيصات (Assignments)**: ربط الطلاب بخطوط السير ونقاط التجمع

---

## 4. التبعيات
- Migration جديدة `0026_busstop` لنموذج BusStop
- إصلاح صلاحيات `MenuItem` لـ `/school/transport/map` → `school_transport_officer`
- تحديث ترجمات ar.json و en.json

---

## 5. الأولوية
**عالية** — الميزة أساسية لعملية النقل المدرسي
