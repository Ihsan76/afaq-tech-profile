# خططة هندسة نظام المحادثات الفورية (Live Chat & WebSockets)

> تاريخ التوثيق: 17 أغسطس 2026
> الغرض: توثيق التصميم الهندسي والمعماري لتنفيذ نظام المحادثات الفورية في منصة آفاق تكنولوجي.

---

## 1. نماذج قاعدة البيانات (Backend Models - `apps.chat`)

### أ. نموذج المحادثة (`Conversation`)
- `id`: معرف فريد.
- `participants`: علاقة متعدد لمتعدد (`ManyToManyField`) مع جدول المستخدمين (`User`).
- `school`: ارتباط اختياري بالمدرسة (`ForeignKey` لـ `School`).
- `created_at` / `updated_at`: تواريخ الإنشاء والتحديث لترتيب المحادثات النشطة.

### ب. نموذج الرسالة (`Message`)
- `id`: معرف فريد.
- `conversation`: ارتباط بالمحادثة (`ForeignKey` لـ `Conversation`).
- `sender`: مرسل الرسالة (`ForeignKey` لـ `User`).
- `content`: نص الرسالة.
- `attachment`: ملف مرفق اختياري (`ForeignKey` لـ `Attachment`).
- `is_read`: مؤشر قراءة الرسالة (`Boolean`).
- `created_at`: وقت إرسال الرسالة.

---

## 2. طبقة الـ APIs (REST Endpoints)
- `GET /api/v1/chat/conversations/`: سرد محادثات المستخدم الحالي.
- `POST /api/v1/chat/conversations/`: بدء محادثة جديدة.
- `GET /api/v1/chat/conversations/<id>/messages/`: جلب الأرشيف والسجل القديم للرسائل.

---

## 3. طبقة الاتصال الفوري (Real-Time WebSockets)
- الاعتماد على **Django Channels** مع طبقة Redis (`channels_redis`).
- مسار الاتصال: `ws://<domain>/ws/chat/<conversation_id>/?token=<jwt>`
- حفظ الرسالة في قاعدة البيانات ثم بثها فوراً (Broadcast) لجميع الأطراف المتصلة بالمحادثة.

---

## 4. الواجهة الأمامية (Frontend)
- صفحة دردشة مخصصة (`/chat`).
- قائمة جانبية للمحادثات مع عداد الرسائل غير المقروءة.
- نافذة دردشة حية مع دعم إعادة الاتصال التلقائي (Auto-reconnect).
