# دليل خدمة Google Classroom — التكامل والشرح التفصيلي

> تاريخ الإنشاء: 22 أغسطس 2026
> آخر تحديث: 22 أغسطس 2026
> الحالة: ✅ المدير مكتمل — 📋 المعلم والطالب قيد التخطيط

---

## 1. ما هي خدمة Google Classroom؟

**Google Classroom** هو نظام إدارة التعلم من Google يُستخدم في المدارس والجامعات. يربط المعلمون والطلاب عبر دورات رقمية تحتوي درجات وواجبات وتقييمات.

**تكامل المنصة مع Google Classroom** يعني:
- البيانات تتدفق بين المنصة و Google Classroom
- لا حاجة لإدخال الدرجات يدوياً في كلا النظامين
-.Student/teacher data sync automatically

---

## 2. هل يحتاج كل شخص حساب Google؟

| الدور | يحتاج حساب Google؟ | السبب |
|-------|---------------------|-------|
| **المدير (Admin)** | ✅ نعم | يربط حسابه مرة واحدة للسماح للمنصة بالوصول لـ Classroom |
| **المعلم (Teacher)** | ✅ نعم (اختياري) | يربط حسابه لرؤية دوراته وإرسال درجات فصليه |
| **ولي الأمر (Parent)** | ❌ لا | لا يتفاعل مع Classroom مباشرة |
| **الطالب (Student)** | ❌ لا | فقط يُرى بيانات Classroom في المنصة |

**ملاحظة مهمة:** حساب Google واحد (حساب المدير) يكفي لعملية **استيراد الطلاب**. لكن كل معلم يريد إرسال درجات من فصليه يحتاج حساباً منفصلاً.

---

## 3. الميزات حسب الدور

### 👨‍💼 المدير — صفحة مكتملة `/school/admin/google-classroom`

#### ماذا يمكنه فعله:

**1. ربط حساب Google**
- يضغط "ربط حساب Google"
- يُنتقل لصفحة Google للإذن
- يختار حسابه → يعود للمنصة مرتبطاً
- التوكن يُحدّث تلقائياً كل ساعة

**2. استيراد الطلاب من Google Classroom**
- يرى قائمة دوراته في Classroom
- يحدد دورات بالتحديد (فردي أو جماعي)
- يضغط "استيراد الطلاب"
- الطلاب يُضافون تلقائياً للمنصة مع بياناتهم

**3. تصدير الدرجات إلى Google Classroom**
- يختار دورة من Classroom
- يختار قسم (شعبه) من المنصة
- يُرسل الدرجات من المنصة إلى Classroom
- يظهر في Classroom كدرجات "مسودة" (Draft)

**4. عرض سجل المزامنة**
- يرى تاريخ كل عملية (استيراد/تصدير)
- يرى عدد الطلاب المُستوردين
- يرى حالة كل عملية (نجاح/فشل/جزئي)

#### شاشة الاتصال:
```
┌─────────────────────────────────────────────┐
│  🔗 تكامل Google Classroom                 │
├─────────────────────────────────────────────┤
│  الحالة: ✅ متصل بحساب Google               │
│  آخر مزامنة: 22/08/2026 10:30 ص             │
│                                             │
│                    [قطع الاتصال]            │
├─────────────────────────────────────────────┤
│  [الدورات]  [تصدير الدرجات]  [سجل المزامنة]│
├─────────────────────────────────────────────┤
│  الدورات:                                   │
│  ☑ فيزياء 101  (35 طالب)  [استيراد]        │
│  ☐ رياضيات 201 (28 طالب)  [استيراد]        │
│  ☑ كيمياء 101  (32 طالب)  [استيراد]        │
│                                             │
│  [استيراد الطلاب المحددة (2)]               │
└─────────────────────────────────────────────┘
```

---

### 👨‍🏫 المعلم — قيد التخطيط `/teacher/classroom`

#### ماذا سيتمكن من فعله (مخطط له):

**1. ربط حساب Google الخاص به**
- كل معلم يربط حسابه الشخصي (منفصل عن المدير)
- هذا يسمح له بالوصول لدوراته في Classroom

**2. عرض دوراته في Classroom**
- يرى الدورات التي يُدرّسها في Google Classroom
- يربط كل دورة بقسم في المنصة

**3. مزامنة الواجبات من Classroom**
- الواجبات التي ينشئها في Classroom تظهر في المنصة
- لا يحتاج لإعادة إنشائها

**4. إرسال درجات فصليه إلى Classroom**
- يُقيّم الطلاب في المنصة (كما يفعل عادياً)
- يُرسل الدرجات إلى Classroom بنقرة واحدة
- الدرجات تظهر كمسودة في Classroom

