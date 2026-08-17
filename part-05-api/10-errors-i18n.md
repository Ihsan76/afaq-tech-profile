# معالجة الأخطاء متعددة اللغات (Multi-language Error Handling)

## نظرة عامة

جميع رسائل الخطأ في المنصة تُرجع بلغة المستخدم، سواء كانت أخطاء في Frontend أو Backend أو API.

---

## مبدأ التصميم

```
المستخدم يرسل طلب
    ↓
النظام يكشف اللغة من:
├── Accept-Language header (API)
├── locale في URL (Frontend)
└── ui_language في الحساب
    ↓
رسائل الخطأ تُرجع باللغة المكتشفة
```

---

## Backend: رسائل الخطأ بلغات متعددة

### نموذج رسائل الخطأ

```python
# errors/messages.py

ERROR_MESSAGES = {
    'ar': {
        'not_found': 'العنصر غير موجود',
        'unauthorized': 'غير مصرح لك بالوصول',
        'forbidden': 'ليس لديك صلاحية对此',
        'validation_error': 'خطأ في البيانات المدخلة',
        'server_error': 'خطأ في الخادم، يرجى المحاولة لاحقاً',
        'rate_limit': 'لقد تجاوزت الحد المسموح، يرجى الانتظار',
        'invalid_email': 'البريد الإلكتروني غير صالح',
        'email_exists': 'البريد الإلكتروني مسجل مسبقاً',
        'weak_password': 'كلمة المرور ضعيفة، يرجى استخدام 8 أحرف على الأقل',
        'invalid_credentials': 'بيانات الدخول غير صحيحة',
        'account_locked': 'تم إغلاق الحساب مؤقتاً',
        'subscription_required': 'يتطلب اشتراكاً للمتابعة',
        'quota_exceeded': 'لقد تجاوزت الحد المسموح',
    },
    'en': {
        'not_found': 'Resource not found',
        'unauthorized': 'Unauthorized access',
        'forbidden': 'You do not have permission',
        'validation_error': 'Validation error',
        'server_error': 'Server error, please try again later',
        'rate_limit': 'Rate limit exceeded, please wait',
        'invalid_email': 'Invalid email address',
        'email_exists': 'Email already registered',
        'weak_password': 'Weak password, use at least 8 characters',
        'invalid_credentials': 'Invalid credentials',
        'account_locked': 'Account temporarily locked',
        'subscription_required': 'Subscription required',
        'quota_exceeded': 'Quota exceeded',
    },
    'fr': {
        'not_found': 'Ressource non trouvée',
        'unauthorized': 'Accès non autorisé',
        'forbidden': 'Vous n\'avez pas la permission',
        'validation_error': 'Erreur de validation',
        'server_error': 'Erreur serveur, veuillez réessayer plus tard',
        'rate_limit': 'Limite de débit dépassée, veuillez patienter',
        'invalid_email': 'Adresse email invalide',
        'email_exists': 'Email déjà enregistré',
        'weak_password': 'Mot de passe faible, utilisez au moins 8 caractères',
        'invalid_credentials': 'Identifiants invalides',
        'account_locked': 'Compte temporairement verrouillé',
        'subscription_required': 'Abonnement requis',
        'quota_exceeded': 'Quota dépassé',
    },
    'tr': {
        'not_found': 'Kaynak bulunamadı',
        'unauthorized': 'Yetkisiz erişim',
        'forbidden': 'İzininiz yok',
        'validation_error': 'Doğrulama hatası',
        'server_error': 'Sunucu hatası, lütfen daha sonra tekrar deneyin',
        'rate_limit': 'Hız limiti aşıldı, lütfen bekleyin',
        'invalid_email': 'Geçersiz e-posta adresi',
        'email_exists': 'E-posta zaten kayıtlı',
        'weak_password': 'Zayıf şifre, en az 8 karakter kullanın',
        'invalid_credentials': 'Geçersiz kimlik bilgileri',
        'account_locked': 'Hesap geçici olarak kilitlendi',
        'subscription_required': 'Abonelik gerekli',
        'quota_exceeded': 'Kota aşıldı',
    },
    'ur': {
        'not_found': 'مواد نہیں ملا',
        'unauthorized': 'غیر مجاز رسائی',
        'forbidden': 'آپ کو اجازت نہیں ہے',
        'validation_error': 'تائید کی خرابی',
        'server_error': 'سرور میں خرابی، براہ کرم بعد میں دوبارہ کوشش کریں',
        'rate_limit': 'درجۂ تاریخ کی حد پار ہو گئی، براہ کرم انتظار کریں',
        'invalid_email': 'غلط ای میل ایڈریس',
        'email_exists': 'ای میل پہلے سے رجسٹرڈ ہے',
        'weak_password': 'کمزور پاس ورڈ، کم از کم 8 حروف استعمال کریں',
        'invalid_credentials': 'غلط اسناد',
        'account_locked': 'اکاؤنٹ عارضی طور پر بند ہے',
        'subscription_required': 'سبسکرپشن درکار ہے',
        'quota_exceeded': 'کوٹا پار ہو گیا',
    },
    'es': {
        'not_found': 'Recurso no encontrado',
        'unauthorized': 'Acceso no autorizado',
        'forbidden': 'No tienes permiso',
        'validation_error': 'Error de validación',
        'server_error': 'Error del servidor, por favor intente de nuevo',
        'rate_limit': 'Límite de velocidad excedido, por favor espere',
        'invalid_email': 'Correo electrónico inválido',
        'email_exists': 'Correo ya registrado',
        'weak_password': 'Contraseña débil, use al menos 8 caracteres',
        'invalid_credentials': 'Credenciales inválidas',
        'account_locked': 'Cuenta temporalmente bloqueada',
        'subscription_required': 'Suscripción requerida',
        'quota_exceeded': 'Cuota excedida',
    },
    'de': {
        'not_found': 'Ressource nicht gefunden',
        'unauthorized': 'Unbefugter Zugriff',
        'forbidden': 'Keine Berechtigung',
        'validation_error': 'Validierungsfehler',
        'server_error': 'Serverfehler, bitte versuchen Sie es später erneut',
        'rate_limit': 'Rate-Limit überschritten, bitte warten',
        'invalid_email': 'Ungültige E-Mail-Adresse',
        'email_exists': 'E-Mail bereits registriert',
        'weak_password': 'Schwaches Passwort, verwenden Sie mindestens 8 Zeichen',
        'invalid_credentials': 'Ungültige Anmeldedaten',
        'account_locked': 'Konto vorübergehend gesperrt',
        'subscription_required': 'Abonnement erforderlich',
        'quota_exceeded': 'Kontingent überschritten',
    },
    'id': {
        'not_found': 'Sumber tidak ditemukan',
        'unauthorized': 'Akses tidak sah',
        'forbidden': 'Anda tidak memiliki izin',
        'validation_error': 'Kesalahan validasi',
        'server_error': 'Kesalahan server, silakan coba lagi nanti',
        'rate_limit': 'Batas laju terlampaui, silakan tunggu',
        'invalid_email': 'Alamat email tidak valid',
        'email_exists': 'Email sudah terdaftar',
        'weak_password': 'Kata sandi lemah, gunakan minimal 8 karakter',
        'invalid_credentials': 'Kredensial tidak valid',
        'account_locked': 'Akun sementara dikunci',
        'subscription_required': 'Langganan diperlukan',
        'quota_exceeded': 'Kuota terlampaui',
    },
    'bn': {
        'not_found': 'রিসোর্স পাওয়া যায়নি',
        'unauthorized': 'অননুমোদিত প্রবেশ',
        'forbidden': 'আপনার অনুমতি নেই',
        'validation_error': 'বৈধতা ত্রুটি',
        'server_error': 'সার্ভার ত্রুটি, অনুগ্রহ করে পরে আবার চেষ্টা করুন',
        'rate_limit': 'হার সীমা অতিক্রান্ত, অনুগ্রহ করে অপেক্ষা করুন',
        'invalid_email': 'অবৈধ ইমেইল ঠিকানা',
        'email_exists': 'ইমেইল ইতিমধ্যে নিবন্ধিত',
        'weak_password': 'দুর্বল পাসওয়ার্ড, কমপক্ষে 8 অক্ষর ব্যবহার করুন',
        'invalid_credentials': 'অবৈধ শংসাপত্র',
        'account_locked': 'অ্যাকাউন্ট অস্থায়ীভাবে বন্ধ',
        'subscription_required': 'সাবস্ক্রিপশন প্রয়োজন',
        'quota_exceeded': 'কোটা অতিক্রান্ত',
    },
}


def get_error_message(code: str, locale: str = 'ar') -> str:
    """جلب رسالة الخطأ باللغة المطلوبة"""
    messages = ERROR_MESSAGES.get(locale, ERROR_MESSAGES['en'])
    return messages.get(code, ERROR_MESSAGES['en'].get(code, 'Unknown error'))
```

