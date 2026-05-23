# 🎮 PS Cafe Manager — V6.1.1 Live Hotfix

## التعديلات المنفذة في هذه النسخة

- إصلاح تفعيل الإشعارات على Android Chrome: لا طلب تلقائي ولا رسالة مضللة؛ يتم عرض النتيجة الحقيقية.
- جعل حالة المزامنة صادقة: لا تظهر `Synced ✓` إلا بعد نجاح طلب فعلي إلى Supabase.
- إضافة آخر وقت مزامنة ناجح ورسالة خطأ واضحة داخل الإعدادات.
- إضافة فحص تحديث وتحديث إجباري آمن يمسح ملفات الكاش فقط **ولا يمسح بيانات المحل**.
- إصلاح استراتيجية الـ PWA حتى لا تظل نسخة قديمة من `index.html` عالقة في الهاتف.
- إضافة طباعة فاتورة مستقلة تعمل بصورة أفضل على طابعات الكمبيوتر وPDF.
- إزالة عرض كلمة المرور الافتراضية من شاشة الدخول وإضافة تحذير واضح لتغييرها قبل التشغيل الحقيقي.

> ملاحظة أمان مهمة: هذه النسخة ما زالت نموذجًا محليًا يستخدم حسابات داخل المتصفح وبيانات الدخول الافتراضية. لا تُستخدم كنسخة تشغيل تجارية نهائية قبل مرحلة الأمان والصلاحيات وقاعدة البيانات.

---

إدارة كافيه البلايستيشن — جلسات مفتوحة، مباريات بوقت محدد، فواتير، تقارير، مزامنة Supabase.

---

## 🚀 رفع على GitHub Pages (خطوة بخطوة)

### الخطوة 1 — إنشاء حساب GitHub
1. افتح [github.com](https://github.com)
2. اضغط **Sign up** وسجل حساب جديد

### الخطوة 2 — إنشاء Repository جديد
1. اضغط زر **"+"** في الأعلى → **New repository**
2. اسم الـ Repository: `ps-cafe-manager`
3. اختر **Public**
4. اضغط **Create repository**

### الخطوة 3 — رفع الملفات
**الطريقة الأسهل (بدون Git):**
1. في صفحة الـ repository الجديد اضغط **"uploading an existing file"**
2. ارفع **كل الملفات** من الـ ZIP الذي نزلته:
   - `index.html`
   - `manifest.json`
   - `sw.js`
   - `.gitignore`
   - مجلد `icons/` بكل محتوياته
   - مجلد `.github/` بكل محتوياته
3. اكتب في خانة الـ commit: `Initial release`
4. اضغط **Commit changes**

### الخطوة 4 — تفعيل GitHub Pages
1. افتح **Settings** في الـ repository
2. من القائمة الجانبية اختر **Pages**
3. في **Source** اختر **GitHub Actions**
4. احفظ

### الخطوة 5 — انتظر الـ Deploy
1. افتح تبويب **Actions** في الـ repository
2. هتلاقي workflow بيشتغل (دقيقة تقريباً)
3. لما يخلص هيظهر ✅ بدل ⏳

### الخطوة 6 — رابط تطبيقك
```
https://USERNAME.github.io/ps-cafe-manager
```
استبدل `USERNAME` باسم حسابك على GitHub.

---

## 📱 تنزيل كـ تطبيق على الهاتف

### Android (Chrome)
1. افتح الرابط في Chrome
2. اضغط **⋮** (القائمة) → **Add to Home screen**
3. اضغط **Install**
4. التطبيق يظهر على الشاشة الرئيسية 🎮

### iPhone/iPad (Safari)
1. افتح الرابط في Safari
2. اضغط **⬆ Share** (السهم للأعلى)
3. اختر **Add to Home Screen**
4. اضغط **Add**

---

## ⚙️ ربط Supabase (للمزامنة بين أجهزة متعددة)

### إنشاء قاعدة بيانات مجانية
1. افتح [supabase.com](https://supabase.com) → **Start for free**
2. أنشئ **New Project**
3. من **Settings → API** خذ:
   - **Project URL**: مثل `https://xxx.supabase.co`
   - **anon public key**: مفتاح طويل يبدأ بـ `eyJ`

### إنشاء الجدول
افتح **SQL Editor** في Supabase والصق هذا:
```sql
create table if not exists ps_cafe_state (
  id text primary key,
  data jsonb not null,
  updated_at timestamptz default now()
);

-- تنبيه: السياسة التالية مناسبة للاختبار فقط وليست للإنتاج التجاري
alter table ps_cafe_state enable row level security;
create policy "allow_all" on ps_cafe_state for all using (true) with check (true);
```
اضغط **Run**.

### ربط التطبيق
1. افتح تطبيقك → **الإعدادات**
2. في **المزامنة Online** اختر **Hybrid Supabase**
3. الصق الـ URL والـ Key
4. اضغط **حفظ الإعدادات**
5. اضغط **مزامنة الآن** ✅

---

## 🔄 هيكل الملفات

```
ps-cafe-manager/
├── index.html          ← التطبيق الكامل
├── manifest.json       ← إعدادات PWA
├── sw.js               ← Service Worker (Offline)
├── .gitignore
├── README.md
├── icons/
│   ├── icon-72.png
│   ├── icon-96.png
│   ├── icon-128.png
│   ├── icon-144.png
│   ├── icon-152.png
│   ├── icon-192.png
│   ├── icon-384.png
│   └── icon-512.png
└── .github/
    └── workflows/
        └── deploy.yml  ← Auto-deploy script
```

---

## 🛡️ الخصائص التقنية

| الخاصية | التفاصيل |
|---------|---------|
| **PWA** | ✅ Manifest + Service Worker + Offline |
| **Offline** | ✅ يشتغل بدون نت بالكامل |
| **Sync** | ✅ Hybrid: Offline → Queue → Auto Sync |
| **Mobile** | ✅ Responsive RTL Arabic |
| **Install** | ✅ Add to Home Screen Android + iOS |
| **Cache** | ✅ Cache First strategy |
| **Update** | ✅ Auto-check كل 60 ثانية |



---

## ✅ اختبار النسخة بعد الرفع

1. سجّل الدخول وأول شيء غيّر كلمة المرور الافتراضية من تبويب **المستخدمين**.
2. افتح الإعدادات وتأكد أن الإصدار الظاهر هو `V6.1.1`.
3. اضغط **تفعيل الإشعارات**؛ يجب أن يظهر طلب Chrome الحقيقي أو رسالة حالة واضحة، ولا تظهر الرسالة القديمة المضللة.
4. في المزامنة، لا تعتبر الحالة ناجحة إلا إذا ظهرت `Synced ✓` ووقت **آخر مزامنة ناجحة** بعد الاتصال الفعلي.
5. أنشئ جلسة تجريبية، أنهِها، افتح الفاتورة واضغط **طباعة / PDF** للتأكد من ظهور فاتورة منفصلة واضحة.
6. عند وجود نسخة قديمة على الهاتف، استخدم **تحديث إجباري آمن** من الإعدادات ثم افتح التطبيق مرة أخرى.
