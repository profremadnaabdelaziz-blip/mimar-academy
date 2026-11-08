$ErrorActionPreference = "Stop"

if (!(Test-Path "src\components")) { Write-Host "❌ شغّل السكربت من جذر المشروع Mimar-Academy" -ForegroundColor Red; exit }

# نسخة احتياطية كاملة
$bak = "src_backup_v2_" + (Get-Date -Format "yyyyMMdd_HHmmss")
Copy-Item "src" $bak -Recurse
Write-Host "📦 نسخة احتياطية: $bak" -ForegroundColor Yellow

$utf8 = New-Object System.Text.UTF8Encoding($false)

function Write-File($path, $text) {
  $full = Join-Path (Get-Location).Path $path
  $dir = Split-Path $full -Parent
  if (!(Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  [IO.File]::WriteAllText($full, $text, $utf8)
}

function Patch($path, $old, $new) {
  $full = Join-Path (Get-Location).Path $path
  if (!(Test-Path $full)) { Write-Host "⚠️ غير موجود: $path" -ForegroundColor Yellow; return }
  $t = [IO.File]::ReadAllText($full)
  if ($t.Contains($new)) { return }
  if (-not $t.Contains($old)) { Write-Host "⚠️ لم أجد موضع التعديل في $path" -ForegroundColor Yellow; return }
  [IO.File]::WriteAllText($full, $t.Replace($old, $new), $utf8)
}

# ============================================================
# 1) Layout: الخطوط + PWA + تهيئة الوضع قبل الرسم
# ============================================================
Write-File "src/layouts/Layout.astro" @'
---
import '../styles/global.css';
interface Props { title: string; description?: string; }
const { title, description = "أكاديمية مِعْمَار للنجاح الدراسي: منصة تدمج العلوم الكونية والشرعية لتمكين الطالب المسلم إيمانياً ونفسياً وأكاديمياً." } = Astro.props;
const isProd = import.meta.env.PROD;
---
<!DOCTYPE html>
<html lang="ar" dir="rtl" class="scroll-smooth" data-theme="dark">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover" />
    <meta name="description" content={description} />
    <meta name="theme-color" content="#0D0E12" />
    <link rel="icon" href="/images/memaar-logo.png" />
    <link rel="manifest" href="/manifest.webmanifest" />
    <title>{title}</title>
    <script is:inline>
      (function () {
        var r = document.documentElement;
        r.classList.add('js');
        try { var t = localStorage.getItem('memaar_theme'); if (t === 'light' || t === 'dark') r.setAttribute('data-theme', t); } catch (e) {}
      })();
    </script>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Amiri+Quran&family=Amiri:ital,wght@0,400;0,700;1,400&family=Aref+Ruqaa:wght@400;700&family=Cairo:wght@300;400;600;700;900&family=Reem+Kufi:wght@400;500;700&display=swap" rel="stylesheet" />
  </head>
  <body class="bg-mem-black text-mem-ivory font-traditional min-h-screen antialiased selection:bg-mem-burgundy selection:text-white">
    <slot />
    {isProd && <script is:inline set:html="if('serviceWorker' in navigator){window.addEventListener('load',function(){navigator.serviceWorker.register('/sw.js');});}"></script>}
  </body>
</html>
'@

# ============================================================
# 2) PWA: manifest + service worker
# ============================================================
Write-File "public/manifest.webmanifest" @'
{
  "name": "أكاديمية مِعْمَار للنجاح الدراسي",
  "short_name": "مِعْمَار",
  "description": "منصة تدمج العلوم الكونية والشرعية لتمكين الطالب المسلم",
  "start_url": "/",
  "scope": "/",
  "display": "standalone",
  "lang": "ar",
  "dir": "rtl",
  "background_color": "#0D0E12",
  "theme_color": "#0D0E12",
  "icons": [
    { "src": "/images/memaar-logo.png", "sizes": "192x192", "type": "image/png", "purpose": "any" },
    { "src": "/images/memaar-logo.png", "sizes": "512x512", "type": "image/png", "purpose": "any" }
  ]
}
'@

Write-File "public/sw.js" @'
const CACHE = 'memaar-v1';
self.addEventListener('install', function (e) {
  self.skipWaiting();
  e.waitUntil(caches.open(CACHE).then(function (c) { return c.addAll(['/', '/images/memaar-logo.png']); }).catch(function () {}));
});
self.addEventListener('activate', function (e) {
  e.waitUntil(caches.keys().then(function (keys) {
    return Promise.all(keys.filter(function (k) { return k !== CACHE; }).map(function (k) { return caches.delete(k); }));
  }).then(function () { return self.clients.claim(); }));
});
self.addEventListener('fetch', function (e) {
  var r = e.request;
  if (r.method !== 'GET' || new URL(r.url).origin !== self.location.origin) return;
  e.respondWith(
    fetch(r).then(function (res) {
      var copy = res.clone();
      caches.open(CACHE).then(function (c) { c.put(r, copy); });
      return res;
    }).catch(function () {
      return caches.match(r).then(function (m) { return m || caches.match('/'); });
    })
  );
});
'@

# ============================================================
# 3) HeroBanner: جزيئات ذهبية + صور أكبر + أسماء ذهبية
# ============================================================
Write-File "src/components/HeroBanner.astro" @'
---
---
<section class="relative px-4 lg:px-8 pt-8 pb-4">
  <div class="hero-card relative mx-auto max-w-7xl rounded-3xl border-2 border-mem-gold/55 bg-gradient-to-b from-mem-panel to-mem-black p-5 lg:p-9 overflow-hidden gold-glow-soft">
    <canvas id="particles" class="absolute inset-0 w-full h-full pointer-events-none" aria-hidden="true"></canvas>

    <div class="grid grid-cols-12 gap-5 items-center mb-8">
      <div class="col-span-12 lg:col-span-4 flex justify-center gap-6">
        <figure class="text-center">
          <img src="/images/albani.jpg" alt="الشيخ الألباني" onerror="this.style.visibility='hidden'" class="scholar-img w-28 h-28 lg:w-36 lg:h-36 rounded-full object-cover" />
          <figcaption class="scholar-name text-xl lg:text-2xl mt-3">الألباني</figcaption>
        </figure>
        <figure class="text-center">
          <img src="/images/qaradawi.jpg" alt="الشيخ القرضاوي" onerror="this.style.visibility='hidden'" class="scholar-img w-28 h-28 lg:w-36 lg:h-36 rounded-full object-cover" />
          <figcaption class="scholar-name text-xl lg:text-2xl mt-3">القرضاوي</figcaption>
        </figure>
      </div>

      <div class="col-span-12 lg:col-span-4 flex flex-col items-center">
        <img src="/images/memaar-logo.png" alt="شعار أكاديمية مِعْمَار" class="w-36 h-36 object-contain" />
        <h1 class="mt-2 text-2xl lg:text-3xl font-bold text-gold-grad font-maryam text-center">أكاديمية مِعْمَار للنجاح الدراسي</h1>
        <div class="w-40 h-px shimmer-divider mt-3"></div>
      </div>

      <div class="col-span-12 lg:col-span-4 flex justify-center gap-6">
        <figure class="text-center">
          <img src="/images/einstein.jpg" alt="العالم أينشتاين" onerror="this.style.visibility='hidden'" class="scholar-img w-28 h-28 lg:w-36 lg:h-36 rounded-full object-cover" />
          <figcaption class="scholar-name text-xl lg:text-2xl mt-3">أينشتاين</figcaption>
        </figure>
        <figure class="text-center">
          <img src="/images/tesla.jpg" alt="العالم تيسلا" onerror="this.style.visibility='hidden'" class="scholar-img w-28 h-28 lg:w-36 lg:h-36 rounded-full object-cover" />
          <figcaption class="scholar-name text-xl lg:text-2xl mt-3">تيسلا</figcaption>
        </figure>
      </div>
    </div>

    <div class="grid grid-cols-12 gap-5">
      <div class="col-span-12 lg:col-span-3 bg-mem-black/60 border border-mem-gold/25 rounded-2xl p-4 text-center">
        <div class="text-5xl" aria-hidden="true">🎓</div>
        <p class="text-sm text-mem-gold font-amiri mt-2">علمٌ نافعٌ يرفعُ صاحبَه درجات</p>
      </div>
      <div class="col-span-12 lg:col-span-6">
        <a href="#" aria-label="مشاهدة: العالم أحمد زويل - نوبل الكيمياء 1999" class="group relative block aspect-video rounded-2xl border-2 border-mem-gold/60 overflow-hidden bg-mem-panel">
          <img src="/images/zewail-nobel.jpg" alt="العالم أحمد زويل" onerror="this.style.visibility='hidden'" class="absolute inset-0 w-full h-full object-cover opacity-70" />
          <div class="absolute inset-0 flex items-center justify-center"><span class="w-20 h-20 bg-mem-gold rounded-full text-mem-black text-3xl flex items-center justify-center group-hover:scale-110 transition-transform" aria-hidden="true">▶</span></div>
          <div class="absolute bottom-0 p-4 w-full text-center bg-gradient-to-t from-mem-black to-transparent">
            <p class="scholar-name text-2xl lg:text-3xl">العالم أحمد زويل</p>
            <p class="text-sm text-mem-ivory">نوبل الكيمياء (1999)</p>
          </div>
        </a>
      </div>
      <div class="col-span-12 lg:col-span-3 bg-mem-black/60 border border-mem-burgundy/60 rounded-2xl p-4">
        <p class="text-xs text-mem-gold mb-2">قال ابن تيمية - رحمه الله:</p>
        <blockquote class="text-sm text-mem-ivory font-amiri">«مَنْ كَانَ طَالِبًا لِلْعِلْمِ لِيُحْيِيَ بِهِ الْإِسْلَامَ، فَهُوَ مِنَ الصِّدِّيقِينَ»</blockquote>
      </div>
    </div>

    <div class="mt-7 rounded-2xl border border-mem-burgundy/60 bg-mem-burgundy/15 p-4 text-center">
      <p class="text-lg text-mem-ivory font-amiri">﴿ يَرْفَعِ اللَّهُ الَّذِينَ آمَنُوا مِنكُمْ وَالَّذِينَ أُوتُوا الْعِلْمَ دَرَجَاتٍ ﴾</p>
    </div>
  </div>
</section>

<script>
  const c = document.getElementById('particles');
  if (c && !matchMedia('(prefers-reduced-motion: reduce)').matches) {
    const ctx = c.getContext('2d');
    const dpr = Math.min(window.devicePixelRatio || 1, 2);
    let w = 0, h = 0, ps = [], raf = 0, visible = true;

    function resize() {
      const r = c.getBoundingClientRect();
      w = r.width; h = r.height;
      c.width = w * dpr; c.height = h * dpr;
      ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
      const weak = (navigator.hardwareConcurrency || 4) <= 2;
      const n = weak ? 18 : (w < 640 ? 24 : 55);
      ps = Array.from({ length: n }, function () {
        return { x: Math.random() * w, y: Math.random() * h, r: Math.random() * 1.8 + 0.6, vy: -(Math.random() * 0.25 + 0.05), vx: (Math.random() - 0.5) * 0.12, a: Math.random() * Math.PI * 2 };
      });
    }

    function frame(t) {
      const light = document.documentElement.getAttribute('data-theme') === 'light';
      const rgb = light ? '156,122,18' : '212,175,55';
      ctx.clearRect(0, 0, w, h);
      for (let i = 0; i < ps.length; i++) {
        const p = ps[i];
        p.x += p.vx; p.y += p.vy;
        if (p.y < -5) { p.y = h + 5; p.x = Math.random() * w; }
        if (p.x < -5) p.x = w + 5;
        if (p.x > w + 5) p.x = -5;
        const alpha = 0.25 + 0.35 * Math.abs(Math.sin(t / 1200 + p.a));
        ctx.fillStyle = 'rgba(' + rgb + ',' + alpha.toFixed(3) + ')';
        ctx.beginPath(); ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2); ctx.fill();
        for (let j = i + 1; j < ps.length; j++) {
          const q = ps[j]; const dx = p.x - q.x; const dy = p.y - q.y; const d = Math.sqrt(dx * dx + dy * dy);
          if (d < 90) {
            ctx.strokeStyle = 'rgba(' + rgb + ',' + (0.12 * (1 - d / 90)).toFixed(3) + ')';
            ctx.lineWidth = 0.6;
            ctx.beginPath(); ctx.moveTo(p.x, p.y); ctx.lineTo(q.x, q.y); ctx.stroke();
          }
        }
      }
      raf = (visible && !document.hidden) ? requestAnimationFrame(frame) : 0;
    }

    function start() { if (!raf && visible && !document.hidden) raf = requestAnimationFrame(frame); }

    resize();
    window.addEventListener('resize', resize);
    document.addEventListener('visibilitychange', start);
    if ('IntersectionObserver' in window) {
      new IntersectionObserver(function (es) { visible = es[0].isIntersecting; start(); }).observe(c);
    }
    start();
  }
</script>
'@

# ============================================================
# 4) GlobalFX: شريط التقدم + الوضع + الظهور التدريجي + الإمالة
# ============================================================
Write-File "src/components/GlobalFX.astro" @'
<div id="scroll-progress" aria-hidden="true"></div>

<script>
  const root = document.documentElement;

  function setTheme(t, persist) {
    root.setAttribute('data-theme', t);
    if (persist) { try { localStorage.setItem('memaar_theme', t); } catch (e) {} }
    document.querySelectorAll('[data-theme-icon]').forEach(function (s) { s.textContent = t === 'light' ? '🌙' : '☀️'; });
    document.querySelectorAll('[data-theme-toggle]').forEach(function (b) {
      b.setAttribute('aria-label', t === 'light' ? 'التبديل إلى الوضع الداكن' : 'التبديل إلى الوضع الفاتح');
    });
    const m = document.querySelector('meta[name="theme-color"]');
    if (m) m.setAttribute('content', t === 'light' ? '#FBF6EA' : '#0D0E12');
  }
  document.querySelectorAll('[data-theme-toggle]').forEach(function (b) {
    b.addEventListener('click', function () { setTheme(root.getAttribute('data-theme') === 'light' ? 'dark' : 'light', true); });
  });
  setTheme(root.getAttribute('data-theme') || 'dark', false);

  const bar = document.getElementById('scroll-progress');
  function onScroll() {
    const h = document.documentElement.scrollHeight - window.innerHeight;
    const p = h > 0 ? Math.min(1, window.scrollY / h) : 0;
    if (bar) bar.style.transform = 'scaleX(' + p + ')';
  }
  window.addEventListener('scroll', onScroll, { passive: true });
  onScroll();

  const items = Array.prototype.slice.call(document.querySelectorAll('[data-reveal]'));
  if ('IntersectionObserver' in window && items.length) {
    const io = new IntersectionObserver(function (entries) {
      entries.forEach(function (en) {
        if (!en.isIntersecting) return;
        const el = en.target;
        io.unobserve(el);
        el.classList.add('in');
        setTimeout(function () { el.classList.remove('reveal', 'in'); el.style.transitionDelay = ''; }, 1400);
      });
    }, { threshold: 0.08, rootMargin: '0px 0px -40px 0px' });
    items.forEach(function (el, i) {
      el.classList.add('reveal');
      if (el.classList.contains('pillar-card')) el.style.transitionDelay = ((i % 5) * 90) + 'ms';
      io.observe(el);
    });
  }

  if (matchMedia('(hover: hover) and (pointer: fine)').matches && !matchMedia('(prefers-reduced-motion: reduce)').matches) {
    document.querySelectorAll('.pillar-card').forEach(function (card) {
      card.addEventListener('pointermove', function (e) {
        const r = card.getBoundingClientRect();
        const x = (e.clientX - r.left) / r.width;
        const y = (e.clientY - r.top) / r.height;
        card.style.setProperty('--ry', ((x - 0.5) * 10).toFixed(2) + 'deg');
        card.style.setProperty('--rx', ((0.5 - y) * 10).toFixed(2) + 'deg');
        card.style.setProperty('--mx', (x * 100).toFixed(1) + '%');
        card.style.setProperty('--my', (y * 100).toFixed(1) + '%');
      });
      card.addEventListener('pointerleave', function () {
        card.style.setProperty('--rx', '0deg');
        card.style.setProperty('--ry', '0deg');
      });
    });
  }
</script>
'@

# ============================================================
# 5) StatsCounter: عدّاد الإنجازات
# ============================================================
Write-File "src/components/StatsCounter.astro" @'
---
import { memaarData } from '../data/memaarData';
const gates = memaarData.reduce((n, p) => n + p.gates.length, 0);
const axes = memaarData.reduce((n, p) => n + p.gates.reduce((m, g) => m + g.axes.length, 0), 0);
const stats = [
  { n: memaarData.length, label: 'معامير', icon: '🏛️' },
  { n: gates, label: 'بوابة', icon: '🚪' },
  { n: axes, label: 'محور', icon: '🧭' },
  { n: 2, label: 'شارعان: بناء وتعمق', icon: '🌉' }
];
---
<section class="px-4 lg:px-8 pt-6" aria-label="إحصاءات الأكاديمية">
  <div class="max-w-7xl mx-auto grid grid-cols-2 lg:grid-cols-4 gap-4">
    {stats.map((s) => (
      <div class="rounded-2xl border border-mem-gold/30 bg-mem-panel p-4 text-center gold-glow-soft" data-reveal>
        <div class="text-2xl" aria-hidden="true">{s.icon}</div>
        <p class="text-3xl lg:text-4xl font-bold text-gold-grad font-thuluth mt-1" data-count={s.n}>{s.n}</p>
        <p class="text-xs text-mem-ivory/70 mt-1">{s.label}</p>
      </div>
    ))}
  </div>
</section>

<script>
  const els = document.querySelectorAll('[data-count]');
  const reduce = matchMedia('(prefers-reduced-motion: reduce)').matches;
  function run(el) {
    const target = parseInt(el.getAttribute('data-count'), 10) || 0;
    if (reduce) { el.textContent = String(target); return; }
    const t0 = performance.now(); const dur = 1400;
    function step(now) {
      const p = Math.min(1, (now - t0) / dur);
      const eased = 1 - Math.pow(1 - p, 3);
      el.textContent = String(Math.round(target * eased));
      if (p < 1) requestAnimationFrame(step);
    }
    el.textContent = '0';
    requestAnimationFrame(step);
  }
  if ('IntersectionObserver' in window) {
    const io = new IntersectionObserver(function (es) {
      es.forEach(function (e) { if (e.isIntersecting) { io.unobserve(e.target); run(e.target); } });
    }, { threshold: 0.4 });
    els.forEach(function (el) { io.observe(el); });
  }
</script>
'@

# ============================================================
# 6) ScholarsCarousel: شريط القدوات الدوّار
# ============================================================
Write-File "src/components/ScholarsCarousel.astro" @'
---
const scholars = [
  { name: 'الألباني', img: 'albani.jpg', tag: 'علم الحديث' },
  { name: 'القرضاوي', img: 'qaradawi.jpg', tag: 'الفقه والدعوة' },
  { name: 'أينشتاين', img: 'einstein.jpg', tag: 'الفيزياء' },
  { name: 'تيسلا', img: 'tesla.jpg', tag: 'الهندسة الكهربائية' },
  { name: 'أحمد زويل', img: 'zewail-nobel.jpg', tag: 'كيمياء الفيمتو' },
  { name: 'ابن الهيثم', img: 'ibn-haytham.jpg', tag: 'البصريات' },
  { name: 'الخوارزمي', img: 'khwarizmi.jpg', tag: 'الجبر والخوارزميات' },
  { name: 'ابن سينا', img: 'ibn-sina.jpg', tag: 'الطب' },
  { name: 'جابر بن حيان', img: 'jabir.jpg', tag: 'الكيمياء' }
];
const loop = [...scholars, ...scholars];
---
<section class="pt-8 pb-2" aria-label="قدوات من العلماء">
  <div class="max-w-7xl mx-auto px-4 lg:px-8 text-center mb-4">
    <h2 class="text-2xl lg:text-3xl font-bold text-gold-grad font-thuluth">قدواتنا من العلماء</h2>
  </div>
  <div class="marquee overflow-hidden" dir="ltr">
    <div class="marquee-track">
      {loop.map((s, i) => (
        <div class="w-44 shrink-0 mx-4 text-center" dir="rtl" aria-hidden={i >= scholars.length ? 'true' : undefined}>
          <div class="scholar-img relative mx-auto w-24 h-24 rounded-full overflow-hidden bg-mem-panel flex items-center justify-center">
            <span class="text-3xl text-mem-gold" aria-hidden="true">✦</span>
            <img src={`/images/${s.img}`} alt={s.name} loading="lazy" onerror="this.style.display='none'" class="absolute inset-0 w-full h-full object-cover" />
          </div>
          <p class="scholar-name text-lg mt-2">{s.name}</p>
          <p class="text-[11px] text-mem-ivory/60">{s.tag}</p>
        </div>
      ))}
    </div>
  </div>
</section>
'@

# ============================================================
# 7) StudyTools: عدّاد الامتحان + سجل التقدّم + حكمة اليوم
# ============================================================
Write-File "src/components/StudyTools.astro" @'
---
import { memaarData } from '../data/memaarData';
const total = memaarData.reduce((n, p) => n + p.gates.length, 0);
const wisdoms = [
  { t: "وَقُل رَّبِّ زِدْنِي عِلْمًا", s: "سورة طه: 114" },
  { t: "قُلْ هَلْ يَسْتَوِي الَّذِينَ يَعْلَمُونَ وَالَّذِينَ لَا يَعْلَمُونَ", s: "سورة الزمر: 9" },
  { t: "إِنَّمَا يَخْشَى اللَّهَ مِنْ عِبَادِهِ الْعُلَمَاءُ", s: "سورة فاطر: 28" },
  { t: "وَأَن لَّيْسَ لِلْإِنسَانِ إِلَّا مَا سَعَىٰ", s: "سورة النجم: 39" },
  { t: "فَإِنَّ مَعَ الْعُسْرِ يُسْرًا", s: "سورة الشرح: 5" },
  { t: "وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ", s: "سورة الطلاق: 3" },
  { t: "اقْرَأْ بِاسْمِ رَبِّكَ الَّذِي خَلَقَ", s: "سورة العلق: 1" },
  { t: "وَقُلِ اعْمَلُوا فَسَيَرَى اللَّهُ عَمَلَكُمْ وَرَسُولُهُ وَالْمُؤْمِنُونَ", s: "سورة التوبة: 105" },
  { t: "يَرْفَعِ اللَّهُ الَّذِينَ آمَنُوا مِنكُمْ وَالَّذِينَ أُوتُوا الْعِلْمَ دَرَجَاتٍ", s: "سورة المجادلة: 11" },
  { t: "مَنْ سَلَكَ طَرِيقًا يَلْتَمِسُ فِيهِ عِلْمًا سَهَّلَ اللَّهُ لَهُ بِهِ طَرِيقًا إِلَى الْجَنَّةِ", s: "رواه مسلم" },
  { t: "احْرِصْ عَلَى مَا يَنْفَعُكَ وَاسْتَعِنْ بِاللَّهِ وَلَا تَعْجَزْ", s: "رواه مسلم" },
  { t: "نِعْمَتَانِ مَغْبُونٌ فِيهِمَا كَثِيرٌ مِنَ النَّاسِ: الصِّحَّةُ وَالْفَرَاغُ", s: "رواه البخاري" },
  { t: "إِنَّ اللَّهَ يُحِبُّ إِذَا عَمِلَ أَحَدُكُمْ عَمَلًا أَنْ يُتْقِنَهُ", s: "رواه البيهقي" },
  { t: "مَنْ جَدَّ وَجَدَ، وَمَنْ زَرَعَ حَصَدَ", s: "من أمثال العرب" }
];
---
<section id="tools" class="section-anchor-offset px-4 lg:px-8 pt-10 pb-4">
  <div class="max-w-7xl mx-auto text-center mb-6">
    <h2 class="text-2xl lg:text-3xl font-bold text-gold-grad font-thuluth">أدواتك اليومية</h2>
    <p class="text-xs text-mem-ivory/60 mt-1">بياناتها محفوظة في متصفحك فقط</p>
  </div>

  <div class="max-w-7xl mx-auto grid grid-cols-1 lg:grid-cols-3 gap-5">
    <article class="rounded-2xl border border-mem-gold/40 bg-mem-panel p-5 gold-glow-soft" data-reveal>
      <h3 class="text-base font-bold text-mem-ivory font-thuluth">⏳ عدّاد الامتحان</h3>
      <div class="text-center my-4" aria-live="polite">
        <p id="exam-title" class="text-sm text-mem-gold font-bold"></p>
        <p id="exam-days" class="text-5xl font-bold text-gold-grad font-thuluth my-1">--</p>
        <p id="exam-sub" class="text-xs text-mem-ivory/70">حدّد تاريخ امتحانك لنبدأ العدّ</p>
      </div>
      <input id="exam-name" type="text" maxlength="40" placeholder="اسم الامتحان (مثال: البكالوريا)" aria-label="اسم الامتحان" class="w-full h-10 px-3 mb-2 rounded-lg bg-mem-black border border-mem-gold/40 text-sm text-mem-ivory placeholder-mem-ivory/40 outline-none focus:border-mem-gold" />
      <input id="exam-date" type="date" aria-label="تاريخ الامتحان" class="w-full h-10 px-3 mb-3 rounded-lg bg-mem-black border border-mem-gold/40 text-sm text-mem-ivory outline-none focus:border-mem-gold" />
      <div class="flex gap-2">
        <button id="exam-save" type="button" class="flex-1 h-10 rounded-lg bg-mem-gold text-mem-black text-sm font-bold">حفظ</button>
        <button id="exam-clear" type="button" class="h-10 px-4 rounded-lg border border-mem-gold/50 text-mem-gold text-sm">مسح</button>
      </div>
    </article>

    <article class="rounded-2xl border border-mem-gold/40 bg-mem-panel p-5 gold-glow-soft" data-reveal>
      <h3 class="text-base font-bold text-mem-ivory font-thuluth">✅ سجلّ تقدّمي</h3>
      <div id="progress-card" data-total={total} class="my-5">
        <p class="text-center text-4xl font-bold text-gold-grad font-thuluth"><span id="progress-num">0</span> <span class="text-lg text-mem-ivory/60">/ {total}</span></p>
        <div class="h-3 rounded-full bg-mem-black border border-mem-gold/30 mt-4 overflow-hidden" role="progressbar" aria-valuemin="0" aria-valuemax={total} aria-valuenow="0" id="progress-track">
          <div id="progress-bar" class="h-full rounded-full bg-gradient-to-l from-mem-gold to-mem-burgundy" style="width:0%; transition: width .5s ease;"></div>
        </div>
        <p class="text-xs text-mem-ivory/70 text-center mt-3">علّم البوابات التي أتممتها بزر ✓ في كل بوابة</p>
      </div>
      <button id="progress-reset" type="button" class="w-full h-10 rounded-lg border border-mem-gold/50 text-mem-gold text-sm">تصفير التقدّم</button>
    </article>

    <article class="rounded-2xl border border-mem-burgundy/60 bg-mem-panel p-5 gold-glow-soft" data-reveal>
      <h3 class="text-base font-bold text-mem-ivory font-thuluth">🌙 حكمة اليوم</h3>
      <div id="wisdom" data-items={JSON.stringify(wisdoms)} class="my-5 text-center min-h-[9rem] flex flex-col justify-center">
        <p id="wisdom-text" class="scholar-name text-xl lg:text-2xl leading-loose">{wisdoms[0].t}</p>
        <p id="wisdom-src" class="text-xs text-mem-rose mt-3">{wisdoms[0].s}</p>
      </div>
      <p class="text-[11px] text-mem-ivory/50 text-center">تتبدّل تلقائياً كل يوم</p>
    </article>
  </div>
</section>

<script>
  /* ----- عدّاد الامتحان ----- */
  const EXAM_KEY = 'memaar_exam_v1';
  const nameI = document.getElementById('exam-name');
  const dateI = document.getElementById('exam-date');
  const titleE = document.getElementById('exam-title');
  const daysE = document.getElementById('exam-days');
  const subE = document.getElementById('exam-sub');
  function loadExam() { try { return JSON.parse(localStorage.getItem(EXAM_KEY) || 'null'); } catch (e) { return null; } }
  function tickExam() {
    const d = loadExam();
    if (!d || !d.date) { titleE.textContent = ''; daysE.textContent = '--'; subE.textContent = 'حدّد تاريخ امتحانك لنبدأ العدّ'; return; }
    const target = new Date(d.date + 'T08:00:00');
    titleE.textContent = d.name || 'امتحانك';
    if (isNaN(target.getTime())) { daysE.textContent = '--'; subE.textContent = 'تاريخ غير صالح'; return; }
    const diff = target.getTime() - Date.now();
    if (diff <= 0) { daysE.textContent = '0'; subE.textContent = 'حان الموعد، بالتوفيق والنجاح 🤲'; return; }
    const days = Math.floor(diff / 864e5);
    const hrs = Math.floor((diff % 864e5) / 36e5);
    const mins = Math.floor((diff % 36e5) / 6e4);
    daysE.textContent = String(days);
    subE.textContent = 'يوماً و ' + hrs + ' ساعة و ' + mins + ' دقيقة';
  }
  if (nameI && dateI) {
    const saved = loadExam();
    if (saved) { nameI.value = saved.name || ''; dateI.value = saved.date || ''; }
    document.getElementById('exam-save').addEventListener('click', function () {
      if (!dateI.value) return;
      try { localStorage.setItem(EXAM_KEY, JSON.stringify({ name: nameI.value.trim().slice(0, 40), date: dateI.value })); } catch (e) {}
      tickExam();
    });
    document.getElementById('exam-clear').addEventListener('click', function () {
      try { localStorage.removeItem(EXAM_KEY); } catch (e) {}
      nameI.value = ''; dateI.value = ''; tickExam();
    });
    tickExam();
    setInterval(tickExam, 30000);
  }

  /* ----- سجل التقدم ----- */
  const GATES_KEY = 'memaar_gates_v1';
  const card = document.getElementById('progress-card');
  if (card) {
    const total = parseInt(card.getAttribute('data-total'), 10) || 0;
    const num = document.getElementById('progress-num');
    const bar = document.getElementById('progress-bar');
    const track = document.getElementById('progress-track');
    const checks = Array.prototype.slice.call(document.querySelectorAll('[data-gate-check]'));
    let done = [];
    try { done = JSON.parse(localStorage.getItem(GATES_KEY) || '[]'); } catch (e) { done = []; }
    if (!Array.isArray(done)) done = [];
    function save() { try { localStorage.setItem(GATES_KEY, JSON.stringify(done)); } catch (e) {} }
    function paint() {
      checks.forEach(function (b) { b.setAttribute('aria-pressed', done.indexOf(b.getAttribute('data-gate-check')) !== -1 ? 'true' : 'false'); });
      const n = done.length;
      num.textContent = String(n);
      bar.style.width = (total ? Math.round((n / total) * 100) : 0) + '%';
      track.setAttribute('aria-valuenow', String(n));
    }
    checks.forEach(function (b) {
      b.addEventListener('click', function () {
        const id = b.getAttribute('data-gate-check');
        const i = done.indexOf(id);
        if (i === -1) done.push(id); else done.splice(i, 1);
        save(); paint();
      });
    });
    document.getElementById('progress-reset').addEventListener('click', function () {
      if (confirm('هل تريد تصفير تقدّمك؟')) { done = []; save(); paint(); }
    });
    paint();
  }

  /* ----- حكمة اليوم ----- */
  const w = document.getElementById('wisdom');
  if (w) {
    try {
      const items = JSON.parse(w.getAttribute('data-items') || '[]');
      if (items.length) {
        const day = Math.floor((Date.now() - new Date().getTimezoneOffset() * 6e4) / 864e5);
        const it = items[day % items.length];
        document.getElementById('wisdom-text').textContent = it.t;
        document.getElementById('wisdom-src').textContent = it.s;
      }
    } catch (e) {}
  }
</script>
'@

# ============================================================
# 8) CommandPalette: بحث فوري Ctrl+K
# ============================================================
Write-File "src/components/CommandPalette.astro" @'
---
import { memaarData } from '../data/memaarData';
const items = memaarData.flatMap((p) => [
  { href: `#pillar-${p.id}`, label: p.title, sub: 'معمار', text: p.title + ' ' + p.desc },
  ...p.gates.map((g) => ({ href: `#pillar-${p.id}`, label: g.title, sub: p.short, text: g.title + ' ' + g.axes.join(' ') }))
]);
---
<div id="cmdk" class="hidden fixed inset-0 z-[80]" role="dialog" aria-modal="true" aria-label="بحث سريع">
  <div data-cmdk-close class="absolute inset-0 bg-black/70 backdrop-blur-sm"></div>
  <div class="relative mx-auto mt-[10vh] w-[min(640px,92vw)] rounded-2xl border border-mem-gold/60 bg-mem-panel shadow-2xl gold-glow-strong overflow-hidden">
    <div class="flex items-center gap-3 px-4 border-b border-mem-gold/30">
      <span aria-hidden="true">🔍</span>
      <input id="cmdk-input" type="text" autocomplete="off" aria-label="بحث سريع" placeholder="ابحث عن بوابة أو محور..." class="flex-1 h-14 bg-transparent text-mem-ivory placeholder-mem-ivory/40 outline-none" />
      <kbd class="text-[10px] text-mem-ivory/50 border border-mem-ivory/20 rounded px-1.5 py-0.5">Esc</kbd>
    </div>
    <ul id="cmdk-list" class="max-h-[50vh] overflow-y-auto scrollbar-thin py-2">
      {items.map((it) => (
        <li>
          <a href={it.href} data-cmdk-item data-text={it.text} class="flex items-center justify-between gap-3 px-4 py-2.5 hover:bg-mem-gold/10">
            <span class="text-sm text-mem-ivory">{it.label}</span>
            <span class="text-[10px] text-mem-rose shrink-0">{it.sub}</span>
          </a>
        </li>
      ))}
    </ul>
    <p id="cmdk-empty" class="hidden p-6 text-center text-sm text-mem-ivory/60">لا توجد نتائج مطابقة.</p>
    <div class="flex justify-between px-4 py-2 border-t border-mem-gold/20 text-[10px] text-mem-ivory/50"><span>↑ ↓ للتنقل</span><span>Enter للفتح</span></div>
  </div>
</div>

<script>
  const root = document.getElementById('cmdk');
  if (root) {
    const input = document.getElementById('cmdk-input');
    const list = document.getElementById('cmdk-list');
    const empty = document.getElementById('cmdk-empty');
    const items = Array.prototype.slice.call(root.querySelectorAll('[data-cmdk-item]'));
    const norm = function (s) {
      return (s || '').toLowerCase().replace(/[\u064B-\u0652\u0640]/g, '').replace(/[أإآ]/g, 'ا').replace(/ى/g, 'ي').replace(/ة/g, 'ه');
    };
    const cache = items.map(function (a) { return norm(a.getAttribute('data-text') + ' ' + a.textContent); });
    let visible = items.slice(); let idx = 0; let last = null;

    function mark() {
      items.forEach(function (a) { a.removeAttribute('data-active'); });
      if (visible[idx]) { visible[idx].setAttribute('data-active', 'true'); visible[idx].scrollIntoView({ block: 'nearest' }); }
    }
    function render() {
      const q = norm(input.value.trim());
      visible = [];
      items.forEach(function (a, i) {
        const ok = !q || cache[i].indexOf(q) !== -1;
        a.parentElement.classList.toggle('hidden', !ok);
        if (ok) visible.push(a);
      });
      idx = 0; mark();
      empty.classList.toggle('hidden', visible.length > 0);
    }
    function open() {
      last = document.activeElement;
      root.classList.remove('hidden');
      document.documentElement.style.overflow = 'hidden';
      input.value = ''; render(); input.focus();
    }
    function close() {
      root.classList.add('hidden');
      document.documentElement.style.overflow = '';
      if (last && last.focus) last.focus();
    }
    document.querySelectorAll('[data-open-palette]').forEach(function (b) { b.addEventListener('click', open); });
    root.querySelector('[data-cmdk-close]').addEventListener('click', close);
    list.addEventListener('click', function (e) { if (e.target.closest('[data-cmdk-item]')) close(); });
    input.addEventListener('input', render);
    document.addEventListener('keydown', function (e) {
      const isOpen = !root.classList.contains('hidden');
      if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'k') { e.preventDefault(); isOpen ? close() : open(); return; }
      if (!isOpen) return;
      if (e.key === 'Escape') { close(); }
      else if (e.key === 'ArrowDown') { e.preventDefault(); idx = Math.min(visible.length - 1, idx + 1); mark(); }
      else if (e.key === 'ArrowUp') { e.preventDefault(); idx = Math.max(0, idx - 1); mark(); }
      else if (e.key === 'Enter') { e.preventDefault(); if (visible[idx]) visible[idx].click(); }
    });
  }
