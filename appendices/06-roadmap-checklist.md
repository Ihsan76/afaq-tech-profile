# خارطة العمل والتنفيذ — منصة آفاق تكنولوجي (Afaq Tech Roadmap)

> تاريخ التحديث: أغسطس 2026
> حالة الخطة: معتمدة للانطلاق الفعلي (Build Mode)

## 📋 قائمة المهام التنفيذية (Checklist)

### 1. إصلاح صور الدورات (Academy Course Images)
- [x] التحقق من استجابة مكونات عرض الصور في `/academy` و `/academy/courses` وتأكيد عمل نطاقات `ytimg.com` و Supabase Storage.
- [x] فحص واختبار تحميل صور الأغلفة والـ thumbnails دون أخطاء CORS أو حجب.

**الإجراءات المنفذة (أغسطس 2026):**
- [x] **حصر الـ Service Worker في التنقل فقط** — `public/sw.js`: شرط `if (event.request.mode !== "navigate") return;` يمرر كل الطلبات غير التنقّل (الصور الخارجية من يوتيوب/Supabase، الملفات، `/api/`) إلى الشبكة مباشرة دون أي تدخل، فلم يعد كاش الـ SW قادراً على خدمة صور قديمة/معطوبة.
- [x] **استراتيجية تنقّل cache-first للسرعة + تحديث خلفي دوري**: عرض نسخة الكاش فوراً؛ إذا تجاوزت `x-sw-cached-at` حد `NAV_TTL_MS` (5 دقائق) يُعاد جلب الصفحة في الخلفية وتُحدَّث النسخة دون جعل المستخدم ينتظر؛ عند فشل الشبكة العودة للصفحة المخزنة (أوفلاين).
- [x] **ترقية كاش الـ SW إلى `afaq-tech-v2`** — معالج `activate` يحذف كاش v1 القديم تلقائياً عند التفعيل، فيشفى جميع المستخدمين المتأثرين بالصور المعطوبة دون تدخل.
- [x] **`Cache-Control: no-cache` لمسار `/sw.js`** في `next.config.ts` لانتشار النسخة الجديدة فوراً عبر Vercel/Cloudflare.
- [x] **تحديث SWR**: تفعيل `revalidateOnFocus: true` + `revalidateOnReconnect: true` في `src/lib/useApi.ts` — عند تعديل صورة دورة من الأدمين ثم العودة للتبويب تُحدَّث القائمة تلقائياً دون Ctrl+Shift+R.
- [x] **التحقق**: `manage.py check` + `makemigrations --check --dry-run` + `tsc --noEmit` + `lint` + `next build` كلها ناجحة.

### 2. التوجيه الذكي وأزرار المصادقة (Smart Auth & Landing Navigation)
- [x] تحديث ترويسات صفحات الهبوط (`Navbar` / Landing headers) للتحقق من حالة المصادقة (`useAuthStore`).
- [x] تحويل أزرار "تسجيل الدخول / إنشاء حساب" إلى "الانتقال لساحة العمل" للمستخدمين المسجلين.
- [x] تعديل مسار إعادة التوجيه عند تسجيل الخروج ليُعيد المستخدم إلى صفحة الهبوط الأصلية للخدمة أو الصفحة الرئيسية بدلاً من إجباره على صفحة تسجيل الدخول. يتم التوجيه إلى صفحة الهبوط (/academy, /curriculum, /ebook, /school) إذا كان المستخدم يتصفح صفحة محمية فعلياً على مستوى أبعد عن الجذر او الى الجذر اذا كان يتصفح (مثل /dashboard أو /admin أو /profile).

### 3. بناء ساحة العمل السياقية (Contextual User Workspaces & Sidebars)
- [x] تطوير مكوّن القائمة الجانبية السياقية (`ContextualSidebar`) بحيث تعرض خيارات مخصصة حسب الخدمة (أكاديمية، كتب، منهاجي، مدرستي).
- [x] ربط القائمة الشاملة في لوحة التحكم العامة (`/dashboard`) بكافة خدمات المنصة للمستخدم المسجل.
- [x] ترتيب عرض البطاقات والخدمات المصرح بها للمستخدم داخل لوحة التحكم الخاصة بها.

