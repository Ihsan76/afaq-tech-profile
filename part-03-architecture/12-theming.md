# نظام الثيمات (Theming System)

## نظرة عامة

نظام ثيمات مرن يسمح للمستخدمين باختيار الثيم المناسب، وللمسؤول بإضافة ثيمات جديدة وتعديل الستايلات.

---

## المستخدمون

### اختيار الثيم

```
┌─────────────────────────────────────────────────────────────────┐
│                    إعدادات المظهر                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  الثيم الحالي: آفاق كلاسيكي (افتراضي)                           │
│                                                                  │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐            │
│  │              │ │              │ │              │            │
│  │  آفاق       │ │  آفاق مسائي  │ │  آفاق فاتح  │            │
│  │  كلاسيكي    │ │  (داكن)      │ │  (فاتح)     │            │
│  │              │ │              │ │              │            │
│  │  🎨 أزرق    │ │  🌙 بنفسجي   │ │  ☀️ أخضر    │            │
│  │              │ │              │ │              │            │
│  └──────────────┘ └──────────────┘ └──────────────┘            │
│                                                                  │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐            │
│  │              │ │              │ │              │            │
│  │  آفاق       │ │  آفاق مدرسي  │ │  آفاق مخصص  │            │
│  │  محايد       │ │  (ملون)      │ │  ( خاص بي)  │            │
│  │              │ │              │ │              │            │
│  │  ⚪ رمادي   │ │  🌈 ملون     │ │  ✏️ تعديل    │            │
│  │              │ │              │ │              │            │
│  └──────────────┘ └──────────────┘ └──────────────┘            │
│                                                                  │
│  [تطبيق]  [معاينة]  [إعادة تعيين]                              │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## المسؤول (Admin)

### إدارة الثيمات

```
┌─────────────────────────────────────────────────────────────────┐
│                    إدارة الثيمات                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  [+ إضافة ثيم جديد]                                            │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │ الثيم          │ الحالة    │ المستخدمون │ الإجراءات       ││
│  ├─────────────────────────────────────────────────────────────┤│
│  │ آفاق كلاسيكي  │ نشط ✅   │ 1,250      │ تعديل | معاينة  ││
│  │ آفاق مسائي    │ نشط ✅   │ 850        │ تعديل | معاينة  ││
│  │ آفاق فاتح     │ نشط ✅   │ 320        │ تعديل | معاينة  ││
│  │ آفاق محايد    │ نشط ✅   │ 180        │ تعديل | معاينة  ││
│  │ آفاق مدرسي    │ مسودة 📝 │ 0          │ تعديل | نشر    ││
│  │ آفاق مخصص     │ نشط ✅   │ 50         │ تعديل | حذف    ││
│  └─────────────────────────────────────────────────────────────┘│
│                                                                  │
│  إجمالي المستخدمين النشطين: 2,650                               │
│  أكثر ثيم استخداماً: آفاق كلاسيكي (47%)                        │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### تعديل الستايلات

