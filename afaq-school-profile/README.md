# وثيقة وملف تعريف منصة آفاق المدرسية الذكية
## Afaq Smart School & Family Collaboration Platform - Comprehensive Profile

هذه الوثيقة التعريفية والتنظيمية الشاملة لمنصة **"آفاق للمتابعة المدرسية الذكية"** (مشابهة لهيكلية `afaq-tech-profile`)، وتغطي رؤية المشروع، البنية التنظيمية (SIS Core)، نظام المتابعة الذكية، ربط الواتساب للطوارئ، الذكاء الاصطناعي، ومراحل التنفيذ.

---

## فهرس الأقسام (Documentation Index)

1. [الرؤية والاهداف (`part-01-vision/01-overview.md`)](./part-01-vision/01-overview.md)
2. [البنية التنظيمية وقاعدة البيانات SIS (`part-02-sis-core/01-architecture-database.md`)](./part-02-sis-core/01-architecture-database.md)
   - [هيكلية مساحة العمل وتوزيع الشاشات حسب الصلاحيات (`part-02-sis-core/02-workspace-architecture.md`)](./part-02-sis-core/02-workspace-architecture.md)
3. [نظام المتابعة الذكية والتواصل (`part-03-collaboration/01-smart-followup.md`)](./part-03-collaboration/01-smart-followup.md)
4. [تكامل إشعارات الواتساب الطارئة (`part-04-whatsapp/01-emergency-alerts.md`)](./part-04-whatsapp/01-emergency-alerts.md)
5. [المساعد الذكي والمنهاج RAG (`part-05-ai-tutoring/01-copilot-rag.md`)](./part-05-ai-tutoring/01-copilot-rag.md)
6. [مراحل وخطة التنفيذ (`part-06-implementation/01-phases.md`)](./part-06-implementation/01-phases.md)
7. [الصوت ولوحات التحكم والدعم الفني (`part-07-voice-analytics/01-voice-dashboards.md`)](./part-07-voice-analytics/01-voice-dashboards.md)

---

## حالة التنفيذ الفعلية (أغسطس 2026)

> تُنفَّذ داخل **تطبيق `apps/schools`** في مستودع آفاق (`/mnt/data/Projects/afaq-tech/afaq-tech/backend/apps/schools/`).

| الجزء | الحالة | ملاحظات |
|-------|--------|---------|
| 1. الرؤية | 📋 خطة | — |
| 2. SIS Core | 🟡 **جزئي (مُنجز معظم النماذج)** | School/`manager`، AcademicYear، Section، StudentEnrollment، TeacherAssignment، FamilyLink، Attachment، AnnouncementReadReceipt، FAQ، SupportRequest + أدوار RBAC (`school_admin`). **متبقي**: دورة العام الدراسي (أرشفة/ترفيع/انتقالات)، أسماء المستخدمين الفريدة التلقائية |
| 3. المتابعة الذكية | 🟡 **جزئي** | واجبات/إعلانات مبوبة + تأكيد قراءة ✅؛ تذاكر ولي الأمر/المعلم ✅؛ مرفقات بمراجعة إدارية ✅؛ تقارير أسبوعية جزئية (`WeeklyReport` + `weekly-summary/`) |
| 4. واتساب الطوارئ | 🟢 **مُنجز (أساسي)** | `send_whatsapp_alert` (WhatsApp Cloud API + mock fallback) + `WhatsAppNotificationLog` + إعلان طارئ `is_emergency` |
| 5. المساعد الذكي RAG | 🟡 **جزئي** | إعدادات المستخدم (`UserAISetting` + `user/settings/`) ✅؛ صوت STT/TTS (`voice/transcribe|synthesize`) ✅؛ RAG مع `apps/academics` متاح؛ **متبقي**: FAQ Copilot |
| 6. التنفيذ | 🟡 **المرحلتان 1-2 قيد التنفيذ** | راجع `part-06-implementation/01-phases.md` للتفاصيل |
| 7. الصوت واللوحات | 🟢 **أساسي مُنجز** | `analytics/` (ساعات الذروة + عداد الإعلانات الطارئة/المرفقات المعلقة) + مرفقات `review` + `faqs/` + `support/email/` |

**الواجهة الأمامية**: صفحة `/school-followup` (متابعة مدرسية — تتضمن الصوت) + لوحة إدارة مدارس في `/admin/schools`.
