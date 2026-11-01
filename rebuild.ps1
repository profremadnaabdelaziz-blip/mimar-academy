# ============================================================
#  أكاديمية مِعْمَار — سكربت إعادة البناء الكامل (النسخة النهائية)
# ============================================================
$ErrorActionPreference = "Stop"

# 1) نسخة احتياطية بدل الحذف النهائي
if (Test-Path "src") {
  $bak = "src_backup_" + (Get-Date -Format "yyyyMMdd_HHmmss")
  Rename-Item -Path "src" -NewName $bak
  Write-Host "📦 تم حفظ src القديم باسم: $bak" -ForegroundColor Yellow
}

# 2) الهيكل الجديد
New-Item -ItemType Directory -Force -Path src\components, src\layouts, src\pages, src\styles, src\data, public\images | Out-Null

# إصلاح اسم صورة زويل تلقائياً (jpeg -> jpg)
if ((Test-Path "public/images/zewail-nobel.jpeg") -and !(Test-Path "public/images/zewail-nobel.jpg")) {
  Rename-Item "public/images/zewail-nobel.jpeg" "zewail-nobel.jpg"
  Write-Host "🖼️ تمت إعادة تسمية zewail-nobel.jpeg إلى zewail-nobel.jpg" -ForegroundColor Yellow
}

$files = @{}

# ------------------------------------------------------------
$files["src/styles/global.css"] = @'
@import "tailwindcss";

@theme {
  --color-mem-black: #0D0E12;
  --color-mem-gold: #D4AF37;
  --color-mem-burgundy: #800020;
  --color-mem-rose: #E0788F;
  --color-mem-ivory: #F5F5F5;
  --font-thuluth: 'Aref Ruqaa', 'Amiri', serif;
  --font-maryam: 'Aref Ruqaa', 'Amiri', serif;
  --font-amiri: 'Amiri', 'Times New Roman', serif;
  --font-traditional: 'Cairo', 'Tahoma', sans-serif;
  --font-kufi: 'Reem Kufi', 'Cairo', sans-serif;
}

html, body { background-color: var(--color-mem-black); color: var(--color-mem-ivory); }

.gold-glow-soft { box-shadow: 0 0 15px rgba(212,175,55,0.08), 0 0 40px rgba(212,175,55,0.04); }
.gold-glow-strong { box-shadow: 0 0 25px rgba(212,175,55,0.28), 0 0 60px rgba(212,175,55,0.12); }
.search-box:focus { box-shadow: 0 0 25px rgba(212,175,55,0.28), 0 0 60px rgba(212,175,55,0.12); }

.text-gold-grad {
  color: #D4AF37;
  background: linear-gradient(135deg, #F4E5A1 0%, #D4AF37 50%, #A8842A 100%);
  -webkit-background-clip: text; background-clip: text;
}
@supports ((-webkit-background-clip: text) or (background-clip: text)) {
  .text-gold-grad { color: transparent; -webkit-text-fill-color: transparent; }
}

.pillar-card { transition: transform .35s ease, box-shadow .35s ease, border-color .35s ease; }
.pillar-card:hover, .pillar-card:focus-visible {
  transform: translateY(-6px) scale(1.015);
  border-color: var(--color-mem-gold);
  box-shadow: 0 20px 60px -20px rgba(212,175,55,0.45), 0 0 40px -10px rgba(212,175,55,0.25);
  outline: none;
}
.pillar-card:hover .pillar-title, .pillar-card:focus-visible .pillar-title { color: var(--color-mem-gold); }

@keyframes shimmer { 0% { background-position: -200% 0; } 100% { background-position: 200% 0; } }
.shimmer-divider {
  background: linear-gradient(90deg, transparent, rgba(212,175,55,0.6), transparent);
  background-size: 200% 100%; animation: shimmer 4s linear infinite;
}

.mega-panel { opacity: 0; visibility: hidden; transform: translateY(-6px); transition: opacity .28s ease, transform .28s ease, visibility .28s; }
.has-mega:hover .mega-panel,
.has-mega:focus-within .mega-panel,
.has-mega[data-open="true"] .mega-panel { opacity: 1; visibility: visible; transform: translateY(0); }
.has-mega:hover > .mega-trigger,
.has-mega:focus-within > .mega-trigger,
.has-mega[data-open="true"] > .mega-trigger { color: var(--color-mem-gold); }
.has-mega:hover > .mega-trigger .chev,
.has-mega[data-open="true"] > .mega-trigger .chev { transform: rotate(180deg); }
.chev { transition: transform .3s ease; display: inline-block; }

.scrollbar-thin { scrollbar-width: thin; scrollbar-color: #D4AF37 #0D0E12; }
.scrollbar-thin::-webkit-scrollbar { width: 6px; height: 6px; }
.scrollbar-thin::-webkit-scrollbar-track { background: var(--color-mem-black); }
.scrollbar-thin::-webkit-scrollbar-thumb { background: var(--color-mem-gold); border-radius: 3px; }

[data-twin-hidden="true"] { display: none !important; }
[data-search-hidden="true"] { display: none !important; }

.twin-btn { transition: background-color .25s ease, color .25s ease, box-shadow .25s ease; }
.twin-btn[data-active="true"] { background-color: var(--color-mem-gold); color: var(--color-mem-black); box-shadow: 0 0 20px rgba(212,175,55,0.45); }
.twin-btn[data-active="false"] { background-color: transparent; color: var(--color-mem-ivory); }

.slot-card { transition: transform .3s ease, border-color .3s ease, box-shadow .3s ease; }
.slot-card:hover { transform: translateY(-3px); border-color: rgba(212,175,55,0.6); box-shadow: 0 12px 40px -18px rgba(212,175,55,0.45); }

.section-anchor-offset { scroll-margin-top: 9rem; }

a:focus-visible, button:focus-visible, input:focus-visible { outline: 2px solid var(--color-mem-gold); outline-offset: 2px; }

@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: .01ms !important; animation-iteration-count: 1 !important;
    transition-duration: .01ms !important; scroll-behavior: auto !important;
  }
}
'@

