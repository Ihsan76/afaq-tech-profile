# قواعد AI Agent — منصة آفاق تكنولوجي

> **ملف إلزامي** — يجب على كل AI Agent قراءة هذا الملف والالتزام به قبل أي عمل على المشروع.

---

## 1. هوية المشروع

| العنصر | القيمة |
|--------|--------|
| **الاسم** | آفاق تكنولوجي (Afaq Tech) |
| **النوع** | **منصة رقمية** (Platform) — ليست شركة |
| **الموقع** | `/mnt/data/Projects/afaq-tech/afaq-tech/` |
| **الملفات** | `/mnt/data/Projects/afaq-tech/afaq-tech-profile/` |

### قاعدة لغوية صارمة
- ✅ **صحيح**: منصة، نظام، حصة، خدمة
- ❌ **خطأ**: شركة، مؤسسة، منظمة
- عند الشك، استخدم "منصة" بدلاً من أي مصطلح آخر

---

## 2. الهيكل التقني

### Backend
| العنصر | التفاصيل |
|--------|----------|
| الإطار | Django 5.x + DRF |
| اللغة | Python 3.12+ |
| المسار | `backend/` |
| venv | `backend/venv/bin/python` |
| المنفذ | **8003** (عبر `screen -dmS backend8003`) |
| قاعدة البيانات | PostgreSQL عبر Supabase |
| المصادقة | JWT (SimpleJWT) |

### Frontend
| العنصر | التفاصيل |
|--------|----------|
| الإطار | Next.js 16+ (App Router) |
| اللغة | TypeScript |
| الأنماط | Tailwind CSS v4 |
| الترجمة | next-intl |
| الحالة | Zustand |
| المسار | `frontend/` |
| المجلدات | `src/app/`, `src/components/`, `src/i18n/` |

### التطبيقات المفعلة (14 تطبيقاً)
```
apps/users        — المستخدمون + JWT Auth + UserRole + RoleRequest
apps/academics    — المراحل، المواد، المناهج، الوحدات
apps/lessonplans  — خطط الدروس المولّدة بالـ AI
apps/ai           — تتبع عمليات AI + Provider Router (Gemini/OpenAI/Ollama)
apps/core         — TimeStampedModel + Language + TranslationKey + FeatureFlag (لغات وترجمات)
apps/themes       — نظام الثيمات (ثيم واحد = سطر واحد)
apps/pages        — نظام الصفحات + البلوكات + القوائم + القوالب + الإعدادات
apps/blog         — المدوّنة (BlogCategory, BlogPost) + APIs عامة وإدارية
apps/marketplace  — سوق الخدمات (Service, Order, Review) + 10 endpoints
apps/gamification — التلعيب (نقاط، شارات، إنجازات، تحديات، سلاسل، لوحة متصدرين، مستويات)
apps/courses      — الدورات التعليمية (Course.instructor_role FK→UserRole)
apps/ebooks       — الكتب الإلكترونية (Ebook.author_role FK→UserRole)
apps/subscriptions — الباقات والاشتراكات (Plan, Subscription)
apps/schools      — المدارس SIS + SchoolStaff + SchoolManagerRequest
```

### قاعدة بيانات
- **Supabase Transaction Pooler** (IPv4): `aws-0-ap-southeast-1.pooler.supabase.com:6543`
- **لا تستخدم** الاتصال المباشر (يسبب خطأ IPv6)
- PostgreSQL 15+ على Supabase

---

## 3. الملفات الحرجة

### لا تعدل هذه الملفات إلا بطلب صريح:
- `backend/config/settings/base.py` — الإعدادات الأساسية
- `backend/config/urls.py` — URLs الرئيسية
- `frontend/src/app/layout.tsx` — الجذر (<html> و <body>)
- `frontend/src/i18n/config.ts` — إعدادات اللغات

### ملفات `.env` — لا تشاركها:
- `backend/.env` — مفاتيح API + DATABASE_URL
- `frontend/.env.local` — NEXT_PUBLIC_API_URL

### معرفات حسابات services:
| الخدمة | الحساب | الملاحظة |
|--------|--------|----------|
| Supabase | `service_role_l8qn8kls@monument-db.632149835.supabase.co` | Service Role Key |
| Upstash | `AX01ASQUISA1MTFKNZI@upstash.io` | Redis URL |
| Resend | `resend@afaq.app` | Email API |
| Sentry | DSN في `backend/.env` | **لا تُعدّل** — يسبب توقف السيرفر |
| Gemini | API Key في `backend/.env` | AI Primary |

---

## 4. قواعد التطوير

### 4.1 قبل أي تعديل
1. **اقرأ الملف** المراد تعديله بالكامل
2. **افهم السياق** — ماذا يفعل هذا الملف ولماذا هكذا
3. **تحقق من الاعتمادية** — ما الملفات الأخرى التي تعتمد عليه
4. **لا تعدل** ملفات `.env` أو الإعدادات إلا بطلب واضح

### 4.2 أثناء التعديل
1. **اتبع أسلوب الكود الموجود** — نفس تنسيق الأسماء، التعليقات، الهيكل
2. **لا ت添加 تعليقات** إلا إذا طُلب منك ذلك صراحةً
3. **استخدم TypeScript** في الواجهة الأمامية — لا ملفات `.js`
4. **استخدم Python type hints** في الخلفية حيثما أمكن
5. **لا تحذف** أي كود موجود إلا إذا كنت متأكداً أنه غير مستخدم

### 4.3 بعد التعديل
1. **تأكد من عدم كسر** أي واجهة برمجية موجودة
2. **تأكد من تطابق** أسماء الحقول بين Backend و Frontend
3. **تأكد من دعم** RTL و LTR في الواجهة الأمامية

### 4.4 بنية المجلدات

#### Backend
```
backend/apps/{app_name}/
├── __init__.py
├── models.py
├── serializers.py
├── views.py
├── urls.py
└── admin.py
```

#### Frontend
```
frontend/src/
├── app/[locale]/          — صفحات التطبيق
├── components/
│   ├── landing/           — مكونات الهبوط (كل ملف = مكون واحد)
│   └── admin/             — مكونات لوحة الإدارة
├── i18n/messages/         — ملفات الترجمة (ar.json, en.json)
└── lib/                   — مساعدات و أنواع
```

---

## 5. نظام الصفحات والبلوكات

### 5.1 نموذج الصفحة (Page)
- كل صفحة لها `slug` فريد
- كل صفحة لها بلوكات `PageBlock` مرتبطة
- `is_homepage=True` يحدد الصفحة الرئيسية
- `show_in_nav` + `nav_order` تتحكم بالظهور بالقوائم

