# الوضع غير المتصل / PWA (Offline Support)

## نظرة عامة

المنصة تعمل كـ Progressive Web App (PWA) مع دعم كامل للعمل بدون اتصال بالإنترنت.

---

## الميزات الرئيسية

| الميزة | الوصف |
|--------|-------|
| **تثبيت** | تثبيت على الشاشة الرئيسية كتطبيق أصلي |
| **عمل غير متصل** | تصفح المحتوى المحفوظ بدون إنترنت |
| **مزامنة** | مزامنة تلقائية عند العودة للإنترنت |
| **إشعارات** | إشعارات الدفع حتى بدون إنترنت |
| **تحسين** | تحميل المحتوى بشكل تدريجي |

---

## التنفيذ الفعلي (أغسطس 2026) — `public/sw.js` (ملف يدوي، بدون Workbox)

> التنفيذ الحالي في `frontend/public/sw.js` هو **Service Worker مكتوب يدوياً** (سطر ~150) وليس Workbox. الأقسام أدناه تعكس المخطط الطموح؛ هذا القسم يوثّق ما يعمل فعلياً في الإنتاج.

### النطاق: التنقّل فقط (إصلاح صور الدورات)

- معالج `fetch` يعترض **صفحات التنقّل فقط** عبر شرط `if (event.request.mode !== "navigate") return;`.
- **كل الطلبات الأخرى تمر دون تدخل**: الصور الخارجية (`i.ytimg.com`, `*.supabase.co`)، السكربتات، الخطوط، و`/api/` — تُجلب من الشبكة مباشرة. هذا **يصلح مشكلة صور الدورات التي لم تكن تُحمّل إلا بعد Ctrl+Shift+R** (كان الـ SW القديم يعترض كل GET بما فيها الصور ويخدم نسخاً قديمة من كاش لا يُمسح).

### استراتيجية كاش التنقّل (cache-first للسرعة + تحديث خلفي دوري)

| الحالة | السلوك |
|--------|--------|
| نسخة مخزنة **حديثة** (< `NAV_TTL_MS` = 5 دقائق) | تُعرض فوراً — لا طلب شبكة (تحميل سريع) |
| نسخة مخزنة **قديمة** (تجاوزت TTL) | تُعرض فوراً ثم يُعاد جلب الصفحة في الخلفية وتُحدَّث النسخة |
| **لا نسخة** | جلب من الشبكة وتخزينها (مع ختم زمني `x-sw-cached-at`) |
| **فشل الشبكة** | العودة للصفحة المخزنة `/` (أوفلاين) |

- الختم الزمني يُلحَق عبر `x-sw-cached-at` عند التخزين ويُقرأ منه للتحقق من انتهاء TTL.
- **ترقية النسخة `afaq-tech-v2`**: `activate` يحذف كل الكاشات ذات الأسماء الأخرى (بما فيها v1 القديم) — يشفى المستخدمون المتأثرون فور التفعيل.
- `skipWaiting()` + `clients.claim()` يفعّلان النسخة الجديدة سريعاً.
- `next.config.ts` يضيف `Cache-Control: no-cache` لمسار `/sw.js` حتى تنتشر النسخة الجديدة عبر Vercel/Cloudflare فوراً.
- **إشعارات push** (معالجا `push` و `notificationclick`) باقيان كما هما — التسجيل عبر `navigator.serviceWorker.register("/sw.js")` + `pushManager` في `src/store/notifications.ts`.

---

## Service Worker

### التثبيت والتفعيل

