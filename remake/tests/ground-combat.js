import { createGroundCombat, validateGroundCombat, fireGroundShot, stepGroundCombat,
  checkpointGroundCombat, resumeGroundCombat, advanceGroundCombat } from '../js/core/ground-combat.js';

// Independent byte/carry implementation of Library22 proc3; literal damage
// and placement vectors below are calculated from these rolls and the source.
function oracle(seed,count) {
  const bytes=Array.from({length:4},(_,i)=>Math.floor(seed/256**i)%256),rolls=[];
  for(let n=0;n<count;n++) {
    for(let bit=0;bit<7;bit++) {
      let carry=(Math.floor(bytes[0]/64)%2+Math.floor(bytes[3]/64)%2)%2;
      for(let i=0;i<4;i++){const high=Math.floor(bytes[i]/128);bytes[i]=(2*bytes[i]+carry)%256;carry=high}
    }
    rolls.push(Math.floor(bytes[0]/2)*256+bytes[2]);
  }
  return {rolls,state:bytes.reduce((n,b,i)=>n+b*256**i,0)};
}

export async function groundCombatTests(test,equal) {
  const content=await fetch('../data/ground-combat.json').then(r=>r.json());
  const arena=()=>({width:140,height:96,bounds:{left:0,right:139,top:0,bottom:95},
    collisionRows:content.glyphs[24],glyphs:content.glyphs,
    backgrounds:{ship:Array.from({length:96},()=>Array(20).fill(0))}});
  const input=(seed=0,kind=16)=>({kind,direction:0,attributes:[90,80,50,50,40],condition:[255,100,200,0],
    carried:[12,75,0,0],cash:1234,flags:Array(128).fill(false),randomState:seed});
  const fresh=()=>createGroundCombat(input(),arena()).state;
  const checkRng=(seed,result)=>equal(result.state.randomState,oracle(seed,result.draws).state);
  const hp=(state,index,value)=>{state.actors[index][3]=value*256+(state.actors[index][3]&255)};
  const timer=(state,index,value)=>{state.actors[index][4]=(state.actors[index][4]&256)|value};
  const reject=(run,message)=>{let error;try{run()}catch(e){error=e.message}equal(error,message)};
  const pointer=a=>({x:a[1]+3,y:a[0]-3});

  await test('Ground initialization uses source actor count, packed records, placement and RNG order',()=>{
    const a=arena(),v=input(12345),before=JSON.stringify(v),r=createGroundCombat(v,a);
    equal(r.draws,11);checkRng(v.randomState,r);
    equal(r.state.actors,[[51,67,5656,51205,256],[43,60,5912,27137,268],[67,76,5912,56325,266]]);
    equal(r.state.history,Array.from({length:7},()=>({x:67,y:51,dx:0,dy:0})));
    equal(r.state.workspace,{8:0,9:4,10:2,11:2,12:0});equal(r.state.shieldCharges,2);
    equal(r.state.flags[50],false);equal(JSON.stringify(v),before);
    for(const kind of [18,22]) {
      const r=createGroundCombat(input(12345,kind),a);equal(r.draws,4);equal(r.state.actors.length,2);
      equal(r.state.flags[50],true);equal(r.state.actors[0][4],0);checkRng(12345,r);
    }
  });
  await test('Combat health preserves native byte packing before its minimum33 clamp',()=>{
    const v=input();v.attributes[0]=100;v.condition[2]=255;
    equal(createGroundCombat(v,arena()).state.actors[0][3]>>>8,33);
    v.attributes[0]=30;v.condition[2]=1;equal(createGroundCombat(v,arena()).state.actors[0][3]>>>8,33);
  });
  await test('Weapon preparation swaps the first carried weapon and keeps the shield slot identity',()=>{
    const v=input();v.carried=[43,0,12,13];const s=createGroundCombat(v,arena()).state;
    equal(s.carried,[12,0,43,13]);equal([s.shieldSlot,s.shieldCharges,s.scatter,s.actors[0][4]],[2,1,false,256]);
  });
  await test('Personal shield blocks damage without a damage draw and switches to the next shield on exhaustion',()=>{
    const s=fresh(),a=arena();s.randomState=12345;s.carried=[12,43,75,0];s.shieldCharges=1;
    const r=fireGroundShot(s,a,{shooter:2,aim:{x:67,y:51}});
    equal([r.draws,r.shots[0].shield,r.shots[0].damage],[1,true,0]);checkRng(12345,r);
    equal([r.state.shieldSlot,r.state.shieldCharges,r.state.carried[1],r.state.actors[0][3]],[2,2,7,51205]);
    equal(s.carried[1],43);
  });
  await test('Zero-charge shield retains the source negative-charge quirk and byte packing at suspension',()=>{
    const s=fresh();s.carried[1]=11;s.shieldCharges=0;s.randomState=12345;
    const r=fireGroundShot(s,arena(),{shooter:2,aim:{x:67,y:51}});
    equal([r.draws,r.state.shieldActive,r.state.shieldCharges],[1,true,-1]);
    equal(checkpointGroundCombat(r.state,arena()).carried[1],235);
    s.shieldCharges=-32768;equal(fireGroundShot(s,arena(),{shooter:2,aim:{x:67,y:51}}).state.shieldCharges,32767);
  });
  await test('Strict ground shot tolerance, intelligence-adjusted distance and damage use independent source vectors',()=>{
    const s=fresh();s.randomState=29;const aim={x:60,y:43};
    const r=fireGroundShot(s,arena(),{shooter:1,aim});
    equal([r.draws,r.shots[0].target,r.shots[0].damage,r.state.actors[1][3]>>>8],[2,2,28,42]);checkRng(29,r);
    const edge=fireGroundShot(s,arena(),{shooter:1,aim:{x:55,y:43}});
    equal([edge.draws,edge.shots[0].target],[1,null]); // abs(dx)==skill is outside.
    const far=fireGroundShot(s,arena(),{shooter:2,aim:{x:130,y:85}});
    equal([far.draws,far.shots[0].target],[1,null]);
    reject(()=>fireGroundShot(s,arena(),{shooter:1,aim:{x:67,y:51}}),'groundCombatSelfShot');
  });
  await test('Five-shot scatter volley expends one charge and equips the next carried weapon',()=>{
    const v=input();v.carried=[45,12,0,0];let s=createGroundCombat(v,arena()).state;
    s.randomState=29;hp(s,1,250);timer(s,1,100);
    const r=stepGroundCombat(s,arena(),{fire:true,pointer:{x:63,y:40}});
    equal(r.shots.map(r=>r.aim),[{x:60,y:43},{x:60,y:37},{x:60,y:46},{x:66,y:37},{x:57,y:37}]);
    equal(r.state.carried,[12,7,0,0]);equal(r.state.scatter,false);equal(!!(r.state.actors[0][4]&256),true);
    equal(r.draws,9);checkRng(29,r);
  });
  await test('Zero-charge scatter uses signed subtraction; misses still consume the complete volley',()=>{
    const v=input();v.carried=[13,0,0,0];const s=createGroundCombat(v,arena()).state;s.randomState=29;
    const r=stepGroundCombat(s,arena(),{fire:true,pointer:{x:120,y:20}});
    equal(r.shots.length,5);equal(r.state.scatterCharges,-1);equal(r.state.scatter,true);
    equal(checkpointGroundCombat(r.state,arena()).carried[0],237);checkRng(29,r);
  });
  await test('Knocked-out NPC recovers to33 after its existing cooldown and consumes one history draw',()=>{
    const s=fresh();hp(s,1,20);s.actors[1][2]=25*256+24;timer(s,1,1);s.randomState=29;
    const r=stepGroundCombat(s,arena());equal(r.draws,1);equal(r.state.actors[1],[43,60,5912,8448,256]);
    equal(r.events,['groundEnemyRecovered']);checkRng(29,r);
  });
  await test('NPC pursuit follows a randomly selected player history and observes glyph collision',()=>{
    const s=fresh(),a=arena();s.actors[1][1]=20;s.actors[1][0]=20;timer(s,1,100);s.randomState=29;
    const r=stepGroundCombat(s,a);equal(r.state.actors[1].slice(0,2),[21,21]);equal(r.draws,1);
    // Block diagonal and horizontal: Library22 falls through to vertical.
    a.backgrounds.ship[14][3]=64;
    const blocked=stepGroundCombat(s,a);equal(blocked.state.actors[1].slice(0,2),[21,20]);
    equal(s.actors[1].slice(0,2),[20,20]);
  });
  await test('Ground avoid outcome uses normal movement to the boundary; passive visitors depart without firing',()=>{
    let s=createGroundCombat(input(0,18),arena()).state;s.actors[1][1]=100;
    let ticks=0,shots=0;while(!s.done&&ticks++<100) {
      const r=stepGroundCombat(s,arena(),{move:true,pointer:{x:139,y:48}});s=r.state;shots+=r.shots.length;
    }
    equal(s.done,true);equal(shots,0);equal(s.cash,1234);equal(s.carried,[12,75,0,0]);
    equal(s.actors[0][3]>>>8,200);
  });
  await test('Fleeing NPC retains the native player-hidden collision retry',()=>{
    const s=fresh();s.mode=2;s.actors[1][0]=45;s.actors[1][1]=67;s.randomState=29;
    s.history=Array.from({length:7},()=>({x:67,y:20,dx:0,dy:0}));
    const r=stepGroundCombat(s,arena());equal(r.state.actors[1].slice(0,2),[46,67]);equal(r.draws,1);
    equal(r.shots,[]);checkRng(29,r);
  });
  await test('NPC friendly fire compacts records without resetting a shifted shooter through its stale slot pointer',()=>{
    const s=fresh();s.randomState=12345;s.actors[0][1]=100;s.actors[0][0]=80;
    hp(s,1,25);s.actors[1][2]=25*256+24;timer(s,1,100);
    s.actors.push([43,20,5912,250*256,257]);
    s.history=Array.from({length:7},()=>({x:60,y:43,dx:0,dy:0}));
    const r=stepGroundCombat(s,arena());equal(r.draws,4);checkRng(12345,r);
    equal(r.shots.map(s=>[s.shooter,s.target,s.damage]),[[3,2,25]]);
    equal(r.state.actors[1],[43,21,5912,64000,256]);
    equal([r.state.done,r.state.actors.length],[false,2]);
  });
  await test('Ground fight outcome removes the final enemy and sets source kind15 without regenerating actors',()=>{
    const s=fresh();hp(s,1,25);s.actors[1][2]=25*256+24;s.randomState=29;
    const r=stepGroundCombat(s,arena(),{fire:true,pointer:pointer(s.actors[1])});
    equal([r.state.done,r.state.lastEnemyKilled,r.state.kind,r.state.actors.length],[true,true,15,1]);
    equal(r.draws,2);equal(r.shots[0].damage,25);checkRng(29,r);
  });
  await test('Ground lose outcome removes cash and carried items after ten ticks, then lets enemies depart',()=>{
    let s=fresh();s.shieldActive=false;s.carried[1]=0;s.randomState=12345;hp(s,0,78);
    const hit=fireGroundShot(s,arena(),{shooter:2,aim:{x:67,y:51}});s=hit.state;
    equal([s.actors[0][3]>>>8,s.mode,s.actors[0][4]&255],[22,1,10]);
    for(let i=0;i<9;i++)s=stepGroundCombat(s,arena()).state;equal(s.cash,1234);
    s=stepGroundCombat(s,arena()).state;equal([s.mode,s.cash,s.carried],[2,0,[0,0,0,0]]);
    for(let i=0;i<200&&!s.done;i++)s=stepGroundCombat(s,arena()).state;
    equal(s.done,true);const result=checkpointGroundCombat(s,arena());
    equal([result.condition[2],result.condition[0]],[22,44]);
  });
  await test('Surrender preserves carried equipment but loses cash; cancellation resumes the same actors',()=>{
    const a=arena(),s=fresh(),personal={...checkpointGroundCombat(s,a),flags:[...s.flags]};personal.flags[48]=true;
    const r=resumeGroundCombat(s,a,personal);equal(r.draws,0);equal(r.state.mode,1);equal(r.state.actors[0][4]&255,2);
    const cancelled=stepGroundCombat(r.state,a,{cancelSurrender:true});equal(cancelled.state.flags[48],false);equal(cancelled.state.mode,0);
    let lost=stepGroundCombat(r.state,a).state;lost=stepGroundCombat(lost,a).state;
    equal([lost.cash,lost.carried,lost.shieldActive,lost.scatter],[0,[12,75,0,0],false,false]);
    equal(s.cash,1234);
  });
  await test('Fatal ground hit changes the return scene nibble12 and stops further browser combat ticks',()=>{
    const s=fresh();s.shieldActive=false;s.carried[1]=0;hp(s,0,20);s.randomState=12345;
    const r=fireGroundShot(s,arena(),{shooter:2,aim:{x:67,y:51}});equal(r.state.sceneMid,12);
    equal(checkpointGroundCombat(r.state,arena()).condition.slice(0,3),[0,100,0]);
    equal(advanceGroundCombat(r.state,arena(),1000).state,r.state);
  });
  await test('Dialogue suspension and JSON resume preserve actors, health, history and RNG; truce makes NPCs flee',()=>{
    const a=arena(),s=stepGroundCombat(fresh(),a,{move:true,pointer:{x:120,y:70}}).state;
    const saved=JSON.parse(JSON.stringify(checkpointGroundCombat(s,a))),personal={...saved,flags:[...saved.flags]};personal.flags[49]=true;
    const r=resumeGroundCombat(saved,a,personal);equal(r.draws,0);equal(r.state.mode,2);equal(r.state.flags[49],false);
    equal(r.state.actors,s.actors);equal(r.state.history,s.history);equal(r.state.randomState,s.randomState);
    equal(stepGroundCombat(saved,a),stepGroundCombat(JSON.parse(JSON.stringify(saved)),a));
  });
  await test('Ground simulation has identical time, RNG and results at30/60/144 display refresh and mid-tick reload',()=>{
    const a=arena(),v=input(12345,18),s=createGroundCombat(v,a).state;
    const run=rate=>{let state=structuredClone(s),last=0;for(let frame=1;frame<=rate;frame++) {
      const time=Math.floor(frame*1000/rate);state=advanceGroundCombat(state,a,time-last).state;last=time;
    }return state};
    equal(run(30),run(60));equal(run(60),run(144));equal(run(30),advanceGroundCombat(s,a,1000).state);
    const partial=advanceGroundCombat(s,a,27).state;equal(partial.elapsed,27);
    equal(advanceGroundCombat(JSON.parse(JSON.stringify(partial)),a,973).state,run(30));
    equal(advanceGroundCombat(partial,a,1000,{}, {paused:true}).state,partial);
  });
  await test('Malformed ground state and impossible placement reject without mutating the caller or geometry',()=>{
    const a=arena();
    for(const edit of [s=>s.attributes[0]=0,s=>delete s.actors[0][1],s=>s.actors[0][2]=22*256+23,
      s=>s.history.pop(),s=>s.elapsed=50,s=>s.shieldSlot=4,s=>s.randomState=-1,s=>delete s.flags[0]]) {
      const s=fresh();edit(s);const before=JSON.stringify(s);reject(()=>validateGroundCombat(s,a),'invalidGroundCombat');equal(JSON.stringify(s),before);
    }
    const v=input();v.direction=4;const before=JSON.stringify(v);reject(()=>createGroundCombat(v,a),'groundCombatPlacementUnavailable');equal(JSON.stringify(v),before);
    const blocked=arena();blocked.backgrounds.ship.forEach(row=>row.fill(127));const rows=JSON.stringify(blocked);
    reject(()=>createGroundCombat(input(),blocked),'groundCombatPlacementUnavailable');equal(JSON.stringify(blocked),rows);
    reject(()=>stepGroundCombat(fresh(),a,{fire:true}),'invalidGroundCombat');
  });
}
