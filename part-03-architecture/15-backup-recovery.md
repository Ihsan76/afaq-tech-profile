# النسخ الاحتياطي والاستعادة (Backup & Recovery)

## نظرة عامة

استراتيجية شاملة للنسخ الاحتياطي لحماية البيانات مع ضمان الاستمرارية.

---

## الأهداف

| المقياس | الهدف | التفصيل |
|---------|-------|---------|
| **RTO** (وقت التعافي) | < 1 ساعة | الوقت الأقصى للتعافي بعد كارثة |
| **RPO** (نقطة التعافي) | < 5 دقائق | أقصى قدر من البيانات الفائتة |
| **SLA** (اتفاقية مستوى الخدمة) | 99.9% | وقت التشغيل |

---

## طبقات النسخ الاحتياطي

```
┌─────────────────────────────────────────────────────────────────┐
│                    طبقات النسخ الاحتياطي                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  الطبقة 1: WAL Archiving (实时)                                 │
│  ├── PostgreSQL WAL files                                       │
│  ├── نسخ كل transactio                                          │
│  └── RPO: < 5 دقائق                                            │
│                                                                  │
│  الطبقة 2: Daily Backups                                        │
│  ├── pg_dump يومياً                                              │
│  ├── تخزين لمدة 30 يوم                                         │
│  └── RPO: < 24 ساعة                                            │
│                                                                  │
│  الطبقة 3: Weekly Backups                                       │
│  ├── نسخة أسبوعية كاملة                                        │
│  ├── تخزين لمدة 6 أشهر                                         │
│  └── RPO: < 7 أيام                                             │
│                                                                  │
│  الطبقة 4: Monthly Backups                                      │
│  ├── نسخة شهرية أرشيفية                                        │
│  ├── تخزين لمدة 3 سنوات                                        │
│  └── RPO: < 30 يوم                                             │
│                                                                  │
│  الطبقة 5: Offsite Backups                                      │
│  ├── نسخ في منطقة جغرافية مختلفة                               │
│  ├── تشفير جميع النسخ                                           │
│  └── لل disasters الكبيرة                                       │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## PostgreSQL Backup

### WAL Archiving (实时)

```bash
# postgresql.conf

# تفعيل WAL archiving
wal_level = replica
archive_mode = on
archive_command = 'cp %p /backup/wal/%f'
archive_timeout = 300  # 5 دقائق
```

### pg_dump يومي

```bash
#!/bin/bash
# scripts/backup-daily.sh

set -e

# المتغيرات
BACKUP_DIR="/backup/daily"
DATE=$(date +%Y%m%d_%H%M%S)
DB_NAME="afaq_production"
S3_BUCKET="s3://afaq-backups/daily"

# إنشاء النسخة الاحتياطية
echo "Creating backup for $DATE..."
pg_dump -Fc -v -f "$BACKUP_DIR/$DB_NAME_$DATE.dump" $DB_NAME

# تشفير النسخة
echo "Encrypting backup..."
gpg --symmetric --cipher-algo AES256 \
    --passphrase-file /etc/backup-key \
    --batch --yes \
    "$BACKUP_DIR/$DB_NAME_$DATE.dump"

# رفع إلى S3
echo "Uploading to S3..."
aws s3 cp "$BACKUP_DIR/$DB_NAME_$DATE.dump.gpg" "$S3_BUCKET/"

# حذف النسخ القديمة (أكثر من 30 يوم)
echo "Cleaning old backups..."
find "$BACKUP_DIR" -name "*.dump.gpg" -mtime +30 -delete

echo "Backup completed: $DATE"
```

### cron job

```bash
# /etc/cron.d/afaq-backup

# نسخ احتياطي يومي الساعة 2:00 صباحاً
0 2 * * * root /opt/afaq/scripts/backup-daily.sh >> /var/log/afaq-backup.log 2>&1

# نسخ احتياطي أسبوعي أحد الساعة 3:00 صباحاً
0 3 * * 0 root /opt/afaq/scripts/backup-weekly.sh >> /var/log/afaq-backup.log 2>&1