```javascript
// public/sw.js

import { precacheAndRoute } from 'workbox-precaching';
import { registerRoute } from 'workbox-routing';
import { CacheFirst, StaleWhileRevalidate, NetworkFirst } from 'workbox-strategies';
import { ExpirationPlugin } from 'workbox-expiration';
import { CacheableResponsePlugin } from 'workbox-cacheable-response';

// تثبيت الموارد الأساسية
precacheAndRoute(self.__WB_MANIFEST);

// استراتيجية التخزين المؤقت للموارد الثابتة
registerRoute(
  ({ request }) => request.destination === 'style' || request.destination === 'script',
  new CacheFirst({
    cacheName: 'static-resources',
    plugins: [
      new CacheableResponsePlugin({ statuses: [0, 200] }),
      new ExpirationPlugin({ maxAgeSeconds: 30 * 24 * 60 * 60 }), // 30 يوم
    ],
  })
);

// استراتيجية الصور
registerRoute(
  ({ request }) => request.destination === 'image',
  new CacheFirst({
    cacheName: 'images',
    plugins: [
      new CacheableResponsePlugin({ statuses: [0, 200] }),
      new ExpirationPlugin({ maxAgeSeconds: 60 * 24 * 60 * 60 }), // 60 يوم
      new ExpirationPlugin({ maxEntries: 1000 }),
    ],
  })
);

// استراتيجية API (StaleWhileRevalidate)
registerRoute(
  ({ url }) => url.pathname.startsWith('/api/v1/'),
  new StaleWhileRevalidate({
    cacheName: 'api-cache',
    plugins: [
      new CacheableResponsePlugin({ statuses: [0, 200] }),
      new ExpirationPlugin({ maxAgeSeconds: 5 * 60 }), // 5 دقائق
    ],
  })
);

// استراتيجية المحتوى التعليمي (NetworkFirst)
registerRoute(
  ({ url }) => url.pathname.startsWith('/api/v1/lessons') || 
                url.pathname.startsWith('/api/v1/courses'),
  new NetworkFirst({
    cacheName: 'educational-content',
    plugins: [
      new CacheableResponsePlugin({ statuses: [0, 200] }),
      new ExpirationPlugin({ maxAgeSeconds: 24 * 60 * 60 }), // 24 ساعة
    ],
    networkTimeoutSeconds: 3, // timeout بعد 3 ثواني
  })
);

// استراتيجية البحث (NetworkOnly)
registerRoute(
  ({ url }) => url.pathname.startsWith('/api/v1/search'),
  new NetworkFirst({
    cacheName: 'search-results',
    networkTimeoutSeconds: 2,
  })
);

// التعامل مع رسائل التحديث
self.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
});

// مزامنة الخلفية
self.addEventListener('sync', (event) => {
  if (event.tag === 'background-sync') {
    event.waitUntil(performBackgroundSync());
  }
});

// التعامل مع الإشعارات
self.addEventListener('push', (event) => {
  const data = event.data.json();
  
  event.waitUntil(
    self.registration.showNotification(data.title, {
      body: data.body,
      icon: '/icons/icon-192.png',
      badge: '/icons/badge-72.png',
      data: data.url,
      actions: [
        { action: 'open', title: 'فتح' },
        { action: 'dismiss', title: 'تجاهل' },
      ],
    })
  );
});
```

---

## React Hook للعمل غير المتصل

