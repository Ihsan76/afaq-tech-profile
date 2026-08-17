# دليل ما قبل البدء (Quick Start Guide)

## الخطوة 1: إنشاء الحسابات

### 필수 (100% مجاناً)

| # | الخدمة | الرابط | لماذا؟ | التكلفة |
|---|--------|--------|--------|---------|
| 1 | **GitHub** | github.com | المستودع + CI/CD | مجاني |
| 2 | **Vercel** | vercel.com | استضافة الواجهة الأمامية | مجاني (Hobby) |
| 3 | **Railway** | railway.app | استضافة الخلفية + قاعدة البيانات | مجاني ($5 credit) |
| 4 | **Supabase** | supabase.com | PostgreSQL + Auth + Storage | مجاني |
| 5 | **Cloudflare** | cloudflare.com | DNS + CDN + SSL | مجاني |
| 6 | **Upstash** | upstash.com | Redis | مجاني |
| 7 | **Resend** | resend.com | بريد إلكتروني | مجاني (100/يوم) |
| 8 | **Sentry** | sentry.io | مراقبة الأخطاء | مجاني (5K/شهر) |

### اختياري (لاحقاً)

| # | الخدمة | الرابط | لماذا؟ | التكلفة |
|---|--------|--------|--------|---------|
| 9 | **Google Cloud** | console.cloud.google.com | Gemini API | مجاني (15 RPM) |
| 10 | **Twilio** | twilio.com | رسائل نصية | مدفوع |
| 11 | **Stripe** | stripe.com | دفع | مدفوع (2.9% + $0.30) |
| 12 | **Paymob** | paymob.com | دفع محلي (الشرق الأوسط) | مدفوع |

---

## الخطوة 2: إنشاء المستودع

```bash
# 1. أنشئ مستودع جديد على GitHub اسمه: afaq-tech
# 2. ثم شغّل:
git clone https://github.com/YOUR_USERNAME/afaq-tech.git
cd afaq-tech
```

---

## الخطوة 3: تثبيت الأدوات

### Docker (ضروري)
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install docker.io docker-compose-plugin
sudo usermod -aG docker $USER
# أعد تسجيل الدخول
docker --version
```

### Python
```bash
sudo apt install python3.12 python3.12-venv python3-pip
python3 --version  # يجب أن يظهر 3.12+
```

### Node.js
```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
node --version  # يجب أن يظهر v20+
```

### Git Hooks
```bash
pip install pre-commit
# سنضيف .pre-commit-config.yaml في المرحلة 0
```

---

## الخطوة 4: الحصول على المفاتيح

### بعد إنشاء الحسابات، احصل على:

| الخدمة | المفتاح | أين تجده |
|--------|---------|----------|
| **Supabase** | `SUPABASE_URL` | Settings > API |
| **Supabase** | `SUPABASE_KEY` | Settings > API > anon public |
| **Supabase** | `DATABASE_URL` | Settings > Database > Connection string |
| **Upstash** | `REDIS_URL` | Dashboard > copy URL |
| **Resend** | `RESEND_API_KEY` | Settings > API Keys |
| **Sentry** | `SENTRY_DSN` | Settings > Client Keys |
| **Gemini** | `GEMINI_API_KEY` | Google AI Studio |

> **ملاحظة:** سنحفظ هذه المفاتيح في ملف `.env` في المرحلة 0. لا تشاركها مع أحد.

---

## الخطوة 5: هيكل المشروع الأولي

```
afaq-tech/
├── backend/              # Django
│   ├── manage.py
│   ├── requirements.txt
│   ├── config/
│   │   ├── settings.py
│   │   ├── urls.py
│   │   └── wsgi.py
│   └── apps/
│       ├── users/
│       ├── academics/
│       ├── lessonplans/
│       └── ai/
├── frontend/             # Next.js
│   ├── package.json
│   ├── next.config.js
│   ├── src/
│   │   ├── app/
│   │   ├── components/
│   │   └── lib/
│   └── public/
├── docker-compose.yml
├── .env.example
└── README.md
```

---

## ملخص سريع

```
1. أنشئ حسابات على: GitHub, Vercel, Railway, Supabase, Cloudflare, Upstash, Resend, Sentry
2. شراء الدومين afaq.app (Namecheap أو Cloudflare)
3. تثبيت: Docker, Python 3.12+, Node.js 20+
4. إنشاء مستودع GitHub
5. حفظ المفاتيح في مكان آمن
6. نبدأ المرحلة 0!
```

---

*下一步: [المرحلة 0: البنية التحتية](02-mvp.md)*