# نسخ احتياطي شهري أول واحد الساعة 4:00 صباحاً
0 4 1 * * root /opt/afaq/scripts/backup-monthly.sh >> /var/log/afaq-backup.log 2>&1
```

---

## Cloudflare R2 Configuration (S3-compatible)

```python
# backup/s3_storage.py

import boto3
from django.conf import settings
from datetime import datetime, timedelta


class R2BackupStorage:
    """تخزين النسخ الاحتياطية في Cloudflare R2 (S3-compatible)"""
    
    def __init__(self):
        self.s3 = boto3.client(
            's3',
            aws_access_key_id=settings.AWS_ACCESS_KEY_ID,
            aws_secret_access_key=settings.AWS_SECRET_ACCESS_KEY,
            region_name=settings.AWS_REGION,
        )
        self.bucket = settings.BACKUP_S3_BUCKET
    
    def upload_backup(self, file_path: str, backup_type: str) -> str:
        """رفع نسخة احتياطية"""
        date = datetime.now().strftime('%Y%m%d_%H%M%S')
        key = f"{backup_type}/{date}/{file_path.split('/')[-1]}"
        
        self.s3.upload_file(file_path, self.bucket, key)
        
        # تشفير عند الرفع
        self.s3.put_object_tagging(
            Bucket=self.bucket,
            Key=key,
            Tagging={
                'TagSet': [
                    {'Key': 'encrypted', 'Value': 'true'},
                    {'Key': 'backup-type', 'Value': backup_type},
                ]
            }
        )
        
        return f"s3://{self.bucket}/{key}"
    
    def list_backups(self, backup_type: str, days: int = 30) -> list:
        """ listing النسخ الاحتياطية"""
        prefix = f"{backup_type}/"
        cutoff = datetime.now() - timedelta(days=days)
        
        backups = []
        paginator = self.s3.get_paginator('list_objects_v2')
        
        for page in paginator.paginate(Bucket=self.bucket, Prefix=prefix):
            for obj in page.get('Contents', []):
                if obj['LastModified'].replace(tzinfo=None) > cutoff:
                    backups.append({
                        'key': obj['Key'],
                        'size': obj['Size'],
                        'last_modified': obj['LastModified'],
                    })
        
        return backups
    
    def delete_old_backups(self, backup_type: str, days: int):
        """حذف النسخ القديمة"""
        backups = self.list_backups(backup_type, days)
        
        for backup in backups:
            self.s3.delete_object(
                Bucket=self.bucket,
                Key=backup['key']
            )
```

---

## الاستعادة

### سكربت الاستعادة

```bash
#!/bin/bash
# scripts/restore-backup.sh

set -e

# المتغيرات
BACKUP_TYPE=$1  # daily, weekly, monthly
BACKUP_DATE=$2
DB_NAME="afaq_production"

echo "Starting restore from $BACKUP_TYPE backup: $BACKUP_DATE"

# 1. إيقاف التطبيق
echo "Stopping application..."
systemctl stop afaq-backend
systemctl stop afaq-frontend

# 2. تحميل النسخة الاحتياطية
echo "Downloading backup from S3..."
BACKUP_FILE="/tmp/restore_$BACKUP_DATE.dump"
aws s3 cp "s3://afaq-backups/$BACKUP_TYPE/$BACKUP_DATE/$DB_NAME_$BACKUP_DATE.dump.gpg" "$BACKUP_FILE.gpg"

# 3. فك التشفير
echo "Decrypting backup..."
gpg --decrypt --batch --yes \
    --passphrase-file /etc/backup-key \
    "$BACKUP_FILE.gpg" > "$BACKUP_FILE"

# 4. إيقاف PostgreSQL مؤقتاً
echo "Stopping PostgreSQL..."
systemctl stop postgresql

# 5. حذف قاعدة البيانات القديمة
echo "Dropping old database..."
dropdb $DB_NAME