#### لماذا يحتاج المعلم حساب Google؟
لأنه يُرسل بيانات **إلى** Classroom (درجات فصليه) — هذا يتطلب توكن OAuth خاص به.

---

### 🎓 الطالب — قيد التخطيط `/student/classroom`

#### ماذا سيتمكن من فعله (مخطط له):

**1. عرض دوراته المتزامنة**
- يرى الدورات التي ينتمي إليها في Classroom
- لا يحتاج لربط أي حساب

**2. عرض درجاته من Classroom**
- درجات Classroom تظهر في صفحة درجاتي
- لا يحتاج لإدخالها يدوياً

**3. عرض واجباته من Classroom**
- واجبات Classroom تظهر في صفحة واجباتي
- يرى المواعيد النهائية والتقييمات

#### لماذا لا يحتاج الطالب حaccount Google؟
لأنه فقط **يُقرأ** البيانات — لا يُرسل شيئاً إلى Classroom.

---

## 4. سير العمل الكامل

```
1. المدير يربط حسابه بـ Google Classroom
   ↓
2. المدير يستورد الطلاب من Classroom إلى المنصة
   ↓
3. المعلم يربط حسابه بـ Google Classroom (اختياري)
   ↓
4. المعلم يُقيّم الطلاب في المنصة
   ↓
5. المعلم يُرسل الدرجات إلى Classroom
   ↓
6. الطالب يرى درجاته في المنصة (من Classroom + المنصة)
```

---

## 5. الإعداد التقني

### 5.1 متطلبات Google Cloud Console

**1. إنشاء مشروع في Google Cloud Console**
- اذهب إلى https://console.cloud.google.com
- أنشئ مشروع جديد أو اختر مشروع موجود

**2. تفعيل Google Classroom API**
- APIs & Services → Library
- ابحث عن "Google Classroom API"
- اضغط "Enable"

**3. إنشاء OAuth 2.0 Credentials**
- APIs & Services → Credentials
- اضغط "Create Credentials" → "OAuth client ID"
- Application type: "Web application"
- Authorized redirect URIs أضف:
  ```
  http://localhost:8003/api/v1/auth/google/callback/
  http://localhost:8003/api/v1/core/google-classroom/callback/
  ```

**4. إعداد OAuth Consent Screen**
- APIs & Services → OAuth consent screen
- User Type: "External" (للتطوير) أو "Internal" (للمنصة)
- أضف Scopes المطلوبة:
  ```
  https://www.googleapis.com/auth/classroom.courses.readonly
  https://www.googleapis.com/auth/classroom.coursework.students
  https://www.googleapis.com/auth/classroom.rosters.readonly
  https://www.googleapis.com/auth/classroom.student-submissions.students.readonly
  ```
- أضف مستخدمين تجريبيين (Test users) إذا كان التطبيق في وضع Testing

### 5.2 إعدادات `.env`

```bash
# Google OAuth (لتسجيل الدخول)
GOOGLE_OAUTH_CLIENT_ID=你的-client-id
GOOGLE_OAUTH_CLIENT_SECRET=你的-client-secret
GOOGLE_REDIRECT_URI=http://localhost:8003/api/v1/auth/google/callback/

# Google Classroom (لتكامل Classroom)
GOOGLE_CLASSROOM_REDIRECT_URI=http://localhost:8003/api/v1/core/google-classroom/callback/
```

**ملاحظة:** `GOOGLE_CLASSROOM_CLIENT_ID` و `GOOGLE_CLASSROOM_CLIENT_SECRET` يأخذان نفس قيم `GOOGLE_OAUTH_CLIENT_ID` و `GOOGLE_OAUTH_CLIENT_SECRET` تلقائياً (يمكنك استخدام حساب Google واحد للكل).

### 5.3 إعادة تشغيل السيرفر

```bash
cd backend
source venv/bin/activate
export SENTRY_DSN_BACKEND=""
python manage.py runserver --noreload 0.0.0.0:8003
```

---

## 6. حل المشاكل الشائعة

### ❌ خطأ "redirect_uri_mismatch"

**السبب:** عنوان URL المُعاد إلى Google لا يتطابق مع المسجل في Google Cloud Console.

**الحل:**
1. اذهب إلى Google Cloud Console → Credentials
2. اضغط على OAuth 2.0 Client ID
3. تأكد من وجود **كلتا** العناوين:
   ```
   http://localhost:8003/api/v1/auth/google/callback/
   http://localhost:8003/api/v1/core/google-classroom/callback/
   ```
4. اضغط Save
5. أعد المحاولة في نافذة Incognito

### ❌ خطأ "تم حظر إمكانية الوصول"

**السبب:** التطبيق في وضع Testing ولم تُضاف بريدك كـ Test User.

