$ErrorActionPreference = "Stop"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Write-File($path, $text) {
  $full = Join-Path (Get-Location).Path $path
  $dir = Split-Path $full -Parent
  if (!(Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  [IO.File]::WriteAllText($full, $text, $utf8NoBom)
}

Write-Host "⏳ جارٍ تحديث البيانات الدقيقة (20 بوابة ومحاورها)... " -ForegroundColor Cyan

# 1. تحديث ملف البيانات (الكنز الحقيقي)
Write-File "src/data/memaarData.ts" @'
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

Write-Host "🛠️ جارٍ ترقيع المكونات لاستيعاب البيانات الجديدة وإصلاح زر التعمق..." -ForegroundColor Cyan

# 2. تحديث بطاقات المعامير (PillarCards) لقراءة عدد البوابات بشكل صحيح
$pcPath = "src/components/PillarCards.astro"
if (Test-Path $pcPath) {
  $t = [IO.File]::ReadAllText($pcPath)
  $t = $t.Replace('{pillar.gates} بوابات', '{pillar.gates.length} بوابات')
  [IO.File]::WriteAllText((Join-Path (Get-Location).Path $pcPath), $t, $utf8NoBom)
}

# 3. تحديث قسم التعمق (DeepSections) لإصلاح الخلل المنطقي
Write-File "src/components/DeepSections.astro" @'
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
              <span class="text-2xl">{slot.icon}</span>
              <p class="text-sm font-bold text-mem-ivory mt-2">{slot.label}</p>
              <p class="text-xs text-mem-ivory/70 mt-1">{slot.desc}</p>
            </div>
          ))}
          {twinSlots.deepening.map((slot) => (
            <div class="slot-card rounded-xl border border-mem-gold/35 bg-mem-black p-4" data-twin-scope="deepening" data-twin-hidden="true">
              <span class="text-2xl">{slot.icon}</span>
              <p class="text-sm font-bold text-mem-ivory mt-2">{slot.label}</p>
              <p class="text-xs text-mem-ivory/70 mt-1">{slot.desc}</p>
            </div>
          ))}
        </div>
      </section>
    ))}
  </div>
</main>

<script is:inline>
  (function () {
    var TWIN_KEY = 'memaar_twin_mode_v1';
    function getTwinMode() { try { var m = localStorage.getItem(TWIN_KEY); return (m === 'deepening') ? 'deepening' : 'building'; } catch (e) { return 'building'; } }
    function applyTwinMode(mode) {
      document.querySelectorAll('[data-twin-scope]').forEach(function (el) {
        el.setAttribute('data-twin-hidden', el.getAttribute('data-twin-scope') === mode ? 'false' : 'true');
      });
      document.querySelectorAll('[data-twin-btn]').forEach(function (btn) {
        var on = btn.getAttribute('data-twin-btn') === mode;
        btn.setAttribute('data-active', on ? 'true' : 'false');
        btn.setAttribute('aria-pressed', on ? 'true' : 'false');
      });
    }
    document.querySelectorAll('[data-twin-btn]').forEach(function (btn) {
      btn.addEventListener('click', function () {
        var mode = btn.getAttribute('data-twin-btn');
        try { localStorage.setItem(TWIN_KEY, mode); } catch (e) {}
        applyTwinMode(mode);
      });
    });
    applyTwinMode(getTwinMode());
  })();
</script>
'@

Write-Host "✅ تمت العملية بنجاح! واجهتك الفخمة محفوظة، والبيانات الصحيحة تم حقنها." -ForegroundColor Green
Write-Host "شغّل الآن: npm run dev" -ForegroundColor Yellow