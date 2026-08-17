# تطبيق الموبايل — نظرة عامة

## التقنية

| العنصر | التفاصيل |
|--------|----------|
| **الإطار** | React Native (Expo) |
| **لغة البرمجة** | TypeScript |
| **إدارة الحالة** | Zustand |
| **طلب HTTP** | Axios + React Query |
| **المصادقة** | SecureStore (JWT) |
| **الإشعارات** | Firebase Cloud Messaging |
| **خرائط** | react-native-maps (مستقبلاً) |
| **الصوت** | expo-av (للدروس الصوتية) |

---

## الميزات حسب الإصدار

### v1.0 (MVP)
- تسجيل الدخول/التسجيل
- لوحة تحكم المعلم (基础)
- عرض خطط الدروس
- المساعد الذكي (محادثة)
- الإشعارات

### v1.1
- الدورات التدريبية
- مشغل الفيديو
- الاختبارات
- التقدم

### v1.2
- المدوّنة
- السوق
- الدفع
- المحفظة

### v2.0
- وضع عدم الاتصال (Offline)
- تشغيل في الخلفية
- دعم Face ID / Touch ID
- تكامل مع Calendar

---

## بنية المشروع

```
mobile/
├── app/
│   ├── (auth)/
│   │   ├── login.tsx
│   │   ├── register.tsx
│   │   └── forgot-password.tsx
│   ├── (tabs)/
│   │   ├── home.tsx
│   │   ├── lesson-plans.tsx
│   │   ├── chat.tsx
│   │   └── profile.tsx
│   ├── teacher/
│   │   ├── new-plan.tsx
│   │   └── plan-detail.tsx
│   ├── student/
│   │   ├── courses.tsx
│   │   └── course-detail.tsx
│   └── _layout.tsx
├── components/
│   ├── ui/
│   ├── forms/
│   └── features/
├── lib/
│   ├── api.ts
│   ├── auth.ts
│   └── storage.ts
├── hooks/
├── stores/
├── utils/
└── assets/
```

---

## التصميم

### مبادئ التصميم
1. **Mobile-first**: تجربة مصممة للهاتف أولاً
2. **RTL**: دعم كامل للعربية
3. **Accessibility**: إمكانية الوصول
4. **Performance**: أداء سريع
5. **Offline-first**: عمل بدون إنترنت (مستقبلاً)

### نظام الألوان
```typescript
const colors = {
  primary: '#2563EB',      // أزرق
  secondary: '#10B981',    // أخضر
  accent: '#F59E0B',       // برتقالي
  background: '#FFFFFF',
  surface: '#F8FAFC',
  text: '#1E293B',
  textSecondary: '#64748B',
  border: '#E2E8F0',
  error: '#EF4444',
  success: '#10B981',
};
```

---

## الإعدادات التقنية

### Expo
```json
{
  "expo": {
    "name": "آفاق تكنولوجي",
    "slug": "afaq-tech",
    "version": "1.0.0",
    "orientation": "portrait",
    "icon": "./assets/icon.png",
    "userInterfaceStyle": "automatic",
    "splash": {
      "image": "./assets/splash.png",
      "resizeMode": "contain",
      "backgroundColor": "#2563EB"
    },
    "plugins": [
      "expo-router",
      "expo-secure-store",
      "expo-notifications"
    ]
  }
}
```
