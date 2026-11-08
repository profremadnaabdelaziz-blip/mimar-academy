// src/data/memaarContent.ts
import { memaarData } from "./memaarData";
import type { Gate, Pillar } from "./memaarData";

export type ContentType = "article" | "book" | "lecture" | "exercise";

export interface Hub {
  id: number;
  title: string;
  description?: string;
}

export interface ContentItem {
  id: string;
  hubId: number;
  title: string;
  type: ContentType;
  summary: string;
  author?: string;
  duration?: string;
  readTime?: string;
  pages?: number;
  slug: string;
}

type TypeMeta = {
  label: string;
  summaryPrefix: string;
  readTime?: string;
  pages?: number;
  duration?: string;
};

const TYPE_META: Record<ContentType, TypeMeta> = {
  article: {
    label: "مقال",
    summaryPrefix: "مقال تأصيلي",
    readTime: "8 دقائق",
  },
  book: {
    label: "كتاب",
    summaryPrefix: "كتاب منهجي",
    pages: 120,
  },
  lecture: {
    label: "محاضرة",
    summaryPrefix: "محاضرة علمية",
    duration: "45 دقيقة",
  },
  exercise: {
    label: "تمرين",
    summaryPrefix: "تمرين تطبيقي",
    duration: "20 دقيقة",
  },
};

const TYPE_ORDER: ContentType[] = ["article", "book", "lecture", "exercise"];

function buildGeneratedItems(pillar: Pillar, gate: Gate): ContentItem[] {
  const description = gate.description || pillar.description;

  return TYPE_ORDER.map((type) => {
    const meta = TYPE_META[type];

    const item: ContentItem = {
      id: `hub-${gate.id}-${type}`,
      hubId: gate.id,
      title: `${gate.title} — ${meta.label}`,
      type,
      summary: `${meta.summaryPrefix}: ${description}`,
      author: "أكاديمية مِعْمَار",
      slug: `hub-${gate.id}-${type}`,
    };

    if (type === "article") item.readTime = meta.readTime;
    if (type === "book") item.pages = meta.pages;
    if (type === "lecture" || type === "exercise") item.duration = meta.duration;

    return item;
  });
}

// تخصيصات يدوية لبعض البوابات (اختياري)
const SEED_OVERRIDES: Record<number, ContentItem[]> = {
  1: [
    {
      id: "c1",
      hubId: 1,
      title: "تصفية النية في طلب العلم الشرعي والتجريبي",
      type: "article",
      summary: "كيف يحول الطالب مقعده الدراسي إلى محراب عبادة.",
      readTime: "8 دقائق",
      slug: "cleansing-niyah",
      author: "أكاديمية مِعْمَار",
    },
    {
      id: "c2",
      hubId: 1,
      title: "إحياء اليقين في طلب المعرفة",
      type: "book",
      summary: "كتاب تأصيلي في فقه الغايات والوسائل.",
      pages: 145,
      slug: "ihya-yaqeen",
      author: "أكاديمية مِعْمَار",
    },
  ],
  5: [
    {
      id: "c3",
      hubId: 5,
      title: "مدخل إلى الأورغانون المنطقي",
      type: "lecture",
      summary: "شرح مفصل لمبادئ الاستدلال والمنطق السليم.",
      duration: "45 دقيقة",
      slug: "intro-logic",
      author: "أكاديمية مِعْمَار",
    },
  ],
};

function mergeOverrides(
  generated: ContentItem[],
  overrides: ContentItem[] = []
): ContentItem[] {
  const byType = new Map<ContentType, ContentItem>();

  generated.forEach((item) => byType.set(item.type, item));
  overrides.forEach((item) => byType.set(item.type, item));

  return TYPE_ORDER.map((type) => byType.get(type)).filter(
    Boolean
  ) as ContentItem[];
}

export const contentDatabase: Record<number, ContentItem[]> = {};

memaarData.forEach((pillar) => {
  pillar.gates.forEach((gate) => {
    const generated = buildGeneratedItems(pillar, gate);
    contentDatabase[gate.id] = mergeOverrides(
      generated,
      SEED_OVERRIDES[gate.id]
    );
  });
});

export const allContent: ContentItem[] = Object.values(contentDatabase).flat();

export function getItems(
  hub: Hub | undefined,
  type?: ContentType
): ContentItem[] {
  if (!hub || !Number.isFinite(Number(hub.id))) return [];

  const items = contentDatabase[Number(hub.id)] ?? [];
  if (!type) return items;

  return items.filter((item) => item.type === type);
}

export function getItemsByGateId(
  gateId: number | string,
  type?: ContentType
): ContentItem[] {
  const id = Number(gateId);
  if (!Number.isFinite(id)) return [];

  const items = contentDatabase[id] ?? [];
  if (!type) return items;

  return items.filter((item) => item.type === type);
}

export function getContentStats() {
  const byType = TYPE_ORDER.reduce((acc, type) => {
    acc[type] = allContent.filter((item) => item.type === type).length;
    return acc;
  }, {} as Record<ContentType, number>);

  return {
    total: allContent.length,
    gates: Object.keys(contentDatabase).length,
    byType,
  };
}