# ------------------------------------------------------------
$files["src/data/memaarData.ts"] = @'
export const memaarData = [
  { id: 1, title: "المعمار الأول: البناء الإيماني، الأخلاقي، والتحصين الفكري", short: "البناء الإيماني", desc: "بوابتك لتصحيح البوصلة وجعل المحبرة والشهادة عبادة واستخلافاً؛ نربط تفوقك برضا الرحمن وبر الوالدين وصناعة الأمانة العلمية.", gates: [{ id: 1, title: "بوابة أنوار الهداية والنية الحسنة", axes: ["الإخلاص لله وجعل الدراسة عبادة واستخلافاً", "التوكل على الله وحسن الظن به والدعاء وطلب الاستعانة"] }, { id: 2, title: "بوابة آداب طالب العلم والمسؤولية الأخلاقية", axes: ["آداب طالب العلم والتأدب مع الأساتذة وعمال المؤسسة", "فقه بر الوالدين وأثره المباشر في التوفيق الدراسي"] }, { id: 3, title: "بوابة التحصين ضد الشهوات والوقاية الرقمية", axes: ["التوعية النفسية ضد الإباحية، وعلاج التعلق العاطفي المحرم", "أدوات الفلترة والوقاية الرقمية والتحصين السلوكي"] }, { id: 4, title: "بوابة تعرية المنصات الهابطة والشبهات الفكرية", axes: ["تفكيك الفلسفات المادية، الإلحاد الجديد، والطوائف المنحرفة", "سؤال «لماذا أتعب وأضحي في دراستي؟» وأثر النجاح في نهضة الأمة"] }] },
  { id: 2, title: "المعمار الثاني: النفس، البدن، والعلاقات الاجتماعية", short: "النفس والبدن", desc: "عيادتك التربوية لتفكيك قلق الامتحانات، وضبط بيولوجيا النوم والغذاء البناء للذاكرة والجسد، وإدارة عواطف المراهقة المتدفقة.", gates: [{ id: 5, title: "بوابة سيكولوجية المراهقة وفهم الذات", axes: ["إدارة العواطف المتدفقة وعلاج الاضطرابات الوجدانية", "التعامل العملي مع القلق، الاكتئاب، التشتت، الفشل، والملل"] }, { id: 6, title: "معامير صحة البدن (النوم - التغذية - الرياضة)", axes: ["هندسة النوم الصحي وعلاج الأرق، والتغذية المخصصة للذاكرة", "ممارسة الرياضة وفوائدها العصبية والنفسية للطالب"] }, { id: 7, title: "بوابة الصداقة والتواصل ومواجهة التنمر", axes: ["هندسة العلاقات الصالحة وعلاج الصداقات السامة وضغط الأقران", "مهارات مواجهة التنمر وبناء التواصل الفعال مع الأسرة"] }, { id: 8, title: "ركن الاستشارات والدعم النفسي الخاص", axes: ["دليل الإجابات الجاهزة للتبويب الذاتي للمشكلات الشائعة", "نموذج الاستشارات السرية المجهولة وإخلاء المسؤولية الطبية"] }] },
  { id: 3, title: "المعمار الثالث: التفوق الأكاديمي، الذكاء الاصطناعي، والتوجيه", short: "التفوق الأكاديمي", desc: "أسرار الفعالية العلمية وأحدث تقنيات التفوق الدراسي السريع؛ ركيزتك لإتقان التكرار المتباعد والخرائط الذهنية وتوظيف الذكاء الاصطناعي بأمانة.", gates: [{ id: 9, title: "آليات التعلم السريع والتنظيم الرقمي", axes: ["آليات التعلم السريع: تنظيم الوقت، التكرار المتباعد، والخرائط الذهنية", "السيطرة الرقمية: التغلب على خوارزميات السوشيال ميديا والتشتت"] }, { id: 10, title: "تطبيقات الذكاء الاصطناعي والتوجيه", axes: ["تطبيقات الذكاء الاصطناعي: توظيف AI في البحث والتلخيص مع الالتزام بأخلاقيات الأمانة العلمية", "التوجيه المدرسي والجامعي: فن اختيار التخصص والمستقبل المهني"] }] },
  { id: 4, title: "المعمار الرابع: الثقافة، عمارة الوقت، والقدوات", short: "الثقافة والقدوات", desc: "بناء عمارة القراءة الاستيعابية النقدية التي تصنع قيادات المستقبل، ومنجمك المختار لأقوى ترشيحات العلوم الشرعية والروايات النظيفة.", gates: [{ id: 11, title: "تشريح الفراغ والبدائل المهارية", axes: ["تشريح الفراغ والبدائل: سيكولوجية الملل والبدائل المهارية والعمل التطوعي"] }, { id: 12, title: "القدوات والعلماء", axes: ["القدوات والعلماء: قصص علماء الإسلام، العلماء الكونيين، والتلاميذ النجباء"] }, { id: 13, title: "الرسوخ الثقافي والشرعي", axes: ["الرسوخ الثقافي والشرعي: خريطة العلوم الشرعية، الأدلة الموثوقة، والعلماء المعتمدين"] }, { id: 14, title: "استراتيجيات القراءة (اقرأ)", axes: ["استراتيجيات القراءة (اقرأ): القراءة النقدية وترشيحات الكتب والفكر والروايات النظيفة"] }] },
  { id: 5, title: "المعمار الخامس: المنارة الجزائرية ورعاية الأسرة", short: "المنارة الجزائرية", desc: "المساحة الوطنية الخاصة والمدخل السريع لأرضيات الوزارة وبنوك الحوليات الشاملة؛ كشافك الموثوق لأقوى الأساتذة الجزائريين والدليل الأسري الاحتوائي.", gates: [{ id: 15, title: "الأرضيات الرسمية", axes: ["الأرضيات الرسمية: روابط وزارتي التربية والتعليم العالي الجزائرية"] }, { id: 16, title: "بنك الحوليات", axes: ["بنك الحوليات: امتحانات شهادات المتوسط والبكالوريا BEM & BAC مع التصحيح"] }, { id: 17, title: "كشاف القنوات الوطنية", axes: ["كشاف القنوات الوطنية: دليل أفضل القنوات والأساتذة الجزائريين في كل المواد"] }, { id: 18, title: "رواق الأولياء", axes: ["رواق الأولياء: دليل الأسرة والمحيط التربوي للتعامل مع ضغوط الامتحانات"] }] }
];