### 5.2 نموذج البلوك (PageBlock) — **40 نوع**

#### بلوكات المنصة (4)
| النوع | الوصف |
|-------|-------|
| `platform_hero` | بطل الصفحة الرئيسية |
| `platform_stats` | إحصائيات المنصة |
| `platform_how_it_works` | كيف تعمل المنصة |
| `services_showcase` | عرض 8 خدمات رقمية |

#### بلوكات الأكاديمية (7)
| النوع | الوصف |
|-------|-------|
| `hero` | بطل الصفحة (عام) |
| `stats` | إحصائيات |
| `features` | الميزات |
| `how_it_works` | كيف يعمل |
| `demo` | عرض توضيحي |
| `grade_showcase` | عرض الصفوف |
| `subjects_grid` | شبكة المواد |

#### بلوكات التسويق (6)
| النوع | الوصف |
|-------|-------|
| `testimonials` | شهادات |
| `pricing` | تسعير |
| `faq` | أسئلة شائعة |
| `cta` | دعوة للعمل |
| `portfolio` | معرض أعمال |
| `partners` | شركاء |

#### بلوكات المحتوى (6)
| النوع | الوصف |
|-------|-------|
| `text` | نص |
| `image` | صورة |
| `video` | فيديو |
| `gallery` | معرض صور |
| `custom_html` | HTML مخصص |
| `blog_list` | عرض مقالات المدوّنة (يجلب من API) |

#### بلوكات التخطيط (2)
| النوع | الوصف |
|-------|-------|
| `spacer` | مسافة |
| `divider` | فاصل |

#### بلوكات إضافية (4)
| النوع | الوصف |
|-------|-------|
| `services` | خدمات (عام) |
| `team` | الفريق |
| `contact` | تواصل معنا |
| `form` | نموذج |

#### بلوكات جديدة (11) — **مُضافة حديثاً**
| النوع | الوصف |
|-------|-------|
| `accordion` | أقسام قابلة للطي |
| `tabs` | تبويبات |
| `timeline` | خط زمني |
| `countdown` | عداد تنازلي |
| `newsletter` | اشتراك بريد |
| `map` | خريطة Google Maps |
| `table` | جدول بيانات |
| `icon_list` | قائمة أيقونات |
| `logo_carousel` | كاروسيل شعارات |
| `download` | تحميل ملف |
| `code` | بلوك كود |

### 5.3 نمط Content Overrides
```
كل كمبوننت في frontend/src/components/landing/ يتلقى content prop
├── إذا وُجد content → استخدمه (بيانات من الباك إند)
├── إذا لم يوجد → استخدم i18n translations (fallback)
└── الحقل يدعم _ar و _en بشكل منفصل
```

### 5.4 قاعدة مهمة — المحتوى لكل بلوك
- كل `PageBlock` له `content` خاص به
- تعديل بلوك على صفحة لا يؤثر على نفس البلوك في صفحة أخرى
- `styles` و `layout` و `animation` اختيارية لكل بلوك

---

## 6. نظام الثيمات

### 6.1 النموذج (Flat Model)
```python
class Theme(models.Model):
    name, name_ar, name_en, icon, description, description_ar
    is_active, is_default, order
    # 16 حقل لون: primary, secondary, accent, success, error, warning,
    #              background, surface, surface_alt, text_color, text_secondary,
    #              text_muted, border_color, border_light, muted
    # إعدادات الأزرار: btn_shape, btn_size, btn_shadow, btn_hover
    # إعدادات البطاقات: card_radius, card_border, card_shadow, card_glass
    # الخطوط: font_heading, font_body, font_size, line_height
```

### 6.2 الثيمات الستة
| الاسم | الوصف |
|-------|-------|
| آفاق كلاسيكي | الثيم الافتراضي — أزرق احترافي |
| آفاق داكن | Dark mode — بنفسجي |
| آفاق فاتح | أخضر طبيعي |
| آفاق محايد | رمادي هادئ |
| آفاق مدرسي | ملون للتعليم |
| آفاق مخصص | ثيم مخصص |

### 6.3 كيفية عمله
- `ThemeSwitcher` في Navbar كـ dropdown (أيقونة + نقاط ألوان + علامة ✅)
- كل ثيم يُطبّق عبر CSS variables على `<html>` element
- `data-theme` attribute يتحكم بالثيم الحالي
- ثيم لكل صفحة يمكن تخصيصه عبر `theme_overrides` في Page model

---

## 7. نظام الترجمة (i18n)

### 7.1 اللغات المدعومة (10)
```
ar — العربية (RTL)
en — English (LTR)
fr — Français
tr — Türkçe
ur — اردو (RTL)
es — Español
de — Deutsch
id — Bahasa Indonesia
bn — বাংলা
fa — فارسی (RTL)
```
- اللغات في **قاعدة البيانات** (نموذج `Language` في `apps/core`) — تُقرأ عبر `/api/v1/core/languages/`
- `frontend/src/i18n/config.ts` + `src/proxy.ts` تحتوي نفس القائمة (للمراوحة في middleware) — عند إضافة لغة يجب تحديثها **معاً**

### 7.2 مصدر الترجمات (طبقتان)
1. **ملفات JSON الثابتة** — `frontend/src/i18n/messages/{locale}.json` (10 ملفات، لكل لغة ملف مستقل). تُمرَّر إلى next-intl كـ fallback.
2. **قاعدة البيانات (المصدر الحي)** — نموذج `TranslationKey` في `apps/core` (1018 مفتاحاً). `TranslationProvider` يجلب `/api/v1/core/translations/` ويدمج قيم اللغة الحالية **متداخلة** (nested) فوق الرسائل الثابتة — أي تعديل من الأدمن يظهر فوراً بدون إعادة نشر.

### 7.3 Namespaces
```
common, auth, nav, home, academy, lessonPlan, admin,
dashboard, profile, landing, servicesMarketplace, gamification
```

### 7.4 إضافة/تعديل الترجمات
- **من الأدمن**: صفحة `/admin/translations` (إدارة كل المفاتيح والقيم لكل اللغات) أو تبويب "ترجمات اللغة" داخل تعديل لغة في `/admin/languages`
- **من الكود**: عدّل `frontend/src/i18n/messages/ar.json` و`en.json` (وغيرها)، ثم:
  ```bash
  cd backend && ./venv/bin/python manage.py seed_translations
  ```
  (يفلّت JSON إلى مفاتيح بنقاط ويستخدم bulk_create/bulk_update)
