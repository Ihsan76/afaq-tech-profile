# خطة هندسة النسخ الاحتياطي والاستعادة (Backup & Disaster Recovery)

> تاريخ التوثيق: 18 أغسطس 2026
> الغرض: توثيق التصميم الهندسي والمعماري للنسخ الاحتياطي التلقائي واستعادة الكوارث في منصة آفاق تكنولوجي.

---

## 1. الفكرة والهدف
ضمان أمان البيانات من خلال:
- **نسخ احتياطي تلقائي** لقاعدة البيانات يومياً
- **تخزين في S3** (Amazon S3 أو Upstash) مع تشفير
- **خطة استعادة كوارث** (Disaster Recovery Plan)
- **استعادة في أقل من ساعة** (RTO < 1 ساعة)

---

## 2. المكونات التقنية

### أ. النسخ الاحتياطي لقاعدة البيانات (pg_dump)
```bash
#!/bin/bash
# scripts/backup_database.sh

# الإعدادات
BACKUP_DIR="/tmp/backups"
S3_BUCKET="afaq-tech-backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="afaq_tech_backup_${TIMESTAMP}.sql.gz"
ENCRYPTED_FILE="${BACKUP_FILE}.gpg"

# إنشاء مجلد النسخ الاحتياطي
mkdir -p $BACKUP_DIR

# نسخ احتياطي لقاعدة البيانات
pg_dump $DATABASE_URL | gzip > "${BACKUP_DIR}/${BACKUP_FILE}"

# تشفير الملف
gpg --batch --yes --passphrase $GPG_PASSPHRASE \
    --symmetric --cipher-algo AES256 \
    -o "${BACKUP_DIR}/${ENCRYPTED_FILE}" \
    "${BACKUP_DIR}/${BACKUP_FILE}"

# رفع إلى S3
aws s3 cp "${BACKUP_DIR}/${ENCRYPTED_FILE}" \
    "s3://${S3_BUCKET}/backups/${ENCRYPTED_FILE}" \
    --storage-class STANDARD_IA

# تنظيف الملفات القديمة (الاحتفاظ بـ 30 نسخة)
aws s3 ls "s3://${S3_BUCKET}/backups/" | sort | head -n -30 | awk '{print $4}' | while read file; do
    aws s3 rm "s3://${S3_BUCKET}/backups/$file"
done

# تنظيف محلي
rm -f "${BACKUP_DIR}/${BACKUP_FILE}" "${BACKUP_DIR}/${ENCRYPTED_FILE}"

echo "✅ Backup completed: ${ENCRYPTED_FILE}"
```

### ب. جدولة النسخ الاحتياطي (Cron)
```bash
# crontab -e
# نسخ احتياطي يومياً الساعة 2:00 صباحاً
0 2 * * * /path/to/scripts/backup_database.sh >> /var/log/backup.log 2>&1

# نسخ احتياطي كل ساعة (للبيانات الحساسة)
0 * * * * /path/to/scripts/backup_database_hourly.sh >> /var/log/backup_hourly.log 2>&1
```

### ج. النسخ الاحتياطي للملفات (Media Files)
```bash
#!/bin/bash
# scripts/backup_media.sh

# رفع ملفات Media إلى S3
aws s3 sync /path/to/media/ "s3://afaq-tech-backups/media/" \
    --exclude "*.tmp" \
    --exclude "*.log"

# رفع ملفات Static إلى S3
aws s3 sync /path/to/static/ "s3://afaq-tech-backups/static/"
```

---

## 3. تكوين Amazon S3

### أ. إنشاء Bucket
```bash
# إنشاء Bucket
aws s3 mb s3://afaq-tech-backups --region me-south-1

# تفعيل Versioning
aws s3api put-bucket-versioning \
    --bucket afaq-tech-backups \
    --versioning-configuration Status=Enabled

# تفعيل التشفير (SSE-S3)
aws s3api put-bucket-encryption \
    --bucket afaq-tech-backups \
    --server-side-encryption-configuration '{
        "Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]
    }'

# تفعيل الحماية من الحذف
aws s3api put-object-lock-configuration \
    --bucket afaq-tech-backups \
    --object-lock-configuration '{
        "ObjectLockEnabled": "Enabled",
        "Rule": {"DefaultRetention": {"Mode": "COMPLIANCE", "Days": 365}}
    }'
```