export const twinSlots = {
  building: [
    { code: "A", icon: "📄", label: "المقالات والأبحاث", desc: "نصوص إجرائية موجزة تُعالج الظواهر السلوكية اليومية، وحلول عملية للطالب في مرحلة المتوسط والثانوي." },
    { code: "B", icon: "📚", label: "الكتب والطروحات", desc: "مؤلفات تأسيسية مبسطة وكراسات تدريبية مصورة، مع بطاقات تعريفية وأغلفة وملخصات وروابط تحميل مرجعية." },
    { code: "C", icon: "🎥", label: "المرئيات والدروس", desc: "حصص مصورة قصيرة وفلاشات توعوية مركزة، وكلمات مقتضبة منظمة تُخاطب الطالب الميداني." }
  ],
  deepening: [
    { code: "A", icon: "📄", label: "الدراسات النقدية", desc: "أوراق علمية محكمة، وتحليلات فلسفية معمقة، ومراجعات نقدية للمناهج والاتجاهات المعاصرة." },
    { code: "B", icon: "📚", label: "الأطروحات والمجلات", desc: "رسائل جامعية موثقة، ومقالات في مجلات علمية محكمة، مع فهارس مرجعية موجهة للباحثين." },
    { code: "C", icon: "🎥", label: "المحاضرات والندوات", desc: "ندوات أكاديمية مطولة، وحوارات متخصصة، وعروض تقديمية للأبحاث الحديثة في التخصص." }
  ]
};
'@

