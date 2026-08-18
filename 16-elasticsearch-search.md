# خطة هندسة نظام البحث المتقدم (Elasticsearch / OpenSearch)

> تاريخ التوثيق: 18 أغسطس 2026
> الغرض: توثيق التصميم الهندسي والمعماري لنظام البحث المتقدم عبر Elasticsearch/OpenSearch في منصة آفاق تكنولوجي.

---

## 1. الفكرة والهدف
توفير محرك بحث متقدم وسريع في جميع محتويات المنصة:
- **البحث في المحتوى التعليمي**: الدورات، الكتب الإلكترونية، الدروس.
- **بحث الطلاب والمعلمين**: بالاسم، البريد، رقم الهوية.
- **بحث المقالات**: في المدوّنة.
- **Autocomplete**: اقتراحات فورية أثناء الكتابة.
- **بحث متعدد اللغات**: دعم 10 لغات مع Stemming و Tokenization.

---

## 2. المكونات التقنية

### أ. خيار 1: OpenSearch على Supabase (مُوصى به)
```python
# backend/config/settings/base.py
ELASTICSEARCH_URL = env('ELASTICSEARCH_URL', default='http://localhost:9200')
ELASTICSEARCH_DSL = {
    'default': {
        'hosts': ELASTICSEARCH_URL,
        'http_auth': (ELASTICSEARCH_USER, ELASTICSEARCH_PASSWORD),
    },
}
```

### ب. خيار 2: Elasticsearch منصة (Hosted)
- **Elastic Cloud**: $95/شهر للـ Standard (1GB RAM)
- **Bonsai**: $19/شهر للـ Starter
- **SearchBox**: $24/شهر للـ Starter

### ج. خيار 3: pg_search (PostgreSQL Full-Text Search)
- **بدون خادم إضافي** — يستخدم tsvector في PostgreSQL
- **أداء مقبول** للمنصات الصغيرة (< 100K سجل)
- **الأولوية**: يُستخدم كـ fallback إذا لم يكن Elasticsearch متاحاً

---

## 3. نماذج البحث (Search Indices)

### أ. فهرس الدورات (`courses`)
```python
from django_elasticsearch_dsl import Document, fields
from django_elasticsearch_dsl.registries import registry

@registry.register_document
class CourseDocument(Document):
    title = fields.TextField(analyzer='arabic', fields={'raw': fields.KeywordField()})
    description = fields.TextField(analyzer='arabic')
    instructor_name = fields.TextField(analyzer='arabic')
    category = fields.KeywordField()
    access_level = fields.KeywordField()
    price = fields.FloatField()
    created_at = fields.DateField()
    suggestions = fields.CompletionField()

    class Index:
        name = 'courses'
        settings = {'number_of_shards': 1}

    def prepare_suggestions(self, instance):
        return [instance.title, instance.instructor_name]
```

### ب. فهرس الكتب (`ebooks`)
```python
@registry.register_document
class EbookDocument(Document):
    title = fields.TextField(analyzer='arabic')
    author = fields.TextField(analyzer='arabic')
    description = fields.TextField(analyzer='arabic')
    category = fields.KeywordField()
    access_level = fields.KeywordField()
```

### ج. فهرس المستخدمين (`users`)
```python
@registry.register_document
class UserDocument(Document):
    full_name = fields.TextField(analyzer='arabic')
    email = fields.TextField(fields={'raw': fields.KeywordField()})
    role = fields.KeywordField()
    school_name = fields.TextField(analyzer='arabic')
```

### د. فهرس المقالات (`blog_posts`)
```python
@registry.register_document
class BlogPostDocument(Document):
    title = fields.TextField(analyzer='arabic')
    content = fields.TextField(analyzer='arabic')
    category = fields.KeywordField()
    author_name = fields.TextField(analyzer='arabic')
```

---

## 4. نقطة النهاية (Search API)

```
GET /api/v1/core/search/?q=math&locale=ar&type=courses,ebooks&page=1
GET /api/v1/core/search/autocomplete/?q=phy&locale=ar
GET /api/v1/core/search/suggestions/?q=mat&locale=ar
```

### استجابة البحث:
```json
{
    "query": "physics",
    "total": 45,
    "page": 1,
    "results": [
        {
            "type": "course",
            "id": 12,
            "title": "فيزياء 101",
            "description": "مقدمة في الفيزياء...",
            "url": "/courses/physics-101",
            "score": 0.95,
            "highlights": {
                "description": ["... <em>فيزياء</em> تفاعلية مع تجارب معملية ..."]
            }
        }
    ],
    "facets": {
        "type": {"course": 30, "ebook": 15},
        "access_level": {"free": 20, "pro": 25}
    }
}
```

---

## 5. الواجهة الأمامية (Frontend)

### مكون البحث الرئيسي
```typescript
interface SearchBarProps {
    onSearch: (query: string) => void;
    onAutocomplete: (suggestions: string[]) => void;
    locale: string;
    types?: ('courses' | 'ebooks' | 'blog' | 'users')[];
}
```

### صفحة البحث: `/search?q=physics`
```
┌─────────────────────────────────────────────────────┐
│  🔍 physics                                    [بحث] │
├─────────────────────────────────────────────────────┤
│  필터: [الكل] [دورات] [كتب] [مقالات] [مستخدمين]     │
├─────────────────────────────────────────────────────┤
│  نتائج البحث (45 نتيجة):                             │
│                                                     │
│  📘 فيزياء 101 — مقدمة تفاعلية                      │
│     الدورة · مجاني · ★ 4.8                          │
│     "... <em>فيزياء</em> تفاعلية مع تجارب معملية ..."│
│                                                     │
│  📕 مقدمة في الفيزياء العامة                         │
│     كتاب · Pro · ★ 4.6                              │
│     "... دليل شامل لأساسيات <em>الفيزياء</em> ..."    │
└─────────────────────────────────────────────────────┘
```

---

## 6. التكامل مع نظام الترجمة
- البحث يدعم **10 لغات** عبر `language` analyzer في Elasticsearch
- كل فهرس يحتوي حقل `locale` لفلترة النتائج حسب اللغة
- **Stemming** لكل لغة: Arabic ( ت gypsum ), English (stemming), French (stemming)
