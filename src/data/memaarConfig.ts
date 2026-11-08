import { memaarData } from './memaarData';

export const levelIds = ['level1', 'level2'] as const;
export type LevelId = (typeof levelIds)[number];

export const levels: Record<LevelId, string> = {
  level1: 'رَوَاسِخُ البِنَاءِ',
  level2: 'قِمَمُ المعالي',
};

export const contentTypes = ['article', 'book', 'video', 'tree'] as const;
export type ContentType = (typeof contentTypes)[number];

export const contentLabels: Record<ContentType, { title: string; kind: string; icon: string }> = {
  article: { title: 'المقالات والأبحاث', kind: 'مقال', icon: '📄' },
  book: { title: 'الكتب والطروحات', kind: 'كتاب', icon: '📚' },
  video: { title: 'المرئيات والدروس', kind: 'مرئي', icon: '🎬' },
  tree: { title: 'الشجرة المعرفية', kind: 'شجرة', icon: '🌳' },
};

export const portalIcons: Record<string, string> = {
  imani: '🕌',
  nafs: '🧠',
  tafawwuq: '📐',
  thaqafa: '🌍',
  manara: '🏛️',
};

export function getPortal(slug: string | undefined) {
  return memaarData.find((portal) => portal.slug === slug);
}

export function getHub(portal: ReturnType<typeof getPortal>, hubId: string | undefined) {
  return portal?.gates.find((gate) => String(gate.id) === hubId);
}

export function hubUrl(portalSlug: string, levelId: LevelId, hubId: number | string, type: ContentType) {
  return `/${portalSlug}/level/${levelId}/hub/${hubId}/${type}`;
}
