# نظام البحث المتقدم (Advanced Search)

## نظرة عامة

نظام بحث شامل يدعم البحث في الدورات، الدروس، المدونة، المنتجات، والمستخدمين مع دعم التصفية والفرز متعدد اللغات.

---

## المكونات

```
┌─────────────────────────────────────────────────────────────────┐
│                      نظام البحث المتقدم                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────┐    ┌──────────────────┐                   │
│  │   Frontend UI    │    │  Search Service  │                   │
│  │  (React Hook)    │◄──►│   (Django)       │                   │
│  └──────────────────┘    └──────────────────┘                   │
│          │                       │                               │
│          ▼                       ▼                               │
│  ┌──────────────────┐    ┌──────────────────┐                   │
│  │  Search Results  │    │  Elasticsearch   │                   │
│  │  (Cached)        │    │  (Full-text)     │                   │
│  └──────────────────┘    └──────────────────┘                   │
│                                 │                               │
│                                 ▼                               │
│                          ┌──────────────────┐                   │
│                          │  PostgreSQL      │                   │
│                          │  (pg_trgm)       │                   │
│                          └──────────────────┘                   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Elasticsearch Configuration

### Index Mapping

```python
# search/elasticsearch.py

from elasticsearch_dsl import (
    Document, Text, Keyword, Integer, 
    Float, Boolean, Date, Nested
)


class CourseDocument(Document):
    """فهرس الدورات"""
    
    title = Text(analyzer='arabic', fields={
        'keyword': Keyword(),
        'autocomplete': Text(analyzer='autocomplete'),
    })
    title_en = Text(analyzer='english', fields={
        'keyword': Keyword(),
    })
    description = Text(analyzer='arabic')
    description_en = Text(analyzer='english')
    
    subject = Keyword()
    level = Keyword()
    language = Keyword()
    price = Float()
    rating = Float()
    enrollment_count = Integer()
    is_published = Boolean()
    created_at = Date()
    
    teacher = Nested(properties={
        'id': Integer(),
        'name': Text(),
    })
    
    tags = Keyword(multi=True)
    
    class Index:
        name = 'courses'
        settings = {
            'number_of_shards': 2,
            'number_of_replicas': 1,
        }


class LessonDocument(Document):
    """فهرس الدروس"""
    
    title = Text(analyzer='arabic', fields={
        'keyword': Keyword(),
        'autocomplete': Text(analyzer='autocomplete'),
    })
    title_en = Text(analyzer='english')
    content = Text(analyzer='arabic')
    content_en = Text(analyzer='english')
    
    subject = Keyword()
    grade = Keyword()
    language = Keyword()
    
    course = Nested(properties={
        'id': Integer(),
        'title': Text(),
    })
    
    created_at = Date()
    
    class Index:
        name = 'lessons'


class BlogDocument(Document):
    """فهرس المدونة"""
    
    title = Text(analyzer='arabic', fields={
        'keyword': Keyword(),
        'autocomplete': Text(analyzer='autocomplete'),
    })
    title_en = Text(analyzer='english')
    content = Text(analyzer='arabic')
    content_en = Text(analyzer='english')
    excerpt = Text(analyzer='arabic')
    
    category = Keyword()
    tags = Keyword(multi=True)
    language = Keyword()
    author = Nested(properties={
        'id': Integer(),
        'name': Text(),
    })
    
    published_at = Date()
    view_count = Integer()
    
    class Index:
        name = 'blog_posts'


class UserDocument(Document):
    """فهرس المستخدمين"""
    
    name = Text(analyzer='arabic', fields={
        'keyword': Keyword(),
    })
    name_en = Text(analyzer='english')
    bio = Text(analyzer='arabic')
    
    role = Keyword()
    subjects = Keyword(multi=True)
    rating = Float()
    total_students = Integer()
    
    is_verified = Boolean()
    is_active = Boolean()
    
    class Index:
        name = 'users'
```

### Custom Analyzers

```python
# search/settings.py

ELASTICSEARCH_DSL = {
    'default': {
        'hosts': 'localhost:9200',
        'index_prefix': 'afaq',
    },
}