- **تلقائياً (signals)**: عند إضافة **لغة جديدة** عبر الأدمن/API يُعبَّأ `translations[code]` لكل المفاتيح من `messages/{code}.json` تلقائياً؛ وعند إضافة **مفتاح جديد** تُعبَّأ اللغات الناقصة من ملفات `messages/*.json`؛ وعند **حذف لغة** (غير الافتراضية) يُنظّف `post_delete` قيم `translations[code]` من كل `TranslationKey` (المنطق في `apps/core/translation_seed.py` + `apps/core/signals.py`).
- **قوائم اللغات (config/matcher)**: المصدر الوحيد `frontend/src/i18n/config.ts` — بعد إضافة لغة شغّل:
  ```bash
  cd frontend && npm run sync:locales
  ```
  (يجلب `/api/v1/core/languages/` ويعيد توليد `config.ts` + `src/proxy.ts` matcher؛ يتطلب تشغيل backend على 8003)

### 7.5 قاعدة الترجمة
- **لا تمرر** `locale` كـ prop يدوياً — استخدم `useLocale()` من next-intl
- **لا تستخدم** `usePathname()` لجلب الـ locale — استخدم `useLocale()` مباشرة
- **لا تفلّت** رسائل next-intl عند حقن قيم DB — يجب البناء المتداخل (`setNested` + `deepMerge` في `TranslationProvider`)
- **كل حقل** يحتوي `_ar` و `_en` بشكل منفصل
- اللغة الافتراضية: `en` (في `config.ts` و`seed_languages.py`)

---

## 8. صلاحيات API

### 8.1 القاعدة العامة
- **القراءة** (GET): `AllowAny` — متاحة للجميع بدون مصادقة
- **الكتابة** (POST/PUT/DELETE): صلاحيات الأقسام في `apps/users/permissions.py` (انظر 8.1ب)
- **الملفات الشخصية**: `IsAuthenticated` — للمستخدمين المسجلين

### 8.1أ نظام الأدوار (RBAC الشامل — أغسطس 2026)

#### نموذج UserRole (المصدر الوحيد للصلاحيات)
```
apps/users/models.py → UserRole(user FK, role, organization FK, is_active, assigned_by FK, assigned_at)
```
- **`User.role`** = حقل قديم محفوظ للتوافق — **لا تعتمد عليه**. المصدر الوحيد: `UserRole` objects.
- **`RoleService`** (`apps/users/services.py`) — الخدمة الموحّدة لكل عمليات الأدوار:
  - `has_role(user, role, org=None)` — تحقق مع فلترة org
  - `has_role_anywhere(user, role)` — تحقق بدون فلترة org
  - `has_role_in_school(user, role, school)` — تحقق في مدرسة محددة
  - `assign_role(user, role, assigned_by=None, org=None)` — تعيين + إنشاء UserRole
  - `revoke_role(user, role, org=None)` — إزالة (set is_active=False)
  - `can_assign_role(assigner, target_role)` — تحقق من صلاحية التعيين
  - `get_user_roles(user, org=None)` — جلب كل الأدوار النشطة

#### أدوار المستخدمين (`User.Role` choices + `UserRole.role`)
```
student          — طالب
teacher          — معلم
parent           — ولي أمر
creator          — منشئ محتوى
instructor       — مدرّب (لدورات الأكاديمية)
publisher        — ناشر (للكتب الإلكترونية)
service_provider — مزود خدمات (سوق الخدمات)
admin            — مدير النظام (كل الصلاحيات)
developer        — مطوّر (تقني)
support          — دعم فني (قراءة فقط)
content_manager  — مدير محتوى
finance          — مشرف مالي
```
- أدوار فريق الإدارة `ADMIN_ROLES = {admin, developer, support, content_manager, finance}` — كلها تدخل `/admin`.
- **التسجيل الافتراضي**: المستخدم الجديد يحصل على دور `user` (وليس `student`) بعد تأكيد البريد. `student`/`parent` يُعيَّنان تلقائياً عند حفظ الملف الشخصي أو الانضمام لمدرسة.

#### نموذج RoleRequest (طلبات الأدوار — أغسطس 2026)
```
apps/users/models.py → RoleRequest(user FK, request_type, status, reviewed_by FK, reviewed_at, notes)
```
- Types: `instructor`, `publisher`, `service_provider`
- Status: `pending`, `approved`, `rejected`
- Endpoint: `GET/POST /api/v1/users/role-requests/` (إنشاء + عرض) + `POST .../review/` (admin)
- Frontend: `/auth/role-request` — نموذج طلب + قائمة طلباتي
- عند الموافقة: `RoleService.assign_role()` + إنشاء `UserRole` تلقائياً

#### نموذج SchoolStaff (طاقم المدرسة — أغسطس 2026)
```
apps/schools/models.py → SchoolStaff(school FK, user FK, staff_role, is_active)
```
- Endpoint: `GET/POST /api/v1/schools/school-staff/` (CRUD)
- Frontend: `/school/admin/staff` — إدارة طاقم المدرسة (إضافة/حذف معلمين ومساعدين)

#### نموذج SchoolManagerRequest (نقل ملكية المدرسة — أغسطس 2026)
```
apps/schools/models.py → SchoolManagerRequest(school FK, from_user FK, to_user FK, status, reviewed_at, notes)
```
- Status: `pending`, `approved`, `rejected`
- Endpoint: `GET/POST /api/v1/schools/manager-requests/` + `POST .../review/`
- Frontend: `/school/admin/transfer` — طلب نقل ملكية المدرسة لمدير جديد

#### حقول الدورات/الكتب/الخدمات (FK إلى UserRole — وليس User مباشرة)
```
Course.instructor_role = FK → UserRole (property: .instructor → User)
Ebook.author_role     = FK → UserRole (property: .author → User)
Service.provider_role = FK → UserRole (property: .provider → User)
```
- **لا تستخدم** `Course(instructor=user)` — خطأ! استخدم `Course(instructor_role=role_object)`
- **لا تستخدم** `select_related('instructor')` — خطأ! استخدم `select_related('instructor_role')`
- عند إنشاء دورات/كتب/خدمات عبر API: `RoleService.assign_role()` ينشئ `UserRole` أولاً ثم يمرره كـ FK

