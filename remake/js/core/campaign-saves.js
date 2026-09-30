import { createCampaignStart, CREATION_RECIPE } from './campaign.js';
import { checkpointCodec, openCheckpointStore } from './checkpoints.js';
import { fitsComponent, recalculateEquipment } from './equipment.js';
import { cityReachability, SHIP_REENTRY } from './city-walk.js';
import { atCityBank } from './city-doors.js';
import { roomAt } from './room-walk.js';
import { validateLodging, lodgingGeometry } from './room-lodging.js';
import { isTavern } from './room-seating.js';
import { populateRoom } from './room-actors.js';
import { initialRoomTraffic, validateRoomTraffic } from './room-traffic.js';
import { initialCampaignDialogue, validateCampaignDialogue, initialCounter, validateCounterRecord, restoreCampaignConversation } from './campaign-dialogue.js';

export const CAMPAIGN_FORMAT = 'sundog-campaign';
export const CAMPAIGN_LIMIT = 131072;
const VERSION = 10, SCOPE = 'landed-taverns-1';
const cityValidators=new WeakMap();
const fail = () => { throw new Error('invalidCampaign'); };
const keysMatch = (value, keys) => value && typeof value==='object' && !Array.isArray(value) &&
  Object.keys(value).length===keys.length && keys.every(key=>Object.hasOwn(value,key));

// Compare against the bounded generated tree; key order is irrelevant. Extra
// fields and unsupported progress fail instead of being silently discarded.
function sameTree(value, expected) {
  if (expected===null || typeof expected!=='object') return value===expected;
  if (Array.isArray(expected)) return Array.isArray(value) && value.length===expected.length &&
    Object.keys(value).length===expected.length && expected.every((item,i)=>sameTree(value[i],item));
  const keys=Object.keys(expected);
  return keysMatch(value,keys) && keys.every(key=>sameTree(value[key],expected[key]));
}

