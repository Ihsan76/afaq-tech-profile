# التوافق مع اللوائح (Compliance & Privacy)

## نظرة عامة

المنصة مصممة للامتثال للوائح حماية البيانات العالمية مع مراعاة طبيعتها التعليمية للطلاب القاصرين.

---

## اللوائح المعمول بها

### 1. GDPR (اللائحة العامة لحماية البيانات) — الاتحاد الأوروبي

| البند | التفصيل | التنفيذ |
|-------|---------|---------|
| **الموافقة** | موافقة واضحة ومستنيرة | نموذج تسجيل واضح مع checkbox |
| **الحق في الوصول** | حق المستخدم في معرفة بياناته | صفحة "بياناتي" + تصدير JSON |
| **حق الحذف** | حق الحذف ("الانسياق") | زر "حذف الحساب" + تنفيذ خلال 30 يوم |
| **حق التصحيح** | تصحيح البيانات الخاطئة | تعديل الملف الشخصي |
| **حق النقل** | نقل البيانات لمنصة أخرى | تصدير بيانات بتنسيق قابل للنقل |
| **إخطار المخترقات** | إخطارAuthorities خلال 72 ساعة | نظام alerts + تدفق عمل |
| **محلل البيانات** | تعيين محلل بيانات | ملف شخصي فني |

### 2. COPPA (قانون حماية خصوصية الأطفال عبر الإنترنت) — الولايات المتحدة

| البند | التفصيل | التنفيذ |
|-------|---------|---------|
| **العمر** | الأطفال تحت 13 سنة | فحص العمر عند التسجيل |
| **موافقة الوالدين** | موافقة الوالدين المسبقة | بريد إلكتروني للوالدين + تأكيد |
**البيانات** | تقليل جمع البيانات | فقط البيانات الضرورية للمعالجة |
**المراقبة** | مراقبة المحتوى | فلترة المحتوى + مراجعة يدوية |
**الحذف** | حذف بيانات الطفل | حذف فوري عند طلب الوالدين |

### 3. CCPA (قانون خصوصية المستهلك في كاليفورنيا)

| البند | التفصيل |
|-------|---------|
| **عدم البيع** | عدم بيع البيانات الشخصية |
| **حق الاختيار** | إمكانية عدم المشاركة |
**التفضيلات** | إدارة تفضيلات الخصوصية

---

## نموذج التسجيل المتوافق

```typescript
// components/auth/CompliantRegisterForm.tsx

'use client';

import { useState } from 'react';

interface RegisterFormData {
  name: string;
  email: string;
  password: string;
  birthDate: string;
  role: 'student' | 'teacher';
  parentEmail?: string;
  privacyPolicy: boolean;
  termsOfService: boolean;
  marketingConsent: boolean;
  parentConsent?: boolean;
}

export function CompliantRegisterForm() {
  const [isMinor, setIsMinor] = useState(false);
  const [step, setStep] = useState(1);
  
  const handleBirthDateChange = (date: string) => {
    const birthDate = new Date(date);
    const today = new Date();
    const age = today.getFullYear() - birthDate.getFullYear();
    
    setIsMinor(age < 13);
  };
  
  return (
    <form>
      {step === 1 && (
        <>
          <Input name="name" label="الاسم الكامل" required />
          <Input name="email" label="البريد الإلكتروني" required />
          <Input 
            name="birthDate" 
            label="تاريخ الميلاد" 
            type="date"
            required 
            onChange={handleBirthDateChange}
          />
          
          {isMinor && (
            <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4">
              <p className="text-yellow-800">
                ⚠️ نظراً لكونك تحت 13 سنة، نحتاج موافقة ولي أمرك.
              </p>
              <Input 
                name="parentEmail" 
                label="بريد ولي الأمر" 
                type="email"
                required 
              />
            </div>
          )}
          
          <Button onClick={() => setStep(2)}>التالي</Button>
        </>
      )}
      
      {step === 2 && (
        <>
          <Checkbox 
            name="privacyPolicy" 
            label={
              <span>
                أقر بـ <Link href="/privacy">سياسة الخصوصية</Link> و<a href="/privacy/gdpr">لائحة GDPR</a>
              </span>
            }
            required
          />
          
          <Checkbox 
            name="termsOfService" 
            label={
              <span>
                أقر بـ <Link href="/terms">شروط الخدمة</Link>
              </span>
            }
            required
          />
          
          <Checkbox 
            name="marketingConsent" 
            label="أوافق على تلقي رسائل تسويقية (اختياري)"
          />
          
          {isMinor && (
            <Checkbox 
              name="parentConsent" 
              label="لدي موافقة ولي أمري على التسجيل"
              required
            />
          )}
          
          <Button type="submit">تسجيل</Button>
        </>
      )}
    </form>
  );
}
```