# ------------------------------------------------------------
$files["src/layouts/Layout.astro"] = @'
---
import '../styles/global.css';
interface Props { title: string; description?: string; }
const { title, description = "أكاديمية مِعْمَار للنجاح الدراسي: منصة تدمج العلوم الكونية والشرعية لتمكين الطالب المسلم إيمانياً ونفسياً وأكاديمياً." } = Astro.props;
---
<!DOCTYPE html>
<html lang="ar" dir="rtl" class="scroll-smooth">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="description" content={description} />
    <meta name="theme-color" content="#0D0E12" />
    <link rel="icon" href="/images/memaar-logo.png" />
    <title>{title}</title>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Amiri:ital,wght@0,400;0,700;1,400&family=Aref+Ruqaa:wght@400;700&family=Cairo:wght@300;400;600;700;900&family=Reem+Kufi:wght@400;500;700&display=swap" rel="stylesheet" />
  </head>
  <body class="bg-mem-black text-mem-ivory font-traditional min-h-screen antialiased selection:bg-mem-burgundy selection:text-white">
    <slot />
  </body>
</html>
'@

# ------------------------------------------------------------
$files["src/components/Header.astro"] = @'
---
import { memaarData } from '../data/memaarData';
---
<header class="sticky top-0 z-50 w-full bg-mem-black/95 backdrop-blur-xl border-b border-mem-gold/40">
  <div class="max-w-7xl mx-auto flex items-center justify-between gap-4 h-20 px-4 lg:px-8">
    <a href="/" class="flex items-center gap-3 group shrink-0" aria-label="أكاديمية مِعْمَار - الصفحة الرئيسية">
      <div class="w-12 h-12 flex items-center justify-center group-hover:scale-105 transition-transform">
        <img src="/images/memaar-logo.png" alt="شعار أكاديمية مِعْمَار" class="w-full h-full object-contain drop-shadow-[0_0_8px_rgba(212,175,55,0.4)]" />
      </div>
      <span class="hidden sm:flex flex-col leading-tight">
        <span class="text-base lg:text-lg font-bold text-gold-grad font-maryam tracking-wide">أكاديمية مِعْمَار</span>
        <span class="text-[10px] text-mem-ivory/60">للنجاح الدراسي</span>
      </span>
    </a>

    <div class="relative flex-1 max-w-md">
      <span class="absolute inset-y-0 right-4 flex items-center text-mem-gold pointer-events-none" aria-hidden="true">🔍</span>
      <input id="memaar-search" type="search" autocomplete="off" aria-label="ابحث في البوابات" placeholder="ابحث في البوابات..."
        class="search-box w-full h-11 pr-11 pl-4 bg-mem-black border border-mem-gold/45 focus:border-mem-gold rounded-full text-sm text-mem-ivory placeholder-mem-ivory/40 outline-none focus:ring-2 focus:ring-mem-gold/25 transition-all gold-glow-soft" />
    </div>

    <div class="hidden lg:flex items-center gap-3 border-r border-mem-ivory/10 pr-5">
      <div class="text-left text-[11px] leading-tight">
        <p class="text-mem-gold font-bold">المشرف العام</p>
        <p class="text-mem-ivory font-semibold">أ. رماضنة عبد العزيز</p>
      </div>
      <span class="w-10 h-10 rounded-full border-2 border-mem-gold bg-[#12141a] flex items-center justify-center text-lg" aria-hidden="true">🧔</span>
    </div>

    <button id="mobile-menu-btn" type="button" aria-label="القائمة" aria-expanded="false" aria-controls="mobile-nav"
      class="lg:hidden w-11 h-11 rounded-full border border-mem-gold/60 text-mem-gold flex items-center justify-center">☰</button>
  </div>

  <nav id="mega-nav" aria-label="المعامير" class="hidden lg:block border-t border-mem-ivory/5">
    <ul class="max-w-7xl mx-auto flex items-stretch justify-center">
      {memaarData.map((pillar, idx) => (
        <li class="has-mega relative flex-1">
          <button type="button" aria-haspopup="true" aria-expanded="false" aria-controls={`mega-${pillar.id}`}
            class="mega-trigger w-full px-3 py-4 text-xs font-bold text-mem-ivory/85 flex items-center justify-center gap-1.5 font-thuluth transition-colors">
            <span class="text-mem-gold" aria-hidden="true">◆</span>
            <span class="whitespace-nowrap">{pillar.short}</span>
            <span class="chev text-[10px]" aria-hidden="true">▼</span>
          </button>
          <div id={`mega-${pillar.id}`}
            class:list={["mega-panel absolute top-full w-[min(560px,90vw)] p-5 bg-mem-black border border-mem-gold/70 rounded-2xl shadow-2xl", idx < 3 ? "right-0" : "left-0"]}>
            <a href={`#pillar-${pillar.id}`} class="block mb-3 text-xs font-bold text-mem-gold hover:underline">الانتقال إلى {pillar.short} ←</a>
            <div class="grid grid-cols-2 gap-4 max-h-[60vh] overflow-y-auto scrollbar-thin">
              {pillar.gates.map((gate) => (
                <div>
                  <p class="text-[11px] font-bold text-mem-rose mb-1">❖ {gate.title}</p>
                  <ul>{gate.axes.map((axis) => (<li class="text-[10.5px] text-mem-ivory/75">• {axis}</li>))}</ul>
                </div>
              ))}
            </div>
          </div>
        </li>
      ))}
    </ul>
  </nav>

  <nav id="mobile-nav" aria-label="المعامير (الجوال)" class="hidden lg:hidden border-t border-mem-ivory/5 bg-mem-black max-h-[70vh] overflow-y-auto">
    <ul class="p-3 space-y-2">
      {memaarData.map((pillar) => (
        <li>
          <a href={`#pillar-${pillar.id}`} data-mobile-link class="block rounded-xl border border-mem-gold/25 bg-[#12141a] p-3 text-xs text-mem-gold">{pillar.title}</a>
        </li>
      ))}
    </ul>
  </nav>
