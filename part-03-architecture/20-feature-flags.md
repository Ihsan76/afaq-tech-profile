# أعلام الميزات (Feature Flags)

## نظرة عامة

ن system لإدارة الميزات الجديدة:Screens gradual rollout، A/B testing، وquick kill switches.

---

## المكونات

```
┌─────────────────────────────────────────────────────────────────┐
│                    Feature Flags System                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────┐    ┌──────────────────┐                   │
│  │  Admin Panel     │    │  Feature Flag    │                   │
│  │  (Control)       │───►│  Service         │                   │
│  └──────────────────┘    └──────────────────┘                   │
│                                 │                               │
│              ┌──────────────────┼──────────────────┐            │
│              ▼                  ▼                   ▼            │
│     ┌──────────────────┐ ┌──────────────────┐ ┌──────────────┐ │
│     │  Backend         │ │  Frontend        │ │  Mobile      │ │
│     │  (Django)        │ │  (React)         │ │  (RN)        │ │
│     └──────────────────┘ └──────────────────┘ └──────────────┘ │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Django Models

```python
# feature_flags/models.py

from django.db import models
from django.contrib.postgres.fields import JSONField


class FeatureFlag(models.Model):
    """علم الميزة"""
    
    class FlagType(models.TextChoices):
        BOOLEAN = 'boolean', 'م.boolean'
        PERCENTAGE = 'percentage', 'نسبة مئوية'
        USER_LIST = 'user_list', 'قائمة مستخدمين'
        PLAN_BASED = 'plan_based', 'بناءً على الخطة'
    
    name = models.CharField(max_length=100, unique=True)
    description = models.TextField(blank=True)
    
    flag_type = models.CharField(max_length=20, choices=FlagType.choices)
    
    # للعلم boolean
    is_enabled = models.BooleanField(default=False)
    
    # للعلم percentage
    percentage = models.IntegerField(default=0, help_text='0-100')
    
    # لعلم قائمة المستخدمين
    user_ids = JSONField(default=list, blank=True)
    
    # لعلم الخطة
    allowed_plans = JSONField(default=list, blank=True)
    # مثال: ['pro', 'enterprise']
    
    # الشرط المخصص
    custom_condition = JSONField(null=True, blank=True)
    # مثال: {"country": ["JO", "SA"], "min_points": 100}
    
    # التتبع
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    created_by = models.ForeignKey(
        'users.User', 
        on_delete=models.SET_NULL, 
        null=True
    )
    
    # إحصائيات
    total_impressions = models.IntegerField(default=0)
    total_clicks = models.IntegerField(default=0)
    
    class Meta:
        verbose_name = 'علم ميزة'
        verbose_name_plural = 'أعلام الميزات'
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.name} ({'ON' if self.is_enabled else 'OFF'})"
    
    def is_enabled_for_user(self, user) -> bool:
        """هل الميزة مفعلة لمستخدم معين؟"""
        
        if not self.is_enabled:
            return False
        
        if self.flag_type == 'boolean':
            return True
        
        elif self.flag_type == 'percentage':
            # خوارزمية نسبية مستقرة
            user_hash = hash(f"{self.name}:{user.id}") % 100
            return user_hash < self.percentage
        
        elif self.flag_type == 'user_list':
            return user.id in self.user_ids
        
        elif self.flag_type == 'plan_based':
            user_plan = getattr(user, 'subscription', None)
            if user_plan:
                return user_plan.plan.name in self.allowed_plans
            return False
        
        elif self.flag_type == 'custom':
            return self._check_custom_condition(user)
        
        return False
    
    def _check_custom_condition(self, user) -> bool:
        """فحص الشرط المخصص"""
        
        if not self.custom_condition:
            return False
        
        # فحص الدولة
        if 'country' in self.custom_condition:
            if user.country not in self.custom_condition['country']:
                return False
        
        # فحص الحد الأدنى من النقاط
        if 'min_points' in self.custom_condition:
            if user.gamification.points < self.custom_condition['min_points']:
                return False
        
        # فحص تاريخ التسجيل
        if 'registered_after' in self.custom_condition:
            from django.utils.dateparse import parse_date
            registered_after = parse_date(self.custom_condition['registered_after'])
            if user.date_joined.date() < registered_after:
                return False
        
        return True
    
    def record_impression(self):
        """تسجيل ظهور"""
        FeatureFlagImpression.objects.create(feature_flag=self)
        self.total_impressions += 1
        self.save(update_fields=['total_impressions'])
    
    def record_click(self):
        """تسجيل نقرة"""
        FeatureFlagClick.objects.create(feature_flag=self)
        self.total_clicks += 1
        self.save(update_fields=['total_clicks'])