#### ملاحظات مهمة
- **مدير المنشأة/المنظمة**: عضوية `OrganizationMembership` بدور MANAGER (أو مالك منظمة بباقة school/enterprise) — منفصل عن `school_admin`.
- **مدير المدرسة = دور `school_admin`** عبر `School.manager` (FK→User) — نطاقه مدرسته فقط عبر `user_school_ids`، لا يدخل `/admin`.
- `is_admin()` في `apps/schools/views.py` يقبل admin + developer (قسم schools).
- `is_school_admin()` يتحقق عبر `RoleService.has_role(user, 'school_admin')`.

### 8.1ب صلاحيات الأقسام (`apps/users/permissions.py`)
- `IsAdminRole` — أي دور إداري (الكتابة محظورة لـ support).
- `IsSystemAdmin` — admin فقط (تغيير أدوار/باقات المستخدمين).
- `IsSectionAdmin` + أقسام `SECTION_ROLES`: content/education/blog/ebooks/courses → admin+developer+content_manager؛ ai/marketplace/organizations/settings/schools → admin+developer؛ messages → admin+developer+support؛ users → admin+developer+support (قراءة)؛ subscriptions → admin+finance.
- كلاسات جاهزة: `IsContentAdmin`, `IsAIAdmin`, `IsMarketplaceAdmin`, `IsMessagesAdmin`, `IsUsersAdmin`, `IsFinanceAdmin`, `IsOrganizationsAdmin`, `IsSettingsAdmin`.
- الواجهة تعكس نفس الخريطة في `frontend/src/app/[locale]/admin/layout.tsx` (`SECTION_ROLES`) — عند تغييرها حدّث الطرفين.
- `is_admin()` في `apps/schools/views.py` يقبل admin + developer (قسم schools).

### 8.2 Endpoint Structure
```
/api/v1/{app}/                    — APIs عامة (AllowAny للقراءة)
/api/v1/{app}/admin/              — APIs الإدارة (صلاحيات الأقسام في 8.1ب)
/api/v1/{app}/admin/{resource}/   — CRUD موارد محددة
```

### 8.3 مثال على URLs
```python
# apps/pages/urls.py
path('settings/', SiteSettingsPublicView.as_view()),          # AllowAny
path('menu/<str:menu_type>/', MenuPublicView.as_view()),      # AllowAny
path('templates/list/', TemplateListView.as_view()),          # AllowAny
path('<slug:slug>/', PagePublicView.as_view()),               # AllowAny
path('admin/pages/', PageAdminListView.as_view()),            # IsContentAdmin
path('admin/pages/create/', PageAdminCreateView.as_view()),   # IsContentAdmin
path('admin/pages/<int:pk>/', PageAdminUpdateView.as_view()), # IsContentAdmin (GET+PUT)
path('admin/pages/<int:pk>/delete/', PageAdminDeleteView.as_view()),
```

### 8.4 تحذير: URL Routing
- يجب أن تأتي `settings/` و `menu/` و `templates/list/` **قبل** `<slug:slug>/`
- `<slug:slug>/` يلتقط أي نص — يجب أن يكون آخر endpoint

### 8.5 تحصين المصادقة (مُنجز)
- **JWT RS256**: مفاتيح RSA (2048) في `.env` بـ `JWT_PRIVATE_KEY_B64` / `JWT_PUBLIC_KEY_B64` (base64)، وتُفك ترميزها في `config/settings/base.py`. لا تُشارك المفاتيح.
- **Argon2id**: أول hasher في `PASSWORD_HASHERS` (القديم PBKDF2 يعمل كـ fallback لتسجيل الدخول فقط).
- **Logout**: `POST /api/v1/auth/logout/` بجسم `{refresh}` → blacklist (يعتمد على `BLACKLIST_AFTER_ROTATION`). الاستدعاء من الـ frontend قبل مسح localStorage (فشل آمن).
- **تأكيد البريد**: نموذجا `EmailVerification` (رمز 6 أرقام، sha256، صالح ساعة) + `POST /auth/verify-email/` (إرسال/إعادة إرسال عبر Resend) + `POST /auth/verify-email/confirm/` (تفعيل `is_verified`). في وضع التطوير بدون `RESEND_API_KEY` يُرجع `debug_code` في الرد (لا يُطبع في الإنتاج).
- **Brute force**: نموذج `LoginAttempt` + قفل 5 محاولات فاشلة / 15 دقيقة → `429 Too many failed attempts`.
- **Rate limiting**: scopes `auth_login` (5/دقيقة)، `auth_register` (3/ساعة)، `auth_verify` (5/دقيقة)، `auth_reset` (3/ساعة) عبر `ScopedRateThrottle` على endpoints المصادقة.
- **Google OAuth**: `GET /auth/google/?locale=` → Google (يُعيد توجيه frontend إلى `/auth/google/callback`) و `GET /auth/google/callback/` → يبدّل الكود → يُنشئ/يربط المستخدم → `302` إلى `{FRONTEND_URL}/{locale}/auth/google/callback?access=&refresh=`. الإعداد: `GOOGLE_OAUTH_CLIENT_ID` / `GOOGLE_OAUTH_CLIENT_SECRET` / `GOOGLE_REDIRECT_URI` في `.env` (placeholders فارغة حالياً — يجب تعبئتها قبل النشر).
- **CSRF**: المصادقة عبر Bearer header (لا cookies) لذا CSRF غير ساري؛ أُضيف `CSRF_TRUSTED_ORIGINS`.

---

## 9. بيئة التطوير

### 9.1 تشغيل Backend
```bash
cd backend
source venv/bin/activate
export SENTRY_DSN_BACKEND=""  # يمنع تعليق السيرفر
python manage.py runserver --noreload 0.0.0.0:8000
```

### 9.2 تشغيل Frontend
```bash
cd frontend
npm run dev
```

### 9.3 إعادة تعيين البيانات
```bash
cd backend
source venv/bin/activate
export SENTRY_DSN_BACKEND=""
python manage.py migrate
python seed_languages.py
python manage.py seed_translations
python seed_themes.py
python seed_menus.py
python seed_pages.py
python seed_blog.py
```

### 9.4 تحذيرات مهمة
- **لا تستخدم** `python manage.py runserver` بدون `--noreload` — قد يسبب مشاكل
- **لا تشغّل** السيرفر بدون `export SENTRY_DSN_BACKEND=""` — يعلق
- **منفذ 8003** هو المنفذ الحالي (عبر screen) — لا تستخدم منافذ أخرى
- **العمليات المنفصلة** (orphaned) قد تكون شغّالة — تحقق بـ `ps aux | grep runserver`
- **البايثون في venv**: `backend/venv/bin/python` — لا تستخدم `python` مباشرة

