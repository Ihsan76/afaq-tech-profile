# سير عمل الترجمة (Translation Workflow)

## نظرة عامة

如何ية إدارة ترجمة المحتوى في المنصة — يدوياً، تلقائياً بالـ AI، وعبر لوحة الإدارة.

---

## أنواع الترجمة

| النوع | الطريقة | الاستخدام |
|-------|---------|----------|
| **ترجمة يدوية** | فريق المحتوى يترجم | المحتوى الرئيسي، المقالات |
| **ترجمة AI** | Gemini/OpenAI | المحتوى الطويل، الدورات |
| **ترجمة آلية** | Google Translate API | المحتوى الثانوي، الوصف |
| **ترجمة هجينة** | AI + مراجعة يدوية | التوازن بين الجودة والسرعة |

---

## سير العمل: ترجمة المحتوى

### الخطوة 1: إنشاء المحتوى الأصلي

```
المستخدم (عربي) → إنشاء مقال بالعربية
    ↓
النظام يحفظ: language='ar', content='...'
    ↓
المقال يظهر في قائمة المقالات العربية
```

### الخطوة 2: طلب الترجمة

```
فريق المحتوى → اختيار المقال → "ترجمة إلى"
    ↓
اختيار اللغات المطلوبة: [en, fr, tr]
    ↓
النظام يُنشئ مهام ترجمة
```

### الخطوة 3: الترجمة

#### الخيار A: ترجمة يدوية

```
المترجم → فتح المقال في محرر الترجمة
    ↓
عرض النص الأصلي (ar) بجانب حقل الترجمة
    ↓
المترجم يكتب الترجمة
    ↓
حفظ → الحالة: "مترجم"
    ↓
مراجع → مراجعة الترجمة → "منشور"
```

#### الخيار B: ترجمة بالـ AI

```
فريق المحتوى → "ترجمة تلقائية بالـ AI"
    ↓
النظام يرسل النص إلى Gemini
    ↓
Gemini يترجم مع الحفاظ على المصطلحات
    ↓
الترجمة تُحفظ بحالة "تحتاج مراجعة"
    ↓
مراجع → مراجعة → تصحيح → "منشور"
```

---

## لوحة إدارة الترجمة

### واجهة الترجمة

```
┌─────────────────────────────────────────────────────────────────┐
│                    إدارة الترجمات                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  المقال: "أساسيات الرياضيات"                                    │
│  اللغة الأصلية: العربية (ar)                                    │
│                                                                  │
│  ┌──────────────┬──────────────┬──────────────┬──────────────┐  │
│  │ English (en) │ Français (fr)│ Türkçe (tr)  │ اردو (ur)    │  │
│  ├──────────────┼──────────────┼──────────────┼──────────────┤  │
│  │ ✅ منشور     │ ⏳ مراجعة    │ ❌ غير مترجم │ ❌ غير مترجم │  │
│  │ 1500 كلمة    │ 1480 كلمة    │ -            │ -            │  │
│  │ آخر تحديث:   │ آخر تحديث:   │              │              │  │
│  │ 2025-01-15   │ 2025-01-14   │              │              │  │
│  └──────────────┴──────────────┴──────────────┴──────────────┘  │
│                                                                  │
│  [ترجمة تلقائية بالـ AI]  [إضافة ترجمة يدوية]  [تصدير]        │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### حالت الترجمة

| الحالة | المعنى | اللون |
|--------|--------|-------|
| `pending` | لم تبدأ بعد | رمادي |
| `in_progress` | قيد الترجمة | أزرق |
| `review` | تحت المراجعة | برتقالي |
| `published` | منشورة | أخضر |
| `outdated` | قديمة (تحديث مطلوب) | أحمر |

---

## الترجمة التلقائية بالـ AI

### API endpoint

```
POST /api/v1/translations/auto-translate/
```

### Request

```json
{
  "content_id": 123,
  "content_type": "blog_post",
  "source_language": "ar",
  "target_languages": ["en", "fr", "tr"],
  "provider": "gemini",
  "quality": "high"
}
```

### Response

```json
{
  "task_id": "translate_123",
  "status": "processing",
  "estimated_time": 30,
  "results": {
    "en": {
      "status": "completed",
      "translation_id": 456,
      "quality_score": 0.92
    },
    "fr": {
      "status": "completed",
      "translation_id": 457,
      "quality_score": 0.89
    },
    "tr": {
      "status": "processing",
      "estimated_time": 15
    }
  }
}
```

### خوارزمية الترجمة

```python
# translations/services.py

from ai.providers import AIProvider