---

## صفحة إدارة البيانات الشخصية

```typescript
// app/[locale]/settings/privacy/page.tsx

export function PrivacySettings() {
  return (
    <div>
      <h1>إدارة الخصوصية والبيانات</h1>
      
      {/* قسم البيانات الشخصية */}
      <Section title="بياناتي الشخصية">
        <p>يمكنك عرض وتصدير جميع بياناتك الشخصية.</p>
        <Button variant="outline">
          <DownloadIcon /> تصدير بياناتي (JSON)
        </Button>
        <Button variant="destructive">
          <TrashIcon /> حذف حسابي نهائياً
        </Button>
      </Section>
      
      {/* قسم التفضيلات */}
      <Section title="تفضيلات الخصوصية">
        <Toggle 
          label="السماح بالتحليلات" 
          description="المساعدة في تحسين المنصة"
        />
        <Toggle 
          label="السماح بالـ Cookies" 
          description="تحسين تجربة التصفح"
        />
        <Toggle 
          label="إظهار الملف الشخصي للآخرين"
        />
      </Section>
      
      {/* قسم الأنشطة */}
      <Section title="النشاط الأخير">
        <ActivityLog />
      </Section>
      
      {/* قسم أجهزة الدخول */}
      <Section title="أجهزة تسجيل الدخول">
        <ActiveSessions />
      </Section>
      
      {/* قسم التصدير */}
      <Section title="تصدير البيانات">
        <ExportForm />
      </Section>
    </div>
  );
}
```

---

## API إدارة الخصوصية

```
# جلب جميع بيانات المستخدم
GET /api/v1/privacy/data/

# تصدير البيانات
POST /api/v1/privacy/export/
{
  "format": "json"  // json, csv, pdf
}

# حذف الحساب
POST /api/v1/privacy/delete-request/
{
  "reason": "لا أريد استخدام المنصة",
  "confirm_email": true
}

# طلب حذف بيانات الطفل (الوالد)
POST /api/v1/privacy/child-delete/
{
  "parent_email": "parent@example.com",
  "child_email": "child@example.com",
  "reason": "حذف حساب الطفل"
}

# جلب سجل النشاط
GET /api/v1/privacy/activity-log/

# جلب الأجهزة النشطة
GET /api/v1/privacy/active-sessions/

# إلغاء جلسة
DELETE /api/v1/privacy/sessions/{id}/
```

---

## سياسة الخصوصية متعددة اللغات

