import { currentShipLocation } from './regional-world.js';
import { validateCargoLot } from './cargo.js';
import { fitsComponent,recalculateEquipment } from './equipment.js';
import { produceShipEncounter,stepShipCombat,fireShipGun,jettisonShipCargo,
  prepareShipCommunication,resumeShipCommunication,stepShipCommunication } from './ship-combat.js';
import { startEncounterDialogue,restoreEncounterDialogue,advanceEncounterDialogue,validateEncounterDialogueRecord } from './encounter-dialogue.js';
import { validateCampaignDialogue } from './campaign-dialogue.js';
import { validateShipTactical,selectShipTacticalMenu,confirmShipJettison,setShipTacticalGun,
  initialShipTrigger,validateShipTrigger,startShipTacticalTractor } from './ship-tactical.js';
import { shipBounty,isShipSalvage } from './ship-salvage.js';
import { MAX_CREDITS } from './banking.js';
import { enterCampaignShipTactical,advanceCampaignShipDispatch } from './campaign-machinery.js';

const LEGACY_CONTACT_FLAGS=Object.freeze([29,36,40,41,42,43,44,45,46,47]);
const CONTACT_FLAGS=Object.freeze([29,35,36,40,41,42,43,44,45,46,47]);
const RETURN_FLAGS=Object.freeze([48,49,50,51]);
const CONTACT_WORDS=Object.freeze([205,206,207,208,209,214,215,216,217,347,354]);
const integer=(n,lo,hi)=>Number.isInteger(n)&&n>=lo&&n<=hi;
const keys=(v,n)=>v&&typeof v==='object'&&!Array.isArray(v)&&Object.keys(v).length===n.length&&n.every(k=>Object.hasOwn(v,k));
const dense=(v,n)=>Array.isArray(v)&&v.length===n&&Object.keys(v).length===n&&
  Array.from({length:n},(_,i)=>Object.hasOwn(v,i)).every(Boolean);
const fail=()=>{throw Error('invalidCampaignSpace')};
const signature=lot=>JSON.stringify([lot.commodityId,lot.quality,lot.originCity??null,lot.originWorld??null,lot.pricePaid]);
const sameTree=(value,expected)=>{
  if(expected===null||typeof expected!=='object')return value===expected;
  if(Array.isArray(expected))return dense(value,expected.length)&&expected.every((v,i)=>sameTree(value[i],v));
  return keys(value,Object.keys(expected))&&Object.keys(expected).every(k=>sameTree(value[k],expected[k]));
};
export const initialShipCommunication=()=>({conversation:null,pending:false,ticks:0});
export const initialShipActivity=()=>({sleeping:false,forced:false,sleepPhase:0});

// Utility12 $0289–$0291 clears system word8/nibble7 for all12 systems.
// Resource, equipment, cargo and RNG fields have existing campaign owners.
export const initialCampaignSpace=({tactical=false}={})=>({flags:Array(128).fill(false),
  words:{205:512,206:512,207:0,208:0,209:0,214:0,215:0,216:0,217:127,347:0,354:0},
  rangeMemory:127,cooldowns:Array(12).fill(0),elapsed:0,view:'ship',
  combatFailures:Array(6).fill(false),losses:[],defeat:null,
  communication:initialShipCommunication(),activity:initialShipActivity(),...(tactical?{tactical:null,bounties:[],wrecks:[]}:{})});

export const neutralShipControl=()=>({x:0,y:0,fire:false});
export function validateShipControl(value) {
  if(!keys(value,['x','y','fire'])||![value.x,value.y].every(n=>integer(n,-8,8))||typeof value.fire!=='boolean')fail();
  return {...value};
}
// Migration does not re-enter Game12 or spend its startup RNG/time. Historical
// saves have no reticle; initialize that missing browser state explicitly.
export function migrateCampaignTactical(campaign,space) {
  const next=structuredClone(space);
  next.tactical=next.view==='tactical'&&!next.defeat&&!campaign.combat.defeat?{
    record:{reticle:{angle:currentShipLocation(campaign).orbit.angle,radius:128},contact:next.flags[40],
      visible:false,grace:0,focused:true,firing:false,sensors:campaign.equipment[3].performance,
      frameLimit:5,menu:0,jettisonChoices:null},control:neutralShipControl(),carry:next.elapsed}:null;
  if(next.tactical)next.elapsed=0;
  return next;
}
export function clearCampaignTactical(state) {
  if(Object.hasOwn(state.space,'tactical')) {
    if(state.space.tactical?.record.firing)state.resources.guns.powered=false;
    if(state.space.tactical)state.space.elapsed+=state.space.tactical.carry;
    state.space.tactical=null;
  }
  return state;
}

