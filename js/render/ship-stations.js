import { canStand, interactionAt } from '../core/ship-walk.js';

const targets = new WeakMap();

// Fixtures include solid walls. Mark the reachable approach pixels instead of
// their decorative centres. Pointer targets use the player's centre, whereas
// saved positions and interactionAt use its left edge and bottom row.
export function shipStationTargets(geometry) {
  if (!targets.has(geometry)) {
    const stations = [], seen = new Set(), queue = [geometry.spawn];
    for (let i = 0; i < queue.length; i++) {
      const position = queue[i], key = position.y * geometry.width + position.x;
      if (seen.has(key) || !canStand(geometry, position)) continue;
      seen.add(key);
      const station = interactionAt(position);
      if (station) stations.push({ station, x: position.x + 3, y: position.y - 3 });
      for (const [dx, dy] of [[-1, 0], [1, 0], [0, -1], [0, 1]]) {
        queue.push({ x: position.x + dx, y: position.y + dy });
      }
    }
    targets.set(geometry, stations);
  }
  return targets.get(geometry);
}

export function drawShipStations(context, geometry, bounds, position, { campaign, landed, podAttached }) {
  const active = interactionAt(position, landed);
  context.save();
  for (const target of shipStationTargets(geometry)) {
    const id = target.station;
    if (id === 7 || (!campaign && id !== 5 && id !== 6) ||
        (!landed && (id === 3 || id === 4)) || (id === 3 && !podAttached)) continue;
    context.fillStyle = id === active ? '#eab975' : '#eab97580';
    context.fillRect(bounds.x + target.x * bounds.width / geometry.width,
      bounds.y + target.y * bounds.height / geometry.height,
      bounds.width / geometry.width, bounds.height / geometry.height);
  }
  context.restore();
}
