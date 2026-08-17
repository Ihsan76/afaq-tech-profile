# الملحق 04: قائمة الأعمال المتبقية حسب الأولوية

> حالة المسح: أغسطس 2026 — بناءً على الفحص الفعلي للكود (backend 14 apps + frontend) ووثائق `afaq-school-profile`.

## 🔴 P0 — حرجة للمنصة الحية (afaq.app)

- [ ] **1. مفاتيح الدفع الفعلية: MyFatoorah Live** (Stripe غير متاح للتاجر الأردني) — في `.env` على Render + `apps/marketplace/payments/` — الدفع اليوم يعرض "غير متاح" (`payment_available=false`)
  - ⏳ **معلّق خارجي**: MyFatoorah لم يتواصلوا بعد (آخر متابعة: أغسطس 2026) — الكود جاهز (`myfatoorah_provider.py` يقرأ `MYFATOORAH_API_TOKEN`/`BASE_URL`/`PAYMENT_METHOD_ID`/`WEBHOOK_SECRET`) ويفعّل فور توفّر المفاتيح، بلا تعديل
  - خيارات بديلة: التواصل مجدداً مع MyFatoorah، أو التحقق من مزوّد آخر متاح في الأردن (HyperPay / Madfu / 123Pay) مع إضافة provider جديد في `payments/registry.py`
- [x] **2. Google OAuth**: تعبئة Client ID/Secret/Redirect URI — في `backend/.env` — التدفّق مكتمل لكنه معطّل بلا مفاتيح
  - ✅ **الكود + الاعتماديات جاهزان** (Client ID/Secret موجودان في `.env`، `GoogleLoginView`/`GoogleCallbackView`، زر `GoogleButton` في login/register، صفحة callback في الواجهة)
  - ✅ **مُنجز**: تعبئة المفاتيح في Render (`GOOGLE_OAUTH_CLIENT_ID/SECRET` + `GOOGLE_REDIRECT_URI=https://api.afaq.app/api/v1/auth/google/callback/`) → افحص الإنتاج: `302` إلى Google؛ تسجيل الدخول يعمل على afaq.app (أغسطس 2026)
- [x] **3. النسخ الاحتياطي اليومي** (pg_dump) + اختبار الاستعادة — Render cron / Supabase — لا يوجد أي backup حالياً
  - ✅ **مُنجز (أغسطس 2026)**: عملان على GitHub Actions — `db-backup.yml` (cron يومي 01:20 UTC: `pg_dump` custom عبر session pooler :5432 → رفع إلى بكت خاص `afaq-backups` في Supabase Storage بمسار `backups/`، استبقاء 14 يوماً) + `restore-test.yml` (فحص يدوي/أسبوعي: تنزيل أحدث نسخة + `pg_restore --list` + تحقق من الجداول الرئيسية PASS). الأسرار في GitHub: `DATABASE_URL`, `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`
  - ⚠️ **ملاحظات تقنية**: استخدم `PG*` env بدل `${{ secrets }}` في GITHUB_OUTPUT (GitHub يستبدل الأسرار بـ `***`)؛ عميل PostgreSQL **17** لمطابقة خادم Supabase 17.6 (استخدام المسار `/usr/lib/postgresql/17/bin/...` بسبب تعارض v16 في PATH)؛ نقطة التنزيل الصحيحة `/storage/v1/object/{bucket}/{path}` وليس `/download/`
- [x] **4. أمان: CSP headers** + WAF/Page rules في Cloudflare — `settings/base.py` + Cloudflare — لا CSP اليوم، وCloudflare بلا قواعد
  - ✅ **CSP + الترويسات منجزة (أغسطس 2026)**: `apps/core/middleware.py` (Middleware CSP للـ API: `default-src 'none'` + COOP/CORP/Permissions-Policy/Referrer) — تم التحقق في `api.afaq.app`. الـ frontend: `next.config.ts → async headers()` (CSP بـ media-src للمايك في `/school-followup`، frame-src لـ YouTube، connect-src لـ api.afaq.app/Supabase) — تم التحقق في `www.afaq.app`.
  - ✅ **Cloudflare قواعد منشورة (أغسطس 2026)** — عبر `05-cloudflare-rules.sh` (نشر + تحقق):
    1. **Rate Limiting** (`http_ratelimit`): حظر `/api/v1/auth/*` — 10 طلبات/10ث لكل (IP+colo)، حظر 10ث — **فُعّل** (الخطة الأساسية تسمح بـ period=10 فقط وmitigation=10 فقط)
    2. **WAF** (`http_request_firewall_custom`): حظر `/admin/` + `/api/v1/auth/admin/` من كل IP إلا `213.139.43.228` — **فُعّل**
    3. **Cache Rules** (`http_request_cache_settings`): تجاوز تخزين `/api/*` و`/robots.txt`+`/sitemap.xml`؛ تخزين سنة لـ`/_next/static/` و`/static/` (دjango) — **فُعّل** وتحقق (robots.txt=DYNAMIC، static=HIT)
    - ⚠️ **قيود خطة Free اكتُشفت أثناء النشر**: إنشاء ruleset عبر `POST /zones/{id}/rulesets` (وليس مسار phase entrypoint)؛ `characteristics` يتطلب `cf.colo.id`؛ لا يدعم `matches` ولا `starts_with` في الـ rate limit (استخدم `contains`)؛ `action_parameters.response` غير مسموح؛ قاعدة rate limit واحدة فقط؛ التوكن يتطلب Account Rulesets Edit + تضمين الحساب في Account Resources
    - التوكن المستخدم: `Edit zone DNS` (Zone WAF+Cache Rules Edit + Account Rulesets Edit، فلتر IP `213.139.43.228`)
