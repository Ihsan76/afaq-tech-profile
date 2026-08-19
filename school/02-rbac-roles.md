# خطة نظام الأدوار المتعددة الموحد (Multi-Role RBAC)

> **الحالة:** قيد التخطيط
> **آخر تحديث:** أغسطس 2026

---

## نظرة عامة

**المشكلة:** النظام الحالي يدعم دور واحد فقط لكل مستخدم (`User.role` CharField).
**الحل:** إنشاء نموذج `UserRole` يدعم أدوار متعددة مع نطاقات (منظمة/عالمي).

### الأدوار عبر كل الخدمات

| الخدمة | الدور | النطاق | الربط |
|--------|-------|--------|-------|
| **المدرسة** | `student` | مدرسة محددة | `StudentEnrollment` |
| | `teacher` | مدرسة محددة | `SchoolTeacher` |
| | `parent` | مدرسة محددة | `FamilyLink` |
| | `school_admin` | مدرسة/منطقة | `School.manager` FK |
| | `school_accountant` | مدرسة محددة | (غير مستخدم حالياً) |
| | `school_transport_officer` | مدرسة محددة | (غير مستخدم حالياً) |
| | `school_librarian` | مدرسة محددة | (إدارة المكتبة) |
| **الأكاديمية** | `instructor` | عالمي | `Course.instructor` FK |
| | (طالب) | — | `Enrollment` (أي مستخدم مسجل) |
| **الكتب** | (مؤلف) | — | `Ebook.author` FK |
| | (مشتري) | — | `EbookPurchase` |
| **السوق** | `provider` | عالمي | `Service.provider` FK |
| | (مشتري) | — | `Order.buyer` FK |
| | (محفظة) | — | `Wallet` 1:1 مع User |
| **المكتبة** | `school_librarian` | مدرسة محددة | (إدارة المكتبة) |
| | (مستعير) | مدرسة محددة | `LibraryLending` |
| **الإدارة** | `admin` | عالمي | كل الأقسام |
| | `developer` | عالمي | معظم الأقسام |
| | `support` | عالمي | قراءة فقط |
| | `content_manager` | عالمي | محتوى + كورسات + كتب |
| | `finance` | عالمي | اشتراكات + مالية |

---

## المرحلة 1: نموذج UserRole + RoleService

### 1.1 نموذج UserRole

**الملف:** `backend/apps/users/models.py`

```python
class UserRole(models.Model):
    """دور مُعيّن لمستخدم في سياق محدد."""

    class Meta:
        unique_together = ('user', 'role', 'organization')
        verbose_name = 'User Role'
        verbose_name_plural = 'User Roles'

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='user_roles',
        verbose_name=_('User')
    )
    role = models.CharField(
        _('Role'),
        max_length=32,
        choices=User.Role.choices
    )
    organization = models.ForeignKey(
        'subscriptions.Organization',
        on_delete=models.CASCADE,
        null=True, blank=True,
        related_name='user_roles',
        verbose_name=_('Organization'),
        help_text=_('Leave empty for global roles (admin, instructor, provider)')
    )
    assigned_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True, blank=True,
        related_name='assigned_roles',
        verbose_name=_('Assigned By')
    )
    assigned_at = models.DateTimeField(auto_now_add=True, verbose_name=_('Assigned At'))
    is_active = models.BooleanField(default=True, verbose_name=_('Is Active'))

    def __str__(self):
        org = f" @ {self.organization}" if self.organization else " (global)"
        return f"{self.user} → {self.role}{org}"
```

### 1.2 حقل roles الإضافي في User

```python
# في نموذج User существующي
roles = models.JSONField(
    _('All Roles'),
    default=list,
    blank=True,
    help_text=_('List of all roles this user has. e.g. ["teacher", "instructor"]')
)
```

### 1.3 RoleService

**الملف الجديد:** `backend/apps/users/services.py`

