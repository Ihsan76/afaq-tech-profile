# تحسين الأداء (Performance Optimization)

## نظرة عامة

استراتيجيات شاملة لتحسين أداء المنصة على جميع المستويات.

---

## المكونات

```
┌─────────────────────────────────────────────────────────────────┐
│                    Performance Stack                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────┐    ┌──────────────────┐                   │
│  │  Image           │    │  Code Splitting  │                   │
│  │  Optimization    │    │  & Lazy Loading  │                   │
│  │  (Next/Image)    │    │  (React.lazy)    │                   │
│  └──────────────────┘    └──────────────────┘                   │
│                                                                  │
│  ┌──────────────────┐    ┌──────────────────┐                   │
│  │  CDN Caching     │    │  Database        │                   │
│  │  (Cloudflare)    │    │  Optimization    │                   │
│  └──────────────────┘    └──────────────────┘                   │
│                                                                  │
│  ┌──────────────────┐    ┌──────────────────┐                   │
│  │  API Response    │    │  Compression     │                   │
│  │  Caching         │    │  (Brotli/Gzip)   │                   │
│  └──────────────────┘    └──────────────────┘                   │
│                                                                  │
│  ┌──────────────────┐    ┌──────────────────┐                   │
│  │  Core Web Vitals │    │  Real User       │                   │
│  │  Monitoring      │    │  Monitoring      │                   │
│  └──────────────────┘    └──────────────────┘                   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Next.js Optimization

### Image Optimization

```typescript
// next.config.js

module.exports = {
  images: {
    formats: ['image/avif', 'image/webp'],
    deviceSizes: [640, 750, 828, 1080, 1200, 1920, 2048],
    imageSizes: [16, 32, 48, 64, 96, 128, 256, 384],
    remotePatterns: [
      {
        protocol: 'https',
        hostname: '*.afaq.app',
      },
      {
        protocol: 'https',
        hostname: 'images.unsplash.com',
      },
    ],
  },
  
  // التحسينات
  experimental: {
    optimizePackageImports: ['@heroicons/react', 'lucide-react'],
  },
  
  // Compression
  compress: true,
  
  // Production Browser Source Maps
  productionBrowserSourceMaps: false,
};
```

```tsx
// components/OptimizedImage.tsx

'use client';

import Image from 'next/image';
import { useState } from 'react';

interface OptimizedImageProps {
  src: string;
  alt: string;
  width?: number;
  height?: number;
  priority?: boolean;
  className?: string;
}

export function OptimizedImage({
  src,
  alt,
  width = 600,
  height = 400,
  priority = false,
  className,
}: OptimizedImageProps) {
  const [isLoading, setIsLoading] = useState(true);

  return (
    <div className={`relative overflow-hidden ${className}`}>
      {isLoading && (
        <div className="absolute inset-0 bg-gray-200 animate-pulse" />
      )}
      <Image
        src={src}
        alt={alt}
        width={width}
        height={height}
        priority={priority}
        loading={priority ? 'eager' : 'lazy'}
        placeholder="blur"
        blurDataURL="data:image/jpeg;base64,/9j/4AAQSkZJRg..."
        onLoad={() => setIsLoading(false)}
        className={`transition-opacity duration-300 ${
          isLoading ? 'opacity-0' : 'opacity-100'
        }`}
      />
    </div>
  );
}
```

### Code Splitting & Lazy Loading

```typescript
// app/[locale]/dashboard/page.tsx

import dynamic from 'next/dynamic';
import { Suspense } from 'react';

// Lazy load heavy components
const Charts = dynamic(() => import('@/components/Charts'), {
  loading: () => <div className="h-64 bg-gray-100 animate-pulse" />,
  ssr: false,
});

const DataTable = dynamic(() => import('@/components/DataTable'), {
  loading: () => <div className="h-96 bg-gray-100 animate-pulse" />,
});

const PDFViewer = dynamic(() => import('@/components/PDFViewer'), {
  loading: () => <div className="h-screen bg-gray-100 animate-pulse" />,
  ssr: false,
});

