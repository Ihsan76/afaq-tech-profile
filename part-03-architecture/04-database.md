# قاعدة البيانات

## التقنية الأساسية

| العنصر | الإصدار |
|--------|---------|
| **PostgreSQL** | 16+ |
| **Django ORM** | 5.x |
| **psycopg2** | latest |
| ** django-debug-toolbar** | 4.x (dev) |

---

## المخطط العام

```
+------------------+     +------------------+
|     users        |     |    academics     |
|------------------|     |------------------|
| id (PK)          |     | id (PK)          |
| email            |     | name_ar          |
| password         |     | name_en          |
| name_ar          |     | type             |
| name_en          |     | parent_id (FK)   |
| role             |     | level            |
| phone            |     | order            |
| avatar           |     | is_active        |
| is_active        |     +------------------+
| ui_language      |
| timezone         |     +------------------+
+------------------+     |   lessonplans    |
         |               |------------------|
         |               | id (PK)          |
         |               | user_id (FK)     |
         |               | title            |
         |               | subject_id (FK)  |
         |               | grade_id (FK)    |
         |               | plan_data (JSON) |
         |               | generated_by     |
         |               | ai_model_used    |
         |               | is_public        |
         |               | status           |
         |               | created_at       |
         |               +------------------+
         |
+------------------+     +------------------+
|   ai_runs        |     |   ai_stats       |
|------------------|     |------------------|
| id (PK)          |     | id (PK)          |
| user_id (FK)     |     | user_id (FK)     |
| provider         |     | date             |
| model            |     | total_runs       |
| prompt_tokens    |     | total_tokens     |
| completion_tokens|     | total_cost_usd   |
| total_tokens     |     | provider_breakdown|
| cost_usd         |     +------------------+
| latency_ms       |
| success          |     +------------------+
| error_message    |     |    payments      |
| created_at       |     |------------------|
+------------------+     | id (PK)          |
                         | user_id (FK)     |
+------------------+     | type             |
|   courses        |     | amount_usd       |
|------------------|     | currency         |
| id (PK)          |     | status           |
| title            |     | provider         |
| slug             |     | provider_ref     |
| description      |     | metadata (JSON)  |
| instructor_id(FK)|     | created_at       |
| subject_id (FK)  |     +------------------+
| grade_id (FK)    |
| price            |     +------------------+
| currency         |     |    wallet        |
| thumbnail        |     |------------------|
| is_published     |     | id (PK)          |
| created_at       |     | user_id (FK)     |
+------------------+     | balance_usd      |
                         | balance_jod      |
+------------------+     | updated_at       |
|    blog          |     +------------------+
|------------------|
| id (PK)          |
| title            |
| slug             |
| content          |
| excerpt          |
| author_id (FK)   |
| featured_image   |
| status           |
| published_at     |
| created_at       |
+------------------+
```

---

## ترتيب الهجرة (Migration Order)

```
1. core            ← base models
2. users           ← User model
3. academics       ← Grade, Subject, Curriculum
4. ai              ← AIRun, AIStats
5. lessonplans     ← LessonPlan
6. courses         ← Course, Enrollment
7. blog            ← BlogPost, Comment
8. marketplace     ← Service, Order
9. payments        ← Transaction, Wallet, Subscription
10. notifications  ← Notification
11. media          ← MediaFile
12. landingpages   ← LandingPage, LandingBlock
```

---

## الفهارس

```sql
-- users
CREATE INDEX idx_users_email ON users_user(email);
CREATE INDEX idx_users_role ON users_user(role);
CREATE INDEX idx_users_is_active ON users_user(is_active);

-- lessonplans
CREATE INDEX idx_lp_user ON lessonplans_lessonplan(user_id);
CREATE INDEX idx_lp_subject ON lessonplans_lessonplan(subject_id);
CREATE INDEX idx_lp_grade ON lessonplans_lessonplan(grade_id);
CREATE INDEX idx_lp_status ON lessonplans_lessonplan(status);
CREATE INDEX idx_lp_created ON lessonplans_lessonplan(created_at);

-- ai_runs
CREATE INDEX idx_airun_user ON ai_airun(user_id);
CREATE INDEX idx_airun_provider ON ai_airun(provider);
CREATE INDEX idx_airun_created ON ai_airun(created_at);

-- courses
CREATE INDEX idx_course_slug ON courses_course(slug);
CREATE INDEX idx_course_published ON courses_course(is_published);

-- blog
CREATE INDEX idx_blog_slug ON blog_blogpost(slug);
CREATE INDEX idx_blog_status ON blog_blogpost(status);
CREATE INDEX idx_blog_published ON blog_blogpost(published_at);
```

---

## النسخ الاحتياطي

```bash
# يومي via cron
0 2 * * * /usr/bin/pg_dump -U afaq afaq_production | gzip > /backups/afaq_$(date +\%Y\%m\%d).sql.gz

# حذف النسخ القديمة (أكثر من 30 يوم)
0 3 * * * find /backups -name "afaq_*.sql.gz" -mtime +30 -delete
```

---

## ملخص

> قاعدة البيانات PostgreSQL 16+ مع ORM من Django. الهجرات منظمة حسب الاعتماديات. الفهارس تُحسّن الاستعلامات الأساسية. النسخ الاحتياطي يومي.
