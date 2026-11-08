// src/data/memaarLabels.ts — أسماء وأيقونات العرض للمستويات وأنواع المحتوى والبوابات
import type { ContentType } from './memaarContent';

export const levelIds = [1, 2] as const;

export const levels: Record<number, string> = {
  1: 'رَوَاسِخُ البِنَاءِ',
  2: 'قِمَمُ المعالي',
};

export const contentTypes: ContentType[] = ['article', 'book', 'video'];

export const contentLabels: Record<ContentType, { title: string; kind: string; icon: string }> = {
  article: { title: 'المقالات والأبحاث', kind: 'مقال', icon: '📄' },
  book: { title: 'الكتب والطروحات', kind: 'كتاب', icon: '📚' },
  video: { title: 'المرئيات والدروس', kind: 'مرئي', icon: '🎬' },
};

export const portalIcons: Record<string, string> = {
  'niyah-message': '🕌',
  'foundation-method': '🧭',
  'awareness-certainty': '🧠',
  'culture-tributaries': '🌍',
  'excellence-empowerment': '📐',
};
