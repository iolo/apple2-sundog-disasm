// Library22 procedure3 ($0C00–$0C27). Seven shifts; Pascal result is
// byte2 as low byte and (byte0 >> 1) as high byte. State is little-endian.
export function sourceRandom(seed) {
  if (!Number.isInteger(seed) || seed < 0 || seed > 0xffffffff) throw new Error('Invalid random seed');
  let state = seed >>> 0;
  return {
    get state() { return state; },
    next() {
      for (let i = 0; i < 7; i++) state = ((state << 1) | (((state >>> 6) ^ (state >>> 30)) & 1)) >>> 0;
      return ((state & 255) >>> 1) * 256 + ((state >>> 16) & 255);
    },
  };
}
