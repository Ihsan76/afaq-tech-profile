# المراقبة والتنبيهات (Monitoring & Observability)

## نظرة عامة

> **مجاني أثناء البناء:** Sentry (5K errors/شهر) + UptimeRobot (50 monitors) + Railway Metrics — كافٍ لـ MVP. Grafana Cloud (مجاني) للأداء المتقدم.

نظام شامل للمراقبة يشمل Logging، Metrics، Tracing، وAlerting.

---

## المكونات

```
┌─────────────────────────────────────────────────────────────────┐
│                    Monitoring Stack                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────┐    ┌──────────────────┐                   │
│  │  Application     │    │  Prometheus      │                   │
│  │  Logs            │───►│  (Metrics)       │                   │
│  └──────────────────┘    └──────────────────┘                   │
│          │                       │                               │
│          ▼                       ▼                               │
│  ┌──────────────────┐    ┌──────────────────┐                   │
│  │  Loki            │    │  Grafana         │                   │
│  │  (Log Storage)   │───►│  (Dashboards)    │                   │
│  └──────────────────┘    └──────────────────┘                   │
│                                 │                               │
│                                 ▼                               │
│                          ┌──────────────────┐                   │
│                          │  AlertManager    │                   │
│                          │  (Notifications) │                   │
│                          └──────────────────┘                   │
│                                                                  │
│  ┌──────────────────┐    ┌──────────────────┐                   │
│  │  Sentry          │    │  UptimeRobot     │                   │
│  │  (Error Tracking)│    │  (Uptime)        │                   │
│  └──────────────────┘    └──────────────────┘                   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Prometheus Metrics

```python
# monitoring/metrics.py

from prometheus_client import (
    Counter, Histogram, Gauge, 
    generate_latest, CONTENT_TYPE_LATEST
)
from functools import wraps
import time


# ─── مقياس الطلبات ────────────────────────────────────
REQUEST_COUNT = Counter(
    'afaq_http_requests_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status_code', 'language']
)

REQUEST_LATENCY = Histogram(
    'afaq_http_request_duration_seconds',
    'HTTP request latency',
    ['method', 'endpoint'],
    buckets=[0.1, 0.25, 0.5, 1.0, 2.5, 5.0, 10.0]
)

# ─── مقياس قاعدة البيانات ──────────────────────────────
DB_QUERY_COUNT = Counter(
    'afaq_db_queries_total',
    'Total database queries',
    ['operation', 'table']
)

DB_QUERY_LATENCY = Histogram(
    'afaq_db_query_duration_seconds',
    'Database query latency',
    ['operation', 'table'],
    buckets=[0.01, 0.05, 0.1, 0.25, 0.5, 1.0]
)

# ─── مقياس الذكاء الاصطناعي ─────────────────────────────
AI_REQUEST_COUNT = Counter(
    'afaq_ai_requests_total',
    'Total AI requests',
    ['provider', 'model', 'status']
)

AI_REQUEST_LATENCY = Histogram(
    'afaq_ai_request_duration_seconds',
    'AI request latency',
    ['provider', 'model'],
    buckets=[1.0, 2.5, 5.0, 10.0, 30.0, 60.0]
)

AI_TOKEN_USAGE = Counter(
    'afaq_ai_tokens_total',
    'Total AI tokens used',
    ['provider', 'model', 'type']  # type: input/output
)

# ─── مقياس الدفع ──────────────────────────────────────
PAYMENT_COUNT = Counter(
    'afaq_payments_total',
    'Total payments',
    ['provider', 'status', 'currency']
)

PAYMENT_AMOUNT = Counter(
    'afaq_payment_amount_total',
    'Total payment amounts',
    ['provider', 'currency']
)

# ─── مقياس المستخدمين ──────────────────────────────────
ACTIVE_USERS = Gauge(
    'afaq_active_users',
    'Currently active users'
)