export function validateSpaceLosses(value,{salvage=false}={}) {
  if(!Array.isArray(value)||!dense(value,value.length)||value.length>512)fail();
  const seen=new Set();
  return value.map(entry=>{
    if(!keys(entry,['lot','count'])||!integer(entry.count,1,65535))fail();
    const lot=validateCargoLot(entry.lot,{auxiliaryFuel:true,salvage}),key=signature(lot);
    if(seen.has(key)||lot.commodityId==='cargo-31'&&entry.count>17)fail();
    seen.add(key);return {lot,count:entry.count};
  });
}

export function validateSpaceBounties(value,content) {
  if(!dense(value,value?.length)||value.length>48)fail();
  const seen=new Set();
  return value.map(entry=>{
    if(!keys(entry,['systemId','enemyType','count'])||!integer(entry.enemyType,0,3)||!integer(entry.count,1,65535))fail();
    const system=content?.dialogue?.systems?.systems.find(s=>s.id===entry.systemId),key=`${entry.systemId}/${entry.enemyType}`;
    if(!system||seen.has(key))fail();
    const amount=shipBounty(entry.enemyType,{piracy:system.local32,coefficient:system.local30});
    seen.add(key);return {...entry,amount:amount*entry.count};
  });
}
function validateSpaceWrecks(value) {
  if(!dense(value,value?.length)||value.length>120)fail();
  const seen=new Set();
  return value.map(entry=>{
    if(!keys(entry,['lot','count'])||!integer(entry.count,1,65535))fail();
    const lot=validateCargoLot(entry.lot,{salvage:true}),key=signature(lot);
    if(!isShipSalvage(lot)||seen.has(key))fail();seen.add(key);return {lot,count:entry.count};
  });
}
export function recordCampaignShipKill(state,aftermath,content) {
  const systemId=currentShipLocation(state).systemId,system=content.dialogue.systems.systems.find(s=>s.id===systemId);
  if(!system)fail();
  const enemyType=state.space.words[214],amount=shipBounty(enemyType,{piracy:system.local32,coefficient:system.local30});
  if(amount) {
    const bank=state.economy.accounts.find(a=>a.systemId===systemId);
    if(!bank||bank.balance+amount>MAX_CREDITS)throw Error('bankOverflow');
    bank.balance+=amount;
  }
  // Keep zero-bounty kills too: one killed contact can generate at most one
  // wreck, even in a system that grants no bank credit for that enemy type.
  const bounty=state.space.bounties.find(e=>e.systemId===systemId&&e.enemyType===enemyType);
  if(bounty)bounty.count++;else state.space.bounties.push({systemId,enemyType,count:1});
  validateSpaceBounties(state.space.bounties,content);
  if(aftermath.wreck) {
    const lot=aftermath.wreck.lot,entry=state.space.wrecks.find(e=>signature(e.lot)===signature(lot));
    if(entry)entry.count++;else state.space.wrecks.push({lot:structuredClone(lot),count:1});
    state.space.wrecks=validateSpaceWrecks(state.space.wrecks);
  }
}
function validateSalvageOwnership(campaign,space) {
  const owned=[...campaign.pod.cargo,...campaign.economy.exchange.warehouse.slots,
    ...campaign.regional.cities.flatMap(c=>c.warehouse.slots)].filter(isShipSalvage);
  if(space.tactical?.record.wreck)owned.push(space.tactical.record.wreck.lot);
  const counts=new Map();for(const lot of owned)counts.set(signature(lot),(counts.get(signature(lot))||0)+1);
  for(const entry of space.losses)if(isShipSalvage(entry.lot))counts.set(signature(entry.lot),(counts.get(signature(entry.lot))||0)+entry.count);
  for(const [key,count] of counts)if((space.wrecks.find(e=>signature(e.lot)===key)?.count||0)<count)fail();
}

