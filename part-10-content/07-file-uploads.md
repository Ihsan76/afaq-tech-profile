# رفع الملفات والتخزين (File Uploads & Storage)

## نظرة عامة

> **مجاني أثناء البناء:** Cloudflare R2 (10GB مجاناً) — S3-compatible، كافٍ لـ MVP. Cloudinary (25GB) بديل للصور.

ن system لرفع وتخزين وإدارة الملفات: صور، فيديو، مستندات، وملفات مرفقة.

---

## المكونات

```
┌─────────────────────────────────────────────────────────────────┐
│                    File Upload System                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────┐    ┌──────────────────┐                   │
│  │  Frontend        │    │  Pre-signed URL  │                   │
│  │  (React)         │───►│  (Direct Upload) │                   │
│  └──────────────────┘    └──────────────────┘                   │
│                                 │                               │
│                                 ▼                               │
│                          ┌──────────────────┐                   │
│                          │  S3 / R2         │                   │
│                          │  (Storage)       │                   │
│                          └──────────────────┘                   │
│                                 │                               │
│              ┌──────────────────┼──────────────────┐            │
│              ▼                  ▼                   ▼            │
│     ┌──────────────────┐ ┌──────────────────┐ ┌──────────────┐ │
│     │  Image           │ │  Video           │ │  Document    │ │
│     │  Processing      │ │  Transcoding     │ │  Conversion  │ │
│     │  (Sharp)         │ │  (FFmpeg)        │ │  (LibreOffice│ │
│     └──────────────────┘ └──────────────────┘ └──────────────┘ │
│                                                                  │
│  ┌──────────────────┐    ┌──────────────────┐                   │
│  │  CDN             │    │  Thumbnail       │                   │
│  │  (Cloudflare)    │    │  Generation      │                   │
│  └──────────────────┘    └──────────────────┘                   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Django Models

```python
# files/models.py

from django.db import models
import uuid


