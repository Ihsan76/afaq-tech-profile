# الواجهة الأمامية (Frontend)

## التقنية الأساسية

| العنصر | الإصدار | السبب |
|--------|---------|-------|
| **Next.js** | 16+ (App Router) | SSR, ISR, Routing, Performance |
| **TypeScript** | 5.x | Type safety, Better DX |
| **Tailwind CSS** | v4 | Utility-first, RTL support |
| **next-intl** | latest | i18n with RTL support |
| **Zustand** | latest | Lightweight state management |
| **TipTap** | latest | Rich text editor (block editor + blog) |
| **axios** | latest | HTTP client with JWT auto-refresh |

---

## بنية الملفات

```
frontend/
├── app/
│   ├── [locale]/
│   │   ├── layout.tsx
│   │   ├── page.tsx
│   │   ├── login/page.tsx
│   │   ├── register/page.tsx
│   │   ├── dashboard/
│   │   │   ├── layout.tsx
│   │   │   └── page.tsx
│   │   ├── teacher/
│   │   │   ├── layout.tsx
│   │   │   ├── page.tsx
│   │   │   └── lesson-plans/
│   │   │       ├── new/page.tsx
│   │   │       ├── [id]/page.tsx
│   │   │       └── page.tsx
│   │   ├── student/
│   │   │   ├── layout.tsx
│   │   │   ├── page.tsx
│   │   │   └── chat/page.tsx
│   │   ├── admin/
│   │   │   ├── layout.tsx
│   │   │   ├── page.tsx
│   │   │   ├── users/page.tsx
│   │   │   ├── academics/page.tsx
│   │   │   └── settings/page.tsx
│   │   ├── blog/
│   │   │   ├── page.tsx
│   │   │   └── [slug]/page.tsx
│   │   ├── marketplace/
│   │   │   ├── page.tsx
│   │   │   └── [slug]/page.tsx
│   │   └── settings/page.tsx
│   └── globals.css
├── components/
│   ├── ui/               (base components)
│   ├── forms/            (form components)
│   ├── layouts/          (header, sidebar, footer)
│   └── features/         (teacher, student, shared)
├── lib/
│   ├── api.ts
│   ├── auth.ts
│   ├── utils.ts
│   ├── validators.ts
│   └── constants.ts
├── hooks/
│   ├── use-auth.ts
│   ├── use-lesson-plans.ts
│   └── use-translations.ts
├── styles/
│   └── globals.css
├── public/
│   └── (static assets)
├── i18n/
│   ├── messages/         # ملف لكل لغة — تُزرع في DB بـ seed_translations
│   │   ├── ar.json       # العربية (RTL)
│   │   ├── en.json       # English
│   │   ├── fr.json       # Français
│   │   ├── tr.json       # Türkçe
│   │   ├── ur.json       # اردو (RTL)
│   │   ├── es.json       # Español
│   │   ├── de.json       # Deutsch
│   │   ├── id.json       # Bahasa Indonesia
│   │   └── bn.json       # বাংলা
│   └── config.ts         # locales + defaultLocale + localeNames
├── proxy.ts              # next-intl middleware (يجب مطابقة locales)
├── components/
│   └── TranslationProvider.tsx  # دمج قيم DB الحية فوق الرسائل الثابتة
```

### إعدادات i18n

```typescript
// i18n/config.ts
export const locales = ['ar', 'en', 'fr', 'tr', 'ur', 'es', 'de', 'id', 'bn'] as const;
export type Locale = (typeof locales)[number];

// اللغة الافتراضية للزوار الجدد (قبل اكتشاف لغة المتصفح)
export const defaultLocale: Locale = 'en';

// اللغة الأصلية للمنصة (للمستخدمين المسجلين العرب)
export const primaryLocale: Locale = 'ar';

export const localeNames: Record<Locale, string> = {
  ar: 'العربية',
  en: 'English',
  fr: 'Français',
  tr: 'Türkçe',
  ur: 'اردو',
  es: 'Español',
  de: 'Deutsch',
  id: 'Bahasa Indonesia',
  bn: 'বাংলা',
};

export const rtlLocales: Locale[] = ['ar', 'ur', 'fa'];
```

### مكون مبدل اللغة

```tsx
// components/LanguageSwitcher.tsx
'use client';

import { useLocale } from 'next-intl';
import { useRouter, usePathname } from 'next/navigation';
import { localeNames, locales, rtlLocales } from '@/i18n/config';

export function LanguageSwitcher() {
  const locale = useLocale();
  const router = useRouter();
  const pathname = usePathname();

  const switchLanguage = (newLocale: string) => {
    document.documentElement.dir = rtlLocales.includes(newLocale as any) ? 'rtl' : 'ltr';
    document.documentElement.lang = newLocale;
    router.push(`/${newLocale}${pathname}`);
  };

  return (
    <select onChange={(e) => switchLanguage(e.target.value)} value={locale}>
      {locales.map((loc) => (
        <option key={loc} value={loc}>
          {localeNames[loc]}
        </option>
      ))}
    </select>
  );
}
```

---

## نظام التنبيهات الفورية (Global Toast Notifications System)

تم بناء وتكامل نظام تنبيهات فورية (Toast Notifications) موحد وعالي الأداء في الواجهة الأمامية لضمان تجربة مستخدم تفاعلية وفورية عند إنجاز العمليات أو حدوث أخطاء.

### 1. مخزن الحالة (`frontend/src/store/toast.ts`)
يعتمد النظام على Zustand لإدارة الحالة العابرة للتنبيهات:
- **الأنواع المدعومة (`ToastType`)**: `success` (نجاح), `error` (خطأ), `warning` (تحذير), `info` (معلومة).
- **الخصائص (`ToastMessage`)**: `id`, `type`, `title?`, `message`, `duration` (افتراضي 4000ms), `action?` (زر إجراء تفاعلي).
- **المساعدات المتاحة**:
  - `useToast()`: هوك لسهولة الاستدعاء داخل المكونات (`const { success, error } = useToast()`).
  - `toast`: كائن ثابت يسمح بإطلاق التنبيهات خارج المكونات أو مباشرة (`toast.success(...)`, `toast.error(...)`).

### 2. مكون العرض الرسومي (`frontend/src/components/ui/Toaster.tsx`)
- مُثبّت جزيئياً في الجذر الرئيسي (`frontend/src/app/[locale]/layout.tsx`) ليكون متاحاً في كل صفحات المنصة.
- **التصميم والتجاوب**:
  - تثبيت علوي مرن (`fixed top-4 z-[9999]`) مع دعم كامل للاتجاهين (RTL عبر `rtl:left-4` و LTR عبر `ltr:right-4`).
  - تأثير زجاجي (`backdrop-blur-md`) وأنماط ألوان مرتبطة بمتغيرات الثيم الحالي (`--color-success`, `--color-error`, `--color-warning`, `--color-primary`, `--color-surface`).
  - أيقونات ملونة متوافقة مع نوع التنبيه (عبر مكتبة `lucide-react`)، مع أزرار الإغلاق السريع والإجراءات الاختيارية.
  - دعم الوصولية (`role="alert"`, `aria-live="polite"`).
