// Apple II utility procedures 25, 27, 29. See docs/remake/character-creation.md.
export const ATTRIBUTES = Object.freeze(['strength', 'intelligence', 'dexterity', 'charisma', 'luck']);
export const BUDGET = 440;
export const minimum = key => key === 'luck' ? 0 : 30;
export function createCharacter() {
  return { name: '', attributes: Object.fromEntries(ATTRIBUTES.map(key => [key, minimum(key)])) };
}

export function increaseCost(value) {
  let remainder = value - 30, cost = 1;
  while (remainder > 0) {
    cost *= 2;
    remainder -= remainder > 60 ? 10 : 20;
  }
  return cost;
}

export function pointsLeft(character) {
  let spent = 0;
  for (const key of ATTRIBUTES) {
    const value = character?.attributes?.[key];
    // These bounds also keep untrusted imports out of unbounded loops.
    if (!Number.isInteger(value) || value < minimum(key) || value > 100) return -1;
    for (let point = minimum(key) + 1; point <= value; point++) spent += increaseCost(point);
  }
  return BUDGET - spent;
}

export function adjustAttribute(character, key, delta) {
  if (!ATTRIBUTES.includes(key) || ![-1, 1].includes(delta) || pointsLeft(character) < 0) return character;
  const next = { ...character, attributes: { ...character.attributes, [key]: character.attributes[key] + delta } };
  return pointsLeft(next) >= 0 ? next : character;
}

export function normalizedName(name) {
  if (typeof name !== 'string' || name.length > 256) throw new Error('invalidName');
  const result = name.normalize('NFC').trim();
  if (!result || /[\p{Cc}\p{Cf}]/u.test(result) || [...new Intl.Segmenter(undefined, { granularity: 'grapheme' }).segment(result)].length > 15) {
    throw new Error('invalidName');
  }
  return result;
}

export function validateCharacter(value) {
  if (pointsLeft(value) < 0) throw new Error('invalidDraft');
  return { name: normalizedName(value.name), attributes: Object.fromEntries(ATTRIBUTES.map(key => [key, value.attributes[key]])) };
}
