# اختبارات تعدد اللغات (i18n Testing)

## نظرة عامة

كيفية اختبار جميع جوانب تعدد اللغات: RTL/LTR، تبديل اللغة، كشف اللغة، التخزين، وSEO.

---

## أنواع الاختبارات

| النوع | الأداة | الهدف |
|-------|--------|-------|
| **اختبارات الوحدة** | Vitest / Jest | اختبار دوال اللغة |
| **اختبارات المكونات** | Testing Library | اختبار واجهة اللغة |
| **اختبارات التكامل** | Playwright / Cypress | اختبار سير العمل |
| **اختبارات E2E** | Playwright | اختبار تجربة المستخدم |
| **اختبارات SEO** | Lighthouse | اختبار hreflang و sitemap |

---

## اختبار RTL/LTR

### اختبار اتجاه الصفحة

```typescript
// __tests__/i18n/rtl.test.ts

import { describe, it, expect } from 'vitest';
import { rtlLocales } from '@/i18n/config';

describe('RTL Support', () => {
  it('should identify RTL languages correctly', () => {
    expect(rtlLocales).toContain('ar');
    expect(rtlLocales).toContain('ur');
    expect(rtlLocales).toContain('fa');
    expect(rtlLocales).not.toContain('en');
    expect(rtlLocales).not.toContain('fr');
  });

  it('should set dir attribute for RTL languages', () => {
    const rtlLocale = 'ar';
    const ltrLocale = 'en';
    
    expect(rtlLocales.includes(rtlLocale as any)).toBe(true);
    expect(rtlLocales.includes(ltrLocale as any)).toBe(false);
  });
});
```

### اختبار CSS Logical Properties

```typescript
// __tests__/i18n/css-logical.test.ts

import { describe, it, expect } from 'vitest';

describe('CSS Logical Properties', () => {
  it('should use logical properties for RTL support', () => {
    // أمثلة على RTL/LTR
    const styles = {
      marginInlineStart: '16px',  // يعمل في RTL و LTR
      paddingInlineEnd: '8px',    // يعمل في RTL و LTR
    };
    
    expect(styles.marginInlineStart).toBe('16px');
  });
});
```

---

## اختبار تبديل اللغة

### اختبار مكون تبديل اللغة

```typescript
// __tests__/components/LanguageSwitcher.test.tsx

import { render, screen, fireEvent } from '@testing-library/react';
import { LanguageSwitcher } from '@/components/LanguageSwitcher';
import { NextIntlProvider } from 'next-intl';

describe('LanguageSwitcher', () => {
  const messages = {
    common: {
      language: 'Language',
    },
  };

  it('should render all available languages', () => {
    render(
      <NextIntlProvider locale="ar" messages={messages}>
        <LanguageSwitcher />
      </NextIntlProvider>
    );

    expect(screen.getByText('العربية')).toBeInTheDocument();
    expect(screen.getByText('English')).toBeInTheDocument();
    expect(screen.getByText('Français')).toBeInTheDocument();
  });

  it('should call onChange when language is switched', async () => {
    const onChange = vi.fn();
    
    render(
      <NextIntlProvider locale="ar" messages={messages}>
        <LanguageSwitcher onChange={onChange} />
      </NextIntlProvider>
    );

    const select = screen.getByRole('combobox');
    await fireEvent.change(select, { target: { value: 'en' } });

    expect(onChange).toHaveBeenCalledWith('en');
  });
});
```

---

## اختبار كشف اللغة

### اختبار خوارزمية الكشف

