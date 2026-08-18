# خطة هندسة نظام العمل بدون إنترنت (IndexedDB Offline)

> تاريخ التوثيق: 18 أغسطس 2026
> الغرض: توثيق التصميم الهندسي والمعماري لنظام المزامنة بدون إنترنت عبر IndexedDB في منصة آفاق تكنولوجي.

---

## 1. الفكرة والهدف
توفير تجربة مستخدم سلسة حتى عند فقدان الاتصال بالإنترنت، مع التركيز على:
- **حضور الطلاب**: تسجيل الحضور/الغياب بدون إنترنت ثم المزامنة عند الاتصال.
- **واجبات الطلاب**: عرض الواجبات وتسليمها بدون إنترنت.
- **درجات الطلاب**: عرض الدرجات المخزنة مسبقاً.
- **الجداول الدراسية**: عرض الجدول بدون إنترنت.

---

## 2. المكونات التقنية

### أ. تقنية التخزين (`idb` library)
```typescript
// frontend/src/lib/offline/db.ts
import { openDB, DBSchema } from 'idb';

interface AfaqDB extends DBSchema {
    pendingAttendance: {
        key: string;
        value: {
            studentId: number;
            sectionId: number;
            date: string;
            status: 'present' | 'absent';
            recordedBy: number;
            syncedAt?: string;
        };
        indexes: { 'by-date': string };
    };
    pendingSubmissions: {
        key: string;
        value: {
            assignmentId: number;
            studentId: number;
            notes: string;
            file?: Blob;
            syncedAt?: string;
        };
    };
    cachedTimetable: {
        key: number;
        value: {
            sectionId: number;
            slots: any[];
            lastSync: string;
        };
    };
    cachedGrades: {
        key: number;
        value: {
            studentId: number;
            grades: any[];
            lastSync: string;
        };
    };
}

const db = await openDB<AfaqDB>('afaq-tech-offline', 1, {
    upgrade(db) {
        const attendanceStore = db.createObjectStore('pendingAttendance', { keyPath: 'id', autoIncrement: true });
        attendanceStore.createIndex('by-date', 'date');
        db.createObjectStore('pendingSubmissions', { keyPath: 'id', autoIncrement: true });
        db.createObjectStore('cachedTimetable', { keyPath: 'sectionId' });
        db.createObjectStore('cachedGrades', { keyPath: 'studentId' });
    },
});
```

### ب. Service Worker (`public/sw.js`)
```javascript
// استراتيجية Cache-First للملفات الثابتة
// استراتيجية Network-First للبيانات الديناميكية
self.addEventListener('fetch', (event) => {
    if (event.request.url.includes('/api/v1/')) {
        // Network-First for API calls
        event.respondWith(
            fetch(event.request).catch(() => caches.match(event.request))
        );
    } else {
        // Cache-First for static assets
        event.respondWith(
            caches.match(event.request).then(response => response || fetch(event.request))
        );
    }
});
```

### ج. مزامنة البيانات (`SyncManager`)
```typescript
// frontend/src/lib/offline/sync.ts
export class OfflineSync {
    private db: AfaqDB;

    async queueAttendance(data: AttendanceRecord): Promise<void> {
        await this.db.add('pendingAttendance', { ...data, id: crypto.randomUUID() });
        this.registerSync('sync-attendance');
    }

    async queueSubmission(data: SubmissionRecord): Promise<void> {
        await this.db.add('pendingSubmissions', { ...data, id: crypto.randomUUID() });
        this.registerSync('sync-submissions');
    }

    private async registerSync(tag: string): Promise<void> {
        if ('sync' in self.registration) {
            await self.registration.sync.register(tag);
        }
    }

    async processPendingAttendance(): Promise<void> {
        const pending = await this.db.getAll('pendingAttendance');
        for (const record of pending) {
            try {
                await api.post('/schools/attendance/', record);
                await this.db.delete('pendingAttendance', record.id);
            } catch (e) {
                console.error('Sync failed for attendance:', record.id);
            }
        }
    }
}
```

---

## 3. بيانات قابلة للتخزين مؤقتاً

| البيانات | TTL الكاش | الطريقة |
|----------|----------|---------|
| الجدول الدراسي | 7 أيام | Cache-First |
| الدرجات | 24 ساعة | Cache-First |
| الواجبات | 12 ساعة | Network-First |
| الحضور/الغياب | لا ينتهي (حتى المزامنة) | IndexedDB Queue |
| الملفات الشخصية | 7 أيام | Cache-First |
| الترجمات | 30 يوم | Cache-First |

---

## 4. مؤشر الاتصال (Online/Offline Indicator)

```typescript
// frontend/src/components/OfflineIndicator.tsx
export function OfflineIndicator() {
    const [isOnline, setIsOnline] = useState(navigator.onLine);
    const [pendingCount, setPendingCount] = useState(0);

    useEffect(() => {
        const handleOnline = () => {
            setIsOnline(true);
            syncPendingData(); // مزامنة تلقائية عند العودة
        };
        const handleOffline = () => setIsOnline(false);

        window.addEventListener('online', handleOnline);
        window.addEventListener('offline', handleOffline);
        return () => {
            window.removeEventListener('online', handleOnline);
            window.removeEventListener('offline', handleOffline);
        };
    }, []);

    if (isOnline) return null;

    return (
        <div className="fixed bottom-4 left-4 bg-yellow-500 text-white px-4 py-2 rounded-lg shadow-lg">
            <span>⚡ وضع عدم الاتصال — {pendingCount} عناصر تنتظر المزامنة</span>
        </div>
    );
}
```

---

## 5. الحدود والقيود
- **لا يُسمح** بالحذف بدون إنترنت (يجب الاتصال أولاً)
- **الحجم الأقصى** لـ IndexedDB: 50MB لكل مستخدم
- **التنظيف التلقائي**: البيانات المزامنة تُحذف بعد 7 أيام
- **الʺConflict Resolution"**: آخر تعديل يفوز (Last-Write-Wins) مع عرض تغييرات
