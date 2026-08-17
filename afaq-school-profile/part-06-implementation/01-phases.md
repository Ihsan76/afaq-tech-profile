# الجزء السادس: خطة ومراحل التنفيذ (Implementation Phases)

لضمان إنجاز المشروع بكفاءة عالية، تُقسم مراحل التطوير إلى الآتي:

## الحالة الفعلية (أغسطس 2026)

> التنفيذ يتم داخل تطبيق `apps/schools` في مستودع آفاق. **المراحل 1-3 مكتملة بالكامل** (نواذج + APIs + واجهات + AI + واتساب)، والمرحلة 4 (الاختبار والتدقيق) قيد التحقق.

* **المرحلة الأولى: الهيكل التنظيمي وقاعدة البيانات (SIS Core)** — ✅ **مكتملة**
  * نماذج المدارس، السنوات الدراسية، الصفوف، الشعب، وإسناد المعلمين. ✅ منجز (School, AcademicYear, Section, StudentEnrollment, TeacherAssignment)
  * أسماء مستخدمين فريدة تلقائية (`student.{national_id}@student.local` / `teacher.{national_id}@teacher.local`). ✅ منجز
  * دورة العام الدراسي: أرشفة، ترفيع سنوي مع `dry_run` و`atomic`، تتبع التخرج، ترحيل المعلمين. ✅ منجز
  * أدوات الاستيراد والتصدير (Bulk Import/Export via Excel/CSV) لكشوفات الطلاب والمعلمين. ✅ منجز (7,296 مدرسة أردنية رسمية مستوردة)

* **المرحلة الثانية: نظام المتابعة الذكية وتكامل الواتساب** — ✅ **مكتملة**
  * لوحات الواجبات والتنبيهات مع تأكيد القراءة (Acknowledgment). ✅ منجز (SchoolAnnouncement + AnnouncementReadReceipt + واجهة `/school-followup`)
  * نظام التذاكر المنظمة بين ولي الأمر والمعلم. ✅ منجز (ParentTeacherTicket)
  * WhatsApp Cloud API لإرسال الإشعارات الطارئة والغياب. ✅ منجز (`send_whatsapp_alert` + `notify_absence` + `send_absence_alerts` + Biometric Webhook)

* **المرحلة الثالثة: المساعد الذكي والتفاعل الصوتي** — ✅ **مكتملة**
  * دمج RAG مع كتب ومناهج المنصة. ✅ أساسي منجز (Curriculum Injection + `curricula/resolve/`)
  * FAQ Copilot: رد آلي بالـ AI مع بحث قاعدة بيانات أولاً. ✅ منجز (`FAQCopilotAPIView` + `ProviderRouter`)
  * إعدادات المساعد الذكي لكل مستخدم. ✅ منجز (UserAISetting + `user/settings/`)
  * تجربة الصوت (STT/TTS) وساعات الذروة. ✅ منجز (`voice/transcribe` + `voice/synthesize` + `analytics/`)

* **المرحلة الرابعة: الاختبار والتدقيق والإطلاق** — 🟡 قيد التحقق
  * اختبارات `apps/schools` ناجحة (88 اختبار عبر pytest) ✅
  * TypeScript نظيف (`tsc --noEmit`) ✅
  * `manage.py check` بدون مشاكل ✅
  * الإطلاق التجريبي مع مدرسة نموذجية — قيد الترتيب