</header>
'@

# ------------------------------------------------------------
$files["src/components/HeroBanner.astro"] = @'
---
---
<section class="relative px-4 lg:px-8 pt-8 pb-4">
  <div class="relative mx-auto max-w-7xl rounded-3xl border-2 border-mem-gold/55 bg-gradient-to-b from-[#12141a] to-mem-black p-5 lg:p-9 overflow-hidden gold-glow-soft">
    <div class="grid grid-cols-12 gap-5 items-start mb-8">
      <div class="col-span-12 lg:col-span-3 flex justify-center gap-4">
        <figure class="text-center"><img src="/images/ibn-uthaymeen.jpg" alt="الشيخ ابن عثيمين" onerror="this.style.visibility='hidden'" class="w-20 h-20 rounded-full border-2 border-mem-gold object-cover" /><figcaption class="text-xs text-mem-gold mt-1">ابن عثيمين</figcaption></figure>
        <figure class="text-center"><img src="/images/qaradawi.jpg" alt="الشيخ القرضاوي" onerror="this.style.visibility='hidden'" class="w-20 h-20 rounded-full border-2 border-mem-gold object-cover" /><figcaption class="text-xs text-mem-gold mt-1">القرضاوي</figcaption></figure>
      </div>
      <div class="col-span-12 lg:col-span-6 flex flex-col items-center">
        <img src="/images/memaar-logo.png" alt="شعار أكاديمية مِعْمَار" class="w-40 h-40 object-contain" />
        <h1 class="mt-2 text-2xl lg:text-3xl font-bold text-gold-grad font-maryam text-center">أكاديمية مِعْمَار للنجاح الدراسي</h1>
        <div class="w-40 h-px shimmer-divider mt-3"></div>
      </div>
      <div class="col-span-12 lg:col-span-3 flex justify-center gap-4">
        <figure class="text-center"><img src="/images/einstein.jpg" alt="العالم أينشتاين" onerror="this.style.visibility='hidden'" class="w-20 h-20 rounded-full border-2 border-mem-gold object-cover" /><figcaption class="text-xs text-mem-gold mt-1">أينشتاين</figcaption></figure>
        <figure class="text-center"><img src="/images/tesla.jpg" alt="العالم تيسلا" onerror="this.style.visibility='hidden'" class="w-20 h-20 rounded-full border-2 border-mem-gold object-cover" /><figcaption class="text-xs text-mem-gold mt-1">تيسلا</figcaption></figure>
      </div>
    </div>

    <div class="grid grid-cols-12 gap-5">
      <div class="col-span-12 lg:col-span-3 bg-mem-black/60 border border-mem-gold/25 rounded-2xl p-4 text-center">
        <div class="text-5xl" aria-hidden="true">🎓</div>
        <p class="text-sm text-mem-gold font-amiri mt-2">علمٌ نافعٌ يرفعُ صاحبَه درجات</p>
      </div>
      <div class="col-span-12 lg:col-span-6">
        <a href="#" aria-label="مشاهدة: العالم أحمد زويل - نوبل الكيمياء 1999" class="group relative block aspect-video rounded-2xl border-2 border-mem-gold/60 overflow-hidden bg-[#12141a]">
          <img src="/images/zewail-nobel.jpg" alt="العالم أحمد زويل" onerror="this.style.visibility='hidden'" class="absolute inset-0 w-full h-full object-cover opacity-70" />
          <div class="absolute inset-0 flex items-center justify-center"><span class="w-20 h-20 bg-mem-gold rounded-full text-mem-black text-3xl flex items-center justify-center group-hover:scale-110 transition-transform" aria-hidden="true">▶</span></div>
          <div class="absolute bottom-0 p-4 w-full text-center bg-gradient-to-t from-mem-black to-transparent">
            <p class="text-xl text-mem-gold font-maryam">العالم أحمد زويل..</p>
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
'@

