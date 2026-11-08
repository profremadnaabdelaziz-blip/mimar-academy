// src/data/memaarContent.ts
import { memaarData } from './memaarData';
import { hubUrl } from './memaarConfig';

export type ContentType = 'article' | 'book' | 'video';

export interface ContentItem {
  id: string;
  hubId: number;
  type: ContentType;
  title: string;
  summary: string;
  slug: string;
  url: string;
  meta: string; // read time, pages, or duration
}

const contentDatabase: Record<number, ContentItem[]> = {};

memaarData.forEach((pillar) => {
  pillar.gates.forEach((gate) => {
    const focus =
      (gate as { description?: string }).description || gate.axes.join('، ');
    const typeUrl = (type: ContentType) => hubUrl(pillar.slug, 'level1', gate.id, type);

    contentDatabase[gate.id] = [
      {
        id: `art-${gate.id}`,
        hubId: gate.id,
        type: 'article',
        title: `مقال: ${gate.title}`,
        summary: `قراءة تحليلية في ${focus} وكيفية تطبيقها عملياً.`,
        slug: `article-${gate.id}`,
        url: typeUrl('article'),
        meta: 'قراءة 5 دقائق',
      },
      {
        id: `book-${gate.id}`,
        hubId: gate.id,
        type: 'book',
        title: `كتاب: دليل ${gate.title}`,
        summary: `مرجع تأصيلي شامل يغطي ${focus}.`,
        slug: `book-${gate.id}`,
        url: typeUrl('book'),
        meta: '120 صفحة',
      },
      {
        id: `vid-${gate.id}`,
        hubId: gate.id,
        type: 'video',
        title: `مرئي: شرح ${gate.title}`,
        summary: `محاضرة مرئية توضح معالم ${focus}.`,
        slug: `video-${gate.id}`,
        url: typeUrl('video'),
        meta: 'مدة 45 دقيقة',
      },
    ];
  });
});

export function getItemsByHubId(hubId: number | string): ContentItem[] {
  const id = Number(hubId);
  return contentDatabase[id] || [];
}

// Tree content is not connected yet; the tree tab renders its empty state.
export function getTree(): [] {
  return [];
}
