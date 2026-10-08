import { campaignSaveCodec } from '../js/core/campaign-saves.js';
import { createCharacter } from '../js/core/character.js';
import { createGroundWorld } from '../js/core/campaign-ground.js';
import { SHIP_REENTRY } from '../js/core/city-walk.js';
import { transferItem } from '../js/core/inventory.js';
import { sourceRandom } from '../js/core/random.js';
import { conditionHour } from '../js/core/survival.js';
import { initialGroundClock,validateGroundClock,stepGroundClock,groundClockRate,
  createGroundHost,advanceGroundHost,restoreCampaignGroundHost } from '../js/core/ground-host.js';
import { produceGroundEncounter,advanceGroundEncounter,restoreGroundEncounter,
  validateGroundEncounterRecord,idleGroundControl } from '../js/core/ground-encounter.js';
import { snapshotCampaignGroundHost,finishCampaignGroundEncounter,validateGroundRewards } from '../js/core/campaign-combat.js';

export async function groundHostTests(test,equal) {
  const names=['initial-navigation','initial-economy','initial-location','ship-inventory','ship-walk','maps',
    'city-walk','surface-walk','dialogue','dialogue-text','items','dialogue-systems','ground-chase','ground-combat','exchange-defaults','flight-defaults'];
  const [navigation,economy,location,inventory,walk,maps,cityWalk,surfaceWalk,scripts,text,items,systems,chase,ground,exchange,flight]=
    await Promise.all(names.map(name=>fetch(`../data/${name}.json`).then(r=>r.json())));
  const legacyContent={navigation,economy,location,inventory,ground:{maps,cityWalk,surfaceWalk},
    dialogue:{scripts,text,items,systems},exchange,flight,regional:true};
  const content={...legacyContent,combat:{chase,ground}},old=campaignSaveCodec(legacyContent,walk),codec=campaignSaveCodec(content,walk);
  const fresh=()=>codec.create({...createCharacter(),name:'Ground host'},12345);
  const world=createGroundWorld({...content,...content.ground},fresh().start);
  const campaign=()=>{
    const state=fresh();state.ship.position={...SHIP_REENTRY};
    state.travel={scene:'city',cityPosition:{x:392,y:288}};state.ground.camera={x:9,y:6};state.encounters.randomState=10804;
    return state;
  };
  const idle=idleGroundControl();
  const fail=(run,message)=>{let actual;try{run()}catch(e){actual=e.message}equal(actual,message)};
  const clockTick=(clock,changes={})=>stepGroundClock(clock,{scene:'city',foot:true,moving:false,minutes:0,
    condition:{vigor:200,rest:200,health:200,nourishment:200},...changes});
  const start=()=>advanceGroundHost(createGroundHost(campaign()),world,content,750);
  const talking=()=>advanceGroundHost(start(),world,content,1800);
  const dialogue=(frame,input)=>{
    const next=structuredClone(frame);next.encounter=advanceGroundEncounter(next.encounter,content,{type:'dialogue',input});
    next.campaign=next.encounter.campaign;return next;
  };
  const reload=frame=>restoreCampaignGroundHost(codec.parse(JSON.stringify(codec.make(snapshotCampaignGroundHost(frame,world,content),0))).state,world,content);
  const prepared=state=>{
    const frame=createGroundHost(state);frame.clock={...initialGroundClock(),scene:'city'};
    frame.encounter=produceGroundEncounter(state,world,content);frame.campaign=frame.encounter.campaign;
    return advanceGroundHost(frame,world,content,6000);
  };

  await test('Ground source clocks use idle15/1, city10/10-or1 and surface2/120-or20',()=>{
    for(const scene of ['city','surface'])for(const foot of [false,true])for(const moving of [false,true]) {
      const rate=groundClockRate(scene,foot,moving),expected=!moving?[15,1]:scene==='city'?[10,foot?10:1]:[2,foot?120:20];
      equal([rate.limit,rate.minutes],expected);
      let clock=initialGroundClock(),result;
      for(let tick=1;tick<=expected[0];tick++) {
        result=clockTick(clock,{scene,foot,moving});clock=result.clock;
        equal(result.due,tick===expected[0]);equal(result.minutes,tick===expected[0]?expected[1]:0);
      }
      equal(result.clock.iterations,0);
    }
  });
  await test('Movement edges preserve native iteration count and scene refresh resets rate without a new button edge',()=>{
    let clock={...initialGroundClock(),scene:'city',iterations:12};
    let r=clockTick(clock,{moving:true});equal([r.due,r.minutes,r.clock.iterations],[true,10,0]);
    clock=r.clock;r=clockTick(clock,{scene:'surface',moving:true});
    equal([r.clock.limit,r.clock.minutesPerTick,r.clock.moving,r.clock.iterations],[15,1,true,1]);
    r=clockTick(r.clock,{scene:'surface',moving:false});equal(r.clock.limit,15);
    r=clockTick(r.clock,{scene:'surface',moving:true});equal([r.due,r.minutes,r.clock.limit],[true,120,2]);
    fail(()=>validateGroundClock({...initialGroundClock(),limit:2}),'invalidGroundHost');
    fail(()=>clockTick(initialGroundClock(),{condition:{vigor:0}}),'invalidGroundHost');
  });
  await test('Two-hour surface increment runs one source hour-change condition update, including midnight',()=>{
    const condition={vigor:200,rest:200,health:200,nourishment:200};
    for(const minutes of [59,1380,1439]) {
      const first=clockTick(initialGroundClock(),{scene:'surface',moving:true,minutes,condition});
      const due=clockTick(first.clock,{scene:'surface',moving:true,minutes,condition});
      equal(due.minutes,minutes+120);equal(due.condition,conditionHour(condition).condition);
    }
    const clock={...initialGroundClock(),scene:'city',iterations:14};
    equal(clockTick(clock,{minutes:58,condition}).condition,condition);
  });
  await test('Host draws only on an actual due clock and preserves return pose during source chase production',()=>{
    const original=campaign(),before=JSON.stringify(original);
    const notDue=advanceGroundHost(createGroundHost(original),world,content,749);
    equal(notDue.campaign.encounters.randomState,10804);equal(notDue.campaign.ship.minutes,0);
    equal([notDue.clock.iterations,notDue.clock.elapsed],[14,49]);equal(notDue.encounter,null);
    const due=advanceGroundHost(notDue,world,content,1);
    equal(due.campaign.encounters.randomState,1183652414);equal(due.encounter.activation.phase,'chase');
    equal(due.encounter.activation.chase.origin,{x:140,y:96});equal(due.campaign.ship.minutes,1);
    for(const field of ['travel','ground','pod','dialogue','economy','start'])equal(due.campaign[field],original[field]);
    equal(due.campaign.ship.inventory,original.ship.inventory);equal(JSON.stringify(original),before);
  });
  await test('Held pointer already at its target advances source moving time without an invalid zero movement',()=>{
    const state=campaign();state.encounters.randomState=1;
    const control={...idle,move:true,pointer:{x:143,y:93}};
    const r=advanceGroundHost(createGroundHost(state),world,content,500,control);
    equal(r.campaign.travel.cityPosition,state.travel.cityPosition);equal(r.campaign.ship.minutes,10);
    equal(r.clock.limit,10);equal(r.clock.minutesPerTick,10);
    const rng=sourceRandom(1);rng.next();equal(r.campaign.encounters.randomState,rng.state);
  });
  await test('Source surface suppression still consumes its due RNG draw and uses the actual map',()=>{
    const state=campaign();state.travel={scene:'surface',cityPosition:{x:1,y:48}};
    state.ground.cityId=null;state.ground.colonyPosition={x:30,y:9};state.regional.colonyPosition={x:30,y:9};state.ground.camera={x:35,y:0};
    const r=advanceGroundHost(createGroundHost(state),world,content,750);
    equal(r.encounter,null);equal(r.campaign.encounters.randomState,1382964);equal(r.campaign.ship.minutes,1);
  });
  await test('Condition death changes source eligibility before the eager due gate and cannot spawn a chase',()=>{
    const state=campaign();state.ship.minutes=59;state.ship.condition={vigor:1,rest:1,health:1,nourishment:1};
    const r=advanceGroundHost(createGroundHost(state),world,content,750);
    equal(r.defeated,true);equal(r.encounter,null);equal(r.campaign.encounters.randomState,1382964);
    const saved=snapshotCampaignGroundHost(r,world,content);
    equal(saved.combat.defeat,{reason:'conditionDeath',minutes:60});equal(codec.snapshot(saved),saved);
    equal(advanceGroundHost(r,world,content,60000).campaign,r.campaign);
  });
  await test('Caught host opens mandatory Game16 before any active combat tick and keeps all six actors',()=>{
    const r=talking();equal(r.encounter.activation.phase,'dialogue');
    equal(r.encounter.activation.combat.actors.length,6);equal(r.encounter.activation.combat.workspace[11],5);
    equal(r.encounter.activation.conversation.state.kind,16);equal(r.encounter.activation.conversation.view.state,65);
    equal(r.campaign.ship.minutes,1);equal(r.campaign.travel.cityPosition,{x:392,y:288});
    const paused=advanceGroundHost(r,world,content,60000);equal(paused.campaign,r.campaign);equal(paused.encounter,r.encounter);
    fail(()=>advanceGroundEncounter(r.encounter,content,{type:'tick',control:idle,ticks:1}),'groundEncounterTickUnavailable');
  });
  await test('Declared rare-dialogue host replays its fault, freezes time and cannot publish a reward',()=>{
    const state=campaign();state.encounters.randomState=10916;
    // Explicit source condition fixture, not legitimate colony progression or
    // an importable fresh campaign. The top-level codec must still reject it.
    state.start.economy.colony.completedPhase=2;
    const r=prepared(state),a=r.encounter.activation;
    equal(a.phase,'dialogue');equal(a.combat.kind,18);equal(a.conversation.fault.runtimeError,6);
    equal(a.conversation.randomState,4196256831);equal(a.conversation.state.flags[125],true);
    equal(a.conversation.state.locals[104],153);equal(r.campaign.dialogue,state.dialogue);
    equal(r.campaign.ship,state.ship);equal(r.campaign.economy,state.economy);
    const saved=snapshotCampaignGroundHost(r,world,content);
    equal(Object.keys(saved.combat.ground),['seed','inputs']);equal(saved.combat.rewards,[]);equal(saved.combat.defeat,null);
    const loaded=restoreCampaignGroundHost(JSON.parse(JSON.stringify(saved)),world,content);
    equal(loaded.encounter.activation,a);equal(loaded.clock,r.clock);
    const frozen=advanceGroundHost(loaded,world,content,60000);
    equal(frozen.campaign,loaded.campaign);equal(frozen.encounter,loaded.encounter);equal(frozen.clock,loaded.clock);
    const before=JSON.stringify(loaded);
    fail(()=>dialogue(loaded,{type:'cancel'}),'dialogueSourceFault');
    fail(()=>finishCampaignGroundEncounter(saved,world,content),'groundEncounterReturnUnavailable');
    fail(()=>codec.snapshot(saved),'invalidCampaign');equal(JSON.stringify(loaded),before);
  });
  await test('Save24 validates historical23 first, adding only default combat fields and retaining old quote bounds',()=>{
    const legacy=old.make(old.create({...createCharacter(),name:'Legacy host'},12345),0),migrated=codec.validate(legacy);
    equal([migrated.version,migrated.scope],[24,'ground-encounters-1']);
    const without=structuredClone(migrated.state);delete without.combat;equal(without,legacy.state);
    const forged=structuredClone(legacy);forged.state.dialogue.workspace.quantity=5;fail(()=>codec.validate(forged),'invalidCampaign');
    forged.state.dialogue.workspace.quantity=1;forged.state.combat=migrated.state.combat;fail(()=>codec.validate(forged),'invalidCampaign');
    equal(codec.parse(JSON.stringify(codec.make(migrated.state,0))).state,migrated.state);
  });
  await test('Partial clock, chase, mandatory dialogue and combat saves reconstruct exact activations and continuations',()=>{
    const partial=advanceGroundHost(createGroundHost(campaign()),world,content,723);
    equal(advanceGroundHost(reload(partial),world,content,27).encounter.activation,start().encounter.activation);
    const chasing=advanceGroundHost(start(),world,content,1373),resumed=reload(chasing);
    equal(resumed.encounter.activation,chasing.encounter.activation);equal(resumed.clock,chasing.clock);
    equal(advanceGroundHost(resumed,world,content,427).encounter.activation,talking().encounter.activation);
    let r=dialogue(talking(),{type:'reply',slot:0});equal(reload(r).encounter.activation,r.encounter.activation);
    r=dialogue(r,{type:'cancel'});equal(r.encounter.activation.phase,'combat');
    const combat=advanceGroundHost(r,world,content,123),loaded=reload(combat);
    equal(loaded.encounter.activation,combat.encounter.activation);
    equal(advanceGroundHost(loaded,world,content,100).encounter.activation,advanceGroundHost(combat,world,content,100).encounter.activation);
  });
  await test('Surrender robbery returns cash loss once without discarding carried items or relocating the player',()=>{
    let r=dialogue(dialogue(talking(),{type:'reply',slot:0}),{type:'cancel'});
    r=advanceGroundHost(r,world,content,10000);
    equal(r.encounter.activation.phase,'returned');equal(r.encounter.activation.outcome.cash,0);
    const before=JSON.stringify(r.campaign),done=snapshotCampaignGroundHost(r,world,content);
    equal(done.dialogue.cash,0);equal(done.ship.inventory.carried,r.campaign.ship.inventory.carried);equal(done.combat.ground,null);
    equal(done.dialogue.workspace.lastCity,1);equal(done.dialogue.workspace.quantity,5);
    equal(done.travel,r.campaign.travel);equal(done.ground,r.campaign.ground);equal(codec.snapshot(done),done);
    fail(()=>finishCampaignGroundEncounter(done,world,content),'groundEncounterReturnUnavailable');equal(JSON.stringify(r.campaign),before);
  });
  await test('Chase escape commits no personal outcome and rejects a terminal record left in a save',()=>{
    const r=advanceGroundHost(start(),world,content,4000,{...idle,move:true,pointer:{x:0,y:191}});
    equal(r.encounter.activation.phase,'escaped');
    const done=snapshotCampaignGroundHost(r,world,content);equal(done.combat.ground,null);equal(done.dialogue,r.campaign.dialogue);
    const forged=structuredClone(done);forged.combat.ground=r.encounter.record;fail(()=>codec.snapshot(forged),'invalidCampaign');
    equal(codec.snapshot(done),done);
  });
  await test('Host logical ticks and sub-tick resumes are identical at30/60/144Hz and pause retains its remainder',()=>{
    const run=hz=>{
      let r=createGroundHost(campaign()),previous=0;
      for(let frame=1;frame<=hz*3;frame++) {const now=Math.floor(frame*1000/hz);r=advanceGroundHost(r,world,content,now-previous);previous=now}
      return snapshotCampaignGroundHost(r,world,content);
    };
    equal(run(30),run(60));equal(run(60),run(144));
    const partial=advanceGroundHost(start(),world,content,1373),paused=advanceGroundHost(partial,world,content,60000,idle,{paused:true});
    equal(paused.clock,partial.clock);equal(paused.encounter,partial.encounter);equal(paused.campaign,partial.campaign);
  });
  await test('Forged actors, RNG, seed, scene context, phase or extra record fields reject without mutating the campaign',()=>{
    const r=talking(),state=snapshotCampaignGroundHost(r,world,content),before=JSON.stringify(state);
    for(const mutate of [s=>s.combat.ground.activation=r.encounter.activation,s=>s.combat.ground.seed=1,
      s=>s.encounters.randomState++,s=>s.combat.clock.scene='surface',s=>s.combat.clock.iterations=1,
      s=>s.combat.ground.inputs[0].ticks++,s=>s.combat.ground.inputs[0].control.money=1,
      s=>s.combat.ground.inputs=[{type:'dialogue',input:{type:'cancel'}}],s=>s.combat.defeat={reason:'groundDeath',minutes:s.ship.minutes}]) {
      const bad=structuredClone(state);mutate(bad);fail(()=>codec.snapshot(bad),'invalidCampaign');
    }
    equal(JSON.stringify(state),before);
    fail(()=>validateGroundEncounterRecord({seed:1,inputs:Array(1025).fill({type:'tick',ticks:1,control:idle})}),'invalidGroundEncounter');
    fail(()=>advanceGroundHost(createGroundHost(campaign()),world,content,50,{...idle,fire:true,pointer:{x:100,y:100}}),'groundCombatUnavailable');
  });
  await test('Reward income receipts replay source quotes and cannot forge amounts, quantities or old-schema wealth',()=>{
    const receipt={kind:15,systemId:'system-01',quantity:1,seed:12345,amount:112};
    equal(validateGroundRewards([receipt],content),[receipt]);
    for(const changes of [{amount:113},{quantity:6},{systemId:'system-99'},{extra:true}])
      fail(()=>validateGroundRewards([{...receipt,...changes}],content),'invalidCampaignCombat');
    const state=campaign();state.combat.rewards=[receipt];state.dialogue.cash+=112;
    equal(codec.snapshot(state),state);
    const bad=structuredClone(state);bad.combat.rewards[0].amount++;fail(()=>codec.snapshot(bad),'invalidCampaign');
  });
  await test('Fighting with the owned starting laser resolves source shots, post-fight dialogue and one cash reward',()=>{
    const state=campaign();state.encounters.randomState=10753;
    state.ship.inventory=transferItem(state.ship.inventory,{container:'stores',index:11},{container:'carried',index:0},{x:54,y:83});
    equal(state.ship.inventory.carried[0],12);equal(state.ship.inventory.stores[11],0);
    let r=prepared(state);equal(r.encounter.activation.combat.kind,18);
    r=dialogue(r,{type:'reply',slot:2});r=dialogue(dialogue(r,{type:'cancel'}),{type:'cancel'});
    equal(r.encounter.activation.phase,'combat');
    for(let tick=0;tick<50&&r.encounter.activation.phase==='combat';tick++) {
      const enemy=r.encounter.activation.combat.actors[1];
      r=advanceGroundHost(r,world,content,50,{...idle,fire:true,pointer:{x:enemy[1]+3,y:enemy[0]-3}});
    }
    equal(r.encounter.activation.phase,'dialogue');equal(r.encounter.activation.combat.kind,15);
    equal(r.encounter.activation.receipts,[{kind:15,systemId:'system-01',quantity:1,seed:2221649509,amount:360}]);
    const loaded=reload(r);equal(loaded.encounter.activation,r.encounter.activation);
    const done=snapshotCampaignGroundHost(dialogue(loaded,{type:'cancel'}),world,content);
    equal(done.dialogue.cash,state.dialogue.cash+360);equal(done.combat.rewards.length,1);
    equal(done.ship.inventory.carried,[12,0,0,0]);equal(done.ship.inventory.stores[11],0);
    equal(codec.snapshot(done),done);fail(()=>finishCampaignGroundEncounter(done,world,content),'groundEncounterReturnUnavailable');
  });
  await test('Knock-out loses the owned weapon and medicine, and preserves damaged condition through reload',()=>{
    const state=campaign();
    state.ship.inventory=transferItem(state.ship.inventory,{container:'stores',index:0},{container:'carried',index:0},{x:54,y:83});
    state.ship.inventory=transferItem(state.ship.inventory,{container:'stores',index:11},{container:'carried',index:1},{x:54,y:83});
    let r=prepared(state);r=dialogue(dialogue(r,{type:'cancel'}),{type:'cancel'});
    r=advanceGroundHost(r,world,content,10000);equal(r.encounter.activation.phase,'returned');
    const done=snapshotCampaignGroundHost(r,world,content);
    equal(done.ship.inventory.carried,[0,0,0,0]);equal([done.ship.inventory.stores[0],done.ship.inventory.stores[11]],[0,0]);
    equal(done.dialogue.cash,0);equal(done.ship.condition.health<state.ship.condition.health,true);
    equal(codec.parse(JSON.stringify(codec.make(done,0))).state,done);
    equal(done.combat.defeat,null);equal(done.travel,state.travel);
  });
  await test('A later source encounter can kill the injured survivor; defeat saves retain losses and reject historical dead imports',()=>{
    let r=dialogue(dialogue(talking(),{type:'cancel'}),{type:'cancel'});
    r=advanceGroundHost(r,world,content,10000);
    const injured=snapshotCampaignGroundHost(r,world,content);equal(injured.ship.condition.health,51);
    // A declared second gate seed isolates fatal damage on the condition
    // actually produced by the first encounter; no health or actor is injected.
    injured.encounters.randomState=10753;r=prepared(injured);
    r=dialogue(r,{type:'reply',slot:2});r=dialogue(dialogue(r,{type:'cancel'}),{type:'cancel'});
    r=advanceGroundHost(r,world,content,10000);equal(r.encounter.activation.phase,'defeated');
    const done=snapshotCampaignGroundHost(r,world,content);
    equal([done.ship.condition.health,done.ship.condition.vigor],[0,0]);
    equal(done.combat.defeat,{reason:'groundDeath',minutes:done.ship.minutes});equal(done.dialogue.cash,0);
    equal(codec.parse(JSON.stringify(codec.make(done,0))).state,done);
    const forged=structuredClone(done);forged.combat.defeat=null;fail(()=>codec.snapshot(forged),'invalidCampaign');
    const historical=old.make(old.create({...createCharacter(),name:'Legacy dead'},12345),0);
    historical.state.ship.condition.vigor=0;fail(()=>codec.validate(historical),'invalidCampaign');
  });
  await test('Clock and input failures, overlong replay batches and mid-dialogue tick attempts are atomic',()=>{
    const original=start(),before=JSON.stringify(original);
    for(const control of [{...idle,pointer:{x:280,y:100}},{...idle,move:true},{...idle,fire:'yes'}])
      fail(()=>advanceGroundHost(original,world,content,50,control),'invalidGroundHost');
    fail(()=>advanceGroundHost(original,world,content,60001),'invalidGroundHost');
    equal(JSON.stringify(original),before);
    fail(()=>validateGroundEncounterRecord({seed:10804,inputs:Array(11).fill({type:'tick',ticks:1200,control:idle})}),'invalidGroundEncounter');
    fail(()=>advanceGroundEncounter(original.encounter,content,{type:'tick',control:idle,ticks:37}),'groundEncounterBoundary');
    equal(JSON.stringify(original),before);
  });
}
