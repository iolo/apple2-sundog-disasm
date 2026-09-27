import { canStand, tryStep, walkToward, interactionAt, createWalk, advanceWalk } from '../js/core/ship-walk.js';

export async function shipWalkTests(test, equal) {
  const geometry = await fetch('../data/ship-walk.json').then(response => response.json());
  await test('Fresh-game spawn and exact player-mask extents', () => {
    equal(canStand(geometry, geometry.spawn), true);
    equal(canStand(geometry, { x: -1, y: 110 }), false);
    equal(canStand(geometry, { x: 54.1, y: 110 }), false);
    equal(canStand(geometry, { x: 54, y: 192 }), false);
    const clear = { ...geometry, backgrounds: { ship: Array.from({ length: 192 }, () => Array(40).fill(0)) } };
    const point = { x: 54, y: 110 };
    // Sprite left column is outside its collision mask; x+1, y−5 is inside it.
    clear.backgrounds.ship[105][Math.floor(54 / 7)] |= 1 << (54 % 7);
    equal(canStand(clear, point), true);
    clear.backgrounds.ship[105][Math.floor(55 / 7)] |= 1 << (55 % 7);
    equal(canStand(clear, point), false);
  });
  await test('MAME endpoint: (50,99) toward pointer (3,81) stops at (47,93)', () => {
    let position = { x: 50, y: 99 };
    const path = [[48, 97], [48, 95], [48, 93], [47, 93]];
    for (const [x, y] of path) {
      position = walkToward(geometry, position, { x: 3, y: 81 });
      equal(position, { x, y }); equal(canStand(geometry, position), true);
    }
    for (let i = 0; i < 20; i++) position = walkToward(geometry, position, { x: 3, y: 81 });
    equal(position, { x: 47, y: 93 });
    // Larger steps fail here, but the evidenced one-pixel retry can still move left.
    equal(tryStep(geometry, { x: 48, y: 93 }, -2, -2), { x: 48, y: 93 });
  });
  await test('Pointer centering settles exactly without oscillation or mutating input', () => {
    const position = { ...geometry.spawn };
    equal(walkToward(geometry, position, { x: position.x + 3, y: position.y - 3 }), position);
    walkToward(geometry, position, { x: 80, y: 110 });
    equal(position, geometry.spawn);
  });
  await test('Native interaction-cell boundaries and landed exit guard', () => {
    equal(interactionAt({ x: 42, y: 100 }), 1);
    equal(interactionAt({ x: 42, y: 99 }), 1);
    equal(interactionAt({ x: 42, y: 98 }), 0);
    equal(interactionAt({ x: 56, y: 116 }), 4);
    equal(interactionAt({ x: 56, y: 116 }, false), 0);
    equal(interactionAt({ x: 84, y: 110 }), 5);
    equal(interactionAt({ x: 112, y: 71 }), 10);
  });
  await test('Fixed movement cadence, release, pause and bounded catch-up', () => {
    const start = { ...createWalk(geometry), held: true, pointer: { x: 80, y: 110 } };
    let small = start;
    for (let i = 0; i < 10; i++) small = advanceWalk(small, 10, geometry);
    equal(small, advanceWalk(start, 100, geometry));
    equal(advanceWalk(start, 10000, geometry), advanceWalk(start, 100, geometry));
    equal(advanceWalk({ ...start, paused: true }, 100, geometry).position, start.position);
    equal(advanceWalk({ ...start, held: false }, 100, geometry).position, start.position);
  });
  await test('All 1784 connected ship positions stay clear across input directions', () => {
    const seen = new Set(), queue = [{ ...geometry.spawn }];
    for (let index = 0; index < queue.length; index++) {
      const point = queue[index], key = `${point.x},${point.y}`;
      if (seen.has(key)) continue; seen.add(key);
      for (const [dx, dy] of [[1, 0], [-1, 0], [0, 1], [0, -1]]) {
        const next = { x: point.x + dx, y: point.y + dy };
        if (canStand(geometry, next) && !seen.has(`${next.x},${next.y}`)) queue.push(next);
      }
      for (const dx of [-2, 0, 2]) for (const dy of [-2, 0, 2]) {
        equal(canStand(geometry, walkToward(geometry, point, { x: point.x + 3 + dx, y: point.y - 3 + dy })), true);
      }
    }
    equal(seen.size, 1784);
  });
}