// Combat recomputes from raw damaged bytes; installation computes with one
// marked byte masked. Keep those caches distinct, including multiple shunts.
export function canonicalCombatEngineeringGroup(group,initial,pending) {
  if(!dense(group?.units,4)||pending===31||!integer(pending,0,18)||pending%5===4)fail();
  const units=group.units.map(u=>{
    if(!dense(u?.components,4))fail();
    return {components:Array.from(u.components,(b,s)=>{
      if(!integer(b,0,255)||(b!==0&&b!==7&&!fitsComponent(initial,b>127?b&31:b,s)))fail();
      return b;
    })};
  });
  if(units[Math.floor(pending/5)].components[pending%5]<=127)fail();
  return recalculateEquipment({...initial,units});
}

export function validateCampaignSpace(campaign,value,{communication=true,tactical=false,input=false,salvage=false,content}={}) {
  if(!keys(value,['flags','words','rangeMemory','cooldowns','elapsed','view','combatFailures','losses','defeat',...(communication?['communication','activity']:[]),...(tactical?['tactical']:[]),...(salvage?['bounties','wrecks']:[])])||
    !dense(value.flags,128)||!value.flags.every((b,i)=>typeof b==='boolean'&&((communication?CONTACT_FLAGS:LEGACY_CONTACT_FLAGS).includes(i)||!b))||
    !keys(value.words,CONTACT_WORDS.map(String))||!dense(value.cooldowns,12)||!value.cooldowns.every(n=>integer(n,0,15))||
    !dense(value.combatFailures,6)||!value.combatFailures.every(b=>typeof b==='boolean')||
    !integer(value.rangeMemory,0,255)||!integer(value.elapsed,0,249)||!['ship','tactical'].includes(value.view))fail();
  const w=value.words;
  if(![205,206].every(n=>integer(w[n],0,1023))||![207,208,209].every(n=>integer(w[n],-4,4))||
    !integer(w[214],0,3)||!integer(w[215],-32768,32767)||!integer(w[216],0,255)||
    !integer(w[217],0,32767)||!integer(w[347],0,1)||!integer(w[354],-32768,32767))fail();
  if((value.flags[40]||value.view==='tactical'||value.defeat!==null)&&
    (campaign.travel.scene!=='ship'||campaign.pod.occupied||campaign.combat.ground!==null))fail();
  if(value.defeat===null?w[347]!==0||campaign.resources.hull===0:
    !keys(value.defeat,['reason','minutes'])||value.defeat.reason!=='shipDestroyed'||
    value.defeat.minutes!==campaign.ship.minutes||w[347]!==1||value.elapsed!==0)fail();
  const next={...structuredClone(value),losses:validateSpaceLosses(value.losses,{salvage}),
    ...(!communication?{communication:initialShipCommunication(),activity:initialShipActivity()}:{} )};
  if(communication) {
    const c=next.communication,a=next.activity;
    if(!keys(c,['conversation','pending','ticks'])||typeof c.pending!=='boolean'||!integer(c.ticks,0,6)||!c.pending&&c.ticks!==0||
      !keys(a,['sleeping','forced','sleepPhase'])||typeof a.sleeping!=='boolean'||typeof a.forced!=='boolean'||!integer(a.sleepPhase,0,1)||
      a.forced&&!a.sleeping||a.forced&&campaign.ship.condition.rest>128||a.sleeping&&next.elapsed>=50||
      (next.defeat||campaign.combat.defeat)&&(a.sleeping||c.conversation!==null||next.elapsed!==0)||
      a.sleeping&&(campaign.travel.scene!=='ship'||next.view==='tactical'||c.conversation!==null)||
      c.pending&&(next.view!=='tactical'||c.conversation!==null||!next.flags[47]||campaign.dialogue.flags[51]))fail();
    if((c.conversation!==null)!==next.flags[35])fail();
    if(c.conversation!==null) {
      if(!next.flags[40]||next.flags[47]||!next.flags[44]||next.view!=='tactical'||c.pending||next.words[354]!==0||campaign.dialogue.flags.slice(48,51).some(Boolean))fail();
      restoreCampaignShipCommunication({...campaign,space:next},content);
    }
  }
  if(tactical) {
    const controller=next.tactical,terminal=next.defeat||campaign.combat.defeat;
    if((controller!==null)!==(next.view==='tactical'&&!terminal))fail();
    if(controller!==null) {
      if(!keys(controller,['record','control','carry',...(input?['trigger']:[])])||next.activity.sleeping||next.elapsed>=50||
        !integer(controller.carry,0,249)||controller.carry>0&&next.elapsed!==0)fail();
      controller.record=validateShipTactical(controller.record,{salvage});controller.control=validateShipControl(controller.control);
      if(input)controller.trigger=validateShipTrigger(controller.trigger);
      if(controller.record.frameLimit!==5)fail();
      if(salvage&&controller.record.wreck) {
        const wreck=controller.record.wreck;
        if(wreck.present&&(!next.flags[36]||next.words[216]!==0||controller.record.contact||!integer(next.words[217],1,128))||
          wreck.tractorSlot!==null&&(campaign.pod.cargo[wreck.tractorSlot]!==null||next.communication.conversation!==null||
            !sameTree(controller.control,neutralShipControl())||!sameTree(controller.trigger,initialShipTrigger())))fail();
      }
      if(next.communication.conversation&&(controller.record.menu!==0||controller.record.firing||
        controller.record.reticle.angle<0||controller.record.reticle.angle>255||controller.record.reticle.radius<0||controller.record.reticle.radius>255||
        !sameTree(controller.control,neutralShipControl())||input&&!sameTree(controller.trigger,initialShipTrigger())))fail();
    }
  }
  if(salvage) {
    validateSpaceBounties(next.bounties,content);next.wrecks=validateSpaceWrecks(next.wrecks);
    if(next.wrecks.reduce((n,e)=>n+e.count,0)>next.bounties.reduce((n,e)=>n+e.count,0))fail();
    validateSalvageOwnership(campaign,next);
  }
  return next;
}