---

## API Response Format

### تنسيق الخطأ الموحد

```python
# errors/exceptions.py

from rest_framework.views import exception_handler
from rest_framework.response import Response
from rest_framework import status


def custom_exception_handler(exc, context):
    """معالج الأخطاء المخصص مع دعم تعدد اللغات"""
    
    # كشف اللغة من الطلب
    request = context.get('request')
    locale = detect_language(request)
    
    response = exception_handler(exc, context)
    
    if response is not None:
        error_code = get_error_code(exc)
        message = get_error_message(error_code, locale)
        
        response.data = {
            'error': {
                'code': error_code,
                'message': message,
                'details': response.data if isinstance(response.data, dict) else None,
            },
            'locale': locale,
        }
    
    return response


def detect_language(request) -> str:
    """كشف اللغة من الطلب"""
    if request is None:
        return 'en'
    
    # 1. فحص Accept-Language header
    accept_language = request.META.get('HTTP_ACCEPT_LANGUAGE', '')
    if accept_language:
        for lang in accept_language.split(','):
            lang_code = lang.split(';')[0].split('-')[0].lower()
            if lang_code in ['ar', 'en', 'fr', 'tr', 'ur', 'es', 'de', 'id', 'bn']:
                return lang_code
    
    # 2. فحص المستخدم المسجل
    if hasattr(request, 'user') and request.user.is_authenticated:
        return getattr(request.user, 'ui_language', 'en')
    
    return 'en'
```