```python
class RoleService:
    """خدمة موحدة لإدارة الأدوار والصلاحيات."""

    @staticmethod
    def has_role(user, role, organization=None):
        """هل المستخدم يملك دور محدد؟"""
        qs = UserRole.objects.filter(user=user, role=role, is_active=True)
        if organization:
            qs = qs.filter(organization=organization)
        else:
            qs = qs.filter(organization__isnull=True)
        return qs.exists()

    @staticmethod
    def has_role_in_school(user, role, school):
        """هل المستخدم يملك دور محدد في مدرسة محددة؟"""
        pass

    @staticmethod
    def get_user_roles(user, organization=None):
        """الحصول على كل أدوار المستخدم."""
        qs = UserRole.objects.filter(user=user, is_active=True)
        if organization:
            qs = qs.filter(organization=organization)
        return qs

    @staticmethod
    def assign_role(user, role, assigned_by=None, organization=None):
        """تعيين دور جديد."""
        user_role, created = UserRole.objects.get_or_create(
            user=user, role=role, organization=organization,
            defaults={'assigned_by': assigned_by}
        )
        # تحديث حقل roles
        user.roles = list(UserRole.objects.filter(
            user=user, is_active=True
        ).values_list('role', flat=True).distinct())
        user.save(update_fields=['roles'])
        return user_role

    @staticmethod
    def revoke_role(user, role, organization=None):
        """إلغاء دور."""
        UserRole.objects.filter(
            user=user, role=role, organization=organization
        ).update(is_active=False)
        # تحديث حقل roles
        user.roles = list(UserRole.objects.filter(
            user=user, is_active=True
        ).values_list('role', flat=True).distinct())
        user.save(update_fields=['roles'])

    @staticmethod
    def can_assign_role(assigner, role_to_assign, organization=None):
        """هل يمكن للمفوّض تعيين هذا الدور؟"""
        # Admin يعين كل شيء
        if RoleService.has_role(assigner, 'admin'):
            return True
        # School Admin يعين أدوار المدرسة فقط
        if RoleService.has_role(assigner, 'school_admin'):
            school_roles = [
                'teacher', 'school_accountant',
                'school_transport_officer', 'school_librarian'
            ]
            if role_to_assign in school_roles:
                return RoleService.has_role_in_school(assigner, 'school_admin', organization)
        return False
```

---

## المرحلة 2: تحديث النماذج الحالية

### 2.1 تحديث Course model

```python
# القديم
instructor = models.ForeignKey(settings.AUTH_USER_MODEL, ...)

# الجديد
instructor_role = models.ForeignKey(
    'users.UserRole',
    on_delete=models.SET_NULL,
    null=True, blank=True,
    related_name='instructed_courses',
    verbose_name=_('Instructor Role')
)
```

### 2.2 تحديث Service model

```python
# القديم
provider = models.ForeignKey(settings.AUTH_USER_MODEL, ...)

# الجديد
provider_role = models.ForeignKey(
    'users.UserRole',
    on_delete=models.SET_NULL,
    null=True, blank=True,
    related_name='provided_services',
    verbose_name=_('Provider Role')
)
```

### 2.3 تحديث Ebook model

```python
# القديم
author = models.ForeignKey(settings.AUTH_USER_MODEL, ...)

# الجديد
author_role = models.ForeignKey(
    'users.UserRole',
    on_delete=models.SET_NULL,
    null=True, blank=True,
    related_name='authored_ebooks',
    verbose_name=_('Author Role')
)
```

---

## المرحلة 3: تحديث الدوال المساعدة

### 3.1 تحديث `is_admin()` و `is_teacher()` و `is_school_admin()`

**الملف:** `apps/schools/views.py` (سطور 94-110)

```python
# القديم
def is_admin(user):
    return user.role in SECTION_ROLES.get('schools', {'admin'})

# الجديد
def is_admin(user):
    return RoleService.has_role(user, 'admin') or \
           RoleService.has_role(user, 'developer') or \
           user.is_staff or user.is_superuser

# القديم
def is_teacher(user):
    return bool(user and user.is_authenticated and user.role == 'teacher')

# الجديد
def is_teacher(user):
    return bool(user and user.is_authenticated and RoleService.has_role(user, 'teacher'))
```

### 3.2 تحديث `is_admin_role()` و `user_sections()`

**الملف:** `apps/users/permissions.py`

```python
# القديم
def is_admin_role(user):
    return user.is_superuser or user.is_staff or user.role in ADMIN_ROLES

# الجديد
def is_admin_role(user):
    return user.is_superuser or user.is_staff or \
           any(RoleService.has_role(user, r) for r in ADMIN_ROLES)
```

---

## المرحلة 4: تحديث Permission Classes

### 4.1 تحديث `IsSectionAdmin`

