# إعدادات الموقع (Site Settings)

## نظرة عامة

نموذج إعدادات الموقع (SiteSettings) هو نموذج Singleton يحتوي جميع الإعدادات العامة للموقع.

> **حالة التنفيذ:** مكتمل ✅

---

## نموذج SiteSettings

```python
class SiteSettings(models.Model):
    # معلومات الموقع
    site_name_en = models.CharField(max_length=200, default='Afaq Tech')
    site_name_ar = models.CharField(max_length=200, default='آفاق تكنولوجي')
    site_description_en = models.TextField(blank=True, default='')
    site_description_ar = models.TextField(blank=True, default='')

    # الشعار
    logo_url = models.URLField(blank=True, default='')
    favicon_url = models.URLField(blank=True, default='')

    # التواصل
    email = models.EmailField(blank=True, default='')
    phone = models.CharField(max_length=50, blank=True, default='')
    whatsapp = models.CharField(max_length=50, blank=True, default='')

    # وسائل التواصل الاجتماعي
    facebook_url = models.URLField(blank=True, default='')
    twitter_url = models.URLField(blank=True, default='')
    instagram_url = models.URLField(blank=True, default='')
    linkedin_url = models.URLField(blank=True, default='')
    youtube_url = models.URLField(blank=True, default='')

    # التذييل
    footer_text_en = models.TextField(blank=True, default='')
    footer_text_ar = models.TextField(blank=True, default='')
    copyright_text = models.CharField(max_length=200, blank=True, default='')

    # إعدادات مخصصة
    custom_settings = models.JSONField(default=dict, blank=True)

    # Singleton enforcement
    is_active = models.BooleanField(default=True, primary_key=True)

    class Meta:
        verbose_name = 'إعدادات الموقع'

    def save(self, *args, **kwargs):
        self.pk = 1
        super().save(*args, **kwargs)

    @classmethod
    def load(cls):
        obj, _ = cls.objects.get_or_create(pk=1)
        return obj
```

---

## الحقول الرئيسية

| الفئة | الحقول |
|-------|--------|
| **الموقع** | site_name_en/ar, site_description_en/ar |
| **الشعار** | logo_url, favicon_url |
| **التواصل** | email, phone, whatsapp |
| **التواصل الاجتماعي** | facebook_url, twitter_url, instagram_url, linkedin_url, youtube_url |
| **التذييل** | footer_text_en/ar, copyright_text |
| **مخصص** | custom_settings (JSON) |

---

## Singleton Pattern

- `primary_key=True` + `is_active` — يضمن سطر واحد فقط
- `save()` يجبر `pk=1` دائماً
- `SiteSettings.load()` يُرجع السطر الوحيد أو يُنشئ واحداً افتراضياً

---

## API Endpoints

### عام (Public)

#### GET `/api/v1/pages/settings/`
```json
{
  "site_name_en": "Afaq Tech",
  "site_name_ar": "آفاق تكنولوجي",
  "site_description_en": "...",
  "site_description_ar": "...",
  "logo_url": "",
  "favicon_url": "",
  "email": "info@afaq.app",
  "phone": "",
  "whatsapp": "",
  "facebook_url": "",
  "twitter_url": "",
  "instagram_url": "",
  "linkedin_url": "",
  "youtube_url": "",
  "footer_text_en": "...",
  "footer_text_ar": "...",
  "copyright_text": "© 2026 Afaq Tech",
  "custom_settings": {}
}
```

### إدارة (Admin)

#### PUT `/api/v1/pages/admin/settings/`
تحديث جميع إعدادات الموقع.

```json
{
  "site_name_en": "Afaq Tech",
  "site_name_ar": "آفاق تكنولوجي",
  "email": "info@afaq.app",
  "phone": "+966...",
  "footer_text_en": "© 2026 Afaq Tech Platform",
  "footer_text_ar": "© 2026 منصة آفاق تكنولوجي"
}
```

---

## ملخص

> SiteSettings نموذج Singleton يحتوي جميع الإعدادات العامة — من معلومات التواصل إلى وسائل التواصل الاجتماعي والشعار والتذييل. سطر واحد في قاعدة البيانات يصلح لجميع احتياجات الموقع.
