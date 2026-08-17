# نماذج الثيمات (Theme Models)

## نموذج الثيم — Flat Model ✅

> **ملاحظة مهمة:** النموذج الفعلي هو **flat model** — جميع الحقول في جدول واحد. لا توجد نماذج فرعية (ThemeColors, ThemeButtons, إلخ).

```python
class Theme(models.Model):
    # معلومات أساسية
    name = models.CharField(max_length=100, unique=True)
    name_ar = models.CharField(max_length=100)
    icon = models.CharField(max_length=10, blank=True, default='🎨')
    description = models.TextField(blank=True, default='')
    description_ar = models.TextField(blank=True, default='')
    is_active = models.BooleanField(default=True)
    is_default = models.BooleanField(default=False)
    order = models.IntegerField(default=0)

    # 16 حقل لون
    primary = models.CharField(max_length=7, default='#2563EB')
    secondary = models.CharField(max_length=7, default='#7C3AED')
    accent = models.CharField(max_length=7, default='#06B6D4')
    success = models.CharField(max_length=7, default='#10B981')
    error = models.CharField(max_length=7, default='#EF4444')
    warning = models.CharField(max_length=7, default='#F59E0B')
    background = models.CharField(max_length=7, default='#FFFFFF')
    surface = models.CharField(max_length=7, default='#F9FAFB')
    surface_alt = models.CharField(max_length=7, default='#F3F4F6')
    text_color = models.CharField(max_length=7, default='#1F2937')
    text_secondary = models.CharField(max_length=7, default='#6B7280')
    text_muted = models.CharField(max_length=7, default='#9CA3AF')
    border_color = models.CharField(max_length=7, default='#E5E7EB')
    border_light = models.CharField(max_length=7, default='#F3F4F6')
    muted = models.CharField(max_length=7, default='#F3F4F6')

    # إعدادات الأزرار
    btn_shape = models.CharField(max_length=10, default='rounded')  # rounded, pill, square
    btn_size = models.CharField(max_length=5, default='md')         # sm, md, lg
    btn_shadow = models.CharField(max_length=5, default='md')       # none, sm, md, lg
    btn_hover = models.CharField(max_length=10, default='scale')    # none, scale, shadow, glow

    # إعدادات البطاقات
    card_radius = models.CharField(max_length=10, default='lg')     # none, sm, md, lg, full
    card_border = models.CharField(max_length=10, default='thin')   # none, thin, medium, thick
    card_shadow = models.CharField(max_length=5, default='md')      # none, sm, md, lg
    card_glass = models.BooleanField(default=False)

    # الخطوط
    font_heading = models.CharField(max_length=200, default='IBM Plex Sans Arabic')
    font_body = models.CharField(max_length=200, default='Noto Sans Arabic')
    font_size = models.CharField(max_length=10, default='16px')
    line_height = models.CharField(max_length=10, default='1.6')

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['order', 'name']
```

---

## الثيمات الستة المُهيأة

| # | الاسم | الاسم AR | primary | الوصف |
|---|-------|----------|---------|-------|
| 1 | default | آفاق كلاسيكي | #2563EB | الثيم الافتراضي — أزرق احترافي |
| 2 | dark | آفاق داكن | #818CF8 | Dark mode — بنفسجي |
| 3 | light | آفاق فاتح | #059669 | أخضر طبيعي |
| 4 | neutral | آفاق محايد | #6B7280 | رمادي هادئ |
| 5 | colorful | آفاق مدرسي | #EC4899 | ملون للتعليم |
| 6 | custom | آفاق مخصص | — | ثيم مخصص |

---

## كيفية العمل

### CSS Variables
كل ثيم يُطبّق عبر CSS variables على `<html>`:
```css
:root {
  --color-primary: #2563EB;
  --color-secondary: #7C3AED;
  --color-background: #FFFFFF;
  /* ... 16 متغير لون */
  --btn-radius: 0.75rem;
  --card-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1);
  /* ... */
}
```

### ThemeSwitcher
- في Navbar كـ dropdown
- يعرض: أيقونة + نقاط ألوان + علامة ✅ للثيم الحالي
- النقر يُطبّق الثيم فوراً
- حفظ في localStorage

### تخصيص لكل صفحة
- `Page.theme_overrides` JSON field
- يمكن تعيين ثيم مختلف لكل صفحة

---

## ملخص

> نموذج Theme flat — 35+ حقل في جدول واحد (ألوان + أزرار + بطاقات + خطوط). 6 ثيمات مُهيأة. يُطبّق عبر CSS variables. لا توجد نماذج فرعية.
