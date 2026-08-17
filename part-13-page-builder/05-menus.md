# نظام القوائم (Menu Manager)

## نظرة عامة

نظام إدارة قوائم التنقل يسمح للمدير بإنشاء وتعديل وترتيب عناصر القوائم في مواقع مختلفة من الصفحة.

> **حالة التنفيذ:** مكتمل ✅

---

## نموذج عنصر القائمة (MenuItem) — مُنفّذ ✅

```python
class MenuItem(models.Model):
    class MenuPosition(models.TextChoices):
        HEADER = 'header', 'القائمة العلوية'
        FOOTER = 'footer', 'تذييل الصفحة'
        SIDEBAR = 'sidebar', 'الشريط الجانبي'

    menu = models.CharField(max_length=20, choices=MenuPosition.choices)

    class ServiceContext(models.TextChoices):
        ACADEMY = 'academy', 'الأكاديمية'
        SCHOOL = 'school', 'آفاق مدرستي'
        CURRICULUM = 'curriculum', 'المناهج'
        LESSON_PLANS = 'lesson-plans', 'خطط الدروس'
        EBOOKS = 'ebooks', 'الكتب الإلكترونية'
        DASHBOARD = 'dashboard', 'ساحة العمل'
        PROFILE = 'profile', 'الملف الشخصي'
        GAMIFICATION = 'gamification', 'التلعيب'
        SUBSCRIPTIONS = 'subscriptions', 'الاشتراكات'
        ADMIN = 'admin', 'لوحة الإدارة'

    class RequiredRole(models.TextChoices):
        USER = 'user', 'مستخدم عام'
        INSTRUCTOR = 'instructor', 'مدرب'
        ADMIN = 'admin', 'مدير'
        SUPPORT = 'support', 'دعم'
        FINANCE = 'finance', 'مالية'
        DEVELOPER = 'developer', 'مطور'

    # سياقات متعددة — مصفوفة؛ فارغة = يظهر في كل الصفحات
    service_context = ArrayField(models.CharField(...))
    # أدوار مطلوبة متعددة — مصفوفة؛ فارغة = للجميع
    required_role = ArrayField(models.CharField(...))

    translations = models.JSONField(default=dict, blank=True)
    url = models.CharField(max_length=500, blank=True, default='')
    page = models.ForeignKey(Page, on_delete=models.SET_NULL, null=True, blank=True)
    icon = models.CharField(max_length=10, blank=True, default='')
    parent = models.ForeignKey('self', null=True, blank=True, related_name='children')
    order = models.IntegerField(default=0)
    is_active = models.BooleanField(default=True)
    open_in_new = models.BooleanField(default=False)
    css_class = models.CharField(max_length=200, blank=True, default='')
    badge = models.CharField(max_length=50, blank=True, default='')
```

> **نظام اختيار متعدّد (Multi-select)**: منذ أغسطس 2026 أصبح `service_context` و `required_role` **مصفوفات** (`ArrayField`) بدل قيمة مفردة، مع مكوّن `MultiSelectDropdown` في لوحة الإدارة (كل الخيارات محددة افتراضياً، ويمكن إلغاء البعض). لا يوجد خيار "all" خاص — **المصفوفة الفارغة تعني "الكل"** (عبر `ArrayField(default=list)`)، ويُعالَج ذلك عند القراءة والعرض. مهاجرة `0015_alter_menuitem_required_role_and_more` حوّلت البيانات القائمة تلقائياً (قيمة مفردة ← مصفوفة، و`all` ← القائمة الكاملة).

---

## مواقع القوائم (3)

| الموقع | الوصف | الاستخدام |
|--------|-------|-----------|
| `header` | القائمة العلوية | التنقل الرئيسي في الأعلى |
| `footer` | تذييل الصفحة | روابط التذييل |
| `sidebar` | الشريط الجانبي | قوائم سياقية حسب الخدمة والدور (عبر `ContextualSidebar`) |

---

## البيانات الأولية (Seeded) — `seed_menus.py`

- **Header** (5): الرئيسية، الأكاديمية، المناهج، المدوّنة، الكتب الإلكترونية (+ تواصل).
- **Footer** (5): عن المنصة، سياسة الخصوصية، شروط الخدمة، تواصل معنا، الكتب الإلكترونية.
- **Sidebar** (مجموعات حسب `service_context`):
  - عناصر عامة (تظهر في كل الخدمات) عبر `ALL_CONTEXTS`.
  - عناصر خاصة بكل خدمة (`["academy"]`, `["ebooks"]`, `["school"]`, `["curriculum"]`).
  - `ALL_ROLES` = كل الأدوار (عام)؛ البقية تُفلتر حسب دور المستخدم.