```typescript
// hooks/useOffline.ts

'use client';

import { useState, useEffect } from 'react';

interface OfflineStatus {
  isOffline: boolean;
  isOnline: boolean;
  lastOnline: Date | null;
  pendingSync: number;
}

export function useOffline(): OfflineStatus {
  const [status, setStatus] = useState<OfflineStatus>({
    isOffline: !navigator.onLine,
    isOnline: navigator.onLine,
    lastOnline: null,
    pendingSync: 0,
  });

  useEffect(() => {
    const handleOnline = () => {
      setStatus(prev => ({
        ...prev,
        isOffline: false,
        isOnline: true,
        lastOnline: new Date(),
      }));
      
      // بدء المزامنة
      syncPendingData();
    };

    const handleOffline = () => {
      setStatus(prev => ({
        ...prev,
        isOffline: true,
        isOnline: false,
      }));
    };

    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);

    // عدد العناصر المعلقة
    const pendingCount = getPendingSyncCount();
    setStatus(prev => ({ ...prev, pendingSync: pendingCount }));

    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
    };
  }, []);

  return status;
}

// مزامنة البيانات المعلقة
async function syncPendingData() {
  const pendingItems = getPendingSyncItems();
  
  for (const item of pendingItems) {
    try {
      await fetch(item.url, {
        method: item.method,
        headers: item.headers,
        body: item.body,
      });
      
      // حذف العنصر المزامن
      removePendingSyncItem(item.id);
    } catch (error) {
      console.error('Sync failed for:', item.url);
    }
  }
}

// إدارة التخزين المحلي
function getPendingSyncCount(): number {
  if (typeof window === 'undefined') return 0;
  const items = localStorage.getItem('pendingSync');
  return items ? JSON.parse(items).length : 0;
}

function getPendingSyncItems(): Array<{
  id: string;
  url: string;
  method: string;
  headers: Record<string, string>;
  body: string;
}> {
  if (typeof window === 'undefined') return [];
  const items = localStorage.getItem('pendingSync');
  return items ? JSON.parse(items) : [];
}

function removePendingSyncItem(id: string) {
  const items = getPendingSyncItems();
  const filtered = items.filter(item => item.id !== id);
  localStorage.setItem('pendingSync', JSON.stringify(filtered));
}
```

---

## صفحة حالة الاتصال

```typescript
// components/OfflineIndicator.tsx

'use client';

import { useOffline } from '@/hooks/useOffline';

export function OfflineIndicator() {
  const { isOffline, pendingSync } = useOffline();

  if (!isOffline) return null;

  return (
    <div className="fixed top-0 left-0 right-0 bg-yellow-500 text-white p-2 text-center z-50">
      <div className="flex items-center justify-center gap-2">
        <span>⚠️ أنت تعمل بدون اتصال بالإنترنت</span>
        {pendingSync > 0 && (
          <span className="bg-yellow-600 px-2 py-1 rounded text-sm">
            {pendingSync} عناصر في الانتظار
          </span>
        )}
      </div>
    </div>
  );
}
```

---

## التخزين المحلي للمحتوى

```typescript
// lib/offlineStorage.ts

import { openDB } from 'idb';

const DB_NAME = 'afaq-offline';
const DB_VERSION = 1;

// إنشاء قاعدة البيانات
async function getDB() {
  return openDB(DB_NAME, DB_VERSION, {
    upgrade(db) {
      // مخزن الدورات
      if (!db.objectStoreNames.contains('courses')) {
        const courseStore = db.createObjectStore('courses', { keyPath: 'id' });
        courseStore.createIndex('subject', 'subject');
        courseStore.createIndex('level', 'level');
      }
      
      // مخزن الدروس
      if (!db.objectStoreNames.contains('lessons')) {
        const lessonStore = db.createObjectStore('lessons', { keyPath: 'id' });
        lessonStore.createIndex('course_id', 'course_id');
        lessonStore.createIndex('subject', 'subject');
      }
      
      // مخزن الملفات الشخصية
      if (!db.objectStoreNames.contains('profile')) {
        db.createObjectStore('profile', { keyPath: 'userId' });
      }
      
      // مخزن الإعدادات
      if (!db.objectStoreNames.contains('settings')) {
        db.createObjectStore('settings', { keyPath: 'key' });
      }
      
      // مخزن البحث
      if (!db.objectStoreNames.contains('search_cache')) {
        const searchStore = db.createObjectStore('search_cache', { keyPath: 'query' });
        searchStore.createIndex('timestamp', 'timestamp');
      }
    },
  });
}

// حفظ الدورة
export async function saveCourseOffline(course: any) {
  const db = await getDB();
  await db.put('courses', {
    ...course,
    savedAt: new Date().toISOString(),
  });
}

// جلب الدورات المحفوظة
export async function getOfflineCourses() {
  const db = await getDB();
  return db.getAll('courses');
}

// حفظ الدرس
export async function saveLessonOffline(lesson: any) {
  const db = await getDB();
  await db.put('lessons', {
    ...lesson,
    savedAt: new Date().toISOString(),
  });
}

// جلب الدروس المحفوظة
export async function getOfflineLessons(courseId: string) {
  const db = await getDB();
  const index = db.transaction('lessons').store.index('course_id');
  return index.getAll(courseId);
}

// حفظ نتائج البحث
export async function saveSearchResults(query: string, results: any[]) {
  const db = await getDB();
  await db.put('search_cache', {
    query,
    results,
    timestamp: new Date().toISOString(),
  });
}

// جلب نتائج البحث المحفوظة
export async function getOfflineSearchResults(query: string) {
  const db = await getDB();
  return db.get('search_cache', query);
}

// حذف المحتوى القديم
export async function cleanupOldContent(maxAgeDays: number = 30) {
  const db = await getDB();
  const cutoff = new Date();
  cutoff.setDate(cutoff.getDate() - maxAgeDays);
  
  const tx = db.transaction(['courses', 'lessons'], 'readwrite');
  
  // حذف الدورات القديمة
  const courseStore = tx.objectStore('courses');
  const courseIndex = courseStore.index('savedAt');
  let cursor = await courseStore.openCursor();
  
  while (cursor) {
    if (new Date(cursor.value.savedAt) < cutoff) {
      cursor.delete();
    }
    cursor = await cursor.continue();
  }
  
  await tx.done;
}
```

