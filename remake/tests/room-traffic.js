import { createRoomGeometries } from '../js/core/room-walk.js';
import { populateRoom, roomActorGeometry } from '../js/core/room-actors.js';
import { initialRoomTraffic, tickRoomTraffic, validateRoomTraffic } from '../js/core/room-traffic.js';
import { canStand } from '../js/core/ship-walk.js';
import { sourceRandom } from '../js/core/random.js';

export async function roomTrafficTests(test,equal) {
  const rooms=createRoomGeometries(await fetch('../data/room-walk.json').then(r=>r.json()));
  const player={x:40,y:50},start=index=>{
    const p=populateRoom(rooms[index],12345);return {state:initialRoomTraffic(p),randomState:p.randomState};
  };
  const tick=(index,s,p=player)=>tickRoomTraffic(rooms[index],s.state,s.randomState,p);
  await test('Source idle scheduling uses eager draws and departure is a two-stage target transition',()=>{
    const p=populateRoom(rooms[8],1),s={state:initialRoomTraffic(p),randomState:0};
    const before=JSON.stringify(s),next=tick(8,s),w=next.state.actors[0].words;
    equal(next.state.active,2);equal(w.slice(0,6),[20,97,51,9,20,97]);equal(w[7],561);
    equal(JSON.stringify(s),before);equal(next.randomState,0);
    const route=tick(8,next);equal(route.state.actors[0].words.slice(0,6),[51,9,51,9,20,97]);
    const moved=tick(8,route);equal(moved.state.actors[0].words.slice(4,6),[22,95]);
  });
  await test('A moving visitor removes its own glyph for collision and arrival bookkeeping waits until the next tick',()=>{
    const s=start(8),w=s.state.actors[0].words;s.state.active=2;
    w[0]=w[2]=w[4]+1;w[1]=w[3]=w[5]-1;w[7]=3*256+32;
    const moved=tick(8,s);equal(moved.state.active,2);equal(moved.state.waiting,0);
    equal(moved.state.actors[0].words.slice(4,6),[55,96]);
    const arrived=tick(8,moved);equal(arrived.state.active,0);equal(arrived.state.waiting,1);
    equal(arrived.state.actors[0].words[7],8);equal(arrived.state.actors[0].words[9],0);
  });
  await test('Counter service selects the first waiting visitor, moves by its glyph3 mask and assigns a source value',()=>{
    const s=start(8),target=s.state.actors[1].words;target[7]=8;target[9]=0;s.state.waiting=1;s.randomState=0;
    const chosen=tick(8,s); // zero also schedules departure of slot2, not the waiting slot3.
    equal(chosen.state.actors.at(-1).words.slice(0,4),[22,113,22,113]);
    equal(chosen.state.actors.at(-1).words[9],3);
    let next=chosen;for(let i=0;i<17;i++)next=tick(8,next);
    equal(next.state.waiting,0);equal(next.state.actors.find(a=>a.slot===3).words[9],64);
    equal(next.state.actors.at(-1).words[9],0);
  });
  await test('Blocked counter-bound visitors settle without a detour draw and cannot mutate the input',()=>{
    const s=start(8),w=s.state.actors[0].words;s.state.active=2;w[1]=w[3]=120;w[0]=w[2]=w[4];w[7]=3*256+32;
    // Actor already stands in counter bounds. Native blocked action3 settles
    // there without a detour draw, then queues on the following tick.
    const before=JSON.stringify(s),next=tick(8,s),rng=sourceRandom(s.randomState);rng.next();
    equal(next.randomState,rng.state);equal(next.state.actors[0].words.slice(0,4),[54,97,54,97]);equal(JSON.stringify(s),before);
  });
  await test('Visitor removal compacts active slots while retaining the identity followed by counter staff',()=>{
    const s=start(8),leaving=s.state.actors[0].words,target=s.state.actors[1].words,counter=s.state.actors.at(-1).words;
    leaving.splice(0,6,51,9,51,9,51,9);leaving[7]=544;s.state.active=2;
    target[7]=8;target[9]=0;s.state.waiting=1;
    counter[7]=32;counter[9]=3;counter[0]=counter[2]=target[4];counter[1]=counter[3]=target[5]+16;
    const next=tick(8,s);
    equal(next.state.actors.map(a=>a.slot),[2,3,4,0]);equal(next.state.active,0);
    equal(next.state.actors.at(-1).words[9],2);equal(next.state.waiting,1);
    equal(validateRoomTraffic(rooms[8],next.state,player).state,next.state);
  });
  await test('Nine room traffic runs preserve valid save states through entry, departure, waiting and service',()=>{
    let sawArrival=false,sawRemoval=false,sawCounterMotion=false,sawServed=false;
    for(const room of Object.values(rooms).filter(r=>r.index===1||r.index>=8)) {
      let s=start(room.index);const original=JSON.stringify(room);let last=s.state.actors.length;
      for(let i=0;i<1200;i++) {
        const next=tick(room.index,s),count=next.state.actors.length;
        sawArrival ||= count>last;sawRemoval ||= count<last;
        sawCounterMotion ||= next.state.actors.at(-1).words[4]!==s.state.actors.at(-1).words[4]||next.state.actors.at(-1).words[5]!==s.state.actors.at(-1).words[5];
        sawServed ||= next.state.waiting<s.state.waiting&&next.state.actors.some(a=>a.slot>1&&a.words[9]>=64);
        if(i%25===0)equal(validateRoomTraffic(room,next.state,player).state,next.state);
        s=next;last=count;
      }
      equal(JSON.stringify(room),original);
      const resumed=structuredClone(s);delete resumed.geometry;
      equal(tick(room.index,resumed).state,tick(room.index,s).state);
      equal(tick(room.index,resumed).randomState,tick(room.index,s).randomState);
    }
    equal([sawArrival,sawRemoval,sawCounterMotion,sawServed],[true,true,true,true]);
  });
  await test('Live room validation rejects malformed actors, unsupported actions, queue drift and visible overlaps',()=>{
    const s=start(8),reject=mutate=>{
      const bad=structuredClone(s.state);mutate(bad);let error;
      try{validateRoomTraffic(rooms[8],bad,player)}catch(e){error=e.message}equal(error,'invalidCampaign');
    };
    for(const mutate of [s=>s.extra=1,s=>s.actors[0].extra=1,s=>s.actors[0].slot=7,s=>s.actors[0].words[6]=0,
      s=>s.actors[0].words[7]=0x100,s=>s.actors[0].words[7]=2**32,s=>s.actors[0].words[8]=5,s=>s.waiting=1,s=>s.active=2,
      s=>s.actors.at(-1).words[9]=9,s=>s.actors.at(-1).words[1]=50,s=>s.actors[0].words[4]=3,
      s=>s.actors.at(-1).words[0]=0,s=>s.actors[0].words.splice(4,2,50,116),
      s=>{s.actors[0].words[7]=8;s.actors[0].words[9]=123;s.waiting=1},
      s=>s.actors[0].words[1]=150,s=>s.actors[0].words.push(0),
      s=>s.actors[1].words.splice(4,2,...s.actors[0].words.slice(4,6))])reject(mutate);
  });
  await test('Moving actors may overlap empty movement-mask margins without overlapping visible player pixels',()=>{
    let s=start(8);for(let i=0;i<37;i++)s=tick(8,s);
    equal(canStand(roomActorGeometry(rooms[8],s.state.actors),player),false);
    equal(validateRoomTraffic(rooms[8],s.state,player).state,s.state);
    const occupied={x:s.state.actors[0].words[5],y:s.state.actors[0].words[4]};let error;
    try{validateRoomTraffic(rooms[8],s.state,occupied)}catch(e){error=e.message}equal(error,'invalidCampaign');
  });
}
