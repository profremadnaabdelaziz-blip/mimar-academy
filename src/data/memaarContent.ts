import type { ContentType } from './memaarConfig';

export interface ContentItem {
  title: string;
  author?: string;
  duration?: string;
  summary?: string;
  href?: string;
}

export interface TreeNode {
  title: string;
  href?: string;
  children?: TreeNode[];
}

interface Hub {
  id: number;
}

// Hub content is not connected yet; every hub renders its empty state until it is.
export function getItems(_hub: Hub, _type: ContentType): ContentItem[] {
  return [];
}

export function getTree(_hub: Hub): TreeNode[] {
  return [];
}

export function countFor(_hub: Hub, _type: ContentType): number {
  return 0;
}
