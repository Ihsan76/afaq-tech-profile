# SEO متعدد اللغات (International SEO)

## نظرة عامة

SEO المتعدد اللغات يضمن ظهور المحتوى في نتائج البحث لكل لغة على حدة، مع تجنب المحتوى المكرر.

---

## بنية URLs

### الخيار المُوصى به: مسار لكل لغة

```
https://afaq.app/ar/                    # العربية
https://afaq.app/en/                    # English
https://afaq.app/fr/                    # Français
https://afaq.app/ar/teacher/lesson-plans/new
https://afaq.app/en/teacher/lesson-plans/new
```

### مقارنة الخيارات

| الخيار | المثال | المميزات | العيوب |
|--------|--------|----------|--------|
| **مسار** (مُوصى به) | `/ar/page` | SEO ممتاز، سهل الإدارة | — |
| **نطاق فرعي** | `ar.afaq.app` | عزل DNS | تكلفة أعلى، SEO أصعب |
| **معامل** | `?lang=ar` | بسيط | سيء للـ SEO |

---

##Hreflang Tags

### ما هوHreflang؟
علامة `<link>` تخبر Google باللغة والمنطقة للصفحة.

### التنفيذ في Next.js

```typescript
// app/[locale]/layout.tsx

import { Metadata } from 'next';

export async function generateMetadata({ params }: { params: { locale: string } }): Promise<Metadata> {
  const { locale } = params;
  const baseUrl = 'https://afaq.app';
  
  // إنشاء hreflang لكل لغة مدعومة
  const languages: Record<string, string> = {
    'ar': `${baseUrl}/ar`,
    'en': `${baseUrl}/en`,
    'fr': `${baseUrl}/fr`,
    'tr': `${baseUrl}/tr`,
    'ur': `${baseUrl}/ur`,
    'es': `${baseUrl}/es`,
    'de': `${baseUrl}/de`,
    'id': `${baseUrl}/id`,
    'bn': `${baseUrl}/bn`,
  };
  
  // إنشاء_alternates
  const alternates: Record<string, string> = {};
  for (const [lang, url] of Object.entries(languages)) {
    alternates[lang] = url;
  }
  
  return {
    alternates: {
      canonical: `${baseUrl}/${locale}`,
      languages: alternates,
    },
    openGraph: {
      locale: locale,
      alternateLocale: Object.keys(languages).filter(l => l !== locale),
    },
  };
}
```

### مثال علىHTML الناتج

```html
<link rel="alternate" hreflang="ar" href="https://afaq.app/ar" />
<link rel="alternate" hreflang="en" href="https://afaq.app/en" />
<link rel="alternate" hreflang="fr" href="https://afaq.app/fr" />
<link rel="alternate" hreflang="tr" href="https://afaq.app/tr" />
<link rel="alternate" hreflang="ur" href="https://afaq.app/ur" />
<link rel="alternate" hreflang="es" href="https://afaq.app/es" />
<link rel="alternate" hreflang="de" href="https://afaq.app/de" />
<link rel="alternate" hreflang="id" href="https://afaq.app/id" />
<link rel="alternate" hreflang="bn" href="https://afaq.app/bn" />
<link rel="alternate" hreflang="x-default" href="https://afaq.app/en" />

<link rel="canonical" href="https://afaq.app/ar" />
<meta property="og:locale" content="ar" />
<meta property="og:locale:alternate" content="en" />
<meta property="og:locale:alternate" content="fr" />
```

---

## Sitemap متعدد اللغات

### بنية Sitemap

```
/sitemaps/
├── sitemap-ar.xml        # خريطة الموقع للعربية
├── sitemap-en.xml        # خريطة الموقع للإنجليزية
├── sitemap-fr.xml        # خريطة الموقع للفرنسية
├── sitemap-index.xml     # الفهرس الرئيسي
└── robots.txt            # ملف robots
```

### إنشاء Sitemap ديناميكي