- [x] **5. ترجمة رسائل أخطاء DRF** (الإنجليزية حالياً) — serializers + `messages/*.json` — لتحسين تجربة المستخدم
  - ✅ **مُنجز (أغسطس 2026)** — commit `cc1ab50`: طبقة ترجمة في الواجهة (`frontend/src/lib/apiErrors.ts` — `extractApiError` يستخرج الرسالة من أي شكل خطأ DRF `detail`/`error`/`non_field_errors`/حقول، و`apiErrorKey` يطابق 48 رسالة إنجليزية معروفة → مفاتيح). أُضيف namespace `errors` (39 مفتاحاً) لكل ملفات `messages/*.json` العشرة. استُخدمت في `login`/`register`/`verify-email` + `store/auth.ts` (بدل `includes()` والمطابقة النصية). تم التحقق في الإنتاج: النصوص العربية حاضرة في HTML `/ar/login`. ملاحظة: المفاتيح الجديدة في الملفات الثابتة فقط — لم تُزرع في `TranslationKey` (DB) بعد؛ إن أراد الأدمن إدارتها شغّل `manage.py seed_translations`.
- [x] **6. متابعة رفع Google Safe Browsing flag** لـ www/api — مراجعة قيد الانتظار — خطر تحذير المتصفح
  - ✅ **مُزَال (أغسطس 2026)** — أُكّد المستخدم أن التحقق تم وأن الموقعين www/api آمنان الآن ولا يظهر تحذير المتصفح. لا متابعة إضافية.

## 🟠 P1 — ميزات منصّة معلّقة (أثر مباشر)

- [x] **7. نظام الإشعارات** (Push) + تبويب داخل الموقع — تطبيق جديد `apps/notifications`
  - ✅ **مُنجز (أغسطس 2026)** — commit `88d578d`: تطبيق `apps/notifications` كامل (نماذج `Notification` بعناوين/نصوص JSON متعددة اللغات + `PushSubscription`؛ `services.notify()`/`notify_many()`؛ `webpush.py` بـ pywebpush اختياري مع `normalize_vapid_key` ومسح 404/410؛ 5 endpoints `/api/v1/notifications/`: قائمة، `unread-count/`, `mark-read/`, `push/subscription/` GET/POST/DELETE, `push/public-key/`؛ أمر `generate_vapid_keys`؛ migration 0001). نقاط الإطلاق: دفع (`payments/base.mark_order_paid`)، طلب/إلغاء/اكتمال/مراجعة (`marketplace/views.py`)، إعلان مدرسي جماعي عبر `StudentEnrollment`+`FamilyLink` ورد تذكرة (`schools/views.py`)، تفعيل باقة (`subscriptions/services.py`)، شارة (`gamification/services.BadgeAwarder`). `notify()` يبادئ `link` بـ locale (`localize_link`). الواجهة: `store/notifications.ts` (استطلاع 30s، mark-read، اشتراك/إلغاء push)، `components/NotificationBell.tsx` (جرس بعدّاد + قائمة منسدلة + مفتاح push)، `app/[locale]/notifications/page.tsx` (قائمة كاملة + فلتر الكل/غير المقروءة)، `public/sw.js` (push + click-to-open)، إضافة للـ Navbar، namespace `notifications` + `nav.notifications` في ملفات الرسائل العشرة. 7 اختبارات backend + كل الـ 75 تمر. **يدوي متبقٍّ على المستخدم**: شغّل `manage.py generate_vapid_keys` وأضف `VAPID_PUBLIC_KEY`/`VAPID_PRIVATE_KEY`/`VAPID_SUBJECT` في Render env ليُفعَّل Web Push (حتى ذلك الحين الإشعارات داخل الموقع تعمل والمفتاح يظهر معطّلاً).