# 6. إنشاء قاعدة البيانات الجديدة
echo "Creating new database..."
createdb $DB_NAME

# 7. استعادة البيانات
echo "Restoring database..."
pg_restore -v -d $DB_NAME "$BACKUP_FILE"

# 8. تشغيل PostgreSQL
echo "Starting PostgreSQL..."
systemctl start postgresql

# 9. تشغيل الهجرات
echo "Running migrations..."
python manage.py migrate --run-syncdb

# 10. تشغيل التطبيق
echo "Starting application..."
systemctl start afaq-backend
systemctl start afaq-frontend

# 11. تنظيف
rm "$BACKUP_FILE" "$BACKUP_FILE.gpg"

echo "Restore completed successfully!"
```

### API الاستعادة (Admin Only)

```python
# backup/views.py

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAdminUser
from django.core.management import call_command
import subprocess


class RestoreBackupView(APIView):
    """استعادة نسخة احتياطية"""
    permission_classes = [IsAdminUser]
    
    def post(self, request):
        backup_type = request.data.get('backup_type')
        backup_date = request.data.get('backup_date')
        confirm = request.data.get('confirm', False)
        
        if not confirm:
            return Response({
                'warning': 'هذا الإجراء سيحذف جميع البيانات الحالية',
                'confirm_required': True,
            })
        
        # تنفيذ الاستعادة
        try:
            result = subprocess.run(
                ['/opt/afaq/scripts/restore-backup.sh', backup_type, backup_date],
                capture_output=True,
                text=True,
                timeout=3600  # ساعة واحدة
            )
            
            if result.returncode == 0:
                return Response({
                    'status': 'success',
                    'message': 'تمت الاستعادة بنجاح',
                })
            else:
                return Response({
                    'status': 'error',
                    'message': result.stderr,
                }, status=500)
                
        except subprocess.TimeoutExpired:
            return Response({
                'status': 'error',
                'message': 'انتهت مهلة الاستعادة',
            }, status=500)
```

---

## المراقبة والإشعارات

```python
# backup/monitoring.py

from django.core.mail import send_mail
from django.utils import timezone
from datetime import timedelta


class BackupMonitor:
    """مراقبة النسخ الاحتياطية"""
    
    @classmethod
    def check_backup_health(cls):
        """فحص صحة النسخ الاحتياطية"""
        
        # فحص آخر نسخة يومية
        last_daily = cls.get_last_backup('daily')
        if not last_daily or last_daily < timezone.now() - timedelta(hours=25):
            cls.send_alert('daily_backup_missing', 'النسخة الاحتياطية اليومية متأخرة!')
        
        # فحص آخر نسخة أسبوعية
        last_weekly = cls.get_last_backup('weekly')
        if not last_weekly or last_weekly < timezone.now() - timedelta(days=8):
            cls.send_alert('weekly_backup_missing', 'النسخة الاحتياطية الأسبوعية متأخرة!')
        
        # فحص حجم النسخة
        backup_size = cls.get_last_backup_size('daily')
        if backup_size > 10 * 1024 * 1024 * 1024:  # 10 GB
            cls.send_alert('backup_too_large', f'حجم النسخة كبيرة جداً: {backup_size / (1024**3):.2f} GB')
    
    @classmethod
    def send_alert(cls, alert_type: str, message: str):
        """إرسال تنبيه"""
        send_mail(
            subject=f'⚠️ Backup Alert: {alert_type}',
            message=message,
            from_email='monitoring@afaq.app',
            recipient_list=['ops-team@afaq.app'],
        )
```

---

## ملخص

> **النسخ الاحتياطي والاستعادة** يشمل 5 طبقات: WAL Archiving، نسخ يومية، أسبوعية، شهرية، و Offsite. الأهداف: RTO < 1 ساعة، RPO < 5 دقائق. المكونات: سكربتات نسخ احتياطي، تشفير AES256، تخزين S3، مراقبة تلقائية، وAPI استعادة.
