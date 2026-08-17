# APIs الإدارة (Admin)

## Base URL
```
/api/v1/
```

### Headers
```
Authorization: Bearer <admin_access_token>
```

---

## APIs الصفحات (Pages) ✅ مُنفّذة

### APIs العامة (AllowAny)

#### GET `/api/v1/pages/<slug>/`
جلب صفحة بالـ slug مع بلوكاتها.

#### GET `/api/v1/pages/menu/<menu_type>/`
جلب عناصر القائمة (header/footer/sidebar). للـ `sidebar` تُفلتر تلقائياً حسب سياق الخدمة الحالي (`service_context__contains`)، والعام (مصفوفة فارغة) أولاً.

#### GET `/api/v1/pages/settings/`
جلب إعدادات الموقع.

#### GET `/api/v1/pages/templates/list/`
جلب القوالب النشطة.

---

### APIs إدارة الصفحات (IsAdminUser)

| Method | Endpoint | الوصف |
|--------|----------|-------|
| GET | `/api/v1/pages/admin/pages/` | قائمة جميع الصفحات |
| POST | `/api/v1/pages/admin/pages/create/` | إنشاء صفحة |
| GET | `/api/v1/pages/admin/pages/<pk>/` | تفاصيل صفحة |
| PUT | `/api/v1/pages/admin/pages/<pk>/` | تحديث صفحة |
| DELETE | `/api/v1/pages/admin/pages/<pk>/delete/` | حذف صفحة |

---

### APIs إدارة البلوكات (IsAdminUser)

| Method | Endpoint | الوصف |
|--------|----------|-------|
| GET | `/api/v1/pages/admin/pages/<page_id>/blocks/` | بلوكات الصفحة |
| POST | `/api/v1/pages/admin/pages/<page_id>/blocks/` | إضافة بلوك |
| PUT | `/api/v1/pages/admin/pages/<page_id>/blocks/<pk>/` | تعديل بلوك |
| DELETE | `/api/v1/pages/admin/pages/<page_id>/blocks/<pk>/delete/` | حذف بلوك |
| PUT | `/api/v1/pages/admin/pages/<page_id>/blocks/reorder/` | إعادة ترتيب |

---

### APIs إدارة القوائم (IsAdminUser)

| Method | Endpoint | الوصف |
|--------|----------|-------|
| GET | `/api/v1/pages/admin/menus/?menu=<type>` | قائمة العناصر (حسب الموقع) |
| POST | `/api/v1/pages/admin/menus/create/` | إضافة عنصر |
| PUT | `/api/v1/pages/admin/menus/<pk>/` | تعديل عنصر |
| DELETE | `/api/v1/pages/admin/menus/<pk>/delete/` | حذف عنصر |
| PUT | `/api/v1/pages/admin/menus/reorder/` | إعادة ترتيب |

**اختيار متعدد**: `service_context` و `required_role` يُرسلان/يُعادان كمصفوفات (`ChoiceListField`) — **المصفوفة الفارغة = الكل/للجميع** (لا خيار "all"). مثال حمولة إنشاء عنصر sidebar:
```json
{ "menu": "sidebar", "translations": { "ar": { "title": "الأكاديمية" }, "en": { "title": "Academy" } },
  "url": "/academy", "icon": "🎬", "service_context": ["academy"], "required_role": ["user", "instructor"], "is_active": true }
```

---

### APIs إدارة القوالب (IsAdminUser)

| Method | Endpoint | الوصف |
|--------|----------|-------|
| GET | `/api/v1/pages/admin/templates/` | جميع القوالب |
| POST | `/api/v1/pages/admin/templates/create/` | إنشاء قالب |
| PUT | `/api/v1/pages/admin/templates/<pk>/` | تعديل قالب |
| DELETE | `/api/v1/pages/admin/templates/<pk>/delete/` | حذف قالب |

---

### APIs الإعدادات (IsAdminUser)

| Method | Endpoint | الوصف |
|--------|----------|-------|
| PUT | `/api/v1/pages/admin/settings/` | تحديث إعدادات الموقع |