// `start` remains immutable; equipment is active, independently owned state.
// Machinery stays off; navigation, power, fuel and economy changes remain gated.
export function campaignSaveCodec(content, geometry, cityGeometry=null) {
  // Own the content used for replay validation; later caller edits cannot
  // retroactively change what this codec accepts.
  const baseline=structuredClone(content), walk=checkpointCodec(geometry);
  let populationCache=null;
  function snapshot(value, version = VERSION) {
    try {
      if (!keysMatch(value,version===1 ? ['start','ship'] : version===2 ? ['start','ship','equipment'] : version<6 ? ['start','ship','equipment','travel'] : version<8 ? ['start','ship','equipment','travel','encounters'] : ['start','ship','equipment','travel','encounters','dialogue']) || value.start?.creation?.recipe!==CREATION_RECIPE) fail();
      const start=createCampaignStart(value.start.character,baseline,value.start.creation.seed);
      if (!sameTree(value.start,start)) fail();
      const ship=walk.snapshot(value.ship);
      if (!sameTree(value.ship,ship)) fail();
      let equipment;
      if (version===1) equipment=start.equipment.map(recalculateEquipment);
      else {
        if (!Array.isArray(value.equipment) || value.equipment.length!==6 || Object.keys(value.equipment).length!==6) fail();
        equipment=value.equipment.map((group,i)=>{
          const initial=start.equipment[i];
          if (!Array.isArray(group?.units) || group.units.length!==4) fail();
          for (const unit of group.units) {
            if (!Array.isArray(unit?.components) || unit.components.length!==4 ||
                Array.from(unit.components).some((byte,socket)=>!Number.isInteger(byte) || (byte!==0 && byte!==7 && !fitsComponent(initial,byte,socket)))) fail();
          }
          const expected=recalculateEquipment({...initial,units:group.units});
          if (!sameTree(group,expected)) fail();
          return expected;
        });
      }
      let travel={scene:'ship',cityPosition:null};
      if(version>=3) {
        const inRoom=version>=5 && value.travel?.scene==='room';
        const lodgingRoom=inRoom&&version>=9&&roomAt(cityGeometry?.rooms,cityGeometry?.map,value.travel.cityPosition)?.index===1;
        if(!keysMatch(value.travel,inRoom ? ['scene','cityPosition','roomPosition',...(lodgingRoom ? ['lodging'] : [])] : ['scene','cityPosition']))fail();
        if(value.travel.scene==='city' || (version>=4 && value.travel.scene==='bank') || inRoom) {
          if(!cityGeometry||!keysMatch(value.travel.cityPosition,['x','y'])||!sameTree(ship.position,SHIP_REENTRY))fail();
          if(!cityValidators.has(cityGeometry))cityValidators.set(cityGeometry,cityReachability(cityGeometry));
          if(!cityValidators.get(cityGeometry)(value.travel.cityPosition))fail();
          if(value.travel.scene==='bank' && !atCityBank(cityGeometry.map,value.travel.cityPosition))fail();
          travel={scene:value.travel.scene,cityPosition:{...value.travel.cityPosition}};
          if(inRoom) {
            const room=roomAt(cityGeometry.rooms,cityGeometry.map,value.travel.cityPosition);
            if(!room || (version<9&&room.index===1) || (version<10&&isTavern(room)) || !keysMatch(value.travel.roomPosition,['x','y']))fail();
            const lodging=lodgingRoom ? validateLodging(value.travel.lodging) : undefined;
            const access=lodgingGeometry(room,lodging,{access:true});
            if(!cityValidators.has(access))cityValidators.set(access,cityReachability(access));
            if(!cityValidators.get(access)(value.travel.roomPosition))fail();
            travel.roomPosition={...value.travel.roomPosition};
            if(lodgingRoom)travel.lodging=lodging;
          }
        } else if(!sameTree(value.travel,travel))fail();
      }
      const dialogue=version>=8 ? validateCampaignDialogue(value.dialogue,{visitors:version>=10,...(version===8 ? {legacyCash:start.credits} : {})}) : initialCampaignDialogue(start);
      if(dialogue.cash>start.credits)fail(); // Live cash changes are lodging fees and bartender tips.
      let encounters={randomState:start.gameplayRandomState,roomSeed:null,roomState:null,counter:null};
      if(version>=6) {
        const validSeed=n=>Number.isInteger(n)&&n>=0&&n<=0xffffffff;
        if(!keysMatch(value.encounters,version===6 ? ['randomState','roomSeed'] : version===7 ? ['randomState','roomSeed','roomState'] : ['randomState','roomSeed','roomState','counter'])||!validSeed(value.encounters.randomState))fail();
        const {randomState,roomSeed}=value.encounters;let roomState=null,counter=null;
        if(travel.lodging&&roomSeed===null)fail();
        if(travel.scene==='room'&&isTavern(roomAt(cityGeometry.rooms,cityGeometry.map,travel.cityPosition))&&roomSeed===null)fail();
        if(roomSeed!==null) {
          if(travel.scene!=='room'||!validSeed(roomSeed))fail();
          const room=roomAt(cityGeometry.rooms,cityGeometry.map,travel.cityPosition);
          if(populationCache?.room!==room||populationCache.seed!==roomSeed) {
            const population=populateRoom(room,roomSeed);
            populationCache={room,seed:roomSeed,population,randomState:population.randomState,reached:cityReachability(population.geometry)};
          }
          if(version===6) {
            // Version6 derived the whole population and rejected the native
            // empty-placement fallback. Keep its historical acceptance rules.
            if(populationCache.population.actors.length===1)fail();
            if(randomState!==populationCache.randomState||!populationCache.reached(travel.roomPosition))fail();
            roomState=initialRoomTraffic(populationCache.population);
          } else roomState=validateRoomTraffic(lodgingGeometry(room,travel.lodging),value.encounters.roomState,travel.roomPosition,
            {playerRoom:lodgingGeometry(room,travel.lodging,{access:true}),
              ...(version>=8 ? {service:validateCounterRecord(value.encounters.counter).service} : {})}).state;
          counter=version>=8 ? validateCounterRecord(value.encounters.counter) : initialCounter();
          if(isTavern(room)&&roomState.tavern.contact&&counter.service!=='talking')fail();
          if(counter.conversation)restoreCampaignConversation({start,ship,travel,dialogue,encounters:{randomState,roomSeed,roomState,counter}},baseline,room);
        }
        if(version>=7&&roomSeed===null&&value.encounters.roomState!==null)fail();
        if(version>=8&&roomSeed===null&&value.encounters.counter!==null)fail();
        encounters={randomState,roomSeed,roomState,counter};
      }
      // Legacy interior saves remain empty until their next entry, preserving
      // the saved position without spawning an occupant on top of the player.
      return {start,ship,equipment,travel,encounters,dialogue};
    } catch { fail(); }
  }
  function validate(value) {
    const legacy=(value?.version===1 && value.scope==='landed-ship-1') ||
      (value?.version===2 && value.scope==='landed-engineering-1') ||
      (value?.version===3 && value.scope==='landed-city-1') ||
      (value?.version===4 && value.scope==='landed-bank-1') ||
      (value?.version===5 && value.scope==='landed-rooms-1') ||
      (value?.version===6 && value.scope==='landed-occupants-1') ||
      (value?.version===7 && value.scope==='landed-traffic-1') ||
      (value?.version===8 && value.scope==='landed-dialogue-1') ||
      (value?.version===9 && value.scope==='landed-lodging-1');
    if (!keysMatch(value,['format','version','scope','slot','savedAt','state']) ||
        value.format!==CAMPAIGN_FORMAT || (!legacy && (value.version!==VERSION || value.scope!==SCOPE)) ||
        !Number.isInteger(value.slot) || value.slot<0 || value.slot>3 ||
        typeof value.savedAt!=='string' || value.savedAt.length>30 || !Number.isFinite(Date.parse(value.savedAt))) fail();
    return {format:CAMPAIGN_FORMAT,version:VERSION,scope:SCOPE,slot:value.slot,savedAt:value.savedAt,state:snapshot(value.state,value.version)};
  }
  return {
    snapshot:value=>snapshot(value),validate,
    create(character,seed) {
      const start=createCampaignStart(character,baseline,seed);
      return {start,ship:walk.snapshot({position:start.playerLocation.position,inventory:start.inventory,
        condition:start.condition,minutes:start.minutes}),equipment:start.equipment.map(recalculateEquipment),travel:{scene:'ship',cityPosition:null},
        encounters:{randomState:start.gameplayRandomState,roomSeed:null,roomState:null,counter:null},dialogue:initialCampaignDialogue(start)};
    },
    make: (state,slot) => validate({format:CAMPAIGN_FORMAT,version:VERSION,scope:SCOPE,slot,savedAt:new Date().toISOString(),state}),
    parse(text) {
      if (typeof text!=='string' || text.length>CAMPAIGN_LIMIT) fail();
      let value;try {value=JSON.parse(text)} catch {fail()}
      return validate(value);
    },
  };
}

// Reuse the tested transactional compare-before-write mechanism while keeping
// the database and error vocabulary separate from drafts and walkthroughs.
export async function openCampaignStore(codec, name='sundog-campaigns') {
  const translate = error => new Error(({checkpointChanged:'campaignChanged',
    checkpointStorageUnavailable:'campaignStorageUnavailable',invalidCheckpoint:'invalidCampaign'})[error.message] || error.message);
  let store;
  try { store=await openCheckpointStore(codec,name); } catch(error) {throw translate(error)}
  const run = async action => {try {return await action()} catch(error) {throw translate(error)}};
  return {
    list:()=>run(()=>store.list()),
    save:(value,expected=null)=>run(()=>store.save(value,expected)),
    delete:(slot,expected)=>run(()=>store.delete(slot,expected)),
    close:()=>store.close(),
  };
}
