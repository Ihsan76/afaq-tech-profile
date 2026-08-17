# إمكانية الوصول متعددة اللغات (i18n Accessibility)

## نظرة عامة

ضمان وصول جميع المستخدمين للمنصة بغض النظر عن لغتهم أو أدوات الوصول المستخدمة.

---

## المبادئ الأساسية

| المبدأ | التفصيل |
|--------|---------|
| **WCAG 2.1** | الامتثال لمعايير الوصول AAA |
| **ARIA** | استخدام علامات ARIA بلغات متعددة |
| **Screen Readers** | دعم قارئات الشاشة بالعربية والإنجليزية |
| **Focus Management** | إدارة التركيز عند تبديل اللغة |
| **Keyboard Navigation** | التنقل بلوحة المفاتيح لجميع اللغات |

---

## دعم قارئات الشاشة

### lang attribute

```tsx
// في layout.tsx
export default function RootLayout({
  children,
  params: { locale },
}: {
  children: React.ReactNode;
  params: { locale: string };
}) {
  return (
    <html lang={locale} dir={locale === 'ar' || locale === 'ur' ? 'rtl' : 'ltr'}>
      <body>{children}</body>
    </html>
  );
}
```

### ARIA Labels بلغات متعددة

```tsx
// components/AccessibleButton.tsx

'use client';

import { useLocale } from 'next-intl';

interface AccessibleButtonProps {
  onClick: () => void;
  label: string;
  ariaKey: string;
}

export function AccessibleButton({ onClick, label, ariaKey }: AccessibleButtonProps) {
  const locale = useLocale();
  
  // ترجمة label حسب اللغة
  const translatedLabel = getAriaLabel(ariaKey, locale);
  
  return (
    <button
      onClick={onClick}
      aria-label={translatedLabel}
      role="button"
      tabIndex={0}
      onKeyDown={(e) => {
        if (e.key === 'Enter' || e.key === ' ') {
          e.preventDefault();
          onClick();
        }
      }}
    >
      {label}
    </button>
  );
}

function getAriaLabel(key: string, locale: string): string {
  const labels: Record<string, Record<string, string>> = {
    'save': {
      ar: 'حفظ',
      en: 'Save',
      fr: 'Enregistrer',
      tr: 'Kaydet',
    },
    'delete': {
      ar: 'حذف',
      en: 'Delete',
      fr: 'Supprimer',
      tr: 'Sil',
    },
    'close': {
      ar: 'إغلاق',
      en: 'Close',
      fr: 'Fermer',
      tr: 'Kapat',
    },
    'menu': {
      ar: 'القائمة',
      en: 'Menu',
      fr: 'Menu',
      tr: 'Menü',
    },
    'search': {
      ar: 'بحث',
      en: 'Search',
      fr: 'Rechercher',
      tr: 'Ara',
    },
    'language_switcher': {
      ar: 'تبديل اللغة',
      en: 'Switch language',
      fr: 'Changer de langue',
      tr: 'Dili değiştir',
    },
  };
  
  return labels[key]?.[locale] || labels[key]?.['en'] || key;
}
```

---

## Focus Management

### عند تبديل اللغة

```tsx
// hooks/use-focus-management.ts

import { useEffect } from 'react';
import { useLocale } from 'next-intl';

export function useFocusManagement() {
  const locale = useLocale();
  
  useEffect(() => {
    // عند تبديل اللغة، نقل التركيز للعنصر الرئيسي
    const mainContent = document.querySelector('main');
    if (mainContent) {
      mainContent.focus();
    }
    
    // تحديث aria-live region
    const liveRegion = document.getElementById('language-announcement');
    if (liveRegion) {
      liveRegion.textContent = `Language changed to ${locale}`;
    }
  }, [locale]);
}
```

### Live Region لل announcements

```tsx
// components/LanguageAnnouncement.tsx

'use client';

import { useLocale } from 'next-intl';

export function LanguageAnnouncement() {
  const locale = useLocale();
  
  const announcements: Record<string, string> = {
    ar: 'تم تغيير اللغة إلى العربية',
    en: 'Language changed to English',
    fr: 'Langue changée en Français',
    tr: 'Dil Türkçeye değiştirildi',
    ur: 'زبان اردو میں تبدیل کی گئی',
    es: 'Idioma cambiado a Español',
    de: 'Sprache auf Deutsch geändert',
    id: 'Bahasa diubah ke Bahasa Indonesia',
    bn: 'ভাষা বাংলায় পরিবর্তন করা হয়েছে',
  };
  
  return (
    <div
      id="language-announcement"
      aria-live="polite"
      aria-atomic="true"
      className="sr-only"
    >
      {announcements[locale] || announcements['en']}
    </div>
  );
}
```

---

## تنسيق الأرقام والتواريخ

### استخدام Intl API

```typescript
// utils/format.ts

export function formatNumber(value: number, locale: string): string {
  return new Intl.NumberFormat(locale).format(value);
}

export function formatCurrency(value: number, locale: string, currency: string = 'USD'): string {
  return new Intl.NumberFormat(locale, {
    style: 'currency',
    currency,
  }).format(value);
}

export function formatDate(date: Date, locale: string): string {
  return new Intl.DateTimeFormat(locale, {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  }).format(date);
}

export function formatRelativeTime(value: number, unit: Intl.RelativeTimeFormatUnit, locale: string): string {
  return new Intl.RelativeTimeFormat(locale, {
    numeric: 'auto',
  }).format(value, unit);
}
```

