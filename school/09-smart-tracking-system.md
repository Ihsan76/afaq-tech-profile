# نظام التتبع الذكي وإدارة الأجهزة — التوثيق الشامل
# Smart Tracking & Device Management — Full Documentation

> **تاريخ الإنشاء:** 20 أغسطس 2026
> **آخر تحديث:** 20 أغسطس 2026
> **الحالة:** مكتمل ✅

---

## 1. ملخص المشروع

بناء نظام متكامل يدعم إدارة الأجهزة الذكية (أجهزة GPS، قارئات RFID، كاميرات التعرف على الوجه، هواتف السائقين) وربطها بمنصة آفاق لتفعيل التتبع الحي للحافلات وتسجيل الحضور والغياب آلياً.

### الأهداف:
- تتبع مواقع الحافلات لحظياً عبر GPS (أجهزة مخصصة أو هواتف السائقين).
- تسجيل صعود ونزول الطلاب تلقائياً عبر بطاقات RFID أو التعرف على الوجه.
- إدارة الأجهزة من لوحة تحكم مدرسة واحدة.
- تقديم واجهة سائق مبسطة عبر الهاتف.

---

## 2. البنية العامة للنظام (System Architecture)

```
┌─────────────────────────────────────────────────────────────────┐
│                    منصة آفاق (Afaq Platform)                     │
│         Backend: Django + DRF  |  Frontend: Next.js             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────┐    │
│  │ Devices  │  │ Telemetry│  │   Scan   │  │  Bus Live    │    │
│  │   API    │  │   API    │  │   API    │  │  Location    │    │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └──────┬───────┘    │
│       │              │              │               │            │
│  ┌────┴──────────────┴──────────────┴───────────────┴───────┐   │
│  │              PostgreSQL (Supabase)                        │   │
│  │  SchoolDevice | BusLocationLog | DeviceEvent | BusStop   │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
         ▲                    ▲                    ▲
         │                    │                    │
    ┌────┴────┐         ┌────┴────┐         ┌────┴────┐
    │ GPS/4G  │         │  RFID   │         │ Smart   │
    │ Router  │         │ Reader  │         │ Camera  │
    └────┬────┘         └────┬────┘         └────┬────┘
         │                    │                    │
    ┌────┴────────────────────┴────────────────────┴────┐
    │              الحافلة المدرسية                       │
    │  ┌──────────┐  ┌──────────┐  ┌──────────────────┐ │
    │  │ هاتف     │  │ قارئ     │  │ كاميرا + حاسوب   │ │
    │  │ السائق   │  │ RFID     │  │ مصغر (Edge PC)   │ │
    │  │ (PWA)    │  │ (Monted) │  │ + نموذج AI       │ │
    │  └──────────┘  └──────────┘  └──────────────────┘ │
    └───────────────────────────────────────────────────┘
```

---

## 3. نماذج قاعدة البيانات (Backend Models)

### 3.1 SchoolDevice (جهاز المدرسة)
النموذج الرئيسي لإدارة جميع الأجهزة المرتبطة بالمدرسة.

| الحقل | النوع | الوصف |
|-------|-------|-------|
| `school` | FK → School | المدرسة المالكة للجهاز |
| `name` | CharField | اسم الجهاز (وصفي) |
| `device_type` | Choice | نوع الجهاز: `gps_tracker`, `rfid_reader`, `facial_camera`, `mobile_app` |
| `device_identifier` | CharField (unique) | المعرف الفريد: رقم IMEI، عنوان MAC، أو معرّف مخصص |
| `api_token` | TextField | رمز الأمان الفريد لتثبيت هوية الجهاز عند كل اتصال |
| `assigned_bus` | FK → SchoolBus (nullable) | الحافلة المرتبطة بالجهاز (اختياري لأجهزة بوابة المدرسة) |
| `assigned_gate` | CharField | بوابة المدرسة التي يراقبها الجهاز (اختياري) |
| `status` | Choice | حالة الجهاز: `offline`, `online`, `maintenance` |
| `last_seen_at` | DateTimeField | آخر وقت اتصل فيه الجهاز بالنظام |

### 3.2 BusLocationLog (سجل إحداثيات الحافلات)
تخزين إحداثيات GPS اللحظية للحافلات.

| الحقل | النوع | الوصف |
|-------|-------|-------|
| `bus` | FK → SchoolBus | الحافلة المرتبطة |
| `device` | FK → SchoolDevice | الجهاز المرسل (اختياري) |
| `latitude` | DecimalField | خط العرض |
| `longitude` | DecimalField | خط الطول |
| `speed` | DecimalField | السرعة (كم/ساعة) |
| `heading` | DecimalField | اتجاه الحركة (درجات) |
| `timestamp` | DateTimeField | وقت التسجيل |

**الفهرسة:** `['bus', '-timestamp']` (للبحث السريع عن آخر موقع لكل حافلة).

### 3.3 DeviceEvent (حدث الجهاز)
تسجيل أحداث مسح البطاقات والتعرف على الوجه.