---

## أمثلة على الاستجابات

### خطأ 404

```json
{
  "error": {
    "code": "not_found",
    "message": "العنصر غير موجود"
  },
  "locale": "ar"
}
```

### خطأ 401

```json
{
  "error": {
    "code": "unauthorized",
    "message": "غير مصرح لك بالوصول"
  },
  "locale": "ar"
}
```

### خطأ 422 (Validation)

```json
{
  "error": {
    "code": "validation_error",
    "message": "خطأ في البيانات المدخلة",
    "details": {
      "email": ["البريد الإلكتروني غير صالح"],
      "password": ["كلمة المرور ضعيفة، يرجى استخدام 8 أحرف على الأقل"]
    }
  },
  "locale": "ar"
}
```

### خطأ 429 (Rate Limit)

```json
{
  "error": {
    "code": "rate_limit",
    "message": "لقد تجاوزت الحد المسموح، يرجى الانتظار"
  },
  "locale": "ar",
  "retry_after": 60
}
```

---

## Frontend: معالجة الأخطاء

### Hook موحد لمعالجة الأخطاء

```typescript
// hooks/use-error-handler.ts

import { useLocale } from 'next-intl';

interface ApiError {
  error: {
    code: string;
    message: string;
    details?: Record<string, string[]>;
  };
  locale: string;
}

export function useErrorHandler() {
  const locale = useLocale();
  
  const handleError = (error: any): string => {
    // خطأ من API
    if (error?.error?.code) {
      return error.error.message;
    }
    
    // خطأ شبكة
    if (error?.name === 'NetworkError') {
      return getNetworkErrorMessage(locale);
    }
    
    // خطأ غير معروف
    return getUnknownErrorMessage(locale);
  };
  
  const getNetworkErrorMessage = (locale: string): string => {
    const messages: Record<string, string> = {
      ar: 'خطأ في الاتصال بالشبكة',
      en: 'Network connection error',
      fr: 'Erreur de connexion réseau',
      tr: 'Ağ bağlantı hatası',
      ur: 'نیٹ ورک کنکشن میں خرابی',
      es: 'Error de conexión de red',
      de: 'Netzwerkverbindungsfehler',
      id: 'Kesalahan koneksi jaringan',
      bn: 'নেটওয়ার্ক সংযোগ ত্রুটি',
    };
    return messages[locale] || messages['en'];
  };
  
  const getUnknownErrorMessage = (locale: string): string => {
    const messages: Record<string, string> = {
      ar: 'حدث خطأ غير متوقع',
      en: 'An unexpected error occurred',
      fr: 'Une erreur inattendue s\'est produite',
      tr: 'Beklenmeyen bir hata oluştu',
      ur: 'ایک غیر متوقع خرابی ہوئی',
      es: 'Ocurrió un error inesperado',
      de: 'Ein unerwarteter Fehler ist aufgetreten',
      id: 'Terjadi kesalahan tak terduga',
      bn: 'একটি অপ্রত্যাশিত ত্রুটি ঘটেছে',
    };
    return messages[locale] || messages['en'];
  };
  
  return { handleError };
}
```

