# APIs المصادقة

## Base URL
```
/api/v1/auth/
```

---

## POST /api/v1/auth/register/

**تسجيل مستخدم جديد** — AllowAny

### Request
```json
{
  "email": "user@example.com",
  "password": "SecurePass123!",
  "password_confirm": "SecurePass123!",
  "name_ar": "محمد أحمد"
}
```

### Response (201)
```json
{
  "id": 1,
  "email": "user@example.com",
  "name_ar": "محمد أحمد",
  "role": "student",
  "access": "eyJ...",
  "refresh": "eyJ..."
}
```

---

## POST /api/v1/auth/login/

**تسجيل الدخول** — AllowAny

### Request
```json
{
  "email": "user@example.com",
  "password": "SecurePass123!"
}
```

### Response (200)
```json
{
  "id": 1,
  "email": "user@example.com",
  "name_ar": "محمد أحمد",
  "role": "student",
  "access": "eyJ...",
  "refresh": "eyJ...",
  "ui_language": "ar"
}
```

---

## POST /api/v1/auth/refresh/

**تجديد Access Token** — AllowAny

### Request
```json
{
  "refresh": "eyJ..."
}
```

### Response (200)
```json
{
  "access": "eyJ..."
}
```

---

## GET /api/v1/auth/profile/

**جلب الملف الشخصي** — IsAuthenticated

### Headers
```
Authorization: Bearer <access_token>
```

### Response (200)
```json
{
  "id": 1,
  "email": "user@example.com",
  "name_ar": "محمد أحمد",
  "name_en": "Mohammed",
  "phone": "+962791234567",
  "role": "teacher",
  "avatar": "https://...",
  "ui_language": "ar",
  "timezone": "Asia/Amman",
  "is_verified": true
}
```

---

## PUT /api/v1/auth/profile/

**تحديث الملف الشخصي** — IsAuthenticated

### Request
```json
{
  "name_ar": "محمد أحمد الجديد",
  "phone": "+962791234568",
  "ui_language": "en"
}
```

---

## POST /api/v1/auth/forgot-password/

**طلب إعادة تعيين كلمة المرور** — AllowAny

### Request
```json
{
  "email": "user@example.com"
}
```

### Response (200)
```json
{
  "message": "تم إرسال رابط إعادة التعيين إلى بريدك الإلكتروني."
}
```

---

## POST /api/v1/auth/reset-password/

**تأكيد إعادة تعيين كلمة المرور** — AllowAny

### Request
```json
{
  "token": "abc123...",
  "password": "NewSecurePass123!"
}
```

### Response (200)
```json
{
  "message": "تم تحديث كلمة المرور بنجاح."
}
```

---

## ما هو غير مُنفّذ ❌

- [ ] POST /auth/logout/ — تسجيل الخروج
- [ ] POST /auth/change-password/ — تغيير كلمة المرور
- [ ] POST /auth/2fa/enable/ — المصادقة الثنائية
- [ ] POST /auth/2fa/verify/
- [ ] POST /auth/2fa/disable/

---

## بيانات الدخول الافتراضية

```
البريد: admin@afaq.app
كلمة المرور: Admin123456
```

---

## ملخص

> 6 APIs مُنفّذة: register, login, refresh, profile (GET/PUT), forgot-password, reset-password. JWT مع 60 دقيقة access + 7 أيام refresh.