| الحقل | النوع | الوصف |
|-------|-------|-------|
| `device` | FK → SchoolDevice | الجهاز الذي سجّل الحدث |
| `event_type` | Choice | نوع الحدث: `rfid_tap`, `facial_recognition` |
| `student` | FK → User (nullable) | الطالب المُعرَّف (يتم تحديده من رقم البطاقة أو ملامح الوجه) |
| `direction` | Choice | الاتجاه: `board` (صعود), `exit` (نزول) |
| `timestamp` | DateTimeField | وقت الحدث |
| `raw_payload` | JSONField | البيانات الأولية الكاملة للحدث (للتتبع والتدقيق) |

### 3.4 BusStop (محطة الحافلة)
نقاط التجمع ومحطات خطوط السير.

| الحقل | النوع | الوصف |
|-------|-------|-------|
| `route` | FK → BusRoute | خط السير التابع له |
| `name` | CharField | اسم المحطة / النقطة |
| `latitude` | DecimalField (nullable) | خط العرض |
| `longitude` | DecimalField (nullable) | خط الطول |
| `order` | PositiveIntegerField | ترتيب المحطة في الخط |
| `is_active` | BooleanField | هل المحطة نشطة |

### 3.5 SchoolBus (حافلة مدرسية)
نموذج الحافلة الذي يربط كل الأجهزة والسائقين.

| الحقل | النوع | الوصف |
|-------|-------|-------|
| `school` | FK → School | المدرسة |
| `bus_number` | CharField | رقم الحافلة |
| `driver_name` | CharField | اسم السائق (حقل نصي — لا يربط بحساب مستخدم) |
| `driver_phone` | CharField | هاتف السائق |
| `capacity` | IntegerField | السعة الاستيعابية |

### 3.6 BusRoute (خط سير) + StudentBusAssignment (تخصيص الطالب)

- **BusRoute**: خط سير يتبع حافلة محددة (اسم الخط، وقت الصباح، وقت المساء).
- **StudentBusAssignment**: ربط طالب بخط سير ونقطة تجمع محددة.

---

## 4. نقاط النهاية البرمجية (API Endpoints)

### 4.1 إدارة الأجهزة (Device Management)
| الطريقة | المسار | الوصف | الصلاحية |
|---------|--------|-------|----------|
| GET/POST | `/api/v1/schools/devices/` | إدارة أجهزة المدرسة (إضافة / عرض / تعديل) | IsAdminOrReadOnly |
| GET/PUT/DELETE | `/api/v1/schools/devices/<id>/` | تعديل / حذف جهاز | IsAdminOrReadOnly |
| POST | `/api/v1/schools/devices/<id>/regenerate-token/` | إعادة توليد مفتاح الأمان | IsAdmin |
| POST | `/api/v1/schools/devices/<id>/heartbeat/` | إشارة أن الجهاز متصلاً | AllowAny |

### 4.2 التتبع الحي (Live Tracking)
| الطريقة | المسار | الوصف | الصلاحية |
|---------|--------|-------|----------|
| POST | `/api/v1/schools/telemetry/` | استقبال إحداثيات GPS من الأجهزة والهواتف | AllowAny |
| GET | `/api/v1/schools/buses/live/` | جميع مواقع الحافلات النشطة لحظياً | AllowAny |
| GET | `/api/v1/schools/buses/<id>/location/` | آخر موقع معروف لحافلة محددة | AllowAny |

### 4.3 تسجيل الحضور (Attendance Scanning)
| الطريقة | المسار | الوصف | الصلاحية |
|---------|--------|-------|----------|
| POST | `/api/v1/schools/scan/` | استقبال مسح بطاقات RFID / كاميرات الوجه | AllowAny |

### 4.4 إدارة النقل (Transport CRUD)
| الطريقة | المسار | الوصف | الصلاحية |
|---------|--------|-------|----------|
| GET/POST | `/api/v1/schools/buses/` | إدارة الحافلات (CRUD) | IsAdminOrReadOnly |
| GET/POST | `/api/v1/schools/bus-routes/` | إدارة خطوط السير | IsAdminOrReadOnly |
| GET/POST | `/api/v1/schools/bus-stops/` | إدارة المحطات | IsAdminOrReadOnly |
| GET/POST | `/api/v1/schools/bus-assignments/` | إدارة تخصيص الطلاب | IsAuthenticated |

---

## 5. كيف يتعرف النظام على الأجهزة (Device Recognition & Authentication)

### 5.1 تسجيل الجهاز في النظام (Device Registration)
1. يقوم **مدير المدرسة** أو **مسؤول النقل** بإضافة الجهاز في لوحة التحكم (`/school/admin/devices`).
2. يُحدد نوع الجهاز و رقمIMEI أو عنوان MAC كـ `device_identifier` فريد.
3. يُحدد الحافلة المرتبطة (إن وُجدت).
4. يولّد النظام **`api_token`** فريداً من نوع `secrets.token_hex(32)` — وهو مفتاح التوقيع السري للجهاز.
5. يتم تسجيل الجهاز في جدول `SchoolDevice` بحالة `offline`.

### 5.2 كيف يتعرف الجهاز على نفسه عند كل اتصال (API Authentication Flow)
```
الجهاز ──POST──► /api/v1/schools/telemetry/
  {
    "device_identifier": "IMEI-123456789",
    "latitude": 31.9539,
    "longitude": 35.9106,
    ...
  }

النظام يستعلم:
  device = SchoolDevice.objects.filter(device_identifier="IMEI-123456789").first()

  ├── إذا وُجد الجهاز:
  │   ├── يحدّث status → ONLINE
  │   ├── يحدّث last_seen_at → الآن
  │   └── يعالج البيانات (GPS → BusLocationLog أو Scan → DeviceEvent)
  │
  └── إذا لم يُوجد الجهاز:
      └── يرفض الطلب بـ 404 Not Found
```

