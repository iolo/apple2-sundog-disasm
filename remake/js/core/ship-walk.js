// Source-backed movement only; no campaign time, inventory or economy is advanced.
// x is the sprite's left edge; y is its bottom row (inclusive).
const detachedGeometries=new WeakMap();
export function detachedShipGeometry(geometry) {
  if(!detachedGeometries.has(geometry))detachedGeometries.set(geometry,{...geometry,backgrounds:{...geometry.backgrounds,ship:geometry.backgrounds['ship-section']}});
  return detachedGeometries.get(geometry);
}
export function canStand(geometry, point, variant = 'ship') {
  const { x, y } = point, rows = geometry.backgrounds[variant];
  const bounds=geometry.walkBounds;
  if(bounds&&(x<bounds.left||x>bounds.right||y<bounds.top||y>bounds.bottom)) return false;
  if (!rows || !Number.isInteger(x) || !Number.isInteger(y) || x < 0 || x + 7 > geometry.width || y < 7 || y >= geometry.height) return false;
  return geometry.collisionRows.every((mask, row) => {
    for (let bit = 0; bit < 7; bit++) {
      const px = x + bit;
      if ((mask & (1 << bit)) && (rows[y - 7 + row][Math.floor(px / 7)] & (1 << (px % 7)))) return false;
    }
    return true;
  });
}

// Library22 procedure22 stops at the first successful diagonal/X/Y attempt.
export function tryStep(geometry, position, dx, dy, variant = 'ship') {
  if (!Number.isInteger(dx) || !Number.isInteger(dy) || Math.abs(dx) > 2 || Math.abs(dy) > 2 || (!dx && !dy)) return position;
  for (const [x, y] of [[dx, dy], [dx, 0], [0, dy]]) {
    const next = { x: position.x + x, y: position.y + y };
    if (canStand(geometry, next, variant)) return next;
  }
  return position;
}

// Game15 procedure13 offsets the pointer to the visible sprite's center.
export function walkToward(geometry, position, pointer, variant = 'ship') {
  const dx = Math.trunc(pointer.x) - 3 - position.x;
  const dy = Math.trunc(pointer.y) + 3 - position.y;
  const sx = Math.sign(dx) * Math.min(2, Math.abs(dx));
  const sy = Math.sign(dy) * Math.min(2, Math.abs(dy));
  const next = tryStep(geometry, position, sx, sy, variant);
  return next.x === position.x && next.y === position.y
    ? tryStep(geometry, position, Math.sign(sx), Math.sign(sy), variant) : next;
}

// Game15 procedure14. Exit IDs 3/4 additionally require a landed location.
export function interactionAt({ x, y }, landed = true) {
  const column = Math.trunc((x + 3) / 7), lowerRow = Math.trunc((y - 3) / 8), upperRow = Math.trunc((y - 5) / 8);
  if (column === 6 && lowerRow === 12) return 1;
  if (column === 8) return lowerRow === 14 && landed ? 4 : lowerRow === 10 ? 6 : 0;
  if (column === 12 && lowerRow === 13) return 5;
  if (column === 14 && lowerRow === 14 && landed) return 3;
  if (column === 16) return lowerRow === 8 ? 10 : lowerRow === 16 ? 11 : lowerRow === 18 ? 13 : upperRow === 6 ? 8 : 0;
  if (column === 17) return lowerRow === 15 ? 7 : lowerRow === 7 ? 9 : lowerRow === 17 ? 12 : 0;
  return 0;
}

// Presentation cadence for this isolated walkthrough, not original-game timing.
export const WALK_STEP_MS = 50;
export function createWalk(geometry) {
  return { position: { ...geometry.spawn }, pointer: null, held: false, paused: false, elapsed: 0 };
}
export function advanceWalk(state, milliseconds, geometry) {
  if (state.paused || !state.held || !state.pointer) return { ...state, elapsed: 0 };
  // A delayed frame cannot create a large catch-up movement.
  let elapsed = state.elapsed + Math.max(0, Math.min(100, milliseconds));
  let position = state.position;
  while (elapsed >= WALK_STEP_MS) {
    position = walkToward(geometry, position, state.pointer);
    elapsed -= WALK_STEP_MS;
  }
  return { ...state, position, elapsed };
}