### 9.5 النشر المستضاف (الحالي — أغسطس 2026)
- **الفرونت**: Vercel (Next.js 16، root `frontend/`) — `afaq.app` → 308 → `www.afaq.app` → 200.
- **الباكند**: Render (`afaq-api-42we`، Docker، port 10000) — health `/api/v1/core/health/`.
- **Cloudflare وسيط أمام الكل** (الـ NS انتقل من Namecheap؛ سجلات CNAME `@`/`www`/`api` Proxied). بعض الشبكات تحجب عناوين Vercel — لا تزيل Cloudflare.
- **لا تُدوَّر `DJANGO_SECRET_KEY`** بعد النشر (مفاتيح AI مشفّرة به).
- **keep-alive**: مكوّن `KeepAlive` يبقي الخدمة حية أثناء الفتح؛ **مراقب خارجي 24/7 أُنشئ** على `https://api.afaq.app/api/v1/core/health/` (cron-job.org/UptimeRobot).
- **الأداء (أغسطس 2026)**:
  - Upstash (Redis) **محجوب إقليمياً** من Render أيضاً → الكاش في `production.py` = `LocMemCache` + `socket_connect_timeout`/`socket_timeout` = 0.3 في `base.py`. **لا تعتمد على Redis في الإنتاج حالياً**.
  - **Service Worker (إصلاح صور الدورات — أغسطس 2026)**: `public/sw.js` = نطاق تنقّل فقط + cache-first مع تحديث خلفي دوري (TTL 5 دقائق) + كاش `afaq-tech-v2`. عند تعديل الـ SW **ارفع رقم النسخة** (v3...) ليُفرّغ الكاش القديم تلقائياً؛ ولنشر التعديل سريعاً أضِف/أبقِ `Cache-Control: no-cache` لمسار `/sw.js`. لا تعرّض الصور/`/api/` للاعتراض أبداً — ذلك يسبب "الصور لا تظهر إلا بعد Ctrl+Shift+R".
  - ترجمات الواجهة: `TranslationPublicSerializer` يفلتر بـ `?locale=` (كان يعيد كل اللغات 561KB — الآن ~56KB)؛ `TranslationProvider` يمرّر `{ locale }`.
  - المدوّنة/الكتب: `select_related('category')` + `annotate(_posts_count)` — لا N+1. **لا تعدّ `usePrefetch` لإطلاق طلبات تفاصيل لكل عنصر قائمة بالتوازي** (كان يُغرق Gunicorn).
  - **Gemini**: الحزمة الحديثة `google-genai` (من `google import genai`) بدل `google.generativeai` (المُهملة) في `apps/ai`.
- **الدفع (مزوّدات متعددة — أغسطس 2026)**: الدفع الإلكتروني للأوردرات عبر واجهة موحّدة `apps/marketplace/payments/` (package) تدعم **Stripe Checkout** و**MyFatoorah** بالتوازي. المزوّد الفعّال يُختار بـ `PAYMENT_PROVIDER` (auto|stripe|myfatoorah)؛ في `auto` الأول المُهيّأ (أولوية: stripe ثم myfatoorah). متغيّرات Stripe: `STRIPE_SECRET_KEY`+`STRIPE_WEBHOOK_SECRET`؛ متغيّرات MyFatoorah: `MYFATOORAH_API_TOKEN`+`MYFATOORAH_WEBHOOK_SECRET` (و`MYFATOORAH_BASE_URL` لبيئة Live/Test + `MYFATOORAH_PAYMENT_METHOD_ID`=0 = صفحة فواتير بكل الطرق). إن لم يُهيّأ أي مزوّد → الطلب يُنشأ بدون دفع (`payment_status=pending`) والواجهة تعرض "الدفع غير متاح". مسارات الويب هوك (سجّلها في كل لوحة): Stripe `POST https://api.afaq.app/api/v1/marketplace/payments/webhook/stripe/` (حدث `checkout.session.completed`)؛ MyFatoorah `POST https://api.afaq.app/api/v1/marketplace/payments/webhook/myfatoorah/` (Webhook V2 + توقيع HMAC `Myfatoorah-Signature`). تدفّق: إنشاء طلب → `checkout_url` → صفحة المزوّد → عودة إلى `/marketplace/orders/?session_id=…|paymentId=…` → الويب هوك يعلّم الطلب `paid`+`confirmed`. إعادة الدفع: `POST /api/v1/marketplace/orders/<id>/checkout/?locale=…`. حقول الطلب عامة: `payment_provider`+`payment_session_id`+`payment_transaction_id` (بدل حقول Stripe السابقة).
- **الاشتراكات والباقات (أغسطس 2026)**: تطبيق جديد `apps/subscriptions` (13) بنموذجي `Plan` + `Subscription`. الباقات تُزرع تلقائياً عبر data migration `0002_seed_plans` (free/pro/school/enterprise) عند أي deploy. واجهات: `GET /api/v1/subscriptions/plans/` (عام، محلّي بـ `?locale=`) + `GET /current/` + `POST /purchase/` (المصادقة؛ `{plan_id, locale}`) + `admin/plans/` (IsFinanceAdmin). الشراء يستخدم **نفس** واجهة المزوّدات الموحّدة (Stripe/MyFatoorah): يُنشئ Subscription بحالة `pending`، يُرجع `checkout_url`، وعند نجاح الدفع يُفعَّل الاشتراك (status=active + start/end_at حسب `duration_days`) ويرفع `user.subscription_plan` إلى كود الباقة (أُضيفت باقة `school` إلى اختيارات `User.SubscriptionPlan` + `PLAN_LEVELS`). تدفّق: صفحة `/subscriptions` → زر الباقة → `purchase/` → صفحة المزوّد → عودة إلى `/subscriptions/?session_id=…|paymentId=…` → الويب هوك (نفس مسارات marketplace) يعالج النوع عبر metadata `kind:subscription` أو `UserDefinedField="subscription:<id>"`. إدارة الباقات من Django Admin (`/admin/subscriptions`).
- مرجع كامل: `part-03-architecture/06-deployment.md`.

---

## 10. الأخطاء الشائعة وكيفية تجنبها

### 10.1 خطأ الاتصال بقاعدة البيانات
- **السبب**: استخدام الاتصال المباشر بدلاً من Transaction Pooler
- **الحل**: تأكد من أن `DATABASE_URL` يشير إلى `aws-0-ap-southeast-1.pooler.supabase.com:6543`