ELASTICSEARCH_DSL_SETTINGS = {
    'settings': {
        'analysis': {
            'filter': {
                'arabic_stop': {
                    'type': 'stop',
                    'stopwords': '_arabic_',
                },
                'arabic_stemmer': {
                    'type': 'stemmer',
                    'language': 'arabic',
                },
                'autocomplete': {
                    'type': 'edge_ngram',
                    'min_gram': 2,
                    'max_gram': 20,
                },
            },
            'analyzer': {
                'arabic': {
                    'type': 'custom',
                    'tokenizer': 'standard',
                    'filter': [
                        'lowercase',
                        'arabic_stop',
                        'arabic_stemmer',
                    ],
                },
                'autocomplete': {
                    'type': 'custom',
                    'tokenizer': 'standard',
                    'filter': [
                        'lowercase',
                        'autocomplete',
                    ],
                },
            },
        },
    },
}
```

---

## Django Search Service

```python
# search/services.py

from elasticsearch_dsl import Q
from .documents import (
    CourseDocument, LessonDocument, 
    BlogDocument, UserDocument
)


class SearchService:
    """خدمة البحث الرئيسية"""
    
    INDEX_MAP = {
        'courses': CourseDocument,
        'lessons': LessonDocument,
        'blog': BlogDocument,
        'users': UserDocument,
    }
    
    @classmethod
    def search(cls, query: str, index: str = 'all', 
               filters: dict = None, page: int = 1, 
               page_size: int = 20) -> dict:
        """بحث رئيسي"""
        
        documents = cls.INDEX_MAP.get(index) if index != 'all' else cls.INDEX_MAP.values()
        
        # بناء الاستعلام
        search_query = cls._build_query(query, filters)
        
        # تنفيذ البحث
        results = []
        total = 0
        
        for doc_class in documents:
            if isinstance(doc_class, dict):
                continue
                
            search = doc_class.search()
            search = search.query(search_query)
            search = search[(page - 1) * page_size: page * page_size]
            
            response = search.execute()
            
            results.extend([{
                'id': hit.meta.id,
                'index': hit.meta.index,
                'score': hit.meta.score,
                **hit.to_dict(),
            } for hit in response])
            
            total += response.hits.total.value
        
        # ترتيب النتائج
        results.sort(key=lambda x: x['score'], reverse=True)
        
        return {
            'results': results[:page_size],
            'total': total,
            'page': page,
            'page_size': page_size,
            'total_pages': (total + page_size - 1) // page_size,
        }
    
    @classmethod
    def _build_query(cls, query: str, filters: dict = None) -> Q:
        """بناء الاستعلام"""
        
        # استعلام متعدد اللغات
        must_queries = [
            Q('multi_match', query=query, fields=[
                'title^3',
                'title.autocomplete^2',
                'title_en^3',
                'description',
                'description_en',
                'content',
                'content_en',
                'tags^2',
            ], type='best_fields', fuzziness='AUTO'),
        ]
        
        filter_queries = []
        
        if filters:
            if 'subject' in filters:
                filter_queries.append(Q('term', subject=filters['subject']))
            
            if 'level' in filters:
                filter_queries.append(Q('term', level=filters['level']))
            
            if 'language' in filters:
                filter_queries.append(Q('term', language=filters['language']))
            
            if 'min_price' in filters:
                filter_queries.append(Q('range', price={'gte': filters['min_price']}))
            
            if 'max_price' in filters:
                filter_queries.append(Q('range', price={'lte': filters['max_price']}))
        
        return Q('bool', must=must_queries, filter=filter_queries)
    
    @classmethod
    def autocomplete(cls, query: str, index: str = 'all') -> list:
        """إكمال تلقائي"""
        
        documents = cls.INDEX_MAP.get(index) if index != 'all' else cls.INDEX_MAP.values()
        
        suggestions = []
        
        for doc_class in documents:
            if isinstance(doc_class, dict):
                continue
            
            search = doc_class.search()
            search = search.query(
                Q('match', **{
                    'title.autocomplete': {
                        'query': query,
                        'fuzzy_transpositions': True,
                    }
                })
            )
            search = search[:5]
            
            response = search.execute()
            
            suggestions.extend([{
                'id': hit.meta.id,
                'text': hit.title,
                'index': hit.meta.index,
            } for hit in response])
        
        return suggestions[:10]
    
    @classmethod
    def suggest(cls, query: str) -> dict:
        """اقتراحات البحث"""
        
        return {
            'autocomplete': cls.autocomplete(query),
            'related': cls._get_related_queries(query),
            'trending': cls._get_trending_searches(),
        }
    
    @classmethod
    def _get_related_queries(cls, query: str) -> list:
        """استعلامات متعلقة"""
        # TODO: تحليل الاستعلامات المشابهة
        return []
    
    @classmethod
    def _get_trending_searches(cls) -> list:
        """البحث الشائع"""
        # TODO: جلب الأكثر بحثاً
        return []