class FeatureFlagImpression(models.Model):
    """ظهور علم الميزة"""
    
    feature_flag = models.ForeignKey(FeatureFlag, on_delete=models.CASCADE)
    user = models.ForeignKey('users.User', null=True, blank=True, on_delete=models.SET_NULL)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name = 'ظهور علم ميزة'
        verbose_name_plural = 'ظهور أعلام الميزات'


class FeatureFlagClick(models.Model):
    """نقرة على علم الميزة"""
    
    feature_flag = models.ForeignKey(FeatureFlag, on_delete=models.CASCADE)
    user = models.ForeignKey('users.User', null=True, blank=True, on_delete=models.SET_NULL)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name = 'نقرة علم ميزة'
        verbose_name_plural = 'نقرات أعلام الميزات'
```

---

## Django Service

```python
# feature_flags/services.py

from django.core.cache import cache
from .models import FeatureFlag


class FeatureFlagService:
    """خدمة أعلام الميزات"""
    
    CACHE_KEY_PREFIX = 'feature_flag:'
    CACHE_TIMEOUT = 300  # 5 دقائق
    
    @classmethod
    def is_enabled(cls, flag_name: str, user=None) -> bool:
        """هل الميزة مفعلة؟"""
        
        # محاولة الجلب من الكاش
        cache_key = f"{cls.CACHE_KEY_PREFIX}{flag_name}"
        flag_data = cache.get(cache_key)
        
        if flag_data is None:
            try:
                flag = FeatureFlag.objects.get(name=flag_name)
                flag_data = {
                    'is_enabled': flag.is_enabled,
                    'flag_type': flag.flag_type,
                    'percentage': flag.percentage,
                    'user_ids': flag.user_ids,
                    'allowed_plans': flag.allowed_plans,
                    'custom_condition': flag.custom_condition,
                }
                cache.set(cache_key, flag_data, cls.CACHE_TIMEOUT)
            except FeatureFlag.DoesNotExist:
                return False
        
        if not flag_data['is_enabled']:
            return False
        
        if user is None:
            return flag_data['is_enabled']
        
        # فحص حسب النوع
        flag = FeatureFlag(name=flag_name, **flag_data)
        return flag.is_enabled_for_user(user)
    
    @classmethod
    def get_all_flags(cls, user=None) -> dict:
        """جلب جميع الأعلام"""
        
        flags = FeatureFlag.objects.filter(is_enabled=True)
        
        result = {}
        for flag in flags:
            result[flag.name] = {
                'enabled': flag.is_enabled_for_user(user) if user else flag.is_enabled,
                'type': flag.flag_type,
            }
        
        return result
    
    @classmethod
    def invalidate_cache(cls, flag_name: str):
        """إبطال الكاش"""
        cache_key = f"{cls.CACHE_KEY_PREFIX}{flag_name}"
        cache.delete(cache_key)
    
    @classmethod
    def toggle_flag(cls, flag_name: str, enabled: bool):
        """toggle علم"""
        flag = FeatureFlag.objects.get(name=flag_name)
        flag.is_enabled = enabled
        flag.save()
        cls.invalidate_cache(flag_name)
```

---

## Django Decorator & Middleware

```python
# feature_flags/decorators.py

from functools import wraps
from django.http import JsonResponse