export function campaignShipSource(state) {
  const r=state.resources,flags=[...state.dialogue.flags];
  CONTACT_FLAGS.forEach(n=>flags[n]=state.space.flags[n]);
  flags[0]=r.warp.charging;flags[1]=r.enginesPowered;flags[2]=r.guns.powered;
  flags[4]=r.shields.targetCharge>0;flags[7]=state.pod.attached;flags[12]=state.machinery.cloaked;
  state.equipment.forEach((g,i)=>flags[16+i]=g.specialAvailable);
  return {flags,words:{...state.space.words,222:r.warp.targetCharge,223:r.warp.charge,
    224:r.shields.targetCharge,225:r.shields.charge,226:r.guns.charge,227:r.fuel,349:0,350:0},
    rangeMemory:state.space.rangeMemory,hull:r.hull,sceneHigh:state.space.defeat?12:state.space.view==='tactical'?1:2,
    shipWorld:currentShipLocation(state).worldId!==null,
    equipment:state.equipment.map((group,i)=>({group:structuredClone(group),pendingFailure:state.engineering.pendingFailures[i]})),
    cargo:structuredClone(state.pod.cargo),randomState:state.encounters.randomState};
}

// Internal commit into an already private campaign clone. Every source helper
// feeds this same owner; a power tick cannot discard combat-owned flags.
export function commitCampaignShipSource(state,source,{combatDamage=false}={}) {
  const r=state.resources,w=source.words,f=source.flags,s=state.space;
  r.hull=source.hull;r.fuel=w[227];r.guns={charge:w[226],powered:f[2]};
  r.shields={charge:w[225],targetCharge:w[224]};r.enginesPowered=f[1];
  r.warp={charge:w[223],targetCharge:w[222],targetSystemId:f[0]?r.warp.targetSystemId:null,charging:f[0]};
  state.machinery.cloaked=f[12];state.pod.cargo=structuredClone(source.cargo);state.encounters.randomState=source.randomState;
  CONTACT_FLAGS.forEach(n=>s.flags[n]=f[n]);CONTACT_WORDS.forEach(n=>s.words[n]=w[n]);s.rangeMemory=source.rangeMemory;
  // Game16's return bits are shared with ground encounters. Keep their one
  // campaign-global owner rather than shadowing an earlier ground return.
  RETURN_FLAGS.forEach(n=>state.dialogue.flags[n]=f[n]);
  source.equipment.forEach(({group,pendingFailure},i)=>{
    if(combatDamage&&JSON.stringify(group.units)!==JSON.stringify(state.equipment[i].units)&&pendingFailure!==31)s.combatFailures[i]=true;
    state.equipment[i]=structuredClone(group);state.engineering.pendingFailures[i]=pendingFailure;
  });
  if(w[347]===1&&!s.defeat){s.defeat={reason:'shipDestroyed',minutes:state.ship.minutes};s.elapsed=0}
  return state;
}