</script>
'@

# ============================================================
# 9) PomodoroWidget: مؤقت التركيز العائم
# ============================================================
Write-File "src/components/PomodoroWidget.astro" @'
<div id="pomo" class="fixed left-4 bottom-20 lg:bottom-6 z-[55] flex flex-col items-start">
  <div id="pomo-panel" class="hidden mb-3 w-64 rounded-2xl border border-mem-gold/60 bg-mem-panel p-4 shadow-2xl gold-glow-soft">
    <div class="flex gap-2 mb-3" role="group" aria-label="نمط المؤقت">
      <button type="button" data-pomo-mode="focus" aria-pressed="true" class="twin-btn flex-1 py-1.5 rounded-full text-xs font-bold border border-mem-gold/40" data-active="true">تركيز 25</button>
      <button type="button" data-pomo-mode="rest" aria-pressed="false" class="twin-btn flex-1 py-1.5 rounded-full text-xs font-bold border border-mem-gold/40" data-active="false">راحة 5</button>
    </div>
    <p id="pomo-time" class="text-center text-5xl font-bold text-gold-grad font-thuluth my-2" aria-live="off">25:00</p>
    <div class="flex gap-2 mt-3">
      <button id="pomo-start" type="button" class="flex-1 h-10 rounded-lg bg-mem-gold text-mem-black text-sm font-bold">ابدأ</button>
      <button id="pomo-reset" type="button" class="h-10 px-4 rounded-lg border border-mem-gold/50 text-mem-gold text-sm">إعادة</button>
    </div>
    <p class="text-[11px] text-mem-ivory/60 text-center mt-3">جلسات تركيز اليوم: <span id="pomo-count">0</span></p>
  </div>
  <button id="pomo-toggle" type="button" aria-expanded="false" aria-label="مؤقت التركيز" class="h-12 px-4 rounded-full border-2 border-mem-gold bg-mem-panel text-mem-gold shadow-xl gold-glow-soft flex items-center gap-2">
    <span aria-hidden="true">🍅</span><span id="pomo-mini" class="hidden text-sm font-bold">25:00</span>
  </button>
