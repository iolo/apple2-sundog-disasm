import { createCondition } from './condition.js';

// Library22 procedures29/60: one update per crossed game hour. Rates are
// indexed by the PRE-update byte's 64-point band; vigor uses the updated trio.
export function conditionHour(condition, sleeping = false) {
  const next = createCondition(condition);
  const recovery = Math.max(0, Math.trunc((condition.vigor - 128) / 32));
  const drain = { rest: [4, 2, 3, 4], health: [1, 0, 0, 0], nourishment: [1, 1, 2, 3] };
  let penalty = 0, total = 0;
  for (const field of ['rest', 'health', 'nourishment']) {
    let value = next[field];
    if (field !== 'rest' || !sleeping) value -= drain[field][Math.floor(value / 64)];
    if (field === 'health' && value > 128) value += recovery * 4;
    next[field] = Math.max(0, Math.min(255, value));
    if (next[field] < 64) penalty += Math.floor(next[field] / 16) - 4;
    total += next[field];
  }
  next.vigor = Math.max(0, Math.min(255, condition.vigor + (penalty < 0 ? penalty : 2 * Math.sign(Math.floor(total / 3) - condition.vigor))));
  return { condition: next, exhausted: next.rest === 0, dead: next.vigor === 0 };
}

// Browser presentation rates, not Apple II cycle timing. Normal play advances
// one game minute/second; sleep runs its source iterations every 50 ms.
export const GAME_MINUTE_MS = 1000, SLEEP_ITERATION_MS = 50;
export function createSurvival(condition) {
  return { condition: createCondition(condition), minutes: 0, elapsed: 0,
    sleeping: false, forced: false, dead: false, sleepPhase: 0, shipPhase: 0 };
}
export function startSleep(state) {
  return state.dead ? state : { ...state, sleeping: true, elapsed: 0, sleepPhase: 0, shipPhase: 0 };
}
export function wakeUp(state) {
  return state.forced || state.dead ? state : { ...state, sleeping: false, elapsed: 0 };
}
export function advanceSurvival(state, milliseconds, paused = false) {
  if (paused || state.dead) return { ...state, elapsed: 0 };
  const next = { ...state, condition: createCondition(state.condition), elapsed: state.elapsed + Math.max(0, Math.min(250, milliseconds)) };
  function minute() {
    next.minutes++;
    if (next.minutes % 60 !== 0) return;
    const update = conditionHour(next.condition, next.sleeping);
    next.condition = update.condition; next.dead = update.dead;
    if (update.exhausted && !next.sleeping && !next.dead) {
      next.sleeping = true; next.forced = true; next.sleepPhase = 0; next.shipPhase = 0;
    }
  }
  while (!next.dead && next.elapsed >= (next.sleeping ? SLEEP_ITERATION_MS : GAME_MINUTE_MS)) {
    const sleeping = next.sleeping;
    next.elapsed -= sleeping ? SLEEP_ITERATION_MS : GAME_MINUTE_MS;
    if (!sleeping) minute();
    else {
      // Game8 procedure17 + library24 procedure9: clock once per four calls,
      // followed by one rest point every second sleep-loop iteration.
      if (next.shipPhase === 0) minute();
      next.shipPhase = (next.shipPhase + 1) % 4;
      next.sleepPhase = (next.sleepPhase + 1) % 2;
      if (!next.dead && next.sleepPhase === 0) next.condition.rest = Math.min(255, next.condition.rest + 1);
      if (next.condition.rest > 128) next.forced = false;
    }
  }
  if (next.dead) { next.sleeping = false; next.elapsed = 0; }
  return next;
}
