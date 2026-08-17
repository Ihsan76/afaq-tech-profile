# نشر تطبيق الموبايل

## متطلبات النشر

### Apple App Store
- حساب Apple Developer ($99/سنة)
- App Store Connect
- مراجعة Apple (1-7 أيام)
- screenshots لكل حجم شاشة

### Google Play Store
- حساب مطور Google ($25 لمرة واحدة)
- Google Play Console
- مراجعة Google (1-3 أيام)
- screenshots + feature graphic

---

## إعداد Expo

```json
{
  "expo": {
    "name": "آفاق تكنولوجي",
    "slug": "afaq-tech",
    "version": "1.0.0",
    "ios": {
      "bundleIdentifier": "com.afaq.tech",
      "buildNumber": "1",
      "supportsTablet": true
    },
    "android": {
      "package": "com.afaq.tech",
      "versionCode": 1,
      "adaptiveIcon": {
        "foregroundImage": "./assets/adaptive-icon.png",
        "backgroundColor": "#2563EB"
      }
    }
  }
}
```

---

## بناء التطبيق

### Development
```bash
# iOS
npx expo run:ios

# Android
npx expo run:android
```

### Production
```bash
# بناء EAS
eas build --platform ios
eas build --platform android
```

### التحديث التلقائي (OTA)
```bash
# تحديث بدون إصدار جديد
eas update --branch production
```

---

## النشر

### App Store
```bash
# رفع للمراجعة
eas submit --platform ios
```

### Play Store
```bash
# رفع للمراجعة
eas submit --platform android
```

---

## إعدادات الإصدارات

```yaml
# eas.json
{
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal"
    },
    "preview": {
      "distribution": "internal"
    },
    "production": {
      "autoIncrement": true
    }
  },
  "submit": {
    "production": {
      "ios": {
        "appleId": "your-apple-id",
        "ascAppId": "your-app-store-id"
      },
      "android": {
        "serviceAccountKeyPath": "./google-service-account.json"
      }
    }
  }
}
```

---

## التحديثات

### نوع التحديث
- **OTA Update**: تحديثات صغيرة (إصلاحات أخطاء)
- **App Store Update**: تحديثات كبيرة (ميزات جديدة)

### استراتيجية الإصدارات
```
v1.0.0 → MVP (تسجيل دخول، خطط دروس، مساعد)
v1.1.0 → دورات تدريبية
v1.2.0 → مدوّنة + سوق
v2.0.0 → وضع عدم اتصال + تحسينات
```

---

## المراقبة

```typescript
// Sentry
import * as Sentry from '@sentry/react-native';

Sentry.init({
  dsn: 'your-dsn',
  tracesSampleRate: 1.0,
});

// Analytics
import { Analytics } from 'expo-analytics';
const analytics = new Analytics('UA-XXXXX');
```

---

## التكلفة

| البند | التكلفة |
|-------|---------|
| Apple Developer | $99/سنة |
| Google Play | $25 (لمرة واحدة) |
| EAS Build (Pro) | $20/شهر |
| Sentry | مجاني (Free tier) |
| **الإجمالي** | **~$150/سنة** |