```

---

## Django Search Views

```python
# search/views.py

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import AllowAny
from django.core.cache import cache


class SearchView(APIView):
    """واجهة البحث الرئيسية"""
    permission_classes = [AllowAny]
    
    def get(self, request):
        query = request.query_params.get('q', '').strip()
        index = request.query_params.get('index', 'all')
        page = int(request.query_params.get('page', 1))
        page_size = int(request.query_params.get('page_size', 20))
        
        # فلاتر
        filters = {
            'subject': request.query_params.get('subject'),
            'level': request.query_params.get('level'),
            'language': request.query_params.get('language'),
            'min_price': request.query_params.get('min_price'),
            'max_price': request.query_params.get('max_price'),
        }
        filters = {k: v for k, v in filters.items() if v}
        
        # التحقق من الكاش
        cache_key = f'search:{query}:{index}:{page}:{hash(frozenset(filters.items()))}'
        cached = cache.get(cache_key)
        
        if cached:
            return Response(cached)
        
        # تنفيذ البحث
        results = SearchService.search(
            query=query,
            index=index,
            filters=filters,
            page=page,
            page_size=page_size,
        )
        
        # حفظ في الكاش
        cache.set(cache_key, results, timeout=300)  # 5 دقائق
        
        return Response(results)


class AutocompleteView(APIView):
    """الإكمال التلقائي"""
    permission_classes = [AllowAny]
    
    def get(self, request):
        query = request.query_params.get('q', '').strip()
        index = request.query_params.get('index', 'all')
        
        if len(query) < 2:
            return Response([])
        
        cache_key = f'autocomplete:{query}:{index}'
        cached = cache.get(cache_key)
        
        if cached:
            return Response(cached)
        
        results = SearchService.autocomplete(query, index)
        
        cache.set(cache_key, results, timeout=600)  # 10 دقائق
        
        return Response(results)


class SearchSuggestionsView(APIView):
    """اقتراحات البحث"""
    permission_classes = [AllowAny]
    
    def get(self, request):
        query = request.query_params.get('q', '').strip()
        
        results = SearchService.suggest(query)
        
        return Response(results)
```

---

## React Hook للبحث

```typescript
// hooks/useSearch.ts

'use client';

import { useState, useCallback, useEffect } from 'react';
import debounce from 'lodash/debounce';

interface SearchResult {
  id: string;
  index: string;
  score: number;
  title: string;
  description?: string;
  [key: string]: any;
}

interface SearchResponse {
  results: SearchResult[];
  total: number;
  page: number;
  page_size: number;
  total_pages: number;
}

interface UseSearchOptions {
  index?: string;
  debounceMs?: number;
  pageSize?: number;
}

export function useSearch(options: UseSearchOptions = {}) {
  const { index = 'all', debounceMs = 300, pageSize = 20 } = options;
  
  const [query, setQuery] = useState('');
  const [results, setResults] = useState<SearchResult[]>([]);
  const [total, setTotal] = useState(0);
  const [page, setPage] = useState(1);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [suggestions, setSuggestions] = useState<any[]>([]);

  const search = useCallback(
    debounce(async (searchQuery: string, searchPage: number) => {
      if (!searchQuery.trim()) {
        setResults([]);
        setTotal(0);
        return;
      }

      setLoading(true);
      setError(null);

      try {
        const params = new URLSearchParams({
          q: searchQuery,
          index,
          page: searchPage.toString(),
          page_size: pageSize.toString(),
        });

        const response = await fetch(`/api/v1/search/?${params}`);
        const data: SearchResponse = await response.json();

        setResults(data.results);
        setTotal(data.total);
      } catch (err) {
        setError('حدث خطأ أثناء البحث');
      } finally {
        setLoading(false);
      }
    }, debounceMs),
    [index, pageSize]
  );

  // البحث عند تغيير الاستعلام
  useEffect(() => {
    search(query, page);
  }, [query, page, search]);

  // جلب الاقتراحات
  const fetchSuggestions = useCallback(
    debounce(async (searchQuery: string) => {
      if (searchQuery.length < 2) {
        setSuggestions([]);
        return;
      }

      try {
        const response = await fetch(
          `/api/v1/search/suggest/?q=${encodeURIComponent(searchQuery)}`
        );
        const data = await response.json();
        setSuggestions(data.autocomplete || []);
      } catch (err) {
        // تجاهل أخطاء الاقتراحات
      }
    }, 200),
    []
  );

  // تغيير الصفحة
  const goToPage = useCallback((newPage: number) => {
    setPage(newPage);
  }, []);

  // إعادة البحث
  const resetSearch = useCallback(() => {
    setQuery('');
    setResults([]);
    setTotal(0);
    setPage(1);
  }, []);

  return {
    query,
    setQuery,
    results,
    total,
    page,
    loading,
    error,
    suggestions,
    fetchSuggestions,
    goToPage,
    resetSearch,
  };
}
```

---

## صفحة نتائج البحث

```typescript
// components/search/SearchResults.tsx

