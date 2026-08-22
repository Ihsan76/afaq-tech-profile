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
8. **[دليل Google Classroom الشامل (`05-google-classroom-guide.md`)](./05-google-classroom-guide.md)** — شرح تفصيلي للخدمة، من يحتاج حساب Google، الميزات لكل دور، الإعداد التقني، وحل المشاكل

---

## حالة التنفيذ الفعلية (أغسطس 2026)

> تُنفَّذ داخل **تطبيق `apps/schools`** في مستودع آفاق (`/mnt/data/Projects/afaq-tech/afaq-tech/backend/apps/schools/`).

| الجزء | الحالة | ملاحظات |
|-------|--------|---------|
| 1. الرؤية | 📋 خطة | — |
| 2. SIS Core | 🟡 **جزئي (مُنجز معظم النماذج)** | School/`manager`، AcademicYear، Section، StudentEnrollment، TeacherAssignment، FamilyLink، Attachment، AnnouncementReadReceipt، FAQ، SupportRequest + أدوار RBAC (`school_admin`). **متبقي**: دورة العام الدراسي (أرشفة/ترفيع/انتقالات)، أسماء المستخدمين الفريدة التلقائية |
| 3. المتابعة الذكية | 🟡 **جزئي** | واجبات/إعلانات مبوبة + تأكيد قراءة ✅؛ تذاكر ولي الأمر/المعلم ✅؛ مرفقات بمراجعة إدارية ✅؛ تقارير أسبوعية جزئية (`WeeklyReport` + `weekly-summary/`) |
| 4. واتساب الطوارئ | 🟢 **مُنجز (أساسي)** | `send_whatsapp_alert` (WhatsApp Cloud API + mock fallback) + `WhatsAppNotificationLog` + إعلان طارئ `is_emergency` |
| 5. المساعد الذكي RAG | 🟢 **مُنجز** | إعدادات المستخدم (`UserAISetting` + `user/settings/`) ✅؛ صوت STT/TTS (`voice/transcribe|synthesize`) ✅؛ RAG مع `apps/academics` متاح؛ **واجهة صوتية مكتملة**: `AudioPlayer` (TTS) + `VoiceRecordButton` (STT) مدمجة في صفحات الدرس والدردشة |
| 6. التنفيذ | 🟢 **مكتمل** | جميع المرحلتين 1-2 مكتملتان |
| 7. الصوت واللوحات | 🟢 **مكتمل** | `analytics/` (ساعات الذروة + عداد الإعلانات الطارئة/المرفقات المعلقة) + مرفقات `review` + `faqs/` + `support/email/` |
| 8. التكاملات الخارجية | 🟢 **مكتمل** | Google Classroom (OAuth + استيراد/تصدير + سجل مزامنة) — واجهة كاملة مدمجة |
| 9. المديريات | 🟢 **مكتمل** | Directorate Dashboard — 6 endpoints + صفحة dashboard بـ 4 تبويبات |

**الواجهة الأمامية**: صفحة `/school-followup` (متابعة مدرسية) + لوحة إدارة مدارس في `/admin/schools` + `/admin/directorates` (المديريات) + `/school/admin/google-classroom` (Google Classroom).
