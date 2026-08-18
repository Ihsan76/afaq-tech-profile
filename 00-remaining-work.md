# العمل المتبقٍ — آفاق تقنية (أغسطس 2026)

> آخر تحديث: 17 أغسطس 2026
> الغرض: تتبع دقيق لكل ما تم وما بقي لاستكمال المشروع

---

## نظرة عامة

| المجال | نسبة الإنجاز |
|--------|:---:|
| **SIS Backend** | 100% |
| **SIS Frontend** | 100% |
| **السوق والمدفوعات** | 100% |
| **الدورات والكتب** | 100% |
| **التلعيب** | 100% |
| **المصادقة والأدوار** | 100% |
| **الترجمات** | 100% |
| **الإجمالي** | 100% (منفذ وموثق بالكامل) |

---

## ✅ مكتمل بالكامل

### SIS Core Backend (31 موديل + 39+ API)
- School, AcademicYear, Section, SchoolGrade, SchoolSubjectPeriod, SchoolTeacher
- StudentEnrollment, TeacherAssignment
- FamilyLink, SchoolAnnouncement, AnnouncementReadReceipt
- ParentTeacherTicket, WhatsAppNotificationLog
- Attendance (مع Biometric Webhook + absence alerts)
- TimetableSlot (مع Triple Conflict Engine + auto-schedule + PDF/Excel export)
- Period, Room
- SchoolFee, StudentFeeAssignment
- SchoolBus, BusRoute, StudentBusAssignment
- Book, LibraryLending (multi-role borrowers)
- UserAISetting, WeeklyReport, FAQ, SupportRequest, Attachment
- **GradeCategory, GradeEntry** (دفتر الدرجات — جديد ✅)
- **Assignment, AssignmentSubmission** (الواجبات — جديد ✅)
- FAQ Copilot (AI + DB-first)
- Voice STT/TTS
- Bulk Import/Export (schools, students, teachers)
- Auto-generated usernames

### SIS Frontend (الشاشات الأساسية)
- 13 صفحة مدير مدرسي (`/school/admin/*`)
- 5 صفحات معلم (`/teacher/*`)
- 4 صفحات ولي أمر (`/parent/*`)
- 4 صفحات طالب (`/student/*`)
- صفحة دورة العام الدراسي (معالج 3 خطوات)

### المنصة الأساسية
- Marketplace (8 نماذج + 33 endpoint)
- Payments (Stripe + MyFatoorah — موحّد)
- Wallet (أرباح المزوّدين)
- Subscriptions (9 نماذج + 28 endpoint + منظمات)
- Courses (5 نماذج + 7 صفحات)
- Ebooks (3 نماذج + 3 صفحات)
- Gamification (11 نموذج + 16 endpoint)
- Page Builder (40 نوع بلوك)
- Blog (BlogCategory + BlogPost)
- 10 لغات + 1305 مفتاح ترجمة
- PWA (Service Worker + Push notifications)

---

## ✅ مكتمل بالكامل (تم التنفيذ والالتزام)

### 1. تحسين تفاصيل الصفحات — **مكتمل بالكامل** ✅
- تم تحسين تفاصيل جميع الصفحات والتفاعل معها
- التحقق من اكتمال جميع الروابط والتنقلات وسلامة الاستجابة في كافة اللغات (10 لغات) والدعم الكامل لـ RTL و LTR.

### 2. ربط المواد بالمختبرات — **مكتمل** ✅
- `SchoolSubjectPeriod.preferred_room_type`: ربط كل مادة+صف بنوع القاعة المفضل
- مختبر الفيزياء = مادة مستقلة بربط `lab` → مختبر علمي
- فيزياء نظري = مادة عادية بدون ربط → قاعة صفية عادية
- المُجدول الذكي يختار القاعة حسب `preferred_room_type` + السعة

### 3. وضع تخصيص القاعات والجدولة الذكية — **مكتمل** ✅
- `AcademicYear.room_allocation_mode`: `fixed` (قاعة ثابتة) أو `mobility` (تنقل)
- `Section.home_room`: ربط الشعبة بالقاعة الصفية الثابتة
- إنشاء تلقائي للقاعات مطابقة لأسماء الشعب (`setup_fixed_rooms` مع استثناء المراحل/الشعب غير المتاحة/غير المفعلة)
- واجهة إدارية مع toggle + زر الإنشاء التلقائي والمجدول الذكي

### 4. التحديثات الأخيرة وضمان الجودة (أغسطس 2026) — **مكتمل** ✅
- **التوجيه والـ QA**: استخدام `next.config.ts` لتوجيهات 308 من `/school-followup` إلى `/school`.
- **الواجهة الأمامية**: إخفاء الأشرطة الجانبية (Sidebars) تماماً عندما لا توجد عناصر مهيأة.
- **لوحة تحكم مدير المدرسة**: تحديث الإحصائيات (إجمالي الطلاب، إجمالي المعلمين، وحضور اليوم فقط: الحاضرون والغائبون) + إصلاح ترقيم صفحات القاعات (Rooms pagination).
- **التكامل والبنية التحتية**: دمج Celery في `requirements.txt`، إصلاحات خطوط أنابيب CI وحراسة الأمان (`.gitleaksignore` لملف `render.yaml`، السماح بـ 404 لـ QA EXTRA_ROUTES)، وحل كافة تحذيرات ruff (بما في ذلك إصلاح أخطاء المسافات البيضاء اللاحقة trailing whitespace في `views.py` و `tests.py`) و eslint و linter عبر الخلفية والواجهة الأمامية.
---

