# استراتيجية الكاش للترجمات (i18n Caching)

## نظرة عامة

تحسين أداء تحميل الترجمات عبر طبقات كاش متعددة: CDN، Backend، Frontend.

---

## طبقات الكاش

```
┌─────────────────────────────────────────────────────────────────┐
│                    طبقات الكاش للترجمات                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  الطبقة 1: Browser Cache                                        │
│  ├── localStorage (الترجمات المحفوظة)                          │
│  ├── Session Storage (ترجمات الجلسة)                           │
│  └── Service Worker (ترجمات offline)                           │
│                                                                  │
│  الطبقة 2: CDN Cache                                            │
│  ├── Cloudflare (ملفات JSON)                                   │
│  ├── Cache-Control headers                                      │
│  └── Edge caching                                               │
│                                                                  │
│  الطبقة 3: Backend Cache                                        │
│  ├── Redis (ترجمات قاعدة البيانات)                              │
│  ├── Django Cache Framework                                     │
│  └── Query caching                                              │
│                                                                  │
│  الطبقة 4: Database                                             │
│  ├── PostgreSQL (ترجمات الأصلية)                               │
│  └── Read replicas (مستقبلاً)                                   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## الطبقة 1: Browser Cache

### localStorage

```typescript
// utils/translation-cache.ts

const CACHE_KEY = 'afaq-translations';
const CACHE_EXPIRY = 24 * 60 * 60 * 1000; // 24 ساعة

interface CachedTranslation {
  locale: string;
  data: Record<string, any>;
  timestamp: number;
}

export function saveTranslationsToCache(locale: string, data: Record<string, any>) {
  const cached: CachedTranslation = {
    locale,
    data,
    timestamp: Date.now(),
  };
  
  try {
    localStorage.setItem(CACHE_KEY, JSON.stringify(cached));
  } catch (e) {
    console.warn('Failed to save translations to cache:', e);
  }
}

export function getTranslationsFromCache(locale: string): Record<string, any> | null {
  try {
    const cached = localStorage.getItem(CACHE_KEY);
    if (!cached) return null;
    
    const parsed: CachedTranslation = JSON.parse(cached);
    
    // فحص انتهاء الصلاحية
    if (Date.now() - parsed.timestamp > CACHE_EXPIRY) {
      localStorage.removeItem(CACHE_KEY);
      return null;
    }
    
    // فحص اللغة
    if (parsed.locale !== locale) {
      return null;
    }
    
    return parsed.data;
  } catch (e) {
    return null;
  }
}
```

### Service Worker للترجمات

```typescript
// public/sw-translations.js

const TRANSLATIONS_CACHE = 'afaq-translations-v1';
const TRANSLATIONS_URL = '/i18n';

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(TRANSLATIONS_CACHE).then((cache) => {
      // تحميل جميع ملفات الترجمة مسبقاً
      const locales = ['ar', 'en', 'fr', 'tr', 'ur', 'es', 'de', 'id', 'bn'];
      const urls = locales.map((locale) => `${TRANSLATIONS_URL}/${locale}.json`);
      return cache.addAll(urls);
    })
  );
});

self.addEventListener('fetch', (event) => {
  if (event.request.url.includes('/i18n/')) {
    event.respondWith(
      caches.match(event.request).then((response) => {
        if (response) {
          return response;
        }
        
        return fetch(event.request).then((response) => {
          if (response.ok) {
            const responseToCache = response.clone();
            caches.open(TRANSLATIONS_CACHE).then((cache) => {
              cache.put(event.request, responseToCache);
            });
          }
          return response;
        });
      })
    );
  }
});
```

---

## الطبقة 2: CDN Cache

### Cloudflare Configuration

```yaml
# wrangler.toml

[env.production]
name = "afaq-i18n"
type = "javascript"

[[assets]]
bucket = "./public/i18n"
exclude_keys = ["*.html"]

[env.production.rules]
type = "Webpack"
webpack_config = "webpack.config.js"
```

### Cache Headers

```typescript
// app/i18n/[locale]/route.ts

import { NextRequest, NextResponse } from 'next/server';

