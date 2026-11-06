// src/lib/navIndex.ts — بناء فهرس التنقل للبحث السريع ولوحة الأوامر (Command Palette)
import { memaarData } from '../data/memaarData';
import { levelIds, levels, hubUrl } from '../data/memaarConfig';
import { getItems } from '../data/memaarContent';

export interface NavEntry {
  kind: 'portal' | 'hub' | 'content';
  title: string;
  context: string;
  href: string;
  keywords: string;
}

export function buildNavIndex(): NavEntry[] {
  const entries: NavEntry[] = [];

  memaarData.forEach((portal) => {
    entries.push({
      kind: 'portal',
      title: portal.title,
      context: portal.subtitle || 'بوابة رئيسية',
      href: portal.gates[0] ? hubUrl(portal.slug, 'level1', portal.gates[0].id, 'article') : '/',
      keywords: portal.desc || '',
    });

    portal.gates.forEach((hub) => {
      const hubSummary = hub.axes?.join(' ') || '';
      
      levelIds.forEach((levelId) => {
        entries.push({
          kind: 'hub',
          title: hub.title,
          context: `${portal.title} — ${levels[levelId]}`,
          href: hubUrl(portal.slug, levelId, hub.id, 'article'),
          keywords: hubSummary,
        });

        const items = getItems(hub, 'article');
        items.forEach((item) => {
          entries.push({
            kind: 'content',
            title: item.title,
            context: `${hub.title} (${levels[levelId]})`,
            href: item.href || hubUrl(portal.slug, levelId, hub.id, 'article'),
            keywords: item.summary || item.author || '',
          });
        });

        const books = getItems(hub, 'book');
        books.forEach((book) => {
          entries.push({
            kind: 'content',
            title: book.title,
            context: `كتاب: ${hub.title}`,
            href: book.href || hubUrl(portal.slug, levelId, hub.id, 'book'),
            keywords: book.summary || book.author || '',
          });
        });
      });
    });
  });

  return entries;
}