```typescript
// app/sitemap/[locale]/route.ts

import { MetadataRoute } from 'next';
import { locales } from '@/i18n/config';

export async function generateStaticParams() {
  return locales.map((locale) => ({ locale }));
}

export async function GET(
  request: Request,
  { params }: { params: { locale: string } }
) {
  const { locale } = params;
  const baseUrl = 'https://afaq.app';
  
  // الصفحات الثابتة
  const staticPages = [
    '',
    '/teacher/lesson-plans',
    '/student/dashboard',
    '/courses',
    '/blog',
    '/marketplace',
    '/settings',
  ];
  
  // الصفحات الديناميكية (من قاعدة البيانات)
  const dynamicPages = await getDynamicPages(locale);
  
  const urls = [...staticPages, ...dynamicPages].map((path) => ({
    url: `${baseUrl}/${locale}${path}`,
    lastModified: new Date(),
    changeFrequency: 'weekly' as const,
    priority: path === '' ? 1.0 : 0.8,
    alternates: {
      languages: Object.fromEntries(
        locales.map((loc) => [loc, `${baseUrl}/${loc}${path}`])
      ),
    },
  }));
  
  return new MetadataRoute.Sitemap(urls);
}
```

### Sitemap Index

```xml
<!-- sitemap-index.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <sitemap>
    <loc>https://afaq.app/sitemaps/sitemap-ar.xml</loc>
    <lastmod>2025-01-15</lastmod>
  </sitemap>
  <sitemap>
    <loc>https://afaq.app/sitemaps/sitemap-en.xml</loc>
    <lastmod>2025-01-15</lastmod>
  </sitemap>
  <sitemap>
    <loc>https://afaq.app/sitemaps/sitemap-fr.xml</loc>
    <lastmod>2025-01-15</lastmod>
  </sitemap>
</sitemapindex>
```

---

## robots.txt

```
# robots.txt
User-agent: *
Allow: /

# خرائط الموقع لكل لغة
Sitemap: https://afaq.app/sitemaps/sitemap-ar.xml
Sitemap: https://afaq.app/sitemaps/sitemap-en.xml
Sitemap: https://afaq.app/sitemaps/sitemap-fr.xml
Sitemap: https://afaq.app/sitemaps/sitemap-tr.xml
Sitemap: https://afaq.app/sitemaps/sitemap-ur.xml
Sitemap: https://afaq.app/sitemaps/sitemap-es.xml
Sitemap: https://afaq.app/sitemaps/sitemap-de.xml
Sitemap: https://afaq.app/sitemaps/sitemap-id.xml
Sitemap: https://afaq.app/sitemaps/sitemap-bn.xml

# منع الصفحات المكررة
Disallow: /*?lang=
Disallow: /*?redirect=
```

---

## Open Graph متعدد اللغات

### لكل صفحة

```typescript
// في generateMetadata
export async function generateMetadata({ params }: { params: { locale: string } }) {
  const { locale } = params;
  
  return {
    openGraph: {
      title: getTranslation(locale, 'meta.title'),
      description: getTranslation(locale, 'meta.description'),
      url: `https://afaq.app/${locale}`,
      siteName: 'Afaq Technology',
      locale: locale,
      type: 'website',
      alternateLocale: locales.filter(l => l !== locale),
      images: [
        {
          url: `https://afaq.app/og/${locale}.png`,
          width: 1200,
          height: 630,
          alt: getTranslation(locale, 'meta.og_alt'),
        },
      ],
    },
    twitter: {
      card: 'summary_large_image',
      title: getTranslation(locale, 'meta.title'),
      description: getTranslation(locale, 'meta.description'),
      images: [`https://afaq.app/og/${locale}.png`],
    },
  };
}
```

---

## JSON-LD متعدد اللغات

### Schema.org لكل صفحة

```typescript
// components/JsonLd.tsx

interface JsonLdProps {
  locale: string;
  type: 'Organization' | 'Course' | 'Article' | 'FAQPage';
  data: Record<string, any>;
}