---

## API Endpoints

### عام (Public)

#### GET `/api/v1/pages/menu/<menu_type>/`
جلب عناصر القائمة حسب النوع (header, footer, sidebar).

- **header / footer**: تُعرض كاملة (عناصر نشطة فقط، مرتبة حسب `order`).
- **sidebar**: تُفلتر حسب سياق الخدمة الحالي (`service_context__contains=[context]`) — العناصر العامة (مصفوفة فارغة) تُعرض أولاً في كل الخدمات، ثم عناصر الخدمة المحددة (ترتيب `when` / `order`). اختيار الدور (`required_role`) يُطبَّق في الواجهة عبر `ContextualSidebar`.

```json
[
  {
    "id": 1,
    "menu": "sidebar",
    "translations": { "ar": { "title": "ساحة العمل" }, "en": { "title": "Workspace" } },
    "url": "/dashboard",
    "icon": "📊",
    "service_context": [],
    "required_role": [],
    "order": 0,
    "is_active": true,
    "children": []
  }
]
```

### إدارة (Admin)

| Method | Endpoint | الوصف |
|--------|----------|-------|
| GET | `/api/v1/pages/admin/menus/?menu=<type>` | قائمة العناصر (حسب الموقع) |
| POST | `/api/v1/pages/admin/menus/create/` | إضافة عنصر |
| PUT | `/api/v1/pages/admin/menus/<pk>/` | تعديل عنصر |
| DELETE | `/api/v1/pages/admin/menus/<pk>/delete/` | حذف عنصر |
| PUT | `/api/v1/pages/admin/menus/reorder/` | إعادة ترتيب |

حمولة الإنشاء/التعديل تتضمن الحقول الجديدة كمصفوفات:
```json
{
  "menu": "sidebar",
  "translations": { "ar": { "title": "الأكاديمية" }, "en": { "title": "Academy" } },
  "url": "/academy",
  "icon": "🎬",
  "service_context": ["academy"],
  "required_role": ["user", "instructor"],
  "is_active": true
}
```

### واجهة الإدارة (`/admin/menus`) — متعدد الاختيار ✅

- **3 تبويبات**: Header | Footer | Sidebar.
- **حقل سياق الخدمة**: `MultiSelectDropdown` (القائمة المنسدلة مع خانات اختيار) — كل الخيارات محددة افتراضياً، ويمكن إلغاء البعض، مع أزرار "تحديد الكل / إلغاء تحديد الكل" وشارة "كل الصفحات" عندما تكون كل الخيارات محددة.
- **حقل الأدوار المطلوبة**: `MultiSelectDropdown` بنفس السلوك (شارة "كل الأدوار" عند التحديد الكامل).
- المكوّن: `frontend/src/components/MultiSelectDropdown.tsx` — يغلق القائمة عند النقر خارجها، يعرض عدد المحدد، ويدعم RTL.

---

## الربط بالصفحات

- كل عنصر قائمة يمكن أن يرتبط بـ `Page` عبر ForeignKey
- إذا وُجد `page` → `resolved_url` ي自動 يصبح `/{page.slug}`
- إذا لم يُوجد `page` → يستخدم `url` مباشرة
- هذا يسمح بالرابط الداخلي مع الحماية من كسر الروابط عند تغيير الـ slugs

---

## العناصر الفرعية (Sub-menus)

- كل عنصر يمكن أن يكون أباً لعناصر أخرى عبر `parent`
- الـ API يُرجع `children` array لكل عنصر
- Navbar.tsx يعرض القوائم الفرعية في dropdown

---

## التكامل مع Navbar

```tsx
// Navbar.tsx
const res = await fetch(`${API_URL}/pages/menu/header/`);
const menuItems = await res.json();
// يعرض العناصر مرتبة حسب order
// العناصر النشطة فقط (is_active=true)
// القوائم الفرعية في dropdown
```

---

## ملخص

> نظام القوائم يدعم 3 مواقع (header, footer, sidebar) مع ربط ديناميكي بالصفحات ودعم للعناصر الفرعية والشارات. يُقرأ من الباك إند ويعرض في Navbar تلقائياً. **الشريط الجانبي سياقي**: `service_context` و `required_role` كمصفوفات اختيار متعددة (فارغة = الكل/للجميع)، والفلترة من `MenuPublicView` (باك إند) + `ContextualSidebar` (واجهة)، والإدارة عبر `MultiSelectDropdown`.