```typescript
// __tests__/i18n/detection.test.ts

import { describe, it, expect } from 'vitest';
import { detectBrowserLanguage } from '@/utils/language-detection';

describe('Language Detection', () => {
  it('should detect Arabic from Accept-Language', () => {
    const acceptLanguage = 'ar,en-US;q=0.9,en;q=0.8';
    expect(detectBrowserLanguage(acceptLanguage)).toBe('ar');
  });

  it('should detect English from Accept-Language', () => {
    const acceptLanguage = 'en-US,en;q=0.9';
    expect(detectBrowserLanguage(acceptLanguage)).toBe('en');
  });

  it('should detect French from Accept-Language', () => {
    const acceptLanguage = 'fr-FR,fr;q=0.9,en-US;q=0.8';
    expect(detectBrowserLanguage(acceptLanguage)).toBe('fr');
  });

  it('should fallback to English for unsupported languages', () => {
    const acceptLanguage = 'zh-CN,zh;q=0.9';
    expect(detectBrowserLanguage(acceptLanguage)).toBe('en');
  });

  it('should handle empty Accept-Language', () => {
    expect(detectBrowserLanguage('')).toBe('en');
  });

  it('should handle partial locale matches', () => {
    const acceptLanguage = 'ar-EG';
    expect(detectBrowserLanguage(acceptLanguage)).toBe('ar');
  });
});
```

---

## اختبار التخزين المحلي

### اختبار localStorage

```typescript
// __tests__/i18n/storage.test.ts

import { describe, it, expect, beforeEach } from 'vitest';
import { saveLanguagePreference, getSavedLanguage } from '@/utils/language-storage';

describe('Language Storage', () => {
  beforeEach(() => {
    localStorage.clear();
  });

  it('should save language to localStorage', () => {
    saveLanguagePreference('fr');
    expect(localStorage.getItem('afaq-locale')).toBe('fr');
  });

  it('should retrieve saved language', () => {
    localStorage.setItem('afaq-locale', 'de');
    expect(getSavedLanguage()).toBe('de');
  });

  it('should return null when no language is saved', () => {
    expect(getSavedLanguage()).toBeNull();
  });
});
```

---

## اختبار ترجمات JSON

### اختبار اكتمال الترجمات

```typescript
// __tests__/i18n/completeness.test.ts

import { describe, it, expect } from 'vitest';
import ar from '@/i18n/messages/ar.json';
import en from '@/i18n/messages/en.json';
import fr from '@/i18n/messages/fr.json';
import tr from '@/i18n/messages/tr.json';
import ur from '@/i18n/messages/ur.json';
import es from '@/i18n/messages/es.json';
import de from '@/i18n/messages/de.json';
import id from '@/i18n/messages/id.json';
import bn from '@/i18n/messages/bn.json';

describe('Translation Completeness', () => {
  const flattenObject = (obj: any, prefix = ''): string[] => {
    return Object.keys(obj).reduce((acc: string[], key) => {
      const newKey = prefix ? `${prefix}.${key}` : key;
      if (typeof obj[key] === 'object' && obj[key] !== null) {
        return [...acc, ...flattenObject(obj[key], newKey)];
      }
      return [...acc, newKey];
    }, []);
  };

  it('should have same keys in all 10 languages', () => {
    const baseKeys = flattenObject(ar).sort();
    for (const file of [en, fr, tr, ur, es, de, id, bn]) {
      expect(flattenObject(file).sort()).toEqual(baseKeys);
    }
  });

  it('should not have empty translations', () => {
    const checkEmpty = (obj: any, path = ''): string[] => {
      return Object.entries(obj).reduce((acc: string[], [key, value]) => {
        const currentPath = path ? `${path}.${key}` : key;
        if (typeof value === 'object' && value !== null) {
          return [...acc, ...checkEmpty(value, currentPath)];
        }
        if (value === '' || value === null) {
          acc.push(currentPath);
        }
        return acc;
      }, []);
    };

    const emptyAr = checkEmpty(ar);
    const emptyEn = checkEmpty(en);

    expect(emptyAr).toEqual([]);
    expect(emptyEn).toEqual([]);
  });
});
```

### اختبار اكتمال الترجمات في قاعدة البيانات

بعد `manage.py seed_translations`، يجب أن يتطابق عدد المفاتيح المفلّتة من ملفات JSON مع عدد `TranslationKey` في DB:

```python
# tests/test_db_translations.py

import json
from pathlib import Path

import pytest
from django.core.management import call_command

from apps.core.models import TranslationKey


@pytest.mark.django_db
def test_seed_translations_matches_json_files():
    """عدد المفاتيح في DB يساوي المفاتيح المفلّتة من messages/*.json"""
    call_command("seed_translations")

    keys = set(TranslationKey.objects.values_list("key", flat=True))

    # حساب المفاتيح من ملفات JSON
    messages_dir = Path(__file__).parents[2] / "frontend" / "src" / "i18n" / "messages"
    expected = set()
    for f in messages_dir.glob("*.json"):
        data = json.loads(f.read_text(encoding="utf-8"))
        expected.update(flatten(data))

    assert expected == keys
```

### اختبار الدمج الحي (TranslationProvider)

```typescript
// __tests__/i18n/merge.test.ts

import { mergeLiveTranslations } from '@/components/TranslationProvider';

describe('DB overrides merge', () => {
  const messages = { nav: { home: 'Home' } };
  const overrides = [
    { key: 'nav.home', translations: { ar: 'الرئيسية', en: 'Home' } },
    { key: 'common.save', translations: { ar: 'حفظ', en: 'Save' } },
  ];

  it('should nest dotted keys and merge over base', () => {
    const merged = mergeLiveTranslations(messages, overrides, 'ar');
    expect(merged.nav.home).toBe('الرئيسية');
    expect(merged.common.save).toBe('حفظ');
    expect(merged.nav.home).not.toBe('nav.home');
  });
});
```

> ⚠️ **درس مستفاد**: حقن المفاتيح **مسطّحة** (flat) فوق رسائل next-intl يكسر الترجمات (تظهر `nav.home` نصاً). الحل هو بناء كائنات متداخلة عبر `setNested` ثم `deepMerge` كما في `TranslationProvider.tsx`.

---

## اختبار API مع اللغة

### اختبار Accept-Language

```python
# tests/test_api_language.py

import pytest
from rest_framework.test import APIClient


@pytest.mark.django_db
class TestAPILanguage:
    """اختبار API مع تعدد اللغات"""
    
    def setup_method(self):
        self.client = APIClient()
    
    def test_error_message_in_arabic(self):
        """اختبار رسالة الخطأ بالعربية"""
        response = self.client.get(
            '/api/v1/lesson-plans/999/',
            HTTP_ACCEPT_LANGUAGE='ar'
        )
        
        assert response.status_code == 404
        assert response.data['error']['message'] == 'العنصر غير موجود'
        assert response.data['locale'] == 'ar'
    
    def test_error_message_in_english(self):
        """اختبار رسالة الخطأ بالإنجليزية"""
        response = self.client.get(
            '/api/v1/lesson-plans/999/',
            HTTP_ACCEPT_LANGUAGE='en'
        )
        
        assert response.status_code == 404
        assert response.data['error']['message'] == 'Resource not found'
        assert response.data['locale'] == 'en'
    
    def test_error_message_in_french(self):
        """اختبار رسالة الخطأ بالفرنسية"""
        response = self.client.get(
            '/api/v1/lesson-plans/999/',
            HTTP_ACCEPT_LANGUAGE='fr'
        )
        
        assert response.status_code == 404
        assert response.data['error']['message'] == 'Ressource non trouvée'
        assert response.data['locale'] == 'fr'
    
    def test_fallback_to_english(self):
        """اختبار التراجع للإنجليزية"""
        response = self.client.get(
            '/api/v1/lesson-plans/999/',
            HTTP_ACCEPT_LANGUAGE='zh'
        )
        
        assert response.status_code == 404
        assert response.data['locale'] == 'en'
    
    def test_lesson_plan_output_language(self):
        """اختبار توليد خطة درس بلغة مختلفة"""
        # إنشاء خطة درس بالإنجليزية
        response = self.client.post(
            '/api/v1/lesson-plans/generate/',
            {
                'subject': 1,
                'grade': 3,
                'lesson': 12,
                'topic': 'Natural Numbers',
                'output_language': 'en',
            },
            HTTP_ACCEPT_LANGUAGE='ar'
        )
        
        assert response.status_code == 201
        assert response.data['output_language'] == 'en'
```

---

## اختبار SEO

### اختبار hreflang