---

## APIs إدارة الثيمات (IsAdminUser)

| Method | Endpoint | الوصف |
|--------|----------|-------|
| GET | `/api/v1/themes/` | الثيمات النشطة (AllowAny) |
| GET | `/api/v1/themes/<pk>/` | تفاصيل ثيم (AllowAny) |
| GET | `/api/v1/themes/admin/` | جميع الثيمات |
| POST | `/api/v1/themes/admin/create/` | إنشاء ثيم |
| PUT | `/api/v1/themes/admin/<pk>/` | تعديل ثيم |
| DELETE | `/api/v1/themes/admin/<pk>/delete/` | حذف ثيم |

---

## APIs إدارة الويدجتات (IsAdminUser)

| Method | Endpoint | الوصف |
|--------|----------|-------|
| GET | `/api/v1/widgets/` | الويدجتات النشطة (AllowAny) |
| GET | `/api/v1/widgets/admin/` | جميع الويدجتات |
| POST | `/api/v1/widgets/admin/create/` | إنشاء ويدجت |
| PUT | `/api/v1/widgets/admin/<pk>/` | تعديل ويدجت |
| DELETE | `/api/v1/widgets/admin/<pk>/delete/` | حذف ويدجت |

---

## APIs إدارة اللغات (Core) ✅ مُنفّذة

### APIs عامة (AllowAny)

| Method | Endpoint | الوصف |
|--------|----------|-------|
| GET | `/api/v1/core/languages/` | اللغات النشطة فقط |
| GET | `/api/v1/core/translations/` | جميع مفاتيح الترجمات النشطة (يجلبها TranslationProvider) |

### APIs إدارة اللغات (IsAdminUser)

| Method | Endpoint | الوصف |
|--------|----------|-------|
| GET | `/api/v1/core/admin/languages/` | جميع اللغات (بما فيها غير النشطة) |
| POST | `/api/v1/core/admin/languages/create/` | إضافة لغة |
| PUT | `/api/v1/core/admin/languages/<pk>/` | تعديل لغة (GET + PUT) |
| DELETE | `/api/v1/core/admin/languages/<pk>/delete/` | حذف لغة (ممنوع حذف الافتراضية) |

### APIs إدارة الترجمات (IsAdminUser)

| Method | Endpoint | الوصف |
|--------|----------|-------|
| GET | `/api/v1/core/admin/translations/` | المفاتيح — يدعم `?namespace=` و `?q=` |
| POST | `/api/v1/core/admin/translations/create/` | إنشاء مفتاح (key + translations JSON) |
| PUT | `/api/v1/core/admin/translations/<pk>/` | تعديل مفتاح (GET + PUT) |
| DELETE | `/api/v1/core/admin/translations/<pk>/delete/` | حذف مفتاح |

> مثال على إعداد ترجمة (PUT):
> ```json
> {
>   "key": "nav.home",
>   "translations": { "ar": "الرئيسية", "en": "Home", "fr": "Accueil" }
> }
> ```

---

## APIs غير المُنفّذة (مخطط)

> هذه الـ APIs غير مُنفّذة بعد但她 موثقة كخطة مستقبلية.

- [ ] GET /api/v1/admin/dashboard/ — إحصائيات لوحة الإدارة
- [ ] GET /api/v1/admin/users/ — إدارة المستخدمين
- [ ] GET /api/v1/admin/ai/stats/ — إحصائيات AI
- [ ] GET /api/v1/admin/payments/stats/ — إحصائيات المدفوعات
- [ ] GET /api/v1/admin/logs/ — سجلات التدقيق

---

## ملخص

> **20 API endpoint مُنفّذة** في تطبيق Pages — صفحات (5)، بلوكات (5)، قوائم (5)، قوالب (4)، إعدادات (2). إضافة 6 endpoints للثيمات و5 للويدجتات و**14 endpoint للغات والترجمات** في تطبيق Core (5 عامة + 9 إدارية). المجموع: **45 API endpoint** مُنفّذ.
