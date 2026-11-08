// src/lib/bookmarks.ts — حفظ المحتوى للاحقاً في المتصفح
const STORAGE_KEY = 'memaar:bookmarks';

export function getBookmarks(): string[] {
  try {
    const parsed: unknown = JSON.parse(localStorage.getItem(STORAGE_KEY) ?? '[]');
    return Array.isArray(parsed) ? parsed.filter((v): v is string => typeof v === 'string') : [];
  } catch {
    return [];
  }
}

export function toggleBookmark(id: string): boolean {
  const current = getBookmarks();
  const next = current.includes(id) ? current.filter((v) => v !== id) : [...current, id];
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(next));
  } catch {}
  return next.includes(id);
}

function paintButton(btn: HTMLButtonElement, pressed: boolean): void {
  btn.setAttribute('aria-pressed', String(pressed));
  btn.setAttribute('aria-label', pressed ? 'إزالة من المحفوظات' : 'حفظ للاحقاً');
  btn.querySelector('svg')?.setAttribute('fill', pressed ? 'currentColor' : 'none');
}

export function initBookmarkButtons(onToggle?: (id: string, pressed: boolean) => void): void {
  const saved = new Set(getBookmarks());
  document.querySelectorAll<HTMLButtonElement>('[data-bookmark]').forEach((btn) => {
    const id = btn.dataset.bookmark ?? '';
    paintButton(btn, saved.has(id));
    btn.addEventListener('click', () => {
      const pressed = toggleBookmark(id);
      document
        .querySelectorAll<HTMLButtonElement>('[data-bookmark]')
        .forEach((other) => {
          if (other.dataset.bookmark === id) paintButton(other, pressed);
        });
      onToggle?.(id, pressed);
    });
  });
}