</div>

<script>
  const MODES = { focus: 25 * 60, rest: 5 * 60 };
  const KEY = 'memaar_pomo_v1';
  const panel = document.getElementById('pomo-panel');
  const toggle = document.getElementById('pomo-toggle');
  const timeE = document.getElementById('pomo-time');
  const miniE = document.getElementById('pomo-mini');
  const startB = document.getElementById('pomo-start');
  const countE = document.getElementById('pomo-count');
  const modeBtns = Array.prototype.slice.call(document.querySelectorAll('[data-pomo-mode]'));
  let mode = 'focus', remaining = MODES.focus, endAt = 0, running = false, timer = 0;

  const today = function () { return new Date().toISOString().slice(0, 10); };
  function getCount() { try { const d = JSON.parse(localStorage.getItem(KEY) || 'null'); return d && d.date === today() ? d.n : 0; } catch (e) { return 0; } }
  function incCount() { try { localStorage.setItem(KEY, JSON.stringify({ date: today(), n: getCount() + 1 })); } catch (e) {} countE.textContent = String(getCount()); }
  const fmt = function (s) { return String(Math.floor(s / 60)).padStart(2, '0') + ':' + String(s % 60).padStart(2, '0'); };

  function render() {
    timeE.textContent = fmt(remaining);
    miniE.textContent = fmt(remaining);
    miniE.classList.toggle('hidden', !running && remaining === MODES[mode]);
    startB.textContent = running ? 'إيقاف مؤقت' : 'ابدأ';
    modeBtns.forEach(function (b) {
      const on = b.getAttribute('data-pomo-mode') === mode;
      b.setAttribute('data-active', on ? 'true' : 'false');
      b.setAttribute('aria-pressed', on ? 'true' : 'false');
    });
  }
  function beep() {
    try {
      const A = window.AudioContext || window.webkitAudioContext;
      const a = new A(); const o = a.createOscillator(); const g = a.createGain();
      o.connect(g); g.connect(a.destination); o.frequency.value = 880; g.gain.value = 0.15; o.start();
      setTimeout(function () { o.stop(); a.close(); }, 700);
    } catch (e) {}
    if (navigator.vibrate) navigator.vibrate([200, 100, 200]);
  }
  function pause() { running = false; clearInterval(timer); render(); }
  function setMode(m) { pause(); mode = m; remaining = MODES[m]; render(); }
  function finish() { pause(); beep(); if (mode === 'focus') { incCount(); setMode('rest'); } else { setMode('focus'); } }
  function tick() { remaining = Math.max(0, Math.round((endAt - Date.now()) / 1000)); render(); if (remaining <= 0) finish(); }
  function start() { if (running) return; endAt = Date.now() + remaining * 1000; running = true; timer = setInterval(tick, 500); render(); }

  toggle.addEventListener('click', function () {
    const open = panel.classList.toggle('hidden') === false;
    toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
  });
  startB.addEventListener('click', function () { running ? pause() : start(); });
  document.getElementById('pomo-reset').addEventListener('click', function () { setMode(mode); });
  modeBtns.forEach(function (b) { b.addEventListener('click', function () { setMode(b.getAttribute('data-pomo-mode')); }); });
  countE.textContent = String(getCount());
  render();