class TranslationService:
    """خدمة الترجمة"""
    
    def __init__(self):
        self.ai_provider = AIProvider()
    
    async def translate_content(
        self,
        content: str,
        source_lang: str,
        target_lang: str,
        content_type: str = 'general'
    ) -> dict:
        """ترجمة المحتوى"""
        
        # 1. تحليل المحتوى
        content_analysis = self.analyze_content(content, content_type)
        
        # 2. إنشاء قالب الترجمة
        prompt = self.create_translation_prompt(
            content=content,
            source_lang=source_lang,
            target_lang=target_lang,
            content_type=content_type,
            glossary=self.get_glossary(source_lang, target_lang)
        )
        
        # 3. الترجمة بالـ AI
        translation = await self.ai_provider.generate(
            prompt=prompt,
            provider='gemini',
            max_tokens=4000
        )
        
        # 4. التحقق من الجودة
        quality_score = self.evaluate_quality(
            original=content,
            translated=translation,
            source_lang=source_lang,
            target_lang=target_lang
        )
        
        # 5. حفظ الترجمة
        translation_id = await self.save_translation(
            original_id=content_analysis['id'],
            translated_content=translation,
            source_lang=source_lang,
            target_lang=target_lang,
            quality_score=quality_score
        )
        
        return {
            'translation_id': translation_id,
            'quality_score': quality_score,
            'status': 'review' if quality_score < 0.9 else 'published'
        }
    
    def create_translation_prompt(
        self,
        content: str,
        source_lang: str,
        target_lang: str,
        content_type: str,
        glossary: dict
    ) -> str:
        """إنشاء قالب الترجمة"""
        
        language_names = {
            'ar': 'العربية',
            'en': 'English',
            'fr': 'Français',
            'tr': 'Türkçe',
            'ur': 'اردو',
            'es': 'Español',
            'de': 'Deutsch',
            'id': 'Bahasa Indonesia',
            'bn': 'বাংলা',
        }
        
        prompt = f"""
أنت خبير ترجمة محترف متخصص في الترجمة التعليمية.
ترجم النص التالي من {language_names[source_lang]} إلى {language_names[target_lang]}.

قواعد الترجمة:
1. حافظ على المعنى الأصلي بدقة
2. استخدم لغة طبيعية وسلسة
3. حافظ على المصطلحات التقنية (انظر المعجم أدناه)
4. حافظ على تنسيق النص (عناوين، نقاط، جداول)
5. لا تترجم أسماء العلامات التجارية أو الأسماء العلمية

المعجم (Glossary):
{self.format_glossary(glossary)}

النص الأصلي:
{content}

أعطني الترجمة بالتنسيق JSON:
{{
    "translated_text": "النص المترجم",
    "confidence_score": 0.95,
    "notes": "ملاحظات على الترجمة"
}}
"""
        return prompt
    
    def get_glossary(self, source_lang: str, target_lang: str) -> dict:
        """جلب المعجم للمصطلحات"""
        
        # معجم أساسي للمصطلحات التعليمية
        glossary = {
            'ar_en': {
                'خطة الدرس': 'Lesson Plan',
                'المرحلة الدراسية': 'Grade Level',
                'المادة الدراسية': 'Subject',
                'المنهاج': 'Curriculum',
                'الهدف التعليمي': 'Learning Objective',
                'التقييم': 'Assessment',
                'التمرين': 'Exercise',
                'الواجب': 'Homework',
            },
            'ar_fr': {
                'خطة الدرس': 'Plan de leçon',
                'المرحلة الدراسية': 'Niveau scolaire',
                'المادة الدراسية': 'Matière',
                'المنهاج': 'Programme',
                'الهدف التعليمي': 'Objectif pédagogique',
                'التقييم': 'Évaluation',
                'التمرين': 'Exercice',
                'الواجب': 'Devoirs',
            },
            'ar_tr': {
                'خطة الدرس': 'Ders Planı',
                'المرحلة الدراسية': 'Sınıf Seviyesi',
                'المادة الدراسية': 'Ders',
                'المنهاج': 'Müfredat',
                'الهدف التعليمي': 'Öğrenim Hedefi',
                'التقييم': 'Değerlendirme',
                'التمرين': 'Alıştırma',
                'الواجب': 'Ödev',
            },
        }
        
        key = f'{source_lang}_{target_lang}'
        return glossary.get(key, {})
    
    def evaluate_quality(
        self,
        original: str,
        translated: str,
        source_lang: str,
        target_lang: str
    ) -> float:
        """تقييم جودة الترجمة"""
        
        score = 1.0
        
        # 1. فحص الطول (الترجمة أطول عادةً)
        length_ratio = len(translated) / len(original)
        if length_ratio < 0.5 or length_ratio > 2.0:
            score -= 0.2
        
        # 2. فحص الأحرف المشفرة
        if any(ord(c) > 0xFFFF for c in translated):
            score -= 0.1
        
        # 3. فحص التكرار
        if translated.count(translated[:10]) > 3:
            score -= 0.3
        
        return max(0.0, min(1.0, score))
    
    def analyze_content(self, content: str, content_type: str) -> dict:
        """تحليل المحتوى"""
        return {
            'id': hash(content),
            'length': len(content),
            'word_count': len(content.split()),
            'has_html': '<' in content,
            'has_code': '```' in content,
        }
    
    def format_glossary(self, glossary: dict) -> str:
        """تنسيق المعجم"""
        lines = []
        for arabic, translation in glossary.items():
            lines.append(f"- {arabic} → {translation}")
        return '\n'.join(lines)
    
    async def save_translation(self, **kwargs) -> int:
        """حفظ الترجمة في قاعدة البيانات"""
        # حفظ في نموذج Translation
        pass