```python
# privacy/models.py

from django.db import models


class PrivacyPolicy(models.Model):
    """سياسة الخصوصية"""
    
    class Version(models.TextChoices):
        V1 = '1.0', 'الإصدار 1.0'
        V2 = '2.0', 'الإصدار 2.0'
    
    version = models.CharField(max_length=10, choices=Version.choices)
    effective_date = models.DateField()
    is_active = models.BooleanField(default=True)
    
    # المحتوى بعدة لغات
    content_ar = models.TextField(verbose_name='المحتوى بالعربية')
    content_en = models.TextField(verbose_name='المحتوى بالإنجليزية')
    content_fr = models.TextField(verbose_name='المحتوى بالفرنسية')
    content_tr = models.TextField(verbose_name='المحتوى بالتركية')
    content_ur = models.TextField(verbose_name='المحتوى بالأوردو')
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name = 'سياسة خصوصية'
        verbose_name_plural = 'سياسات الخصوصية'
        ordering = ['-effective_date']


class UserConsent(models.Model):
    """سجل موافقات المستخدمين"""
    
    class ConsentType(models.TextChoices):
        PRIVACY = 'privacy_policy', 'سياسة الخصوصية'
        TERMS = 'terms_of_service', 'شروط الخدمة'
        MARKETING = 'marketing', 'الرسائل التسويقية'
        ANALYTICS = 'analytics', 'التحليلات'
        COOKIES = 'cookies', 'ملفات تعريف الارتباط'
        PARENT = 'parent_consent', 'موافقة الوالدين'
    
    user = models.ForeignKey('users.User', on_delete=models.CASCADE, related_name='consents')
    consent_type = models.CharField(max_length=20, choices=ConsentType.choices)
    
    # حالة الموافقة
    is_granted = models.BooleanField(default=False)
    
    # معلومات إضافية
    ip_address = models.GenericIPAddressField(null=True, blank=True)
    user_agent = models.TextField(blank=True)
    version = models.CharField(max_length=10, help_text='إصدار السياسة')
    
    # التوقيت
    granted_at = models.DateTimeField(null=True, blank=True)
    revoked_at = models.DateTimeField(null=True, blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name = 'موافقة مستخدم'
        verbose_name_plural = 'موافقات المستخدمين'
        unique_together = ['user', 'consent_type']
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.user.username}: {self.consent_type} = {self.is_granted}"


class DataExportRequest(models.Model):
    """طلبات تصدير البيانات"""
    
    class Status(models.TextChoices):
        PENDING = 'pending', 'قيد الانتظار'
        PROCESSING = 'processing', 'قيد المعالجة'
        COMPLETED = 'completed', 'مكتمل'
        FAILED = 'failed', 'فاشل'
    
    user = models.ForeignKey('users.User', on_delete=models.CASCADE, related_name='export_requests')
    status = models.CharField(max_length=15, choices=Status.choices, default=Status.PENDING)
    format = models.CharField(max_length=10, default='json')  # json, csv, pdf
    
    # الملف
    file_url = models.URLField(blank=True)
    file_size = models.IntegerField(default=0)
    expires_at = models.DateTimeField(null=True, blank=True, help_text='انتهاء صلاحية الملف')
    
    # التوقيت
    requested_at = models.DateTimeField(auto_now_add=True)
    completed_at = models.DateTimeField(null=True, blank=True)
    
    class Meta:
        verbose_name = 'طلب تصدير'
        verbose_name_plural = 'طلبات التصدير'
        ordering = ['-requested_at']


class AccountDeletionRequest(models.Model):
    """طلبات حذف الحساب"""
    
    class Status(models.TextChoices):
        PENDING = 'pending', 'قيد الانتظار'
        CONFIRMED = 'confirmed', 'مؤكد'
        PROCESSING = 'processing', 'قيد المعالجة'
        COMPLETED = 'completed', 'مكتمل'
    
    user = models.ForeignKey('users.User', on_delete=models.CASCADE, related_name='deletion_requests')
    status = models.CharField(max_length=15, choices=Status.choices, default=Status.PENDING)
    
    # السبب
    reason = models.TextField(blank=True)
    
    # التأكيد
    confirmation_sent = models.BooleanField(default=False)
    confirmation_token = models.CharField(max_length=255, blank=True)
    
    # التوقيت
    requested_at = models.DateTimeField(auto_now_add=True)
    confirmed_at = models.DateTimeField(null=True, blank=True)
    scheduled_deletion_at = models.DateTimeField(null=True, blank=True)
    completed_at = models.DateTimeField(null=True, blank=True)
    
    class Meta:
        verbose_name = 'طلب حذف'
        verbose_name_plural = 'طلبات الحذف'
        ordering = ['-requested_at']


class ChildAccount(models.Model):
    """حسابات الأطفال (تحت 13 سنة)"""
    
    user = models.OneToOneField('users.User', on_delete=models.CASCADE, related_name='child_profile')
    parent_email = models.EmailField(help_text='بريد ولي الأمر')
    parent_verified = models.BooleanField(default=False)
    
    # بيانات ولي الأمر
    parent_name = models.CharField(max_length=255, blank=True)
    parent_phone = models.CharField(max_length=20, blank=True)
    
    # القيود
    data_collection_consent = models.BooleanField(default=False, help_text='موافقة جمع البيانات')
    marketing_consent = models.BooleanField(default=False, help_text='موافقة التسويق')
    
    # التحقق
    verification_token = models.CharField(max_length=255, blank=True)
    verified_at = models.DateTimeField(null=True, blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name = 'حساب طفل'
        verbose_name_plural = 'حسابات الأطفال'
    
    def __str__(self):
        return f"Child: {self.user.username} (Parent: {self.parent_email})"
```

---

## إخطار المخترقات

