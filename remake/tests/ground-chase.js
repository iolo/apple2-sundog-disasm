import { groundThreatGate,createGroundChase,validateGroundChase,groundChaseGeometry,
  stepGroundChase,advanceGroundChase,campaignGroundThreatContext,produceCampaignGroundChase,
  initializeCaughtGroundCombat } from '../js/core/ground-chase.js';
import { createGroundWorld } from '../js/core/campaign-ground.js';
import { createCampaignStart } from '../js/core/campaign.js';
import { createCharacter } from '../js/core/character.js';

// Independent byte/carry oracle, not the production word/shift RNG.
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

export async function groundChaseTests(test,equal) {
  const names=['ground-chase','ground-combat','maps','initial-navigation','initial-economy','initial-location',
    'ship-inventory','city-walk','surface-walk','dialogue-systems'];
  const [content,combat,maps,navigation,economy,location,inventory,cityWalk,surfaceWalk,systems]=
    await Promise.all(names.map(n=>fetch(`../data/${n}.json`).then(r=>r.json())));
  const native=await fetch('fixtures/ground-native-init.json').then(r=>r.json());
  const context={scene:3,foot:true,special:false,randomState:10804};
  const initial=()=>createGroundChase({position:{x:140,y:96},tile:8,threshold:12,randomState:1382964},content).state;
  const caught=()=>advanceGroundChase(initial(),content,1800).state;
  const reject=(run,code='invalidGroundChase')=>{let error;try{run()}catch(e){error=e.message}equal(error,code)};
  const checkRng=(seed,result)=>equal(result.state.randomState,oracle(seed,result.draws).state);

  await test('Ground threat gate draws eagerly for city, surface, pod and special-city contexts',()=>{
    equal(groundThreatGate(context),{triggered:true,randomState:1382964,draws:1});
    equal(oracle(10804,1).rolls,[6677]);
    for(const input of [{...context,scene:4},{...context,foot:false},{...context,special:true}])
      equal(groundThreatGate(input),{triggered:false,randomState:1382964,draws:1});
    const r=groundThreatGate({...context,randomState:12345});
    equal(r.triggered,false);equal(r.randomState,oracle(12345,1).state);equal(r.draws,1);
    reject(()=>groundThreatGate({...context,scene:5}));
  });
  await test('Native Game21 gate, chase, catch and Game17 initialization form one matching RNG path',()=>{
    equal(oracle(10804,4),{rolls:[6677,6797,8077,15501],state:1183653752});
    const s=initial();
    equal([s.window,s.copyOrigin,s.player,s.enemy,s.fast,s.randomState],
      [{left:100,top:66,right:180,bottom:126},{x:10,y:48},{x:137,y:99},{x:137,y:76},false,1183652414]);
    let current=s,ticks=0,draws=0;
    while(current.status==='chasing'&&ticks<100) {
      const r=stepGroundChase(current,content);current=r.state;draws+=r.draws;ticks++;
    }
    equal([ticks,current.counter,current.player,current.enemy,current.direction,current.kind,current.mode,draws],
      [36,32731,{x:137,y:99},{x:137,y:93},3,16,9,1]);
    equal(current.randomState,native.input.randomState);
    const r=initializeCaughtGroundCombat(current,content,combat,{...native.input,cash:0,flags:Array(128).fill(false)});
    equal(['left','top','right','bottom'].map(k=>r.arena.bounds[k]),['left','top','right','bottom'].map(k=>native.arena.bounds[k]));equal(r.state.actors,native.actors);
    equal(r.state.carried,native.carriedAfter);equal(r.draws,native.draws);equal(r.state.randomState,native.randomState);
    equal(s.player,{x:137,y:99});equal(s.enemy,{x:137,y:76});
  });
  await test('Ground chase clamps copy/window corners and clears the source full-mask collision interior',()=>{
    for(const [position,window,copy] of [
      [{x:0,y:7},{left:10,top:10,right:90,bottom:70},{x:0,y:0}],
      [{x:273,y:191},{left:199,top:131,right:279,bottom:191},{x:20,y:96}]]) {
      const s=createGroundChase({position,tile:2,threshold:15,randomState:0},content).state;
      equal(s.window,window);equal(s.copyOrigin,copy);
      const g=groundChaseGeometry(s,content),pixel=(x,y)=>(g.backgrounds.ship[y][Math.floor(x/7)]>>(x%7))&1;
      equal(g.collisionRows,Array(8).fill(127));
      equal([pixel(window.left,window.top),pixel(window.right,window.bottom)], [1,1]);
      equal([pixel(window.left+2,window.top+1),pixel(window.right-2,window.bottom-1)], [0,0]);
    }
  });
  await test('All source entry sides and fast/slow branches preserve their two initialization draws',()=>{
    const covered=new Set();
    for(let n=1;n<=300&&covered.size<8;n++) {
      const seed=(n*0x9e3779b9)>>>0;
      const expected=oracle(seed,2),side=expected.rolls[0]%4,fast=expected.rolls[1]%3===0,key=`${side}/${fast}`;
      if(covered.has(key))continue;covered.add(key);
      const r=createGroundChase({position:{x:140,y:96},tile:8,threshold:12,randomState:seed},content);
      const enemy=[{x:103,y:99},{x:137,y:76},{x:170,y:99},{x:137,y:121}][side];
      equal(r.state.enemy,enemy);equal(r.state.fast,fast);equal(r.draws,2);checkRng(seed,r);
    }
    equal(covered.size,8);
  });
  await test('Chase movement uses raw pointer coordinates and decremented Boolean bit0 rather than truthiness',()=>{
    const s=initial(),r=stepGroundChase(s,content,{move:true,pointer:{...s.player}});
    equal(r.state.player,s.player);equal(r.state.enemy,s.enemy);equal(r.state.counter,32766);equal(r.draws,0);
    const moved=stepGroundChase(s,content,{move:true,pointer:{x:137,y:98}});
    equal(moved.state.player,{x:137,y:98});equal(moved.state.enemy,s.enemy);
    const next=stepGroundChase(r.state,content);
    equal(next.state.enemy,{x:137,y:77});equal(next.state.counter,32765);
    const fast={...s,fast:true};equal(stepGroundChase(fast,content).state.enemy,{x:137,y:77});
    const wrapped={...s,counter:-32768};const wrap=stepGroundChase(wrapped,content);
    equal(wrap.state.counter,32767);equal(wrap.state.enemy,{x:137,y:77});
  });
  await test('Catch uses blocked full-glyph movement and keeps equality/tile12 in the visitor branch',()=>{
    const before=advanceGroundChase(initial(),content,1750).state;
    equal([before.status,before.counter,before.enemy],['chasing',32732,{x:137,y:93}]);
    // Next y94 would overlap the visible player's first set row, though the
    // enemy's visible circle itself does not yet touch the player's circle.
    const r=stepGroundChase(before,content);equal(r.state.status,'caught');equal(r.state.kind,16);equal(r.draws,1);
    for(const change of [{threshold:13},{threshold:15},{tile:12},{tile:15}]) {
      const s={...before,...change},r=stepGroundChase(s,content);
      equal([r.state.kind,r.draws],[22,2]); // Independent fifth native roll8079 MOD3=0.
      checkRng(s.randomState,r);
    }
    const visitors=new Set();
    for(let seed=0;seed<100&&visitors.size<2;seed++) {
      const s={...before,threshold:15,randomState:seed},o=oracle(seed,2),r=stepGroundChase(s,content);
      equal(r.state.kind,o.rolls[1]%3===0?22:18);equal(r.draws,2);checkRng(seed,r);visitors.add(r.state.kind);
    }
    equal([...visitors].sort(),[18,22]);
  });
  await test('Four escape edges preserve strict thresholds and consume no catch/outcome RNG',()=>{
    const rows=[
      [{x:104,y:99},{x:0,y:99},{x:103,y:99}],
      [{x:171,y:99},{x:279,y:99},{x:172,y:99}],
      [{x:137,y:76},{x:137,y:0},{x:137,y:75}],
      [{x:137,y:123},{x:137,y:191},{x:137,y:124}]];
    for(const [player,pointer,expected] of rows) {
      const s={...initial(),player,enemy:{x:170,y:115}},before=JSON.stringify(s);
      const r=stepGroundChase(s,content,{move:true,pointer});
      equal(r.state.player,expected);equal([r.state.status,r.state.mode,r.state.kind,r.state.direction,r.draws],['escaped',9,null,null,0]);
      equal(r.events,['groundChaseEscaped']);equal(r.state.randomState,s.randomState);equal(JSON.stringify(s),before);
      reject(()=>initializeCaughtGroundCombat(r.state,content,combat,{}),'groundChaseNotCaught');
    }
  });
  await test('Ordinary held movement escapes the prepared native chase without moving its return pose',()=>{
    const s=initial();const r=advanceGroundChase(s,content,4000,{move:true,pointer:{x:0,y:191}});
    equal(r.state.status,'escaped');equal(r.events,['groundChaseEscaped']);equal(r.draws,0);
    equal(r.state.origin,{x:140,y:96});equal(r.state.randomState,s.randomState);
    equal(r.state.elapsed,0);equal(stepGroundChase(r.state,content).state,r.state);
  });
  await test('A simultaneous blocked catch and boundary escape takes the source caught branch',()=>{
    const s={...initial(),fast:true,player:{x:104,y:99},enemy:{x:103,y:93}};
    const r=stepGroundChase(s,content,{move:true,pointer:{x:0,y:99}});
    equal(r.state.player,{x:103,y:99});equal(r.state.status,'caught');equal(r.events,['groundCaught']);equal(r.state.direction,3);
  });
  await test('Ground chase is refresh independent, preserves JSON sub-tick resume and freezes pause',()=>{
    const simulate=hz=>{
      let s=initial(),previous=0,draws=0,events=[];
      for(let frame=1;frame<=hz*2;frame++) {
        const now=Math.floor(frame*1000/hz),r=advanceGroundChase(s,content,now-previous);previous=now;
        s=r.state;draws+=r.draws;events.push(...r.events);
      }
      return {state:s,draws,events};
    };
    equal(simulate(30),simulate(60));equal(simulate(60),simulate(144));
    const partial=advanceGroundChase(initial(),content,1373).state;
    equal(partial.elapsed,23);equal(partial.counter,32740);
    equal(advanceGroundChase(partial,content,60000,{}, {paused:true}),{state:partial,draws:0,events:[]});
    const resumed=advanceGroundChase(JSON.parse(JSON.stringify(partial)),content,427);
    equal(resumed.state,caught());equal(resumed.events,['groundCaught']);equal(resumed.draws,1);
    equal(advanceGroundChase(initial(),content,1800).state,advanceGroundChase(initial(),content,60000).state);
  });

  const campaignContent={navigation,economy,location,inventory,dialogue:{systems},ground:{maps,cityWalk,surfaceWalk}};
  const start=createCampaignStart({...createCharacter(),name:'Threat pilot'},campaignContent,12345);
  const world=createGroundWorld({maps,navigation,economy,cityWalk,surfaceWalk},start);
  const campaign=()=>({start,ground:{worldId:'world-01',cityId:'city-01',podCityId:'city-01',colonyPosition:null,camera:{x:9,y:6}},
    travel:{scene:'city',cityPosition:{x:392,y:288}},pod:{attached:true,occupied:false},encounters:{randomState:10804},
    ship:{minutes:75,inventory:structuredClone(start.inventory),condition:{...start.condition}},economy:{cash:1234}});
  await test('Campaign threat production uses actual camera/map/system threshold and leaves all return state unchanged',()=>{
    const s=campaign(),before=JSON.stringify(s),ctx=campaignGroundThreatContext(s,world,campaignContent);
    equal(ctx,{scene:3,foot:true,special:false,position:{x:140,y:96},tile:8,threshold:12,randomState:10804});
    const r=produceCampaignGroundChase(s,world,campaignContent,content);
    equal(r.draws,3);equal(r.session,initial());equal(r.campaign.encounters.randomState,1183652414);
    for(const field of ['travel','ground','pod','ship','economy','start'])equal(r.campaign[field],s[field]);
    equal(JSON.stringify(s),before);
    const foreign=structuredClone(s);foreign.ground.worldId='world-03';foreign.ground.cityId='city-09';
    const other=createGroundWorld({maps,navigation,economy,cityWalk,surfaceWalk},{...start,playerLocation:{...start.playerLocation,worldId:'world-03'}});
    equal(campaignGroundThreatContext(foreign,other,campaignContent).threshold,8);
    reject(()=>campaignGroundThreatContext(foreign,world,campaignContent));
    const bad=structuredClone(campaignContent);bad.dialogue.systems.systems=[];
    reject(()=>campaignGroundThreatContext(s,world,bad));
  });
  await test('Due campaign ticks retain eager RNG on surface/pod/Banville and mask actual city tile variants',()=>{
    const s=campaign();s.pod.occupied=true;
    const surface=campaign();surface.ground.cityId=null;surface.travel.scene='surface';surface.travel.cityPosition.y=240;
    const special=campaign();special.ground.cityId='city-60';
    for(const state of [s,surface,special]) {
      const r=produceCampaignGroundChase(state,world,campaignContent,content);
      equal(r.session,null);equal(r.draws,1);equal(r.campaign.encounters.randomState,1382964);
    }
    // Native map bytes include bank/variant bit4; the chase keeps only tile MOD16.
    equal(world.city('city-01',true).map.tiles[8][14],24);
    equal(campaignGroundThreatContext(campaign(),world,campaignContent).tile,8);
  });
  await test('Bad tile/context/control/session imports reject atomically before publishing any RNG mutation',()=>{
    const input={position:{x:140,y:96},tile:0,threshold:12,randomState:1382964},before=JSON.stringify(input);
    reject(()=>createGroundChase(input,content),'groundChaseInvalidTile');equal(JSON.stringify(input),before);
    for(const edit of [s=>s.extra=true,s=>s.window.left++,s=>s.copyOrigin.y++,s=>s.randomState=-1,
      s=>s.kind=16,s=>s.elapsed=50,s=>s.fast=1,s=>s.player.x=0,s=>s.origin.z=0]) {
      const s=initial();edit(s);reject(()=>validateGroundChase(s));
    }
    const s=initial(),original=JSON.stringify(s);
    for(const controls of [{move:true},{pointer:{x:280,y:99}},{move:1},{pointer:{x:140.5,y:96}}])
      reject(()=>stepGroundChase(s,content,controls));
    reject(()=>advanceGroundChase(s,content,60001));reject(()=>advanceGroundChase(s,content,0,{}, {paused:1}));
    equal(JSON.stringify(s),original);
    const invalidContent=structuredClone(content);delete invalidContent.glyphs[24][0];
    reject(()=>createGroundChase({...input,tile:8},invalidContent));
    const state=campaign();state.travel.cityPosition={x:252,y:192};state.ground.camera={x:4,y:3};
    const saved=JSON.stringify(state);
    reject(()=>produceCampaignGroundChase(state,world,campaignContent,content),'groundChaseInvalidTile');
    equal(JSON.stringify(state),saved);
  });
}