USER_REGISTRATIONS = Counter(
    'afaq_user_registrations_total',
    'Total user registrations',
    ['source']  # web, mobile, api
)

# ─── مقياس الموارد ──────────────────────────────────────
CPU_USAGE = Gauge(
    'afaq_cpu_usage_percent',
    'CPU usage percentage'
)

MEMORY_USAGE = Gauge(
    'afaq_memory_usage_bytes',
    'Memory usage in bytes'
)

DISK_USAGE = Gauge(
    'afaq_disk_usage_bytes',
    'Disk usage in bytes'
)


# ─── Decorators ─────────────────────────────────────────

def track_request_metrics(func):
    """تتبع مقاييس الطلبات"""
    @wraps(func)
    def wrapper(request, *args, **kwargs):
        start_time = time.time()
        
        response = func(request, *args, **kwargs)
        
        duration = time.time() - start_time
        
        REQUEST_COUNT.labels(
            method=request.method,
            endpoint=request.path,
            status_code=response.status_code,
            language=getattr(request, 'language', 'unknown'),
        ).inc()
        
        REQUEST_LATENCY.labels(
            method=request.method,
            endpoint=request.path,
        ).observe(duration)
        
        return response
    return wrapper


def track_db_query(operation: str, table: str):
    """تتبع استعلامات قاعدة البيانات"""
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            start_time = time.time()
            
            result = func(*args, **kwargs)
            
            duration = time.time() - start_time
            
            DB_QUERY_COUNT.labels(
                operation=operation,
                table=table,
            ).inc()
            
            DB_QUERY_LATENCY.labels(
                operation=operation,
                table=table,
            ).observe(duration)
            
            return result
        return wrapper
    return decorator


def track_ai_request(provider: str, model: str):
    """تتبع طلبات الذكاء الاصطناعي"""
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            start_time = time.time()
            
            try:
                result = func(*args, **kwargs)
                duration = time.time() - start_time
                
                AI_REQUEST_COUNT.labels(
                    provider=provider,
                    model=model,
                    status='success',
                ).inc()
                
                AI_REQUEST_LATENCY.labels(
                    provider=provider,
                    model=model,
                ).observe(duration)
                
                # تسجيل استخدام التوكنات
                if 'usage' in result:
                    AI_TOKEN_USAGE.labels(
                        provider=provider,
                        model=model,
                        type='input',
                    ).inc(result['usage'].get('prompt_tokens', 0))
                    
                    AI_TOKEN_USAGE.labels(
                        provider=provider,
                        model=model,
                        type='output',
                    ).inc(result['usage'].get('completion_tokens', 0))
                
                return result
                
            except Exception as e:
                duration = time.time() - start_time
                
                AI_REQUEST_COUNT.labels(
                    provider=provider,
                    model=model,
                    status='error',
                ).inc()
                
                AI_REQUEST_LATENCY.labels(
                    provider=provider,
                    model=model,
                ).observe(duration)
                
                raise
        return wrapper
    return decorator
```

---

## Django Logging Configuration

```python
# config/logging.py

LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    
    'formatters': {
        'verbose': {
            'format': '{levelname} {asctime} {module} {process:d} {thread:d} {message}',
            'style': '{',
        },
        'json': {
            '()': 'pythonjsonlogger.jsonlogger.JsonFormatter',
            'format': '%(asctime)s %(levelname)s %(name)s %(message)s',
        },
    },
    
    'filters': {
        'request_context': {
            '()': 'monitoring.filters.RequestContextFilter',
        },
    },
    
    'handlers': {
        'console': {
            'level': 'INFO',
            'class': 'logging.StreamHandler',
            'formatter': 'json',
        },
        'file': {
            'level': 'INFO',
            'class': 'logging.handlers.RotatingFileHandler',
            'filename': '/var/log/afaq/app.log',
            'maxBytes': 1024 * 1024 * 100,  # 100MB
            'backupCount': 10,
            'formatter': 'json',
        },
        'error_file': {
            'level': 'ERROR',
            'class': 'logging.handlers.RotatingFileHandler',
            'filename': '/var/log/afaq/error.log',
            'maxBytes': 1024 * 1024 * 50,  # 50MB
            'backupCount': 10,
            'formatter': 'json',
        },
        'ai_file': {
            'level': 'INFO',
            'class': 'logging.handlers.RotatingFileHandler',
            'filename': '/var/log/afaq/ai.log',
            'maxBytes': 1024 * 1024 * 50,
            'backupCount': 5,
            'formatter': 'json',
        },
        'payment_file': {
            'level': 'INFO',
            'class': 'logging.handlers.RotatingFileHandler',
            'filename': '/var/log/afaq/payments.log',
            'maxBytes': 1024 * 1024 * 50,
            'backupCount': 5,
            'formatter': 'json',
        },
        'sentry': {
            'level': 'ERROR',
            'class': 'sentry_sdk.integrations.logging.SentryHandler',
            'formatter': 'verbose',
        },
    },
    
    'loggers': {
        'django': {
            'handlers': ['console', 'file'],
            'level': 'INFO',
            'propagate': True,
        },
        'django.request': {
            'handlers': ['console', 'file', 'error_file'],
            'level': 'INFO',
            'propagate': False,
        },
        'ai': {
            'handlers': ['console', 'ai_file'],
            'level': 'INFO',
            'propagate': False,
        },
        'payments': {
            'handlers': ['console', 'payment_file'],
            'level': 'INFO',
            'propagate': False,
        },
        'monitoring': {
            'handlers': ['console', 'file'],
            'level': 'INFO',
            'propagate': False,
        },
    },
    
    'root': {
        'handlers': ['console', 'file', 'sentry'],
        'level': 'INFO',
    },
}
```

---

## Sentry Error Tracking

```python
# config/sentry.py

import sentry_sdk
from sentry_sdk.integrations.django import DjangoIntegration
from sentry_sdk.integrations.postgres import PostgresIntegration
from sentry_sdk.integrations.redis import RedisIntegration


def init_sentry():
    """تهيئة Sentry"""
    
    sentry_sdk.init(
        dsn="https://your-dsn@sentry.io/project-id",
        
        integrations=[
            DjangoIntegration(),
            PostgresIntegration(),
            RedisIntegration(),
        ],
        
        # نسبة عينات الأخطاء
        traces_sample_rate=0.1,
        
        # نسبة عينات الأداء
        profiles_sample_rate=0.1,
        
        # البيئة
        environment="production",
        
        # إصدار التطبيق
        release="afaq@1.0.0",
        
        # المستخدمين
        send_default_pii=True,
        
        # فلترة المسارات
        before_send=filter_sensitive_data,
        
        # تعليقات المستخدمين
        attach_stacktrace=True,
    )


def filter_sensitive_data(event, hint):
    """فلترة البيانات الحساسة"""
    
    # إخفاء كلمات المرور
    if 'request' in event and 'data' in event['request']:
        data = event['request']['data']
        for key in ['password', 'token', 'secret', 'credit_card']:
            if key in data:
                data[key] = '[FILTERED]'
    
    # إخفاء الـ IPs
    if 'request' in event and 'env' in event['request']:
        event['request']['env'].pop('REMOTE_ADDR', None)
    
    return event
```

---

## Grafana Dashboards

```json
// monitoring/grafana/dashboard.json