def feature_flag_required(flag_name: str, redirect_url: str = None):
    """ديكورات لحماية الميزات"""
    
    def decorator(view_func):
        @wraps(view_func)
        def wrapper(request, *args, **kwargs):
            from .services import FeatureFlagService
            
            if not FeatureFlagService.is_enabled(flag_name, request.user):
                if redirect_url:
                    return redirect(redirect_url)
                return JsonResponse({
                    'error': 'Feature not available',
                    'flag': flag_name,
                }, status=403)
            
            return view_func(request, *args, **kwargs)
        return wrapper
    return decorator
```

```python
# feature_flags/middleware.py

from .services import FeatureFlagService


class FeatureFlagMiddleware:
    """Middleware لإضافة الأعلام للطلب"""
    
    def __init__(self, get_response):
        self.get_response = get_response
    
    def __call__(self, request):
        # إضافة جميع الأعلام للطلب
        if request.user.is_authenticated:
            request.feature_flags = FeatureFlagService.get_all_flags(request.user)
        else:
            request.feature_flags = {}
        
        response = self.get_response(request)
        
        return response
```

---

## React Context

```typescript
// contexts/FeatureFlagsContext.tsx

'use client';

import { createContext, useContext, useEffect, useState, ReactNode } from 'react';

interface FeatureFlags {
  [key: string]: {
    enabled: boolean;
    type: string;
  };
}

interface FeatureFlagsContextType {
  flags: FeatureFlags;
  isEnabled: (flagName: string) => boolean;
  refresh: () => Promise<void>;
}

const FeatureFlagsContext = createContext<FeatureFlagsContextType>({
  flags: {},
  isEnabled: () => false,
  refresh: async () => {},
});

export function FeatureFlagsProvider({ children }: { children: ReactNode }) {
  const [flags, setFlags] = useState<FeatureFlags>({});

  const fetchFlags = async () => {
    try {
      const response = await fetch('/api/v1/feature-flags/', {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('access_token')}`,
        },
      });
      const data = await response.json();
      setFlags(data);
    } catch (error) {
      console.error('Failed to fetch feature flags:', error);
    }
  };

  useEffect(() => {
    fetchFlags();
  }, []);

  const isEnabled = (flagName: string): boolean => {
    return flags[flagName]?.enabled ?? false;
  };

  return (
    <FeatureFlagsContext.Provider value={{ flags, isEnabled, refresh: fetchFlags }}>
      {children}
    </FeatureFlagsContext.Provider>
  );
}

export function useFeatureFlag(flagName: string): boolean {
  const { isEnabled } = useContext(FeatureFlagsContext);
  return isEnabled(flagName);
}
```

---

## React Component

```typescript
// components/FeatureGate.tsx

import { useFeatureFlag } from '@/contexts/FeatureFlagsContext';
import { ReactNode } from 'react';

interface FeatureGateProps {
  flag: string;
  children: ReactNode;
  fallback?: ReactNode;
}

export function FeatureGate({ flag, children, fallback = null }: FeatureGateProps) {
  const isEnabled = useFeatureFlag(flag);
  
  if (!isEnabled) {
    return <>{fallback}</>;
  }
  
  return <>{children}</>;
}

// الاستخدام
// <FeatureGate flag="new_dashboard" fallback={<OldDashboard />}>
//   <NewDashboard />
// </FeatureGate>
```

---

## URLs API

```
# جلب جميع الأعلام
GET /api/v1/feature-flags/

# فحص علم معين
GET /api/v1/feature-flags/{name}/check/

# إنشاء/تعديل علم
POST /api/v1/feature-flags/
PUT /api/v1/feature-flags/{id}/

# toggle
POST /api/v1/feature-flags/{id}/toggle/

# إحصائيات
GET /api/v1/feature-flags/{id}/stats/
```

---

## ملخص

> **أعلام الميزات** تدعم: boolean، نسب مئوية، قوائم مستخدمين، خطط اشتراك، وشروط مخصصة. تشمل: Django Models + Service، Middleware، React Context + Components، تخزين مؤقت، وإحصائيات.