### أمثلة على التنسيق

```typescript
// للعربية
formatNumber(1234567.89, 'ar');  // "١٬٢٣٤٬٥٦٧٫٨٩"
formatDate(new Date(), 'ar');    // "١٥ يناير ٢٠٢٥"

// للإنجليزية
formatNumber(1234567.89, 'en');  // "1,234,567.89"
formatDate(new Date(), 'en');    // "January 15, 2025"

// للفرنسية
formatNumber(1234567.89, 'fr');  // "1 234 567,89"
formatDate(new Date(), 'fr');    // "15 janvier 2025"
```

---

## RTL/LTR في CSS

### استخدام Logical Properties

```css
/* صحيح - يعمل في RTL و LTR */
.element {
  margin-inline-start: 16px;
  margin-inline-end: 16px;
  padding-inline-start: 8px;
  padding-inline-end: 8px;
  border-inline-start: 2px solid;
  border-inline-end: 2px solid;
  text-align: start;
  float: inline-start;
}

/* خاطئ - لا يعمل في RTL */
.element {
  margin-left: 16px;
  margin-right: 16px;
  padding-left: 8px;
  padding-right: 8px;
  border-left: 2px solid;
  border-right: 2px solid;
  text-align: left;
  float: left;
}
```

### Tailwind CSS RTL Support

```tsx
// باستخدام Tailwind
<div className="ms-4 me-4 ps-8 pe-8 text-start">
  {/* ms = margin-inline-start */}
  {/* me = margin-inline-end */}
  {/* ps = padding-inline-start */}
  {/* pe = padding-inline-end */}
  {/* text-start = text-align: start */}
</div>
```

---

## Navigation

### التنقل بلوحة المفاتيح

```tsx
// components/AccessibleNavigation.tsx

'use client';

import { useLocale } from 'next-intl';

export function AccessibleNavigation() {
  const locale = useLocale();
  
  const handleKeyDown = (e: React.KeyboardEvent) => {
    // التنقل بـ Alt + Arrow Keys
    if (e.altKey) {
      if (e.key === 'ArrowRight' && locale === 'ar') {
        // في RTL، ArrowRight يذهب للخلف
        navigatePrevious();
      } else if (e.key === 'ArrowLeft' && locale === 'ar') {
        // في RTL، ArrowLeft يذهب للأمام
        navigateNext();
      }
    }
  };
  
  return (
    <nav
      role="navigation"
      aria-label={locale === 'ar' ? 'التنقل الرئيسي' : 'Main navigation'}
      onKeyDown={handleKeyDown}
    >
      {/* المحتوى */}
    </nav>
  );
}
```

---

## Screen Reader Only Content

### إخفاء المحتوى بصرياً

```tsx
// components/ScreenReaderOnly.tsx

export function ScreenReaderOnly({ children }: { children: React.ReactNode }) {
  return (
    <span className="sr-only">
      {children}
    </span>
  );
}

// استخدامه
<ScreenReaderOnly>
  {locale === 'ar' ? 'الصفحة الرئيسية' : 'Home page'}
</ScreenReaderOnly>
```

### CSS

```css
.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border: 0;
}
```

---

## اختبارات إمكانية الوصول

### مع Lighthouse

```typescript
// __tests__/accessibility/lighthouse.test.ts

import { describe, it, expect } from 'vitest';

describe('Accessibility', () => {
  it('should have no axe violations for Arabic', async () => {
    const results = await runAxeTest('https://afaq.app/ar');
    expect(results.violations).toHaveLength(0);
  });

  it('should have no axe violations for English', async () => {
    const results = await runAxeTest('https://afaq.app/en');
    expect(results.violations).toHaveLength(0);
  });
});
```

### مع Playwright

```typescript
// tests/accessibility.spec.ts

import { test, expect } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

test.describe('Accessibility', () => {
  test('Arabic page should be accessible', async ({ page }) => {
    await page.goto('https://afaq.app/ar');
    
    const accessibilityScanResults = await new AxeBuilder({ page })
      .withTags(['wcag2a', 'wcag2aa', 'wcag2aaa'])
      .analyze();
    
    expect(accessibilityScanResults.violations).toEqual([]);
  });

  test('English page should be accessible', async ({ page }) => {
    await page.goto('https://afaq.app/en');
    
    const accessibilityScanResults = await new AxeBuilder({ page })
      .withTags(['wcag2a', 'wcag2aa', 'wcag2aaa'])
      .analyze();
    
    expect(accessibilityScanResults.violations).toEqual([]);
  });
});
```

---

## ملخص

> **إمكانية الوصول متعددة اللغات** تضمن وصول جميع المستخدمين للمنصة. المكونات: دعم قارئات الشاشة بالعربية والإنجليزية، ARIA labels بلغات متعددة، إدارة التركيز عند تبديل اللغة، تنسيق الأرقام والتواريخ حسب اللغة، وCSS logical properties. الهدف: الامتثال لمعايير WCAG 2.1 AAA.