// Called after movement, before power. The native non-arrival jump also runs
// the producer; planetary browser overlays keep their declared separate ETA.
export function stepCampaignSpaceProducer(previous,content,{enabled,arrived,dispatch=false}) {
  if(!previous.space||!enabled||previous.space.defeat||previous.space.communication?.conversation&&!dispatch)return previous;
  const next=structuredClone(previous),source=campaignShipSource(next),ship=currentShipLocation(next);
  if(arrived&&source.flags[40])source.words[215]=0; // $049B–$04A6.
  const index=next.start.systems.findIndex(s=>s.id===ship.systemId),system=content.dialogue.systems.systems.find(s=>s.id===ship.systemId);
  if(index<0||!integer(system?.local32,0,15))fail();
  const produced=produceShipEncounter(source,{cityPresent:ship.cityId!==null,
    system:{piracy:system.local32,cooldown:next.space.cooldowns[index]}});
  commitCampaignShipSource(next,produced.state);next.space.cooldowns[index]=produced.system.cooldown;
  return next;
}

export function stepCampaignSpaceCombat(previous,{dispatch=false}={}) {
  if(!previous.space||!previous.space.flags[40]||previous.space.defeat||previous.space.communication?.conversation&&!dispatch)return previous;
  const next=structuredClone(previous),result=stepShipCombat(campaignShipSource(next));
  return commitCampaignShipSource(next,result.state,{combatDamage:true});
}

export function finishCampaignSpaceWarp(state,content) {
  if(state.space){leaveCampaignShipDeadline(state);state.space.flags[40]=state.space.flags[47]=false;state.space.view='tactical'}
  if(state.space&&Object.hasOwn(state.space,'tactical'))return enterCampaignShipTactical(clearCampaignTactical(state),content,{warp:true});
  return state;
}

// Game12 $14D4–$14E0: leaving a pending demand restores aggression. Dropping
// cargo does not clear local28 either; only the source deadline/exit owns it.
export function leaveCampaignShipDeadline(state) {
  const c=state.space.communication;
  if(c?.pending){state.space.flags[44]=true;c.pending=false;c.ticks=0}
}

export function stepCampaignShipCommunication(previous) {
  if(!previous.space?.communication?.pending||previous.space.view!=='tactical'||previous.space.defeat||previous.space.communication.conversation)return previous;
  const next=structuredClone(previous),c=next.space.communication;
  const result=stepShipCommunication(campaignShipSource(next),{pending:c.pending,ticks:c.ticks});
  commitCampaignShipSource(next,result.state);Object.assign(c,result.communication);
  return next;
}

function shipDialogueSetup(state,content,seed) {
  const ship=currentShipLocation(state),system=content.dialogue.systems.systems.find(s=>s.id===ship.systemId);
  const bank=state.economy.accounts.find(a=>a.systemId===ship.systemId);
  if(!system||!bank)fail();
  const source=campaignShipSource(state),workspace={...state.dialogue.workspace,item:0,mood:0,quantity:source.words[214]+1};
  return {context:{kind:19,system:structuredClone(system),attributes:[...state.dialogue.attributes],carried:[...state.ship.inventory.carried],
    flags:source.flags,workspace,city:ship.cityId?Number(ship.cityId.slice(-2)):0,hour:Math.floor(state.ship.minutes/60)%24,
    surface:{...ship.surfacePosition},cash:state.dialogue.cash,bankBalance:bank.balance,randomState:seed,sceneMiddle:1},
    places:{systems:content.navigation.systems.map(s=>s.name),worlds:content.navigation.worlds.map(w=>w.name),
      system:content.navigation.systems.findIndex(s=>s.id===ship.systemId)+1,world:content.navigation.worlds.findIndex(w=>w.id===ship.worldId)+1}};
}