</script>
'@

# ============================================================
# 10) BottomNav: شريط سفلي للجوال
# ============================================================
Write-File "src/components/BottomNav.astro" @'
<nav class="lg:hidden fixed bottom-0 inset-x-0 z-[60] border-t border-mem-gold/40 bg-mem-black/95 backdrop-blur-xl" style="padding-bottom: env(safe-area-inset-bottom, 0px);" aria-label="التنقل السريع">
  <ul class="grid grid-cols-5 text-center">
    <li><a href="#" class="flex flex-col items-center gap-0.5 py-2 text-[10px] text-mem-ivory/85"><span class="text-lg" aria-hidden="true">🏠</span>الرئيسية</a></li>
    <li><a href="#pillars" class="flex flex-col items-center gap-0.5 py-2 text-[10px] text-mem-ivory/85"><span class="text-lg" aria-hidden="true">🏛️</span>المعامير</a></li>
    <li><button type="button" data-open-palette class="w-full flex flex-col items-center gap-0.5 py-2 text-[10px] text-mem-ivory/85"><span class="text-lg" aria-hidden="true">🔍</span>بحث</button></li>
    <li><a href="#tools" class="flex flex-col items-center gap-0.5 py-2 text-[10px] text-mem-ivory/85"><span class="text-lg" aria-hidden="true">🎯</span>أدواتي</a></li>
    <li><button type="button" data-theme-toggle aria-label="تبديل الوضع" class="w-full flex flex-col items-center gap-0.5 py-2 text-[10px] text-mem-ivory/85"><span class="text-lg" data-theme-icon aria-hidden="true">☀️</span>الوضع</button></li>
  </ul>
