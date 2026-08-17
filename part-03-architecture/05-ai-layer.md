# طبقة الذكاء الاصطناعي — مُنفّذة ✅

## المزودون — مُنفّذ ✅

| المزود | النموذج | الاستخدام | الحالة |
|--------|---------|-----------|--------|
| **Google Gemini** | gemini-3.6-flash | Primary | ✅ مُنفّذ |
| **OpenAI** | gpt-4o | Secondary | ✅ مُنفّذ |
| **Ollama** | llama3 | Local fallback | ✅ مُنفّذ |
| **OpenAI Compatible** | أي نموذج | توافقية | ✅ مُنفّذ |
| **Anthropic Claude** | claude-3-haiku | Fallback | ⏳ غير منفّذ بعد |

---

## الهيكل الفعلي

```
ai/
├── services.py           # AI Service Layer (توليد، تعديل، caching)
├── models.py             # AIModel, AIProvider, PromptTemplate, AIRun
├── serializers.py
├── views.py
└── urls.py
```

> **ملاحظة:** الملفات `router.py` و `providers/` و `prompts/` هي الخطة المستقبلية. حالياً كل المنطق في `services.py`.

---

## المعمارية الفعلية

```
User Request → API View → services.generate_lesson_plan()
                                │
                    ┌───────────┴───────────┐
                    │                       │
            Semantic Cache            PromptBuilder
            (SHA256 + Redis)          (اختيار القالب)
                    │                       │
                    └───────────┬───────────┘
                                │
                    _resolve_model_and_client()
                    (تحديد المزود من قاعدة البيانات)
                                │
                    ┌───────────┴───────────┐
                    │                       │
                 Gemini (google)         OpenAI / Ollama /
                                         OpenAI Compatible
                                │
                    ┌───────────┴───────────┐
                    │                       │
              JSON Parser              AIRun Logger
              (استخراج JSON)           (تسجيل العملية)
```

---

## الخدمات الأساسية — مُنفّذة ✅

### `generate_lesson_plan(title, prompt_text, subject, grade, language, ...)`
- **Semantic Caching**: SHA256(prompt) → تخزين في Redis لمدة 24 ساعة
- **Curriculum Injection**: إدراج نصوص من `CurriculumDocument` في السياق
- **PromptBuilder**: اختيار القالب الأنسب حسب `learners_stage`, `subject`, `curriculum`
- **Fallback**: إذا فشل Gemini → يجرب OpenAI → Ollama (ضمن `_resolve_model_and_client`)

### `refine_lesson_plan(current_plan_data, refinement_prompt, ...)`
- تعديل خطة درس موجودة حسب طلب المستخدم
- نفس نظام fallback

### `chat_stream(messages, new_message, ...)`
- محادثة تفاعلية (للمساعد الذكي)
- يدعم streaming

### `PromptBuilderService`
- اختيار `PromptTemplate` من قاعدة البيانات حسب `feature_key`, `language`, `learner_stage`, `subject`, `curriculum`
- ترتيب حسب `specificity` (يُفضل القوالب المطابقة تماماً)

---

## التوجيه (Routing)

### `_resolve_model_and_client(requested_model_id=None)`
- يبحث عن `AIModel` في قاعدة البيانات
- إذا لم يُحدد: يستخدم النموذج الافتراضي (`is_default=True`)
- يعيد `(provider_code, model_name, api_key, base_url)`
- يدعم: `google`, `openai`, `ollama`, `openai_compatible`

### نظام fallback — بسيط حالياً
- **المستقبل:** `ProviderRouter` مع health checks, circuit breaker, rate limiting

---

## التخزين المؤقت (Caching) — مُنفّذ ✅

```python
# Semantic caching باستخدام SHA256
cache_key_data = f"{title}-{prompt_text}-{subject}-{grade}-{language}-{model_id}"
cache_hash = hashlib.sha256(cache_key_data.encode('utf-8')).hexdigest()
cached_result = cache.get(f"ai_lesson_plan:{cache_hash}")
if cached_result:
    return cached_result  # استرجاع فوري
# ... توليد جديد ...
cache.set(f"ai_lesson_plan:{cache_hash}", plan_data, 86400)  # 24 ساعة
```

---

## نماذج AI — مُنفّذة ✅

```python
class AIModel(models.Model):
    """نموذج AI مسجل في قاعدة البيانات"""
    provider = models.CharField(max_length=50)           # google, openai, ollama...
    model_id = models.CharField(max_length=100)          # gemini-3.6-flash...
    is_active = models.BooleanField(default=True)
    is_default = models.BooleanField(default=False)
    # ...

class AIProvider(models.Model):
    """مزود AI مع API key"""
    provider_type = models.ForeignKey(ProviderType, on_delete=models.CASCADE)
    api_key_encrypted = models.CharField(max_length=500, blank=True)
    base_url = models.CharField(max_length=500, blank=True)
    is_active = models.BooleanField(default=True)
    # ...

class PromptTemplate(models.Model):
    """قوالب الاستعلامات"""
    feature_key = models.CharField(max_length=50)        # lesson_plan, quiz...
    language = models.CharField(max_length=5)
    template_body = models.TextField()
    is_default = models.BooleanField(default=False)
    subject = models.ForeignKey(Subject, null=True, blank=True)
    curriculum = models.ForeignKey(Curriculum, null=True, blank=True)
    learner_stage = models.CharField(max_length=50, blank=True)
    # ...

class AIRun(models.Model):
    """سجل تشغيل AI (تسجل كل عملية توليد)"""
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    feature = models.CharField(max_length=50)            # lesson_plan, refine...
    prompt = models.TextField()
    response = models.TextField()
    model_used = models.CharField(max_length=100)
    tokens_used = models.IntegerField(default=0)
    duration_ms = models.IntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)
```

---

## ما هو مُنفّذ ✅

- `generate_lesson_plan` مع Semantic Caching وCurriculum Injection وPromptBuilderService
- `refine_lesson_plan` (تعديل الخطة عبر AI)
- `chat_stream` (محادثة تفاعلية مع streaming)
- `PromptBuilderService` (اختيار القالب حسب السياق)
- `AIModel`, `AIProvider`, `PromptTemplate`, `AIRun` (نماذج قابلة للتكوين عبر DB)
- 9 لغات مدعومة في القوالب
- تخزين مؤقت (Redis) لمدة 24 ساعة

## ما هو غير مُنفّذ ❌

- `ProviderRouter` الرسمي (BaseProvider ABC + router.py) — حالياً `_resolve_model_and_client` بسيط
- Health checks التلقائية
- Circuit breaker
- Rate limiting على مستوى المزود
- `AIStats` تجميع إحصائيات