### 5.3 كيف يُعدّد الجهاز ماذا يرسل (Device Configuration)
الأجهزة المعدة مسبقاً (المخصصة) تأتي مع برمجية (Firmware) مبرمجة بعنوان API المنصة ومفتاح الأمان.

لكن في حالات الأجهزة العامة (مثل كاميرا IP أو حاسوب مصغر)، يتم الإعداد عبر:

| الطريقة | الوصف | مناسب لـ |
|---------|-------|---------|
| **لوحة إعدادات الجهاز (Device Web UI)** | صفحة إدارة محلية يمكن الوصول إليها عبر المتصفح | قارئات RFID، أجهزة GPS مخصصة |
| **ملف إعداد JSON** | ملف برمجي محلي يحتوي على الـ API URL والتوكن | كاميرات AI مخصصة، Raspberry Pi |
| **تطبيق الهاتف (PWA)** | واجهة ويب تقدمية تعمل على متصفح الهاتف | هاتف السائق (لا يحتاج إعداد معقد) |

**المعلومات الأساسية المطلوبة في كل جهاز:**
```
SERVER_URL = "https://api.afaq.app/api/v1/schools/scan/"    # أو telemetry/
DEVICE_ID  = "RFID-GATE-001"                                 # المعرف الفريد
API_TOKEN  = "a1b2c3d4e5f6..."                               # رمز الأمان
POLL_INTERVAL = 10  # ثوانٍ (للمواقع اللحظية)
```

---

## 6. تفصيل آلية عمل كل نوع من الأجهزة

### 6.1 هاتف السائق (Mobile Driver Phone / PWA)

#### كيف يعمل:
- **واجهة السائق** (`/school/driver`) هي تطبيق ويب تقدمي (PWA) يعمل في متصفح الهاتف.
- لا يحتاج تثبيت من متجر التطبيقات — يعمل عبر الرابط المباشر.

#### كيف يسجل الجهاز نفسه:
1. **مسؤول النقل** يضيف الحافلة مع رقم هاتف السائق في `/school/transport`.
2. النظام يولّد تلقائياً جهازاً من نوع `MOBILE_APP` بالمعرّف `DRIVER-PHONE-{رقم_الحافلة}`.
3. السائق يفتح الرابط على هاتفه ويُدخل رقم هاتفه أو معرّف الحافلة.
4. يتعرف النظام على الجهاز ويبدأ بجمع البيانات تلقائياً.

#### ماذا يرسل الجهاز:
```
POST /api/v1/schools/telemetry/     ← كل 10 ثوانٍ
{
  "device_identifier": "DRIVER-PHONE-101",
  "latitude": 31.9539,
  "longitude": 35.9106,
  "speed": 45.0,
  "heading": 180.0,
  "timestamp": "2026-08-20T07:30:00Z"
}

POST /api/v1/schools/scan/           ← عند مسح بطاقة طالب
{
  "device_identifier": "DRIVER-PHONE-101",
  "student_id": 105,
  "event_type": "rfid_tap",
  "direction": "board",
  "timestamp": "2026-08-20T07:35:00Z"
}
```

#### وسائل مسح البطاقات من الهاتف:
- **NFC مدمج:** إذا كانت البطاقات تدعم NFC، يمكن للسائق تقريب البطاقة من الهاتف.
- **قارئ RFID خارجي:** ربط قارئ Bluetooth صغير بالهاتف لقراءة البطاقات proprietary.

---

### 6.2 قارئ البطاقات الذكية (RFID Reader)

#### كيف يعمل:
- جهاز مثبت على باب الحافلة أو بوابة المدرسة.
- مزود بشريحة اتصال (4G SIM أو Wi-Fi) أو مربوط بـ Raspberry Pi محلي.

#### كيف يُعدّد الجهاز:
1. يتم تسجيله في `/school/admin/devices` بالمعرّف مثل `RFID-GATE-001`.
2. يتم إدخال الـ API URL والـ `api_token` في لوحة إعدادات الجهاز (Device Web UI).
3. يتم تحديد البوابة (`assigned_gate`) أو الحافلة (`assigned_bus`) المرتبطة.

#### ماذا يرسل الجهاز:
```
POST /api/v1/schools/scan/           ← عند كل تمرير بطاقة
{
  "device_identifier": "RFID-GATE-001",
  "student_id": 105,                  # أو رقم البطاقة raw_payload
  "event_type": "rfid_tap",
  "direction": "board",
  "timestamp": "2026-08-20T07:30:00Z",
  "raw_payload": {
    "card_uid": "A4:B2:C3:D4:E5:F6",
    "signal_strength": -45
  }
}
```

#### معالجة الأحداث في الخلفية:
```
DeviceScanAPIView
  → يبحث عن الجهاز via device_identifier
  → يبحث عن الطالب via student_id (أو card_uid)
  → ينشئ DeviceEvent
  → يمكن أن يُنشئ سجل حضور تلقائياً (Attendance)
  → يمكن أن يُرسل تنبيه لولي الأمر عبر واتساب
```

---

