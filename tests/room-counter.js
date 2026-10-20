import { createRoomGeometries } from '../js/core/room-walk.js';
import { populateRoom } from '../js/core/room-actors.js';
import { initialRoomTraffic, validateRoomTraffic, tickRoomTraffic } from '../js/core/room-traffic.js';
import { createRoomCounter, requestRoomCounter, cancelRoomCounter, moveRoomCounter,
  tickRoomCounter, openRoomCounter, advanceRoomCounter } from '../js/core/room-counter.js';
import { sourceRandom } from '../js/core/random.js';

export async function roomCounterTests(test,equal) {
  const [layouts,scripts,text,items,systems]=await Promise.all(['room-walk','dialogue','dialogue-text','items','dialogue-systems']
    .map(name=>fetch(`../data/${name}.json`).then(r=>r.json())));
  const rooms=createRoomGeometries(layouts),content={scripts,text,items};
  const context={system:systems.systems[0],attributes:[30,40,50,30,81],carried:[12,141,139,140],
    flags:Array(128).fill(false),workspace:{lastCity:0,mood:0,quantity:9,gate:1},city:1,hour:4,
    surface:{x:10,y:6},cash:500};
  const fail=(fn,message)=>{let actual;try{fn()}catch(e){actual=e.message}equal(actual,message)};
  const start=(index=8,seed=12345)=>{
    const room=rooms[index],p=populateRoom(room,seed),traffic=initialRoomTraffic(p),b=room.population.bounds;
    for(let y=b.top;y<=b.bottom;y++)for(let x=b.left;x<=b.right;x++) {
      try{return createRoomCounter(room,traffic,p.randomState,{x,y})}catch{}
    }
    throw new Error('No unoccupied counter position');
  };
  const ready=(index=8,seed=12345)=>{
    const room=rooms[index];let frame=requestRoomCounter(room,start(index,seed)),ticks=0;
    while(frame.service!=='talking'&&ticks<500){frame=tickRoomCounter(room,frame);ticks++}
    equal(frame.service,'talking');return {frame,ticks};
  };
  const check=(room,frame)=>equal(validateRoomTraffic(room,frame.traffic,frame.position,{service:frame.service}).state,frame.traffic);

  await test('Counter requests use inclusive bounds, own state and do not double-count repeated input',()=>{
    const room=rooms[8],frame=start(),before=JSON.stringify(frame),requested=requestRoomCounter(room,frame);
    equal(requested.position,{x:97,y:16});equal(requested.service,'waiting');equal(requested.traffic.waiting,1);
    equal(requested.randomState,frame.randomState);equal(requestRoomCounter(room,requested),requested);
    equal(JSON.stringify(frame),before);check(room,requested);
    const outside=moveRoomCounter(room,frame,{x:40,y:50});
    fail(()=>requestRoomCounter(room,outside),'notAtRoomCounter');
    for(const index of [8,12]) {
      const room=rooms[index],frame=start(index),b=room.population.bounds;
      // Isolate the counter to test reachable boundary positions. Some source
      // rectangle edges are inside walls and must still fail collision checks.
      frame.traffic.actors=frame.traffic.actors.filter(a=>a.slot===0);
      const positions=index===8 ? [{x:b.left,y:b.top},{x:b.left,y:b.bottom}] : [{x:b.left,y:b.top}];
      for(const position of positions) {
        const moved=moveRoomCounter(room,frame,position);
        equal(requestRoomCounter(room,moved).service,'waiting');
      }
      fail(()=>moveRoomCounter(room,frame,{x:b.right,y:b.bottom}),'invalidCampaign');
    }
  });
  await test('Player slot1 takes priority over waiting visitors after the eager scheduling draw',()=>{
    const room=rooms[8],frame=start(),visitor=frame.traffic.actors[1].words;
    visitor[7]=8;visitor[9]=0;frame.traffic.waiting=1;frame.randomState=0;
    const requested=requestRoomCounter(room,frame),next=tickRoomCounter(room,requested),counter=next.traffic.actors.at(-1).words;
    equal(next.service,'waiting');equal(next.traffic.waiting,2);equal(counter[9],1);
    equal(counter.slice(0,4),[16,113,16,113]);
    equal(next.traffic.actors.find(a=>a.slot===3).words[9],0);check(room,next);
  });
  await test('Cancelling service stops staff following the player and removes only the player queue entry',()=>{
    const room=rooms[8],frame=start();frame.randomState=0;
    const following=tickRoomCounter(room,requestRoomCounter(room,frame)),before=JSON.stringify(following);
    const cancelled=cancelRoomCounter(room,following),counter=cancelled.traffic.actors.at(-1).words;
    equal([cancelled.service,cancelled.traffic.waiting,counter[9],counter[7]&32],['idle',0,0,0]);
    equal(cancelled.randomState,following.randomState);equal(cancelRoomCounter(room,cancelled),cancelled);
    equal(JSON.stringify(following),before);check(room,cancelled);
    equal(moveRoomCounter(room,following,{x:40,y:50}).position,{x:40,y:50});
    fail(()=>moveRoomCounter(room,following,{x:-1,y:-1}),'invalidCampaign');equal(JSON.stringify(following),before);
  });
  await test('Cancelling a player request preserves a counter already following a visitor',()=>{
    const room=rooms[8],frame=start(),target=frame.traffic.actors[1].words,counter=frame.traffic.actors.at(-1).words;
    target[7]=8;target[9]=0;frame.traffic.waiting=1;
    counter[7]=32;counter[9]=3;counter[0]=counter[2]=target[4];counter[1]=counter[3]=target[5]+16;
    const next=cancelRoomCounter(room,requestRoomCounter(room,frame));
    equal(next.traffic.waiting,1);equal(next.traffic.actors.at(-1).words,counter);check(room,next);
  });
  await test('Player arrival dispatches dialogue without a visitor service-value draw and then freezes traffic',()=>{
    const room=rooms[8],frame=start(),counter=frame.traffic.actors.at(-1).words;
    frame.traffic.actors=[frame.traffic.actors.at(-1)];frame.randomState=12345;
    counter[0]=counter[2]=counter[4]=frame.position.y;
    counter[1]=counter[3]=counter[5]=frame.position.x+16;counter[7]=32;counter[9]=1;
    frame.traffic.waiting=1;frame.service='waiting';
    const rng=sourceRandom(frame.randomState);equal(rng.next()%32!==0,true);
    const next=tickRoomCounter(room,frame);
    equal([next.service,next.traffic.waiting,next.traffic.actors[0].words[9]],['talking',0,0]);
    equal(next.randomState,rng.state); // Only procedure28's activity draw on this dispatch tick.
    equal(tickRoomCounter(room,next),next);check(room,next);
    fail(()=>cancelRoomCounter(room,next),'roomConversationActive');
    fail(()=>moveRoomCounter(room,next,{x:40,y:50}),'roomConversationActive');
  });
  await test('All nine live layouts reach counter dialogue with valid actor geometry and deterministic resume',()=>{
    const expectedTicks=[26,27,27,26,21,21,21,21];
    for(const room of Object.values(rooms).filter(r=>r.index===1||r.index>=8))for(const seed of [0,1,12345,0xffffffff]) {
      let frame=requestRoomCounter(room,start(room.index,seed)),ticks=0;
      while(frame.service!=='talking'&&ticks<500) {
        const before=JSON.stringify(frame),next=tickRoomCounter(room,frame);
        equal(tickRoomCounter(room,JSON.parse(before)),next);equal(JSON.stringify(frame),before);
        check(room,next);frame=next;ticks++;
      }
      equal(frame.service,'talking');if(seed===12345&&room.index>=8)equal(ticks,expectedTicks[room.index-8]);
      const opened=openRoomCounter(content,room,frame,context);
      equal(opened.conversation.state.kind,room.index===1 ? 23 : room.index<12 ? 13 : 14);
      equal(opened.conversation.view.state,room.index===1 ? 96 : room.index<12 ? 82 : 83);
      equal(opened.conversation.state.workspace,{lastCity:1,mood:3,quantity:1,gate:0,item:0,actor:0});
      equal(opened.randomState,opened.conversation.randomState);equal(tickRoomCounter(room,opened),opened);
    }
  });
  await test('Dialogue return remembers counter mood and greeting gate for the next request',()=>{
    const room=rooms[8],frame=openRoomCounter(content,room,ready().frame,context),before=JSON.stringify(frame);
    const waiting=advanceRoomCounter(content,room,frame,{type:'timeout'});
    equal(waiting.outcome,null);equal(waiting.frame.conversation.view.state,87);
    const returned=advanceRoomCounter(content,room,waiting.frame,{type:'reply',slot:2}),counter=returned.frame.traffic.actors.at(-1).words;
    equal([returned.frame.service,returned.frame.conversation,counter[8],counter[7]&2],['served',null,2,2]);
    equal(returned.outcome.flags.slice(48,52),[false,false,false,false]);
    equal(returned.outcome.locals[104],500);equal(returned.outcome.carried,context.carried);
    equal(JSON.stringify(frame),before);check(room,returned.frame);
    fail(()=>validateRoomTraffic(room,returned.frame.traffic,returned.frame.position),'invalidCampaign'); // Version7 remains strict.
    let again=requestRoomCounter(room,returned.frame),ticks=0;
    while(again.service!=='talking'&&ticks++<500)again=tickRoomCounter(room,again);
    const reopened=openRoomCounter(content,room,again,{...context,workspace:returned.outcome.workspace,flags:returned.outcome.flags});
    equal([reopened.conversation.state.workspace.mood,reopened.conversation.state.workspace.gate],[2,1]);
    equal(reopened.conversation.view.word===147,false); // Source selector21 now chooses its gated greeting.
    equal(cancelRoomCounter(room,returned.frame).traffic.actors.at(-1).words[8],2);
  });
  await test('Information, cancel and return complete a room-to-dialogue round trip without modifying the context',()=>{
    const room=rooms[12],before=JSON.stringify(context),readyFrame=ready(12).frame;
    const opened=openRoomCounter(content,room,readyFrame,context);
    const info=advanceRoomCounter(content,room,opened,{type:'reply',slot:2});
    equal(info.frame.conversation.view.state,160);
    const back=advanceRoomCounter(content,room,info.frame,{type:'cancel'});equal(back.frame.conversation.view.state,83);
    const closed=advanceRoomCounter(content,room,back.frame,{type:'cancel'});
    equal(closed.frame.service,'served');equal(closed.outcome.kind,14);equal(JSON.stringify(context),before);
    equal(closed.frame.traffic.actors.map(a=>a.words.slice(0,6)),readyFrame.traffic.actors.map(a=>a.words.slice(0,6)));
  });
  await test('Counter-state validation rejects queue, target, position and phase inconsistencies',()=>{
    const room=rooms[8],frame=start();frame.randomState=0;
    const following=tickRoomCounter(room,requestRoomCounter(room,frame));
    for(const mutate of [f=>f.traffic.waiting++,f=>f.service='idle',f=>f.service='talking',
      f=>f.traffic.actors.at(-1).words[1]++,f=>f.position={x:40,y:50},
      f=>f.traffic.actors.at(-1).words[7]|=4,f=>f.traffic.actors.at(-1).words[8]=5]) {
      const bad=structuredClone(following);mutate(bad);
      fail(()=>tickRoomCounter(room,bad),'invalidCampaign');
    }
    fail(()=>tickRoomCounter(room,{...frame,service:'unknown'}),'invalidRoomService');
    fail(()=>tickRoomCounter(rooms[9],frame),'invalidRoomService');
    fail(()=>createRoomCounter({...room,index:3},frame.traffic,12345,frame.position),'unsupportedRoomCounter');
  });
  await test('Failed dialogue setup and unsupported return effects preserve the whole room session',()=>{
    const room=rooms[8],frame=ready().frame,before=JSON.stringify(frame);
    fail(()=>openRoomCounter(content,room,frame,{...context,cash:-1}),'invalidDialogueSetup');
    equal(JSON.stringify(frame),before);
    fail(()=>openRoomCounter(content,room,start(),context),'roomCounterNotReady');
    const opened=openRoomCounter(content,room,frame,context);
    fail(()=>openRoomCounter(content,room,opened,context),'roomCounterNotReady');
    fail(()=>advanceRoomCounter(content,room,frame,{type:'cancel'}),'roomCounterNotReady');
    opened.conversation.state.flags[65]=true;const snapshot=JSON.stringify(opened);
    fail(()=>advanceRoomCounter(content,room,opened,{type:'cancel'}),'unsupportedRoomDialogueReturn');
    equal(JSON.stringify(opened),snapshot);
  });
  await test('Opt-in idle service keeps the existing visitor simulation and version7 validator behavior',()=>{
    const room=rooms[8],frame=moveRoomCounter(room,start(),{x:40,y:50});
    const old=tickRoomTraffic(room,frame.traffic,frame.randomState,frame.position),next=tickRoomCounter(room,frame);
    equal(next.traffic,old.state);equal(next.randomState,old.randomState);
    equal(validateRoomTraffic(room,next.traffic,next.position).state,next.traffic);
  });
}
