import { initialRegional,regionalGroundStart,validateRegionalCargo } from './regional-world.js';
import { initialCampaignCombat,validateCampaignCombat,validateGroundRewards } from './campaign-combat.js';
import { initialCampaignSpace,validateCampaignSpace,validateSpaceLosses,canonicalCombatEngineeringGroup,migrateCampaignTactical } from './campaign-space.js';
import { createGroundWorld } from './campaign-ground.js';
import { initialFlight } from './campaign-flight.js';
import { validateRegionalFlight } from './regional-saves.js';
import { initialMachinery, validateMachinery } from './campaign-machinery.js';
import { groundSaveValidator, migratedGround } from './ground-saves.js';
import { detachedShipGeometry } from './ship-walk.js';
import { initialEngineering, validateEngineering, canonicalEngineeringGroup } from './campaign-engineering.js';
import { initialShipResources, validateShipResources } from './ship-resources.js';
import { initialCampaignPod, validateCampaignPod, validateLocalCargo, campaignFootGeometry } from './campaign-pod.js';
import { createCampaignStart, CREATION_RECIPE } from './campaign.js';
import { initialBanking, validateBanking } from './banking.js';
import { initialExchange, validateExchange } from './campaign-exchange.js';
import { initialPersonalTrade, validatePersonalTrade, recordPersonalSales } from './personal-trade.js';
import { checkpointCodec, openCheckpointStore } from './checkpoints.js';
import { fitsComponent, recalculateEquipment } from './equipment.js';
import { cityReachability, SHIP_REENTRY } from './city-walk.js';
import { atCityBank, cityServiceAt } from './city-doors.js';
import { roomAt } from './room-walk.js';
import { validateLodging, lodgingGeometry } from './room-lodging.js';
import { isTavern } from './room-seating.js';
import { populateRoom } from './room-actors.js';
import { initialRoomTraffic, validateRoomTraffic } from './room-traffic.js';
import { initialCampaignDialogue, validateCampaignDialogue, initialCounter, validateCounterRecord, restoreCampaignConversation } from './campaign-dialogue.js';