- [x] **8. بحث متقدم** (PostgreSQL FTS) + إكمال تلقائي — `apps/courses`/`blog` + `/search`
  - ✅ **مُنجز (أغسطس 2026)**: نقطة نهاية الإكمال التلقائي الشامل (`/api/v1/core/search/autocomplete/`) تبحث في الدورات (`apps/courses`)، المقالات (`apps/blog`)، والكتب الإلكترونية (`apps/ebooks`)؛ وتحديث صفحة الواجهة الأمامية `/search` لدعم التصفح المبوب (الكل، الدورات، المقالات، الكتب)، نتائج بحث فورية، إكمال تلقائي أثناء الكتابة، وتكامل مع قواعد البيانات (يدعم FTS و icontains fallback).
- [x] **9. PWA / Offline** (Service Worker + IndexedDB) — `frontend/` manifest + SW
  - ✅ **مُنجز (أغسطس 2026)**: إضافة `manifest.json`، وتحديث Service Worker (`sw.js`) للتخزين المؤقت والتصفح بدون إنترنت، وإنشاء مساعد IndexedDB (`offlineStore.ts`)، وتسجيل الخدمة تلقائياً في الجذر.
- [x] **10. محفظة Wallet + Payouts للمزوّدين + رسوم السوق** — `apps/marketplace/payments/`
  - ✅ **مُنجز (أغسطس 2026)**: نماذج `Wallet` (OneToOne→user، رصيد/عملة)، `WalletTransaction` (sale_earning/platform_fee/payout/deposit/refund مع reference_id)، `PayoutRequest` (pending/approved/rejected/paid + bank_details) + migration `0005`. عند إتمام أي طلب (`mark_order_paid` في `payments/base.py`) تُخصم **عمولة المنصة 10%** ويُودَع 90% في محفظة المزوّد مع تسجيل حركة. Endpoints: `wallet/` (رصيد + حركات)، `wallet/transactions/`، `payouts/` (إنشاء + تحقق رصيد)، `payouts/mine/`، `admin/payouts/` (قائمة بفلتر حالة)، `admin/payouts/<id>/process/` (approve/reject/mark_paid — يُخصم الرصيد عند الدفع). إدارة كاملة في Django Admin (Wallet + حركات + Payouts). 6 اختبارات جديدة (81 إجمالاً تمر).
- [x] **11. فصل server wrappers للصفحات `"use client"` → `generateMetadata`** — `app/[locale]/**` (SEO/SSR)
  - ✅ **مُنجز (أغسطس 2026)** — commit `82951d7`: فُصلت 22 صفحة عامة إلى `page.tsx` (server wrapper مع `generateMetadata`) + `page-client.tsx` (المكوّن "use client") — منها الرئيسية، `[...slug]`، المدوّنة، الكتب، الأكاديمية/الدورات، المناهج (3 مستويات)، خدمات السوق (CMS + marketplace)، البحث، الباقات، خطط الدروس، صفحات الخصوصية/الشروط/المصادقة. مكتبة جديدة `frontend/src/lib/metadata.ts` (server-only): `buildMetadata` يولّد canonical محلي + hreflang لكل اللغات العشر + OpenGraph + robots، مع دوال جلب SEO من APIs (`getCmsPageSeo`/`getBlogPostSeo`/`getEbookSeo`/`getCourseSeo`/`getServiceSeo`/`getCurriculumSeo`). مكوّن `JsonLd.tsx` + `StaticPageWrapper.tsx` يضيفان JSON-LD (WebSite/BlogPosting/Book/Course/Service/LearningResource/WebPage) في الـ SSR. التحقق: `tsc` نظيف، lint 0 أخطاء، build إنتاجي ناجح.
- [x] **12. كشف Accept-Language** في middleware + OG/JSON-LD لكل صفحة — `proxy.ts`
  - ✅ **مُنجز (أغسطس 2026)** — commit `82951d7`: `frontend/src/proxy.ts` يلفّ next-intl middleware ويضيف كشفاً صريحاً لـ `Accept-Language` (تحليل q-weights + fallback لأساس اللغة مثل `ar-SA`→`ar`) ويضبط ترويسات `x-locale` و`Content-Language` و`Vary: Accept-Language, Cookie`. كل صفحة عامة الآن تحمل OG + JSON-LD محلي (انظر البند 11).