'use client';

import { useSearch } from '@/hooks/useSearch';
import { SearchFilters } from './SearchFilters';
import { SearchResultCard } from './SearchResultCard';
import { Pagination } from '@/components/ui/Pagination';

export function SearchResults() {
  const {
    query,
    setQuery,
    results,
    total,
    page,
    loading,
    error,
    suggestions,
    fetchSuggestions,
    goToPage,
    resetSearch,
  } = useSearch({ index: 'all' });

  return (
    <div className="container mx-auto px-4">
      {/* شريط البحث */}
      <div className="mb-8">
        <div className="relative">
          <input
            type="text"
            value={query}
            onChange={(e) => {
              setQuery(e.target.value);
              fetchSuggestions(e.target.value);
            }}
            placeholder="ابحث عن دورات، دروس، مقالات..."
            className="w-full px-4 py-3 text-lg border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
          />
          
          {/* الاقتراحات */}
          {suggestions.length > 0 && (
            <div className="absolute top-full left-0 right-0 bg-white border border-gray-200 rounded-lg mt-1 shadow-lg z-10">
              {suggestions.map((suggestion) => (
                <button
                  key={suggestion.id}
                  onClick={() => setQuery(suggestion.text)}
                  className="w-full px-4 py-2 text-right hover:bg-gray-50"
                >
                  {suggestion.text}
                </button>
              ))}
            </div>
          )}
        </div>
      </div>

      {/* الفلاتر ونتائج البحث */}
      <div className="flex gap-8">
        {/* الفلاتر */}
        <div className="w-64 flex-shrink-0">
          <SearchFilters />
        </div>

        {/* النتائج */}
        <div className="flex-1">
          {/* إحصائيات */}
          <div className="mb-4 text-gray-600">
            {total > 0 ? (
              <span>تم العثور على {total.toLocaleString('ar')} نتيجة</span>
            ) : query && !loading ? (
              <span>لم يتم العثور على نتائج</span>
            ) : null}
          </div>

          {/* حالة التحميل */}
          {loading && (
            <div className="text-center py-8">
              <div className="animate-spin w-8 h-8 border-4 border-blue-500 border-t-transparent rounded-full mx-auto" />
              <p className="mt-2 text-gray-600">جاري البحث...</p>
            </div>
          )}

          {/* الخطأ */}
          {error && (
            <div className="bg-red-50 border border-red-200 rounded-lg p-4 text-red-700">
              {error}
            </div>
          )}

          {/* النتائج */}
          {!loading && results.length > 0 && (
            <div className="space-y-4">
              {results.map((result) => (
                <SearchResultCard key={result.id} result={result} />
              ))}
            </div>
          )}

          {/* تقسيم الصفحات */}
          {total > 20 && (
            <div className="mt-8">
              <Pagination
                currentPage={page}
                totalPages={Math.ceil(total / 20)}
                onPageChange={goToPage}
              />
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
```

---

## فلاتر البحث

```typescript
// components/search/SearchFilters.tsx

'use client';

import { useState } from 'react';

interface FilterState {
  subject: string;
  level: string;
  language: string;
  priceRange: [number, number];
}

export function SearchFilters() {
  const [filters, setFilters] = useState<FilterState>({
    subject: '',
    level: '',
    language: '',
    priceRange: [0, 100],
  });

  const subjects = [
    { value: 'math', label: 'الرياضيات' },
    { value: 'science', label: 'العلوم' },
    { value: 'arabic', label: 'اللغة العربية' },
    { value: 'english', label: 'اللغة الإنجليزية' },
    { value: 'history', label: 'التاريخ' },
  ];

  const levels = [
    { value: 'primary', label: 'المرحلة الابتدائية' },
    { value: 'middle', label: 'المرحلة المتوسطة' },
    { value: 'secondary', label: 'المرحلة الثانوية' },
  ];

  const languages = [
    { value: 'ar', label: 'العربية' },
    { value: 'en', label: 'الإنجليزية' },
    { value: 'fr', label: 'الفرنسية' },
    { value: 'tr', label: 'التركية' },
  ];

  return (
    <div className="bg-white border border-gray-200 rounded-lg p-4">
      <h3 className="font-semibold mb-4">الفلاتر</h3>
      
      {/* المادة */}
      <div className="mb-4">
        <label className="block text-sm font-medium mb-2">المادة</label>
        <select
          value={filters.subject}
          onChange={(e) => setFilters({ ...filters, subject: e.target.value })}
          className="w-full border border-gray-300 rounded px-3 py-2"
        >
          <option value="">الكل</option>
          {subjects.map((subject) => (
            <option key={subject.value} value={subject.value}>
              {subject.label}
            </option>
          ))}
        </select>
      </div>
      
      {/* المرحلة */}
      <div className="mb-4">
        <label className="block text-sm font-medium mb-2">المرحلة</label>
        <select
          value={filters.level}
          onChange={(e) => setFilters({ ...filters, level: e.target.value })}
          className="w-full border border-gray-300 rounded px-3 py-2"
        >
          <option value="">الكل</option>
          {levels.map((level) => (
            <option key={level.value} value={level.value}>
              {level.label}
            </option>
          ))}
        </select>
      </div>
      
      {/* اللغة */}
      <div className="mb-4">
        <label className="block text-sm font-medium mb-2">لغة المحتوى</label>
        <select
          value={filters.language}
          onChange={(e) => setFilters({ ...filters, language: e.target.value })}
          className="w-full border border-gray-300 rounded px-3 py-2"
        >
          <option value="">الكل</option>
          {languages.map((lang) => (
            <option key={lang.value} value={lang.value}>
              {lang.label}
            </option>
          ))}
        </select>
      </div>
      
      {/* نطاق السعر */}
      <div className="mb-4">
        <label className="block text-sm font-medium mb-2">السعر</label>
        <div className="flex gap-2">
          <input
            type="number"
            value={filters.priceRange[0]}
            onChange={(e) => setFilters({
              ...filters,
              priceRange: [parseInt(e.target.value), filters.priceRange[1]],
            })}
            className="w-1/2 border border-gray-300 rounded px-3 py-2"
            placeholder="من"
          />
          <input
            type="number"
            value={filters.priceRange[1]}
            onChange={(e) => setFilters({
              ...filters,
              priceRange: [filters.priceRange[0], parseInt(e.target.value)],
            })}
            className="w-1/2 border border-gray-300 rounded px-3 py-2"
            placeholder="إلى"
          />
        </div>
      </div>
      
      {/* إعادة ضبط */}
      <button
        onClick={() => setFilters({
          subject: '',
          level: '',
          language: '',
          priceRange: [0, 100],
        })}
        className="w-full bg-gray-100 text-gray-700 px-4 py-2 rounded hover:bg-gray-200"
      >
        إعادة ضبط الفلاتر
      </button>
    </div>
  );
}
```

---

## URLs API

```
# البحث الرئيسي
GET /api/v1/search/?q={query}&index={index}&page={page}&page_size={20}

# إكمال تلقائي
GET /api/v1/search/autocomplete/?q={query}&index={index}

# اقتراحات
GET /api/v1/search/suggest/?q={query}

# فلاتر
GET /api/v1/search/filters/
```

---

## ملخص

> **نظام البحث المتقدم** يدعم Elasticsearch مع تحليل عربي/إنجليزي، إكمال تلقائي، فلاتر متقدمة، تقسيم صفحات، وتخزين مؤقت. يشمل React Hook، صفحة نتائج متكاملة، وواجهة API.