---

## مزامنة المحتوى

```typescript
// lib/contentSync.ts

import { saveCourseOffline, saveLessonOffline } from './offlineStorage';

export class ContentSync {
  private static SYNC_INTERVAL = 5 * 60 * 1000; // 5 دقائق
  private static syncTimer: NodeJS.Timeout | null = null;

  // بدء المزامنة التلقائية
  static startAutoSync() {
    if (this.syncTimer) return;
    
    this.syncTimer = setInterval(() => {
      this.syncContent();
    }, this.SYNC_INTERVAL);
  }

  // إيقاف المزامنة
  static stopAutoSync() {
    if (this.syncTimer) {
      clearInterval(this.syncTimer);
      this.syncTimer = null;
    }
  }

  // مزامنة المحتوى
  static async syncContent() {
    if (!navigator.onLine) return;

    try {
      // مزامنة الدورات المحفوظة
      await this.syncSavedCourses();
      
      // مزامنة الدروس المحفوظة
      await this.syncSavedLessons();
      
      // مزامنة الملف الشخصي
      await this.syncProfile();
      
    } catch (error) {
      console.error('Content sync failed:', error);
    }
  }

  // مزامنة الدورات
  private static async syncSavedCourses() {
    const response = await fetch('/api/v1/courses/sync/', {
      headers: {
        'Authorization': `Bearer ${getToken()}`,
      },
    });
    
    const courses = await response.json();
    
    for (const course of courses) {
      await saveCourseOffline(course);
    }
  }

  // مزامنة الدروس
  private static async syncSavedLessons() {
    const response = await fetch('/api/v1/lessons/sync/', {
      headers: {
        'Authorization': `Bearer ${getToken()}`,
      },
    });
    
    const lessons = await response.json();
    
    for (const lesson of lessons) {
      await saveLessonOffline(lesson);
    }
  }

  // مزامنة الملف الشخصي
  private static async syncProfile() {
    const response = await fetch('/api/v1/users/me/', {
      headers: {
        'Authorization': `Bearer ${getToken()}`,
      },
    });
    
    const profile = await response.json();
    
    // حفظ في التخزين المحلي
    const db = await getDB();
    await db.put('profile', { userId: profile.id, ...profile });
  }
}
```

---

## إعدادات PWA