export const CAMPAIGN_FORMAT = 'sundog-campaign';
export const CAMPAIGN_LIMIT = 131072;
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
// Regional content opts into version23 flight; legacy consumers keep landed scopes.
export function campaignSaveCodec(content, geometry, cityGeometry=null) {
  // Own the content used for replay validation; later caller edits cannot
  // retroactively change what this codec accepts.
  const baseline=structuredClone(content), walk=checkpointCodec(geometry),detachedWalk=checkpointCodec(detachedShipGeometry(geometry));
  // Ground-aware callers opt into22 by supplying the source world resources.
  // Existing city-only callers keep their21 contract until live integration.
  if(baseline.combat&&!baseline.regional)throw Error('invalidCampaignContent');
  if(baseline.space!==undefined&&(baseline.space!==true||!baseline.combat||baseline.dialogue?.systems?.systems?.length!==12))throw Error('invalidCampaignContent');
  if(baseline.tactical!==undefined&&(baseline.tactical!==true||!baseline.space))throw Error('invalidCampaignContent');
  const VERSION=baseline.tactical?27:baseline.space?26:baseline.combat?24:baseline.regional?23:baseline.ground?22:21,SCOPE=baseline.tactical?'ship-tactical-1':baseline.space?'ship-communication-1':baseline.combat?'ground-encounters-1':baseline.regional?'regional-flight-1':baseline.ground?'landed-ground-1':'landed-parking-1';
  let groundValidator=null,groundSeed=null;
  let populationCache=null;
  function snapshot(value, version = VERSION) {
    try {
      if (!keysMatch(value,version===1 ? ['start','ship'] : version===2 ? ['start','ship','equipment'] : version<6 ? ['start','ship','equipment','travel'] : version<8 ? ['start','ship','equipment','travel','encounters'] : ['start','ship','equipment','travel','encounters','dialogue',...(version>=12 ? ['economy'] : []),...(version>=16 ? ['pod'] : []),...(version>=18 ? ['resources'] : []),...(version>=19 ? ['engineering'] : []),...(version>=20 ? ['machinery'] : []),...(version>=22 ? ['ground'] : []),...(version>=23 ? ['regional','flight'] : []),...(version>=24 ? ['combat'] : []),...(version>=25 ? ['space'] : [])]) || value.start?.creation?.recipe!==CREATION_RECIPE) fail();
      const start=createCampaignStart(value.start.character,baseline,value.start.creation.seed);
      if (!sameTree(value.start,start)) fail();
      const ship=(version>=21&&value.pod?.attached===false?detachedWalk:walk).snapshot(value.ship,{allowInactiveCondition:version>=24});
      if (!sameTree(value.ship,ship)) fail();
      const engineering=version>=19?validateEngineering(value.engineering):initialEngineering();
      let equipment;
      if (version===1) equipment=start.equipment.map(recalculateEquipment);
      else {
        if (!Array.isArray(value.equipment) || value.equipment.length!==6 || Object.keys(value.equipment).length!==6) fail();
        equipment=value.equipment.map((group,i)=>{
          const initial=start.equipment[i];
          if (!Array.isArray(group?.units) || group.units.length!==4) fail();
          let expected;
          if(version>=25&&value.space?.combatFailures?.[i]===true)expected=canonicalCombatEngineeringGroup(group,initial,engineering.pendingFailures[i]);
          else if(version>=19)expected=canonicalEngineeringGroup(group,initial,engineering.pendingFailures[i]);
          else {
            for(const unit of group.units) {
              if(!Array.isArray(unit?.components)||unit.components.length!==4||
                Array.from(unit.components).some((byte,socket)=>!Number.isInteger(byte)||(byte!==0&&byte!==7&&!fitsComponent(initial,byte,socket))))fail();
            }
            expected=recalculateEquipment({...initial,units:group.units});
          }
          if (!sameTree(group,expected)) fail();
          return expected;
        });
      }
      const regional=version>=23?structuredClone(value.regional):null,flight=version>=23?structuredClone(value.flight):null;
      let ground=null,groundCheck=null;
      if(version>=22) {
        if(!baseline.ground)fail();
        const groundStart=regional?regionalGroundStart({...value,start}):start;
        const key=JSON.stringify([start.creation.seed,groundStart.shipLocation,value.ground.worldId,version>=23]);
        if(groundSeed!==key) {
          groundValidator=groundSaveValidator({...baseline,...baseline.ground},groundStart,cityGeometry?.rooms,{regional:version>=23});
          groundSeed=key;
        }
        groundCheck=groundValidator;
        ground=groundCheck.metadata(value.ground,value.travel,value.pod);
      }
      const activeCity=groundCheck?groundCheck.city({...value,ground}):cityGeometry;
      const pod=groundCheck?groundCheck.pod(value.pod,{...value,ground}):version>=16 ? validateCampaignPod(value.pod,value.travel,cityGeometry?.pod,{depot:version>=18,auxiliaryFuel:version>=18,parking:version>=21}) : initialCampaignPod();
      const driving=pod.occupied;
      const foot=groundCheck?activeCity:cityGeometry&&!driving?campaignFootGeometry(cityGeometry,pod):cityGeometry;
      let travel={scene:'ship',cityPosition:null};
      if(version>=3) {
        const inRoom=version>=5 && value.travel?.scene==='room';
        const inService=version>=11 && ['transstation','depot','exchange'].includes(value.travel?.scene);
        const lodgingRoom=inRoom&&version>=9&&roomAt(activeCity?.rooms,activeCity?.map,value.travel.cityPosition)?.index===1;
        if(!keysMatch(value.travel,inRoom ? ['scene','cityPosition','roomPosition',...(lodgingRoom ? ['lodging'] : [])] : ['scene','cityPosition']))fail();
        if(version>=22&&value.travel.scene==='surface') {
          if(!keysMatch(value.travel.cityPosition,['x','y'])||!sameTree(ship.position,SHIP_REENTRY))fail();
          travel={scene:'surface',cityPosition:{x:value.travel.cityPosition.x,y:value.travel.cityPosition.y}};
        } else if(value.travel.scene==='city' || (version>=4 && value.travel.scene==='bank') || inRoom || inService) {
          if(!activeCity||!keysMatch(value.travel.cityPosition,['x','y'])||!sameTree(ship.position,SHIP_REENTRY))fail();
          if(!driving&&!groundCheck) {
            if(!cityValidators.has(foot))cityValidators.set(foot,cityReachability(foot));
            if(!cityValidators.get(foot)(value.travel.cityPosition))fail();
          }
          if(value.travel.scene==='bank' && !atCityBank(activeCity.map,value.travel.cityPosition))fail();
          if(inService && cityServiceAt(activeCity.map,value.travel.cityPosition,driving?'pod':'foot')!==value.travel.scene)fail();
          travel={scene:value.travel.scene,cityPosition:{x:value.travel.cityPosition.x,y:value.travel.cityPosition.y}};
          if(inRoom) {
            const room=roomAt(activeCity.rooms,activeCity.map,value.travel.cityPosition);
            if(!room || (version<9&&room.index===1) || (version<10&&isTavern(room)) || !keysMatch(value.travel.roomPosition,['x','y']))fail();
            const lodging=lodgingRoom ? validateLodging(value.travel.lodging) : undefined;
            const access=lodgingGeometry(room,lodging,{access:true});
            if(!cityValidators.has(access))cityValidators.set(access,cityReachability(access));
            if(!cityValidators.get(access)(value.travel.roomPosition))fail();
            travel.roomPosition={x:value.travel.roomPosition.x,y:value.travel.roomPosition.y};
            if(lodgingRoom)travel.lodging=lodging;
          }
        } else if(!sameTree(value.travel,travel))fail();
      }
      const dialogue=version>=8 ? validateCampaignDialogue(value.dialogue,{visitors:version>=10,traderMatching:version>=17,groundEncounters:version>=24,...(version===8 ? {legacyCash:start.credits} : {})}) : initialCampaignDialogue(start);
      if(dialogue.flags[65]&&travel.scene==='room'&&!isTavern(roomAt(activeCity.rooms,activeCity.map,travel.cityPosition)))fail();
      if(version>=13&&!keysMatch(value.economy,['accounts','exchange',...(version>=15 ? ['personalTrade'] : [])]))fail();
      const banking=version>=12 ? validateBanking(version>=13 ? {accounts:value.economy.accounts} : value.economy) : initialBanking(start);
      const economy={...banking,exchange:version>=13 ? validateExchange(value.economy.exchange,start,ship,travel,baseline,{movableCargo:version>=16,auxiliaryFuel:version>=18,regional:version>=23}) : initialExchange(start),
        personalTrade:version>=15 ? validatePersonalTrade(value.economy.personalTrade,baseline.dialogue?.items||baseline.items) : initialPersonalTrade()};
      const resources=version>=18 ? validateShipResources(value.resources,start,{machinery:version>=20,flight:version>=23,combat:version>=25}) : initialShipResources(start);
      const machinery=version>=20?validateMachinery(value.machinery,equipment,resources,{tacticalGunLoop:version>=27&&value.space?.tactical?.record?.firing===true}):initialMachinery();
      let storedCosts;
      if(version>=23) {
        for(const c of regional.cities)validateExchange({...c,visit:null},start,ship,{scene:'ship',cityPosition:null},baseline,{movableCargo:true,auxiliaryFuel:true,regional:true});
        storedCosts=validateRegionalCargo(start,economy.exchange,pod,regional,version>=25?validateSpaceLosses(value.space?.losses):[]);
        validateRegionalFlight({...value,start,ship,equipment,ground,pod,travel,resources,regional,flight},baseline);
      } else {if(version>=16)validateLocalCargo(start,economy.exchange,pod);storedCosts=[...economy.exchange.warehouse.slots,...pod.cargo].reduce((sum,c)=>sum+(c?.pricePaid||0),0)}
      if(version<12 && dialogue.cash>start.credits)fail();
      // Local cargo can only resell at/below price paid. Cash, accounts and
      // stored purchase costs cannot exceed creation wealth plus personal sales.
      if(dialogue.cash+economy.accounts.reduce((sum,a)=>sum+a.balance,0)+storedCosts>
        start.credits+start.systems.reduce((sum,s)=>sum+s.bankBalance,0)+economy.personalTrade.proceeds.reduce((sum,p)=>sum+p,0)+(regional?.cargoProceeds??0)+
          (version>=24?validateGroundRewards(value.combat?.rewards,baseline).reduce((sum,r)=>sum+r.amount,0):0))fail();
      let encounters={randomState:start.gameplayRandomState,roomSeed:null,roomState:null,counter:null};
      if(version>=6) {
        const validSeed=n=>Number.isInteger(n)&&n>=0&&n<=0xffffffff;
        if(!keysMatch(value.encounters,version===6 ? ['randomState','roomSeed'] : version===7 ? ['randomState','roomSeed','roomState'] : ['randomState','roomSeed','roomState','counter'])||!validSeed(value.encounters.randomState))fail();
        const {randomState,roomSeed}=value.encounters;let roomState=null,counter=null;
        if(travel.lodging&&roomSeed===null)fail();
        if(travel.scene==='room'&&isTavern(roomAt(activeCity.rooms,activeCity.map,travel.cityPosition))&&roomSeed===null)fail();
        if(roomSeed!==null) {
          if(travel.scene!=='room'||!validSeed(roomSeed))fail();
          const room=roomAt(activeCity.rooms,activeCity.map,travel.cityPosition);
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
            {traderMatching:version>=17,playerRoom:lodgingGeometry(room,travel.lodging,{access:true}),
              ...(version>=8 ? {service:validateCounterRecord(value.encounters.counter).service} : {})}).state;
          counter=version>=8 ? validateCounterRecord(value.encounters.counter) : initialCounter();
          if(isTavern(room)&&roomState.tavern.contact&&counter.service!=='talking')fail();
          if(counter.conversation) {
            const restored=restoreCampaignConversation({start,ship,travel,dialogue,...(regional?{regional,ground}:{}),encounters:{randomState,roomSeed,roomState,counter}},baseline,room,{purchases:version>=14,visitorTrades:version>=15,traderMatching:version>=17});
            recordPersonalSales(economy.personalTrade,restored.conversation.state.sales,baseline.dialogue.items);
          }
        }
        if(version>=7&&roomSeed===null&&value.encounters.roomState!==null)fail();
        if(version>=8&&roomSeed===null&&value.encounters.counter!==null)fail();
        encounters={randomState,roomSeed,roomState,counter};
      }
      // Legacy interior saves remain empty until their next entry, preserving
      // the saved position without spawning an occupant on top of the player.
      if(groundCheck)groundCheck.player({...value,ground,pod,travel});
      let combat=null;
      if(version>=24) {
        const campaign={...value,start,ship,equipment,travel,encounters,dialogue,economy,pod,resources,engineering,machinery,ground,regional,flight};
        const world=createGroundWorld({...baseline,...baseline.ground},regionalGroundStart(campaign));
        combat=validateCampaignCombat(campaign,value.combat,world,baseline);
      }
      const campaign={start,ship,equipment,travel,encounters,dialogue,economy,pod,resources,engineering,machinery,ground,regional,flight,combat};
      let space=version>=25?validateCampaignSpace(campaign,value.space,{communication:version>=26,tactical:version>=27,content:baseline}):null;
      if(VERSION>=27&&version<27)space=migrateCampaignTactical(campaign,space??initialCampaignSpace());
      return {start,ship,equipment,travel,encounters,dialogue,economy,pod,resources,engineering,machinery,
        ...(VERSION>=22?{ground:ground??migratedGround(start,travel)}:{}),...(VERSION>=23?{regional:regional??{...initialRegional(start),colonyPosition:ground?.colonyPosition??null,legacyDialogueSurface:encounters.counter?.conversation?structuredClone(start.playerLocation.surfacePosition):null},flight:flight??initialFlight()}:{}),...(VERSION>=24?{combat:combat??initialCampaignCombat()}:{}),...(VERSION>=25?{space:space??initialCampaignSpace()}:{})};
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
      (value?.version===9 && value.scope==='landed-lodging-1') ||
      (value?.version===10 && value.scope==='landed-taverns-1') ||
      (value?.version===11 && value.scope==='landed-services-1') ||
      (value?.version===12 && value.scope==='landed-banking-1') ||
      (value?.version===13 && value.scope==='landed-exchange-1') ||
      (value?.version===14 && value.scope==='landed-purchases-1') ||
      (value?.version===15 && value.scope==='landed-personal-trade-1') ||
      (value?.version===16 && value.scope==='landed-local-cargo-1') ||
      (value?.version===17 && value.scope==='landed-trader-matching-1') ||
      (value?.version===18 && value.scope==='landed-depot-1') ||
      (value?.version===19 && value.scope==='landed-failures-1') ||
      (value?.version===20 && value.scope==='landed-power-1') ||
      (VERSION>=27 && value?.version===26 && value.scope==='ship-communication-1') ||
      (VERSION>=26 && value?.version===25 && value.scope==='ship-encounters-1') ||
      (VERSION>=25 && value?.version===24 && value.scope==='ground-encounters-1') ||
      (VERSION>=24 && value?.version===23 && value.scope==='regional-flight-1') ||
      (VERSION>=23 && value?.version===22 && value.scope==='landed-ground-1') ||
      (VERSION>=22 && value?.version===21 && value.scope==='landed-parking-1');
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
        encounters:{randomState:start.gameplayRandomState,roomSeed:null,roomState:null,counter:null},dialogue:initialCampaignDialogue(start),economy:{...initialBanking(start),exchange:initialExchange(start),personalTrade:initialPersonalTrade()},pod:initialCampaignPod(),resources:initialShipResources(start),engineering:initialEngineering(),machinery:initialMachinery(),...(VERSION>=22?{ground:migratedGround(start,{scene:'ship',cityPosition:null})}:{}),...(VERSION>=23?{regional:initialRegional(start),flight:initialFlight()}:{}),...(VERSION>=24?{combat:initialCampaignCombat()}:{}),...(VERSION>=25?{space:initialCampaignSpace({tactical:VERSION>=27})}:{})};
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
