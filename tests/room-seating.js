import { createRoomGeometries } from '../js/core/room-walk.js';
import { populateRoom } from '../js/core/room-actors.js';
import { initialRoomTraffic, tickRoomTraffic, validateRoomTraffic, sitRoomTraffic, standRoomTraffic, finishTavernContact } from '../js/core/room-traffic.js';
import { playerSeatAt, seatOccupants } from '../js/core/room-seating.js';

export async function roomSeatingTests(test,equal) {
  const rooms=createRoomGeometries(await fetch('../data/room-walk.json').then(r=>r.json()));
  const player={x:40,y:50},start=(index=4,seed=12345)=>{
    const p=populateRoom(rooms[index],seed);return {state:initialRoomTraffic(p,rooms[index]),randomState:p.randomState};
  };
  const tick=(s,p=player,index=4)=>tickRoomTraffic(rooms[index],s.state,s.randomState,p);
  const check=(s,p=player,index=4)=>equal(validateRoomTraffic(rooms[index],s.state,p).state,s.state);
  const seated=(seat=5)=>{
    const s=start(),target=rooms[4].fixtures.seats[seat-4],w=s.state.actors[0].words;
    s.state.actors=[s.state.actors[0],s.state.actors.at(-1)];
    w.splice(0,6,target.y,target.x,target.y,target.x,target.y,target.x);w[7]=4;w[9]=0;
    return s;
  };
  const fail=(fn,message='invalidCampaign')=>{let error;try{fn()}catch(e){error=e.message}equal(error,message)};
  await test('Tavern seating follows all six source targets and player release bands',()=>{
    const room=rooms[4];
    equal(room.fixtures.seats.map(s=>playerSeatAt(room,s)),[4,5,6,7,8,9]);
    equal(playerSeatAt(room,{x:16,y:83}),null);equal(playerSeatAt(room,{x:16,y:84}),4);
    equal(playerSeatAt(room,{x:126,y:86}),null);equal(playerSeatAt(rooms[8],{x:16,y:86}),null);
    const s=seated(),before=JSON.stringify(s),p={x:16,y:86};
    const sat=sitRoomTraffic(room,s.state,p);
    equal(sat.tavern,{playerSeat:4,secondary:0,contact:{actor:2,kind:21}});
    equal(seatOccupants(room,sat),[1,2,0,0,0,0]);equal(JSON.stringify(s),before);
    check({state:sat},p);
    fail(()=>standRoomTraffic(room,sat,p),'roomConversationActive');
    const frozen=tick({state:sat,randomState:12345},p);
    equal(frozen.state,sat);equal(frozen.randomState,12345);
    const returned=finishTavernContact(room,sat,12345,p);
    equal(returned.state.tavern.contact,null);equal(returned.randomState,12345);
    equal(standRoomTraffic(room,returned.state,p).tavern.playerSeat,null);
  });
  await test('Tavern arrival consumes eight source draws and commits a seat only after entry succeeds',()=>{
    const s=start();s.state.actors=[s.state.actors.at(-1)];s.randomState=1;
    // Library22's first eight results from seed1 are 16384,16384,16416,
    // 16416,18464,16416,18468,16416: activity, traits, preference, group/side.
    const arrived=tick(s);
    equal(arrived.randomState,304105601);
    equal(arrived.state.actors[0],{slot:2,words:[76,16,86,16,61,9,5912,1057,4,0]});check(arrived);
    const blocked=tick(s,{x:9,y:61});
    equal(blocked.randomState,304105601);equal(blocked.state,s.state);
    equal(seatOccupants(rooms[4],blocked.state),[0,0,0,0,0,0]);
    const flipped=tick(s,{x:16,y:86});
    equal(flipped.state.actors[0].words.slice(0,4),[76,43,86,43]);equal(flipped.randomState,304105601);check(flipped,{x:16,y:86});
    s.state.tavern.playerSeat=5;
    const opposite=tick(s,{x:43,y:86});
    equal(opposite.state.actors[0].words.slice(7,9),[1057,4]);check(opposite,{x:43,y:86});
  });
  await test('Bartender matching skips source seat draws, retains the full item byte and supports every opposite seat',()=>{
    for(const index of [4,5,6,7])for(const seat of [4,5,6,7,8,9]) {
      const room=rooms[index],s=start(index),p=room.fixtures.seats[seat-4];
      s.state.actors=[s.state.actors.at(-1)];s.state.tavern.playerSeat=seat;
      const moved=tickRoomTraffic(room,s.state,1,p,{service:'idle',solicitation:{item:235}}),w=moved.state.actors[0].words;
      equal(moved.randomState,270551169); // Six draws, versus eight without solicitation.
      equal(w[8],235*256+4);equal(w[7]&3,3);equal(w[7]>>>8,4+((seat-4)^1));
      equal(validateRoomTraffic(room,moved.state,p,{service:'idle'}).state,moved.state);
      fail(()=>validateRoomTraffic(room,moved.state,p,{service:'idle',traderMatching:false}));
    }
    const room=rooms[4],s=seated(),p={x:16,y:86},w=s.state.actors[0].words;
    w[7]|=3;w[8]=139*256+4;
    equal(sitRoomTraffic(room,s.state,p,{service:'idle',solicitation:{item:139}}).tavern.contact,{actor:2,kind:17});
    equal(sitRoomTraffic(room,s.state,p,{service:'idle'}).tavern.contact,{actor:2,kind:21});
  });
  await test('Counter-to-seat retarget cancels both the waiting count and the staff follow reference',()=>{
    const s=start(4,1),w=s.state.actors[0].words;w[7]=8;w[9]=0;s.state.waiting=1;s.randomState=0;
    check(s);
    const moved=tick(s);equal(moved.state.active,2);equal(moved.state.waiting,0);
    equal(moved.state.actors[0].words.slice(0,4),[76,16,86,16]);equal(moved.state.actors[0].words[7],1056);
    equal(moved.state.actors.at(-1).words[9],0);equal(moved.state.actors.at(-1).words[7],0);check(moved);
  });
  await test('Seat arrival yields kind22 and resumes the speaker through the secondary mover',()=>{
    const s=seated(),w=s.state.actors[0].words,p={x:16,y:86};
    s.state.tavern.playerSeat=4;w[7]=5*256+32+1;w[8]=4;s.state.active=2;
    check(s,p);
    const arrived=tick(s,p);equal(arrived.state.tavern.contact,{actor:2,kind:22});
    equal(arrived.state.active,0);equal(arrived.state.actors[0].words[7],5);check(arrived,p);
    const returned=finishTavernContact(rooms[4],arrived.state,0,p,{dismiss:true});
    equal(returned.state.tavern,{playerSeat:4,secondary:2,contact:null});
    equal(returned.state.actors[0].words[7],2*256+32+1);check(returned,p);
    let next=returned;
    for(let i=0;i<600&&next.state.tavern.secondary;i++){next=tick(next,p);check(next,p)}
    equal(next.state.tavern.secondary,0);equal(next.state.actors.length,1);
  });
  await test('Conversation return retargets a seated speaker toward the counter using the source waypoint',()=>{
    const s=seated(),p={x:16,y:86};s.state=sitRoomTraffic(rooms[4],s.state,p);
    const before=JSON.stringify(s),returned=finishTavernContact(rooms[4],s.state,512,p,{dismiss:true});
    // First result is1 (true); the two counter-coordinate draws follow.
    equal(returned.randomState,1073741824);equal(returned.state.actors[0].words.slice(0,6),[41,30,31,30,86,43]);
    equal(returned.state.actors[0].words[7],800);equal(returned.state.tavern.secondary,2);
    equal(JSON.stringify(s),before);check(returned,p);
  });
  await test('Removing the primary mover compacts and advances the secondary mover in the same tick',()=>{
    const s=seated(),w=s.state.actors[0].words;
    w.splice(0,6,51,9,51,9,51,9);w[7]=544;
    s.state.actors.splice(1,0,{slot:3,words:[49,78,51,9,50,80,5912,544,0,0]});
    s.state.active=2;s.state.tavern.secondary=3;check(s);
    const next=tick(s);equal(next.state.actors.map(a=>a.slot),[2,0]);
    equal(next.state.active,0);equal(next.state.tavern.secondary,2);
    equal(next.state.actors[0].words.slice(4,6),[49,78]);check(next);
  });
  await test('A new contact preserves an earlier returning visitor instead of overwriting its mover slot',()=>{
    const s=seated(),p={x:16,y:86};
    s.state.actors.splice(1,0,{slot:3,words:[49,78,51,9,50,80,5912,544,0,0]});
    s.state.tavern.secondary=3;s.state=sitRoomTraffic(rooms[4],s.state,p);
    const returned=finishTavernContact(rooms[4],s.state,0,p,{dismiss:true});
    equal([returned.state.active,returned.state.tavern.secondary],[3,2]);check(returned,p);
    const busy=seated();busy.state.actors.splice(1,0,
      {slot:3,words:[49,78,51,9,50,80,5912,544,0,0]},
      {slot:4,words:[48,100,51,9,50,100,5912,544,0,0]});
    busy.state.active=3;busy.state.tavern.secondary=4;check(busy,p);
    const before=JSON.stringify(busy);fail(()=>sitRoomTraffic(rooms[4],busy.state,p),'roomTrafficBusy');equal(JSON.stringify(busy),before);
  });
  await test('Tavern reservations reject duplicate owners, forged contacts and mismatched targets',()=>{
    const s=seated(),p={x:16,y:86};
    const sat=sitRoomTraffic(rooms[4],s.state,p);
    for(const mutate of [s=>s.tavern.extra=0,s=>s.tavern.playerSeat=5,s=>s.tavern.secondary=2,
      s=>s.tavern.contact.actor=3,s=>s.tavern.contact.kind=17,s=>s.tavern.contact.kind=22,
      s=>s.actors[0].words[7]|=8,s=>s.actors[0].words[5]++,s=>delete s.tavern]) {
      const bad=structuredClone(sat);mutate(bad);fail(()=>validateRoomTraffic(rooms[4],bad,p));
    }
    const reserved=seated(),w=reserved.state.actors[0].words;
    reserved.state.active=2;w.splice(0,6,76,16,86,16,70,16);w[7]=4*256+32;
    check(reserved,p);fail(()=>sitRoomTraffic(rooms[4],reserved.state,p),'tavernSeatReserved');
    reserved.state.tavern.playerSeat=4;fail(()=>validateRoomTraffic(rooms[4],reserved.state,p));
    const bad=start();bad.state.active=2;bad.state.actors[0].words[7]=4*256+32;
    fail(()=>validateRoomTraffic(rooms[4],bad.state,player));
    const ordinary=initialRoomTraffic(populateRoom(rooms[8],12345));ordinary.tavern={playerSeat:null,secondary:0,contact:null};
    fail(()=>validateRoomTraffic(rooms[8],ordinary,player));
  });
  await test('All four taverns preserve valid deterministic traffic through seats, counter service and departure',()=>{
    let arrivals=0,departures=0,seats=0,retargets=0;
    for(let index=4;index<=7;index++) {
      let s=start(index);const original=JSON.stringify(rooms[index]);
      for(let i=0;i<6000;i++) {
        const next=tick(s,player,index);
        arrivals+=Number(next.state.actors.length>s.state.actors.length);
        departures+=Number(next.state.actors.length<s.state.actors.length);
        seats+=Number(next.state.actors.some(a=>a.slot>1&&(a.words[7]&4)));
        retargets+=Number(next.state.actors.some(a=>a.slot>1&&(a.words[7]>>>8)>=4));
        if(i%10===0)check(next,player,index);
        s=next;
      }
      equal(JSON.stringify(rooms[index]),original);
      const resumed=JSON.parse(JSON.stringify({state:s.state,randomState:s.randomState}));
      equal(tick(resumed,player,index),tick(s,player,index));
    }
    equal([arrivals>0,departures>0,seats>0,retargets>0],[true,true,true,true]);
  });
  await test('Seated-player traffic yields repeatable contacts and resumes valid visits in all four taverns',()=>{
    let contacts=0,returnsToCounter=0,departures=0;
    const p={x:43,y:86};
    for(let index=4;index<=7;index++) {
      let s=start(index);s.state=sitRoomTraffic(rooms[index],s.state,p);
      for(let i=0;i<6000;i++) {
        s=tick(s,p,index);
        if(s.state.tavern.contact) {
          contacts++;check(s,p,index);
          const saved=JSON.parse(JSON.stringify({state:s.state,randomState:s.randomState}));
          const next=finishTavernContact(rooms[index],s.state,s.randomState,p,{dismiss:true});
          equal(next,finishTavernContact(rooms[index],saved.state,saved.randomState,p,{dismiss:true}));
          const w=next.state.actors.find(a=>a.slot===next.state.tavern.secondary).words;
          returnsToCounter+=Number((w[7]>>>8)===3);departures+=Number((w[7]>>>8)===2);s=next;
        }
        if(i%10===0)check(s,p,index);
      }
    }
    equal([contacts>0,returnsToCounter>0,departures>0],[true,true,true]);
  });
}
