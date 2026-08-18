# خطة هندسة التوافق التنظيمي (GDPR / CCPA / COPPA)

> تاريخ التوثيق: 18 أغسطس 2026
> الغرض: توثيق التصميم الهندسي والمعماري للتوافق مع لوائح حماية البيانات في منصة آفاق تكنولوجي.

---

## 1. الفكرة والهدف
ضمان التوافق مع لوائح حماية البيانات العالمية:
- **GDPR** (General Data Protection Regulation) — الاتحاد الأوروبي
- **CCPA** (California Consumer Privacy Act) — كاليفورنيا، الولايات المتحدة
- **COPPA** (Children's Online Privacy Protection Act) — حماية الأطفال تحت 13 سنة
- **PDPL** (Personal Data Protection Law) — المملكة العربية السعودية

---

## 2. المكونات التقنية

### أ. نماذج الموافقة (`apps/core/models.py`)
```python
class DataConsent(models.Model):
    """تسجيل موافقة المستخدم على معالجة بياناته"""
    CONSENT_TYPES = [
        ('data_processing', 'معالجة البيانات الشخصية'),
        ('marketing', 'التسويق المباشر'),
        ('analytics', 'التحليلات والإحصائيات'),
        ('third_party', 'مشاركة البيانات مع أطراف ثالثة'),
        ('children_data', 'بيانات الأطفال (COPPA)'),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='data_consents')
    consent_type = models.CharField(max_length=30, choices=CONSENT_TYPES)
    is_granted = models.BooleanField()
    ip_address = models.GenericIPAddressField()
    user_agent = models.TextField(blank=True)
    granted_at = models.DateTimeField(null=True, blank=True)
    revoked_at = models.DateTimeField(null=True, blank=True)
    version = models.CharField(max_length=10, default='1.0')  # إصدار السياسة

    class Meta:
        unique_together = [['user', 'consent_type', 'version']]
```

### ب. نموذج طلب حذف البيانات (Right to Erasure)
```python
class DataDeletionRequest(models.Model):
    """طلب حذف البيانات الشخصية (GDPR Article 17)"""
    STATUS_CHOICES = [
        ('pending', 'قيد المراجعة'),
        ('approved', 'تمت الموافقة'),
        ('rejected', 'مرفوض'),
        ('completed', 'تم التنفيذ'),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='deletion_requests')
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    reason = models.TextField(blank=True)
    requested_at = models.DateTimeField(auto_now_add=True)
    processed_at = models.DateTimeField(null=True, blank=True)
    processed_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, related_name='processed_deletions')
    data_exported = models.BooleanField(default=False)  # تصدير البيانات قبل الحذف
    notes = models.TextField(blank=True)

    class Meta:
        ordering = ['-requested_at']
```

### ج. نموذج سجل المعالجة (Processing Log)
```python
class DataProcessingLog(models.Model):
    """سجل جميع عمليات معالجة البيانات الشخصية"""
    PROCESSING_PURPOSES = [
        ('education', 'الغرض التعليمي'),
        ('communication', 'التواصل'),
        ('analytics', 'التحليلات'),
        ('legal', 'الالتزام القانوني'),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='processing_logs')
    purpose = models.CharField(max_length=30, choices=PROCESSING_PURPOSES)
    data_type = models.CharField(max_length=100)  # مثال: 'attendance', 'grades', 'personal_info'
    action = models.CharField(max_length=50)  # مثال: 'collect', 'store', 'share', 'delete'
    third_party = models.CharField(max_length=100, blank=True)  # الجهة الثالثة إن وجدت
    timestamp = models.DateTimeField(auto_now_add=True)
    ip_address = models.GenericIPAddressField()

    class Meta:
        ordering = ['-timestamp']
```

---

## 3. نقاط النهاية (API Endpoints)

```
# GDPR Endpoints
POST /api/v1/core/consent/                    # تسجيل موافقة
GET  /api/v1/core/consent/                    # عرض موافقاتي
POST /api/v1/core/deletion-request/           # طلب حذف البيانات
GET  /api/v1/core/deletion-request/status/    # حالة الطلب
POST /api/v1/core/data-export/                # تصدير البيانات (Data Portability)

# COPPA Endpoints
POST /api/v1/core/parental-consent/           # موافقة ولي الأمر (للأطفال < 13)
GET  /api/v1/core/parental-consent/           # عرض موافقات الأبناء

# Admin Endpoints
GET  /api/v1/core/admin/deletion-requests/    # إدارة طلبات الحذف
POST /api/v1/core/admin/deletion-requests/<id>/process/  # معالجة الطلب
GET  /api/v1/core/admin/processing-logs/      # سجلات المعالجة
```

---

## 4. واجهة المستخدم (Frontend)

### صفحة الإعدادات: `/profile/privacy`
```
┌─────────────────────────────────────────────────────┐
│  إعدادات الخصوصية والحماية                          │
├─────────────────────────────────────────────────────┤
│  ☑  الموافقة على معالجة البيانات الشخصية             │
│  ☐  الموافقة على التسويق المباشر                     │
│  ☑  الموافقة على التحليلات والإحصائيات               │
│  ☐  الموافقة على المشاركة مع أطراف ثالثة             │
├─────────────────────────────────────────────────────┤
│  [تصدير بياناتي]  [طلب حذف بياناتي]                  │
├─────────────────────────────────────────────────────┤
│  سجل النشاط:                                        │
│  • 18/08/2026 10:30 — تسجيل دخول من الرياض          │
│  • 17/08/2026 14:15 — تحديث الملف الشخصي            │
│  • 16/08/2026 09:00 — تسجيل حضور طالب              │
└─────────────────────────────────────────────────────┘
```

---

## 5. COPPA — حماية الأطفال (< 13 سنة)
- **التحقق من العمر**: عند التسجيل، إذا كان العمر < 13 سنة:
  1. يُطلب **موافقة ولي الأمر** عبر البريد الإلكتروني
  2. يُرسل البريد مع رابط تأكيد (صالح 48 ساعة)
  3. **لا يُسمح** بالتسجيل حتى تصل الموافقة
- **بيانات الأطفال**: لا تُشارك مع أطراف ثالثة أبداً
- **حقوق أولياء الأمور**: يمكنهم عرض وحذف بيانات أبناءهم في أي وقت

---

## 6. Right to Erasure (حق الحذف)
1. المستخدم يطلب حذف بياناته عبر `/core/deletion-request/`
2. المشرف يراجع الطلب (يُقبل أو يرفض مع السبب)
3. إذا قُبل:
   a. **تصدير البيانات** أولاً (GDPR Article 20 — Data Portability)
   b. **حذف البيانات الشخصية** من جميع الجداول
   c. **إبقاء السجلات المطلوبة قانونياً** (الفواتير، سجلات الدفع — لمدة 7 سنوات)
   d. **تحديث الحالة** إلى "completed"

---

## 7. البيانات المحفوظة قانونياً (لا تُحذف)
| البيانات | المدة | السبب القانوني |
|----------|-------|---------------|
| الفواتير وسجلات الدفع | 7 سنوات | قوانين الضرائب |
| سجلات المعالجة | 3 سنوات | GDPR Accountability |
| موافقات المستخدمين | طوال فترة العلاقة | GDPR Consent |
| سجلات الأمان (Login Attempts) | سنة واحدة | أمني |

---

## 8. التكامل مع Supabase RLS
- **Row Level Security** على جميع الجداول الحساسة
- كل مستخدم يرى بياناته فقط (باستثناء المشرفين)
- **RLS Policies** تمنع الوصول العرضي للبيانات بين المستخدمين
