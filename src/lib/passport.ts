// src/lib/passport.ts — نظام جواز السفر الرقمي لتتبع مكان الطالب ومساره في المنصة
export interface PassportEntry {
  title: string;
  href: string;
  timestamp: number;
}

export interface PassportState {
  last: PassportEntry | null;
  byPortal: Record<string, PassportEntry>;
  visitedHubs: Record<string, string[]>;
}

const STORAGE_KEY = 'memaar:passport:v1';

export function getPassport(): PassportState {
  if (typeof window === 'undefined') {
    return { last: null, byPortal: {}, visitedHubs: {} };
  }
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return { last: null, byPortal: {}, visitedHubs: {} };
    return JSON.parse(raw);
  } catch {
    return { last: null, byPortal: {}, visitedHubs: {} };
  }
}

export function savePassport(state: PassportState): void {
  if (typeof window === 'undefined') return;
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
  } catch {
    // التخزين غير متاح
  }
}

export function recordVisit(portalSlug: string, hubId: string, title: string, href: string) {
  const state = getPassport();
  const entry: PassportEntry = { title, href, timestamp: Date.now() };
  
  state.last = entry;
  state.byPortal[portalSlug] = entry;

  if (!state.visitedHubs[portalSlug]) {
    state.visitedHubs[portalSlug] = [];
  }
  if (!state.visitedHubs[portalSlug].includes(hubId)) {
    state.visitedHubs[portalSlug].push(hubId);
  }

  savePassport(state);
}

export function visitedCount(state: PassportState, portalSlug: string): number {
  return state.visitedHubs[portalSlug]?.length ?? 0;
}