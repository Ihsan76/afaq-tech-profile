# إدارة الصلاحيات (Permissions)

## نظرة عامة

نظام الصلاحيات في المنصة يعتمد على three-level permissions: عام، مسجّل، مدير.

> **حالة التنفيذ:** مكتمل ✅ (أساسي)

---

## مستويات الصلاحيات

### 1. عام (AllowAny)
- **المستخدمون:** الزوار غير المسجلين
- **الصلاحيات:** قراءة الصفحات، القوائم، الإعدادات، القوالب
- **الاستخدام:** جميع APIs العامة

### 2. مسجّل (IsAuthenticated)
- **المستخدمون:** المستخدمون المسجلون بعد تسجيل الدخول
- **الصلاحيات:** إدارة الملف الشخصي، عرض/إنشاء/تعديل/حذف خطط الدروس
- **الاستخدام:** Profile API, Lesson Plans APIs

### 3. مدير (IsAdminUser)
- **المستخدمون:** المديرون فقط (`is_staff=True`)
- **الصلاحيات:** صلاحيات كاملة — إنشاء/تعديل/حذف جميع الموارد
- **الاستخدام:** جميع Admin APIs

---

## جدول الصلاحيات

| API | AllowAny | IsAuthenticated | IsAdminUser |
|-----|----------|-----------------|-------------|
| **Pages** |
| GET /pages/<slug>/ | ✅ | ✅ | ✅ |
| GET /pages/admin/pages/ | ❌ | ❌ | ✅ |
| POST /pages/admin/pages/create/ | ❌ | ❌ | ✅ |
| PUT /pages/admin/pages/<pk>/ | ❌ | ❌ | ✅ |
| DELETE /pages/admin/pages/<pk>/delete/ | ❌ | ❌ | ✅ |
| **Blocks** |
| GET /pages/admin/pages/<id>/blocks/ | ❌ | ❌ | ✅ |
| POST /pages/admin/pages/<id>/blocks/ | ❌ | ❌ | ✅ |
| PUT /pages/admin/pages/<id>/blocks/<pk>/ | ❌ | ❌ | ✅ |
| DELETE /pages/admin/pages/<id>/blocks/<pk>/delete/ | ❌ | ❌ | ✅ |
| **Menus** |
| GET /pages/menu/<type>/ | ✅ | ✅ | ✅ |
| GET /pages/admin/menus/ | ❌ | ❌ | ✅ |
| POST /pages/admin/menus/create/ | ❌ | ❌ | ✅ |
| **Templates** |
| GET /pages/templates/list/ | ✅ | ✅ | ✅ |
| GET /pages/admin/templates/ | ❌ | ❌ | ✅ |
| **Settings** |
| GET /pages/settings/ | ✅ | ✅ | ✅ |
| PUT /pages/admin/settings/ | ❌ | ❌ | ✅ |
| **Auth** |
| POST /auth/register/ | ✅ | — | — |
| POST /auth/login/ | ✅ | — | — |
| POST /auth/refresh/ | ✅ | — | — |
| GET/PUT /auth/profile/ | ❌ | ✅ | ✅ |
| **Lesson Plans** |
| GET /lesson-plans/ | ❌ | ✅ | ✅ |
| POST /lesson-plans/generate/ | ❌ | ✅ | ✅ |
| **Academics** |
| GET /academics/grades/ | ✅ | ✅ | ✅ |
| POST /academics/grades/create/ | ❌ | ❌ | ✅ |

---

## أدوار المستخدمين

| الدور | الوصف | Admin Panel |
|-------|-------|-------------|
| `student` | طالب | ❌ |
| `teacher` | معلم | ❌ |
| `creator` | منشئ محتوى | ❌ |
| `admin` | مدير | ✅ |

> **ملاحظة:** حالياً، `IsAdminUser` يتحقق من `is_staff` فقط — لا يوجد فرق بين الأدوار في الصلاحيات.

---

## المصادقة (JWT)

### تدفق تسجيل الدخول
```
1. POST /api/v1/auth/login/ { email, password }
2. Response: { access, refresh, user data }
3. Request محمّل: Authorization: Bearer <access_token>
4. Access token ينتهي بعد 60 دقيقة
5. Refresh token ينتهي بعد 7 أيام
6. POST /api/v1/auth/refresh/ { refresh } → access token جديد
```

### بيانات الدخول الافتراضية
```
البريد: admin@afaq.app
كلمة المرور: Admin123456
```

---

## مستقبل الصلاحيات (مخطط)

- [ ] فصل صلاحيات حسب الدور (teacher vs student vs creator)
- [ ] صلاحيات مخصصة للمحتوى (منشئ المحتوى يعدل صفحته فقط)
- [ ] Audit log لكل عملية
- [ ] Rate limiting على APIs العامة

---

## ملخص

> النظام يعتمد على 3 مستويات: عام (قراءة فقط)، مسجّل (ملفي شخصي + خطط دروس)، مدير (كل شيء). حالياً لا يوجد فرق بين الأدوار — المدير هو من `is_staff=True`.
