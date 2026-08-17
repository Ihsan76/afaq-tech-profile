# نماذج الدورات التدريبية

## نموذج الدورة

```python
class Course(models.Model):
    """الدورة التدريبية"""
    
    class Status(models.TextChoices):
        DRAFT = 'draft', 'مسودة'
        PUBLISHED = 'published', 'منشورة'
        ARCHIVED = 'archived', 'مؤرشفة'
    
    # معلومات أساسية
    title = models.CharField(max_length=255, verbose_name='عنوان الدورة')
    slug = models.SlugField(unique=True, allow_unicode=True)
    description = models.TextField(verbose_name='الوصف')
    short_description = models.CharField(max_length=500, blank=True)
    
    # اللغة
    language = models.CharField(max_length=5, default='ar', verbose_name='لغة الدورة')
    
    # المدرب
    instructor = models.ForeignKey('users.User', on_delete=models.CASCADE, related_name='courses')
    
    # المناهج
    subject = models.ForeignKey('academics.Subject', on_delete=models.SET_NULL, null=True)
    grade = models.ForeignKey('academics.Grade', on_delete=models.SET_NULL, null=True, blank=True)
    
    # التسعير
    price = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    currency = models.CharField(max_length=3, default='USD')
    
    # الوسائط
    thumbnail = models.ImageField(upload_to='courses/thumbnails/', blank=True, null=True)
    promo_video = models.URLField(blank=True)
    
    # الإعدادات
    status = models.CharField(max_length=15, choices=Status.choices, default=Status.DRAFT)
    is_featured = models.BooleanField(default=False)
    max_students = models.IntegerField(null=True, blank=True)
    
    # الإحصائيات
    enrollment_count = models.IntegerField(default=0)
    rating = models.DecimalField(max_digits=3, decimal_places=2, default=0)
    review_count = models.IntegerField(default=0)
    
    # التوقيت
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    published_at = models.DateTimeField(null=True, blank=True)
    
    class Meta:
        verbose_name = 'دورة تدريبية'
        verbose_name_plural = 'الدورات التدريبية'
        ordering = ['-created_at']
    
    def __str__(self):
        return self.title
    
    @property
    def is_free(self):
        return self.price == 0
```

---

## نموذج الفصل

```python
class Chapter(models.Model):
    """فصل في الدورة"""
    
    course = models.ForeignKey(Course, on_delete=models.CASCADE, related_name='chapters')
    title = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    order = models.IntegerField(default=0)
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name = 'فصل'
        verbose_name_plural = 'الفصول'
        ordering = ['order']
    
    def __str__(self):
        return f"{self.course.title} - {self.title}"
```

---

## نموذج الدرس

```python
class CourseLesson(models.Model):
    """الدرس في الدورة"""
    
    class LessonType(models.TextChoices):
        VIDEO = 'video', 'فيديو'
        TEXT = 'text', 'نص'
        QUIZ = 'quiz', 'اختبار'
        ASSIGNMENT = 'assignment', 'مهام'
    
    chapter = models.ForeignKey(Chapter, on_delete=models.CASCADE, related_name='lessons')
    
    title = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    lesson_type = models.CharField(max_length=15, choices=LessonType.choices)
    
    # المحتوى
    content = models.TextField(blank=True)  # Text content
    video_url = models.URLField(blank=True)
    video_duration = models.IntegerField(null=True, blank=True)  # in seconds
    
    # الموارد
    resources = models.JSONField(default=list, blank=True)
    # [{"name": "PDF", "url": "...", "type": "pdf"}]
    
    # الإعدادات
    is_preview = models.BooleanField(default=False)  # متاح للمشاهدة مجاناً
    is_required = models.BooleanField(default=True)
    order = models.IntegerField(default=0)
    
    # التقييم
    passing_score = models.IntegerField(null=True, blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name = 'درس الدورة'
        verbose_name_plural = 'دروس الدورة'
        ordering = ['order']
    
    def __str__(self):
        return self.title
    
    @property
    def duration_display(self):
        if self.video_duration:
            minutes = self.video_duration // 60
            seconds = self.video_duration % 60
            return f"{minutes}:{seconds:02d}"
        return None
```

---

## نموذج التسجيل

```python
class Enrollment(models.Model):
    """تسجيل الطالب في الدورة"""
    
    class Status(models.TextChoices):
        ACTIVE = 'active', 'نشط'
        COMPLETED = 'completed', 'مكتمل'
        DROPPED = 'dropped', 'منسحب'
    
    student = models.ForeignKey('users.User', on_delete=models.CASCADE, related_name='enrollments')
    course = models.ForeignKey(Course, on_delete=models.CASCADE, related_name='enrollments')
    
    status = models.CharField(max_length=15, choices=Status.choices, default=Status.ACTIVE)
    
    # التقدم
    progress = models.IntegerField(default=0)  # 0-100
    completed_lessons = models.ManyToManyField(CourseLesson, blank=True)
    
    # التقييم
    rating = models.IntegerField(null=True, blank=True)
    review = models.TextField(blank=True)
    
    # التوقيت
    enrolled_at = models.DateTimeField(auto_now_add=True)
    completed_at = models.DateTimeField(null=True, blank=True)
    last_accessed = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name = 'تسجيل'
        verbose_name_plural = 'التسجيلات'
        unique_together = ['student', 'course']
    
    def __str__(self):
        return f"{self.student.name_ar} - {self.course.title}"
    
    @property
    def is_completed(self):
        return self.status == self.Status.COMPLETED
```

---

## ملخص العلاقات

```
User (instructor) ──── (N) Course
                              │
                              ├── Chapter (1:N)
                              │   └── CourseLesson (1:N)
                              │       └── resources (JSON)
                              │
                              └── Enrollment (1:N)
                                  └── Student (M:1)
                                      └── completed_lessons (M:N)
```