export default function DashboardPage() {
  return (
    <div>
      <h1>Dashboard</h1>
      
      <Suspense fallback={<div>Loading charts...</div>}>
        <Charts />
      </Suspense>
      
      <Suspense fallback={<div>Loading data...</div>}>
        <DataTable />
      </Suspense>
    </div>
  );
}
```

### Route Groups & Parallel Routes

```typescript
// app/(marketing)/layout.tsx

export default function MarketingLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div>
      <MarketingHeader />
      <main>{children}</main>
      <MarketingFooter />
    </div>
  );
}

// app/(dashboard)/layout.tsx

export default function DashboardLayout({
  children,
  analytics,
  notifications,
}: {
  children: React.ReactNode;
  analytics: React.ReactNode;
  notifications: React.ReactNode;
}) {
  return (
    <div className="flex">
      <Sidebar />
      <div className="flex-1">
        <Header />
        <div className="flex">
          <main className="flex-1">{children}</main>
          <aside className="w-80">
            {notifications}
          </aside>
        </div>
      </div>
    </div>
  );
}
```

---

## Database Optimization

```python
# config/settings.py (Additional)

# Connection pooling
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.environ.get('DB_NAME'),
        'USER': os.environ.get('DB_USER'),
        'PASSWORD': os.environ.get('DB_PASSWORD'),
        'HOST': os.environ.get('DB_HOST'),
        'PORT': os.environ.get('DB_PORT', '5432'),
        'CONN_MAX_AGE': 600,
        'CONN_HEALTH_CHECKS': True,
        'OPTIONS': {
            'connect_timeout': 5,
        },
    }
}

# Cache
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.redis.RedisCache',
        'LOCATION': os.environ.get('REDIS_URL'),
        'TIMEOUT': 300,
        'OPTIONS': {
            'db': '0',
        },
    }
}

# Session
SESSION_ENGINE = 'django.contrib.sessions.backends.cache'
SESSION_CACHE_ALIAS = 'default'
```

```python
# performance/query_optimization.py

from django.db import models
from django.db.models import Prefetch, Q


class OptimizedQueries:
    """استعلامات محسّنة"""
    
    @staticmethod
    def get_courses_with_teacher():
        """جلب الدورات مع المعلم"""
        return Course.objects.select_related(
            'teacher',
            'teacher__profile',
        ).prefetch_related(
            'lessons',
            'enrollments',
            'reviews',
        ).filter(
            is_published=True
        )
    
    @staticmethod
    def get_lesson_with_content():
        """جلب الدرس مع المحتوى"""
        return Lesson.objects.select_related(
            'course',
            'course__teacher',
        ).prefetch_related(
            Prefetch(
                'contents',
                queryset=LessonContent.objects.order_by('order'),
            ),
            'quizzes',
        )
    
    @staticmethod
    def get_user_dashboard_data(user_id: int):
        """جلب بيانات لوحة تحكم المستخدم"""
        from courses.models import Enrollment
        from lessonplans.models import LessonPlan
        
        enrollments = Enrollment.objects.filter(
            user_id=user_id
        ).select_related(
            'course',
            'course__teacher',
        ).prefetch_related(
            'course__lessons',
        )[:10]
        
        recent_plans = LessonPlan.objects.filter(
            user_id=user_id
        ).order_by('-created_at')[:5]
        
        return {
            'enrollments': enrollments,
            'recent_plans': recent_plans,
        }
```

```python
# performance/indexes.py

#_indexes.py - database indexes for performance

from django.db import migrations


class Migration(migrations.Migration):
    dependencies = [
        ('courses', '0001_initial'),
    ]

    operations = [
        # Indexes for courses
        migrations.AddIndex(
            model_name='course',
            index=models.Index(
                fields=['-created_at'],
                name='course_created_idx',
            ),
        ),
        migrations.AddIndex(
            model_name='course',
            index=models.Index(
                fields=['subject', 'level'],
                name='course_subject_level_idx',
            ),
        ),
        migrations.AddIndex(
            model_name='course',
            index=models.Index(
                fields=['teacher', '-created_at'],
                name='course_teacher_created_idx',
            ),
        ),
        
        # Indexes for lessons
        migrations.AddIndex(
            model_name='lesson',
            index=models.Index(
                fields=['course', 'order'],
                name='lesson_course_order_idx',
            ),
        ),
        
        # Full-text search index
        migrations.RunSQL(
            """
            CREATE INDEX IF NOT EXISTS course_title_search_idx 
            ON course USING GIN (to_tsvector('arabic', title));
            """,
            """
            DROP INDEX IF EXISTS course_title_search_idx;
            """,
        ),
    ]