```
┌─────────────────────────────────────────────────────────────────┐
│                    محرر الثيمات                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  الثيم: آفاق كلاسيكي                                            │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │ الألوان                                                     ││
│  ├─────────────────────────────────────────────────────────────┤│
│  │ اللون الرئيسي:  [██████] #2563EB                           ││
│  │ اللون الثانوي:  [██████] #7C3AED                           ││
│  │ لون النجاح:     [██████] #10B981                           ││
│  │ لون الخطأ:      [██████] #EF4444                           ││
│  │ لون التحذير:    [██████] #F59E0B                           ││
│  │ لون الخلفية:    [██████] #FFFFFF                           ││
│  │ لون النص:       [██████] #1F2937                           ││
│  └─────────────────────────────────────────────────────────────┘│
│                                                                  │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │ الأزرار                                                     ││
│  ├─────────────────────────────────────────────────────────────┤│
│  │ شكل الزر:        [مدوّر ▼]                                 ││
│  │ حجم الزر:        [كبير ▼]                                  ││
│  │ سمك الخط:        [عادي ▼]                                  ││
│  │ ظل الزر:         [ خفيف ▼]                                 ││
│  │ تأثير Hover:     [ تكبير ▼]                                ││
│  └─────────────────────────────────────────────────────────────┘│
│                                                                  │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │ الجداول                                                     ││
│  ├─────────────────────────────────────────────────────────────┤│
│  │ نمط الجدول:      [ مُخطّط ▼]                               ││
│  │ سمك الحدود:      [ رفيع ▼]                                 ││
│  │ ألوان الصفوف:    [ متناوبة ▼]                              ││
│  │ تباعد الصفوف:    [ متوسط ▼]                                ││
│  │ محاذاة النص:     [ يسار ▼]                                 ││
│  └─────────────────────────────────────────────────────────────┘│
│                                                                  │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │ البطاقات                                                    ││
│  ├─────────────────────────────────────────────────────────────┤│
│  │ شكل البطاقة:     [ مدوّرة الزوايا ▼]                       ││
│  │ الحدود:          [ خفيفة ▼]                                 ││
│  │ الظل:            [ متوسط ▼]                                 ││
│  │ التباعد:         [ متوسط ▼]                                 ││
│  └─────────────────────────────────────────────────────────────┘│
│                                                                  │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │ الخطوط                                                      ││
│  ├─────────────────────────────────────────────────────────────┤│
│  │ خط العناوين:     [ IBM Plex Sans Arabic ▼]                  ││
│  │ خط النص:         [ Noto Sans Arabic ▼]                      ││
│  │ حجم الخط الأساسي: [ 16px ▼]                                ││
│  │ ارتفاع السطر:    [ 1.6 ▼]                                  ││
│  └─────────────────────────────────────────────────────────────┘│
│                                                                  │
│  [حفظ]  [معاينة حية]  [إعادة تعيين]  [تصدير CSS]              │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## المعمارية التقنية

### هيكل الثيم

```typescript
// types/theme.ts

export interface Theme {
  id: string;
  name: string;
  name_ar: string;
  is_active: boolean;
  is_default: boolean;
  created_at: string;
  updated_at: string;
  
  // الألوان
  colors: ThemeColors;
  
  // الأزرار
  buttons: ThemeButtons;
  
  // الجداول
  tables: ThemeTables;
  
  // البطاقات
  cards: ThemeCards;
  
  // الخطوط
  fonts: ThemeFonts;
  
  // الت/layout
  layout: ThemeLayout;
}

export interface ThemeColors {
  primary: string;
  secondary: string;
  success: string;
  error: string;
  warning: string;
  background: string;
  surface: string;
  text: string;
  textSecondary: string;
  border: string;
  muted: string;
}

export interface ThemeButtons {
  shape: 'rounded' | 'pill' | 'square';
  size: 'sm' | 'md' | 'lg';
  fontWeight: 'normal' | 'medium' | 'bold';
  shadow: 'none' | 'sm' | 'md' | 'lg';
  hoverEffect: 'none' | 'scale' | 'shadow' | 'color';
}

export interface ThemeTables {
  style: 'striped' | 'bordered' | 'clean' | 'card';
  borderWidth: 'thin' | 'medium' | 'thick';
  alternatingRows: boolean;
  rowSpacing: 'compact' | 'normal' | 'relaxed';
  textAlign: 'left' | 'center' | 'right';
}

export interface ThemeCards {
  borderRadius: 'none' | 'sm' | 'md' | 'lg' | 'full';
  border: 'none' | 'thin' | 'medium' | 'thick';
  shadow: 'none' | 'sm' | 'md' | 'lg';
  spacing: 'compact' | 'normal' | 'relaxed';
}

export interface ThemeFonts {
  heading: string;
  body: string;
  baseSize: string;
  lineHeight: string;
}

export interface ThemeLayout {
  sidebarWidth: string;
  headerHeight: string;
  contentMaxWidth: string;
  borderRadius: string;
}
```

---

## تنفيذ CSS

### ملف الثيم الرئيسي

```css
/* styles/themes/default.css */

:root {
  /* الألوان */
  --color-primary: #2563EB;
  --color-secondary: #7C3AED;
  --color-success: #10B981;
  --color-error: #EF4444;
  --color-warning: #F59E0B;
  --color-background: #FFFFFF;
  --color-surface: #F9FAFB;
  --color-text: #1F2937;
  --color-text-secondary: #6B7280;
  --color-border: #E5E7EB;
  --color-muted: #F3F4F6;
  
  /* الأزرار */
  --button-radius: 0.5rem;
  --button-padding: 0.625rem 1.25rem;
  --button-font-weight: 500;
  --button-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05);
  --button-hover-transform: scale(1.02);
  
  /* الجداول */
  --table-border-width: 1px;
  --table-row-spacing: 0.75rem;
  --table-alternating-bg: #F9FAFB;
  
  /* البطاقات */
  --card-radius: 0.75rem;
  --card-border: 1px solid #E5E7EB;
  --card-shadow: 0 1px 3px 0 rgb(0 0 0 / 0.1);
  --card-padding: 1.5rem;
  
  /* الخطوط */
  --font-heading: 'IBM Plex Sans Arabic', sans-serif;
  --font-body: 'Noto Sans Arabic', sans-serif;
  --font-size-base: 16px;
  --line-height: 1.6;
  
  /* التخطيط */
  --sidebar-width: 250px;
  --header-height: 64px;
  --content-max-width: 1200px;
}
```

### ثيم داكن

```css
/* styles/themes/dark.css */

