# شاشة الملف الشخصي

## شاشة عرض الملف الشخصي

### العناصر
- **Header**:
  - صورة المستخدم (حرف أول من الاسم في دائرة متدرجة)
  - اسم المستخدم
  - البريد الإلكتروني

- **قسم المعلومات الشخصية** (`glass-strong rounded-3xl`):
  - حقل: الاسم بالعربية (قابل للتعديل)
  - حقل: الاسم بالإنجليزية (قابل للتعديل)
  - حقل: البريد الإلكتروني (غير قابل للتعديل - `bg-[var(--color-muted)] cursor-not-allowed`)
  - حقل: الهاتف (قابل للتعديل)
  - dropdown: المنطقة الزمنية (Asia/Amman, Asia/Riyadh, Asia/Dubai, Africa/Cairo, Europe/London, America/New_York)

- **قسم إعدادات اللغة** (`glass-strong rounded-3xl`):
  - dropdown: لغة الواجهة (9 لغات: العربية, English, Français, Deutsch, Español, 中文, 日本語, 한국어, Türkçe)
  - dropdown: لغة الإدخال (9 لغات)
  - dropdown: لغة الإخراج (9 لغات)

- **قسم المظهر** (`glass-strong rounded-3xl`):
  - عنوان: "المظهر" مع أيقونة 🎨
  - وصف: "اختر الثيم المناسب لأسلوبك"
  - **مُختار الثيمات** (`ThemeSwitcher`): شبكة 2x3 أو 3x2
    - كل ثيم: بطاقة بـ (أيقونة + اسم + وصف + نقاط ألوان)
    - مؤشر تفعيل: دائرة بعلامة ✓ بلون الثيم الرئيسي
    - تأثير Hover: حدود ملونة + ظل + رفع خفيف

- **معلومات الحساب** (`glass-strong rounded-3xl`):
  - الدور (teacher/student/creator/admin)
  - حالة التوثيق (موثق/غير موثق) مع badge ملون
  - تاريخ الانضمام

- **زر الحفظ**:
  - `background: linear-gradient(135deg, var(--color-primary), var(--color-secondary))`
  - `rounded-xl font-semibold`
  - `box-shadow: var(--btn-shadow)`
  - حالة التحميل: `disabled:opacity-50 disabled:cursor-not-allowed`

### الرسائل
- **نجاح**: `bg-[var(--color-success-light)] text-[var(--color-success)] border border-[var(--color-success)]`
- **خطأ**: `bg-[var(--color-error-light)] text-[var(--color-error)] border border-[var(--color-error)]`

### التدفق
```
المستخدم → الملف الشخصي → تعديل البيانات → حفظ → تحديث فوري → رسالة نجاح
المستخدم → الملف الشخصي → اختيار ثيم → تطبيق فوري → حفظ في localStorage
```

### API
- `GET /api/v1/auth/profile/` - جلب بيانات المستخدم
- `PATCH /api/v1/auth/profile/` - تحديث البيانات

---

## نظام الثيمات

### الثيمات المتاحة (6 ثيمات)

| الثيم | المعرّف | الأيقونة | اللون الرئيسي | الخلفية |
|-------|---------|----------|---------------|---------|
| آفاق كلاسيكي | `classic` | 🎨 | `#4F46E5` (نيلي) | `#F8FAFC` |
| آفاق مسائي | `dark` | 🌙 | `#818CF8` (نيلي فاتح) | `#0F0D1A` |
| آفاق فاتح | `light` | ☀️ | `#059669` (زمرد) | `#FAFDF9` |
| آفاق محايد | `neutral` | ⚪ | `#374151` (رمادي) | `#F9FAFB` |
| آفاق مدرسي | `colorful` | 🌈 | `#EC4899` (وردي) | `#FFF7ED` |
| آفاق محيطي | `ocean` | 🌊 | `#0891B2` (أزرق سماوي) | `#ECFEFF` |

### معمارية الثيم

```typescript
// types/theme.ts
export interface Theme {
  id: string;
  name: string;
  name_ar: string;
  icon: string;
  description: string;
  description_ar: string;
  is_active: boolean;
  is_default: boolean;
  colors: ThemeColors;
  buttons: ThemeButtons;
  cards: ThemeCards;
  fonts: ThemeFonts;
}
```

### CSS Variables

```css
:root {
  /* الألوان */
  --color-primary: #4F46E5;
  --color-primary-hover: #4338CA;
  --color-primary-light: #EEF2FF;
  --color-secondary: #7C3AED;
  --color-accent: #6366F1;
  --color-success: #10B981;
  --color-error: #EF4444;
  --color-warning: #F59E0B;
  --color-background: #F8FAFC;
  --color-surface: #FFFFFF;
  --color-surface-alt: #F1F5F9;
  --color-text: #0F172A;
  --color-text-secondary: #475569;
  --color-text-muted: #94A3B8;
  --color-border: #E2E8F0;
  --color-border-light: #F1F5F9;
  --color-muted: #F1F5F9;

  /* الأزرار */
  --btn-radius: 0.75rem;
  --btn-padding: 0.625rem 1.25rem;
  --btn-font-weight: 600;
  --btn-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1);
  --btn-hover-transform: scale(1.02);

  /* البطاقات */
  --card-radius: 1.25rem;
  --card-border: 1px solid var(--color-border);
  --card-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.07);
  --card-glass: 1;

  /* الخطوط */
  --font-heading: 'IBM Plex Sans Arabic', sans-serif;
  --font-body: 'Noto Sans Arabic', sans-serif;
  --font-size-base: 16px;
  --line-height: 1.6;
}
```

### React Hook

```typescript
// hooks/useTheme.ts
export function useTheme() {
  const [themeId, setThemeIdState] = useState("classic");
  const [isLoaded, setIsLoaded] = useState(false);

  useEffect(() => {
    const stored = getStoredTheme();
    const theme = THEMES.find(t => t.id === stored) || THEMES[0];
    setThemeIdState(theme.id);
    applyThemeToDOM(theme);
    setIsLoaded(true);
  }, []);

  const setThemeId = useCallback((id: string) => {
    const theme = THEMES.find(t => t.id === id);
    if (!theme) return;
    setThemeIdState(id);
    localStorage.setItem("afaq-theme", id);
    applyThemeToDOM(theme);
  }, []);

  return { themeId, setThemeId, currentTheme, themes: THEMES, isLoaded };
}
```

### حفظ الثيم
- **localStorage**: `afaq-theme` key
- **تطبيق فوري**: عبر `document.documentElement.setAttribute("data-theme", id)`
- **تحول سلس**: فئة `theme-transitioning` لمدة 400ms
- **بدون إعادة تحميل**: تطبيق CSS variables ديناميكياً

### المكونات
- `ThemeSwitcher` - مُختار الثيمات (شبكة بطاقات)
- `useTheme` - Hook للثيمات
- `types/theme.ts` - تعريفات TypeScript
- `globals.css` - متغيرات CSS لجميع الثيمات