**الحل:**
1. Google Cloud Console → OAuth consent screen
2. اضغط "Add users" under Test users
3. أضف بريدك الإلكتروني
4. احفظ

### ❌ الاتصال ينقطع عند التنقل بين التبويبات

**السبب:** كان النظام يستدعي Google API في كل مرة → إذا انتهى التوكن يُظهر "غير متصل".

**الحل (مُنجز):** الآن يستخدم endpoint خفيف (`/status/`) لا يحتاج Google API + التوكن يُحدّث تلقائياً.

### ❌ لا يمكن ربط حساب Google

**التحقق:**
1. تأكد من تشغيل السيرفر على المنفذ 8003
2. تأكد من صحة `GOOGLE_OAUTH_CLIENT_ID` و `GOOGLE_OAUTH_CLIENT_SECRET` في `.env`
3. تأكد من أن Google Classroom API مفعّل في المشروع
4. افتح Console في المتصفح وتأكد من عدم وجود أخطاء

---

## 7. نقاط النهاية (API Endpoints)

### للمدير (Admin)
```
GET  /core/google-classroom/status/          — فحص الاتصال (خفيف)
GET  /core/google-classroom/auth/            — رابط ربط الحساب
GET  /core/google-classroom/callback/        — معالجة العودة من Google
GET  /core/google-classroom/courses/         — قائمة الدورات
POST /core/google-classroom/import/students/ — استيراد طلاب
POST /core/google-classroom/export/grades/   — تصدير درجات
GET  /core/google-classroom/sync/logs/       — سجل المزامنة
POST /core/google-classroom/disconnect/      — فصل الاتصال
```

### للمعلم (Teacher) — قيد التطوير
```
GET  /core/google-classroom/teacher/status/       — فحص اتصال المعلم
GET  /core/google-classroom/teacher/auth/         — رابط ربط حساب المعلم
GET  /core/google-classroom/teacher/courses/      — دورات المعلم
POST /core/google-classroom/teacher/sync-assignments/ — مزامنة واجبات
POST /core/google-classroom/teacher/send-grades/  — إرسال درجات فصليه
```

### للطالب (Student) — قيد التطوير
```
GET /core/google-classroom/student/courses/     — دورات الطالب
GET /core/google-classroom/student/grades/      — درجات الطالب
GET /core/google-classroom/student/assignments/ — واجبات الطالب
```

---

## 8. هيكل قاعدة البيانات

### GoogleClassroomToken — توكن الاتصال
```python
class GoogleClassroomToken(models.Model):
    user = OneToOneField(User)        — المستخدم (مدير/معلم)
    access_token = TextField()        — توكن الوصول
    refresh_token = TextField()       — توكن التحديث
    token_expiry = DateTimeField()    — تاريخ انتهاء الصلاحية
    classroom_id = CharField()        — معرف Classroom (اختياري)
    synced_at = DateTimeField()       — آخر مزامنة
    created_at = DateTimeField()      — تاريخ الإنشاء
    updated_at = DateTimeField()      — تاريخ التعديل
```

### GoogleClassroomSyncLog — سجل المزامنة
```python
class GoogleClassroomSyncLog(models.Model):
    user = ForeignKey(User)           — من قام بالعملية
    sync_type = CharField()           — import_students / export_grades / sync_assignments
    course_id = CharField()           — معرف الدورة
    status = CharField()              — success / partial / failed
    details = JSONField()             — تفاصيل العملية (عدد المُستوردين/المُرسلين)
    created_at = DateTimeField()      — تاريخ العملية
```

### GoogleClassroomCourseSync — ربط الدورات (مخطط له)
```python
class GoogleClassroomCourseSync(models.Model):
    teacher = ForeignKey(User)        — المعلم
    classroom_course_id = CharField() — معرف دورة Classroom
    classroom_course_name = CharField() — اسم الدورة
    platform_section = ForeignKey(Section) — القسم في المنصة (اختياري)
    last_synced = DateTimeField()     — آخر مزامنة
```

---

## 9. ملخص الحالة

| الميزة | المدير | المعلم | الطالب |
|--------|--------|--------|--------|
| ربط حساب Google | ✅ مكتمل | 📋 مخطط | ❌ غير مطلوب |
| عرض الدورات | ✅ مكتمل | 📋 مخطط | 📋 مخطط |
| استيراد الطلاب | ✅ مكتمل | ❌ | ❌ |
| إرسال الدرجات | ✅ مكتمل | 📋 مخطط | ❌ |
| مزامنة الواجبات | ❌ | 📋 مخطط | ❌ |
| عرض الدرجات | ❌ | ❌ | 📋 مخطط |
| عرض الواجبات | ❌ | ❌ | 📋 مخطط |

---

*آخر تحديث: 22 أغسطس 2026 — دليل شامل لخدمة Google Classroom*