[data-theme="dark"] {
  --color-primary: #818CF8;
  --color-secondary: #A78BFA;
  --color-success: #34D399;
  --color-error: #F87171;
  --color-warning: #FBBF24;
  --color-background: #111827;
  --color-surface: #1F2937;
  --color-text: #F9FAFB;
  --color-text-secondary: #9CA3AF;
  --color-border: #374151;
  --color-muted: #1F2937;
  
  --button-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.3);
  --card-shadow: 0 1px 3px 0 rgb(0 0 0 / 0.4);
  --card-border: 1px solid #374151;
}
```

### ثيم ملون (مدرسي)

```css
/* styles/themes/colorful.css */

[data-theme="colorful"] {
  --color-primary: #EC4899;
  --color-secondary: #8B5CF6;
  --color-success: #10B981;
  --color-error: #EF4444;
  --color-warning: #F59E0B;
  --color-background: #FFF7ED;
  --color-surface: #FFFFFF;
  --color-text: #1C1917;
  --color-text-secondary: #78716C;
  --color-border: #E7E5E4;
  --color-muted: #F5F5F4;
  
  --button-radius: 9999px;
  --button-shadow: 0 4px 6px -1px rgb(236 72 153 / 0.3);
  --card-radius: 1rem;
  --card-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1);
}
```

---

## تطبيق الثيم ديناميكياً

### React Hook

```typescript
// hooks/use-theme.ts

import { useState, useEffect } from 'react';
import { useLocalStorage } from './use-local-storage';

export function useTheme() {
  const [themeId, setThemeId] = useLocalStorage('afaq-theme', 'default');
  const [themes, setThemes] = useState<Theme[]>([]);
  
  useEffect(() => {
    // جلب الثيمات من الخادم
    fetchThemes().then(setThemes);
  }, []);
  
  useEffect() => {
    // تطبيق الثيم على الصفحة
    applyTheme(themeId);
  }, [themeId, themes]);
  
  const applyTheme = (id: string) => {
    const theme = themes.find(t => t.id === id);
    if (!theme) return;
    
    const root = document.documentElement;
    
    // تطبيق الألوان
    Object.entries(theme.colors).forEach(([key, value]) => {
      root.style.setProperty(`--color-${key}`, value);
    });
    
    // تطبيق الأزرار
    root.style.setProperty('--button-radius', getRadius(theme.buttons.shape));
    root.style.setProperty('--button-padding', getPadding(theme.buttons.size));
    root.style.setProperty('--button-font-weight', getFontWeight(theme.buttons.fontWeight));
    root.style.setProperty('--button-shadow', getShadow(theme.buttons.shadow));
    
    // تطبيق الجداول
    root.style.setProperty('--table-border-width', getBorderWidth(theme.tables.borderWidth));
    root.style.setProperty('--table-row-spacing', getSpacing(theme.tables.rowSpacing));
    
    // تطبيق البطاقات
    root.style.setProperty('--card-radius', getRadius(theme.cards.borderRadius));
    root.style.setProperty('--card-shadow', getShadow(theme.cards.shadow));
    root.style.setProperty('--card-padding', getSpacing(theme.cards.spacing));
    
    // تطبيق الخطوط
    root.style.setProperty('--font-heading', theme.fonts.heading);
    root.style.setProperty('--font-body', theme.fonts.body);
    root.style.setProperty('--font-size-base', theme.fonts.baseSize);
    root.style.setProperty('--line-height', theme.fonts.lineHeight);
    
    // تحديث attribute
    root.setAttribute('data-theme', id);
  };
  
  return {
    themeId,
    setThemeId,
    themes,
    currentTheme: themes.find(t => t.id === themeId),
  };
}

function getRadius(shape: string): string {
  const map: Record<string, string> = {
    none: '0',
    sm: '0.25rem',
    md: '0.5rem',
    lg: '0.75rem',
    full: '9999px',
  };
  return map[shape] || map['md'];
}