### 10.2 تعليق السيرفر
- **السبب**: Sentry DSN غير صحيح أو غير موجود
- **الحل**: `export SENTRY_DSN_BACKEND=""` قبل التشغيل

### 10.3 عدم ظهور الترجمات
- **السبب**: اللغة غير موجودة في `messages/` أو المفتاح خاطئ أو `TranslationKey` مفقود من DB
- **الحل**: تحقق من `frontend/src/i18n/messages/{locale}.json`، ثم أعد `manage.py seed_translations`، وتأكد أن `/api/v1/core/translations/` يعيد المفتاح بالقيمة الصحيحة

### 10.6 ظهور المفاتيح بدل النصوص (مثل `nav.home`)
- **السبب**: حقن قيم مسطّحة في رسائل next-intl بدل البناء المتداخل
- **الحل**: استخدم `setNested` + `deepMerge` (كما في `TranslationProvider.tsx`) — لا تفلّت الكائنات عند الدمج

### 10.4 خطأ 404 على APIs
- **السبب**: URL Routing خاطئ (slug يلتقط endpoints أخرى)
- **الحل**: تأكد من أن `settings/` و `menu/` و `templates/list/` قبل `<slug:slug>/`

### 10.5 عدم تطابق الحقول بين Backend و Frontend
- **السبب**: إضافة حقل في Backend ولم يُضاف في Frontend
- **الحل**: تأكد من تطابق أسماء الحقول في Models و Serializers و API Response و Frontend Components

---

## 11. أوامر مفيدة

### Backend
```bash
# إنشاء هجرة
python manage.py makemigrations {app_name}

# تطبيق هجرة
python manage.py migrate

# إنشاء مستخدم مشرف
python manage.py createsuperuser

# عرض جميع URLs
python manage.py show_urls

# اختبار API
curl http://localhost:8000/api/v1/pages/homepage/
curl http://localhost:8000/api/v1/core/languages/
curl http://localhost:8000/api/v1/core/translations/
curl -H "Authorization: Bearer <token>" http://localhost:8000/api/v1/pages/admin/pages/

# زرع الترجمات من ملفات الواجهة الأمامية إلى DB
python manage.py seed_translations
# زرع اللغات
python ../backend/seed_languages.py

# الاختبارات (بيئة SQLite + locmem تلقائياً عبر config.settings.testing)
python -m pytest tests/

# فحص النمط (Ruff)
ruff check apps tests config --exclude "*migrations*"
ruff check apps tests config --exclude "*migrations*" --fix

# التحقق من إعدادات Django
python manage.py check

# Redis (حاويات Docker)
docker ps --filter name=afaq_redis          # الحالة
docker exec afaq_redis redis-cli ping       # اختبار الاتصال
docker exec afaq_redis redis-cli --scan     # عرض المفاتيح
```

### Frontend
```bash
# بناء للإنتاج
npm run build

# فحص TypeScript
npm run typecheck

# فحص التنسيق
npm run lint

# عرض جميع Routes
find src/app -name "page.tsx" | sort
```

---

## 12. قواعد عامة

### 12.1 عند إضافة مكون جديد
1. أنشئ الملف في `frontend/src/components/landing/` أو `frontend/src/components/admin/`
2. أضف الـ import في `BlockRenderer.tsx` إذا كان بلوكاً
3. أضف نوع البلوك في `apps/pages/models.py` (BlockType choices)
4. أضف محرر المحتوى في `BlockEditorPanel.tsx`
5. أضف الترجمات في `frontend/src/i18n/messages/ar.json` و `en.json` وأعد `seed_translations`

### 12.2 عند إضافة API جديد
1. أنشئ الـ View في `views.py`
2. أضف الـ Serializer في `serializers.py`
3. أضف الـ URL في `urls.py`
4. تأكد من الصلاحيات (AllowAny أو صلاحية القسم المناسبة من `apps/users/permissions.py` — انظر 8.1ب)
5. تأكد من ترتيب URLs (static paths قبل dynamic slugs)

### 12.3 عند إضافة صفحة جديدة
1. أنشئ المجلد في `frontend/src/app/[locale]/`
2. أنشئ `page.tsx` يستخدم `DynamicPage` أو مكون مخصص
3. أضف الترجمات اللازمة
4. إذا أردت ظهورها بالقائمة: `show_in_nav=True` + `nav_order`

### 12.4 عند تعديل نموذج (Model)
1. عدّل `models.py`
2. شغّل `makemigrations`
3. شغّل `migrate`
4. عدّل `serializers.py` إذا لزم الأمر
5. عدّل `admin.py` لعرض الحقول الجديدة

### 12.5 عند إضافة أو تعديل ترجمة في الكود
1. عدّل `frontend/src/i18n/messages/{locale}.json` (جميع اللغات المطلوبة)
2. أعد زرعها في DB: `cd backend && ./venv/bin/python manage.py seed_translations` (التعبئة التلقائية للغة/مفتاح جديد تتم عبر signals في `apps/core/signals.py`)
3. إذا أضفت **لغة جديدة**: أنشئ `messages/{code}.json` + أضفها من صفحة `/admin/languages` (أو `seed_languages.py`) ثم `cd frontend && npm run sync:locales` (يعيد توليد `config.ts` و `proxy.ts` matcher تلقائياً)
4. أعد `npm run build` للتأكد من سير عمل next-intl

### 12.6 لا تحذف
- لا تحذف أي حقل من Model موجود
- لا تحذف أي API endpoint موجود
- لا تحذف أي مكون frontend موجود
- إذا أردت إيقاف استخدام شيء، علّمه بـ `deprecated` بدلاً من الحذف

---

## 13. ملخص سريعة