### 6.3 الكاميرا الذكية وال_Find على الوجه (Smart Camera / Facial Recognition)

#### كيف تعمل الكاميرا:
- كاميرا IP متصلة بشبكة الحافلة أو المدرسة.
- مربوطة بجهاز حاسوب مصغر (Edge PC) مثل **Raspberry Pi 4** أو **NVIDIA Jetson Nano**.
- الحاسوب يشغل نموذج ذكاء اصطناعي محلي للتعرف على الوجه.

#### المكونات البرمجية على الحاسوب المصغر (Edge Agent):
```python
# مثال توضيحي — سكربت Python يعمل على الحاسوب المصغر

import cv2
import requests
import face_recognition  # أو MobileFaceNet
import sqlite3
from datetime import datetime

# --- الإعدادات ---
SERVER_URL = "https://api.afaq.app/api/v1/schools/scan/"
DEVICE_ID  = "CAM-BUS-101"
API_TOKEN  = "your_api_token_here"
KNOWN_FACES_DB = "students_faces.db"  # قاعدة بيانات محلية

# --- الخطوة 1: التقاط الفيديو من كاميرا IP ---
cap = cv2.VideoCapture("rtsp://admin:password@192.168.1.100:554/stream")

# --- الخطوة 2: تحميل الوجوه المعروفة محلياً ---
known_face_encodings = load_known_faces(KNOWN_FACES_DB)
known_face_ids = load_student_ids(KNOWN_FACES_DB)

while True:
    ret, frame = cap.read()
    if not ret:
        continue

    # --- الخطوة 3: التعرف على الوجه (AI Processing) ---
    face_locations = face_recognition.face_locations(frame)
    face_encodings = face_recognition.face_encodings(frame, face_locations)

    for (top, right, bottom, left), face_encoding in zip(face_locations, face_encodings):
        # مقارنة الوجه مع الوجوه المعروفة
        matches = face_recognition.compare_faces(known_face_encodings, face_encoding)
        face_distances = face_recognition.face_distance(known_face_encodings, face_encoding)
        best_match_index = face_distances.argmin()

        if matches[best_match_index] and face_distances[best_match_index] < 0.5:
            student_id = known_face_ids[best_match_index]

            # --- الخطوة 4: تكوين وإرسال الطلب للمنصة ---
            payload = {
                "device_identifier": DEVICE_ID,
                "student_id": student_id,
                "event_type": "facial_recognition",
                "direction": "board",
                "timestamp": datetime.utcnow().isoformat() + "Z"
            }

            try:
                response = requests.post(
                    SERVER_URL,
                    json=payload,
                    headers={"Authorization": f"Bearer {API_TOKEN}"},
                    timeout=10
                )
                if response.status_code == 200:
                    # تم التسجيل بنجاح — يمكن عرض علامة على الشاشة
                    display_confirmation(frame, top, right, bottom, left)
            except requests.exceptions.RequestException:
                # --- وضع عدم الاتصال (Offline Buffer) ---
                save_to_local_buffer(payload)
```

#### آلية عمل الحاسوب المصغر خطوة بخطوة:
```
1. التقاط فيديو مباشر من كاميرا IP عبر RTSP
         │
2. استخراج الإطارات (Frames) كل ثانية
         │
3. كشف الوجوه في الإطار (Face Detection)
         │
4. استخراج ملامح الوجه (Face Encoding)
         │
5. مقارنة مع قاعدة بيانات محلية (Local DB)
   ├── تطابق → استخراج student_id
   └── لا تطابق → تجاهل
         │
6. تكوين طلب JSON
         │
7. إرسال POST إلى /api/v1/schools/scan/
   ├── نجاح → عرض تأكيد على شاشة/small LCD
   └── فشل الاتصال → تخزين مؤقت في SQLite محلي
         │
8. عند عودة الاتصال → إرسال البيانات المخزنة (Batch Sync)
```

#### وضع عدم الاتصال (Offline Buffer):
```
┌──────────────────────────────────────────────┐
│          وضع عدم الاتصال (Offline Mode)       │
│                                              │
│  1. لا يوجد إنترنت → لا يتم إرسال البيانات   │
│  2. يتم حفظ الأحداث في SQLite محلياً          │
│  3. عند عودة الاتصال:                         │
│     ├── جلب الأحداث المخزنة                   │
│     ├── إرسالها دفعة واحدة (Batch)            │
│     └── حذفها من التخزين المحلي               │
└──────────────────────────────────────────────┘
```

---

### 6.4 جهاز GPS خارجي (Dedicated GPS Tracker)

#### كيف يعمل:
- جهاز GPS صلب مثبت في الحافلة، مزود بشريحة 4G SIM.
- يُرسل إحداثيات الموقع كل بضع ثوانٍ تلقائياً.

#### كيف يُعدّد الجهاز:
1. يُسجل في `/school/admin/devices` بالمعرّف (IMEI الجهاز): `GPS-101`.
2. يتم إدخال API URL والتوكن في واجهة الجهاز (عادة عبر برنامج/configuration خاص بالشركة المصنعة).
3. يُربط بالحافلة المحددة.

#### ماذا يرسل:
```
POST /api/v1/schools/telemetry/     ← كل 10-30 ثانية
{
  "device_identifier": "GPS-101",
  "latitude": 31.9539,
  "longitude": 35.9106,
  "speed": 60.0,
  "heading": 90.0,
  "timestamp": "2026-08-20T07:30:00Z"
}
```

