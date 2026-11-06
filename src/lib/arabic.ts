// src/lib/arabic.ts — تطبيع النصوص العربية لتسهيل البحث والمقارنة
export function normalizeArabic(text: string): string {
  if (!text) return '';
  return text
    .toLowerCase()
    .replace(/[\u064b-\u0652]/g, '') // إزالة التشكيل
    .replace(/[إأآا]/g, 'ا') // توحيد الألفات
    .replace(/ة/g, 'ه') // توحيد الهاء والتاء المربوطة
    .replace(/ى/g, 'ي') // توحيد الياء والألف المقصورة
    .replace(/ـ/g, ''); // إزالة الكشيدة
}