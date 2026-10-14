import { currentShipLocation,campaignLocation,regionalGroundStart } from '../core/regional-world.js';
import { reduceCampaignFlight,flightMode } from '../core/campaign-flight.js';
import { navigationPanel,navigationDestinations,drawNavigation } from './navigation.js';
import { createGroundWorld, reduceCampaignGround, nearbySurfacePod } from '../core/campaign-ground.js';
import { groundCameraAt, groundWindow } from '../core/ground-camera.js';
import { surfaceCityAt } from '../core/surface-walk.js';
import { advanceCampaignMachinery, reduceMachineryControl } from '../core/campaign-machinery.js';
import { machineryPanel } from './machinery.js';
import { reduceCampaignEngineering, ENGINEERING_UPDATE_MS } from '../core/campaign-engineering.js';
import { campaignDepotOffers, reduceCampaignDepot } from '../core/campaign-depot.js';
import { depotPanel } from './depot.js';
import { canBoardParkedPod } from '../core/parked-pod.js';
import { canDockPod, podServiceAt } from '../core/city-pod.js';
import { reduceCampaignPod } from '../core/campaign-pod.js';
import { createWalk, advanceWalk, interactionAt, canStand, detachedShipGeometry } from '../core/ship-walk.js';
import { createInventory, storageAt, transferItem } from '../core/inventory.js';
import { inventoryPanel } from './inventory.js';
import { createCondition, useCarriedItem } from '../core/condition.js';
import { createSurvival, advanceSurvival, startSleep, wakeUp } from '../core/survival.js';
import { checkpointCodec, openCheckpointStore, CHECKPOINT_LIMIT } from '../core/checkpoints.js';
import { campaignSaveCodec, openCampaignStore, CAMPAIGN_LIMIT } from '../core/campaign-saves.js';
import { checkpointScreen } from './checkpoints.js';
import { escapeHTML } from './html.js';
import { equipmentBayAt, inspectEquipment } from '../core/equipment.js';
import { equipmentPanel } from './equipment.js';
import { canBoardShip, SHIP_REENTRY } from '../core/city-walk.js';
import { atCityBank, cityServiceAt } from '../core/city-doors.js';
import { bankPanel } from './bank.js';
import { reduceCampaignBank, bankAvailable as availableBankFunds, adjustBankAmount } from '../core/banking.js';
import { cityServicePanel } from './city-service.js';
import { exchangePanel } from './exchange.js';
import { reduceCampaignExchange } from '../core/campaign-exchange.js';
import { reduceCampaignColony } from '../core/colony.js';
import { colonyPanel } from './colony.js';
import { roomAt, canLeaveRoom } from '../core/room-walk.js';
import { initialLodging, lodgingGeometry } from '../core/room-lodging.js';
import { isTavern, playerSeatAt } from '../core/room-seating.js';
import { populateRoom, roomActorGeometry } from '../core/room-actors.js';
import { initialRoomTraffic, tickRoomTraffic, ROOM_TICK_MS } from '../core/room-traffic.js';
import { reduceCampaignCounter, restoreCampaignConversation } from '../core/campaign-dialogue.js';
import { dialoguePanel } from './dialogue.js';
import { advanceGroundHost, restoreCampaignGroundHost } from '../core/ground-host.js';
import { advanceGroundEncounter } from '../core/ground-encounter.js';
import { snapshotCampaignGroundHost } from '../core/campaign-combat.js';
import { drawGroundEncounter } from '../render/ground-encounter.js';
import { reduceCampaignSpace,reduceCampaignShipCommunication,restoreCampaignShipCommunication,neutralShipControl } from '../core/campaign-space.js';
import { spacePanel,drawSpace } from './space.js';