export async function GET(
  request: NextRequest,
  { params }: { params: { locale: string } }
) {
  const { locale } = params;
  
  // جلب الترجمات
  const translations = await loadTranslations(locale);
  
  const response = NextResponse.json(translations);
  
  // إعدادات الكاش
  response.headers.set(
    'Cache-Control',
    'public, max-age=86400, stale-while-revalidate=604800'
  );
  
  // CDN cache key
  response.headers.set(
    'CDN-Cache-Control',
    'public, max-age=604800'  // 7 أيام للـ CDN
  );
  
  // Vercel cache
  response.headers.set(
    'Vercel-CDN-Cache-Control',
    'public, max-age=604800'
  );
  
  return response;
}
```

---

## الطبقة 3: Backend Cache (Redis)

### Django Cache Configuration

```python
# config/settings/base.py

CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.redis.RedisCache',
        'LOCATION': env('REDIS_URL', default='redis://redis:6379/0'),
        'OPTIONS': {
            'db': '0',
        },
        'KEY_PREFIX': 'afaq',
        'TIMEOUT': 60 * 60 * 24,  # 24 ساعة
    }
}

# Cache key patterns
TRANSLATION_CACHE_KEY = 'translation:{locale}:{key}'
TRANSLATIONS_CACHE_KEY = 'translations:{locale}'
```

### تخزين الترجمات

```python
# translations/cache.py

from django.core.cache import cache
from .models import Translation


class TranslationCache:
    """كاش الترجمات"""
    
    TIMEOUT = 60 * 60 * 24  # 24 ساعة
    
    @classmethod
    def get_translations(cls, locale: str) -> dict:
        """جلب جميع الترجمات للغة معينة"""
        cache_key = f'translations:{locale}'
        
        # محاولة الجلب من الكاش
        translations = cache.get(cache_key)
        if translations is not None:
            return translations
        
        # الجلب من قاعدة البيانات
        translations = Translation.objects.filter(
            language__code=locale,
            is_approved=True
        ).values_list('key', 'value')
        
        translations_dict = dict(translations)
        
        # التخزين في الكاش
        cache.set(cache_key, translations_dict, cls.TIMEOUT)
        
        return translations_dict
    
    @classmethod
    def get_translation(cls, locale: str, key: str) -> str:
        """جلب ترجمة محددة"""
        cache_key = f'translation:{locale}:{key}'
        
        # محاولة الجلب من الكاش
        value = cache.get(cache_key)
        if value is not None:
            return value
        
        # الجلب من قاعدة البيانات
        try:
            translation = Translation.objects.get(
                language__code=locale,
                key=key,
                is_approved=True
            )
            value = translation.value
        except Translation.DoesNotExist:
            value = None
        
        # التخزين في الكاش
        if value is not None:
            cache.set(cache_key, value, cls.TIMEOUT)
        
        return value
    
    @classmethod
    def invalidate(cls, locale: str):
        """مسح الكاش للغة معينة"""
        cache_key = f'translations:{locale}'
        cache.delete(cache_key)
        
        # مسح جميع المفاتيح الفرعية
        pattern = f'translation:{locale}:*'
        cache.delete_pattern(pattern)
    
    @classmethod
    def invalidate_all(cls):
        """مسح جميع الكاش"""
        cache.clear()
```

### استخدام الكاش في API

```python
# translations/views.py

from rest_framework.views import APIView
from rest_framework.response import Response
from .cache import TranslationCache


class TranslationsView(APIView):
    """جلب جميع الترجمات"""
    
    def get(self, request, locale):
        translations = TranslationCache.get_translations(locale)
        
        return Response({
            'locale': locale,
            'translations': translations,
            'count': len(translations),
        })


class TranslationView(APIView):
    """جلب ترجمة محددة"""
    
    def get(self, request, locale, key):
        value = TranslationCache.get_translation(locale, key)
        
        if value is None:
            return Response(
                {'error': 'Translation not found'},
                status=404
            )
        
        return Response({
            'locale': locale,
            'key': key,
            'value': value,
        })
```

---

## الطبقة 4: Frontend Cache

### تحميل الترجمات

```typescript
// i18n/loadTranslations.ts

import { saveTranslationsToCache, getTranslationsFromCache } from '@/utils/translation-cache';

export async function loadTranslations(locale: string): Promise<Record<string, any>> {
  // 1. فحص الكاش المحلي
  const cached = getTranslationsFromCache(locale);
  if (cached) {
    return cached;
  }
  
  // 2. الجلب من الخادم
  try {
    const response = await fetch(`/i18n/${locale}.json`);
    if (!response.ok) {
      throw new Error('Failed to load translations');
    }
    
    const translations = await response.json();
    
    // 3. التخزين في الكاش
    saveTranslationsToCache(locale, translations);
    
    return translations;
  } catch (error) {
    console.error('Error loading translations:', error);
    
    // 4. التراجع للإنجليزية
    if (locale !== 'en') {
      return loadTranslations('en');
    }
    
    return {};
  }
}
```

### React Query Cache

```typescript
// hooks/use-translations.ts