### 4. نظام المحتوى المدفوع والمدربين (Courses, Ebooks & Instructor Payouts) — ✅ (مُنجز - أغسطس 2026)
- [x] تفعيل منطق التسعير والوصول الدائم (مدى الحياة - Lifetime Access) للدورات والكتب عند الشراء أو تفعيل الباقات.
- [x] ربط الدورات بالمدربين وتفعيل نظام احتساب حصص الأرباح (Revenue Share) وتكاملها مع نظام الـ Wallet / Payouts.

### 5. استراتيجية "مدرستي" و "منهاجي" (SIS & AI Curricula Models) — ✅ (مُنجز - أغسطس 2026)
- [x] تثبيت "مدرستي" (Afaq Madrasti) كخدمة مجانية بالكامل لجلب الترافيك والانتشار (تطبيق `apps/schools` مع 14 نموذجاً، استيراد 7,296 مدرسة حكومية).
- [x] تفعيل نظام مستويات الباقات والاشتراكات لـ "منهاجي" (Free, Pro, School, Enterprise) وتكاملها مع بوابة الدفع (تطبيق `apps/subscriptions` ودعم منهاجي).

### 6. القوائم متعددة الاختيار (Menu service_context / required_role Multi-select)
- [x] تحويل `service_context` و `required_role` في نموذج `MenuItem` من نص مفرد إلى مصفوفات `ArrayField` مع **مهاجرة 0015 بتحويل البيانات** تلقائياً للقيم المخزنة (قيمة مفردة ← مصفوفة؛ `all` ← القائمة الكاملة).
- [x] `ChoiceListField` في `serializers.py` — قبول وإرجاع المصفوفات مع التحقق من قيم الاختيارات.
- [x] **فلترة الشريط الجانبي**: `MenuPublicView` يعيد العناصر التي تحتوي سياق الخدمة الحالي (`service_context__contains`) مع إبقاء العناصر العامة (مصفوفة فارغة) أولاً حسب الترتيب — لا يوجد خيار "all" خاص.
- [x] **واجهة إدارة متعددة الاختيار**: مكوّن `MultiSelectDropdown` (قائمة منسدلة بخانات اختيار + تحديد/إلغاء الكل + كشف الكل عند تطابق جميع الخيارات) في `/admin/menus` لسياقات الخدمة والأدوار، والكل محدد افتراضياً.
- [x] `ContextualSidebar` — `roleAllowed` يدعم مصفوفات الأدوار (عنصر بمصفوفة فارغة/عام = للجميع؛ الاداريون يمررون دائماً؛ العضو يمرر إذا كان دوره ضمن القائمة).
- [x] `seed_menus.py` — `ALL_CONTEXTS`/`ALL_ROLES` كمصفوفات + تحديث قيم السياق للقوائم الجانبية.
- [x] ترجمات 10 لغات: `selectAll` / `deselectAll` / `allPages` / `noSelection` (مع `allRoles` القائم) في `src/i18n/messages/*.json`.
- [x] التحقق: `tsc` + `lint` + `next build` + `manage.py check` + `makemigrations --check` ناجحة.

### 7. خطة المحتوى المدفوع وحصص الأرباح (Courses/Ebooks Paid Content & Revenue Share) — معتمدة

**القرارات:**
- الدورات: `access_level` (free/basic/pro/enterprise) مثل الكتب + شراء لمرة واحدة = وصول مدى الحياة (مساران: باقة أو شراء).
- الكتب: إضافة `price` + `is_free` لشراء مدى الحياة، بجانب `access_level` القائم.
- حصة المنصة: `platform_fee_percent` قابل للضبط لكل دورة/كتاب (افتراضي 10%)، الباقي للمدرب/المؤلف عبر الـ Wallet القائم.
- السعر: دينار (JOD) بحقل سعر مفرد (تحويل متعدد العملات لاحقاً).

**A. النماذج والهجرات**
- `apps/courses/models.py`: `Course.access_level` + `Course.instructor` (FK→User nullable) + `Course.platform_fee_percent`؛ نموذج `CoursePurchase` (kind=course_purchase، user+course unique، pending/paid/refunded، payment_*، price_paid/currency/display_*، purchased_at، title property).
- `apps/ebooks/models.py`: `Ebook.price` + `is_free` + `Ebook.author` (FK→User) + `Ebook.platform_fee_percent`؛ نموذج `EbookPurchase` (kind=ebook_purchase).
- هجرات: `courses/0002` + `ebooks/0003`.

