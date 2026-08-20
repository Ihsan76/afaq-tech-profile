# خطة إضافة واجهات الفرونتايند للخدمات الخلفية (Upcoming Frontend Features)

> **تاريخ الإنشاء**: 20 أغسطس 2026
> **آخر تحديث**: 21 أغسطس 2026
> **الحالة**: ✅ جميع المراحل مكتملة

---

## 1. مقدمة
بناءً على مراجعة معمارية المنصة، تم تحديد 3 خدمات أساسية مدعومة بالكامل في الخلفية (Backend APIs) واحتاجت إلى واجهات أمامية مخصصة (Frontend UI) لتفعيلها بالكامل للمستخدمين والإداريين.

---

## 2. المشاريع — ✅ جميعها مكتملة

### أ. لوحة تحكم مديرية التربية والتعليم (Directorate Dashboard) ✅
* **المسار:** `/admin/directorates`
* **الحالة:** مكتمل — `896c9a1`
* **المكونات:**
  * صفحة قائمة المديريات مع بطاقات تفاعلية
  * Dashboard بـ 5 بطاقات KPI (إجمالي المدارس/الطلاب/المعلمين/نسبة الحضور/متوسط الدرجات)
  * 4 تبويبات: نظرة عامة (رسوم 14 يوم)، المدارس (جدول)، المقارنة (ترتيب)، التنبيهات
* **Backend endpoints:**
  * `GET /core/directorates/` — قائمة المديريات
  * `GET /core/directorates/<id>/dashboard/` — ملخص KPIs
  * `GET /core/directorates/<id>/stats/` — سلسلة زمنية 30 يوم
  * `GET /core/directorates/<id>/schools/` — مدارس مع KPIs
  * `GET /core/directorates/<id>/comparison/` — مقارنة مرتّبة
  * `GET /core/directorates/<id>/alerts/` — تنبيهات ذكية
* **ملفات:**
  * `backend/apps/core/directorate_serializers.py` — DRF serializers
  * `backend/apps/core/directorate_views.py` — 6 view classes
  * `frontend/src/app/[locale]/admin/directorates/page.tsx` — صفحة كاملة
* **i18n:** 28 مفتاح × 10 لغات (`admin.directorates.*`)

### ب. واجهة التكامل مع Google Classroom ✅
* **المسار:** `/school/admin/google-classroom`
* **الحالة:** مكتمل — `e197469`
* **المكونات:**
  * بطاقة حالة الاتصال (متصل/غير متصل + ربط/قطع)
  * تبويب الدورات — جدول مع تحديد + استيراد طلاب (فردي/جماعي)
  * تبويب تصدير الدرجات — اختيار دورة + شعبة
  * تبويب سجل المزامنة — تاريخ العمليات
* **Backend endpoints (جديد):**
  * `GET /core/google-classroom/sync/logs/` — سجل المزامنة
  * `POST /core/google-classroom/disconnect/` — قطع الاتصال
* **ملفات:**
  * `frontend/src/app/[locale]/school/admin/google-classroom/page.tsx` — صفحة كاملة
  * `backend/apps/pages/migrations/0021_seed_google_classroom_menu_item.py` — هجرة Sidebar
* **i18n:** 52 مفتاح × 10 لغات (`school.googleClassroom.*`)

### ج. واجهة الخدمات الصوتية والذكاء الاصطناعي الصوتي (Voice AI / TTS UI) ✅
* **المسار:** مدمج في `/lesson-plans/[id]` و `/chat`
* **الحالة:** مكتمل — `b8caae9`
* **المكونات:**
  * `AudioPlayer` — مشغل TTS مع اختيار المزوّد (Edge/Gemini/ElevenLabs) والسرعة (0.5x-2.0x)
  * `VoiceRecordButton` — زر تسجيل صوتي مع تحويل آلي للنص
* **Integrations:**
  * صفحة تفاصيل خطة الدرس — زر "استماع للدرس" في الهيدر
  * صفحة الدردشة — زر "إدخال صوتي" بجانب حقل الرسالة
* **ملفات:**
  * `frontend/src/components/school/AudioPlayer.tsx` — مكون TTS
  * `frontend/src/components/school/VoiceRecordButton.tsx` — مكون STT
* **i18n:** 14 مفتاح × 10 لغات (`school.voice.*`)

---

## 3. ملخص الإنجاز

| المرحلة | الميزة | الحالة | Commit | التاريخ |
|---------|--------|--------|--------|---------|
| 1 | Directorate Dashboard | ✅ مكتمل | `896c9a1` | 21 أغسطس 2026 |
| 2 | Google Classroom | ✅ مكتمل | `e197469` | 21 أغسطس 2026 |
| 3 | Voice AI / TTS UI | ✅ مكتمل | `b8caae9` | 21 أغسطس 2026 |

**إجمالي الملفات المُنشأة/المعدّلة:** 44 ملفاً، ~2,600 سطر
**إجمالي مفاتيح i18n المُضافة:** 94 مفتاحاً × 10 لغات = 940 ترجمة

---

*آخر تحديث: 21 أغسطس 2026 — جميع المراحل مكتملة ✅*