```python
class IsSectionAdmin(BasePermission):
    def has_permission(self, request, view):
        u = request.user
        if not (u and u.is_authenticated):
            return False
        if u.is_superuser or u.is_staff:
            return True
        allowed = SECTION_ROLES.get(self.section, set())
        # القديم: u.role in allowed
        # الجديد: أي دور من allowed موجود لدى المستخدم
        return any(RoleService.has_role(u, r) for r in allowed)
```

---

## المرحلة 5: تحديث فلترات Queryset

### 5.1 تحديث `user_section_ids()`

```python
# القديم
def user_section_ids(user):
    if user.role == 'teacher':
        return list(SchoolTeacher.objects.filter(teacher=user).values_list('section_id', flat=True))
    if user.role == 'student':
        return list(StudentEnrollment.objects.filter(student=user).values_list('section_id', flat=True))
    # ...

# الجديد
def user_section_ids(user):
    if RoleService.has_role(user, 'teacher'):
        return list(SchoolTeacher.objects.filter(teacher=user).values_list('section_id', flat=True))
    if RoleService.has_role(user, 'student'):
        return list(StudentEnrollment.objects.filter(student=user).values_list('section_id', flat=True))
    # ...
```

### 5.2 نطاق التعديلات

| الموقع | عدد مرات(role) | الملف |
|--------|----------------|-------|
| `schools/views.py` | ~100+ | الأكبر |
| `users/permissions.py` | 10 | |
| `directorate_views.py` | 6 | |
| `subscriptions/views.py` | 4 | |
| `pages/models.py` | MenuItem.RequiredRole | |
| `pages/serializers.py` | 1 | |
| Frontend | ~50+ | 17 ملف |

---

## المرحلة 6: API Endpoints جديدة

### 6.1 UserManagementView (تحديث)

```python
class UserAdminUpdateView(generics.RetrieveUpdateAPIView):
    # التحديث: إضافة roles field
    allowed = ['role', 'roles', 'subscription_plan', 'is_verified', 'is_active', 'phone', ...]
```

### 6.2 RoleAssignmentView (جديد)

```python
class RoleAssignmentView(generics.CreateAPIView):
    """تعيين دور لمستخدم."""
    permission_classes = [IsSystemAdmin]

    def create(self, request, *args, **kwargs):
        user_id = request.data.get('user_id')
        role = request.data.get('role')
        organization_id = request.data.get('organization_id')

        if not RoleService.can_assign_role(request.user, role, organization_id):
            return Response(status=403)

        user_role = RoleService.assign_role(
            user_id=user_id,
            role=role,
            assigned_by=request.user,
            organization_id=organization_id
        )
        return Response(UserRoleSerializer(user_role).data)
```

### 6.3 MyRolesView (جديد)

```python
class MyRolesView(generics.RetrieveAPIView):
    """الحصول على أدوار المستخدم الحالي."""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        roles = RoleService.get_user_roles(request.user)
        return Response(UserRoleSerializer(roles, many=True).data)
```

### 6.4 UserRolesView (جديد)

```python
class UserRolesView(generics.ListAPIView):
    """إدارة أدوار مستخدم محدد."""
    permission_classes = [IsSystemAdmin]

    def get_queryset(self):
        user_id = self.kwargs['user_id']
        return UserRole.objects.filter(user_id=user_id, is_active=True)
```

### 6.5 في urls.py

```python
path('auth/my-roles/', MyRolesView.as_view(), name='my-roles'),
path('auth/users/<int:user_id>/roles/', UserRolesView.as_view(), name='user-roles'),
path('auth/assign-role/', RoleAssignmentView.as_view(), name='assign-role'),
```

---

## المرحلة 7: تحديث Frontend

### 7.1 تحديث RoleGuard

**الملف:** `frontend/src/components/school/RoleGuard.tsx`

```typescript
// القديم
const isAllowed = isStaff || allowed.includes(user.role);

// الجديد
const isAllowed = isStaff || allowed.some(role => user.roles.includes(role));
```

### 7.2 الملفات المطلوب تحديثها