```

---

## المراجعة والتدقيق

### واجهة المراجعة

```
┌─────────────────────────────────────────────────────────────────┐
│                    مراجعة الترجمة                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  النص الأصلي (ar):                                              │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ خطة الدرس: الأعداد الطبيعية                            │    │
│  │ الهدف: يعرف الطالب الأعداد الطبيعية ويستطيع العد       │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                  │
│  الترجمة (en):                                                  │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ Lesson Plan: Natural Numbers                            │    │
│  │ Objective: Student recognizes natural numbers and can   │    │
│  │ count from 1 to 100                                     │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                  │
│  جودة الترجمة: 92% ✅                                           │
│                                                                  │
│  ملاحظات المراجع:                                               │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ الترجمة ممتازة، تم اقتراح تغيير بسيط على العنوان       │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                  │
│  [✅ قبول]  [✏️ تعديل]  [❌ رفض]  [🔄 إعادة ترجمة]          │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### API المراجعة

```
PUT /api/v1/translations/{id}/review/
```

```json
{
  "status": "published",
  "review_notes": "الترجمة ممتازة، تم قبولها",
  "changes_made": [
    {
      "original": "Student recognizes natural numbers",
      "corrected": "Student understands natural numbers",
      "reason": "كلمة 'underwent' أنسب في السياق التعليمي"
    }
  ]
}
```

---

## المعجم (Glossary)

### إنشاء معجم موحد

```
POST /api/v1/glossary/
```

```json
{
  "source_language": "ar",
  "target_language": "en",
  "terms": [
    {
      "source": "خطة الدرس",
      "target": "Lesson Plan",
      "context": "تعليمي",
      "notes": "يُستخدم في سياق التخطيط التعليمي"
    },
    {
      "source": "المرحلة الدراسية",
      "target": "Grade Level",
      "context": "تعليمي",
      "notes": ""
    }
  ]
}
```

### استخدام المعجم في الترجمة

```python
# عند الترجمة، يتم إدراج المعجم في القالب
glossary = get_glossary(source_lang='ar', target_lang='en')
prompt = f"""
ترجم النص التالي...

المعجم:
- خطة الدرس → Lesson Plan
- المرحلة الدراسية → Grade Level
- المادة الدراسية → Subject

النص:
{content}
"""
```

---

## التتبع والإحصائيات

### لوحة معلومات الترجمة

```
┌─────────────────────────────────────────────────────────────────┐
│                    إحصائيات الترجمة                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  إجمالي المحتوى: 500 مقال                                       │
│                                                                  │
│  الحالة حسب اللغة:                                               │
│  ├── ar: 500 ✅ (100%)                                          │
│  ├── en: 350 ✅ (70%)                                           │
│  ├── fr: 200 ✅ (40%)                                           │
│  ├── tr: 50 ⏳ (10%)                                            │
│  ├── ur: 30 ⏳ (6%)                                             │
│  └── أخرى: 0 ❌                                                 │
│                                                                  │
│  الترجمات التلقائية:                                             │
│  ├──_AI generated: 300                                          │
│  ├── يدوية: 150                                                 │
│  └── هجينة: 50                                                  │
│                                                                  │
│  متوسط جودة الترجمة: 89%                                        │
│  الترجمات تحت المراجعة: 25                                       │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## ملخص

> **سير عمل الترجمة** يدعم الترجمة اليدوية، التلقائية بالـ AI، والهجينة. المكونات: لوحة إدارة الترجمات، معجم موحد للمصطلحات، نظام مراجعة وتدقيق، وتتبع الإحصائيات. الهدف: ترجمة محتوى عالي الجودة لكل لغة بسرعة ودقة.