---

### 6.5 مزامنة قاعدة بيانات الوجوه (Face Database Sync — `students_faces.db`)

#### لماذا قاعدة بيانات محلية وليس سحابية مباشرة؟
- الكاميرا داخل الحافلة قد لا يكون لديها إنترنت دائماً.
- التعرف على الوجه يجب أن يكون **فوريًا** (أقل من ثانية) — الاتصال بالخادم السحابي في كل مرة يسبب تأخيراً غير مقبول.
- الجودة: المقارنة المحلية أدق لأن بصمات الوجه (`Embeddings`) ثابتة ولا تتغير.

#### ماذا تحتوي قاعدة بيانات الوجوه (`students_faces.db`)؟
```
┌─────────────────────────────────────────────────┐
│           students_faces.db (SQLite)             │
│                                                  │
│  student_id  │  student_name  │  face_embedding  │
│  105         │  أحمد محمد     │  [0.12, -0.45...] │
│  108         │  فاطمة علي     │  [0.08, 0.33...]  │
│  112         │  خالد سعيد     │  [-0.01, 0.22...] │
│                                                  │
│  + جدول offline_events (للتخزين المؤقت)          │
└─────────────────────────────────────────────────┘
```

**ملاحظة هامة:** لا يتم تخزين صور الطلاب الحقيقية على الحاسوب المصغر — فقط **المصفوفات الرقمية (Facial Embeddings)** التي هي أرقام رياضية بحتة لا يمكن عكسها لاستعادة الصورة الأصلية (data privacy / GDPR compliance).

#### آلية التحميل الأولي (Initial Download / Seeding):
```
1. الحاسوب المصغر يتصل بشبكة المدرسة (Wi-Fi)
   │
2. يرسل طلب GET:
   GET /api/v1/schools/bus-routes/{route_id}/students/faces/
   Headers: { "Authorization": "Bearer {device_api_token}" }
   │
3. الخادم يُعيد JSON يحتوي:
   {
     "students": [
       {
         "student_id": 105,
         "student_name": "أحمد محمد",
         "face_embedding": [0.12, -0.45, 0.08, ...]  // مصفوفة 128-512 قيمة
       },
       ...
     ]
   }
   │
4. الحاسوب يخزن البيانات في students_faces.db محلياً
```

#### آلية المزامنة التلقائية عند بدء التشغيل (Startup Sync):
```
┌──────────────────────────────────────────────────────┐
│            مزامنة عند بدء تشغيل الحافلة               │
│                                                      │
│  1. الحاسوب المصغر يُشغّل صباحاً (مع تشغيل الحافلة) │
│  2. يتحقق من اتصال الإنترنت                          │
│     ├── لا يوجد إنترنت → يใช้students_faces.db القديمة│
│     └── يوجد إنترنت → المتابache                      │
│  3. يرسل طلب GET مع version_hash أو last_sync_time   │
│  4. الخادم يقارن ويعيد فقط التغييرات:                │
│     ├── طلاب جدد (إضافة)                             │
│     ├── طلاب انتقلوا (حذف)                           │
│     └── بصمات محدّثة (تحديث)                         │
│  5. الحاسوب يُحدّث students_faces.db محلياً           │
│  6. يبدأ العمل فوراً (Online أو Offline)              │
└──────────────────────────────────────────────────────┘
```

#### آلية التحديث الفوري عبر السحابة (OTA Push Update):
```
1. مدير المدرسة يُضيف طالباً جديداً في /school/transport
   └── يُربط الطالب بخط سير / حافلة محددة
   │
2. الخادم يولّد "حدث تحديث" (Update Event)
   │
3. يُرسل إشارة خفيفة عبر WebSocket/MQTT إلى الحاسوب المصغر
   │
4. الحاسوب المصغر يستقبل الإشارة:
   ├── يطلب البيانات المحدّثة من الخادم
   ├── يُحدّث students_faces.db محلياً
   └── يُكمل العمل بدون أي تدخل بشري
```

#### لماذا نستخدم Embeddings (مصفوفات رياضية) وليس صور؟
```
الصور الحقيقية:                    Embeddings (المصفوفات الرقمية):
├── كبيرة الحجم (MBs)              ├── صغيرة جداً (KBs)
├── تنتهك خصوصية الطلاب (GDPR)     ├── لا يمكن عكسها لاستعادة الصورة
├── بطيئة في المعالجة              ├── مقارنة رياضية سريعة جداً
├── تختلف مع تغير الإضاءة          ├── ثابتة وغير متأثرة بالإضاءة
└── تحتاج نموذج AI محلي ثقيل       └── تعمل بـ CPU خفيف فقط
```

---

### 6.6 إعداد الحاسوب المصغر داخل الحافلة (Edge PC Setup)

#### أولاً: العتاد المطلوب (Hardware Requirements)