| الملف | التعديل |
|-------|---------|
| `components/school/RoleGuard.tsx` | تحديث لدعم roles array |
| `components/ContextualSidebar.tsx` | تحديث role checks |
| `components/school/RoleDashboard.tsx` | تحديث role checks |
| `components/Navbar.tsx` | تحديث role checks |
| `app/[locale]/admin/layout.tsx` | تحديث role checks |
| `app/[locale]/dashboard/page.tsx` | تحديث role checks |
| `app/[locale]/school/page-client.tsx` | تحديث role checks |
| `app/[locale]/admin/users/page.tsx` | تحديث role checks |
| `app/[locale]/admin/users/[userId]/page.tsx` | تحديث role checks |
| `app/[locale]/admin/schools/page.tsx` | تحديث role checks |
| `app/[locale]/profile/page.tsx` | تحديث role display |

---

## المرحلة 8: Migration Script

**الملف الجديد:** `backend/apps/users/management/commands/migrate_roles.py`

```python
class Command(BaseCommand):
    help = 'Migrate single role field to UserRole model'

    def handle(self, *args, **options):
        for user in User.objects.all():
            # 1. إنشاء سجل UserRole من user.role الحالي
            UserRole.objects.get_or_create(
                user=user,
                role=user.role,
                organization=None,
                defaults={'assigned_by': None}
            )

            # 2. إنشاء سجلات من SchoolTeacher
            for st in SchoolTeacher.objects.filter(teacher=user):
                UserRole.objects.get_or_create(
                    user=user,
                    role='teacher',
                    organization=None,
                    defaults={'assigned_by': getattr(st, 'created_by', None)}
                )

            # 3. إنشاء سجلات من StudentEnrollment
            for se in StudentEnrollment.objects.filter(student=user):
                UserRole.objects.get_or_create(
                    user=user,
                    role='student',
                    organization=None,
                    defaults={'assigned_by': None}
                )

            # 4. إنشاء سجلات من Course.instructor
            for course in Course.objects.filter(instructor=user):
                UserRole.objects.get_or_create(
                    user=user,
                    role='instructor',
                    organization=None,
                    defaults={'assigned_by': None}
                )

            # 5. إنشاء سجلات من Service.provider
            for service in Service.objects.filter(provider=user):
                UserRole.objects.get_or_create(
                    user=user,
                    role='provider',
                    organization=None,
                    defaults={'assigned_by': None}
                )

            # 6. إنشاء سجلات من Ebook.author
            for ebook in Ebook.objects.filter(author=user):
                UserRole.objects.get_or_create(
                    user=user,
                    role='provider',
                    organization=None,
                    defaults={'assigned_by': None}
                )

            # 7. تحديث حقل roles
            user.roles = list(UserRole.objects.filter(
                user=user, is_active=True
            ).values_list('role', flat=True).distinct())
            user.save(update_fields=['roles'])
```

---

## المرحلة 9: التفويض المتدرج

### قواعد التفويض

```
Admin
├── يعين: كل الأدوار الإدارية (developer, support, content_manager, finance)
├── يعين: school_admin (في أي منظمة)
├── يعين: instructor (عالمي)
└── يعين: provider (عالمي)

School Admin
├── يعين: teacher (في مدرسته فقط)
├── يعين: school_accountant (في مدرسته فقط)
├── يعين: school_transport_officer (في مدرسته فقط)
└── يعين: school_librarian (في مدرسته فقط)

Instructor / Provider
└── لا يعين أي دور (يستخدم فقط)
```

### منطق `can_assign_role()`

```python
@staticmethod
def can_assign_role(assigner, role_to_assign, organization=None):
    # Admin يعين كل شيء
    if RoleService.has_role(assigner, 'admin'):
        return True
    # School Admin يعين أدوار المدرسة فقط
    if RoleService.has_role(assigner, 'school_admin'):
        school_roles = [
            'teacher', 'school_accountant',
            'school_transport_officer', 'school_librarian'
        ]
        if role_to_assign in school_roles:
            return RoleService.has_role_in_school(assigner, 'school_admin', organization)
    return False
```

---

## المرحلة 10: التوافق مع الماضي

### 10.1 الاحتفاظ بـ `role` field

```python
# في نموذج User
role = models.CharField(max_length=32, choices=Role.choices, default=Role.STUDENT)
roles = models.JSONField(default=list, blank=True)  # جديد
```

### 10.2 التزامن التلقائي

```python
# في RoleService.assign_role()
user.roles = list(UserRole.objects.filter(
    user=user, is_active=True
).values_list('role', flat=True).distinct())
user.save(update_fields=['roles'])

# تحديث role field (أول دور)
if not user.role or user.role == 'student':
    user.role = role
    user.save(update_fields=['role'])
```

---