# ------------------------------------------------------------
$files["src/components/PillarCards.astro"] = @'
---
import { memaarData } from '../data/memaarData';
---
<section class="relative px-4 lg:px-8 pt-10 pb-6">
  <div class="max-w-7xl mx-auto text-center mb-8">
    <h2 class="text-3xl font-bold text-gold-grad font-thuluth">العمارة المعرفية الشاملة للأكاديمية</h2>
  </div>
  <div class="max-w-7xl mx-auto grid grid-cols-1 md:grid-cols-2 xl:grid-cols-5 gap-5">
    {memaarData.map((pillar) => (
      <a href={`#pillar-${pillar.id}`} class="pillar-card group rounded-2xl bg-mem-black border border-mem-gold/60 p-5 flex flex-col" data-search-card>
        <div class="flex items-center justify-between mb-3">
          <span class="w-11 h-11 rounded-xl border border-mem-gold/60 bg-mem-burgundy/15 flex items-center justify-center text-xl text-mem-gold" aria-hidden="true">🏛️</span>
          <span class="text-[10px] font-bold text-mem-rose bg-mem-burgundy/20 px-2 py-1 rounded-full">{pillar.gates.length} بوابات</span>
        </div>
        <h3 class="pillar-title text-base font-bold text-mem-ivory font-thuluth mb-2">{pillar.title}</h3>
        <p class="text-xs text-mem-ivory/70 font-amiri flex-1">{pillar.desc}</p>
      </a>
    ))}
  </div>
</section>
<div id="no-results" class="hidden max-w-7xl mx-auto px-4 pb-8 text-center text-mem-ivory/70" role="status">لا توجد نتائج مطابقة.</div>
'@

# ------------------------------------------------------------
$files["src/components/DeepSections.astro"] = @'
---
import { memaarData, twinSlots } from '../data/memaarData';
---
<section class="relative px-4 lg:px-8 pt-8 pb-4">
  <div class="max-w-7xl mx-auto flex flex-col md:flex-row justify-between items-center p-4 rounded-2xl bg-[#12141a] border border-mem-gold/35 gold-glow-soft">
    <div><h2 class="text-lg font-bold text-mem-ivory font-thuluth">نظام جسر التوأم — شارع البناء وشارع التعمق</h2></div>
    <div class="flex p-1 rounded-full bg-mem-black border border-mem-gold/40 mt-4 md:mt-0" role="group" aria-label="تبديل الشارع">
      <button type="button" class="twin-btn px-4 py-2 rounded-full text-xs font-bold" data-twin-btn="building" data-active="true" aria-pressed="true">🏗️ شارع البناء</button>
      <button type="button" class="twin-btn px-4 py-2 rounded-full text-xs font-bold" data-twin-btn="deepening" data-active="false" aria-pressed="false">🎓 شارع التعمق</button>
    </div>
  </div>
</section>

<main class="relative px-4 lg:px-8 pb-16">
  <div class="max-w-7xl mx-auto space-y-12">
    {memaarData.map((pillar) => (
      <section id={`pillar-${pillar.id}`} class="section-anchor-offset rounded-3xl border border-mem-gold/30 bg-gradient-to-b from-[#101117] to-mem-black p-5 lg:p-8" data-search-section>
        <header class="pb-5 border-b border-mem-burgundy/60 mb-5">
          <h2 class="text-2xl font-bold text-gold-grad font-thuluth">{pillar.title}</h2>
        </header>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-3 mb-7">
          {pillar.gates.map((gate) => (
            <div class="rounded-xl border border-mem-gold/25 bg-mem-black/70 p-4">
              <h3 class="text-sm font-bold text-mem-rose mb-2">❖ {gate.title}</h3>
              <ul>{gate.axes.map((axis) => (<li class="text-xs text-mem-ivory/80">• {axis}</li>))}</ul>
            </div>
          ))}
        </div>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-3">
          {twinSlots.building.map((slot) => (
            <div class="slot-card rounded-xl border border-mem-gold/35 bg-mem-black p-4" data-twin-scope="building">
              <span class="text-2xl" aria-hidden="true">{slot.icon}</span>
              <p class="text-sm font-bold text-mem-ivory mt-2">{slot.label}</p>
              <p class="text-xs text-mem-ivory/70 mt-1">{slot.desc}</p>
            </div>
          ))}
          {twinSlots.deepening.map((slot) => (
            <div class="slot-card rounded-xl border border-mem-gold/35 bg-mem-black p-4" data-twin-scope="deepening" data-twin-hidden="true">
              <span class="text-2xl" aria-hidden="true">{slot.icon}</span>
              <p class="text-sm font-bold text-mem-ivory mt-2">{slot.label}</p>
              <p class="text-xs text-mem-ivory/70 mt-1">{slot.desc}</p>
            </div>
          ))}
        </div>
      </section>
    ))}
  </div>