| المكون | المواصفات | السبب |
|--------|-----------|-------|
| **الحاسوب المصغر** | Raspberry Pi 4/5 (4-8GB RAM) أو Mini PC (Intel N100) | مناسب للحجم والتكلفة وأداء AI كافٍ |
| **الكاميرا** | كاميرا IP أو USB HD بزاوية واسعة، مقاومة للاهتزاز | التقاط وجوه الطلاب في بيئة حافلة متغيرة |
| **راوتر الإنترنت** | 4G/5G Router مع شريحة بيانات (SIM) | اتصال مستمر بالمنصة |
| **مزود الطاقة** | محول DC-DC (12/24V → 5V) + Mini UPS / Power Hat | حماية من انقطاع الكهرباء عند إطفاء المحرك |
| **بطاقة التخزين** | MicroSD / SSD بسعة 64GB+ | تشغيل نظام Linux + تخزين قاعدة البيانات |
| ** HDD/SSD خارجي** (اختياري) | 256GB+ | تخزين سجلات الفيديو القديمة |

#### ثانياً: نظام التشغيل والمكتبات البرمجية (Software Stack)

| المكون | الإصدار/النوع | الوظيفة |
|--------|-------------|---------|
| **نظام التشغيل** | Ubuntu Server 22.04 LTS أو Raspberry Pi OS Lite | استقرار + تشغيل 24/7 |
| **Python** | 3.10+ | لغة السكربت الرئيسي |
| **OpenCV** | 4.x+ | لتقاط ومعالجة تدفق الفيديو |
| **face_recognition** أو **onnxruntime** | أحدث إصدار | للتعرف على الوجه بكفاءة |
| **requests** | Python package | لإرسال طلبات HTTP إلى المنصة |
| **sqlite3** | Python built-in | قاعدة البيانات المحلية |
| **Systemd** | Linux built-in | تشغيل السكربت تلقائياً عند الإقلاع |

#### ثالثاً: خطوات الإعداد والتهيئة

**الخطوة 1: إعداد نظام التشغيل والاتصال**
```bash
# تثبيت Ubuntu Server على MicroSD/SSD
# تفعيل SSH للإعداد عن بُعد
sudo apt update && sudo apt install -y openssh-server

# إعداد اتصال الشبكة (Wi-Fi أو Ethernet)
sudo nano /etc/netplan/01-config.yaml
sudo netplan apply

# اختبار الاتصال بالإنترنت
ping api.afaq.app
```

**الخطوة 2: تثبيت المكتبات البرمجية**
```bash
# تثبيت Python و المكتبات
sudo apt install -y python3 python3-pip python3-venv

# إنشاء بيئة عمل معزولة
python3 -m venv /opt/afaq/venv
source /opt/afaq/venv/bin/activate

# تثبيت المكتبات
pip install opencv-python face_recognition requests numpy
```

**الخطوة 3: إنشاء ملف الإعدادات المحلي (`config.json`)**
```json
{
  "server_url": "https://api.afaq.app/api/v1/schools/scan/",
  "telemetry_url": "https://api.afaq.app/api/v1/schools/telemetry/",
  "faces_sync_url": "https://api.afaq.app/api/v1/schools/bus-routes/{route_id}/students/faces/",
  "device_identifier": "CAM-BUS-101",
  "api_token": "a1b2c3d4e5f67890abcdef1234567890abcdef1234567890abcdef1234567890",
  "bus_id": 12,
  "route_id": 5,
  "camera_url": "rtsp://admin:password@192.168.1.100:554/stream",
  "sync_interval_seconds": 300,
  "telemetry_interval_seconds": 10,
  "offline_buffer_max": 1000
}
```

**الخطوة 4: وضع ملف الإعدادات في الموقع الآمن**
```bash
sudo mkdir -p /opt/afaq
sudo cp config.json /opt/afaq/config.json
sudo chmod 600 /opt/afaq/config.json  # فقط root يمكنه القراءة
```

**الخطوة 5: إعداد التشغيل التلقائي عبر Systemd (Auto-Start)**
لضمان عمل السكربت تلقائياً عند تشغيل الحاسوب بدون تدخل بشري:

1. إنشاء ملف الخدمة:
```ini
# /etc/systemd/system/afaq-bus-agent.service

[Unit]
Description=Afaq Bus Smart Tracking Edge Agent
After=network.target
Wants=network-online.target

[Service]
ExecStart=/opt/afaq/venv/bin/python /opt/afaq/agent.py
WorkingDirectory=/opt/afaq
Restart=always
RestartSec=10
User=root
Environment=PYTHONUNBUFFERED=1

[Install]
WantedBy=multi-user.target
```

2. تفعيل الخدمة:
```bash
sudo systemctl daemon-reload
sudo systemctl enable afaq-bus-agent
sudo systemctl start afaq-bus-agent

# للتحقق من حالة الخدمة:
sudo systemctl status afaq-bus-agent

# لعرض السجلات:
sudo journalctl -u afaq-bus-agent -f
```

#### رابعاً: ملخص سير العمل الكامل بعد الإعداد
```
┌──────────────────────────────────────────────────────┐
│        سير العمل الكامل بعد الإعداد الناجح            │
│                                                      │
│  1. الحاسوب المصغر يُشغّل مع تشغيل الحافلة          │
│  2. Linux يُشغّل الخدمة (afaq-bus-agent) تلقائياً   │
│  3. السكربت يتصل بالإنترنت ويجلب بيانات الوجوه      │
│  4. يحفظ students_faces.db محلياً                    │
│  5. يبدأ التقاط الفيديو من كاميرا IP                │
│  6. يكشف الوجوه ويُطابقها محلياً                    │
│  7. يُرسل أحداث التعرف إلى /api/v1/schools/scan/    │
│  8. إذا انقطع الإنترنت → يُخزّن الأحداث مؤقتاً      │
│  9. عند عودة الاتصال → يُرسل البيانات المخزنة        │
│  10. يُحدّث بيانات الوجوه عند بدء التشغيل التالي     │
│                                                      │
│  النتيجة: نظام ذكي يعمل بدون تدخل بشري 24/7         │
└──────────────────────────────────────────────────────┘
```