```python
# privacy/breach.py

from django.core.mail import send_mail
from django.template.loader import render_to_string
from django.utils import timezone
from datetime import timedelta


class BreachNotifier:
    """نظام إخطار المخترقات"""
    
    @classmethod
    def notify_authorities(cls, breach_data: dict):
        """إخطار Authorities خلال 72 ساعة"""
        
        # 1. تسجيل المخترقة
        breach = cls.log_breach(breach_data)
        
        # 2. إخطار فريق الأمان
        cls.notify_security_team(breach)
        
        # 3. إخطار المستخدمين المتأثرين
        cls.notify_affected_users(breach)
        
        # 4. إخطار Authorities (إن لزم)
        if cls.requires_authority_notification(breach):
            cls.notify_data_protection_authority(breach)
        
        return breach
    
    @classmethod
    def log_breach(cls, data: dict):
        """تسجيل المخترقة"""
        from .models import SecurityBreach
        
        return SecurityBreach.objects.create(
            description=data['description'],
            severity=data['severity'],  # low, medium, high, critical
            affected_users_count=data.get('affected_count', 0),
            data_types_affected=data.get('data_types', []),
            detected_at=timezone.now(),
        )
    
    @classmethod
    def notify_security_team(cls, breach):
        """إخطار فريق الأمان"""
        send_mail(
            subject=f'⚠️ Security Breach Detected: {breach.severity}',
            message=f'''
            Security Breach Detected
            
            Severity: {breach.severity}
            Description: {breach.description}
            Affected Users: {breach.affected_users_count}
            Detected At: {breach.detected_at}
            
            Please investigate immediately.
            ''',
            from_email='security@afaq.app',
            recipient_list=['security-team@afaq.app'],
        )
    
    @classmethod
    def notify_affected_users(cls, breach):
        """إخطار المستخدمين المتأثرين"""
        affected_users = cls.get_affected_users(breach)
        
        for user in affected_users:
            # إرسال بريد إلكتروني
            cls.send_breach_email(user, breach)
            
            # إرسال إشعار داخل النظام
            cls.send_in_app_notification(user, breach)
    
    @classmethod
    def send_breach_email(cls, user, breach):
        """إرسال بريد إلكتروني للمستخدم"""
        subject = 'إخطار بأمني - خطوة أمان مطلوبة'
        
        # استخدام القالب المناسب حسب اللغة
        template = f'emails/breach_notification_{user.ui_language}.html'
        
        html_message = render_to_string(template, {
            'user': user,
            'breach': breach,
            'actions_taken': cls.get_actions_taken(breach),
            'recommended_actions': cls.get_recommended_actions(breach),
        })
        
        send_mail(
            subject=subject,
            message='',
            from_email='security@afaq.app',
            recipient_list=[user.email],
            html_message=html_message,
        )
    
    @classmethod
    def requires_authority_notification(cls, breach):
        """هل يتطلب إخطار Authorities؟"""
        # GDPR: إذا تأثر أكثر من 1000 مستخدم
        if breach.affected_users_count > 1000:
            return True
        
        # إذا كان الخطأ حرج (high/critical)
        if breach.severity in ['high', 'critical']:
            return True
        
        return False
    
    @classmethod
    def notify_data_protection_authority(cls, breach):
        """إخطار هيئة حماية البيانات"""
        # GDPR: إخطار خلال 72 ساعة
        # TODO: ربط مع API هيئة حماية البيانات
        pass
    
    @classmethod
    def get_actions_taken(cls, breach):
        """الإجراءات المتخذة"""
        return [
            'تم تغيير كلمات المرور للمستخدمين المتأثرين',
            'تم إصدار tokens جديدة',
            'تم فتح تحقيق داخلي',
        ]
    
    @classmethod
    def get_recommended_actions(cls, breach):
        """الإجراءات الموصى بها للمستخدم"""
        return [
            'غيّر كلمة المرور الخاصة بك فوراً',
            'فعّل المصادقة الثنائية',
            'راجع نشاط حسابك الأخير',
        ]
```

---

## ملخص

> **التوافق مع اللوائح** يشمل GDPR وCCPA وCOPPA. المكونات: نموذج تسجيل متوافق، إدارة البيانات الشخصية، طلبات التصدير والحذف، حسابات الأطفال مع موافقة الوالدين، إخطار المخترقات، وسياسة خصوصية متعددة اللغات.