function getPadding(size: string): string {
  const map: Record<string, string> = {
    sm: '0.375rem 0.75rem',
    md: '0.625rem 1.25rem',
    lg: '0.75rem 1.5rem',
  };
  return map[size] || map['md'];
}

function getFontWeight(weight: string): string {
  const map: Record<string, string> = {
    normal: '400',
    medium: '500',
    bold: '700',
  };
  return map[weight] || map['medium'];
}

function getShadow(shadow: string): string {
  const map: Record<string, string> = {
    none: 'none',
    sm: '0 1px 2px 0 rgb(0 0 0 / 0.05)',
    md: '0 1px 3px 0 rgb(0 0 0 / 0.1)',
    lg: '0 4px 6px -1px rgb(0 0 0 / 0.1)',
  };
  return map[shadow] || map['sm'];
}

function getSpacing(spacing: string): string {
  const map: Record<string, string> = {
    compact: '0.75rem',
    normal: '1.5rem',
    relaxed: '2rem',
  };
  return map[spacing] || map['normal'];
}

function getBorderWidth(width: string): string {
  const map: Record<string, string> = {
    thin: '1px',
    medium: '2px',
    thick: '3px',
  };
  return map[width] || map['thin'];
}
```

---

## API إدارة الثيمات

```
# جلب جميع الثيمات
GET /api/v1/themes/

# جلب ثيم محدد
GET /api/v1/themes/{id}/

# إنشاء ثيم جديد (Admin)
POST /api/v1/themes/

# تحديث ثيم (Admin)
PUT /api/v1/themes/{id}/

# حذف ثيم (Admin)
DELETE /api/v1/themes/{id}/

# تطبيق ثيم على المستخدم
POST /api/v1/users/theme/
{
    "theme_id": "dark"
}

# جلب ثيم المستخدم
GET /api/v1/users/theme/
```

### Response

```json
{
  "id": "dark",
  "name": "Afaq Dark",
  "name_ar": "آفاق مسائي",
  "is_active": true,
  "colors": {
    "primary": "#818CF8",
    "secondary": "#A78BFA",
    "background": "#111827",
    "surface": "#1F2937",
    "text": "#F9FAFB"
  },
  "buttons": {
    "shape": "rounded",
    "size": "md",
    "shadow": "md"
  },
  "tables": {
    "style": "striped",
    "alternatingRows": true
  },
  "fonts": {
    "heading": "IBM Plex Sans Arabic",
    "body": "Noto Sans Arabic"
  }
}
```

---

## تصدير CSS

### للمسؤول

```typescript
// lib/export-theme.ts

export function exportThemeAsCSS(theme: Theme): string {
  let css = `/* Theme: ${theme.name} */\n`;
  css += `/* Generated by Afaq Technology */\n\n`;
  
  css += `:root {\n`;
  
  // الألوان
  Object.entries(theme.colors).forEach(([key, value]) => {
    css += `  --color-${key}: ${value};\n`;
  });
  
  css += `\n  /* Buttons */\n`;
  css += `  --button-radius: ${getRadius(theme.buttons.shape)};\n`;
  css += `  --button-padding: ${getPadding(theme.buttons.size)};\n`;
  
  css += `\n  /* Tables */\n`;
  css += `  --table-border-width: ${getBorderWidth(theme.tables.borderWidth)};\n`;
  css += `  --table-row-spacing: ${getSpacing(theme.tables.rowSpacing)};\n`;
  
  css += `\n  /* Cards */\n`;
  css += `  --card-radius: ${getRadius(theme.cards.borderRadius)};\n`;
  css += `  --card-shadow: ${getShadow(theme.cards.shadow)};\n`;
  
  css += `\n  /* Fonts */\n`;
  css += `  --font-heading: ${theme.fonts.heading};\n`;
  css += `  --font-body: ${theme.fonts.body};\n`;
  
  css += `}\n`;
  
  return css;
}
```

---

## ملخص

> **نظام الثيمات** يدعم اختيار المستخدمين من عدة ثيمات جاهزة، وإنشاء ثيمات مخصصة من لوحة الإدارة. المكونات: CSS Variables dinamically, Hook موحد للثيمات, API إدارة الثيمات, وتصدير CSS. الهدف: تجربة مستخدم مخصصة لكل مستخدم مع مرونة كاملة للمسؤول في تعديل الستايلات.
