import { checkpointCodec, openCheckpointStore } from '../js/core/checkpoints.js';
import { createInventory } from '../js/core/inventory.js';
import { createCondition } from '../js/core/condition.js';
import { createSurvival, advanceSurvival } from '../js/core/survival.js';

export async function checkpointTests(test, equal) {
  const [geometry, initial] = await Promise.all(['ship-walk','ship-inventory'].map(name => fetch(`../data/${name}.json`).then(r=>r.json())));
  const codec = checkpointCodec(geometry);
  const state = () => ({ position:{x:54,y:86}, inventory:createInventory(initial), condition:createCondition(initial.condition), minutes:59 });
  const rejects = fn => { let rejected=false;try{fn()}catch{rejected=true}equal(rejected,true) };
  await test('Ship checkpoint roundtrip copies all state and preserves encoded items', () => {
    const original = state();original.inventory.carried[0]=235;original.inventory.stores[10]=0;original.condition.nourishment=120;
    const value=codec.make(original,2),copy=codec.parse(JSON.stringify(value));
    equal(copy,value);equal(copy.state,original);
    copy.state.inventory.carried[0]=0;copy.state.position.x=10;copy.state.condition.health=1;
    equal(original.inventory.carried[0],235);equal(original.position.x,54);equal(original.condition.health,255);
    const resumed={...createSurvival(value.state.condition),minutes:value.state.minutes};
    let next=resumed;for(let i=0;i<4;i++)next=advanceSurvival(next,250);
    equal(next.minutes,60);equal(next.condition.nourishment,119);
  });
  await test('Ship checkpoint imports reject malformed, foreign and future envelopes', () => {
    const valid=codec.make(state(),0);
    for(const text of ['null','{','x'.repeat(16385),JSON.stringify({...valid,version:2}),JSON.stringify({...valid,content:'future'}),JSON.stringify({...valid,format:'sundog-character-draft'}),JSON.stringify({...valid,format:'sundog-remake'}),JSON.stringify({...valid,slot:4}),JSON.stringify({...valid,savedAt:'invalid'})])rejects(()=>codec.parse(text));
    equal(codec.validate({...valid,ignored:'<script>',state:{...valid.state,untrusted:'ignored'}}),valid);
  });
  await test('Unsafe positions, terminal conditions and invalid inventory never load', () => {
    for(const position of [{x:0,y:7},{x:54.5,y:86},{x:280,y:192},{x:NaN,y:86},{x:160,y:130}])rejects(()=>codec.snapshot({...state(),position}));
    for(const field of ['vigor','rest','health','nourishment'])for(const value of [-1,256,1.5,NaN])rejects(()=>codec.snapshot({...state(),condition:{...initial.condition,[field]:value}}));
    for(const field of ['vigor','rest'])rejects(()=>codec.snapshot({...state(),condition:{...initial.condition,[field]:0}}));
    for(const minutes of [-1,0.1,Infinity,Number.MAX_SAFE_INTEGER])rejects(()=>codec.snapshot({...state(),minutes}));
    for(const items of [[0,0,0],[0,0,0,0,0],[32,0,0,0],[256,0,0,0],[null,0,0,0],Array(4)])rejects(()=>codec.snapshot({...state(),inventory:{...createInventory(initial),carried:items}}));
  });
  await test('Four checkpoint slots survive reopening and failed writes preserve records', async () => {
    const name=`sundog-checkpoint-tests-${crypto.randomUUID()}`;
    let store=await openCheckpointStore(codec,name);
    try {
      for(let slot=0;slot<4;slot++)await store.save(codec.make({...state(),minutes:slot},slot));
      const before=await store.list();store.close();store=await openCheckpointStore(codec,name);equal(await store.list(),before);
      rejects(()=>store.save({...before[0],version:2},before[0]));equal(await store.list(),before);
      await store.save(codec.make({...state(),minutes:99},1),before[1]);
      const after=await store.list();equal(after[1].state.minutes,99);equal(after.filter(x=>x.slot!==1),before.filter(x=>x.slot!==1));
      await store.delete(1,after[1]);equal((await store.list()).map(x=>x.slot),[0,2,3]);
    } finally {store.close();await new Promise(resolve=>{const request=indexedDB.deleteDatabase(name);request.onsuccess=resolve})}
  });
  await test('Stale-tab saves and deletes abort atomically instead of overwriting newer slots', async () => {
    const name=`sundog-checkpoint-race-${crypto.randomUUID()}`,a=await openCheckpointStore(codec,name),b=await openCheckpointStore(codec,name);
    try {
      const first=codec.make(state(),0);await a.save(first);
      const latest=codec.make({...state(),minutes:120},0);await b.save(latest,first);
      for(const run of [()=>a.save(first,first),()=>a.delete(0,first),()=>a.save(first)]) {
        let message;try{await run()}catch(error){message=error.message}equal(message,'checkpointChanged');equal(await a.list(),[latest]);
      }
    } finally {a.close();b.close();await new Promise(resolve=>{const request=indexedDB.deleteDatabase(name);request.onsuccess=resolve})}
  });
}
