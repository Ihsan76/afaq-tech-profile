# التوجيه الذكي (Smart Routing) — مُنفّذ ✅

> تم تنفيذ `router.py` في `backend/apps/ai/router.py` مع `BaseProvider` ABC، Circuit Breaker، Token Bucket rate limiting، Feature-based routing، Semantic Caching، وAIRun logging.

## المعمارية المُنفّذة

```
ProviderRouter.generate(prompt, feature, system_instruction)
    │
    ├── 1. Check Cache (SHA256 hash → Redis)
    │     └── Hit? → Return cached AIResponse
    │
    ├── 2. Get Provider Order (حسب feature)
    │     └── lesson_plan → google, openai, ollama
    │     └── quiz → openai, google, ollama
    │     └── ...
    │
    ├── 3. For each provider:
    │     ├── Circuit Breaker check (3 failures → skip 60s)
    │     ├── Rate Limit check (TokenBucket: 15/min google, 60/min openai)
    │     ├── Health check (يختبر API)
    │     └── Generate (مع توقيت + تسجيل)
    │
    └── 4. All failed → AIResponse(success=False, error="...")
```

## BaseProvider (ABC) — مُنفّذ ✅

```python
class BaseProvider(ABC):
    name: str
    model_name: str

    @abstractmethod
    def generate(self, prompt, **kwargs) -> AIResponse: ...
    @abstractmethod
    def health_check(self) -> bool: ...
```

### المزودون المُنفّذون

| المزود | الكلاس | API |
|--------|--------|-----|
| Gemini | `GeminiProvider` | `google.generativeai` |
| OpenAI | `OpenAIProvider` | `openai.ChatCompletion` |
| Ollama | `OllamaProvider` | `openai` client → `localhost:11434/v1` |

## AIResponse — مُنفّذ ✅

```python
@dataclass
class AIResponse:
    content: str
    model: str
    provider: str
    prompt_tokens: int = 0
    completion_tokens: int = 0
    total_tokens: int = 0
    latency_ms: int = 0
    success: bool = True
    error: Optional[str] = None
```

## Circuit Breaker — مُنفّذ ✅

- **الحد**: 3 إخفاقات متتالية خلال 60 ثانية
- **السلوك**: تخطي المزود تلقائياً
- **إعادة التعيين**: تلقائي بعد 60 ثانية من آخر فشل
- **التسجيل**: `logging.warning` عند الفتح

## Rate Limiting (Token Bucket) — مُنفّذ ✅

| المزود | الحد/دقيقة |
|--------|-----------|
| Google Gemini | 15 |
| OpenAI | 60 |
| Ollama | 100 |

## Feature-based Routing — مُنفّذ ✅

| الميزة | ترتيب المزودين |
|--------|---------------|
| `lesson_plan` | google → openai → ollama |
| `refine` | google → openai → ollama |
| `worksheet` | google → openai → ollama |
| `homework` | google → openai → ollama |
| `quiz` | openai → google → ollama |
| `assistant` | google → openai → ollama |
| `summary` | google → ollama → openai |
| `translation` | google → openai → ollama |

## Semantic Caching — مُنفّذ ✅

- مفتاح الكاش: `ai_cache:{SHA256(prompt + feature + system_instruction)}`
- TTL: 86400 ثانية (24 ساعة)
- تسجيل: `Cache hit for feature=...`

## AIRun Logging — مُنفّذ ✅

- يسجل كل طلب AI ناجح في جدول `AIRun`
- الحقول: `feature`, `prompt`, `response`, `model_used`, `tokens_used`, `duration_ms`

## دمج مع services.py — مُنفّذ ✅

- `generate_lesson_plan()` و `refine_lesson_plan()` تستخدم `router.generate()` بدلاً من الكود المكرر
- `generate_worksheet_view()` و `generate_homework_view()` في lessonplans تستخدم `ProviderRouter()` مباشرة