#### خامساً: الصيانة والدعم عن بُعد
```bash
# الاتصال بالحاسوب المصغر عبر SSH من المدرسة
ssh root@192.168.1.50

# مراقبة السجلات مباشرة
journalctl -u afaq-bus-agent -f

# إعادة تشغيل الخدمة يدوياً (عند الحاجة)
sudo systemctl restart afaq-bus-agent

# تحديث السكربت عن بُعد (إذا تم نشر إصدار جديد)
scp agent.py root@192.168.1.50:/opt/afaq/agent.py
ssh root@192.168.1.50 "systemctl restart afaq-bus-agent"

# عرض حالة قاعدة البيانات المحلية
sqlite3 /opt/afaq/students_faces.db "SELECT COUNT(*) FROM students;"
```

---

### 6.7 المقارنة بين كاميرا الحاسوب المصغر وهاتف السائق في التعرف على الوجوه

#### أ. هل يُحمل قاعدة بيانات الوجوه (`students_faces.db`) على هاتف السائق؟
**لا، مطلقاً.** والأسباب المعمارية لذلك هي:
1. **استنزاف الموارد:** تشغيل نماذج الذكاء الاصطناعي للتعرف على الوجه محلياً على الهاتف يستهلك البطارية بسرعة ويؤدي إلى ارتفاع حرارة الهاتف.
2. **طبيعة تطبيق السائق (PWA):** واجهة السائق (`/school/driver`) مصممة لتكون خفيفة وسريعة، وتعتمد كلياً على الاتصال السحابي (Cloud APIs) أو المسح المباشر للبطاقات.

#### ب. كيف يتعامل الهاتف مع حضور الطلاب؟
عند استخدام هاتف السائق، يتم الاعتماد على أمرين:
1. **مسح بطاقات RFID / NFC المباشر:** عبر NFC المدمج في الهاتف أو قارئ Bluetooth خارجي، ويرسل الرقم مباشرة عبر `POST /api/v1/schools/scan/`.
2. **التعرف السحابي على الوجه (Cloud-Side Recognition):** إذا التقط السائق صورة، تُرفع الصورة للسحابة ليقوم الخادم الرئيسي بمعالجتها ومطابقتها.

#### ج. الفرق بين لقطة الهاتف وفيديو الكاميرا الذكية (Snapshot vs. Live Stream):

| وجه المقارنة | هاتف السائق (Mobile PWA) | الحاسوب المصغر + كاميرا IP |
|-------------|---------------------------|----------------------------|
| **نوع التقاط الصورة** | **صورة ثابتة (Still Photo / Snapshot)** يلتقطها السائق يدوياً عند الحاجة. | **فيديو مباشر (Live Video Stream - RTSP)** بمعدل 15-30 إطاراً في الثانية (FPS). |
| **مكان المعالجة** | تُرفع الصورة للسحابة (Cloud-Side) لمعالجتها. | تُعالج محلياً على الحاسوب المصغر في الحافلة (Edge Computing). |
| **التفاعل البشري** | يتطلب تدخلاً يدوياً من السائق (التصوير أو تمرير البطاقة). | يعمل تلقائياً 24/7 بدون أي تدخل من السائق. |
| **الاعتماد على الإنترنت** | يتطلب اتصالاً مباشراً عند الإرسال. | يعمل محلياً حتى بدون إنترنت (Offline Buffer) ويُزامن لاحقاً. |

---

## 7. كيف يتعامل السائق مع النظام (.Driver Integration)

### تسجيل السائق ودوره في المنصة:
- **السائق ليس دوراً أكاديمياً** في النظام (ليس معلماً أو طالباً أو مديراً).
- السائق هو **كيان تشغيلي (Operational Entity)** مرتبط مباشرة بـ `SchoolBus`.
- لا يحتاج السائق إلى حساب مستخدم مستقل — يُعرف برقم هاتفه أو معرّف الحافلة.

### خطوات تسجيل السائق:
```
1. مسؤول النقل يضيف الحافلة في /school/transport
   ├── يُدخل: رقم الحافلة، اسم السائق، هاتف السائق، السعة
   │
2. النظام يولّد جهازاً تلقائياً:
   ├── device_identifier = "DRIVER-PHONE-{bus_number}"
   ├── device_type = "mobile_app"
   └── assigned_bus = الحافلة المحددة
   │
3. السائق يفتح /school/driver على هاتفه
   ├── يُدخل رقم هاتفه أو معرّف الحافلة
   ├── النظام يتعرف على الجهاز ويُنشئ جلسة
   │
4. السائق يبدأ الرحلة
   ├── يضغط "بدء الرحلة"
   ├── الهاتف يبدأ ببث الموقع تلقائياً
   └── السائق يمكنه مسح بطاقات الطلاب
```

---

## 8. بنية البيانات المرسلة من كل جهاز (Payload Formats)