</nav>
'@

# ============================================================
# 11) CSS: الوضع الفاتح + الحركات + الزخارف
# ============================================================
$cssPath = Join-Path (Get-Location).Path "src\styles\global.css"
$css = [IO.File]::ReadAllText($cssPath)
if (-not $css.Contains("UPGRADE v2")) {
$block = @'

/* === UPGRADE v2 === */
@theme {
  --color-mem-panel: #12141a;
  --color-mem-panel2: #101117;
  --color-mem-footer: #0a0b0f;
}

:root[data-theme="dark"] { color-scheme: dark; }
:root[data-theme="light"] {
  color-scheme: light;
  --color-mem-black: #FBF6EA;
  --color-mem-ivory: #1B1A17;
  --color-mem-gold: #9C7A12;
  --color-mem-rose: #A3213F;
  --color-mem-panel: #F1E8D2;
  --color-mem-panel2: #F6EEDA;
  --color-mem-footer: #EADFC4;
}
:root[data-theme="light"] .text-gold-grad {
  color: #7A5A08;
  background: linear-gradient(135deg, #7A5A08 0%, #9C7A12 50%, #5E4506 100%);
  -webkit-background-clip: text; background-clip: text;
}
:root[data-theme="light"] .scholar-name { color: #7A5A08; -webkit-text-stroke: 0.6px #7A5A08; text-shadow: none; }

body { transition: background-color .4s ease, color .4s ease; }
@media (max-width: 1023px) { body { padding-bottom: calc(4.5rem + env(safe-area-inset-bottom, 0px)); } }

.scholar-name {
  font-family: 'Amiri Quran', 'Aref Ruqaa', serif;
  font-weight: 700;
  color: #D4AF37;
  -webkit-text-stroke: 0.6px #D4AF37;
  text-shadow: 0 2px 10px rgba(212,175,55,0.45), 0 0 2px rgba(0,0,0,0.9);
  letter-spacing: 0.02em;
}
.scholar-img {
  border: 3px solid #D4AF37;
  box-shadow: 0 0 22px rgba(212,175,55,0.35);
  transition: transform .3s ease, box-shadow .3s ease;
}
.scholar-img:hover { transform: scale(1.06); box-shadow: 0 0 34px rgba(212,175,55,0.6); }

#scroll-progress {
  position: fixed; top: 0; left: 0; right: 0; height: 3px; z-index: 70;
  transform-origin: right center; transform: scaleX(0);
  background: linear-gradient(270deg, #F4E5A1, #D4AF37, #800020);
  pointer-events: none;
}

.hero-card > :not(canvas) { position: relative; z-index: 1; }

.js .reveal { opacity: 0; transform: translateY(26px); transition: opacity .8s ease, transform .8s cubic-bezier(.2,.7,.2,1); }
.js .reveal.in { opacity: 1; transform: none; }

.pillar-card {
  position: relative; overflow: hidden;
  transform: perspective(900px) rotateX(var(--rx, 0deg)) rotateY(var(--ry, 0deg));
  transition: transform .15s ease-out, box-shadow .35s ease, border-color .35s ease;
}
.pillar-card:hover, .pillar-card:focus-visible {
  transform: perspective(900px) rotateX(var(--rx, 0deg)) rotateY(var(--ry, 0deg)) translateY(-6px) scale(1.015);
}
.pillar-card::after {
  content: ""; position: absolute; inset: 0; pointer-events: none; opacity: 0; transition: opacity .3s ease;
  background: radial-gradient(260px circle at var(--mx, 50%) var(--my, 0%), rgba(212,175,55,.22), transparent 60%);
}
.pillar-card:hover::after { opacity: 1; }

.pattern-bg { position: relative; isolation: isolate; }
.pattern-bg::before {
  content: ""; position: absolute; inset: 0; z-index: -1; border-radius: inherit; pointer-events: none; opacity: .06;
  background-size: 80px 80px;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='80' height='80' viewBox='0 0 80 80'%3E%3Cg fill='none' stroke='%23D4AF37' stroke-width='1'%3E%3Crect x='20' y='20' width='40' height='40'/%3E%3Crect x='20' y='20' width='40' height='40' transform='rotate(45 40 40)'/%3E%3Ccircle cx='40' cy='40' r='8'/%3E%3Cpath d='M0 0L20 20M80 0L60 20M0 80L20 60M80 80L60 60'/%3E%3C/g%3E%3C/svg%3E");
}

@keyframes marquee { from { transform: translateX(0); } to { transform: translateX(-50%); } }
.marquee { -webkit-mask-image: linear-gradient(90deg, transparent, #000 8%, #000 92%, transparent); mask-image: linear-gradient(90deg, transparent, #000 8%, #000 92%, transparent); }
.marquee-track { display: flex; width: max-content; padding: 1rem 0; animation: marquee 50s linear infinite; }
.marquee:hover .marquee-track { animation-play-state: paused; }
@media (prefers-reduced-motion: reduce) { .marquee { overflow-x: auto !important; } }

.gate-check {
  flex-shrink: 0; width: 1.75rem; height: 1.75rem; border-radius: 9999px; cursor: pointer;
  border: 1px solid rgba(212,175,55,.5); background: transparent; color: transparent;
  font-size: .8rem; line-height: 1; display: inline-flex; align-items: center; justify-content: center;
  transition: all .25s ease;
}
.gate-check:hover { border-color: var(--color-mem-gold); color: rgba(212,175,55,.6); }
.gate-check[aria-pressed="true"] {
  background: var(--color-mem-gold); color: var(--color-mem-black); border-color: var(--color-mem-gold);
  box-shadow: 0 0 14px rgba(212,175,55,.45);
}

[data-cmdk-item][data-active="true"] { background: rgba(212,175,55,.16); }
'@
[IO.File]::WriteAllText($cssPath, $css + "`r`n" + $block, $utf8)
}

# ============================================================
# 12) تعديلات على الملفات الحالية
# ============================================================
Patch "src/components/Header.astro" '<button id="mobile-menu-btn"' '<div class="hidden sm:flex items-center gap-2 shrink-0"><button type="button" data-open-palette aria-label="بحث سريع" class="h-11 px-3 flex items-center rounded-full border border-mem-gold/45 text-[11px] text-mem-gold hover:bg-mem-gold/10">Ctrl K</button><button type="button" data-theme-toggle aria-label="تبديل الوضع" class="w-11 h-11 rounded-full border border-mem-gold/60 text-mem-gold flex items-center justify-center"><span data-theme-icon>☀️</span></button></div><button id="mobile-menu-btn"'

Patch "src/components/PillarCards.astro" '<section class="relative px-4 lg:px-8 pt-10 pb-6">' '<section id="pillars" class="section-anchor-offset relative px-4 lg:px-8 pt-10 pb-6">'
Patch "src/components/PillarCards.astro" 'data-search-card>' 'data-search-card data-reveal>'

Patch "src/components/DeepSections.astro" 'data-search-section>' 'data-search-section data-reveal>'
Patch "src/components/DeepSections.astro" 'class="section-anchor-offset rounded-3xl' 'class="section-anchor-offset pattern-bg rounded-3xl'
Patch "src/components/DeepSections.astro" '<h3 class="text-sm font-bold text-mem-rose mb-2">❖ {gate.title}</h3>' '<div class="flex items-start justify-between gap-2 mb-2"><h3 class="text-sm font-bold text-mem-rose">❖ {gate.title}</h3><button type="button" class="gate-check" data-gate-check={gate.id} aria-pressed="false" aria-label="تعليم البوابة كمقروءة" title="تمت قراءتها">✓</button></div>'

Patch "src/pages/index.astro" "import Footer from '../components/Footer.astro';" "import Footer from '../components/Footer.astro';`nimport StatsCounter from '../components/StatsCounter.astro';`nimport ScholarsCarousel from '../components/ScholarsCarousel.astro';`nimport StudyTools from '../components/StudyTools.astro';`nimport PomodoroWidget from '../components/PomodoroWidget.astro';`nimport BottomNav from '../components/BottomNav.astro';`nimport CommandPalette from '../components/CommandPalette.astro';`nimport GlobalFX from '../components/GlobalFX.astro';"
Patch "src/pages/index.astro" '<HeroBanner />' '<HeroBanner /><StatsCounter /><ScholarsCarousel />'
Patch "src/pages/index.astro" '<PillarCards />' '<PillarCards /><StudyTools />'
Patch "src/pages/index.astro" '<Footer />' '<Footer /><PomodoroWidget /><BottomNav /><CommandPalette /><GlobalFX />'

# استبدال الألوان الثابتة برموز تدعم الوضعين
$map = @{ 'bg-[#12141a]' = 'bg-mem-panel'; 'from-[#12141a]' = 'from-mem-panel'; 'from-[#101117]' = 'from-mem-panel2'; 'bg-[#0a0b0f]' = 'bg-mem-footer' }
Get-ChildItem "src" -Recurse -Include *.astro -File | ForEach-Object {
  $t = [IO.File]::ReadAllText($_.FullName); $o = $t
  foreach ($k in $map.Keys) { $t = $t.Replace($k, $map[$k]) }
  if ($t -ne $o) { [IO.File]::WriteAllText($_.FullName, $t, $utf8) }
}

Write-Host "✅ تم التحديث الكامل! حدّث الصفحة بـ Ctrl+F5" -ForegroundColor Green
Write-Host "   لو حدث خطأ: احذف src وأعد تسمية $bak إلى src" -ForegroundColor Cyan