```json
// public/manifest.json

{
  "name": "آفاق تكنولوجي",
  "short_name": "آفاق",
  "description": "منصة تعليمية ذكية",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#3b82f6",
  "orientation": "any",
  "icons": [
    {
      "src": "/icons/icon-72x72.png",
      "sizes": "72x72",
      "type": "image/png"
    },
    {
      "src": "/icons/icon-96x96.png",
      "sizes": "96x96",
      "type": "image/png"
    },
    {
      "src": "/icons/icon-128x128.png",
      "sizes": "128x128",
      "type": "image/png"
    },
    {
      "src": "/icons/icon-144x144.png",
      "sizes": "144x144",
      "type": "image/png"
    },
    {
      "src": "/icons/icon-152x152.png",
      "sizes": "152x152",
      "type": "image/png"
    },
    {
      "src": "/icons/icon-192x192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "any maskable"
    },
    {
      "src": "/icons/icon-384x384.png",
      "sizes": "384x384",
      "type": "image/png"
    },
    {
      "src": "/icons/icon-512x512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "any maskable"
    }
  ],
  "screenshots": [
    {
      "src": "/screenshots/desktop.png",
      "sizes": "1920x1080",
      "type": "image/png",
      "form_factor": "wide"
    },
    {
      "src": "/screenshots/mobile.png",
      "sizes": "390x844",
      "type": "image/png",
      "form_factor": "narrow"
    }
  ],
  "categories": ["education", "productivity"],
  "lang": "ar",
  "dir": "auto"
}
```

---

## إعداد Next.js لـ PWA

```javascript
// next.config.js

const withPWA = require('next-pwa')({
  dest: 'public',
  register: true,
  skipWaiting: true,
  disable: process.env.NODE_ENV === 'development',
  runtimeCaching: [
    {
      urlPattern: /^https:\/\/fonts\.googleapis\.com\/.*/i,
      handler: 'CacheFirst',
      options: {
        cacheName: 'google-fonts-cache',
        expiration: {
          maxEntries: 10,
          maxAgeSeconds: 60 * 60 * 24 * 365, // سنة
        },
      },
    },
    {
      urlPattern: /\.(?:eot|otf|ttc|ttf|woff|woff2|font.css)$/i,
      handler: 'StaleWhileRevalidate',
      options: {
        cacheName: 'static-font-assets',
        expiration: {
          maxEntries: 10,
          maxAgeSeconds: 60 * 60 * 24 * 365, // سنة
        },
      },
    },
    {
      urlPattern: /\.(?:jpg|jpeg|gif|png|svg|ico|webp)$/i,
      handler: 'StaleWhileRevalidate',
      options: {
        cacheName: 'static-image-assets',
        expiration: {
          maxEntries: 64,
          maxAgeSeconds: 60 * 60 * 24 * 30, // 30 يوم
        },
      },
    },
    {
      urlPattern: /\/_next\/static.+\.js$/i,
      handler: 'CacheFirst',
      options: {
        cacheName: 'next-static-js-assets',
        expiration: {
          maxEntries: 64,
          maxAgeSeconds: 60 * 60 * 24 * 30, // 30 يوم
        },
      },
    },
  ],
});

module.exports = withPWA({
  // إعدادات Next.js
});
```

---

## ملخص

> **الوضع غير المتصل / PWA** يشمل Service Worker مع استراتيجيات تخزين مؤقت ذكية، React Hooks للعمل غير المتصل، IndexedDB للمحتوى المحفوظ، مزامنة تلقائية عند العودة للإنترنت، وإعدادات PWA كاملة مع manifest.json. **التنفيذ الفعلي (أغسطس 2026)**: `sw.js` يدوي — نطاق تنقّل فقط، cache-first مع تحديث خلفي دوري (TTL 5 دقائق)، كاش v2، وإشعارات push — انظر قسم «التنفيذ الفعلي» أعلاه.