</main>
'@

# ------------------------------------------------------------
$files["src/components/Footer.astro"] = @'
---
import { memaarData } from '../data/memaarData';
const year = new Date().getFullYear();
---
<footer class="border-t border-mem-gold/40 bg-[#0a0b0f] py-10 mt-8">
  <div class="max-w-7xl mx-auto px-4 grid grid-cols-1 lg:grid-cols-3 gap-8 text-center lg:text-right">
    <div>
      <img src="/images/memaar-logo.png" alt="شعار أكاديمية مِعْمَار" class="w-16 h-16 mx-auto lg:mx-0 object-contain mb-2" />
      <p class="text-sm text-mem-ivory/70 font-amiri">منصة سحابية ثابتة تدمج بين العلوم الكونية والشرعية لتمكين الشباب المسلم.</p>
    </div>
    <div>
      <p class="text-xs text-mem-gold mb-3">المعامير</p>
      <ul class="grid grid-cols-2 gap-2">
        {memaarData.map((p) => (<li><a href={`#pillar-${p.id}`} class="text-xs text-mem-ivory/70 hover:text-mem-gold">◆ {p.short}</a></li>))}
      </ul>
    </div>
    <div>
      <p class="text-xs text-mem-gold mb-3">الإشراف</p>
      <p class="text-sm text-mem-ivory">الأستاذ الباحث رماضنة عبد العزيز</p>
    </div>
  </div>
  <div class="text-center text-[10px] text-mem-ivory/50 mt-8">جميع الحقوق محفوظة © {year}م — أكاديمية مِعْمَار</div>
</footer>
'@

