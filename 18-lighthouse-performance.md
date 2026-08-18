# خطة هندسة تحسين الأداء (Lighthouse >90)

> تاريخ التوثيق: 18 أغسطس 2026
> الغرض: توثيق التصميم الهندسي والمعماري لتحسين أداء التطبيق لتحقيق Lighthouse Score >90.

---

## 1. الفكرة والهدف
تحسين أداء التطبيق لتحقيق درجة Lighthouse >90 في جميع الفئات:
- **Performance**: >90
- **Accessibility**: >95
- **Best Practices**: >95
- **SEO**: >95

---

## 2. Core Web Vitals

### أ. Largest Contentful Paint (LCP) — الهدف: < 2.5s
| المشكلة | الحل |
|---------|------|
| صور كبيرة | `next/image` مع `sizes` + `priority` + `placeholder="blur"` |
| خطوط خارجية | `next/font` مع `display: swap` |
| محتوى ثابت | ISR (Incremental Static Regeneration) |

### ب. First Input Delay (FID) — الهدف: < 100ms
| المشكلة | الحل |
|---------|------|
| JavaScript كثيف | Code Splitting via `next/dynamic` |
| مكتبات ثقيلة | Tree Shaking + Bundle Analysis |

### ج. Cumulative Layout Shift (CLS) — الهدف: < 0.1
| المشكلة | الحل |
|---------|------|
| صور بدون أبعاد | تحديد `width` + `height` دائماً |
| خطوط تتغير | `font-display: swap` + fallback fonts |
| محتوى متأخر | `min-height` للحاويات |

---

## 3. التحسينات التقنية

### أ. تحسين الصور (`next/image`)
```typescript
// BAD ❌
<img src="/hero.jpg" alt="Hero" />

// GOOD ✅
import Image from 'next/image';
<Image
    src="/hero.jpg"
    alt="Hero"
    width={1200}
    height={600}
    priority  // للصور أعلاه الصفحة
    placeholder="blur"
    blurDataURL="data:image/jpeg;base64,..."
    sizes="(max-width: 768px) 100vw, 50vw"
/>
```

### ب. تحميل كسول (Lazy Loading)
```typescript
// BAD ❌
import AdminGradesView from '@/components/school/admin/AdminGradesView';

// GOOD ✅
import dynamic from 'next/dynamic';
const AdminGradesView = dynamic(() => import('@/components/school/admin/AdminGradesView'), {
    loading: () => <Skeleton className="h-64 w-full" />,
    ssr: false,  // لا يحتاج SSR
});
```

### ج. تقسيم الحزم (Bundle Splitting)
```typescript
// next.config.ts
const nextConfig = {
    experimental: {
        optimizePackageImports: [
            'lucide-react',
            '@supabase/supabase-js',
            'zustand',
        ],
    },
    webpack: (config) => {
        config.optimization.splitChunks = {
            chunks: 'all',
            maxSize: 250000,  // 250KB أقصى حجم للـ chunk
        };
        return config;
    },
};
```

### د. التخزين المؤقت (Caching Strategy)
```typescript
// ISR for static pages
export const revalidate = 3600; // 1 ساعة

// SWR for dynamic data
const { data } = useSWR('/api/v1/schools/', fetcher, {
    revalidateOnFocus: true,
    revalidateOnReconnect: true,
    dedupingInterval: 60000, // 1 دقيقة
});
```

---

## 4. تحسين الخلفية (Backend Optimization)

### أ. تحسين الاستعلامات
```python
# BAD ❌ N+1 Query
for student in students:
    grades = GradeEntry.objects.filter(student=student)

# GOOD ✅ Prefetch
students = Student.objects.prefetch_related('grade_entries').all()
```

### ب. التخزين المؤقت للاستعلامات
```python
from django.core.cache import cache

def get_school_stats(school_id):
    cache_key = f'school_stats:{school_id}'
    stats = cache.get(cache_key)
    if not stats:
        stats = compute_school_stats(school_id)
        cache.set(cache_key, stats, timeout=300)  # 5 دقائق
    return stats
```

### ج. تحسين API Responses
```python
# Pagination
class SchoolViewSet(viewsets.ModelViewSet):
    pagination_class = PageNumberPagination
    page_size = 20
    page_size_query_param = 'page_size'
    max_page_size = 100
```

---

## 5. قياس الأداء

### أ. Lighthouse CI
```yaml
# .github/workflows/lighthouse.yml
name: Lighthouse CI
on: [pull_request]
jobs:
  lighthouse:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - run: npm ci
      - run: npm run build
      - uses: treosh/lighthouse-ci-action@v12
        with:
          urls: |
            http://localhost:3000/
            http://localhost:3000/en/school
            http://localhost:3000/en/teacher
          budgetPath: ./lighthouse-budget.json
```

### ب. ميزانية الأداء (`lighthouse-budget.json`)
```json
[
    {
        "path": "/*",
        "timings": [
            {"metric": "first-contentful-paint", "budget": 1500},
            {"metric": "largest-contentful-paint", "budget": 2500},
            {"metric": "cumulative-layout-shift", "budget": 0.1},
            {"metric": "total-blocking-time", "budget": 300}
        ],
        "resourceSizes": [
            {"resourceType": "script", "budget": 200},
            {"resourceType": "stylesheet", "budget": 50},
            {"resourceType": "image", "budget": 500},
            {"resourceType": "total", "budget": 1000}
        ]
    }
]
```

---

## 6. التحقق من الأداء
| الأداة | الاستخدام |
|--------|----------|
| Lighthouse (Chrome DevTools) | فحص محلي |
| Lighthouse CI | فحص تلقائي في CI |
| WebPageTest | فحص من مواقع مختلفة |
| Chrome User Experience Report (CrUX) | بيانات حقيقية من المستخدمين |
