# خطة هندسة نظام النطق النصي الحقيقي (TTS - Text-to-Speech)

> تاريخ التوثيق: 18 أغسطس 2026
> الغرض: توثيق التصميم الهندسي والمعماري لنظام النطق النصي الحقيقي (TTS) في منصة آفاق تكنولوجي.

---

## 1. الفكرة والهدف
توفير ميزة تحويل النص إلى كلام طبيعي (TTS) للمحتوى التعليمي في المنصة، بما يشمل:
- **قراءة الدروس بصوت عالٍ** للطلابבעלי صعوبات التعلم أو من يفضلون الاستماع.
- **توليد تعليقات صوتية** على الواجبات من المعلمين.
- **تحويل التقارير الأسبوعية** إلى ملفات صوتية لأولياء الأمور.
- **دعم 10 لغات** (العربية، الإنجليزية، الفرنسية، التركية، الأوردو، الإسبانية، الألمانية، الإندونيسية، البنغالية، الفارسية).

---

## 2. المكونات التقنية

### أ. مزودات TTS (Multi-Provider)
| المزود | الأولوية | المميزات | التكلفة |
|--------|----------|----------|---------|
| **Google Gemini TTS** | 1 (افتراضي) | مدمج في `google-genai`، دعم العربية ممتاز، مجاني جزئياً | $4/1M chars |
| **ElevenLabs** | 2 (بديل) | أصوات طبيعية جداً، custom voices، barge-in | $5/100K chars |
| **Edge TTS** | 3 (مجاني) | مجاني بالكامل، جودة مقبولة، دعم 75 لغة | مجاني |

### ب. نموذج البيانات (`apps/core/models.py`)
```python
class VoiceSettings(models.Model):
    """إعدادات TTS المخصصة لكل مستخدم"""
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='voice_settings')
    provider = models.CharField(max_length=20, choices=PROVIDER_CHOICES, default='gemini')
    voice_id = models.CharField(max_length=100, blank=True)  # ElevenLabs voice ID
    language = models.CharField(max_length=10, default='ar')
    speed = models.FloatField(default=1.0)  # 0.5 - 2.0
    pitch = models.FloatField(default=0.0)  # -1.0 - 1.0
    volume = models.FloatField(default=1.0)  # 0.0 - 1.0
    auto_play = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
```

### ج. نقطة النهاية (API Endpoint)
```
POST /api/v1/schools/voice/synthesize/
{
    "text": "نص للتحويل إلى كلام",
    "locale": "ar",
    "provider": "gemini",     // اختياري: gemini|elevenlabs|edge
    "speed": 1.0,             // اختياري
    "format": "mp3"           // mp3|wav|ogg
}
Response: Binary audio stream (audio/mpeg)
```

---

## 3. التكامل مع النظام الحالي

### الاتصال بنظام الصوت الموجود
- `apps/schools/views.py` يحتوي `VoiceTranscribeAPIView` (STT) و `VoiceSynthesizeAPIView` (TTS)
- `VoiceSynthesizeAPIView` يستخدم حالياً `google-genai` للتحويل
- التحسين المطلوب: إضافة ElevenLabs و Edge TTS كبدائل

### الاستخدام في المكونات
- **دفتر الدرجات**: زر "استمع للتعليق" بجانب كل درجة
- **الواجبات**: زر "استمع للسؤال" في تفاصيل الواجب
- **التقارير الأسبوعية**: زر "تحميل تقرير صوتي" في واجهة ولي الأمر
- **الدروس**: زر "تشغيل الدرس كاملاً" في عرض خطة الدرس

---

## 4. الواجهة الأمامية (Frontend)

### مكون `AudioPlayer` مخصص
```typescript
interface AudioPlayerProps {
    src: string;           // URL الملف الصوتي
    title?: string;        // عنوان التشغيل
    autoPlay?: boolean;    // تشغيل تلقائي
    showDownload?: boolean; // زر التنزيل
    locale?: string;       // اللغة الحالية
}
```

### مواقع الاستخدام
| الموقع | المكون | الوظيفة |
|--------|--------|---------|
| `/teacher/grades` | `GradeAudioFeedback` | تشغيل تعليق صوتي على الدرجات |
| `/student/assignments` | `AssignmentQuestionAudio` | قراءة سؤال الواجب بصوت عالٍ |
| `/parent/reports` | `WeeklyReportAudio` | تحويل التقرير الأسبوعي لملف صوتي |
| `/school/admin/lessons` | `LessonAudioPlayer` | تشغيل محتوى الدرس كاملاً |

---

## 5. التخزين المؤقت (Caching)
- التخزين المؤقت للملفات الصوتية في **Local Memory Cache** ( accommodates 50+ concurrent requests)
- مفتاح الكاش: `tts:{text_hash}:{locale}:{speed}:{provider}`
- TTL: 24 ساعة (النصوص التعليمية نادراً ما تتغير)
- تنظيف تلقائي: ملفات أكبر من 10MB تُحذف بعد ساعة

---

## 6. الأداء والمحددات
- **مدة النص الأقصى**: 5000 حرف لكل طلب ( تقسيم تلقائي للنصوص الأطول)
- **زمن الاستجابة المتوقع**: < 2 ثانية للنصوص القصيرة (< 500 حرف)
- **عدد الطلبات**: Throttled بـ 10 طلبات/دقيقة لكل مستخدم
- **الحجم الأقصى للملف**: 10MB (بعد الضغط)

---

## 7. الأمان
- **Rate limiting**: 10 طلبات/دقيقة لكل مستخدم
- **التحقق من الصلاحيات**: `IsAuthenticated` فقط
- **نطاق النصوص**: فقط محتوى المنصة (لا نصوص خارجية)
- **حظر المحتوى**: فلترة النصوص المخالفة عبر Google Perspective API
