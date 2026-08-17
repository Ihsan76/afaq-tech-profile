# نماذج إدارة اللغات

> **مُحدَّثة (يوليو 2026)** — تطابق التنفيذ الفعلي في `backend/apps/core/models.py`.

## نموذج اللغة (Language)

```python
class Language(TimeStampedModel):
    """اللغة المدعومة في المنصة"""

    code = models.CharField('رمز اللغة', max_length=10, unique=True)     # ISO 639-1
    name = models.CharField('اسم اللغة (إنجليزي)', max_length=100)
    native_name = models.CharField('اسم اللغة بالعربية', max_length=100, blank=True)
    flag = models.CharField('العلم', max_length=20, blank=True)          # emoji 🇸🇦
    is_rtl = models.BooleanField('اتجاه من اليمين لليسار', default=False)
    is_active = models.BooleanField('مفعلة', default=True)
    is_default = models.BooleanField('الافتراضية', default=False)
    order = models.IntegerField('الترتيب', default=0)
    created_at / updated_at  # من TimeStampedModel

    class Meta:
        ordering = ['order', 'code']
```

- `save()` يضمن وجود **لغة افتراضية واحدة فقط**: عند تعيين `is_default=True` تُلغى الافتراضية عن باقي اللغات.
- اللغات المزروعة (9): `ar` (RTL، 🇸🇦)، `en` (الافتراضية، 🇬🇧)، `fr`، `tr`، `ur` (RTL، 🇵🇰)، `es`، `de`، `id`، `bn`.

---

## نموذج مفتاح الترجمة (TranslationKey)

```python
class TranslationKey(TimeStampedModel):
    """مفتاح ترجمة لواجهة الموقع — القيمة لكل لغة"""

    key = models.CharField('المفتاح', max_length=200, unique=True)       # مثال: nav.home
    namespace = models.CharField('النطاق', max_length=100, blank=True, default='')
    translations = models.JSONField('الترجمات', default=dict, blank=True) # {"ar": "...", "en": "..."}
    is_active = models.BooleanField('مفعل', default=True)
    order = models.IntegerField('الترتيب', default=0)

    class Meta:
        ordering = ['order', 'key']
```

- `save()` يستخرج `namespace` تلقائياً من المفتاح: الجزء قبل أول نقطة، أو `root` إن لم يحتوِ نقطة.
- الترجمة لكل مفتاح تُخزَّن في **كائن JSON واحد** `translations: {locale: value}` بدلاً من سجل لكل لغة.

---

## نموذج FeatureFlag (أعلام الميزات)

```python
class FeatureFlag(TimeStampedModel):
    key = models.CharField('مفتاح الميزة', max_length=100, unique=True)
    name = models.CharField('اسم الميزة', max_length=200)
    is_active = models.BooleanField('مفعلة', default=True)
    description = models.TextField('الوصف', blank=True)
```

---

## أوامر الزرع (Seed)

### زرع اللغات
```bash
cd backend
./venv/bin/python seed_languages.py
# الناتج: Languages seeded: 9 created (تحديث عبر update_or_create بالرمز)
```

### زرع مفاتيح الترجمات (من ملفات الواجهة الأمامية)
```bash
cd backend
./venv/bin/python manage.py seed_translations
# الناتج: تم زرع 923 مفتاح من 10 ملفات: 4 جديد، 910 محدّث
```

- يُقرأ من `../frontend/src/i18n/messages/*.json` (9 ملفات — واحد لكل لغة).
- يفلّت الكائنات المتداخلة إلى مفاتيح مسطّطة بنقاط (`{a: {b: x}}` → `a.b`).
- يستخدم `bulk_create`/`bulk_update` (دفعات 200) لتجنب بطء الاتصال بـ PostgreSQL.
- مع `--clear` يحذف جميع المفاتيح قبل الزرع.

---

## ملخص العلاقات

```
Language (1) ── لا علاقة مباشرة بالترجمات
    └── fields: code, name, native_name, flag, is_rtl,
                is_active, is_default, order

TranslationKey (مستقل عن Language)
    ├── key        — المفتاح المسطّح بنقاط
    ├── namespace  — أول جزء من المفتاح (فلترة)
    └── translations — JSON: {locale: value} لكل لغة
```

---

## ملخص

> **إدارة اللغات والترجمات** أصبحت ديناميكية بالكامل: 10 لغات في قاعدة البيانات (`Language`)، و1018 مفتاح ترجمة (`TranslationKey`) تُزاح من ملفات `messages/*.json` وتُعدَّل من لوحة الإدارة، و`TranslationProvider` في الواجهة يسحب القيم الحية ويدمجها فوق الرسائل الثابتة — أي تعديل يُحفظ يظهر فوراً بدون إعادة نشر.