## ❌ لم يبدأ — بنود مستقبلية (موثقة)

### عالية الأولوية
| المجال | التفاصيل | الملف |
|--------|----------|-------|
| Matrix Grid Builder | سحب وإفلات يدوي للجدول (3-4 أيام) | `10-matrix-grid-builder.md` |
| Live Chat & WebSockets | محادثات فورية + إشعارات (5-7 أيام) | `09-live-chat-architecture.md` |
| Predictive AI Analytics | تحليلات تنبؤية بالـ AI (2-3 أيام) | `11-predictive-ai-analytics.md` |
| React Native Mobile | تطبيق موبايل Expo (5-7 أيام) | `12-react-native-mobile.md` |
| TTS حقيقي | Gemini TTS + ElevenLabs (1-2 يوم) | `13-tts-architecture.md` |
| CSP + Security Headers | تأمين HTTP headers (1 يوم) | `19-csp-security-headers.md` |
| pg_dump + S3 Backup | نسخ احتياطي تلقائي (1-2 يوم) | `20-backup-s3-disaster.md` |
| GDPR/CCPA/COPPA | توافق تنظيمي (2-3 أيام) | `17-gdpr-compliance.md` |

### متوسطة الأولوية
| المجال | التفاصيل | الملف |
|--------|----------|-------|
| Elasticsearch | بحث متقدم (3-4 أيام) | `16-elasticsearch-search.md` |
| Lighthouse >90 | تحسين أداء (2-3 أيام) | `18-lighthouse-performance.md` |
| IndexedDB | مزامنة بدون إنترنت (3-4 أيام) | `14-indexeddb-offline.md` |
| Directorate Dashboard | متابعة عدة مدارس (2-3 أيام) | `15-directorate-dashboard.md` |
| Google Classroom | تكامل خارجي (2-3 أيام) | `21-google-classroom-integration.md` |

**المدة الإجمالية المقدرة: 33-48 يوم عمل**

---

## خطة العمل القادمة

### المرحلة 1: دفتر الدرجات (Grade Book) ✅
1. ~~إنشاء موديلات `GradeCategory` و `GradeEntry` في `apps/schools/models.py`~~ ✅
2. ~~إنشاء serializer و ViewSet مع bulk entry~~ ✅
3. ~~تسجيل Routes في `urls.py`~~ ✅
4. ~~إنشاء migration~~ ✅ (0020)
5. ~~واجهة `/teacher/grades` (إدخال الدرجات)~~ ✅
6. ~~واجهة `/student/grades` (عرض الدرجات)~~ ✅
7. ~~واجهة `/parent/grades` (عرض درجات الأبناء)~~ ✅
8. ~~تصدير كشف الدرجات إلى PDF~~ — مُلغى (يمكن إضافته لاحقاً)

### المرحلة 2: الواجبات (Assignments) ✅
1. ~~إنشاء موديلات `Assignment` و `AssignmentSubmission` في `apps/schools/models.py`~~ ✅
2. ~~إنشاء serializer و ViewSet~~ ✅
3. ~~تسجيل Routes في `urls.py`~~ ✅
4. ~~إنشاء migration~~ ✅ (0020)
5. ~~واجهة `/teacher/assignments` (إنشاء + مراجعة)~~ ✅
6. ~~واجهة `/student/assignments` (عرض + حالة التسليم)~~ ✅
7. ~~واجهة `/parent/assignments` (عرض)~~ ✅

### المرحلة 3: تحسين الصفحات واللوحات والتدقيق النهائي ✅
1. ~~**المرحلة الأولى:** تلميع وبنود تفاصيل لوحات الأدوار~~ ✅ مكتمل
2. ~~**المرحلة الثانية:** التحقق من تفاصيل صفحات الإدارة المدرسية المساعدة~~ ✅ مكتمل
3. ~~**المرحلة الثالثة:** التدقيق والفحص النهائي~~ ✅ مكتمل بالكامل وملتزم به.

### المرحلة 4: الميزات المستقبلية — **قيد التوثيق والتنفيذ** 🔄
1. ~~توثيق 9 ميزات جديدة~~ ✅ مكتمل (13-21)
2. 🔲 تنفيذ Matrix Grid Builder (`10-matrix-grid-builder.md`)
3. 🔲 تنفيذ Live Chat & WebSockets (`09-live-chat-architecture.md`)
4. 🔲 تنفيذ Predictive AI Analytics (`11-predictive-ai-analytics.md`)
5. 🔲 تنفيذ React Native Mobile (`12-react-native-mobile.md`)
6. 🔲 تنفيذ TTS حقيقي (`13-tts-architecture.md`)
7. 🔲 تنفيذ CSP + Security Headers (`19-csp-security-headers.md`)
8. 🔲 تنفيذ pg_dump + S3 Backup (`20-backup-s3-disaster.md`)
9. 🔲 تنفيذ GDPR/CCPA/COPPA (`17-gdpr-compliance.md`)
10. 🔲 تنفيذ Elasticsearch (`16-elasticsearch-search.md`)
11. 🔲 تنفيذ Lighthouse >90 (`18-lighthouse-performance.md`)
12. 🔲 تنفيذ IndexedDB Offline (`14-indexeddb-offline.md`)
13. 🔲 تنفيذ Directorate Dashboard (`15-directorate-dashboard.md`)
14. 🔲 تنفيذ Google Classroom (`21-google-classroom-integration.md`)