### 8.1 بيانات GPS (Telemetry)
```json
{
  "device_identifier": "string (مطلوب)",
  "bus_number": "string (اختياري — للبحث عن الحافلة إذا لم يكن مربوطاً بالجهاز)",
  "latitude": "decimal (مطلوب)",
  "longitude": "decimal (مطلوب)",
  "speed": "decimal (اختياري)",
  "heading": "decimal (اختياري — الاتجاه بالدرجات)",
  "timestamp": "ISO 8601 (اختياري — الافتراضي: الوقت الحالي)"
}
```

### 8.2 بيانات مسح البطاقات / التعرف على الوجه (Scan)
```json
{
  "device_identifier": "string (مطلوب)",
  "student_id": "integer (اختياري — إذا كان معروفاً مسبقاً)",
  "event_type": "rfid_tap | facial_recognition (مطلوب)",
  "direction": "board | exit (مطلوب — صعود أو نزول)",
  "timestamp": "ISO 8601 (اختياري)",
  "raw_payload": {
    "card_uid": "string (اختياري — لقراءات RFID)",
    "confidence": "decimal (اختياري — للكاميرات الذكية)"
  }
}
```

### 8.3 إشارة الاتصال (Heartbeat)
```json
POST /api/v1/schools/devices/{id}/heartbeat/
// لا يحتاج جسم — يحدّث last_seen_at ويضع status = ONLINE
```

---

## 9. شاشات الفرونتايند (Frontend Pages)

### 9.1 إدارة الأجهزة (`/school/admin/devices`)
- جدول يعرض جميع الأجهزة المسجلة (نوع الجهاز، الحالة، آخر اتصال، الحافلة المرتبطة).
- إضافة جهاز جديد (اختيار النوع، إدخال المعرّف، تحديد الحافلة).
- تعديل / حذف جهاز.
- إعادة توليد مفتاح الأمان (`regenerate-token`).

### 9.2 واجهة السائق (`/school/driver`)
- واجهة موبايل مبسطة.
- زر "بدء الرحلة" / "إنهاء الرحلة".
- عرض خريطة صغيرة بالموقع الحالي.
- إمكانية مسح بطاقات الطلاب عبر كاميرا الهاتف أو NFC.

### 9.3 خريطة التتبع الحي (`/school/transport/map`)
- خريطة تفاعلية (Google Maps / Leaflet) تُعرض مواقع جميع الحافلات النشطة.
- تحديث تلقائي كل بضع ثوانٍ.
- عرض معلومات كل حافلة عند النقر عليها (رقم الحافلة، اسم السائق، السرعة، عدد الطلاب على متنها).

### 9.4 إدارة النقل المدرسي (`/school/transport`)
- تبويبات: الحافلات | خطوط السير | المحطات | التخصيصات.
- CRUD كامل لكل مكون (إضافة، تعديل، حذف مع تأكيد).
- RoleGuard محدّث ليسمح لـ `school_transport_officer` فقط.

---

## 10. التسلسل الزمني للتنفيذ
1. نماذج قاعدة البيانات + الهجرات ✅
2. APIs الخلفية (Serializers + Views + URLs) ✅
3. صفحة إدارة الأجهزة (Admin UI) ✅
4. واجهة السائق (Driver UI) ✅
5. خريطة التتبع الحي (Live Map) ✅
6. إدارة النقل المدرسي (Transport CRUD — حافلات، خطوط، محطات، تخصيصات) ✅
7. إصلاح صلاحيات تتبع الحافلات → مسؤول النقل فقط ✅
8. نموذج BusStop + APIs + واجهة المحطات ✅
9. توثيق شامل لآليات ربط الأجهزة ✅
10. توثيق مزامنة قاعدة بيانات الوجوه (Face DB Sync — Initial + Startup + OTA) ✅
11. توثيق إعداد الحاسوب المصغر بالكامل (Hardware + Software + Systemd + SSH) ✅

---

## 11. ملاحظات تقنية مهمة

### 11.1 أمن الاتصالات (Security)
- كل جهاز له `api_token` فريد — يجب أن يُرفق مع كل طلب.
- يُنصح باستخدام HTTPS فقط (المنصة تعمل على `https://api.afaq.app`).
- يمكن تقييد الطلبات بعنوان IP للجهاز (اختياري — عبر Django middleware).

### 11.2 وضع عدم الاتصال (Offline Mode)
- الأجهزة تعمل في بيئة الحافلة التي قد تنقطع فيها الشبكة.
- يجب أن تحتوي كل جهاز على ذاكرة تخزين مؤقت (SQLite أو ملف JSON).
- عند عودة الاتصال، يتم إرسال البيانات المخزنة تلقائياً (Batch Sync).

### 11.3 التوقيع الزمني (Timestamps)
- يجب أن يحتوي كل طلب على `timestamp` بتنسيق ISO 8601.
- إذا لم يُرسل الجهاز الوقت، يستخدم النظام الوقت الحالي (`timezone.now()`).

### 11.4 التوفر (Availability)
- الـ APIs العامة (`/telemetry/` و `/scan/`) تعمل بصلاحية `AllowAny` — لا تحتاج مصادقة مستخدم.
- الأمان يتم عبر `device_identifier` + `api_token` (وليس JWT tokens).
- يمكن إضافة rate limiting لمنع الطلبات المفرطة.
