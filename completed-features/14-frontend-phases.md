# واجهات الخدمات الثلاث — Frontend Phases 1-3

> تاريخ الإنشاء: 21 أغسطس 2026
> الحالة: ✅ مكتمل
> Commits: `896c9a1`, `e197469`, `b8caae9`

---

## 1. الملخص

بناء واجهات أمامية كاملة لثلاث خدمات خلفية كانت مدعومة بالكامل في الباك إند لكن تحتاج واجهات مستخدم:

1. **لوحة تحكم المديريات** — Directorate Dashboard
2. **تكامل Google Classroom** — Google Classroom Integration
3. **الخدمات الصوتية** — Voice AI / TTS UI

---

## 2. المرحلة الأولى: Directorate Dashboard (`896c9a1`)

### Backend (مُنشأ في هذه الجلسة)
- `backend/apps/core/directorate_serializers.py` — DRF serializers لـ Directorate + DirectorateStats
- `backend/apps/core/directorate_views.py` — 6 view classes معروضة:
  - `DirectorateListView` — قائمة المديريات
  - `DirectorateDashboardView` — ملخص KPIs (إجمالي المدارس/الطلاب/المعلمين/الحضور/الدرجات)
  - `DirectorateStatsView` — سلسلة زمنية 30 يوم (حضور + درجات + طلاب)
  - `DirectorateSchoolsView` — مدارس مع KPIs فردية + ترتيب حسب الأداء
  - `DirectorateComparisonView` — مقارنة مدارس مع ترتيب ونقاط
  - `DirectorateAlertsView` — تنبيهات ذكية (حضور <80%، درجات <60، واجبات معلقة)
- `backend/apps/core/admin.py` — تسجيل Directorate + DirectorateStats في Django Admin

### Frontend
- `frontend/src/app/[locale]/admin/directorates/page.tsx` — صفحة كاملة:
  - قائمة المديريات مع بطاقات تفاعلية
  - Dashboard بـ 5 بطاقات KPI
  - 4 تبويبات: نظرة عامة (رسوم 14 يوم)， المدارس (جدول)， المقارنة (ترتيب + ميداليات)， التنبيهات
  - نظام حالة: excellent/good/fair/needs_attention بألوان مميزة

### i18n
- 28 مفتاحاً × 10 لغات تحت `admin.directorates`

---

## 3. المرحلة الثانية: Google Classroom (`e197469`)

### Backend (مُنشأ في هذه الجلسة)
- `backend/apps/core/classroom_views.py` — 2 views جديدة:
  - `GoogleClassroomSyncLogsView` — GET سجل المزامنة (آخر 50 سجل)
  - `GoogleClassroomDisconnectView` — POST قطع الاتصال
- `backend/apps/core/urls.py` — 2 URL patterns جديدة

### Frontend
- `frontend/src/app/[locale]/school/admin/google-classroom/page.tsx` — صفحة كاملة:
  - بطاقة حالة الاتصال (متصل/غير متصل + ربط/قطع)
  - تبويب الدورات — جدول مع تحديد + استيراد طلاب (فردي/جماعي)
  - تبويب تصدير الدرجات — اختيار دورة + شعبة
  - تبويب سجل المزامنة — تاريخ العمليات
- `backend/apps/pages/migrations/0021_seed_google_classroom_menu_item.py` — هجرة Sidebar (order=410)

### i18n
- 52 مفتاحاً × 10 لغات تحت `school.googleClassroom`

---

## 4. المرحلة الثالثة: Voice AI / TTS UI (`b8caae9`)

### مكونات جديدة
- `frontend/src/components/school/AudioPlayer.tsx`:
  - مشغل TTS مع 3 مزوّدات (Edge/Gemini/ElevenLabs)
  - تحكم بالسرعة (0.5x-2.0x)
  - زر play/stop مع إعدادات
  - يستدعي `POST /schools/voice/synthesize/` ويشغل `audio/mpeg`
- `frontend/src/components/school/VoiceRecordButton.tsx`:
  - زر تسجيل صوتي عبر `MediaRecorder` API
  - يرسل للـ `POST /schools/voice/transcribe/`
  - يعرض مدة التسجيل + حالة التحويل
  - يُعيد النص المُتحوّل عبر callback

### التكاملات
- `frontend/src/app/[locale]/lesson-plans/[id]/page-client.tsx`:
  - يبني نص TTS من هيكلية الخطة (العنوان + الأهداف + المقدمة + الأنشطة + التقييم + الواجب)
  - AudioPlayer مدمج في أزرار الهيدر
- `frontend/src/app/[locale]/chat/page.tsx`:
  - VoiceRecordButton مدمج بجانب حقل الإدخال
  - النص المُتحوّل يملأ تلقائياً حقل الرسالة

### i18n
- 14 مفتاحاً × 10 لغات تحت `school.voice`

---

## 5. الإحصائيات

| العنصر | العدد |
|--------|-------|
| ملفات جديدة | 8 |
| ملفات معدلة | 36 |
| إجمالي السطور | ~2,600 |
| مفاتيح i18n جديدة | 94 |
| ترجمات (94 × 10) | 940 |
| Commits | 3 |

---

*آخر تحديث: 21 أغسطس 2026*