// Freeze setup inputs, never interpreter frames/messages/outcomes. Imports
// must match the still-frozen canonical campaign owners and replay to its RNG.
export function restoreCampaignShipCommunication(state,content) {
  const frozen=state.space.communication.conversation;
  if(!keys(frozen,['context','record']))fail();
  const record=validateEncounterDialogueRecord(frozen.record),setup=shipDialogueSetup(state,content,record.seed);
  if(!sameTree(frozen.context,setup.context))fail();
  return restoreEncounterDialogue(content.dialogue,setup.context,record,{places:setup.places,randomState:state.encounters.randomState});
}

export function reduceCampaignShipCommunication(previous,content,action) {
  if(!previous.space?.communication||previous.travel.scene!=='ship'||previous.space.view!=='tactical'||previous.space.defeat||previous.combat.defeat||previous.space.activity.sleeping)throw Error('shipCommunicationUnavailable');
  if(previous.space.tactical?.record.wreck&&previous.space.tactical.record.wreck.tractorSlot!==null)throw Error('shipTractorActive');
  let next=structuredClone(previous),c=next.space.communication;
  if(action.type==='comm') {
    if(c.conversation)throw Error('shipCommunicationUnavailable');
    if(next.space.tactical) {
      const t=next.space.tactical;
      if(t.record.menu!==0||t.record.firing)throw Error('shipCommunicationUnavailable');
      // Game12 stores bytes16/17 before handing control to Game16.
      t.record.reticle={angle:t.record.reticle.angle&255,radius:t.record.reticle.radius&255};t.control=neutralShipControl();t.trigger=initialShipTrigger();
    }
    const prepared=prepareShipCommunication(campaignShipSource(next));
    commitCampaignShipSource(next,prepared.state);
    next.space.words[354]=0; // Game16 proc30 $0E4E–$0E62, scene-middle<3.
    const setup=shipDialogueSetup(next,content,next.encounters.randomState),opened=startEncounterDialogue(content.dialogue,setup.context,{places:setup.places});
    c.conversation={context:setup.context,record:opened.record};c.pending=false;c.ticks=0;next.encounters.randomState=opened.conversation.randomState;
  } else if(action.type==='dialogue'&&c.conversation) {
    restoreCampaignShipCommunication(next,content);
    const setup=shipDialogueSetup(next,content,c.conversation.record.seed),result=advanceEncounterDialogue(content.dialogue,setup.context,c.conversation.record,action.input,{places:setup.places,randomState:next.encounters.randomState});
    if(result.outcome) {
      const out=result.outcome;
      const bank=next.economy.accounts.find(a=>a.systemId===currentShipLocation(next).systemId);bank.balance=out.bankBalance;
      // Ship/resource slots remain owned by their adapters. Dialogue owns the
      // remaining globals and its full source-return workspace/personal fields.
      const flags=[...out.flags];CONTACT_FLAGS.forEach(n=>flags[n]=previous.dialogue.flags[n]);
      next.dialogue=validateCampaignDialogue({cash:out.cash,attributes:out.attributes,flags,workspace:out.workspace},
        {visitors:true,traderMatching:true,groundEncounters:true});
      next.ship.inventory.carried=[...out.carried];
      if(Object.hasOwn(next.space,'tactical')) {
        const returned=campaignShipSource(next);returned.flags=[...out.flags];returned.randomState=out.randomState;
        commitCampaignShipSource(next,returned);
        next=advanceCampaignShipDispatch(next,content);c=next.space.communication;
        if(next.space.defeat||next.combat.defeat||next.space.activity.sleeping) {
          c.conversation=null;c.pending=false;c.ticks=0;next.space.flags[35]=false;return next;
        }
      }
      const source=campaignShipSource(next),resumed=resumeShipCommunication(source,
        Object.hasOwn(next.space,'tactical')?source.flags:out.flags,
        Object.hasOwn(next.space,'tactical')?source.randomState:out.randomState);
      commitCampaignShipSource(next,resumed.state);
      c.conversation=null;Object.assign(c,resumed.communication);
      if(next.space.tactical) {
        const t=next.space.tactical;
        Object.assign(t.record,{contact:next.space.flags[40],visible:false,focused:true,firing:false,
          sensors:next.equipment[3].performance,menu:0,jettisonChoices:null});t.control=neutralShipControl();t.trigger=initialShipTrigger();
      }
    } else {c.conversation.record=result.record;next.encounters.randomState=result.conversation.randomState}
  } else throw Error('shipCommunicationUnavailable');
  return next;
}

