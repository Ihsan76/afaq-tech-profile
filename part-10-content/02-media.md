# إدارة الوسائط

## التخزين

### الخيار الموصى به: Cloudflare R2

| الميزة | التفاصيل |
|--------|----------|
| **التكلفة** | $0.015/GB/شهر |
| **التحميل** | مجاني |
| **الـ API** | S3-compatible |
| **الحدود** | 10GB مجاني |

### الإعداد
```python
# settings.py
AWS_ACCESS_KEY_ID = env('R2_ACCESS_KEY_ID')
AWS_SECRET_ACCESS_KEY = env('R2_SECRET_ACCESS_KEY')
AWS_STORAGE_BUCKET_NAME = 'afaq-media'
AWS_S3_ENDPOINT_URL = f'https://{env("R2_ACCOUNT_ID")}.r2.cloudflarestorage.com'
AWS_S3_CUSTOM_DOMAIN = 'media.afaq.app'
AWS_DEFAULT_ACL = 'private'
AWS_S3_FILE_OVERWRITE = False
```

---

## إدارة الملفات

### رفع الملفات

```python
# services/media.py
class MediaService:
    
    ALLOWED_TYPES = {
        'image': ['image/jpeg', 'image/png', 'image/webp', 'image/gif'],
        'video': ['video/mp4', 'video/webm'],
        'document': ['application/pdf', 'application/msword'],
        'audio': ['audio/mpeg', 'audio/wav'],
    }
    
    MAX_SIZES = {
        'image': 10 * 1024 * 1024,      # 10MB
        'video': 100 * 1024 * 1024,     # 100MB
        'document': 20 * 1024 * 1024,   # 20MB
        'audio': 50 * 1024 * 1024,      # 50MB
    }
    
    @classmethod
    def upload(cls, file, user, usage_type='general'):
        """رفع ملف مع التحقق"""
        # تحديد نوع الملف
        file_type = cls._get_file_type(file.content_type)
        
        if not file_type:
            raise ValueError("نوع الملف غير مدعوم")
        
        # فحص الحجم
        if file.size > cls.MAX_SIZES[file_type]:
            raise ValueError(f"حجم الملف يتجاوز الحد الأقصى")
        
        # إنشاء مسار فريد
        file_path = cls._generate_path(file.name, file_type)
        
        # رفع الملف
        media = MediaFile.objects.create(
            file=file_path,
            original_name=file.name,
            file_type=file_type,
            usage_type=usage_type,
            file_size=file.size,
            mime_type=file.content_type,
            uploaded_by=user
        )
        
        return media
    
    @classmethod
    def _get_file_type(cls, mime_type):
        for file_type, mimes in cls.ALLOWED_TYPES.items():
            if mime_type in mimes:
                return file_type
        return None
    
    @classmethod
    def _generate_path(cls, filename, file_type):
        import uuid
        from datetime import datetime
        
        ext = filename.rsplit('.', 1)[-1]
        unique = uuid.uuid4().hex[:8]
        date_path = datetime.now().strftime('%Y/%m')
        
        return f"media/{file_type}s/{date_path}/{unique}.{ext}"
```

---

## تحسين الصور

```python
# services/image_optimizer.py
from PIL import Image
import io

class ImageOptimizer:
    
    SIZES = {
        'thumbnail': (150, 150),
        'small': (400, 400),
        'medium': (800, 800),
        'large': (1200, 1200),
    }
    
    @classmethod
    def optimize(cls, image_file, sizes=None):
        """تحسين الصورة بأحجام متعددة"""
        if sizes is None:
            sizes = ['thumbnail', 'small', 'medium', 'large']
        
        img = Image.open(image_file)
        variants = {}
        
        for size_name in sizes:
            width, height = cls.SIZES[size_name]
            
            # تصغير الصورة
            img_resized = img.copy()
            img_resized.thumbnail((width, height), Image.Resampling.LANCZOS)
            
            # حفظ بتنسيق WebP
            buffer = io.BytesIO()
            img_resized.save(buffer, format='WebP', quality=85)
            buffer.seek(0)
            
            variants[size_name] = buffer
        
        return variants
```

---

## CDN

```python
# Cloudflare CDN
CDN_SETTINGS = {
    'CACHE_CONTROL': {
        'images': 'public, max-age=31536000, immutable',
        'videos': 'public, max-age=86400',
        'documents': 'private, max-age=3600',
    },
    'CACHE_HEADERS': {
        'images': 'image/webp',
        'videos': 'video/mp4',
    }
}
```

---

## حذف الملفات

```python
def delete_media(media_id):
    """حذف ملف وسائط"""
    media = MediaFile.objects.get(id=media_id)
    
    # حذف من التخزين
    if media.file:
        media.file.delete(save=False)
    
    # حذف النسخ المحسّنة
    for variant in media.variants.values():
        if variant:
            # حذف من التخزين
            pass
    
    # حذف السجل
    media.delete()
```
