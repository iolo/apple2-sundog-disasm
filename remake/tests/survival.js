import { conditionHour, createSurvival, advanceSurvival, startSleep, wakeUp } from '../js/core/survival.js';

const full = { vigor: 255, rest: 255, health: 255, nourishment: 255 };
const run = (state, ms, chunk = 50, paused = false) => {
  for (let left = ms; left > 0; left -= chunk) state = advanceSurvival(state, Math.min(left, chunk), paused);
  return state;
};
export async function survivalTests(test, equal) {
  await test('Hour boundary drains rest/nourishment and adjusts vigor from updated values', () => {
    const state = createSurvival(full), before = JSON.stringify(state);
    equal(run(state, 59999).condition, full);
    const hour = run(state, 60000);
    equal(hour.minutes, 60); equal(hour.condition, { vigor: 253, rest: 251, health: 255, nourishment: 252 });
    equal(JSON.stringify(state), before);
  });
  await test('Source drain bands, health recovery threshold and low-condition penalties', () => {
    for (const [value, rest, nourishment] of [[0,0,0],[1,0,0],[63,59,62],[64,62,63],[127,125,126],[128,125,126],[191,188,189],[192,188,189],[255,251,252]]) {
      const result = conditionHour({ ...full, rest:value, nourishment:value });
      equal(result.condition.rest, rest); equal(result.condition.nourishment, nourishment);
    }
    equal(conditionHour({ ...full, health:128 }).condition.health,128);
    equal(conditionHour({ ...full, health:129 }).condition.health,141);
    equal(conditionHour({ ...full, vigor:159, health:129 }).condition.health,129);
    equal(conditionHour({ vigor:128,rest:90,health:120,nourishment:100 }).condition,{vigor:126,rest:88,health:120,nourishment:99});
    equal(conditionHour({ vigor:192,rest:64,health:129,nourishment:192 }).condition,{vigor:191,rest:62,health:137,nourishment:189});
    equal(conditionHour({ vigor:10,rest:1,health:1,nourishment:1 }).condition,{vigor:0,rest:0,health:0,nourishment:0});
  });
  await test('Sleep restores every two iterations while its ship clock advances every four', () => {
    let state = startSleep(createSurvival({ ...full,rest:90 }));
    state = advanceSurvival(state,50);equal(state.minutes,1);equal(state.condition.rest,90);
    state = advanceSurvival(state,50);equal(state.minutes,1);equal(state.condition.rest,91);
    state = run(state,11900);equal(state.minutes,60);equal(state.condition.rest,210);equal(state.condition.nourishment,252);
    equal(wakeUp(state).sleeping,false);
    equal(conditionHour({ ...full,rest:90 },true).condition.rest,90);
    equal(conditionHour({ vigor:128,rest:90,health:120,nourishment:100 },true).condition,{vigor:126,rest:90,health:120,nourishment:99});
  });
  await test('Exhaustion forces sleep until rest exceeds 128; zero vigor ends simulation', () => {
    let state = run(createSurvival({ ...full,rest:1 }),60000);
    equal(state.forced,true);equal(state.sleeping,true);equal(wakeUp(state).sleeping,true);
    state = run(state,12800);equal(state.condition.rest,128);equal(state.forced,true);
    state = run(state,100);equal(state.condition.rest,129);equal(state.forced,false);equal(wakeUp(state).sleeping,false);
    const dead = run(createSurvival({ vigor:1,rest:1,health:1,nourishment:1 }),60000);
    equal(dead.dead,true);equal(dead.condition.vigor,0);equal(run(dead,5000),dead);equal(startSleep(dead),dead);
  });
  await test('Clock is frame-rate independent, pauses without catch-up and crosses midnight', () => {
    equal(run(createSurvival(full),60000,20),run(createSurvival(full),60000,100));
    const state = { ...createSurvival(full),minutes:1439,elapsed:900 };
    equal(run(state,5000,100,true).minutes,1439);
    equal(advanceSurvival(state,100).minutes,1440);
    equal(advanceSurvival(createSurvival(full),60000).minutes,0);
    equal(advanceSurvival(createSurvival(full),60000).elapsed,250);
  });
}