{
  "dashboard": {
    "title": "آفاق تكنولوجي - Dashboard",
    "tags": ["afaq", "production"],
    "timezone": "browser",
    "panels": [
      {
        "title": "طلبات API / دقيقة",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(afaq_http_requests_total[5m])",
            "legendFormat": "{{method}} {{endpoint}}"
          }
        ]
      },
      {
        "title": "متوسط وقت الاستجابة",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(afaq_http_request_duration_seconds_bucket[5m]))",
            "legendFormat": "P95"
          }
        ]
      },
      {
        "title": "المستخدمون النشطون",
        "type": "stat",
        "targets": [
          {
            "expr": "afaq_active_users",
            "legendFormat": "Active Users"
          }
        ]
      },
      {
        "title": "استخدام AI",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(afaq_ai_requests_total[5m])",
            "legendFormat": "{{provider}} {{model}}"
          }
        ]
      },
      {
        "title": "المدفوعات",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(afaq_payments_total[5m])",
            "legendFormat": "{{provider}} {{status}}"
          }
        ]
      }
    ]
  }
}
```

---

## Alert Rules

```yaml
# monitoring/alerts.yml

groups:
  - name: afaq_alerts
    rules:
      # ─── تنبيهات الأداء ──────────────────────────
      - alert: HighResponseTime
        expr: histogram_quantile(0.95, rate(afaq_http_request_duration_seconds_bucket[5m])) > 2
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "وقت الاستجابة مرتفع"
          description: "P95 uptime > 2 seconds for 5 minutes"
      
      - alert: HighErrorRate
        expr: rate(afaq_http_requests_total{status_code=~"5.."}[5m]) / rate(afaq_http_requests_total[5m]) > 0.05
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "معدل أخطاء مرتفع"
          description: "Error rate > 5% for 2 minutes"
      
      # ─── تنبيهات قاعدة البيانات ──────────────────
      - alert: HighDBLatency
        expr: histogram_quantile(0.95, rate(afaq_db_query_duration_seconds_bucket[5m])) > 0.5
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "بطء استعلامات قاعدة البيانات"
          description: "DB query P95 > 500ms for 5 minutes"
      
      - alert: DBConnectionPoolExhausted
        expr: django_db_connections_active / django_db_connections_max > 0.9
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "استنفاذ اتصالات قاعدة البيانات"
          description: "DB connection pool > 90% for 2 minutes"
      
      # ─── تنبيهات الذكاء الاصطناعي ─────────────────
      - alert: HighAILatency
        expr: histogram_quantile(0.95, rate(afaq_ai_request_duration_seconds_bucket[5m])) > 10
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "بطء طلبات الذكاء الاصطناعي"
          description: "AI request P95 > 10 seconds"
      
      - alert: AIErrorRateHigh
        expr: rate(afaq_ai_requests_total{status="error"}[5m]) / rate(afaq_ai_requests_total[5m]) > 0.1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "ارتفاع معدل أخطاء الذكاء الاصطناعي"
          description: "AI error rate > 10%"
      
      # ─── تنبيهات الموارد ──────────────────────────
      - alert: HighCPUUsage
        expr: afaq_cpu_usage_percent > 80
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "استخدام المعالج مرتفع"
          description: "CPU usage > 80% for 10 minutes"
      
      - alert: HighMemoryUsage
        expr: afaq_memory_usage_bytes / node_memory_MemTotal_bytes > 0.85
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "استخدام الذاكرة مرتفع"
          description: "Memory usage > 85%"
      
      - alert: DiskSpaceLow
        expr: afaq_disk_usage_bytes / node_filesystem_size_bytes < 0.15
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "مساحة القرص منخفضة"
          description: "Disk space < 15%"
      
      # ─── تنبيهات uptime ──────────────────────────
      - alert: ServiceDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "الخدمة معطلة"
          description: "Service is down for 1 minute"
```

---

## Sentry Alerts Configuration

```yaml
# monitoring/sentry_alerts.yml

# تنبيهات Sentry
alerts:
  - name: "New Issue"
    condition: "is:unresolved event.count:>1"
    action: "email"
    targets: ["dev-team@afaq.app"]
  
  - name: "Regression"
    condition: "is:unresolved event.count:>10"
    action: "slack"
    targets: ["#alerts-critical"]
  
  - name: "Performance Issue"
    condition: "is:unresolved issue.level:warning"
    action: "email"
    targets: ["dev-team@afaq.app"]
