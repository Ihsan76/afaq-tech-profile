# تحسين التكلفة

## استراتيجية تحسين التكلفة

### 1. Gemini أولاً (مجاني)
Gemini هو المزود الأساسي لأنه مجاني. جميع الطلبات تبدأ من Gemini.

### 2. Caching ذكي
```python
# تخزين مؤقت للنتائج المكررة
CACHE_STRATEGIES = {
    'lesson_plan': {
        'ttl': 86400,  # 24 ساعة
        'key': 'subject:{subject}:grade:{grade}:topic:{topic}'
    },
    'quiz': {
        'ttl': 86400,
        'key': 'lesson:{lesson}:type:{type}:difficulty:{difficulty}'
    },
    'summary': {
        'ttl': 604800,  # أسبوع
        'key': 'content_hash:{hash}'
    }
}
```

### 3. تقليل الرموز
```python
# تقليل حجم الاستعلام
def optimize_prompt(prompt: str) -> str:
    """تقليل عدد الرموز في الاستعلام"""
    # إزالة المسافات الزائدة
    prompt = ' '.join(prompt.split())
    
    # تقليل التكرار
    # ... logic to remove redundancy
    
    return prompt

# تقليل حجم الإخراج
GENERATION_CONFIG = {
    'lesson_plan': {'max_tokens': 2000},
    'quiz': {'max_tokens': 1500},
    'assistant': {'max_tokens': 1000},
    'summary': {'max_tokens': 500},
}
```

### 4. Rate Limiting
```python
# حدود الاستخدام حسب الباقة
RATE_LIMITS = {
    'free': {'daily': 50, 'per_minute': 5},
    'basic': {'daily': 100, 'per_minute': 10},
    'pro': {'daily': 300, 'per_minute': 30},
    'team': {'daily': -1, 'per_minute': 100},  # -1 = غير محدود
}
```

---

## تكلفة تقديرية

### حسب المزود

| المزود | تكلفة/1K رمز | ملاحظات |
|--------|--------------|---------|
| Gemini | مجاني | 15 RPM مجاني |
| OpenAI GPT-4o | $2.5 input, $10 output | الأغلى |
| Claude Haiku | $0.25 input, $1.25 output | متوسط |
| Ollama | مجاني | محلي فقط |

### حسب الاستخدام الشهري

| الحجم | Gemini | OpenAI | الإجمالي |
|-------|--------|--------|----------|
| 10K طلب/شهر | $0 | $50-100 | $50-100 |
| 50K طلب/شهر | $0 | $250-500 | $250-500 |
| 100K طلب/شهر | $0 | $500-1000 | $500-1000 |

### الحساب التفصيلي

```
مثال: 10,000 طلب/شهر
- متوسط 500 رمز/طلب = 5,000,000 رمز شهرياً
- 80% عبر Gemini = $0
- 20% عبر OpenAI = 1,000,000 رمز × $0.00625/1K = $6.25
- الإجمالي: ~$6.25/شهر
```

---

## تحسين الأداء

### 1. Batch Processing
```python
# معالجة متعددة الطلبات
async def batch_generate(prompts: List[str], feature: str) -> List[AIResponse]:
    """معالجة مجموعة طلبات دفعة واحدة"""
    tasks = [router.route(p, feature) for p in prompts]
    return await asyncio.gather(*tasks)
```

### 2. Connection Pooling
```python
# إدارة اتصالات HTTP
import httpx

class ConnectionPool:
    def __init__(self):
        self.client = httpx.AsyncClient(
            limits=httpx.Limits(
                max_connections=100,
                max_keepalive_connections=20
            )
        )
```

### 3. Retry Logic
```python
# إعادة المحاولة مع تراجع أسي
from tenacity import retry, stop_after_attempt, wait_exponential

@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=4, max=10)
)
async def generate_with_retry(provider, prompt, **kwargs):
    return await provider.generate(prompt, **kwargs)
```

---

## مراقبة التكلفة

```python
# alerts.py
class CostAlert:
    """تنبيهات التكلفة"""
    
    DAILY_LIMIT = Decimal('10.00')  # $10/يوم
    MONTHLY_LIMIT = Decimal('200.00')  # $200/شهر
    
    def check_daily_cost(self, user):
        today_cost = AIRun.objects.filter(
            user=user,
            created_at__date=timezone.now().date()
        ).aggregate(total=Sum('cost_usd'))['total'] or 0
        
        if today_cost >= self.DAILY_LIMIT:
            self.send_alert(user, f"تجاوزت التكلفة اليومية: ${today_cost}")
    
    def check_monthly_cost(self, user):
        month_cost = AIRun.objects.filter(
            user=user,
            created_at__month=timezone.now().month
        ).aggregate(total=Sum('cost_usd'))['total'] or 0
        
        if month_cost >= self.MONTHLY_LIMIT:
            self.send_alert(user, f"تجاوزت التكلفة الشهرية: ${month_cost}")
```