// These reducers operate on the actual aboard state. UI sensor/reticle mapping
// and the source bolt-arming confirmation are separate controls, still pending.
export function reduceCampaignSpace(previous,action,content=null) {
  if(!previous.space||previous.travel.scene!=='ship'||previous.space.defeat||previous.combat.defeat)throw Error('spaceUnavailable');
  if(previous.space.communication?.conversation)throw Error('spaceUnavailable');
  if(previous.space.tactical?.record.wreck&&previous.space.tactical.record.wreck.tractorSlot!==null)throw Error('shipTractorActive');
  const next=structuredClone(previous);
  if(action.type==='sleep'&&next.space.activity) {
    if(next.space.activity.sleeping)throw Error('spaceUnavailable');
    leaveCampaignShipDeadline(next);clearCampaignTactical(next);next.space.view='ship';next.space.elapsed=0;next.space.activity={sleeping:true,forced:false,sleepPhase:0};return next;
  }
  if(action.type==='wake'&&next.space.activity?.sleeping) {
    if(next.space.activity.forced)throw Error('spaceWakeUnavailable');
    next.space.activity.sleeping=false;next.space.elapsed=0;return next;
  }
  if(next.space.activity?.sleeping)throw Error('spaceUnavailable');
  if(action.type==='view'&&['ship','tactical'].includes(action.view)) {
    if(action.view==='ship'){leaveCampaignShipDeadline(next);clearCampaignTactical(next)}
    else if(Object.hasOwn(next.space,'tactical'))return enterCampaignShipTactical(next,content);
    next.space.view=action.view;return next;
  }
  if(next.space.view!=='tactical')throw Error('spaceUnavailable');
  const index=next.start.systems.findIndex(s=>s.id===currentShipLocation(next).systemId);
  if(action.type==='tractor'&&next.space.tactical) {
    const t=next.space.tactical,result=startShipTacticalTractor(campaignShipSource(next),t.record);
    commitCampaignShipSource(next,result.state);t.record=result.tactical;t.control=neutralShipControl();t.trigger=initialShipTrigger();return next;
  }
  if(next.space.tactical&&['menu','gun','aim'].includes(action.type)) {
    const t=next.space.tactical;
    if(action.type==='aim') {
      t.control=validateShipControl(action.control);
      // Native dispatch-hook ORs presses into its buffer between polls.
      if(t.control.fire)t.trigger.latched=true;
      return next;
    }
    const result=action.type==='menu'?selectShipTacticalMenu(campaignShipSource(next),t.record,action.menu):
      setShipTacticalGun(campaignShipSource(next),t.record,{firing:action.firing,focused:action.focused});
    commitCampaignShipSource(next,result.state);t.record=result.tactical;t.control=neutralShipControl();t.trigger=initialShipTrigger();return next;
  }
  if(action.type==='fire') {
    if(Object.hasOwn(next.space,'tactical'))throw Error('spaceUnavailable');
    const result=fireShipGun(campaignShipSource(next),{focused:action.focused,dexterity:next.dialogue.attributes[2]});
    commitCampaignShipSource(next,result.state);next.space.cooldowns[index]=(next.space.cooldowns[index]+result.cooldownIncrement)&15;
  } else if(action.type==='jettison') {
    if(!next.pod.attached)throw Error('spaceCargoUnavailable');
    const result=next.space.tactical?confirmShipJettison(campaignShipSource(next),next.space.tactical.record,action.selection):jettisonShipCargo(campaignShipSource(next),action.selection);
    if(next.space.tactical)next.space.tactical.record=result.tactical;
    for(const {lot} of result.jettisoned) {
      const entry=next.space.losses.find(e=>signature(e.lot)===signature(lot));
      if(entry)entry.count++;else next.space.losses.push({lot:structuredClone(lot),count:1});
    }
    next.space.losses=validateSpaceLosses(next.space.losses,{salvage:Object.hasOwn(next.space,'wrecks')});
    commitCampaignShipSource(next,result.state);if(result.resetSystemCooldown)next.space.cooldowns[index]=0;
  } else throw Error('spaceUnavailable');
  return next;
}