```

---

## Uptime Monitoring

```python
# monitoring/uptime.py

import requests
from datetime import datetime, timedelta


class UptimeChecker:
    """فحص uptime للخدمات"""
    
    SERVICES = [
        {
            'name': 'API Backend',
            'url': 'https://api.afaq.app/health/',
            'timeout': 10,
        },
        {
            'name': 'Frontend',
            'url': 'https://afaq.app',
            'timeout': 10,
        },
        {
            'name': 'WebSocket',
            'url': 'wss://ws.afaq.app/health/',
            'timeout': 10,
        },
        {
            'name': 'Admin Panel',
            'url': 'https://admin.afaq.app/health/',
            'timeout': 10,
        },
    ]
    
    @classmethod
    def check_all(cls) -> list:
        """فحص جميع الخدمات"""
        results = []
        
        for service in cls.SERVICES:
            result = cls.check_service(service)
            results.append(result)
        
        return results
    
    @classmethod
    def check_service(cls, service: dict) -> dict:
        """فحص خدمة محددة"""
        
        try:
            start_time = datetime.now()
            
            response = requests.get(
                service['url'],
                timeout=service['timeout']
            )
            
            duration = (datetime.now() - start_time).total_seconds()
            
            return {
                'name': service['name'],
                'url': service['url'],
                'status': 'up' if response.status_code == 200 else 'degraded',
                'status_code': response.status_code,
                'response_time': duration,
                'checked_at': datetime.now().isoformat(),
            }
            
        except requests.Timeout:
            return {
                'name': service['name'],
                'url': service['url'],
                'status': 'down',
                'error': 'Timeout',
                'checked_at': datetime.now().isoformat(),
            }
        except Exception as e:
            return {
                'name': service['name'],
                'url': service['url'],
                'status': 'down',
                'error': str(e),
                'checked_at': datetime.now().isoformat(),
            }
```

---

## Health Check API

```python
# monitoring/views.py

from rest_framework.views import APIView
from rest_framework.response import Response
from django.db import connection
import redis
import psutil


class HealthCheckView(APIView):
    """فحص صحة النظام"""
    permission_classes = []  # public
    
    def get(self, request):
        checks = {}
        
        # فحص قاعدة البيانات
        try:
            with connection.cursor() as cursor:
                cursor.execute("SELECT 1")
            checks['database'] = {'status': 'healthy'}
        except Exception as e:
            checks['database'] = {'status': 'unhealthy', 'error': str(e)}
        
        # فحص Redis
        try:
            r = redis.Redis(host='localhost', port=6379)
            r.ping()
            checks['redis'] = {'status': 'healthy'}
        except Exception as e:
            checks['redis'] = {'status': 'unhealthy', 'error': str(e)}
        
        # فحص الموارد
        checks['resources'] = {
            'cpu_percent': psutil.cpu_percent(interval=1),
            'memory_percent': psutil.virtual_memory().percent,
            'disk_percent': psutil.disk_usage('/').percent,
        }
        
        # حالة النظام العامة
        all_healthy = all(
            check.get('status') == 'healthy' 
            for check in checks.values() 
            if isinstance(check, dict) and 'status' in check
        )
        
        return Response({
            'status': 'healthy' if all_healthy else 'degraded',
            'checks': checks,
            'timestamp': datetime.now().isoformat(),
        })
```

---

## ملخص

> **المراقبة والتنبيهات** تشمل Prometheus (مقاييس)، Grafana (لوحات)، Loki (سجلات)، Sentry (أخطاء)، UptimeRobot (وقت التشغيل)، وتنبيهات آلية. تغطي: أداء API، قاعدة البيانات، الذكاء الاصطناعي، المدفوعات، الموارد، ووقت التشغيل.