export const WALK_BOUNDS = { x: 32, y: 46, width: 640, height: 384 };
const CITY_BOUNDS={x:145,y:126,width:350,height:240};
export function shipWalkScreen({ stage, background, assets, t, language, locale=()=> 'en', close }) {
  const root = document.createElement('section'); root.id = 'walk-screen'; root.hidden = true; stage.append(root);
  let state = createWalk(assets.shipWalk), open = false, frame, previous = 0, help = false, activePointer = null;
  let inventory = createInventory(assets.shipInventory), inventoryOpen = false, selected = null, inventoryMessage = '';
  let condition = createCondition(assets.shipInventory.condition);
  let survival = createSurvival(condition);
  let campaignMode=false, campaignStart=null;
  let campaignEquipment=null,campaignDialogue=null;
  let campaignGround=null,groundWorld=null,campaignRegional=null,campaignFlight=null,campaignColony=null;
  let campaignSpace=null,spaceMessage='';
  const inSpace=()=>campaignMode&&!outsideShip()&&!!campaignSpace?.tactical&&!survival.dead&&!survival.sleeping;
  const tractorActive=()=>!!campaignSpace?.tactical?.record.wreck&&campaignSpace.tactical.record.wreck.tractorSlot!==null;
  let campaignCombat=null,groundHost=null,combatAim=null,fireHeld=false,firePointer=false,aimMode=false,cancelSurrender=false;
  const groundEncounter=()=>campaignMode?groundHost?.encounter?.activation:null;
  let navigationOpen=false,navigationScale='system',navigationDraft=null,navigationMessage='',navigationChoice=null;
  const shipLocation=()=>currentShipLocation({regional:campaignRegional,start:campaignStart});
  const location=()=>campaignLocation({regional:campaignRegional,start:campaignStart,ground:campaignGround},assets.campaignContent);
  const landed=()=>!campaignMode||!!shipLocation()?.cityId&&!campaignFlight?.motion;
  const rebuildGround=()=>{groundWorld=createGroundWorld({...assets.campaignContent,...assets.campaignContent.ground},regionalGroundStart({start:campaignStart,regional:campaignRegional,ground:campaignGround}),{completedPhase:campaignColony?.completedPhase??0})};
  let campaignPod=null,campaignResources=null,campaignEngineering=null,campaignMachinery=null;
  let machineryOpen=false,machineryMessage='';
  let depotDraft=null,depotMessage='';
  const driving=()=>campaignMode&&campaignPod?.occupied===true;
  const activeCity=()=>groundWorld&&campaignGround?{...groundWorld.city(campaignGround.cityId??shipLocation().cityId,campaignPod.attached),rooms:assets.cityGeometry.rooms}:assets.cityGeometry;
  const footGeometry=()=>groundWorld?groundWorld.foot({ground:{...campaignGround,cityId:campaignGround.cityId??shipLocation().cityId},pod:campaignPod}):assets.cityGeometry;
  const localServices=()=>campaignRegional?!!campaignGround?.cityId:campaignGround?.cityId===campaignStart?.shipLocation.cityId;
  const inSurface=()=>campaignMode&&travel.scene==='surface';
  const groundCamera=()=>campaignGround?.camera??{x:0,y:0};
  const boardPodAvailable=()=>campaignPod&&!campaignPod.attached&&!driving()&&campaignGround.podCityId===campaignGround.cityId&&(!campaignRegional||campaignRegional.podWorldId===campaignGround.worldId)&&
    (inSurface()?nearbySurfacePod(state.position,campaignPod.position):canBoardParkedPod(footGeometry(),state.position,campaignPod.position));
  let campaignEconomy=null,bankDraft=null,bankMessage='';
  let exchangeTab='offers',exchangeDraft=null,exchangeMessage='';
  let colonyDraft=null,colonyMessage='';
  let dialogueFrame=null,dialogueError='';
  let travel={scene:'ship',cityPosition:null};
  let encounters=null,roomPopulation=null,roomMessage='',roomElapsed=0;
  const inCity=()=>campaignMode&&['city','bank','transstation','depot','exchange','colony'].includes(travel.scene);
  const inService=()=>campaignMode&&['bank','transstation','depot','exchange','colony'].includes(travel.scene);
  const inBank=()=>campaignMode&&travel.scene==='bank';
  const inRoom=()=>campaignMode&&travel.scene==='room';
  const outsideShip=()=>inCity()||inSurface()||inRoom();
  const currentRoom=()=>roomAt(activeCity().rooms,activeCity().map,travel.cityPosition);
  const roomGeometry=()=>lodgingGeometry(currentRoom(),travel.lodging);
  const counterAvailable=()=>{
    if(!inRoom()||!encounters.counter||dialogueFrame)return false;
    const b=currentRoom().population.bounds,p=state.position;
    if(isTavern(currentRoom())&&playerSeatAt(currentRoom(),p)!==null)return true;
    return p.x>=b.left&&p.x<=b.right&&p.y>=b.top&&p.y<=b.bottom;
  };
  const availableRoom=()=>localServices()&&inCity()&&!inService()&&!driving() ? roomAt(activeCity().rooms,activeCity().map,state.position) : null;
  const bankAvailable=()=>localServices()&&inCity()&&!inService()&&!driving()&&atCityBank(activeCity().map,state.position);
  const serviceAvailable=()=>localServices()&&inCity()&&!inService() ? (driving() ? podServiceAt(activeCity().pod,state.position,campaignPod.heading) : cityServiceAt(activeCity().map,state.position)) : null;
  const geometry=()=>inSurface()?groundWorld.surface(campaignGround.colonyPosition):inRoom() ? roomPopulation?.geometry || roomGeometry() : inCity() ? driving()?activeCity().pod:footGeometry() : campaignMode&&campaignPod&&!campaignPod.attached?detachedShipGeometry(assets.shipWalk):assets.shipWalk;
  const bayAt=()=>outsideShip() ? null : equipmentBayAt(state.position);
  const storage=()=>outsideShip() ? null : storageAt(state.position);
  const travelAvailable=()=>campaignMode&&campaignStart&&!groundEncounter()&&landed()&&!inService()&&(inSurface()?surfaceCityAt(geometry().map,state.position):inRoom() ? canLeaveRoom(currentRoom(),state.position) : inCity() ? serviceAvailable()||availableRoom()||(driving()?canDockPod(activeCity().pod,state.position,campaignPod.heading):canBoardShip(footGeometry(),state.position)) : interactionAt(state.position)===3?campaignPod.attached:interactionAt(state.position)===4&&canStand(footGeometry(),activeCity().spawn));
  let equipmentOpen=false, equipmentOffset=0, equipmentSelected=null;
  let equipmentMoving=false, equipmentMessage='',equipmentElapsed=0;
  const sessions=new Map();
  const campaignCodec=campaignSaveCodec(assets.campaignContent,assets.shipWalk,assets.cityGeometry);
  const campaignKeys = Object.fromEntries(['checkpointTitle','checkpointScope','checkpointHint','checkpointLoadOnly',
    'checkpointSaved','checkpointDeleted','checkpointLoaded','checkpointImported','checkpointExported',
    'invalidCheckpoint','replaceCheckpointConfirm','deleteCheckpointConfirm','loadCheckpointConfirm']
    .map(key=>[key,key.replace('checkpoint','campaign').replace('Checkpoint','Campaign')]));
  const timeLabel = () => t('gameTime', { day: Math.floor(survival.minutes / 1440), hour: String(Math.floor(survival.minutes / 60) % 24).padStart(2, '0'), minute: String(survival.minutes % 60).padStart(2, '0') });
  const keys = new Set();
  const directions = { ArrowLeft: [-1, 0], ArrowRight: [1, 0], ArrowUp: [0, -1], ArrowDown: [0, 1] };
  const spaceSignature=()=>JSON.stringify([campaignSpace?.tactical?.record.menu,campaignSpace?.tactical?.record.firing,
    campaignSpace?.tactical?.record.sensors,campaignSpace?.tactical?.record.wreck?.present,
    campaignSpace?.tactical?.record.wreck?.tractorSlot,campaignSpace?.flags[40],campaignSpace?.flags[47]]);
  const stop = ({releaseSpace=true}={}) => { keys.clear(); activePointer = null;fireHeld=false;firePointer=false;cancelSurrender=false; state = { ...state, held: false, pointer: null, elapsed: 0 };
    if(releaseSpace&&campaignMode&&campaignSpace?.tactical&&!tractorActive())campaignSpace.tactical.control=neutralShipControl();
  };
  const codec = checkpointCodec(assets.shipWalk),detachedCodec=checkpointCodec(detachedShipGeometry(assets.shipWalk));
  const selectedCodec=()=>campaignMode ? campaignCodec : codec;
  const liveShip=()=>({position:outsideShip() ? SHIP_REENTRY : state.position,inventory,condition,minutes:survival.minutes});
  const liveCampaign=(snapshot=true)=>({start:campaignStart,ship:snapshot?(campaignPod.attached?codec:detachedCodec).snapshot(liveShip(),{allowInactiveCondition:true}):liveShip(),equipment:campaignEquipment,encounters,dialogue:campaignDialogue,economy:campaignEconomy,pod:campaignPod,resources:campaignResources,engineering:campaignEngineering,machinery:campaignMachinery,ground:campaignGround,regional:campaignRegional,flight:campaignFlight,combat:campaignCombat,colony:campaignColony,...(campaignSpace?{space:campaignSpace}:{}),
    travel:inRoom() ? {...travel,roomPosition:state.position} : {scene:travel.scene,cityPosition:inCity()||inSurface() ? state.position : null}});
  function commitCampaign(next) {
    campaignStart=next.start;campaignGround=next.ground;campaignRegional=next.regional;campaignFlight=next.flight;campaignCombat=next.combat;campaignColony=next.colony;
    campaignSpace=next.space??null;campaignEquipment=next.equipment;campaignDialogue=next.dialogue;campaignEconomy=next.economy;
    campaignPod=next.pod;campaignResources=next.resources;campaignEngineering=next.engineering;campaignMachinery=next.machinery;travel=next.travel;encounters=next.encounters;
    inventory=next.ship.inventory;condition=next.ship.condition;
    survival={...survival,condition,minutes:next.ship.minutes,dead:condition.vigor===0||!!campaignCombat?.defeat||!!campaignSpace?.defeat,
      ...(!outsideShip()&&campaignSpace?{...campaignSpace.activity,elapsed:campaignSpace.elapsed}:{})};
  }
  function settleAboardClock() {
    if(!campaignMode||!campaignSpace||outsideShip()||!previous||state.paused||dialogueFrame||checkpoints.active||help||equipmentOpen||inventoryOpen&&!survival.sleeping)return;
    const now=performance.now(),oldLocation=campaignRegional.shipLocation,activity=`${survival.sleeping}/${survival.forced}/${survival.dead}`;
    const advanced=advanceCampaignMachinery(liveCampaign(false),survival,Math.max(0,Math.min(60000,Math.floor(now)-Math.floor(previous))),false,assets.campaignContent);
    commitCampaign(advanced.state);survival=advanced.survival;previous=now;
    if(oldLocation.cityId!==campaignRegional.shipLocation.cityId||oldLocation.worldId!==campaignRegional.shipLocation.worldId)rebuildGround();
    if(activity!==`${survival.sleeping}/${survival.forced}/${survival.dead}`){stop();selected=null;render()}
  }
  function spaceAction(action,{pause=true}={}) {
    try {
      if(pause)settleCampaignClock();
      const next=action.type==='comm'||action.type==='dialogue'?reduceCampaignShipCommunication(liveCampaign(false),assets.campaignContent,action):
        ['shields','cloak'].includes(action.type)?reduceMachineryControl(liveCampaign(false),action):reduceCampaignSpace(liveCampaign(false),action,assets.campaignContent);
      commitCampaign(next);spaceMessage='';
      dialogueFrame=campaignSpace.communication.conversation?restoreCampaignShipCommunication(liveCampaign(false),assets.campaignContent):null;
      if(pause){stop();state.paused=true;previous=0}
      return true;
    }catch(error){spaceMessage=error.message;return false}
  }
  function spaceInput(control) {
    if(inSpace()&&!tractorActive()) {
      settleCampaignClock();
      if(inSpace())spaceAction({type:'aim',control},{pause:false});
    }
  }
  function exchangeAction(action) {
    const next=['store','fetch','swap'].includes(action.type) ? reduceCampaignPod(liveCampaign(),activeCity().pod,action) : reduceCampaignExchange(liveCampaign(),assets.campaignContent,activeCity().map,action);
    commitCampaign(next);
  }
  function colonyAction(action) {
    const previous=campaignColony.completedPhase;
    const next=reduceCampaignColony(liveCampaign(),assets.campaignContent,driving()?activeCity().pod:activeCity(),action);
    commitCampaign(next);
    if(campaignColony.completedPhase!==previous)rebuildGround();
  }
  function prepareCampaignRestore(value) {
    const next=campaignCodec.snapshot(value);
    return next.travel.scene==='exchange'&&!next.economy.exchange.visit ?
      reduceCampaignExchange(next,assets.campaignContent,createGroundWorld({...assets.campaignContent,...assets.campaignContent.ground},regionalGroundStart(next)).city(next.ground.cityId,next.pod.attached).map,{type:'enter'}) : next;
  }
  function engineeringAction(action) {
    const result=reduceCampaignEngineering(liveCampaign(),action);
    commitCampaign(result.state);equipmentMessage=result.message;
  }
  function resetExchangeDraft() {exchangeDraft=null;exchangeMessage='';exchangeTab='offers';depotDraft=null;depotMessage=''}
  function applyGroundHost(next) {
    let campaign=next.campaign;
    campaign.combat={...campaignCombat,clock:next.clock,ground:next.encounter?.record??null};
    const terminal=next.encounter&&['escaped','returned','defeated'].includes(next.encounter.activation.phase);
    if(terminal)campaign=snapshotCampaignGroundHost({...next,campaign},groundWorld,assets.campaignContent);
    else if(next.defeated)campaign.combat.defeat={reason:'conditionDeath',minutes:campaign.ship.minutes};
    campaignCombat=campaign.combat;campaignGround=campaign.ground;campaignRegional=campaign.regional;
    campaignPod=campaign.pod;campaignDialogue=campaign.dialogue;campaignEconomy=campaign.economy;
    encounters=campaign.encounters;travel=campaign.travel;inventory=campaign.ship.inventory;condition=campaign.ship.condition;
    state.position=travel.cityPosition;
    groundHost=terminal?restoreCampaignGroundHost(campaign,groundWorld,assets.campaignContent):{...next,campaign};
    dialogueFrame=groundHost.encounter?.activation.conversation??null;
    survival={...survival,condition,minutes:campaign.ship.minutes,dead:campaignCombat.defeat!==null};
    if(next.exhausted&&!survival.dead&&!survival.sleeping)survival={...startSleep(survival),forced:true};
    return terminal;
  }
  function encounterDialogue(input) {
    try {
      const next={...groundHost,encounter:advanceGroundEncounter(groundHost.encounter,assets.campaignContent,{type:'dialogue',input})};
      next.campaign=next.encounter.campaign;applyGroundHost(next);dialogueError='';
      stop();state.paused=true;previous=0;
    }catch(error){dialogueError=['dialogueHistoryFull','dialogueSlotOccupied','dialogueInsufficientCash','dialogueCashOverflow'].includes(error.message)?error.message:'dialogueUnavailable'}
  }
  const dialogueAction=input=>campaignSpace?.communication.conversation?spaceAction({type:'dialogue',input}):groundEncounter()?encounterDialogue(input):counterAction({type:'dialogue',input});
  function counterAction(action) {
    try {
      const result=reduceCampaignCounter(liveCampaign(),assets.campaignContent,currentRoom(),action);
      encounters=result.state.encounters;campaignDialogue=result.state.dialogue;dialogueFrame=result.conversation;dialogueError='';
      inventory=result.state.ship.inventory;campaignEconomy=result.state.economy;campaignRegional=result.state.regional;
      travel=result.state.travel;
      roomPopulation={actors:encounters.roomState.actors,geometry:roomActorGeometry(roomGeometry(),encounters.roomState.actors)};
      if(dialogueFrame||action.type==='dialogue'){stop();state.paused=true;roomElapsed=0;survival={...survival,elapsed:0}}
      return true;
    } catch(error) {
      dialogueError=['dialogueHistoryFull','dialogueSlotOccupied','dialogueInsufficientCash','dialogueCashOverflow'].includes(error.message) ? error.message :
        error.message==='roomTrafficBusy' ? 'tavernBusy' : error.message==='tavernSeatReserved' ? 'tavernReserved' : 'dialogueUnavailable';
      roomMessage=dialogueError;stop();state.paused=true;return false;
    }
  }
  function restoreShip(next) {
    if(campaignMode&&campaignStart)rebuildGround();
    bankDraft=null;bankMessage='';
    if(campaignMode)roomPopulation=inRoom()&&encounters.roomState ? {actors:encounters.roomState.actors,geometry:roomActorGeometry(roomGeometry(),encounters.roomState.actors)} : null;
    roomMessage='';roomElapsed=0;
    stop({releaseSpace:false});state={...createWalk(geometry()),position:inRoom() ? travel.roomPosition : inCity()||inSurface() ? travel.cityPosition : next.position,paused:true};
    inventory=next.inventory;condition=next.condition;survival={...createSurvival(condition),minutes:next.minutes};
    dialogueFrame=inRoom()&&encounters.counter?.conversation ? restoreCampaignConversation(liveCampaign(),assets.campaignContent,currentRoom()).conversation : null;
    if(campaignMode&&campaignCombat) {
      groundHost=restoreCampaignGroundHost(liveCampaign(false),groundWorld,assets.campaignContent);
      dialogueFrame=groundHost.encounter?.activation.conversation??dialogueFrame;
      survival.dead=campaignCombat.defeat!==null||!!campaignSpace?.defeat||condition.vigor===0;
      if(groundHost.exhausted&&!survival.dead)survival={...startSleep(survival),forced:true};
    }
    if(campaignMode&&!outsideShip()&&campaignSpace) {
      survival={...survival,...campaignSpace.activity,elapsed:campaignSpace.elapsed};
      if(campaignSpace.communication.conversation)dialogueFrame=restoreCampaignShipCommunication(liveCampaign(false),assets.campaignContent);
    }
    combatAim=null;aimMode=false;
    dialogueError='';spaceMessage='';
    inventoryOpen=false;selected=null;equipmentOpen=false;machineryOpen=false;navigationOpen=false;navigationDraft=null;navigationMessage='';machineryMessage='';help=false;previous=0;
  }
  const checkpoints = checkpointScreen({ stage, background:root,
    codec:Object.fromEntries(['validate','make','parse'].map(key=>[key,(...args)=>selectedCodec()[key](...args)])),
    t:(key,params)=>t(campaignMode ? campaignKeys[key] || key : key,params),language,
    storeKey:()=>campaignMode ? 'campaign' : 'checkpoint',
    openStore:()=>campaignMode ? openCampaignStore(campaignCodec) : openCheckpointStore(codec),
    limit:()=>campaignMode ? CAMPAIGN_LIMIT : CHECKPOINT_LIMIT,
    filename:()=>campaignMode ? 'sundog-campaign.json' : 'sundog-ship-checkpoint.json',
    describe:value=>campaignMode ? t('campaignSummary',{name:value.state.start.character.name,day:Math.floor(value.state.ship.minutes/1440)}) :
      t('checkpointSummary',{hours:Math.floor(value.state.minutes/60),minute:String(value.state.minutes%60).padStart(2,'0'),x:value.state.position.x,y:value.state.position.y}),
    snapshot: () => {
      if ((survival.sleeping || survival.forced)&&(!campaignMode||!campaignSpace||outsideShip()) || survival.dead&&!campaignMode) throw new Error('invalidCheckpoint');
      if(campaignMode) {
        if(!campaignStart)throw new Error('invalidCampaign');
        return liveCampaign();
      }
      return codec.snapshot(liveShip());
    },
    restore: value => {
      const next=campaignMode ? prepareCampaignRestore(value) : selectedCodec().snapshot(value); // Prepare before replacing live state.
      if(campaignMode) {commitCampaign(next);restoreShip(next.ship);resetExchangeDraft()}
      else restoreShip(next);
    },
    close: () => {
      if(campaignMode && !campaignStart) {api.hide();close();return}
      render(); root.querySelector(survival.dead||survival.sleeping ? '#sleep-saves' : dialogueFrame ? '#dialogue-saves' : inBank() ? '#bank-saves' : inService() ? '#service-saves' : navigationOpen ? '#nav-saves' : inSpace() ? '#space-saves' : machineryOpen ? '#power-saves' : equipmentOpen ? '#equipment-saves' : '#walk-saves')?.focus();
    },
  });
  function pause() { settleCampaignClock();stop(); state.paused = true; if (open) render(); }
  function draw() {
    if (!open) return;
    const canvas = root.querySelector('canvas'), context = canvas.getContext('2d');
    const scale = stage.getBoundingClientRect().width / 640 * Math.min(devicePixelRatio || 1, 3);
    const width = Math.round(640 * scale), height = Math.round(480 * scale);
    if (canvas.width !== width || canvas.height !== height) { canvas.width = width; canvas.height = height; }
    context.setTransform(width / 640, 0, 0, height / 480, 0, 0);
    context.fillStyle = '#101411'; context.fillRect(0, 0, 640, 480); context.imageSmoothingEnabled = false;
    const b = outsideShip() ? CITY_BOUNDS : WALK_BOUNDS;
    const camera=inCity()||inSurface()?groundCamera():{x:0,y:0};
    if(inCity()) {
      const map=activeCity().map;
      groundWindow(map,camera).forEach((row,y)=>row.forEach((cell,x)=>{
        context.drawImage(assets.images[assets.catalog.tileBanks[`city-${map.banks[Math.floor(cell.tile/16)]}`][cell.tile%16]],b.x+x*35,b.y+y*40,35,40);
      }));
      const anchor=activeCity().shipAnchor;
      context.save();context.beginPath();context.rect(b.x,b.y,b.width,b.height);context.clip();
      if(anchor){const x=b.x+(anchor.x-camera.x*28)*b.width/280,y=b.y+(anchor.y-7-camera.y*32)*b.height/192;
      context.fillRect(x,y,14*b.width/280,8*b.height/192);
      context.drawImage(assets.images[assets.catalog.images[!campaignPod.attached?'landed-ship-detached':'landed-ship']],x,y,14*b.width/280,8*b.height/192);}
      if(!campaignPod.attached&&!driving()&&campaignGround.podCityId===campaignGround.cityId) {
        const p=campaignPod.position;context.globalCompositeOperation='difference';
        context.drawImage(assets.images[assets.catalog.images[`pod-${campaignPod.heading}`]],b.x+(p.x-camera.x*28)*b.width/280,b.y+(p.y-7-camera.y*32)*b.height/192,7*b.width/280,8*b.height/192);
      }
      context.restore();
    } else if(inSurface()) {
      groundWindow(geometry().map,camera,true).forEach((row,y)=>row.forEach((cell,x)=>{
        context.drawImage(assets.images[assets.catalog.tileBanks.world[cell.tile]],b.x+x*35,b.y+y*30,35,30);
      }));
    } else {
      const key=inRoom() ? `room-${currentRoom().index.toString().padStart(2,'0')}${travel.lodging?.openMask ? `-doors-${travel.lodging.openMask}` : ''}` : campaignMode&&campaignPod&&!campaignPod.attached?'ship-section':'ship';
      context.drawImage(assets.images[assets.catalog.images[key]], b.x, b.y, b.width, b.height);
    }
    const sx = b.width / (inRoom() ? 140 : 280), sy = b.height / (inRoom() ? 96 : 192);
    if(inRoom())for(const actor of roomPopulation?.actors || []) {
      context.drawImage(assets.images[assets.catalog.images['room-npc']],b.x+actor.words[5]*sx,b.y+(actor.words[4]-7)*sy,7*sx,8*sy);
    }
    const relativeX=inSurface()?(state.position.x-camera.x*28+1120)%1120:state.position.x-camera.x*28;
    const relativeY=inSurface()?(state.position.y-camera.y*24+576)%576:state.position.y-camera.y*32;
    const x=b.x+relativeX*sx,y=b.y+(relativeY-7)*sy;
    context.strokeStyle = '#eab975'; context.lineWidth = 1;
    if(groundEncounter())drawGroundEncounter(context,groundEncounter(),assets.campaignContent.combat,b,combatAim);
    else {
      context.beginPath(); context.arc(x + 3 * sx, y + 4 * sy, 11, 0, Math.PI * 2); context.stroke();
      context.drawImage(assets.images[assets.catalog.images[inRoom() ? 'room-player' : inCity()||inSurface() ? driving()?`pod-${campaignPod.heading}`:'city-player' : 'player']], x, y, 7 * sx, 8 * sy);
    }
    root.dataset.x = state.position.x; root.dataset.y = state.position.y; root.dataset.paused = state.paused;
    const station = outsideShip() ? 0 : interactionAt(state.position);
    const accessible = storage();
    const bay = campaignMode && campaignStart ? bayAt() : null;
    const message = travelAvailable() ? t(inSurface()?'surfaceEnterHint':driving() ? serviceAvailable()?'podExchangeHint':'podDockHint' : !outsideShip()&&station===3 ? 'podDepartHint' : inRoom() ? 'roomExitHint' : availableRoom() ? 'roomDoorHint' : bankAvailable() ? 'bankDoorHint' : serviceAvailable() ? 'serviceDoorHint' : inCity() ? 'cityBoardHint' : 'shipExitHint') : outsideShip() ? t(state.paused ? 'walkPaused' : inRoom() ? 'roomWalkHint' : inSurface() ? 'surfaceWalkHint' : 'cityWalkHint') : bay !== null ? t('equipmentReached', { name:t(`equipment${bay}`) }) : accessible ? t('storageReached', { storage: t(accessible) }) : t(state.paused ? 'walkPaused' : station ? 'walkStation' : 'walkHint');
    const status = root.querySelector('#walk-status');
    const encounter=groundEncounter(),player=encounter?.combat?.actors[0];
    const statusMessage=outsideShip()&&roomMessage ? t(roomMessage) : encounter ? t(encounter.phase==='chase'?'groundChaseHint':state.paused?'groundCombatPaused':'groundCombatHint',
      {health:player?player[3]>>>8:0,enemies:encounter.combat?encounter.combat.actors.length-1:1}) : inRoom()&&encounters.counter?.service==='waiting' ? t('dialogueWaiting') :
      inRoom()&&travel.lodging?.rented ? t('lodgingRoomHint',{number:travel.lodging.rented}) :
      inRoom()&&isTavern(currentRoom()) ? t(encounters.roomState?.tavern.playerSeat!==null ? 'tavernSeated' : 'tavernHint') : message;
    if (status.textContent !== statusMessage) status.textContent = statusMessage;
    const button = root.querySelector('#walk-inventory');
    const label = t(accessible || 'inventoryTitle');
    if(button){if (button.textContent !== label) button.textContent = label;button.disabled=!!encounter}
    const engineering = root.querySelector('#walk-equipment');
    if (engineering) engineering.disabled = bay === null;
    const talk=root.querySelector('#walk-talk');if(talk)talk.disabled=!counterAvailable()||encounters.counter.service==='waiting';
    const airlock=root.querySelector('#walk-airlock');if(airlock) {
      airlock.disabled=!travelAvailable();
      const label=t(inSurface()?'enterCity':driving() ? serviceAvailable()?'enterService':'podDock' : !outsideShip()&&station===3 ? 'podDepart' : inRoom() ? 'leaveRoom' : availableRoom() ? 'enterRoom' : bankAvailable() ? 'enterBank' : serviceAvailable() ? 'enterService' : inCity() ? 'boardShip' : 'leaveShip');
      if(airlock.textContent!==label)airlock.textContent=label;
    }
    const podButton=root.querySelector('#walk-pod');
    if(podButton)podButton.disabled=!!encounter||(driving()?false:!boardPodAvailable());
    const cancelButton=root.querySelector('#combat-cancel-surrender');if(cancelButton)cancelButton.disabled=state.paused||!encounter?.combat.flags[48]||encounter.combat.mode!==1;
    root.dataset.encounter=encounter?.phase??'';
    root.dataset.combatX=player?.[1]??encounter?.chase.player.x??'';root.dataset.combatY=player?.[0]??encounter?.chase.player.y??'';
    root.dataset.enemies=encounter?.combat?encounter.combat.actors.length-1:encounter?1:0;
    root.dataset.combatHealth=player?player[3]>>>8:'';
    root.dataset.podX=campaignPod?.position?.x??'';root.dataset.podY=campaignPod?.position?.y??'';root.dataset.podHeading=campaignPod?.heading??'';
    root.dataset.transport=driving()?'pod':'foot';
    root.dataset.city=campaignGround?.cityId??'';root.dataset.cameraX=camera.x;root.dataset.cameraY=camera.y;
    root.dataset.heading=driving()?campaignPod.heading:'';
    root.dataset.scene=campaignMode ? travel.scene : 'ship';
    root.dataset.room=inRoom() ? currentRoom().index : '';
    root.dataset.occupants=inRoom() ? roomPopulation?.actors.length || 0 : 0;
    root.dataset.service=inRoom() ? encounters.counter?.service || '' : '';
    root.dataset.dialogue=dialogueFrame?.view.state ?? '';
    root.dataset.minutes = survival.minutes; root.dataset.sleeping = survival.sleeping; root.dataset.dead = survival.dead;
    root.dataset.system=campaignRegional?.shipLocation.systemId??'';root.dataset.world=campaignRegional?.shipLocation.worldId??'';root.dataset.flight=campaignFlight?.motion?.type??'';root.dataset.flightProgress=campaignFlight?.motion?.progress??'';
    const navigationButton=root.querySelector('#walk-navigation');if(navigationButton)navigationButton.disabled=outsideShip()||interactionAt(state.position)!==1;
    if(navigationOpen)drawNavigation(root.querySelector('#nav-chart'),liveCampaign(false),assets.campaignContent,navigationScale);
    if(inSpace())drawSpace(root.querySelector('#space-panel'),liveCampaign(false),t,timeLabel());
    root.dataset.space=campaignMode?campaignSpace?.view??'':'';
    root.dataset.contact=campaignMode?campaignSpace?.flags[40]??false:false;
    root.dataset.shipHull=campaignMode?campaignResources?.hull??'':'';root.dataset.shipGun=campaignMode?campaignResources?.guns.charge??'':'';
    root.dataset.shipRange=campaignMode?campaignSpace?.words[217]??'':'';root.dataset.shipHealth=campaignMode?campaignSpace?.words[216]??'':'';
    root.dataset.mode=campaignMode ? 'campaign' : 'walk';
    root.dataset.rest=condition.rest;root.dataset.nourishment=condition.nourishment;
    root.dataset.seed=campaignStart && campaignMode ? campaignStart.creation.seed : '';
    const clock = root.querySelector('#walk-clock'); if (clock) clock.textContent = timeLabel();
    const sleepClock = root.querySelector('#sleep-clock'); if (sleepClock) sleepClock.textContent = timeLabel();
    const rest = root.querySelector('#sleep-rest'); if (rest) rest.textContent = t('sleepRest', { value: condition.rest });
  }
  function render() {
    if (!open) return;
    if (checkpoints.active) { checkpoints.render(); return; }
    const focus = document.activeElement?.id;
    root.classList.toggle('city-walk',outsideShip());
    root.innerHTML = `<canvas aria-hidden="true"></canvas><header class="topline"><button id="walk-back" data-walk="back">← ${t('backShort')}</button><h1>${inRoom() ? t('roomTitle') : inSurface()?escapeHTML(campaignStart?assets.campaignContent.navigation.worlds.find(w=>w.id===campaignGround.worldId).name:''):inCity() ? escapeHTML(assets.cityMaps[campaignGround.cityId].name) : t('walkTitle')}</h1><button id="walk-language" data-walk="language">${t('language')}</button></header>
      <p class="walk-note">${campaignMode && campaignStart ? escapeHTML(t('campaignIdentity',{name:campaignStart.character.name,seed:campaignStart.creation.seed})) : t('walkNote')}</p><p id="walk-clock"></p><div id="walk-surface" tabindex="0" role="button" aria-label="${t(groundEncounter()?'groundEncounterControls':campaignMode ? 'campaignControls' : 'walkControls')}"></div>
      <p id="walk-status" role="status"></p><footer class="walk-actions"><button id="walk-pause" data-walk="pause">${t(state.paused ? 'walkResume' : 'walkPause')}</button><button id="walk-inventory" data-walk="inventory">${t('inventoryTitle')}</button>${campaignMode ? `${outsideShip() ? '' : `<button id="walk-equipment" data-walk="equipment" disabled>${t('equipmentTitle')}</button>`}<button id="walk-airlock" data-walk="airlock" disabled>${t(inCity() ? 'boardShip' : 'leaveShip')}</button>` : ''}<button id="walk-saves" data-walk="checkpoints">${t('shipSaves')}</button>${campaignMode ? '' : `<button id="walk-reset" data-walk="reset">${t('walkReset')}</button>`}<button id="walk-help" data-walk="help">${t('help')} ?</button></footer>`;
    if(campaignMode&&!outsideShip())root.querySelector('.walk-actions').insertAdjacentHTML('afterbegin',`<button id="walk-navigation" data-walk="navigation" disabled>${t('navigationTitle')}</button>`);
    if(campaignMode&&['city','surface'].includes(travel.scene)&&!campaignPod.attached)root.querySelector('.walk-actions').insertAdjacentHTML('afterbegin',`<button id="walk-pod" data-walk="pod">${t(driving()?'podPark':'podBoard')}</button>`);
    if(inRoom()&&encounters.counter)root.querySelector('.walk-actions').insertAdjacentHTML('afterbegin',`<button id="walk-talk" data-walk="talk">${t('dialogueTalk')}</button>`);
    if(groundEncounter()?.phase==='combat')root.querySelector('.walk-actions').insertAdjacentHTML('afterbegin',`<button id="combat-mode" data-walk="combat-mode" aria-pressed="${aimMode}">${t(aimMode?'groundAimMode':'groundMoveMode')}</button><button id="combat-cancel-surrender" data-walk="cancel-surrender">${t('groundCancelSurrender')}</button>`);
    if(groundEncounter())for(const id of ['walk-inventory','walk-airlock','walk-pod'])root.querySelector('#'+id)?.remove();
    if(dialogueFrame) {
      for(const child of root.children)child.inert=true;
      root.insertAdjacentHTML('beforeend',dialoguePanel({frame:dialogueFrame,assets,t,locale:locale(),message:dialogueError||spaceMessage,encounter:!!groundEncounter()||!!campaignSpace?.communication.conversation}));
      (root.querySelector('#dialogue-panel').querySelector(`[id="${focus||''}"]:not(:disabled)`)||root.querySelector('#dialogue-cancel')||root.querySelector('#dialogue-saves')).focus({preventScroll:true});
    } else if (survival.sleeping || survival.dead) {
      for (const child of root.children) child.inert = true;
      root.insertAdjacentHTML('beforeend', `<div class="help-shade"><section class="help sleep-panel" role="dialog" aria-modal="true" aria-labelledby="sleep-title"><h2 id="sleep-title">${t(survival.dead ? campaignSpace?.defeat?'shipDestroyed':'conditionDeath' : survival.forced ? 'exhaustedSleep' : 'sleeping')}</h2><p id="sleep-clock">${timeLabel()}</p><p id="sleep-rest">${t('sleepRest', { value: condition.rest })}</p><p>${t(survival.dead ? (campaignMode ? 'campaignDeath' : 'deathScope') : 'sleepHint')}</p>${survival.dead ? `${campaignMode ? `<button id="sleep-back" data-walk="back">${t('backShort')}</button>` : `<button id="sleep-restart" data-walk="restart">${t('restartWalk')}</button>`}<button id="sleep-saves" data-walk="checkpoints">${t('shipSaves')}</button>` : `<button id="sleep-pause" data-walk="sleep-pause">${t(state.paused ? 'walkResume' : 'walkPause')}</button><button id="sleep-wake" data-walk="wake" ${survival.forced ? 'disabled' : ''}>${t('wake')}</button>${campaignSpace&&!outsideShip()?`<button id="sleep-saves" data-walk="checkpoints">${t('shipSaves')}</button>`:''}`}</section></div>`);
      const panel = root.querySelector('.sleep-panel');
      (panel.querySelector(`#${focus || 'sleep-pause'}:not(:disabled)`) || panel.querySelector('button')).focus({ preventScroll: true });
    } else if (inBank()) {
      for(const child of root.children)child.inert=true;
      root.insertAdjacentHTML('beforeend',bankPanel({start:{...campaignStart,playerLocation:location()},cash:campaignDialogue.cash,economy:campaignEconomy,navigation:assets.campaignContent.navigation,draft:bankDraft,message:bankMessage,t}));
      (root.querySelector('#bank-panel').querySelector(`[id="${focus || ''}"]:not(:disabled)`) || root.querySelector(bankDraft ? '#bank-cancel' : '#bank-leave')).focus({preventScroll:true});
    } else if (inService()) {
      for(const child of root.children)child.inert=true;
      root.insertAdjacentHTML('beforeend',travel.scene==='colony' ? colonyPanel({state:liveCampaign(),content:assets.campaignContent,draft:colonyDraft,message:colonyMessage,t}) : travel.scene==='exchange' ? exchangePanel({state:liveCampaign(),content:assets.campaignContent,name:assets.cityMaps[campaignGround.cityId].name,tab:exchangeTab,draft:exchangeDraft,message:exchangeMessage,t}) : travel.scene==='depot' ? depotPanel({state:liveCampaign(),content:assets.campaignContent,geometry:activeCity(),name:assets.cityMaps[campaignGround.cityId].name,draft:depotDraft,message:depotMessage,t}) : cityServicePanel({service:travel.scene,name:assets.cityMaps[campaignGround.cityId].name,t}));
      (root.querySelector('#service-panel').querySelector(`[id="${focus || ''}"]:not(:disabled)`) || root.querySelector(colonyDraft ? '#colony-cancel' : exchangeDraft ? '#exchange-cancel' : depotDraft ? '#depot-cancel' : '#service-leave')).focus({preventScroll:true});
    } else if (help) {
      for (const child of root.children) child.inert = true;
      root.insertAdjacentHTML('beforeend', `<div class="help-shade"><section class="help" role="dialog" aria-modal="true" aria-labelledby="walk-help-title"><h2 id="walk-help-title">${t(inSpace()?'spaceTitle':groundEncounter()?'encounterDialogueTitle':'walkTitle')}</h2><p>${t(inSpace()?'spaceControls':groundEncounter()?'groundEncounterControls':campaignMode ? 'campaignControls' : 'walkControls')}</p><p>${t(inSpace()?'spaceHelp':groundEncounter()?'groundEncounterHelp':campaignMode ? 'campaignPlayScope' : 'walkScope')}</p><button id="walk-close-help" data-walk="close-help">${t('close')}</button></section></div>`);
      root.querySelector('#walk-close-help').focus();
    } else if (inSpace()) {
      for(const child of root.children)child.inert=true;
      root.insertAdjacentHTML('beforeend',spacePanel({state:liveCampaign(false),paused:state.paused,time:timeLabel(),message:spaceMessage,t}));
      (root.querySelector(`#space-panel [id="${focus||''}"]:not(:disabled)`)||root.querySelector('#space-surface')).focus({preventScroll:true});
    } else if (navigationOpen) {
      for(const child of root.children)child.inert=true;
      root.insertAdjacentHTML('beforeend',navigationPanel({state:liveCampaign(false),content:assets.campaignContent,scale:navigationScale,draft:navigationDraft,message:navigationMessage,paused:state.paused,time:timeLabel(),t,choice:navigationChoice}));
      (root.querySelector(`#navigation-panel [id="${focus||''}"]:not(:disabled)`)||root.querySelector('#nav-close')).focus({preventScroll:true});
    } else if (machineryOpen) {
      for(const child of root.children)child.inert=true;
      root.insertAdjacentHTML('beforeend',machineryPanel({resources:campaignResources,machinery:campaignMachinery,equipment:campaignEquipment,paused:state.paused,message:machineryMessage,time:timeLabel(),t}));
      (root.querySelector(`#power-panel [id="${focus||''}"]:not(:disabled)`)||root.querySelector('#power-close')).focus({preventScroll:true});
    } else if (equipmentOpen) {
      for (const child of root.children) child.inert = true;
      root.insertAdjacentHTML('beforeend', equipmentPanel({ view:inspectEquipment(campaignEquipment,state.position,equipmentOffset), engineering:campaignEngineering, resources:campaignResources, equipment:campaignEquipment, inventory, selected:equipmentSelected, moving:equipmentMoving, message:equipmentMessage, assets, t }));
      (root.querySelector('#equipment-panel').querySelector(`[id="${focus || ''}"]:not(:disabled)`) || root.querySelector(equipmentMoving ? '#equipment-cancel' : '#equipment-close')).focus({ preventScroll:true });
    } else if (inventoryOpen) {
      for (const child of root.children) child.inert = true;
      root.insertAdjacentHTML('beforeend', inventoryPanel({ cargo:campaignMode&&((!outsideShip()&&campaignPod.attached)||driving())?campaignPod?.cargo:null, inventory, condition, time: timeLabel(), storage: storage(), selected, message: inventoryMessage, assets, t }));
      (root.querySelector('#inventory-panel').querySelector(`[id="${focus || ''}"]:not(:disabled)`) || root.querySelector('#inventory-close')).focus({ preventScroll: true });
    } else if (focus) document.getElementById(focus)?.focus({ preventScroll: true });
    draw();
  }
  function advanceLiveGround(now,simulationPaused) {
    const oldPhase=groundEncounter()?.phase,oldScene=travel.scene;
    try {
      const campaign=liveCampaign(false);
      groundHost={...(groundHost??restoreCampaignGroundHost(campaign,groundWorld,assets.campaignContent)),campaign,exhausted:false};
      let move=state.held&&!firePointer,fire=!!groundEncounter()?.combat&&(firePointer||fireHeld)&&!!combatAim;
      let pointer=state.pointer??combatAim;
      if(keys.size) {
        let dx=0,dy=0;for(const key of keys){dx+=directions[key][0];dy+=directions[key][1]}
        move=!!(dx||dy);
        const encounter=groundEncounter(),p=encounter?.combat?{x:encounter.combat.actors[0][1],y:encounter.combat.actors[0][0]}:encounter?.chase.player;
        pointer=p?{x:Math.max(0,Math.min(279,p.x+(encounter.phase==='chase'?0:3)+Math.sign(dx)*2)),y:Math.max(0,Math.min(191,p.y-(encounter.phase==='chase'?0:3)+Math.sign(dy)*2))}:
          viewportPointer({x:state.position.x+3+Math.sign(dx)*(driving()?8:2),y:state.position.y-3+Math.sign(dy)*(driving()?8:2)});
      }
      if(fire)pointer=combatAim;
      const milliseconds=previous?Math.max(0,Math.min(60000,Math.floor(now)-Math.floor(previous))):0;
      const didTick=!simulationPaused&&groundHost.clock.elapsed+milliseconds>=50;
      const next=advanceGroundHost(groundHost,groundWorld,assets.campaignContent,milliseconds,
        {move,fire,cancelSurrender,pointer},{paused:simulationPaused});
      previous=now;
      const activity=`${survival.sleeping}/${survival.forced}/${survival.dead}`;
      const terminal=applyGroundHost(next);
      if(didTick)cancelSurrender=false;
      if(terminal||dialogueFrame||travel.scene!==oldScene){stop();state.paused=true}
      if(terminal||oldPhase!==groundEncounter()?.phase||travel.scene!==oldScene||activity!==`${survival.sleeping}/${survival.forced}/${survival.dead}`){stop();selected=null;render()}
    }catch(error){previous=now;roomMessage='groundEncounterUnavailable';stop();state.paused=true;render()}
  }
  function settleGroundClock() {
    if(!campaignMode||!['city','surface'].includes(travel.scene)||!previous||state.paused||dialogueFrame||inService()||checkpoints.active||help||equipmentOpen||inventoryOpen||survival.sleeping||survival.dead)return;
    advanceLiveGround(performance.now(),false);draw();
  }
  function settleCampaignClock() {settleGroundClock();settleAboardClock()}
  function loop(now) {
    if (!open) return;
    const framePrevious=previous;
    if(equipmentOpen&&!checkpoints.active&&!document.hidden) {
      const index=inspectEquipment(campaignEquipment,state.position,equipmentOffset).index;
      if(campaignEngineering.pendingFailures[index]!==31) {
        equipmentElapsed+=Math.max(0,Math.min(100,previous?now-previous:0));
        if(equipmentElapsed>=ENGINEERING_UPDATE_MS){engineeringAction({type:'tick',groupIndex:index});equipmentElapsed=0;render()}
      } else equipmentElapsed=0;
    } else equipmentElapsed=0;
    const before = `${survival.sleeping}/${survival.forced}/${survival.dead}`;
    const simulationPaused=state.paused||!!dialogueFrame||inService()||checkpoints.active||help||equipmentOpen||(inventoryOpen&&!survival.sleeping);
    const groundActive=campaignMode&&['city','surface'].includes(travel.scene)&&!survival.sleeping&&!survival.dead;
    if(groundActive) {
      advanceLiveGround(now,simulationPaused);
    } else {
      if(campaignMode&&campaignStart&&!outsideShip()) {
        const oldLocation=campaignRegional?.shipLocation,signature=spaceSignature();
        const advanced=advanceCampaignMachinery(liveCampaign(false),survival,previous?Math.max(0,Math.min(60000,Math.floor(now)-Math.floor(previous))):0,simulationPaused,assets.campaignContent);
        commitCampaign(advanced.state);survival=advanced.survival;previous=now;
        if(oldLocation?.cityId!==campaignRegional?.shipLocation.cityId||oldLocation?.worldId!==campaignRegional?.shipLocation.worldId)rebuildGround();
        if(advanced.cycles&&(machineryOpen||navigationOpen)||signature!==spaceSignature())render();
      } else survival=advanceSurvival(survival,previous?now-previous:0,simulationPaused);
      condition=survival.condition;
      if(campaignMode&&survival.dead&&condition.vigor===0&&campaignCombat&&!campaignCombat.defeat)
        campaignCombat={...campaignCombat,defeat:{reason:'conditionDeath',minutes:survival.minutes}};
      if(keys.size&&!state.paused&&!inSpace()) {
        let dx=0,dy=0;for(const key of keys){dx+=directions[key][0];dy+=directions[key][1]}
        state.held=!!(dx||dy);state.pointer={x:state.position.x+3+Math.sign(dx)*2,y:state.position.y-3+Math.sign(dy)*2};
      }
      if(!survival.sleeping&&!survival.dead&&!inSpace()&&!inService()&&!(inRoom()&&roomPopulation))state=advanceWalk(state,framePrevious?now-framePrevious:0,geometry());
    }
    if (before !== `${survival.sleeping}/${survival.forced}/${survival.dead}`) { stop(); selected = null; render(); }
    if(inRoom()&&roomPopulation&&!dialogueFrame&&!state.paused&&!survival.sleeping&&!survival.dead&&!checkpoints.active&&!help&&!inventoryOpen) {
      roomElapsed+=Math.max(0,Math.min(100,previous ? now-previous : 0));
      while(roomElapsed>=ROOM_TICK_MS) {
        if(keys.size) {
          let dx=0,dy=0;for(const key of keys){dx+=directions[key][0];dy+=directions[key][1]}
          state.pointer={x:state.position.x+3+Math.sign(dx)*2,y:state.position.y-3+Math.sign(dy)*2};
        }
        if(state.held&&encounters.counter&&(encounters.counter.service!=='idle'||(encounters.roomState.tavern?.playerSeat??null)!==null))counterAction({type:'cancel'});
        state=advanceWalk({...state,elapsed:0},ROOM_TICK_MS,geometry());
        if(encounters.counter) {
          if(!counterAction({type:'tick'})||dialogueFrame){render();break}
        } else {
          const next=tickRoomTraffic(currentRoom(),encounters.roomState,encounters.randomState,state.position);
          encounters={...encounters,randomState:next.randomState,roomState:next.state};
          roomPopulation={actors:next.state.actors,geometry:next.geometry};
        }
        roomElapsed-=ROOM_TICK_MS;
      }
    } else roomElapsed=0;
    previous = now;
    draw(); frame = requestAnimationFrame(loop);
  }
  function point(event) {
    const box = stage.getBoundingClientRect(), b = outsideShip() ? CITY_BOUNDS : WALK_BOUNDS;
    const camera=inCity()||inSurface()?groundCamera():{x:0,y:0};
    if(campaignMode&&['city','surface'].includes(travel.scene))return {x:Math.max(0,Math.min(279,Math.floor(((event.clientX-box.left)*640/box.width-b.x)*280/b.width))),
      y:Math.max(0,Math.min(191,Math.floor(((event.clientY-box.top)*480/box.height-b.y)*192/b.height)))};
    return { x: ((event.clientX - box.left) * 640 / box.width - b.x) * (inRoom() ? 140 : 280) / b.width+camera.x*28,
      y: ((event.clientY - box.top) * 480 / box.height - b.y) * (inRoom() ? 96 : 192) / b.height+camera.y*(inSurface()?24:32) };
  }
  function viewportPointer(pointer) {
    if(groundEncounter())return {x:Math.max(0,Math.min(279,Math.floor(pointer.x))),y:Math.max(0,Math.min(191,Math.floor(pointer.y)))};
    const camera=groundCamera(),height=inSurface()?576:768;
    return {x:Math.max(0,Math.min(279,Math.floor((pointer.x-camera.x*28+1120)%1120))),
      y:Math.max(0,Math.min(191,Math.floor((pointer.y-camera.y*(inSurface()?24:32)+height)%height)))};
  }
  const spacePoint=event=>{
    const box=root.querySelector('#space-surface').getBoundingClientRect();
    return {x:Math.max(-8,Math.min(8,Math.round(((event.clientX-box.left)/box.width-.5)*16))),
      y:Math.max(-8,Math.min(8,Math.round(((event.clientY-box.top)/box.height-.5)*16))),fire:true};
  };
  const spaceKeys=()=>{
    let x=0,y=0;for(const key of keys){x+=directions[key][0]*8;y+=directions[key][1]*8}
    spaceInput({x:Math.max(-8,Math.min(8,x)),y:Math.max(-8,Math.min(8,y)),fire:fireHeld});
  };
  root.addEventListener('pointerdown', event => {
    if(inSpace()&&(event.target.id==='space-surface'||event.target.id==='space-fire'||event.target.dataset.spaceX!==undefined)) {
      if(state.paused||tractorActive()||![0,2].includes(event.button)||activePointer!==null)return;
      event.preventDefault();keys.clear();event.target.focus();activePointer=event.pointerId;event.target.setPointerCapture(event.pointerId);
      spaceInput(event.target.id==='space-surface'?spacePoint(event):event.target.id==='space-fire'?{x:0,y:0,fire:true}:
        {x:Number(event.target.dataset.spaceX),y:Number(event.target.dataset.spaceY),fire:fireHeld});return;
    }
    if (event.target.id !== 'walk-surface' || (event.button!==0&&!(event.button===2&&groundEncounter()?.phase==='combat')) || state.paused || help || activePointer !== null) return;
    settleGroundClock();if(state.paused||survival.sleeping||survival.dead||dialogueFrame)return;
    event.preventDefault();keys.clear();event.target.focus();activePointer=event.pointerId;event.target.setPointerCapture(event.pointerId);
    firePointer=groundEncounter()?.phase==='combat'&&(aimMode||event.button===2);
    if(groundEncounter())combatAim=point(event);
    state = { ...state, pointer: point(event), held: true };
  });
  root.addEventListener('pointermove', event => {if(event.target.id==='walk-surface')settleGroundClock();if(inSpace()&&event.target.id==='space-surface'&&event.pointerId===activePointer){spaceInput(spacePoint(event));return}if(event.target.id==='walk-surface'&&groundEncounter())combatAim=point(event);if (event.pointerId === activePointer&&event.target.id==='walk-surface') state.pointer = point(event); });
  root.addEventListener('contextmenu',event=>{if(event.target.id==='space-surface'||event.target.id==='walk-surface'&&groundEncounter())event.preventDefault()});
  for (const name of ['pointerup', 'pointercancel', 'lostpointercapture']) root.addEventListener(name, event => {
    if(event.pointerId!==activePointer)return;
    if(event.target.id==='walk-surface')settleGroundClock();
    if(event.target.id.startsWith('space-')){activePointer=null;spaceKeys();return}
    name==='pointerup' ? releaseWalk() : stop();
  });
  root.addEventListener('change',event=>{if(navigationOpen&&event.target.id==='nav-destination'){settleCampaignClock();navigationChoice=event.target.value;state.paused=true;stop();render()}});
  root.addEventListener('keydown', event => {
    if (event.isComposing) return;
    if(event.target.id==='walk-surface')settleGroundClock();
    if(dialogueFrame) {
      if(event.key==='Escape'){event.preventDefault();if(!dialogueFrame.fault){dialogueAction({type:'cancel'});render()}}
      if(event.key==='Tab') {
        const buttons=[...root.querySelectorAll('#dialogue-panel button:not(:disabled)')],i=buttons.indexOf(document.activeElement);
        event.preventDefault();buttons[(i+(event.shiftKey ? -1 : 1)+buttons.length)%buttons.length].focus();
      }
      return;
    }
    if(inService()) {
      if(event.key==='Escape'){event.preventDefault();if(inBank()&&bankDraft){bankDraft=null;bankMessage='bankCancelled';render()}else if(exchangeDraft){exchangeDraft=null;exchangeMessage='';render()}else if(depotDraft){depotDraft=null;depotMessage='';render()}else leaveService()}
      if(event.key==='Tab') {
        const buttons=[...root.querySelectorAll(inBank() ? '#bank-panel button:not(:disabled),#bank-panel select' : '#service-panel button:not(:disabled)')];
        const index=buttons.indexOf(document.activeElement);event.preventDefault();
        buttons[(index+(event.shiftKey ? -1 : 1)+buttons.length)%buttons.length].focus();
      }
      return;
    }
    if (survival.sleeping || survival.dead) {
      if (event.key === 'Tab') {
        const buttons = [...root.querySelectorAll('.sleep-panel button:not(:disabled)')];
        const index = buttons.indexOf(document.activeElement); event.preventDefault();
        buttons[(index + (event.shiftKey ? -1 : 1) + buttons.length) % buttons.length].focus();
      }
      if (event.key === 'Escape' && survival.sleeping) { event.preventDefault(); finishSleep(); }
      return;
    }
    if (inventoryOpen) {
      if (event.key === 'Escape') {
        event.preventDefault();
        if (selected) { selected = null; inventoryMessage = 'selectionCancelled'; render(); }
        else closeInventory();
      }
      if (event.key === 'Tab') {
        const buttons = [...root.querySelectorAll('#inventory-panel button:not(:disabled)')];
        const index = buttons.indexOf(document.activeElement);
        event.preventDefault(); buttons[(index + (event.shiftKey ? -1 : 1) + buttons.length) % buttons.length].focus();
      }
      return;
    }
    if(navigationOpen) {
      if(event.key==='Escape'){event.preventDefault();if(navigationDraft){navigationDraft=null;render()}else {navigationOpen=false;pause();root.querySelector('#walk-navigation').focus()}}
      if(event.key==='Tab'){const buttons=[...root.querySelectorAll('#navigation-panel button:not(:disabled),#navigation-panel select:not(:disabled)')],i=buttons.indexOf(document.activeElement);event.preventDefault();buttons[(i+(event.shiftKey?-1:1)+buttons.length)%buttons.length].focus()}
      return;
    }
    if(machineryOpen) {
      if(event.key==='Escape'){event.preventDefault();closeMachinery()}
      if(event.key==='Tab') {
        const buttons=[...root.querySelectorAll('#power-panel button:not(:disabled)')],i=buttons.indexOf(document.activeElement);
        event.preventDefault();buttons[(i+(event.shiftKey?-1:1)+buttons.length)%buttons.length].focus();
      }
      return;
    }
    if (equipmentOpen) {
      if (event.key === 'Escape') {
        event.preventDefault();
        if (equipmentMoving) {equipmentMoving=false;equipmentMessage='selectionCancelled';render();root.querySelector('#equipment-move').focus()}
        else closeEquipment();
      }
      if (event.key === 'Tab') {
        const buttons = [...root.querySelectorAll('#equipment-panel button:not(:disabled)')];
        const index = buttons.indexOf(document.activeElement);
        event.preventDefault(); buttons[(index + (event.shiftKey ? -1 : 1) + buttons.length) % buttons.length].focus();
      }
      return;
    }
    if (help) {
      if (event.key === 'Tab') { event.preventDefault(); root.querySelector('#walk-close-help').focus(); }
      if (event.key === 'Escape') { event.preventDefault(); help = false; render(); root.querySelector(inSpace()?'#space-help':'#walk-help').focus(); }
      return;
    }
    if(inSpace()) {
      if(event.key==='Escape'){event.preventDefault();const menu=campaignSpace.tactical.record.menu;if(menu)spaceAction({type:'menu',menu:0});else openSpaceNavigation();render();return}
      if(event.key==='Tab'){const buttons=[...root.querySelectorAll('#space-panel button:not(:disabled),#space-surface')],i=buttons.indexOf(document.activeElement);event.preventDefault();buttons[(i+(event.shiftKey?-1:1)+buttons.length)%buttons.length].focus();return}
      if(event.target.id==='space-surface'&&!state.paused&&!tractorActive()) {
        if(directions[event.key]){event.preventDefault();keys.add(event.key);spaceKeys()}
        if(event.key===' '){event.preventDefault();fireHeld=true;spaceKeys()}
      }
      return;
    }
    if (event.key === 'Escape') { event.preventDefault(); api.hide(); close(); return; }
    if(groundEncounter()?.phase==='combat'&&event.target.id==='walk-surface') {
      if(event.key===' '){event.preventDefault();if(!state.paused&&combatAim)fireHeld=true;return}
      if(event.key.toLowerCase()==='s'){event.preventDefault();if(!state.paused)cancelSurrender=true;return}
    }
    if (event.target.id === 'walk-surface' && event.key === 'Enter' && travelAvailable()) {event.preventDefault();changeScene();return}
    if(event.target.id==='walk-surface'&&event.key==='Enter'&&counterAvailable()){event.preventDefault();requestCounter();return}
    if (event.target.id === 'walk-surface' && event.key === 'Enter' && campaignMode && bayAt() !== null) { event.preventDefault(); openEquipment(); return; }
    if (event.target.id === 'walk-surface' && (event.key === 'Enter' || event.key.toLowerCase() === 'i')) { event.preventDefault(); openInventory(); return; }
    if (event.target.id === 'walk-surface' && directions[event.key]) { event.preventDefault(); keys.add(event.key); }
  });
  root.addEventListener('keyup', event => {if(event.target.id==='walk-surface')settleGroundClock(); if(event.key===' '){fireHeld=false;firePointer=false}if (directions[event.key])keys.delete(event.key);if(inSpace()&&(directions[event.key]||event.key===' ')){spaceKeys();return}if(directions[event.key]&&!keys.size)releaseWalk(); });
  root.addEventListener('focusout', event => { if (event.target.id==='space-surface'||event.target.id==='walk-surface')settleCampaignClock();if (event.target.id === 'walk-surface'||event.target.id==='space-surface')stop(); });
  function openInventory() { if(groundEncounter())return;stop(); state.paused = true; inventoryOpen = true; selected = null; inventoryMessage = ''; render(); }
  function requestCounter() {
    if(!counterAvailable())return;
    stop();roomMessage='';
    if(counterAction({type:'request'})){state.paused=!!dialogueFrame;previous=0;roomElapsed=0}
    render();if(!dialogueFrame)root.querySelector('#walk-surface').focus();
  }
  function releaseWalk() {
    stop();
    if(!state.paused&&inRoom()&&isTavern(currentRoom())&&playerSeatAt(currentRoom(),state.position)!==null)requestCounter();
  }
  function podAction() {
    if(!campaignMode||!['city','surface'].includes(travel.scene)||groundEncounter()||survival.sleeping||survival.dead)return;
    try {
      const next=reduceCampaignGround(liveCampaign(),groundWorld,{type:driving()?'park':'board'});
      commitCampaign(next);restoreShip(next.ship);roomMessage='';
    }catch(error){roomMessage=error.message==='podExitBlocked'?'podExitBlocked':'podUnavailable';stop();state.paused=true}
    render();root.querySelector('#walk-surface').focus();
  }
  function changeScene() {
    if(!travelAvailable()||survival.sleeping||survival.dead)return;
    stop();
    roomMessage='';roomElapsed=0;
    if(inSurface()) {
      const next=reduceCampaignGround(liveCampaign(),groundWorld,{type:'enterCity'});
      commitCampaign(next);if(travel.scene==='city')campaignGround.camera=groundCameraAt(travel.cityPosition);restoreShip(next.ship);render();root.querySelector('#walk-surface').focus();return;
    }
    if(inRoom()) {
      campaignDialogue.flags[57]=false;
      encounters={...encounters,roomSeed:null,roomState:null,counter:null};roomPopulation=null;
      const position={...travel.cityPosition};travel={scene:'city',cityPosition:position};
      state={...createWalk(geometry()),position,paused:true};previous=0;survival={...survival,elapsed:0};
      render();root.querySelector('#walk-surface').focus();return;
    }
    const room=availableRoom();
    if(room) {
      let population;
      try {population=populateRoom(room,encounters.randomState)}
      catch {roomMessage='roomPopulationUnavailable';state.paused=true;render();return}
      roomPopulation=population;
      campaignDialogue={...campaignDialogue,flags:[...campaignDialogue.flags]};
      campaignDialogue.flags.fill(false,64,72); // Game18 fresh room entry.
      encounters={randomState:population.randomState,roomSeed:population.seed,roomState:initialRoomTraffic(population,room),counter:{service:'idle',conversation:null}};
      travel={scene:'room',cityPosition:{...state.position},roomPosition:{...room.spawn}};
      if(room.index===1)travel.lodging=initialLodging();
      state={...createWalk(room),paused:true};previous=0;survival={...survival,elapsed:0};
      render();root.querySelector('#walk-surface').focus();return;
    }
    const service=serviceAvailable();
    if(service) {
      bankDraft=null;bankMessage='';depotDraft=null;depotMessage='';
      if(service==='colony') {
        try {colonyAction({type:'enter'});colonyDraft=null;colonyMessage=''}
        catch {roomMessage='colonyUnavailable';state.paused=true;render();return}
      } else if(service==='exchange') {
        try {exchangeAction({type:'enter'});exchangeDraft=null;exchangeMessage='';exchangeTab='offers'}
        catch {roomMessage='exchangeEntryFailed';state.paused=true;render();return}
      } else travel={scene:service,cityPosition:{...state.position}};
      state.paused=true;previous=0;survival={...survival,elapsed:0};render();return;
    }
    if(driving()||(!outsideShip()&&interactionAt(state.position)===3)) {
      const next=reduceCampaignPod(liveCampaign(),activeCity().pod,{type:driving()?'dock':'depart'});
      commitCampaign(next);if(travel.scene==='city')campaignGround.camera=groundCameraAt(travel.cityPosition);restoreShip(next.ship);render();root.querySelector('#walk-surface').focus();return;
    }
    const exiting=!inCity();travel={scene:exiting ? 'city' : 'ship',cityPosition:null};
    state={...createWalk(geometry()),position:{...(exiting ? activeCity().spawn : SHIP_REENTRY)},paused:true};
    if(exiting)campaignGround.camera=groundCameraAt(state.position);
    previous=0;survival={...survival,elapsed:0};render();root.querySelector('#walk-surface').focus();
  }
  function leaveService() {
    if(travel.scene==='exchange')exchangeAction({type:'leave'});
    if(travel.scene==='colony')colonyAction({type:'leave'});
    colonyDraft=null;colonyMessage='';
    exchangeDraft=null;exchangeMessage='';depotDraft=null;depotMessage='';
    bankDraft=null;bankMessage='';
    stop();travel={scene:'city',cityPosition:{...state.position}};state.paused=true;
    previous=0;render();root.querySelector('#walk-surface').focus();
  }
  function closeInventory() { inventoryOpen = false; selected = null; inventoryMessage = ''; render(); root.querySelector('#walk-inventory').focus(); }
  function openEquipment() {
    if (!campaignMode || !campaignStart || bayAt() === null || survival.sleeping || survival.dead) return;
    stop(); state.paused=true; equipmentOpen=true; equipmentOffset=0; equipmentSelected=null; equipmentMoving=false;equipmentElapsed=0;engineeringAction({type:'enter',groupIndex:bayAt()});render();
  }
  function closeMachinery(){machineryOpen=false;state.paused=true;openEquipment()}
  function closeEquipment() { equipmentOpen=false; equipmentSelected=null; render(); root.querySelector('#walk-equipment').focus(); }
  function finishSleep() {
    if(campaignMode&&!outsideShip()&&campaignSpace){if(!spaceAction({type:'wake'}))return}
    else survival = wakeUp(survival);
    if (survival.sleeping || survival.dead) return;
    state.paused = true; inventoryOpen = true; inventoryMessage = 'wokeUp'; previous = 0;
    render(); root.querySelector('#inventory-sleep').focus();
  }
  root.addEventListener('change',event=>{
    if(inBank()&&bankDraft?.type==='transfer'&&event.target.id==='bank-destination') {
      bankDraft={...bankDraft,targetSystemId:event.target.value};bankMessage='';render();
    }
  });
  root.addEventListener('click', event => {
    const space=event.target.closest('button[data-space]');
    if(space&&inSpace()) {
      const action=space.dataset.space;
      if(action==='fire') {if(event.detail===0&&!state.paused){spaceInput({x:0,y:0,fire:true});spaceInput({x:0,y:0,fire:false})}return}
      settleCampaignClock();stop();
      if(action==='run'){state.paused=!state.paused;previous=state.paused?0:performance.now()}
      else if(action==='navigation')openSpaceNavigation();
      else if(action==='menu')spaceAction({type:'menu',menu:Number(space.dataset.menu)});
      else if(['laser','cannon','gun-off'].includes(action))spaceAction({type:'gun',firing:action!=='gun-off',focused:action!=='cannon'});
      else if(action==='shields')spaceAction({type:'shields',delta:Number(space.dataset.delta)});
      else if(action==='cloak')spaceAction({type:'cloak',enabled:!campaignMachinery.cloaked});
      else if(action==='jettison')spaceAction({type:'jettison',selection:Number(space.dataset.selection)});
      else if(action==='tractor'){if(spaceAction({type:'tractor'})){state.paused=false;previous=performance.now()}}
      else if(action==='comm')spaceAction({type:'comm'});
      render();return;
    }
    const power=event.target.closest('[data-power]');
    if(machineryOpen&&power) {
      try {
        settleCampaignClock();
        const type=power.dataset.power;
        const action=type==='shields'?{type,delta:Number(power.dataset.delta)}:{type,enabled:type==='guns'?!campaignResources.guns.powered:!campaignMachinery.cloaked};
        const next=reduceMachineryControl(liveCampaign(),action);commitCampaign(next);machineryMessage='';
      }catch(e){machineryMessage=e.message}
      render();return;
    }
    const depot=event.target.closest('[data-depot-service],[data-depot-units],[data-depot-action]');
    if(travel.scene==='depot'&&depot) {
      try {
        depotMessage='';
        if(depot.dataset.depotService)depotDraft={type:depot.dataset.depotService,units:1};
        else if(depot.dataset.depotAction==='cancel')depotDraft=null;
        else if(depot.dataset.depotAction==='confirm'&&depotDraft) {
          const next=reduceCampaignDepot(liveCampaign(),assets.campaignContent,activeCity(),depotDraft);
          commitCampaign(next);
          depotDraft=null;depotMessage='depotCompleted';
        } else if(depot.dataset.depotUnits&&depotDraft) {
          const offer=campaignDepotOffers(liveCampaign(),assets.campaignContent,activeCity()).find(o=>o.type===depotDraft.type);
          depotDraft={...depotDraft,units:Math.max(1,Math.min(offer.affordable,depot.dataset.depotUnits==='all'?offer.affordable:depotDraft.units+Number(depot.dataset.depotUnits)))};
        }
      } catch(error){depotMessage=['depotVehicleAbsent','depotCapacity','depotInsufficient'].includes(error.message)?error.message:'depotUnavailable'}
      render();return;
    }
    const ex=event.target.closest('[data-exchange-tab],[data-exchange-slot],[data-exchange-action],[data-cargo-container],[data-cargo-mode]');
    if(travel.scene==='exchange'&&ex) {
      try {
        exchangeMessage='';
        if(ex.dataset.cargoMode){exchangeDraft={type:'swap',podSlot:null,warehouseSlot:null}}
        else if(ex.dataset.cargoContainer){const container=ex.dataset.cargoContainer,slot=Number(ex.dataset.cargoSlot);exchangeDraft=exchangeDraft?.type==='swap'?{...exchangeDraft,[`${container}Slot`]:slot}:{type:container==='pod'?'store':'fetch',slot}}
        else if(ex.dataset.exchangeTab){exchangeTab=ex.dataset.exchangeTab;exchangeDraft=null}
        else if(ex.dataset.exchangeSlot!==undefined)exchangeDraft={type:exchangeTab==='offers'?'buy':'sell',slot:Number(ex.dataset.exchangeSlot)};
        else if(ex.dataset.exchangeAction==='cancel')exchangeDraft=null;
        else if(ex.dataset.exchangeAction==='confirm'&&exchangeDraft){exchangeAction(exchangeDraft);exchangeDraft=null;exchangeMessage='exchangeCompleted'}
      } catch(error){exchangeMessage=error.message}
      render();return;
    }
    const colony=event.target.closest('[data-colony-container],[data-colony-confirm]');
    if(travel.scene==='colony'&&colony) {
      try {
        colonyMessage='';
        if(colony.dataset.colonyConfirm==='cancel')colonyDraft=null;
        else if(colony.dataset.colonyConfirm==='confirm'&&colonyDraft){colonyAction(colonyDraft);colonyDraft=null;colonyMessage='colonyCompleted'}
        else if(colony.dataset.colonyContainer)colonyDraft={type:colony.dataset.colonyAction,container:colony.dataset.colonyContainer,slot:Number(colony.dataset.colonySlot)};
      }catch(error){colonyMessage=error.message}
      render();return;
    }
    const bankAction=event.target.closest('[data-bank-action]')?.dataset.bankAction;
    const bankStep=event.target.closest('[data-bank-step]')?.dataset.bankStep;
    if(inBank()&&(bankAction||bankStep)) {
      try {
        bankMessage='';
        if(['deposit','withdraw','transfer'].includes(bankAction))bankDraft={type:bankAction,amount:0,
          ...(bankAction==='transfer' ? {targetSystemId:campaignEconomy.accounts.find(a=>a.systemId!==location().systemId).systemId} : {})};
        else if(bankAction==='cancel'){bankDraft=null;bankMessage='bankCancelled'}
        else if(bankAction==='confirm'&&bankDraft) {
          const next=reduceCampaignBank(liveCampaign(),activeCity().map,bankDraft,assets.campaignContent);
          campaignDialogue=next.dialogue;campaignEconomy=next.economy;bankDraft=null;bankMessage='bankCompleted';
        } else if(bankStep&&bankDraft) {
          const available=availableBankFunds(campaignDialogue.cash,campaignEconomy,location().systemId,bankDraft.type);
          bankDraft={...bankDraft,amount:adjustBankAmount(bankDraft.amount,available,['all','clear'].includes(bankStep)?bankStep:Number(bankStep))};
        }
      } catch(error) {bankMessage=['bankInvalidAmount','bankInsufficient','bankInvalidDestination','bankOverflow'].includes(error.message)?error.message:'bankUnavailable'}
      render();return;
    }
    if(dialogueFrame) {
      const reply=event.target.closest('[data-dialogue-reply]'),sale=event.target.closest('[data-dialogue-sale]'),purchase=event.target.closest('[data-dialogue-purchase]'),item=event.target.closest('[data-dialogue-item]'),command=event.target.closest('button[data-dialogue]'),offer=event.target.closest('[data-dialogue-offer]');
      const input=sale ? {type:'sale',slot:Number(sale.dataset.dialogueSale)} : purchase ? {type:'purchase',slot:Number(purchase.dataset.dialoguePurchase)} : reply ? {type:'reply',slot:Number(reply.dataset.dialogueReply)} : item ? {type:'item',item:Number(item.dataset.dialogueItem)} : command ? {type:command.dataset.dialogue} :
        offer ? {type:'offer',direction:offer.dataset.dialogueOffer,step:Number(offer.dataset.step)} : null;
      if(input){dialogueAction(input);render();return}
    }
    const component = event.target.closest('[data-equipment-container]');
    if (equipmentOpen && component) {
      const slot=component.dataset.equipmentContainer==='carried' ? {container:'carried',index:Number(component.dataset.equipmentIndex)} :
        {container:'installed',unit:Number(component.dataset.equipmentRow),socket:Number(component.dataset.equipmentSocket)};
      if (equipmentMoving) {
        const view=inspectEquipment(campaignEquipment,state.position,equipmentOffset);
        engineeringAction({type:'exchange',groupIndex:view.index,from:equipmentSelected,to:slot});equipmentElapsed=0;
        equipmentMoving=false;equipmentSelected=slot;
      } else {equipmentSelected=slot;equipmentMessage=''}
      render(); return;
    }
    const slotButton = event.target.closest('[data-slot]');
    if (inventoryOpen && slotButton) {
      const slot = { container: slotButton.dataset.container, index: Number(slotButton.dataset.slot) };
      if (selected) {
        const next = transferItem(inventory, selected, slot, outsideShip() ? {x:0,y:0} : state.position);
        inventoryMessage = next === inventory ? 'selectionCancelled' : 'inventoryTransferred';
        inventory = next; selected = null;
      } else if (inventory[slot.container][slot.index]) { selected = slot; inventoryMessage = ''; }
      else inventoryMessage = 'inventoryEmpty';
      render(); return;
    }
    const nav=event.target.closest('[data-nav],[data-nav-scale]');
    if(navigationOpen&&nav) {
      settleCampaignClock();stop();navigationMessage='';
      try {
        if(nav.dataset.navScale){navigationScale=nav.dataset.navScale;navigationChoice=null;navigationDraft=null;state.paused=true}
        else if(nav.dataset.nav==='close'){navigationOpen=false;state.paused=true}
        else if(nav.dataset.nav==='cancel'){navigationDraft=null;state.paused=true}
        else if(nav.dataset.nav==='run'){state.paused=!state.paused;previous=state.paused?0:performance.now()}
        else if(nav.dataset.nav==='tactical'){if(spaceAction({type:'view',view:'tactical'}))navigationOpen=false}
        else if(nav.dataset.nav==='select'){const id=root.querySelector('#nav-destination').value,selected=navigationDestinations(liveCampaign(false),assets.campaignContent,navigationScale).find(d=>d.id===id);if(selected&&!selected.disabled){navigationDraft={id,action:selected.action};state.paused=true}}
        else if(['launch','warp','distress'].includes(nav.dataset.nav)){navigationDraft={action:{type:nav.dataset.nav}};state.paused=true}
        else {
          const action=nav.dataset.nav==='confirm'?navigationDraft?.action:{type:nav.dataset.nav};
          if(action){const next=reduceCampaignFlight(liveCampaign(false),assets.campaignContent,action);commitCampaign(next);navigationDraft=null;state.paused=true;rebuildGround();if(action.type==='warp'){navigationScale='system';if(inSpace())navigationOpen=false}}
        }
      }catch(error){navigationMessage=error.message;state.paused=true}
      render();return;
    }
    const action = event.target.closest('[data-walk]')?.dataset.walk;
    if (!action) return;
    settleCampaignClock();stop();
    if(action==='combat-mode'&&groundEncounter()?.phase==='combat'){aimMode=!aimMode;render();root.querySelector('#walk-surface').focus();return}
    if(action==='cancel-surrender'&&groundEncounter()?.phase==='combat'&&!state.paused){cancelSurrender=true;root.querySelector('#walk-surface').focus();return}
    if (action === 'checkpoints') {
      state.paused = true; survival = { ...survival, elapsed:0 }; selected = null;
      void checkpoints.show(); return;
    }
    if (action === 'sleep') { selected = null;if(campaignMode&&!outsideShip()&&campaignSpace){if(!spaceAction({type:'sleep'}))return}else survival = startSleep(survival); state.paused = false; previous = performance.now(); render(); return; }
    if (action === 'wake') { finishSleep(); return; }
    if (action === 'sleep-pause') { state.paused = !state.paused; previous = state.paused?0:performance.now(); render(); return; }
    if (action === 'restart' && !campaignMode) {
      inventory = createInventory(assets.shipInventory); condition = createCondition(assets.shipInventory.condition);
      survival = createSurvival(condition); state = createWalk(assets.shipWalk); inventoryOpen = false; selected = null; previous = 0;
      render(); root.querySelector('#walk-surface').focus(); return;
    }
    if (action === 'back') { api.hide(); close(); return; }
    if (action === 'language') { language(); return; }
    if ((action === 'leave-bank' || action === 'leave-service') && inService()) {leaveService();return}
    if(action==='power'&&equipmentOpen){equipmentOpen=false;equipmentMoving=false;equipmentSelected=null;machineryOpen=true;machineryMessage='';state.paused=true;survival={...survival,elapsed:0};render();return}
    if(action==='close-power'&&machineryOpen){closeMachinery();return}
    if(action==='power-run'&&machineryOpen){state.paused=!state.paused;previous=state.paused?0:performance.now();render();return}
    if(action==='navigation'&&campaignMode&&!outsideShip()&&interactionAt(state.position)===1){navigationOpen=true;navigationDraft=null;navigationMessage='';state.paused=true;survival={...survival,elapsed:0};render();return}
    if (action === 'equipment') { openEquipment(); return; }
    if(action==='pod'){podAction();return}
    if (action === 'airlock') {changeScene();return}
    if (action === 'talk') {requestCounter();return}
    if (action === 'close-equipment') { closeEquipment(); return; }
    if (action==='equipment-move' && equipmentOpen && equipmentSelected) {equipmentMoving=true;equipmentMessage='';render();return}
    if (action==='equipment-cancel' && equipmentOpen) {equipmentMoving=false;equipmentMessage='selectionCancelled';render();root.querySelector('#equipment-move').focus();return}
    if (equipmentOpen && ['equipment-next','equipment-previous'].includes(action)) {
      equipmentOffset=(equipmentOffset + (action==='equipment-next' ? 1 : 2)) % 3;
      equipmentSelected=null; equipmentMoving=false;equipmentElapsed=0;engineeringAction({type:'enter',groupIndex:inspectEquipment(campaignEquipment,state.position,equipmentOffset).index});render(); return;
    }
    if (action === 'inventory') { openInventory(); return; }
    if (action === 'close-inventory') { closeInventory(); return; }
    if (action === 'cancel-item') { selected = null; inventoryMessage = 'selectionCancelled'; }
    if (action === 'use-item' && inventoryOpen && selected?.container === 'carried') {
      const result = useCarriedItem(inventory, condition, selected.index);
      if (result) {
        inventory = result.inventory; condition = result.condition;
        survival = { ...survival, condition };
        inventoryMessage = result.restored ? (result.field === 'health' ? 'rapidhealApplied' : 'foodEaten') : 'itemUsedAtFull';
        const index = selected.index; selected = null; render(); root.querySelector(`#slot-carried-${index}`).focus(); return;
      }
    }
    if (action === 'reset' && !campaignMode) { state = createWalk(assets.shipWalk); previous = 0; }
    if (action === 'pause') { state.paused = !state.paused; previous = campaignMode&&(campaignSpace&&!outsideShip()||['city','surface'].includes(travel.scene))&&!state.paused?performance.now():0; }
    if (action === 'help') { help = true; state.paused = true; }
    if (action === 'close-help') help = false;
    render();
    if (action === 'reset' || (action === 'pause' && !state.paused)) root.querySelector('#walk-surface').focus();
    if (action === 'close-help') root.querySelector(inSpace()?'#space-help':'#walk-help').focus();
  });
  window.addEventListener('blur', () => { if (open) pause(); });
  function openSpaceNavigation() {
    if(spaceAction({type:'view',view:'ship'})){navigationOpen=true;navigationDraft=null;navigationMessage='';state.paused=true}
  }
  document.addEventListener('visibilitychange', () => { if (open && document.hidden) pause(); });
  function switchMode(next) {
    if(next===campaignMode)return;
    stop();
    sessions.set(campaignMode,{state,inventory,condition,survival});
    campaignMode=next;
    const saved=sessions.get(next);
    if(saved) ({state,inventory,condition,survival}=saved);
    else {
      state=createWalk(assets.shipWalk);inventory=createInventory(assets.shipInventory);
      condition=createCondition(assets.shipInventory.condition);survival=createSurvival(condition);
    }
    dialogueFrame=campaignMode?(campaignSpace?.communication.conversation?restoreCampaignShipCommunication(liveCampaign(false),assets.campaignContent):groundHost?.encounter?.activation.conversation??
      (inRoom()&&encounters?.counter?.conversation?restoreCampaignConversation(liveCampaign(),assets.campaignContent,currentRoom()).conversation:null)):null;
    state={...state,paused:true};previous=0;
  }
  function show() {
    if(open)return;
    open=true;root.hidden=false;background.inert=true;previous=0;render();
    root.querySelector('#walk-surface').focus();frame=requestAnimationFrame(loop);
  }
  const api = {
    get active() { return open; }, render,
    get hasCampaign() {return !!campaignStart},
    show() {switchMode(false);show()},
    showCampaign(value) {
      const next=value ? prepareCampaignRestore(value) : null;
      switchMode(true);
      if(next) {commitCampaign(next);restoreShip(next.ship);resetExchangeDraft()}
      if(campaignStart)show();
    },
    showCampaignSaves() {switchMode(true);state.paused=true;show();void checkpoints.show()},
    hide() { stop();state.paused=true; open = false; help = false; equipmentOpen=false; machineryOpen=false;navigationOpen=false; inventoryOpen = false; selected = null; root.hidden = true; background.inert = false; cancelAnimationFrame(frame); },
  };
  return api;
}