export function JsonLd({ locale, type, data }: JsonLdProps) {
  const baseUrl = 'https://afaq.app';
  
  const jsonLd = {
    '@context': 'https://schema.org',
    '@type': type,
    ...data,
    inLanguage: locale,
    isPartOf: {
      '@type': 'WebSite',
      name: 'Afaq Technology',
      url: baseUrl,
      inLanguage: locales,
    },
  };
  
  return (
    <script
      type="application/ld+json"
      dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
    />
  );
}
```

### مثال: صفحة دورة

```json
{
  "@context": "https://schema.org",
  "@type": "Course",
  "name": "أساسيات الرياضيات",
  "description": "دورة شاملة في أساسيات الرياضيات",
  "inLanguage": "ar",
  "provider": {
    "@type": "Organization",
    "name": "Afaq Technology",
    "url": "https://afaq.app"
  },
  "hasCourseInstance": [
    {
      "@type": "CourseInstance",
      "courseMode": "online",
      "inLanguage": "ar"
    },
    {
      "@type": "CourseInstance",
      "courseMode": "online",
      "inLanguage": "en"
    }
  ]
}
```

---

## Meta Tags لكل لغة

### الإعدادات العامة

```typescript
// في layout.tsx
export async function generateMetadata({ params }: { params: { locale: string } }) {
  const { locale } = params;
  
  return {
    title: {
      default: getTranslation(locale, 'site.title'),
      template: `%s | ${getTranslation(locale, 'site.name')}`,
    },
    description: getTranslation(locale, 'site.description'),
    keywords: getTranslation(locale, 'site.keywords'),
    robots: {
      index: true,
      follow: true,
      googleBot: {
        index: true,
        follow: true,
        'max-video-preview': -1,
        'max-image-preview': 'large',
        'max-snippet': -1,
      },
    },
    verification: {
      google: process.env.GOOGLE_SITE_VERIFICATION,
    },
  };
}
```

---

## إعادة التوجيه حسب اللغة

### Middleware

```typescript
// middleware.ts
import { NextRequest, NextResponse } from 'next/server';
import { locales, defaultLocale } from '@/i18n/config';

export function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;
  
  // التحقق من وجود لغة في المسار
  const pathnameHasLocale = locales.some(
    (locale) => pathname.startsWith(`/${locale}/`) || pathname === `/${locale}`
  );
  
  if (pathnameHasLocale) return;
  
  // كشف اللغة من المتصفح
  const acceptLanguage = request.headers.get('accept-language') || '';
  const detectedLocale = detectLocale(acceptLanguage);
  
  // إعادة التوجيه
  request.nextUrl.pathname = `/${detectedLocale}${pathname}`;
  return NextResponse.redirect(request.nextUrl);
}

function detectLocale(acceptLanguage: string): string {
  const browserLocales = acceptLanguage
    .split(',')
    .map((lang) => lang.split(';')[0].split('-')[0].toLowerCase());
  
  for (const browserLocale of browserLocales) {
    if (locales.includes(browserLocale as any)) {
      return browserLocale;
    }
  }
  
  return defaultLocale;
}
```

---

## المحتوى المكرر vs المحتوى الفريد

### قاعدة "كل صفحة بلغتها"

```
✅ صحيح:
/Ar/courses/math-101       → محتوى عربي أصلي
/en/courses/math-101       → محتوى إنجليزي (ترجمة)
/fr/courses/math-101       → محتوى فرنسي (ترجمة)

❌ خاطئ:
/courses/math-101?lang=ar  → محتوى مكرر
/courses/math-101?lang=en  → محتوى مكرر
```

### كل صفحة لها:
- **URL فريد** لكل لغة
- **محتوى فريد** لكل لغة (ليس ترجمة آلية فقط)
- **meta tags** خاصة بكل لغة
- **hreflang** يربط بين اللغات

---

## تتبع أداء SEO حسب اللغة

### Google Search Console

```typescript
// تقارير الأداء لكل لغة
interface SEOReport {
  locale: string;
  impressions: number;
  clicks: number;
  ctr: number;
  position: number;
}

async function getSEOReportByLanguage(): Promise<SEOReport[]> {
  const reports: SEOReport[] = [];
  
  for (const locale of locales) {
    const report = await fetchSearchConsoleData({
      startDate: '2025-01-01',
      endDate: '2025-01-31',
      dimensions: ['query'],
      dimensionFilterGroups: [{
        dimension: 'page',
        expression: `https://afaq.app/${locale}/*`,
      }],
    });
    
    reports.push({
      locale,
      ...report,
    });
  }
  
  return reports;
}
```

---

## ملخص

> **SEO المتعدد اللغات** يضمن أن كل لغة لها حضور مستقل في محركات البحث. المكونات الأساسية: بنية URLs واضحة (`/ar/`, `/en/`)، hreflang tags، Sitemaps منفصلة لكل لغة، وmeta tags مخصصة. الهدف: تجنب المحتوى المكرر وتحسين تجربة البحث لكل مستخدم حسب لغته.
