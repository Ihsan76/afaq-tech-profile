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