import { useQuery } from '@tanstack/react-query';
import { loadTranslations } from '@/i18n/loadTranslations';

export function useTranslations(locale: string) {
  return useQuery({
    queryKey: ['translations', locale],
    queryFn: () => loadTranslations(locale),
    staleTime: 1000 * 60 * 60,  // 1 ساعة
    cacheTime: 1000 * 60 * 60 * 24,  // 24 ساعة
    refetchOnWindowFocus: false,
  });
}
```

---

## Stale-While-Revalidate

### الفكرة

```
الطلب الأول:
├── الكاش فارغ → جلب من الخادم → عرض → تخزين في الكاش

الطلب الثاني (بعد 5 دقائق):
├── الكاش به البيانات → عرض فوراً
├── في الخلفية: تحديث الكاش من الخادم
└── إذا تغير التحديث → إعادة العرض

الطلب الثالث (بعد انتهاء الصلاحية):
├── الكاش منتهي الصلاحية → جلب من الخادم
└── عرض البيانات الجديدة
```

### التنفيذ

```typescript
// utils/swr-config.ts

export const swrConfig = {
  revalidateIfStale: true,
  revalidateOnMount: true,
  revalidateOnFocus: false,
  revalidateOnReconnect: false,
  refreshInterval: 1000 * 60 * 60,  // تحديث كل ساعة
  dedupingInterval: 1000 * 60 * 5,  // إزالة التكرار كل 5 دقائق
};
```

### التنفيذ الفعلي (SWR في المشروع) — `frontend/src/lib/useApi.ts`

```typescript
// src/lib/useApi.ts (أغسطس 2026 — بعد إصلاح صور الدورات)
const { data, error, isLoading, mutate } = useSWR<T>(
  key,
  () => api.get(url + qs).then((r) => r.data),
  { revalidateOnFocus: true, revalidateOnReconnect: true }
);
```

- كان `revalidateOnFocus: false` — أي قائمة (مثل الدورات مع روابط الصور) تبقى في ذاكرة التبويب حتى إعادة تحميل كاملة، فكانت الصور المعدّلة من الأدمين لا تظهر إلا بعد Ctrl+Shift+R.
- **التغيير**: تفعيل `revalidateOnFocus` + `revalidateOnReconnect` — عند العودة للتبويب أو إعادة الاتصال تُعاد مصادقة SWR تلقائياً وتُحدَّث البيانات (بما فيها الـ thumbnails) دون تحديث قسري.
- `useApi` / `useApiList` يستخدمهما معظم صفحات القوائم (دورات، كتب، إلخ). لا `staleTime`/`refreshInterval` افتراضياً (دورة حياة SWR في التبويب).
- ملاحظة: `usePrefetch` يُستخدم بحذر (تسخين الكاش بـ `revalidate: false`) — لا تُطلِق طلبات تفاصيل لكل عنصر قائمة بالتوازي.

---

## إعدادات الكاش حسب النوع

| النوع | Browser | CDN | Backend | TTL |
|-------|---------|-----|---------|-----|
| **واجهة المستخدم** | localStorage | Cloudflare | Redis | 24 ساعة |
| **محتوى ثابت** | Service Worker | Cloudflare | Redis | 7 أيام |
| **محتوى ديناميكي** | Session | لا | Redis | 1 ساعة |
| **بيانات المستخدم** | لا | لا | لا | لا |

---

## مسح الكاش

### مسح يدوي

```bash
# مسح كاش الترجمات
redis-cli DEL "afaq:translations:*"

# مسح كاش المتصفح
localStorage.removeItem('afaq-translations')
```

### مسح تلقائي

```python
# عند تحديث الترجمة
def update_translation(translation_id, new_value):
    translation = Translation.objects.get(id=translation_id)
    translation.value = new_value
    translation.save()
    
    # مسح الكاش
    TranslationCache.invalidate(translation.language.code)
```

---

## ملخص

> **استراتيجية الكاش للترجمات** تستخدم 4 طبقات: Browser (localStorage + Service Worker)، CDN (Cloudflare)، Backend (Redis)، Database. الهدف: تقليل وقت التحميل وتحسين الأداء مع الحفاظ على تحديث الترجمات. TTL: 24 ساعة للترجمات، 7 أيام للمحتوى الثابت.