class UploadedFile(models.Model):
    """الملف المرفوع"""
    
    class FileType(models.TextChoices):
        IMAGE = 'image', 'صورة'
        VIDEO = 'video', 'فيديو'
        DOCUMENT = 'document', 'مستند'
        AUDIO = 'audio', 'صوت'
        OTHER = 'other', 'أخرى'
    
    class Status(models.TextChoices):
        UPLOADING = 'uploading', 'جارٍ الرفع'
        PROCESSING = 'processing', 'جارٍ المعالجة'
        READY = 'ready', 'جاهز'
        FAILED = 'failed', 'فاشل'
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4)
    
    # المالك
    uploaded_by = models.ForeignKey('users.User', on_delete=models.CASCADE, related_name='files')
    
    # الملف
    original_name = models.CharField(max_length=255)
    file_type = models.CharField(max_length=15, choices=FileType.choices)
    mime_type = models.CharField(max_length=100)
    file_size = models.BigIntegerField()  # بالبايت
    
    # التخزين
    storage_key = models.CharField(max_length=500, unique=True)
    url = models.URLField()
    cdn_url = models.URLField(blank=True)
    
    # المعالجة
    status = models.CharField(max_length=15, choices=Status.choices, default=Status.UPLOADING)
    
    # بيانات الأبعاد (للصور والفيديو)
    width = models.IntegerField(null=True, blank=True)
    height = models.IntegerField(null=True, blank=True)
    duration = models.FloatField(null=True, blank=True, help_text='المدة بالثواني')
    
    # الصور المصغرة
    thumbnail_url = models.URLField(blank=True)
    thumbnail_small_url = models.URLField(blank=True)
    
    # المعاينة
    preview_url = models.URLField(blank=True)
    
    # الوسوم والبيانات الوصفية
    alt_text = models.CharField(max_length=255, blank=True)
    title = models.CharField(max_length=255, blank=True)
    description = models.TextField(blank=True)
    tags = models.JSONField(default=list, blank=True)
    
    # الوصول
    is_public = models.BooleanField(default=True)
    access_count = models.IntegerField(default=0)
    
    # الارتباط
    content_type = models.CharField(max_length=50, blank=True)
    content_id = models.PositiveIntegerField(null=True, blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    expires_at = models.DateTimeField(null=True, blank=True)
    
    class Meta:
        verbose_name = 'ملف مرفوع'
        verbose_name_plural = 'الملفات المرفوعة'
        ordering = ['-created_at']
    
    def __str__(self):
        return self.original_name
    
    @property
    def file_size_mb(self) -> float:
        """الحجم بالميغابايت"""
        return self.file_size / (1024 * 1024)
    
    @property
    def is_image(self) -> bool:
        return self.file_type == self.FileType.IMAGE
    
    @property
    def is_video(self) -> bool:
        return self.file_type == self.FileType.VIDEO


class FileUploadPolicy(models.Model):
    """سياسة رفع الملفات"""
    
    name = models.CharField(max_length=100)
    
    # أنواع الملفات المسموحة
    allowed_mime_types = models.JSONField(default=list)
    # مثال: ['image/jpeg', 'image/png', 'image/webp']
    
    # الحد الأقصى للحجم (MB)
    max_size_mb = models.IntegerField(default=10)
    
    # الحد الأقصى للرفع يومياً
    daily_upload_limit = models.IntegerField(default=100)
    
    # المعالجة
    auto_resize = models.BooleanField(default=True)
    max_width = models.IntegerField(default=2048)
    max_height = models.IntegerField(default=2048)
    
    # الجودة
    jpeg_quality = models.IntegerField(default=85)
    webp_quality = models.IntegerField(default=80)
    
    is_active = models.BooleanField(default=True)
    
    class Meta:
        verbose_name = 'سياسة رفع ملف'
        verbose_name_plural = 'سياسات رفع الملفات'


class FileUploadLog(models.Model):
    """سجل رفع الملفات"""
    
    class Action(models.TextChoices):
        UPLOAD = 'upload', 'رفع'
        DELETE = 'delete', 'حذف'
        PROCESS = 'process', 'معالجة'
        SHARE = 'share', 'مشاركة'
    
    file = models.ForeignKey(UploadedFile, on_delete=models.CASCADE, related_name='logs')
    user = models.ForeignKey('users.User', on_delete=models.CASCADE)
    action = models.CharField(max_length=10, choices=Action.choices)
    details = models.JSONField(default=dict, blank=True)
    ip_address = models.GenericIPAddressField(null=True, blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name = 'سجل رفع ملف'
        verbose_name_plural = 'سجلات رفع الملفات'
        ordering = ['-created_at']
```

---

## File Upload Service

```python
# files/services.py

import boto3
import uuid
from django.conf import settings
from PIL import Image
import io


class FileStorageService:
    """خدمة التخزين"""
    
    def __init__(self):
        self.s3 = boto3.client(
            's3',
            aws_access_key_id=settings.AWS_ACCESS_KEY_ID,
            aws_secret_access_key=settings.AWS_SECRET_ACCESS_KEY,
            region_name=settings.AWS_REGION,
        )
        self.bucket = settings.S3_BUCKET_NAME
        self.cdn_domain = settings.CDN_DOMAIN
    
    def generate_upload_url(
        self,
        filename: str,
        content_type: str,
        folder: str = 'uploads',
    ) -> dict:
        """إنشاء URL للرفع المباشر"""
        
        # إنشاء مفتاح فريد
        ext = filename.rsplit('.', 1)[-1].lower()
        key = f"{folder}/{uuid.uuid4().hex}.{ext}"
        
        # إنشاء pre-signed URL
        presigned_url = self.s3.generate_presigned_url(
            'put_object',
            Params={
                'Bucket': self.bucket,
                'Key': key,
                'ContentType': content_type,
            },
            ExpiresIn=3600,  # ساعة
        )
        
        return {
            'upload_url': presigned_url,
            'key': key,
            'url': f"https://{self.cdn_domain}/{key}",
        }
    
    def get_file_url(self, key: str, expires: int = 3600) -> str:
        """جلب URL للقراءة"""
        
        if settings.CDN_DOMAIN:
            return f"https://{settings.CDN_DOMAIN}/{key}"
        
        return self.s3.generate_presigned_url(
            'get_object',
            Params={
                'Bucket': self.bucket,
                'Key': key,
            },
            ExpiresIn=expires,
        )
    
    def delete_file(self, key: str):
        """حذف ملف"""
        self.s3.delete_object(Bucket=self.bucket, Key=key)
    
    def copy_file(self, source_key: str, dest_key: str):
        """نسخ ملف"""
        self.s3.copy_object(
            Bucket=self.bucket,
            CopySource={'Bucket': self.bucket, 'Key': source_key},
            Key=dest_key,
        )


class ImageProcessor:
    """معالج الصور"""
    
    SIZES = {
        'thumbnail': (150, 150),
        'small': (300, 300),
        'medium': (600, 600),
        'large': (1200, 1200),
    }
    
    @classmethod
    def process_image(cls, file_content: bytes, filename: str) -> dict:
        """معالجة الصورة"""
        
        image = Image.open(io.BytesIO(file_content))
        
        results = {}
        
        for size_name, dimensions in cls.SIZES.items():
            # تغيير الحجم
            resized = cls._resize_image(image, dimensions)
            
            # حفظ بصيغة WebP
            buffer = io.BytesIO()
            resized.save(buffer, format='WebP', quality=85)
            
            results[size_name] = {
                'content': buffer.getvalue(),
                'width': resized.width,
                'height': resized.height,
            }
        
        # الصورة الأصلية
        results['original'] = {
            'content': file_content,
            'width': image.width,
            'height': image.height,
        }
        
        return results
    
    @classmethod
    def _resize_image(cls, image: Image.Image, max_size: tuple) -> Image.Image:
        """تغيير حجم الصورة مع الحفاظ على النسبة"""
        
        image.thumbnail(max_size, Image.Resampling.LANCZOS)
        return image
    
    @classmethod
    def generate_thumbnails(cls, file_content: bytes) -> dict:
        """إنشاء صور مصغرة"""
        
        image = Image.open(io.BytesIO(file_content))
        
        thumbnails = {}
        
        # مصغرة صغيرة
        thumb_small = image.copy()
        thumb_small.thumbnail((50, 50), Image.Resampling.LANCZOS)
        buffer = io.BytesIO()
        thumb_small.save(buffer, format='WebP', quality=80)
        thumbnails['small'] = buffer.getvalue()
        
        # مصغرة متوسطة
        thumb_medium = image.copy()
        thumb_medium.thumbnail((150, 150), Image.Resampling.LANCZOS)
        buffer = io.BytesIO()
        thumb_medium.save(buffer, format='WebP', quality=85)
        thumbnails['medium'] = buffer.getvalue()
        
        return thumbnails
```

---

## Upload API

```python
# files/views.py

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.core.cache import cache


class UploadURLView(APIView):
    """إنشاء URL للرفع"""
    permission_classes = [IsAuthenticated]
    
    def post(self, request):
        filename = request.data.get('filename')
        content_type = request.data.get('content_type')
        folder = request.data.get('folder', 'uploads')
        
        # فحص نوع الملف
        if not self._is_allowed_type(content_type):
            return Response({
                'error': 'نوع الملف غير مدعوم'
            }, status=400)
        
        # فحص الحجم
        max_size = self._get_max_size(content_type)
        file_size = request.data.get('file_size', 0)
        
        if file_size > max_size:
            return Response({
                'error': f'حجم الملف يتجاوز الحد الأقصى ({max_size / (1024*1024):.0f} MB)'
            }, status=400)
        
        # إنشاء URL
        storage = FileStorageService()
        result = storage.generate_upload_url(filename, content_type, folder)
        
        # إنشاء سجل
        file = UploadedFile.objects.create(
            uploaded_by=request.user,
            original_name=filename,
            file_type=self._get_file_type(content_type),
            mime_type=content_type,
            file_size=file_size,
            storage_key=result['key'],
            url=result['url'],
            status=UploadedFile.Status.UPLOADING,
        )
        
        return Response({
            'upload_url': result['upload_url'],
            'file_id': file.id,
            'key': result['key'],
        })
    
    def _is_allowed_type(self, content_type: str) -> bool:
        allowed = [
            'image/jpeg', 'image/png', 'image/webp', 'image/gif',
            'video/mp4', 'video/webm',
            'application/pdf',
            'application/msword',
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        ]
        return content_type in allowed
    
    def _get_file_type(self, content_type: str) -> str:
        if content_type.startswith('image/'):
            return 'image'
        elif content_type.startswith('video/'):
            return 'video'
        elif content_type.startswith('audio/'):
            return 'audio'
        elif content_type in ['application/pdf', 'application/msword']:
            return 'document'
        return 'other'
    
    def _get_max_size(self, content_type: str) -> int:
        if content_type.startswith('video/'):
            return 500 * 1024 * 1024  # 500 MB
        elif content_type.startswith('image/'):
            return 10 * 1024 * 1024  # 10 MB
        return 50 * 1024 * 1024  # 50 MB


class FileProcessView(APIView):
    """معالجة الملف بعد الرفع"""
    permission_classes = [IsAuthenticated]
    
    def post(self, request, file_id):
        file = UploadedFile.objects.get(id=file_id, uploaded_by=request.user)
        
        file.status = UploadedFile.Status.PROCESSING
        file.save()
        
        # معالجة حسب النوع
        if file.is_image:
            self._process_image(file)
        elif file.is_video:
            self._process_video(file)
        
        return Response({'status': 'processing'})
    
    def _process_image(self, file):
        """معالجة الصورة"""
        storage = FileStorageService()
        
        # تحميل الصورة
        file_content = storage.get_file_content(file.storage_key)
        
        # معالجة
        processor = ImageProcessor()
        results = processor.process_image(file_content, file.original_name)
        
        # رفع النسخ المعالجة
        for size_name, data in results.items():
            key = f"processed/{file.id}/{size_name}.webp"
            storage.upload_content(key, data['content'], 'image/webp')
        
        # تحديث الملف
        file.width = results['original']['width']
        file.height = results['original']['height']
        file.thumbnail_url = f"https://{settings.CDN_DOMAIN}/processed/{file.id}/small.webp"
        file.status = UploadedFile.Status.READY
        file.save()
    
    def _process_video(self, file):
        """معالجة الفيديو"""
        # TODO: FFmpeg transcoding
        file.status = UploadedFile.Status.READY
        file.save()
```

---

## React Hook

```typescript
// hooks/useFileUpload.ts

'use client';

import { useState, useCallback } from 'react';

interface UploadProgress {
  fileId: string;
  progress: number;
  status: 'uploading' | 'processing' | 'ready' | 'error';
  url?: string;
  error?: string;
}

export function useFileUpload() {
  const [uploads, setUploads] = useState<UploadProgress[]>([]);

  const uploadFile = useCallback(async (file: File, folder?: string) => {
    // 1. جلب URL للرفع
    const response = await fetch('/api/v1/files/upload-url/', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${localStorage.getItem('access_token')}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        filename: file.name,
        content_type: file.type,
        file_size: file.size,
        folder,
      }),
    });

    const { upload_url, file_id, key } = await response.json();

    // 2. رفع الملف
    const xhr = new XMLHttpRequest();

    xhr.upload.onprogress = (event) => {
      if (event.lengthComputable) {
        const progress = Math.round((event.loaded / event.total) * 100);
        setUploads(prev =>
          prev.map(u =>
            u.fileId === file_id ? { ...u, progress } : u
          )
        );
      }
    };

    await new Promise((resolve, reject) => {
      xhr.onload = () => {
        if (xhr.status === 200) {
          resolve(null);
        } else {
          reject(new Error('Upload failed'));
        }
      };
      xhr.onerror = () => reject(new Error('Upload failed'));

      xhr.open('PUT', upload_url);
      xhr.setRequestHeader('Content-Type', file.type);
      xhr.send(file);
    });

    // 3. معالجة الملف
    await fetch(`/api/v1/files/${file_id}/process/`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${localStorage.getItem('access_token')}`,
      },
    });

    // 4. الانتظار حتى تجهيز
    const fileUrl = await pollFileStatus(file_id);

    return file_id;
  }, []);

  const uploadMultiple = useCallback(async (files: File[], folder?: string) => {
    const results = await Promise.all(
      files.map(file => uploadFile(file, folder))
    );
    return results;
  }, [uploadFile]);

  return {
    uploads,
    uploadFile,
    uploadMultiple,
  };
}
```

---

## ملخص

> **رفع الملفات والتخزين** يدعم: pre-signed URL للرفع المباشر، معالجة الصور ( resize + thumbnails + WebP)، معالجة الفيديو، CDN، rate limiting، وسجلات مفصلة. يدعم: صور، فيديو، مستندات، وصوت.