### ب. تكلفة التخزين
| النوع | التكلفة/GB/شهر | الاستخدام |
|-------|----------------|----------|
| S3 Standard | $0.023 | النسخ الاحتياطي اليومي |
| S3 Standard-IA | $0.0125 | النسخ الاحتياطي الشهري |
| S3 Glacier | $0.004 | الأرشيف طويل الأمد |

**التكلفة المقدرة**: ~$5-10/شهر لقاعدة بيانات 1GB

---

## 4. استعادة الكوارث (Disaster Recovery)

### أ. خطة الاستعادة
```bash
#!/bin/bash
# scripts/restore_database.sh

# الإعدادات
BACKUP_FILE=$1  # ملف النسخ الاحتياطي المراد استعادته
S3_BUCKET="afaq-tech-backups"

# تحميل الملف من S3
aws s3 cp "s3://${S3_BUCKET}/backups/${BACKUP_FILE}" /tmp/

# فك التشفير
gpg --batch --yes --passphrase $GPG_PASSPHRASE \
    --decrypt /tmp/${BACKUP_FILE} > /tmp/backup.sql

# استعادة قاعدة البيانات
psql $DATABASE_URL < /tmp/backup.sql

# تنظيف
rm -f /tmp/${BACKUP_FILE} /tmp/backup.sql

echo "✅ Database restored from: ${BACKUP_FILE}"
```

### ب. مؤشرات KPI لاستعادة الكوارث
| المؤشر | الهدف |
|--------|-------|
| **RTO** (Recovery Time Objective) | < 1 ساعة |
| **RPO** (Recovery Point Objective) | < 24 ساعة (يوم واحد) |
| **MTTR** (Mean Time To Recovery) | < 30 دقيقة |

---

## 5. المراقبة والتنبيهات

### أ. التحقق من النسخ الاحتياطي
```python
# backend/apps/core/management/commands/verify_backups.py
from django.core.management.base import BaseCommand
import boto3
from datetime import datetime, timedelta

class Command(BaseCommand):
    help = 'التحقق من النسخ الاحتياطية وتنبيه إذا فات نسخة'

    def handle(self, *args, **options):
        s3 = boto3.client('s3')
        bucket = 'afaq-tech-backups'
        cutoff = datetime.now() - timedelta(hours=25)  # أكثر من 25 ساعة

        response = s3.list_objects_v2(Bucket=bucket, Prefix='backups/')
        for obj in response.get('Contents', []):
            last_modified = obj['LastModified'].replace(tenvinfo=None)
            if last_modified < cutoff:
                self.send_alert(f"⚠️ Backup missing! Last backup: {last_modified}")
                break
        else:
            self.stdout.write(self.style.SUCCESS('✅ All backups are current'))
```

---

## 6. الاستعادة السريعة (Quick Recovery)

### سيناريو 1: فقدان بيانات جزئي
```bash
# استعادة جدول واحد
pg_dump $DATABASE_URL --table=schools_attendance | gzip > attendance_backup.sql.gz
psql $DATABASE_URL < attendance_backup.sql
```

### سيناريو 2: فقدان كامل لقاعدة البيانات
```bash
# استعادة كاملة من آخر نسخة احتياطية
./scripts/restore_database.sh afaq_tech_backup_20260818_0200.sql.gz.gpg
```

### سيناريو 3: حذف خاطئ
```bash
# استعادة من Versioning
aws s3api list-object-versions --bucket afaq-tech-backups --prefix backups/
aws s3api get-object --bucket afaq-tech-backups --key backups/old_backup.sql.gz restored.sql.gz
```