```

---

## API Response Optimization

```python
# performance/serializers.py

from rest_framework import serializers


class OptimizedSerializer:
    """Serializers محسّنة"""
    
    @staticmethod
    def get_course_list_serializer():
        """serializers قائمة الدورات"""
        
        class CourseListSerializer(serializers.ModelSerializer):
            teacher_name = serializers.CharField(source='teacher.name', read_only=True)
            teacher_avatar = serializers.ImageField(source='teacher.avatar', read_only=True)
            lessons_count = serializers.IntegerField(read_only=True)
            avg_rating = serializers.FloatField(read_only=True)
            
            class Meta:
                model = Course
                fields = [
                    'id', 'title', 'description', 'subject', 'level',
                    'price', 'thumbnail', 'teacher_name', 'teacher_avatar',
                    'lessons_count', 'avg_rating', 'created_at',
                ]
        
        return CourseListSerializer


# prefetch data
from django.db.models import Count, Avg


def get_optimized_courses():
    """جلب الدورات مع إحصائيات"""
    return Course.objects.annotate(
        lessons_count=Count('lessons'),
        avg_rating=Avg('reviews__rating'),
        enrollments_count=Count('enrollments'),
    ).select_related(
        'teacher'
    ).filter(
        is_published=True
    )
```

---

## Frontend Performance

```typescript
// lib/performance.ts

// Intersection Observer for lazy loading
export function useIntersectionObserver(
  ref: React.RefObject<HTMLElement>,
  options: IntersectionObserverInit = {}
) {
  const [isVisible, setIsVisible] = useState(false);

  useEffect(() => {
    const observer = new IntersectionObserver(([entry]) => {
      if (entry.isIntersecting) {
        setIsVisible(true);
        observer.disconnect();
      }
    }, options);

    if (ref.current) {
      observer.observe(ref.current);
    }

    return () => observer.disconnect();
  }, [ref, options]);

  return isVisible;
}

// Virtual scrolling for large lists
export function useVirtualScroll<T>(
  items: T[],
  itemHeight: number,
  containerHeight: number
) {
  const [scrollTop, setScrollTop] = useState(0);

  const startIndex = Math.floor(scrollTop / itemHeight);
  const endIndex = Math.min(
    startIndex + Math.ceil(containerHeight / itemHeight) + 1,
    items.length
  );

  const visibleItems = items.slice(startIndex, endIndex);

  return {
    visibleItems,
    startIndex,
    totalHeight: items.length * itemHeight,
    offsetY: startIndex * itemHeight,
    onScroll: (e: React.UIEvent<HTMLElement>) => {
      setScrollTop(e.currentTarget.scrollTop);
    },
  };
}

// Debounced search
export function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState(value);

  useEffect(() => {
    const handler = setTimeout(() => {
      setDebouncedValue(value);
    }, delay);

    return () => clearTimeout(handler);
  }, [value, delay]);

  return debouncedValue;
}
```

---

## Core Web Vitals Monitoring

```typescript
// lib/web-vitals.ts

import { onCLS, onFID, onLCP, onFCP, onTTFB } from 'web-vitals';

function sendToAnalytics(metric: any) {
  // إرسال إلى Google Analytics
  if (typeof window.gtag === 'function') {
    window.gtag('event', metric.name, {
      event_category: 'Web Vitals',
      event_label: metric.id,
      value: Math.round(metric.name === 'CLS' ? metric.value * 1000 : metric.value),
      non_interaction: true,
    });
  }
}

export function reportWebVitals() {
  onCLS(sendToAnalytics);
  onFID(sendToAnalytics);
  onLCP(sendToAnalytics);
  onFCP(sendToAnalytics);
  onTTFB(sendToAnalytics);
}
```

```typescript
// app/layout.tsx

import { reportWebVitals } from '@/lib/web-vitals';

// تقرير Core Web Vitals
if (typeof window !== 'undefined') {
  reportWebVitals();
}
```

---

## Compression & Headers

```typescript
// next.config.js

