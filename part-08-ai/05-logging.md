# التتبع والسجلات

## نموذج AIRun

```python
# models.py
class AIRun(models.Model):
    """تتبع كل تشغيل AI"""
    
    user = models.ForeignKey('users.User', on_delete=models.CASCADE)
    
    provider = models.CharField(max_length=50)
    model = models.CharField(max_length=100)
    feature = models.CharField(max_length=50)
    
    prompt_tokens = models.IntegerField(default=0)
    completion_tokens = models.IntegerField(default=0)
    total_tokens = models.IntegerField(default=0)
    
    cost_usd = models.DecimalField(max_digits=10, decimal_places=6, default=0)
    latency_ms = models.IntegerField(default=0)
    
    success = models.BooleanField(default=True)
    error_message = models.TextField(blank=True)
    
    request_data = models.JSONField(default=dict)
    response_data = models.JSONField(default=dict)
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        indexes = [
            models.Index(fields=['user', 'created_at']),
            models.Index(fields=['provider', 'created_at']),
            models.Index(fields=['feature', 'created_at']),
        ]
```

---

## تسجيل التشغيل

```python
# services.py
class AIService:
    def __init__(self, router: ProviderRouter):
        self.router = router
    
    async def generate(self, user, feature: str, prompt: str, **kwargs) -> AIResponse:
        """توليد مع التتبع"""
        
        import time
        start = time.time()
        
        # توليد
        response = await self.router.route(prompt, feature, **kwargs)
        
        latency = int((time.time() - start) * 1000)
        
        # تسجيل AIRun
        airun = AIRun.objects.create(
            user=user,
            provider=response.provider,
            model=response.model,
            feature=feature,
            prompt_tokens=response.prompt_tokens,
            completion_tokens=response.completion_tokens,
            total_tokens=response.total_tokens,
            cost_usd=self._calculate_cost(response),
            latency_ms=latency,
            success=response.success,
            error_message=response.error or '',
            request_data={'prompt': prompt[:500], **kwargs},
            response_data={'content': response.content[:500]}
        )
        
        # تحديث الإحصائيات
        await self._update_stats(user, airun)
        
        return response
    
    def _calculate_cost(self, response: AIResponse) -> Decimal:
        """حساب التكلفة"""
        # Gemini مجاني
        if response.provider == 'gemini':
            return Decimal('0')
        
        # OpenAI
        if response.provider == 'openai':
            # gpt-4o: $2.5/1M input, $10/1M output
            input_cost = response.prompt_tokens * Decimal('0.0000025')
            output_cost = response.completion_tokens * Decimal('0.00001')
            return input_cost + output_cost
        
        # Claude
        if response.provider == 'claude':
            # claude-3-haiku: $0.25/1M input, $1.25/1M output
            input_cost = response.prompt_tokens * Decimal('0.00000025')
            output_cost = response.completion_tokens * Decimal('0.00000125')
            return input_cost + output_cost
        
        return Decimal('0')
    
    async def _update_stats(self, user, airun):
        """تحديث الإحصائيات اليومية"""
        from django.utils import timezone
        today = timezone.now().date()
        
        stats, created = AIStats.objects.get_or_create(
            user=user,
            date=today,
            defaults={
                'total_runs': 0,
                'total_tokens': 0,
                'total_cost_usd': 0,
                'provider_breakdown': {},
                'feature_breakdown': {}
            }
        )
        
        stats.total_runs += 1
        stats.total_tokens += airun.total_tokens
        stats.total_cost_usd += airun.cost_usd
        
        # تحديث التفصيل حسب المزود
        breakdown = stats.provider_breakdown
        if airun.provider not in breakdown:
            breakdown[airun.provider] = {'runs': 0, 'tokens': 0, 'cost': 0}
        breakdown[airun.provider]['runs'] += 1
        breakdown[airun.provider]['tokens'] += airun.total_tokens
        breakdown[airun.provider]['cost'] += float(airun.cost_usd)
        stats.provider_breakdown = breakdown
        
        # تحديث التفصيل حسب الميزة
        feature_breakdown = stats.feature_breakdown
        if airun.feature not in feature_breakdown:
            feature_breakdown[airun.feature] = {'runs': 0, 'tokens': 0}
        feature_breakdown[airun.feature]['runs'] += 1
        feature_breakdown[airun.feature]['tokens'] += airun.total_tokens
        stats.feature_breakdown = feature_breakdown
        
        stats.save()
```

---

## تقارير الاستخدام

```python
# views.py
class AIStatsView(APIView):
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        user = request.user
        period = request.query_params.get('period', 'month')
        
        if period == 'today':
            stats = AIStats.objects.filter(
                user=user,
                date=timezone.now().date()
            ).first()
        elif period == 'week':
            week_ago = timezone.now() - timedelta(days=7)
            stats = AIStats.objects.filter(
                user=user,
                date__gte=week_ago
            ).aggregate(
                total_runs=Sum('total_runs'),
                total_tokens=Sum('total_tokens'),
                total_cost_usd=Sum('total_cost_usd')
            )
        else:  # month
            month_ago = timezone.now() - timedelta(days=30)
            stats = AIStats.objects.filter(
                user=user,
                date__gte=month_ago
            ).aggregate(
                total_runs=Sum('total_runs'),
                total_tokens=Sum('total_tokens'),
                total_cost_usd=Sum('total_cost_usd')
            )
        
        return Response(stats)
```