# ------------------------------------------------------------
$files["src/pages/index.astro"] = @'
---
import Layout from '../layouts/Layout.astro';
import Header from '../components/Header.astro';
import HeroBanner from '../components/HeroBanner.astro';
import PillarCards from '../components/PillarCards.astro';
import DeepSections from '../components/DeepSections.astro';
import Footer from '../components/Footer.astro';
---
<Layout title="أكاديمية مِعْمَار — للنجاح الدراسي">
  <Header />
  <HeroBanner />
  <PillarCards />
  <DeepSections />
  <Footer />

  <script is:inline>
    (function () {
      var doc = document;
      var TWIN_KEY = 'memaar_twin_mode_v1';

      /* ---------- شارع البناء / التعمق ---------- */
      function getTwinMode() {
        try { var m = localStorage.getItem(TWIN_KEY); return (m === 'deepening') ? 'deepening' : 'building'; }
        catch (e) { return 'building'; }
      }
      function applyTwinMode(mode) {
        doc.querySelectorAll('[data-twin-scope]').forEach(function (el) {
          el.setAttribute('data-twin-hidden', el.getAttribute('data-twin-scope') === mode ? 'false' : 'true');
        });
        doc.querySelectorAll('[data-twin-btn]').forEach(function (btn) {
          var on = btn.getAttribute('data-twin-btn') === mode;
          btn.setAttribute('data-active', on ? 'true' : 'false');
          btn.setAttribute('aria-pressed', on ? 'true' : 'false');
        });
      }
      function setTwinMode(mode) {
        try { localStorage.setItem(TWIN_KEY, mode); } catch (e) {}
        applyTwinMode(mode);
      }
      doc.querySelectorAll('[data-twin-btn]').forEach(function (btn) {
        btn.addEventListener('click', function () { setTwinMode(btn.getAttribute('data-twin-btn')); });
      });

      /* ---------- البحث (يتجاهل التشكيل والهمزات) ---------- */
      function norm(s) {
        return (s || '').toLowerCase()
          .replace(/[\u064B-\u0652\u0640]/g, '')
          .replace(/[أإآ]/g, 'ا').replace(/ى/g, 'ي').replace(/ة/g, 'ه')
          .replace(/\s+/g, ' ');
      }
      var input = doc.getElementById('memaar-search');
      var noRes = doc.getElementById('no-results');
      var targets = Array.prototype.slice.call(doc.querySelectorAll('[data-search-card], [data-search-section]'));
      var cache = targets.map(function (el) { return norm(el.textContent); });
      if (input) {
        input.addEventListener('input', function () {
          var q = norm(input.value.trim()), anyCard = false;
          targets.forEach(function (el, i) {
            var match = q === '' || cache[i].indexOf(q) !== -1;
            el.setAttribute('data-search-hidden', match ? 'false' : 'true');
            if (match && el.hasAttribute('data-search-card')) anyCard = true;
          });
          if (noRes) noRes.classList.toggle('hidden', q === '' || anyCard);
        });
      }

      /* ---------- القائمة الكبرى (تمرير + نقر + Escape) ---------- */
      var megas = Array.prototype.slice.call(doc.querySelectorAll('.has-mega'));
      function closeMegas(except) {
        megas.forEach(function (m) {
          if (m === except) return;
          m.removeAttribute('data-open');
          var t = m.querySelector('.mega-trigger'); if (t) t.setAttribute('aria-expanded', 'false');
        });
      }
      megas.forEach(function (m) {
        var t = m.querySelector('.mega-trigger');
        if (!t) return;
        t.addEventListener('click', function (e) {
          e.stopPropagation();
          var open = m.getAttribute('data-open') === 'true';
          closeMegas(m);
          m.setAttribute('data-open', open ? 'false' : 'true');
          t.setAttribute('aria-expanded', open ? 'false' : 'true');
        });
      });
      doc.addEventListener('click', function () { closeMegas(null); });

      /* ---------- قائمة الجوال ---------- */
      var mBtn = doc.getElementById('mobile-menu-btn');
      var mNav = doc.getElementById('mobile-nav');
      function setMobile(open) {
        if (!mBtn || !mNav) return;
        mNav.classList.toggle('hidden', !open);
        mBtn.setAttribute('aria-expanded', open ? 'true' : 'false');
      }
      if (mBtn && mNav) {
        mBtn.addEventListener('click', function () { setMobile(mNav.classList.contains('hidden')); });
        doc.querySelectorAll('[data-mobile-link]').forEach(function (a) {
          a.addEventListener('click', function () { setMobile(false); });
        });
      }

      doc.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') { closeMegas(null); setMobile(false); }
      });

      applyTwinMode(getTwinMode());
    })();
  </script>
</Layout>
'@

# 3) الكتابة بترميز UTF-8 بدون BOM
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
foreach ($file in $files.Keys) {
  $full = Join-Path (Get-Location).Path $file
  $dir  = Split-Path $full -Parent
  if (!(Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  [System.IO.File]::WriteAllText($full, $files[$file], $utf8NoBom)
}

# 4) Tailwind: تثبيت تلقائي إن كان ناقصاً + ضبط astro.config.mjs
$needInstall = $true
if (Test-Path "package.json") {
  $pkg = Get-Content "package.json" -Raw
  if ($pkg -match '@tailwindcss/vite') { $needInstall = $false }
}
if ($needInstall) {
  Write-Host "⬇️ جارٍ تثبيت tailwindcss و @tailwindcss/vite ..." -ForegroundColor Cyan
  npm install tailwindcss @tailwindcss/vite
}

$cfgPath = Join-Path (Get-Location).Path "astro.config.mjs"
$cfgOk = $false
if (Test-Path $cfgPath) { $cfgOk = (Get-Content $cfgPath -Raw) -match '@tailwindcss/vite' }
if (-not $cfgOk) {
  if (Test-Path $cfgPath) { Copy-Item $cfgPath "$cfgPath.bak" -Force }
  $cfg = @'
import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
  vite: { plugins: [tailwindcss()] }
});
'@
  [System.IO.File]::WriteAllText($cfgPath, $cfg, $utf8NoBom)
  Write-Host "⚙️ تم ضبط astro.config.mjs (نسخة احتياطية: astro.config.mjs.bak)" -ForegroundColor Yellow
}

# 5) فحص الصور
$missing = @("memaar-logo.png","ibn-uthaymeen.jpg","qaradawi.jpg","einstein.jpg","tesla.jpg","zewail-nobel.jpg") | Where-Object { !(Test-Path "public/images/$_") }
if ($missing) { Write-Host "🖼️ صور ناقصة في public/images: $($missing -join ', ')" -ForegroundColor Yellow }

Write-Host "✅ تم إعادة بناء المشروع بالكامل بنجاح!  شغّل الآن: npm run dev" -ForegroundColor Green