- [x] **13. اختبارات جودة**: cross-browser + mobile + RTL + اللغات العشر — CI
  - ✅ **مُنجز (أغسطس 2026)** — commit `7644c5e`: `frontend/tests/qa/smoke.mjs` (سكربت Node بلا اعتماديات) يجري **2151 فحصاً** على اللغات العشر × المسارات الرئيسية: HTTP 200، `<html lang>`، اتجاه RTL/LTR (ar/ur/fa RTL)، وصف `meta description`، canonical، hreflang (كل اللغات + x-default)، OpenGraph، JSON-LD، وتمريرة Mobile User-Agent. أُضيف سكربت `npm run test:qa` + وظيفة **qa** في `.github/workflows/ci.yml` (build → next start → smoke). **إصلاح SEO**: جذر `app/layout.tsx` يصدّر الآن `<html lang>/dir` من الخادم عبر `getLocale()` (كان يُضبط عميلاً فقط). التحقق: tsc نظيف، lint 0 أخطاء، smoke 0 إخفاقات. ملاحظة: يشمل هذا نطاق cross-browser بالمعنى العملي (فحص SSR/هيكلية لكل اللغات + أجهزة الجوال)؛ مصفوفة متصفحات حقيقية (Playwright) متاحة كتحسين مستقبلي.

## 🟡 P2 — منصة المدارس SIS (afaq-school-profile)

- [x] **13+. جعل آفاق مدرستي**  تعمل وتدار من ضمن afaq.app/ar/school  وذلك لتسهيل تسويقه ونشره / ابقي على افاق منهاجي منفصل  — **منفّذ (أغسطس 2026)**
  - ✅ commit `9968904`: نقل صفحة المتابعة إلى `afaq.app/ar/school` مع تحويل 308 من `/school-followup` (القديم محجوز في proxy + `[...slug]`).
  - ✅ commit `fd372c0`: صفحة تسويقية عامة في `/school` للزوار غير المسجّلين (Hero + 6 ميزات + كيف تعمل + CTA تسجيل/دخول)، مع بقاء لوحة المتابعة للمسجّلين؛ رابط «آفاق منهاجي» منفصل نحو `/curriculum`.
- [x] **14. دورة العام الدراسي**: أرشفة / ترفيع سنوي / انتقالات برمز تحويل — **منفّذ (أغسطس 2026)**
  - ✅ **منفّذ**: واجهة إدارية متكاملة للأعوام الدراسية (`/admin/schools` تبويب الأعوام): نموذج إنشاء عام دراسي جديد، إشارة أرشيف للأعوام السابقة، نافذة تنفيذ الترفيع السنوي (Annual Promotion) مع اختيار العام المستهدف وعرض تقرير ملخص بالطلاب المُرفَعين والمُتخطَّين، ونافذة تحويل الطلاب برمز أو رقم وطني (`transfer_by_code`) لأي شعبة مستهدفة. وترجمات كاملة في اللغات العشر.
- [ ] **15. أسماء مستخدمين فريدة تلقائية** (student./teacher./parent.) — غير منفّذ
- [ ] **16. FAQ Copilot** (رد آلي بالـAI) + تصنيف الدعم — غير منفّذ
- [ ] **17. تقارير أسبوعية آلية** كاملة لولي الأمر — جزئي
- [ ] **18. لوحة المديرية** (Directorate) + الإطلاق التجريبي مع مدرسة — غير منفّذ
- [x] **19. إشعار غياب تلقائي** بالواتساب عند عدم تسجيل الحضور — **منفّذ (أغسطس 2026)**
  - ✅ commit `852bdc2`: نموذج `Attendance` (فريد لكل طالب/تاريخ) + migration 0008؛ `AttendanceViewSet` مع `bulk_record` وفلترة section/date بصلاحيات الأدوار؛ `notify_absence()` (واتساب + إشعار داخل المنصة لولي الأمر، متكرر-السلامة)؛ أمر `send_absence_alerts` (`--date/--include-weekend/--dry-run`)؛ `my-context`/`analytics`/`weekly-summary` تعيد بيانات الحضور الآن؛ تبويب الحضور في `/school` (تسجيل للمعلم/المدير + عرض للطالب/ولي الأمر) + ترجمات اللغات العشر. الاختبارات: 133 backend تمر.


## 🟢 P3 — توسع مستقبلي

- [ ] **20. WebSocket** (Channels): إشعارات فورية + حصص مباشرة
- [ ] **21. تطبيق موبايل** (React Native / Expo)
- [ ] **22. التوافق مع اللوائح** (GDPR / CCPA / COPPA)
- [ ] **23. Elasticsearch** + موازين أداء (TTFB/LCP)
- [ ] **24. Git hooks** (pre-commit) + CI للتغطية + JSON logging