## المرحلة 11: الاختبارات

### 11.1 اختبارات النموذج

```python
# backend/apps/users/tests/test_userrole.py
class UserRoleTest(TestCase):
    def test_assign_role(self):
        pass

    def test_revoke_role(self):
        pass

    def test_has_role(self):
        pass

    def test_has_role_in_school(self):
        pass

    def test_can_assign_role_admin(self):
        pass

    def test_can_assign_role_school_admin(self):
        pass

    def test_prevent_unauthorized_assignment(self):
        pass

    def test_multiple_roles(self):
        pass
```

### 11.2 اختبارات الصلاحيات

```python
# backend/apps/users/tests/test_permissions.py
class PermissionTest(TestCase):
    def test_admin_can_access_all_sections(self):
        pass

    def test_content_manager_can_access_content_section(self):
        pass

    def test_teacher_can_only_access_own_school(self):
        pass

    def test_student_cannot_access_admin_panel(self):
        pass
```

---

## ملخص التعديلات

### Backend (18 ملف)

| الملف | التعديل |
|-------|---------|
| `apps/users/models.py` | إضافة UserRole model + حقل roles |
| `apps/users/services.py` | ملف جديد: RoleService |
| `apps/users/serializers.py` | تحديث UserSerializer + إضافة UserRoleSerializer |
| `apps/users/views.py` | تحديث UserAdminUpdateView + إضافة RoleAssignmentView, MyRolesView, UserRolesView |
| `apps/users/permissions.py` | تحديث permission classes + الدوال المساعدة |
| `apps/users/urls.py` | إضافة 3 endpoints جديدة |
| `apps/users/migrations/` | إضافة migration جديد |
| `apps/schools/views.py` | تحديث ~100+ فلتر role |
| `apps/core/directorate_views.py` | تحديث 6 فلتر role |
| `apps/subscriptions/views.py` | تحديث role checks |
| `apps/pages/models.py` | تحديث MenuItem.RequiredRole |
| `apps/pages/serializers.py` | تحديث role reference |
| `apps/courses/models.py` | تحديث instructor FK |
| `apps/courses/views.py` | تحديث permission checks |
| `apps/ebooks/models.py` | تحديث author FK |
| `apps/marketplace/models.py` | تحديث provider FK |
| `apps/users/management/commands/migrate_roles.py` | ملف جديد: Migration script |
| `apps/users/tests/test_userrole.py` | ملف جديد: اختبارات |

### Frontend (11 ملف)

| الملف | التعديل |
|-------|---------|
| `components/school/RoleGuard.tsx` | تحديث لدعم roles array |
| `components/ContextualSidebar.tsx` | تحديث role checks |
| `components/school/RoleDashboard.tsx` | تحديث role checks |
| `components/Navbar.tsx` | تحديث role checks |
| `app/[locale]/admin/layout.tsx` | تحديث role checks |
| `app/[locale]/dashboard/page.tsx` | تحديث role checks |
| `app/[locale]/school/page-client.tsx` | تحديث role checks |
| `app/[locale]/admin/users/page.tsx` | تحديث role checks |
| `app/[locale]/admin/users/[userId]/page.tsx` | تحديث role checks |
| `app/[locale]/admin/schools/page.tsx` | تحديث role checks |
| `app/[locale]/profile/page.tsx` | تحديث role display |

---

## التسلسل الزمني (8 أسابيع)

| الأسبوع | المراحل |
|---------|---------|
| 1 | إنشاء نموذج UserRole + RoleService + Migration |
| 2 | تحديث النماذج الحالية (Course, Service, Ebook) |
| 3 | تحديث Backend permission classes + helper functions |
| 4 | تحديث schools/views.py (~100+ role checks) |
| 5 | إضافة API endpoints جديدة |
| 6 | تحديث Frontend components |
| 7 | Migration script + اختبارات |
| 8 | مراجعة + تنظيف |

---

## المخاطر

| المخاطر | الحل |
|---------|------|
| كسر التوافق مع الماضي | الاحتفاظ بـ `role` field + التزامن التلقائي |
| أداء Queries | إضافة indexes على UserRole (user, role, organization) |
| تعقيد Frontend | إنشاء hook موحد `useRoles()` |
| صعوبة Migration | script تدريجي + backup قبل التنفيذ |
| تكرار `SECTION_ROLES` | توحيد في ملف واحد + hook frontend |