module.exports = {
  // Headers
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff',
          },
          {
            key: 'X-Frame-Options',
            value: 'DENY',
          },
          {
            key: 'X-XSS-Protection',
            value: '1; mode=block',
          },
          {
            key: 'Referrer-Policy',
            value: 'strict-origin-when-cross-origin',
          },
        ],
      },
      {
        source: '/api/(.*)',
        headers: [
          {
            key: 'Cache-Control',
            value: 'public, s-maxage=60, stale-while-revalidate=300',
          },
        ],
      },
      {
        source: '/_next/static/(.*)',
        headers: [
          {
            key: 'Cache-Control',
            value: 'public, max-age=31536000, immutable',
          },
        ],
      },
    ];
  },
};
```

---

## ما نُفّذ فعلياً (أغسطس 2026)

> ملاحظة: القسمان أعلاه وثيقة تصور (الأنماط المقترحة). الوارد أدناه **ما طُبّق فعلياً في الكود** مع قياسات حية.

### 1. إزالة تأخير Redis (الأهم — +2s على كل endpoint)
- **السبب**: Upstash (Redis) محجوب إقليمياً — غير قابل للوصول من بيئة التطوير **ولا من Render** (قياس: connect timeout على المنفذ 6379). كل request عبر DRF يمر من throttle → `cache.get` على Redis → انتظار `socket_connect_timeout` (كان 2s) → سقوط صامت بفضل `DJANGO_REDIS_IGNORE_EXCEPTIONS`.
- **القياس قبل**: `menu/header/?locale=ar` = **2.5s** (متكرر، وليست برودة)، `translations/?locale=ar` = **2.8s**، بينما `health` (view عادي بلا throttle) = **0.44s** — هذا التفاوت كشف السبب.
- **الحل**:
  - `production.py`: الكاش = `LocMemCache` (بلا شبكة — يكفي لخدمة Gunicorn أحادية على الخطة المجانية).
  - `base.py`: `socket_connect_timeout`/`socket_timeout` = **0.3s** كتأمين لو أُعيد ربط Redis لاحقاً.
- **النتيجة المتوقعة**: ~0.3–0.5s لكل endpoint.

### 2. تصغير حمولة الترجمات (10×)
- **قبل**: `TranslationPublicListView` يعيد كل اللغات لكل مفتاح → **561KB** لكل تحميل صفحة.
- **بعد**: `TranslationPublicSerializer` يفلتر بـ `?locale=` → **~56KB**؛ `TranslationProvider` يمرّر `{ locale }`. (متوافق مع الواجهة لأنها كانت تقرأ `item.translations[locale]` فقط).

### 3. إصلاح N+1 في المدوّنة والكتب
- `select_related('category')` في `BlogPostPublicListView` و`EbookListView`.
- `annotate(_posts_count=Count('posts', filter=Q(posts__is_published=True)))` لتصنيفات المدوّنة + `get_posts_count` يقرأ الحقل المُجمّع.

### 4. إزالة طوفان الـ prefetch (الواجهة)
- **قبل**: `blog/page.tsx` و`BlogListBlock.tsx` كانا يُطلقان طلب تفاصيل لكل مقال بالتوازي بعد 600–700ms من تحميل القائمة (عبر `usePrefetch`) — يُغرقان خدمة Render المجانية (Gunicorn 2 workers × 4 threads) ويزيدان زمن كل الطلبات.
- **بعد**: حذف `usePrefetch`/`useEffect` من الملفين (لا حاجة — Next `<Link>` يسبق التحميل عند الـ hover).

### 5. بطاقات الكتب الإلكترونية
- غلاف افتراضي بتدرج لوني + عنوان الكتاب بدل الأيقونة `📚`، وحركة `scale` على hover للغلافات الموجودة.

### 6. ترحيل Gemini إلى `google-genai`
- الحزمة الحديثة (`from google import genai`) بدل `google.generativeai` (المُهملة) — انظر `part-03-architecture/05-ai-layer.md` إن وُجد.

---

## ملخص

> **تحسين الأداء** يشمل: Next.js Image + Code Splitting + Route Groups، Database Optimization (indexing + prefetch + connection pooling)، API Response Optimization، Frontend Performance (virtual scroll + intersection observer)، Core Web Vitals Monitoring، وCompression/Caching Headers.