```
1. "آفاق تكنولوجي" منصة — ليست شركة
2. Backend: Django 5.x + DRF + Python 3.12+ (14 تطبيقاً)
3. Frontend: Next.js 16+ + TypeScript + Tailwind
4. قاعدة البيانات: Supabase PostgreSQL (Transaction Pooler)
5. 40 نوع بلوك، 6 ثيمات، 10 لغات
6. لا تعدل .env أو settings بدون طلب واضح
7. اتبع أسلوب الكود الموجود دائماً
8. تأكد من دعم RTL/LTR
9. لا تحذف — علّم بـ deprecated
10. اقرأ AGENTS.md قبل كل مهمة
11. Backend يعمل على المنفذ 8003 عبر screen
12. التطبيقات: users, academics, lessonplans, ai, core, themes, pages, blog, marketplace, gamification, courses, ebooks, subscriptions, schools (14)
13. PDF: WeasyPrint مع Noto Naskh Arabic، RTL، عناوين عربية/إنجليزية، إخفاء الإجابات
14. سوق الخدمات (Marketplace): ServiceCategory, Service, Order, Review + 4 صفحات أمامية
15. Gamification بكاملها: 12 موديل، 16 API، 16 نشاطاً — جاهز، يحتاج واجهة أمامية
16. اللغات والترجمات من DB: Language (10) + TranslationKey (1305) في apps/core، TranslationProvider يدمج القيم الحية، إدارة من /admin/translations و /admin/languages
17. المصادقة محصّنة: Argon2id، JWT RS256، logout (blacklist)، تأكيد بريد عبر Resend، brute-force (5/15د)، rate limiting على endpoints الدخول، Google OAuth جاهز (ينتظر client ID/secret في .env)
18. **RBAC الشامل (أغسطس 2026)**: نظام أدوار موحد عبر `UserRole` (FK table) — `RoleService` للتعيين/الإزالة/التحقق؛ `RoleRequest` لطلب الأدوار؛ `SchoolStaff` لطاقم المدرسة؛ `SchoolManagerRequest` لنقل الملكية؛ تسجيل مبسّط (ادخار student/parent مع تأكيد البريد → دور `user` افتراضياً)؛ الدورات/الكتب/الخدمات تستخدم FK إلى `UserRole`
19. **تمايز Curriculum Injection (المنهاج الرسمي)**: نموذج `Unit` يتضمن `subject` (FK) + `outcomes` (قائمة نواتج التعلم) + `content`؛ سكربت `seed_curricula.py` يزرع مناهج السعودية والأردن بصفوف/مواد/وحدات/نواتج (46 وحدة)؛ النهاية `GET /api/v1/academics/curricula/resolve/?grade=&subject=` تعيد المنهاج المطابق + وحداته؛ توليد الخطة يقبل `unit` اختيارياً ويحقن نواتج التعلم تلقائياً (دالة `build_curriculum_context` في `apps/lessonplans/views.py`)؛ منتقي وحدة في `lesson-plans/new`. ✅ **Gemini حُلّ**: ترحيل `google.generativeai` → `google.genai` (من `google import genai`)
20. **الأداء (أغسطس 2026)**: الكاش في الإنتاج = `LocMemCache` (Upstash محجوب إقليمياً)؛ ترجمات مصفّاة باللغة (561KB ← ~56KB)؛ لا N+1 في المدوّنة/الكتب؛ لا طوفان prefetch؛ بطاقات كتب بغلاف افتراضي محسّن
21. **الدفع (أغسطس 2026)**: واجهة مزوّدات موحّدة `apps/marketplace/payments/{base,registry,stripe_provider,myfatoorah_provider}.py` — Stripe Checkout + MyFatoorah بالتوازي (اختيار عبر `PAYMENT_PROVIDER=auto|stripe|myfatoorah`)؛ webhook موحّد `payments/webhook/<provider>/` (تحقق توقيع لكل مزوّد) + `orders/<pk>/checkout/` لإعادة الدفع؛ حقول Order عامة: `payment_provider`/`payment_session_id`/`payment_transaction_id`؛ بدون أي مفتاح → إنشاء طلب بلا دفع مع `payment_available=false`. ملاحظة: Stripe غير متاح للتاجر الأردني — استخدم MyFatoorah كبوابة فعلية.
22. **الاشتراكات والباقات (أغسطس 2026)**: تطبيق `apps/subscriptions` (13) — نماذج `Plan` (باقات متعددة اللغات بأسعار ومدة `duration_days`) + `Subscription` (طلب/اشتراك بلاستخدام نفس واجهة الدفع)؛ endpoints `subscriptions/{plans,current,purchase}` + admin plans؛ webhook يوصل بالـ `kind` (metadata stripe / `UserDefinedField` myfatoorah) ليفعّل الاشتراك ويرفع `subscription_plan` للمستخدم؛ باقات مُزرعة بـ data migration؛ صفحة `/subscriptions` تعرض الباقات + باقتك الحالية + زر اشتراك (تدخل `/register` للزوار، والدفع يفعّل فوراً).
23. **الأدوار والصلاحيات (أغسطس 2026 — RBAC شامل)**: نظام أدوار موحد عبر `UserRole` (FK table) — `RoleService` الموحّد يدير التعيين/الإزالة/التحقق؛ `RoleRequest` للمستخدمين لطلب أدوار (instructor/publisher/service_provider) مع موافقة الأدمن؛ `SchoolStaff` لإدارة طاقم المدرسة؛ `SchoolManagerRequest` لنقل ملكية المدارس؛ الدورات/الكتب/الخدمات تستخدم FK إلى `UserRole` (وليس User مباشرة) عبر `instructor_role`/`author_role`/`provider_role`；تسجيل مبسّط (ادخار student/parent مع تأكيد البريد → دور `user` افتراضياً). الصلاحيات في `apps/users/permissions.py` بـ `SECTION_ROLES` — `school_admin` نطاقه مدرسته فقط.
24. **المدارس SIS (أغسطس 2026)**: تطبيق `apps/schools` (14) — نماذج School (`manager` FK), AcademicYear, Section, StudentEnrollment, TeacherAssignment, SchoolAnnouncement (`is_emergency`), FamilyLink, AnnouncementReadReceipt, ParentTeacherTicket, WhatsAppNotificationLog, UserAISetting, WeeklyReport, FAQ, SupportRequest, Attachment؛ endpoints: schools/academic-years/sections/enrollments/teacher-assignments/announcements/tickets/family-links/faqs/attachments + user/settings + my-context + voice/transcribe + voice/synthesize + analytics (ساعات الذروة) + weekly-summary + support/email + bulk/import/export؛ استيراد مدارس الأردن الرسمية `fetch_opendata_schools` (7,296 مدرسة). واجهة `/school-followup`. — تغطي المرحلتين 1-2 من `afaq-school-profile` جزئياً.
25. **Gamification UI (أغسطس 2026)**: صفحة `/gamification` (نقاط، شارات، إنجازات، تحديات، سلسلة، مستوى) — الواجهة الأمامية مكتملة (كانت Backend-only).
26. **صفحات الخدمات الهجينة (أغسطس 2026)**: `/services/[slug]` تُعرض CMS-first عبر `BlockRenderer` (بلوكات من `/pages/services/{slug}/`) مع fallback مطابق بصرياً مبني من namespace `services` في i18n (7 خدمات)؛ سلاكات غير معروفة → `notFound()`؛ أُزيل `services` من `RESERVED_PREFIXES` في `[...slug]`. مساعد `resolveLink()` في `src/lib/i18n.ts` يمنع إضافة بادئة locale للروابط المطلقة (mailto/http/tel) والروابط `#`.
27. **إصلاح صور الدورات — كاش الـ Service Worker (أغسطس 2026)**: كانت الصور لا تُحمّل إلا بعد Ctrl+Shift+R لأن `sw.js` كان يعترض كل GET (بما فيها الصور الخارجية) ويخدم نسخاً قديمة من كاش لا يُمسح. الآن `public/sw.js` يعترض **التنقّل فقط** (`if (event.request.mode !== "navigate") return;`) فتمر الصور/الملفات/`/api/` من الشبكة دائماً؛ كاش التنقّل **cache-first للسرعة + تحديث خلفي دوري** (TTL 5 دقائق عبر ختم `x-sw-cached-at`)؛ الكاش **v2** (`afaq-tech-v2`) يُفرّغ v1 القديم عند التفعيل؛ `next.config.ts` يضيف `Cache-Control: no-cache` لمسار `/sw.js`؛ و`src/lib/useApi.ts` يفعّل `revalidateOnFocus`+`revalidateOnReconnect` (تحديث قوائم الدورات عند العودة للتبويب دون تحديث قسري). إشعارات push (معالجا push/notificationclick + `src/store/notifications.ts`) لم تتأثر.
28. **القوائم متعددة الاختيار (أغسطس 2026)**: `MenuItem.service_context` و `MenuItem.required_role` → `ArrayField` (مصفوفات، مهاجرة `pages/0015` تحوّل البيانات: قيمة مفردة ← مصفوفة و`all` ← القائمة الكاملة؛ **فارغة = الكل/للجميع** — لا خيار "all"). `ChoiceListField` في `apps/pages/serializers.py`؛ فلترة الشريط الجانبي في `MenuPublicView` بـ `service_context__contains=[context]` مع عرض العام (فارغ) أولاً؛ واجهة `/admin/menus` عبر مكوّن `MultiSelectDropdown` (الكل محدد افتراضياً + تحديد/إلغاء الكل + شارات "كل الصفحات/كل الأدوار")؛ `ContextualSidebar.roleAllowed` يدعم مصفوفات الأدوار؛ `seed_menus.py` يستخدم `ALL_CONTEXTS`/`ALL_ROLES`؛ ترجمات `selectAll`/`deselectAll`/`allPages`/`noSelection` في 10 لغات.
29. **المحتوى المدفوع + محفظة الأرباح (أغسطس 2026)**: الدورات والكتب أصبحت مدفوعة — `Course.access_level`/`Ebook.access_level` (free/basic/pro/enterprise) + `is_free`/`price`/`platform_fee_percent` (10%)؛ شراء مدى الحياة عبر `CoursePurchase`/`EbookPurchase` (عبر واجهة الدفع الموحّدة، `kind:course_purchase`/`kind:ebook_purchase`)؛ `can_access`/`is_purchased` في التفاصيل؛ `activate_course_purchase` ينشئ Enrollment مدى الحياة ويسجّل ربح المدرب، `activate_ebook_purchase` يفتح التنزيل ويسجّل ربح المؤلف؛ قفل بـ 402/403؛ المحفظة `Wallet` + `WalletTransaction` و`credit_earnings()`؛ واجهة الدورة تعرض زر "اشترِ الآن" ووصول مدى الحياة وبنرات الدفع؛ اختبارات `tests/test_paid_content.py`.
30. **إعداد الجداول الدراسية SIS (أغسطس 2026)**: معمارية نظام إعداد الجداول الدراسية في `afaq-school-profile` عبر الحصص اليومية `Period` والقاعات/المختبرات `Room` وخانات الجدول الأسبوعية `TimetableSlot` مع محرك منع التعارضات الثلاثية (تعارض المعلم، تعارض الشعبة، تعارض القاعة) وشبكة بصرية تفاعلية (Matrix Grid) وتوليد آلي ذكي (Smart Auto-Scheduler) وشاشات مخصصة لمدير المدرسة، المعلم، ولي الأمر، والطالب.
31. **التقويم المدرسي وأيام الدوام (أغسطس 2026)**: تخصيص `week_start` و `working_days` لكل مدرسة (معياري ISO 1..7)؛ ترحيل TimetableSlot؛ تكييف المجدول التلقائي وتنبيعات الغياب والتقارير؛ تبويب إعدادات التقويم في لوحة المدرسة (`/school/admin/settings`).
32. **نظام الفحص الأمني وضمان الجودة (أغسطس 2026)**: خط أنابيب CI شامل (gitleaks, bandit, pip-audit, npm audit)؛ وكلاء تدقيق متخصصين (`security-audit`, `user-flow-qa`, `visual-qa`); بيئة اختبار معزولة (`:8004`/`:3001`); تحصين اشتراكات المحتوى المدفوع (`get_subscription_level()`) وتأمين مرفقات المدارس برأس `Content-Disposition: attachment` وحظر الامتدادات الخطرة.
33. **واجهة Directorate Dashboard (أغسطس 2026)**: `896c9a1` — 6 endpoints (dashboard/stats/schools/comparison/alerts) + DRF serializers + صفحة dashboard بـ 4 تبويبات (نظرة عامة برسوم 14 يوم + مدارس بجدول + مقارنة بترتيب + تنبيهات ذكية) + ا تسجيل في Django Admin + Sidebar nav item + i18n (28 مفتاح × 10 لغات).
34. **واجهة Google Classroom (أغسطس 2026)**: `e197469` — صفحة تكامل كاملة (دورات مع تحديد + استيراد طلاب فردي/جماعي + تصدير درجات + سجل مزامنة) + 2 endpoints جديد (sync logs + disconnect) + هجرة Sidebar `0021` + i18n (52 مفتاح × 10 لغات).
35. **واجهة Voice AI / TTS (أغسطس 2026)**: `b8caae9` — مكون `AudioPlayer` (TTS مع 3 مزوّدات + سرعة + إعدادات) + مكون `VoiceRecordButton` (STT عبر MediaRecorder) + تكامل في صفحة تفاصيل الدرس (بناء نص من هيكلية الخطة) وصفحة الدردشة (إدخال صوتي) + i18n (14 مفتاح × 10 لغات).
```

---

*آخر تحديث: 21 أغسطس 2026 — واجهات الخدمات الثلاث مكتملة (Directorate + Google Classroom + Voice AI)*
