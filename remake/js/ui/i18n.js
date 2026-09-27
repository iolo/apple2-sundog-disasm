export function translator(catalogs, locale) {
  return (key, parameters = {}) => {
    const value = catalogs[locale]?.[key] ?? catalogs.en[key];
    if (value === undefined) throw new Error(`Missing translation: ${key}`);
    return value.replace(/\{(\w+)\}/g, (_, name) => String(parameters[name] ?? `{${name}}`));
  };
}

export function readLocale() {
  try {
    const saved = localStorage.getItem('sundog.locale');
    if (saved === 'en' || saved === 'ko') return saved;
  } catch { /* Preferences are optional when storage is unavailable. */ }
  return navigator.language.startsWith('ko') ? 'ko' : 'en';
}

export function saveLocale(locale) {
  try { localStorage.setItem('sundog.locale', locale); } catch { /* Keep the current session usable. */ }
}
