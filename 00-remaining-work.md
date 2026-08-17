# العمل المتبقٍ — آفاق تقنية (أغسطس 2026)

> آخر تحديث: 17 أغسطس 2026
> الغرض: تتبع دقيق لكل ما تم وما بقي لاستكمال المشروع

---

## نظرة عامة

| المجال | نسبة الإنجاز |
|--------|:---:|
| **SIS Backend** | ~98% |
| **SIS Frontend** | ~90% |
| **السوق والمدفوعات** | ~100% |
| **الدورات والكتب** | ~100% |
| **التلعيب** | ~100% |
| **المصادقة والأدوار** | ~100% |
| **الترجمات** | ~100% |
| **الإجمالي** | ~92% |

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

## 🔶 جزئي — يحتاج إكمال

### 1. تحسين تفاصيل الصفحات — **أولوية عالية**
- بعض الصفحات قد تحتاج تحسين التفاعل
- التحقق من اكتمال جميع الروابط والتنقلات

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
- **التكامل والبنية التحتية**: دمج Celery في `requirements.txt`، إصلاحات خطوط أنابيب CI وحراسة الأمان (`.gitleaksignore` لملف `render.yaml`، السماح بـ 404 لـ QA EXTRA_ROUTES)، وحل كافة تحذيرات ruff و eslint و linter عبر الخلفية والواجهة الأمامية.
---

## ❌ لم يبدأ — بنود مستقبلية

### أولوية منخفضة
| المجال | التفاصيل |
|--------|----------|
| Matrix Grid Builder | سحب وإفلات يدوي للجدول |
| TTS حقيقي | Gemini/ElevenLabs |
| IndexedDB | مزامنة بدون إنترنت |
| Directorate Dashboard | متابعة عدة مدارس |
| WebSocket | إشعارات فورية + محادثات |
| Elasticsearch | بحث متقدم |
| React Native | تطبيق موبايل |
| GDPR/CCPA/COPPA | توافق تنظيمي |
| Lighthouse >90 | أداء |
| CSP headers | أمان |
| pg_dump + S3 | نسخ احتياطي |
| Google Classroom | تكامل خارجي |

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
8. تصدير كشف الدرجات إلى PDF — مُلغى (يمكن إضافته لاحقاً)

### المرحلة 2: الواجبات (Assignments) ✅
1. ~~إنشاء موديلات `Assignment` و `AssignmentSubmission` في `apps/schools/models.py`~~ ✅
2. ~~إنشاء serializer و ViewSet~~ ✅
3. ~~تسجيل Routes في `urls.py`~~ ✅
4. ~~إنشاء migration~~ ✅ (0020)
5. ~~واجهة `/teacher/assignments` (إنشاء + مراجعة)~~ ✅
6. ~~واجهة `/student/assignments` (عرض + حالة التسليم)~~ ✅
7. ~~واجهة `/parent/assignments` (عرض)~~ ✅

### المرحلة 3: تحسين الصفحات
1. مراجعة جميع صفحات الأدوار الأربع
2. تحسين التنقل والتفاعل
3. إضافة أي بيانات مفقودة