### مكون عرض الخطأ

```tsx
// components/ErrorMessage.tsx

'use client';

import { useLocale } from 'next-intl';

interface ErrorMessageProps {
  code: string;
  details?: Record<string, string[]>;
  onRetry?: () => void;
}

export function ErrorMessage({ code, details, onRetry }: ErrorMessageProps) {
  const locale = useLocale();
  const message = getErrorTranslation(code, locale);
  
  return (
    <div className="rounded-lg bg-red-50 border border-red-200 p-4">
      <div className="flex items-center">
        <div className="flex-shrink-0">
          <svg className="h-5 w-5 text-red-400" viewBox="0 0 20 20" fill="currentColor">
            <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clipRule="evenodd" />
          </svg>
        </div>
        <div className="ml-3">
          <h3 className="text-sm font-medium text-red-800">{message}</h3>
          {details && (
            <div className="mt-2 text-sm text-red-700">
              <ul className="list-disc space-y-1">
                {Object.entries(details).map(([field, errors]) => (
                  <li key={field}>{errors.join(', ')}</li>
                ))}
              </ul>
            </div>
          )}
        </div>
      </div>
      {onRetry && (
        <div className="mt-4">
          <button
            onClick={onRetry}
            className="text-sm font-medium text-red-800 hover:text-red-600"
          >
            {locale === 'ar' ? 'إعادة المحاولة' : 'Retry'}
          </button>
        </div>
      )}
    </div>
  );
}
```

---

## Toast Notifications

```typescript
// lib/toast.ts

import toast from 'react-hot-toast';

export function showErrorToast(code: string, locale: string = 'ar') {
  const message = getErrorTranslation(code, locale);
  
  toast.error(message, {
    duration: 4000,
    position: locale === 'ar' ? 'top-left' : 'top-right',
    style: {
      direction: locale === 'ar' ? 'rtl' : 'ltr',
    },
  });
}

export function showSuccessToast(code: string, locale: string = 'ar') {
  const message = getSuccessTranslation(code, locale);
  
  toast.success(message, {
    duration: 3000,
    position: locale === 'ar' ? 'top-left' : 'top-right',
    style: {
      direction: locale === 'ar' ? 'rtl' : 'ltr',
    },
  });
}
```

---

## تسجيل الأخطاء

```python
# errors/logging.py

import logging
from django.utils import timezone

logger = logging.getLogger('errors')


def log_error(error_code: str, locale: str, request=None, details=None):
    """تسجيل الخطأ مع معلومات اللغة"""
    
    extra_data = {
        'error_code': error_code,
        'locale': locale,
        'timestamp': timezone.now().isoformat(),
    }
    
    if request:
        extra_data.update({
            'ip_address': get_client_ip(request),
            'user_agent': request.META.get('HTTP_USER_AGENT', ''),
            'path': request.path,
            'method': request.method,
            'user_id': getattr(request.user, 'id', None),
        })
    
    if details:
        extra_data['details'] = details
    
    logger.error(f"Error: {error_code}", extra=extra_data)


def get_client_ip(request):
    """جلب IP العميل"""
    x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
    if x_forwarded_for:
        return x_forwarded_for.split(',')[0]
    return request.META.get('REMOTE_ADDR')
```

---

## ملخص

> **معالجة الأخطاء متعددة اللغات** تضمن أن المستخدم يرى رسائل خطأ بلغته. المكونات: قاعدة بيانات رسائل الخطأ لكل لغة، كشف اللغة من `Accept-Language` header، تنسيق استجابة موحد، وتواريخ وتنبيهات بلغة المستخدم. جميع الأخطاء تُسجل مع معلومات اللغة للتحليل.