**B. واجهة الدفع**
- `apps/marketplace/payments/base.py`: فروع `mark_paid` لـ course_purchase/ebook_purchase؛ `checkout_return_path` → `academy/courses/{slug}` و `ebooks/{slug}`؛ `parse_checkout_id` بالبادئتين.
- استخراج منطق رصيد الـ wallet من `mark_order_paid` إلى مساعد `credit_earnings(user, gross, currency, reference, fee_percent)` في `apps/marketplace/payments/wallet.py` (إعادة استخدامه في السوق والخدمات الجديدة).

**C. خدمات التفعيل**
- `apps/courses/services.py`: `activate_course_purchase` — idempotent، تعليم الدفع، `Enrollment.get_or_create` (مدى الحياة)، اعتماد رصيد المدرب بعد خصم fee_percent، إشعار.
- `apps/ebooks/services.py`: `activate_ebook_purchase` — نفس المنطق.

**D. الـ Views/Serializers/URLs**
- `CourseEnrollView`: تسجيل إذا is_free أو مستوى الباقة ≥ access_level أو يوجد شراء مدفوع؛ وإلا 402.
- `EbookDownloadView` + `can_download`: السماح إذا مشترى أو الباقة كافية.
- `POST /api/v1/courses/<slug>/purchase/` + `POST /api/v1/ebooks/<slug>/purchase/` (IsAuthenticated) — إنشاء pending → create_checkout → checkout_url (+ payment_available:false).
- Serializers: `CourseDetailSerializer` (+is_purchased, can_access)، `EbookDetailSerializer` (+is_purchased, price)، `CoursePurchase/EbookPurchaseSerializer`.

**E. Admin**: حقول access_level/platform_fee_percent/price + autocomplete مدرب/مؤلف + تسجيل سجلات الشراء.

**F. Frontend**
- دورة (`academy/courses/[slug]/page-client.tsx`): شارة سعر بدل "مجاني" الثابتة؛ CTA: enrolled→تعلّم / can_access→تسجيل / وإلا بطاقة شراء (سعر + زر → checkout_url)؛ معالجة `?session_id=` (banner + mutate).
- كتاب (`ebooks/[slug]/page-client.tsx`): بطاقة الشراء مدى الحياة بجانب رابط الاشتراك؛ معالجة العودة.
- i18n: مفاتيح buyNow/buy/price/lifetime/paymentUnavailable/includedInPlan في 10 لغات + seed_translations.

**G. التحقق**: pytest (mock provider: شراء→تفعيل→Enrollment+wallet+idempotency، تسجيل بباقة، تنزيل بعد شراء) + check + makemigrations --check + ruff + tsc + lint + next build.

**H. التوثيق والنشر**: شطب القسم 4 هنا + تحديث AGENTS.md + commit/push (Vercel/Render).

### 8. التحديثات الأخيرة وشؤون القاعات والتشغيل (أغسطس 2026) — ✅ (مُنجز)
- **وضع تخصيص القاعات (Room Allocation Mode)**: دعم وضعين (`fixed` بقاعة ثابتة و `mobility` للتنقل) لكل عام دراسي، مع إنشاء القاعات تلقائياً.
- **استثناء المراحل/الشعب غير المتاحة**: تحديث `setup_fixed_rooms` لاستبعاد المراحل والشعب غير المعروضة أو غير المفعلة.
- **إعادة التوجيه (QA Redirects)**: استخدام `next.config.ts` لإضافة توجيهات 308 صحيحة من `/school-followup` إلى `/school`.
- **إخفاء الأشرطة الجانبية**: إخفاء الشريط الجانبي في الواجهة الأمامية تلقائياً عندما لا توجد عناصر مهيأة.
- **إحصائيات لوحة تحكم مدير المدرسة**: تحديث الإحصائيات لعرض إجمالي الطلاب، إجمالي المعلمين، وحضور اليوم فقط (الحاضرون والغائبون) مع إصلاح ترقيم صفحات القاعات.
- **البنية التحتية والـ CI**: دمج Celery في `backend/requirements.txt`، إضافة `.gitleaksignore` لتجاوز تنبيهات `render.yaml`، السماح بـ 404 لـ QA EXTRA_ROUTES، وإصلاح كافة تحذيرات ruff (بما في ذلك إصلاح أخطاء المسافات البيضاء اللاحقة trailing whitespace في `views.py` و `tests.py`) و eslint و lint عبر الباكند والفرونت إند.
