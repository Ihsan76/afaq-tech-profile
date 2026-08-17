# التحليلات والتقارير

## Google Analytics 4

### الإعداد
```typescript
// Frontend
import { Analytics } from '@vercel/analytics';

export function AnalyticsProvider({ children }) {
  return (
    <Analytics>
      {children}
    </Analytics>
  );
}
```

### الأحداث المتعقبة
```typescript
// Events
analytics.track('lesson_plan_generated', {
  subject: 'math',
  grade: '3rd',
  provider: 'gemini'
});

analytics.track('course_enrolled', {
  course_id: 123,
  course_name: 'Math Basics'
});

analytics.track('payment_completed', {
  amount: 15,
  currency: 'USD',
  plan: 'pro'
});
```

---

## تحليلات المنصة

### إحصائيات المستخدمين

```python
class UserAnalytics:
    
    @staticmethod
    def get_user_stats():
        """إحصائيات المستخدمين"""
        from django.db.models import Count
        from django.utils import timezone
        from datetime import timedelta
        
        today = timezone.now().date()
        week_ago = today - timedelta(days=7)
        month_ago = today - timedelta(days=30)
        
        return {
            'total_users': User.objects.count(),
            'today_registrations': User.objects.filter(
                date_joined__date=today
            ).count(),
            'week_registrations': User.objects.filter(
                date_joined__date__gte=week_ago
            ).count(),
            'month_registrations': User.objects.filter(
                date_joined__date__gte=month_ago
            ).count(),
            'active_users': User.objects.filter(
                last_login__date=today
            ).count(),
            'by_role': User.objects.values('role').annotate(
                count=Count('id')
            )
        }
```

### إحصائيات AI

```python
class AIAnalytics:
    
    @staticmethod
    def get_ai_stats():
        """إحصائيات AI"""
        from django.db.models import Sum
        from django.utils import timezone
        from datetime import timedelta
        
        today = timezone.now().date()
        month_ago = today - timedelta(days=30)
        
        month_stats = AIRun.objects.filter(
            created_at__date__gte=month_ago
        ).aggregate(
            total_runs=Count('id'),
            total_tokens=Sum('total_tokens'),
            total_cost=Sum('cost_usd'),
            avg_latency=Avg('latency_ms'),
            success_rate=Count('id', filter=Q(success=True)) / Count('id')
        )
        
        return {
            'today': AIRun.objects.filter(
                created_at__date=today
            ).aggregate(
                runs=Count('id'),
                tokens=Sum('total_tokens'),
                cost=Sum('cost_usd')
            ),
            'month': month_stats,
            'by_provider': AIRun.objects.filter(
                created_at__date__gte=month_ago
            ).values('provider').annotate(
                runs=Count('id'),
                tokens=Sum('total_tokens'),
                cost=Sum('cost_usd')
            ),
            'by_feature': AIRun.objects.filter(
                created_at__date__gte=month_ago
            ).values('feature').annotate(
                runs=Count('id'),
                tokens=Sum('total_tokens')
            )
        }
```

### إحصائيات المدفوعات

```python
class PaymentAnalytics:
    
    @staticmethod
    def get_payment_stats():
        """إحصائيات المدفوعات"""
        from django.db.models import Sum, Count
        from django.utils import timezone
        from datetime import timedelta
        
        today = timezone.now().date()
        month_ago = today - timedelta(days=30)
        
        return {
            'today': Transaction.objects.filter(
                created_at__date=today,
                status='completed'
            ).aggregate(
                count=Count('id'),
                amount=Sum('amount')
            ),
            'month': Transaction.objects.filter(
                created_at__date__gte=month_ago,
                status='completed'
            ).aggregate(
                count=Count('id'),
                amount=Sum('amount')
            ),
            'by_type': Transaction.objects.filter(
                created_at__date__gte=month_ago,
                status='completed'
            ).values('type').annotate(
                count=Count('id'),
                amount=Sum('amount')
            )
        }
```

---

## تقارير مخصصة

```python
class ReportGenerator:
    
    @staticmethod
    def generate_monthly_report(year, month):
        """تقرير شهري"""
        return {
            'period': f'{year}-{month:02d}',
            'users': UserAnalytics.get_user_stats(),
            'ai': AIAnalytics.get_ai_stats(),
            'payments': PaymentAnalytics.get_payment_stats(),
            'courses': Course.objects.filter(
                created_at__year=year,
                created_at__month=month
            ).count(),
            'lesson_plans': LessonPlan.objects.filter(
                created_at__year=year,
                created_at__month=month
            ).count()
        }
```

---

## KPIs الرئيسية

| KPI | الهدف (6 أشهر) |
|-----|----------------|
| مستخدمون مسجلون | 10,000 |
| مستخدمون نشطون يومياً | 1,000 |
| طلبات AI/يوم | 5,000 |
| دورات مكتملة | 100 |
| إيرادات شهرية | $1,000 |
| معدل التحويل (مجاني → مدفوع) | 5% |
| معدل الاحتفاظ الشهري | 40% |