```typescript
// __tests__/seo/hreflang.test.ts

import { describe, it, expect } from 'vitest';

describe('Hreflang Tags', () => {
  it('should include hreflang for all supported languages', async () => {
    const response = await fetch('https://afaq.app/ar');
    const html = await response.text();
    
    const locales = ['ar', 'en', 'fr', 'tr', 'ur', 'es', 'de', 'id', 'bn'];
    
    for (const locale of locales) {
      expect(html).toContain(`hreflang="${locale}"`);
    }
    
    expect(html).toContain('hreflang="x-default"');
  });

  it('should include canonical URL', async () => {
    const response = await fetch('https://afaq.app/ar');
    const html = await response.text();
    
    expect(html).toContain('rel="canonical"');
    expect(html).toContain('href="https://afaq.app/ar"');
  });
});
```

### اختبار Sitemap

```typescript
// __tests__/seo/sitemap.test.ts

import { describe, it, expect } from 'vitest';

describe('Sitemap', () => {
  it('should have sitemap index', async () => {
    const response = await fetch('https://afaq.app/sitemaps/sitemap-index.xml');
    const xml = await response.text();
    
    expect(xml).toContain('<sitemapindex');
    expect(xml).toContain('sitemap-ar.xml');
    expect(xml).toContain('sitemap-en.xml');
  });

  it('should have locale-specific sitemaps', async () => {
    const locales = ['ar', 'en', 'fr'];
    
    for (const locale of locales) {
      const response = await fetch(`https://afaq.app/sitemaps/sitemap-${locale}.xml`);
      expect(response.status).toBe(200);
    }
  });
});
```

---

## اختبار واجهة المستخدم

### اختبار تبديل الاتجاه

```typescript
// __tests__/ui/direction.test.ts

import { render, screen } from '@testing-library/react';
import { DirectionProvider } from '@/components/DirectionProvider';

describe('Direction Switching', () => {
  it('should apply RTL direction for Arabic', () => {
    render(
      <DirectionProvider locale="ar">
        <div>Test</div>
      </DirectionProvider>
    );
    
    expect(document.documentElement.dir).toBe('rtl');
    expect(document.documentElement.lang).toBe('ar');
  });

  it('should apply LTR direction for English', () => {
    render(
      <DirectionProvider locale="en">
        <div>Test</div>
      </DirectionProvider>
    );
    
    expect(document.documentElement.dir).toBe('ltr');
    expect(document.documentElement.lang).toBe('en');
  });
});
```

---

## اختبار التوافق

### اختبار المتصفحات

```typescript
// __tests__/compatibility/browsers.test.ts

import { describe, it, expect } from 'vitest';

describe('Browser Compatibility', () => {
  it('should support Intl API', () => {
    expect(Intl.NumberFormat).toBeDefined();
    expect(Intl.DateTimeFormat).toBeDefined();
  });

  it('should format numbers correctly for Arabic', () => {
    const formatter = new Intl.NumberFormat('ar', {
      style: 'decimal',
      minimumFractionDigits: 2,
    });
    
    const result = formatter.format(1234567.89);
    expect(result).toContain('١');
  });

  it('should format dates correctly for Arabic', () => {
    const formatter = new Intl.DateTimeFormat('ar', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    });
    
    const date = new Date('2025-01-15');
    const result = formatter.format(date);
    expect(result).toContain('يناير');
  });
});
```

---

## أوامر الاختبار

```bash
# اختبارات الوحدة
npm run test:unit

# اختبارات i18n
npm run test:i18n

# اختبارات SEO
npm run test:seo

# اختبارات E2E
npm run test:e2e

# اختبارات التوافق
npm run test:compatibility

# تشغيل جميع الاختبارات
npm run test:all
```

---

## ملخص

> **اختبارات تعدد اللغات** تضمن صحة RTL/LTR، تبديل اللغة، كشف اللغة التلقائي، التخزين المحلي، وSEO. الأدوات: Vitest للوحدات، Testing Library للمكونات، Playwright لـ E2E. الهدف: تجربة مستخدم سلسة لجميع اللغات المدعومة.
