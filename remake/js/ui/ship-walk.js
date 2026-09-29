import { createWalk, advanceWalk, interactionAt } from '../core/ship-walk.js';
import { createInventory, storageAt, transferItem } from '../core/inventory.js';
import { inventoryPanel } from './inventory.js';
import { createCondition, useCarriedItem } from '../core/condition.js';
import { createSurvival, advanceSurvival, startSleep, wakeUp } from '../core/survival.js';
import { checkpointCodec, openCheckpointStore, CHECKPOINT_LIMIT } from '../core/checkpoints.js';
import { campaignSaveCodec, openCampaignStore, CAMPAIGN_LIMIT } from '../core/campaign-saves.js';
import { checkpointScreen } from './checkpoints.js';
import { escapeHTML } from './html.js';
import { equipmentBayAt, inspectEquipment, exchangeEquipment } from '../core/equipment.js';
import { equipmentPanel } from './equipment.js';
import { canBoardShip, cityCamera, SHIP_REENTRY } from '../core/city-walk.js';
import { cityWindow } from '../core/city-map.js';
import { atCityBank } from '../core/city-doors.js';
import { bankPanel } from './bank.js';
import { roomAt, canLeaveRoom } from '../core/room-walk.js';
import { populateRoom } from '../core/room-actors.js';

export const WALK_BOUNDS = { x: 32, y: 46, width: 640, height: 384 };
const CITY_BOUNDS={x:145,y:126,width:350,height:240};
export function shipWalkScreen({ stage, background, assets, t, language, close }) {
  const root = document.createElement('section'); root.id = 'walk-screen'; root.hidden = true; stage.append(root);
  let state = createWalk(assets.shipWalk), open = false, frame, previous = 0, help = false, activePointer = null;
  let inventory = createInventory(assets.shipInventory), inventoryOpen = false, selected = null, inventoryMessage = '';
  let condition = createCondition(assets.shipInventory.condition);
  let survival = createSurvival(condition);
  let campaignMode=false, campaignStart=null;
  let campaignEquipment=null;
  let travel={scene:'ship',cityPosition:null};
  let encounters=null,roomPopulation=null,roomMessage='';
  const inCity=()=>campaignMode&&['city','bank'].includes(travel.scene);
  const inBank=()=>campaignMode&&travel.scene==='bank';
  const inRoom=()=>campaignMode&&travel.scene==='room';
  const outsideShip=()=>inCity()||inRoom();
  const currentRoom=()=>roomAt(assets.cityGeometry.rooms,assets.cityGeometry.map,travel.cityPosition);
  const availableRoom=()=>inCity()&&!inBank() ? roomAt(assets.cityGeometry.rooms,assets.cityGeometry.map,state.position) : null;
  const bankAvailable=()=>inCity()&&!inBank()&&atCityBank(assets.cityGeometry.map,state.position);
  const geometry=()=>inRoom() ? roomPopulation?.geometry || currentRoom() : inCity() ? assets.cityGeometry : assets.shipWalk;
  const bayAt=()=>outsideShip() ? null : equipmentBayAt(state.position);
  const storage=()=>outsideShip() ? null : storageAt(state.position);
  const travelAvailable=()=>campaignMode&&campaignStart&&!inBank()&&(inRoom() ? canLeaveRoom(currentRoom(),state.position) : inCity() ? bankAvailable()||availableRoom()||canBoardShip(assets.cityGeometry,state.position) : interactionAt(state.position)===4);
  let equipmentOpen=false, equipmentOffset=0, equipmentSelected=null;
  let equipmentMoving=false, equipmentMessage='';
  const sessions=new Map();
  const campaignCodec=campaignSaveCodec(assets.campaignContent,assets.shipWalk,assets.cityGeometry);
  const campaignKeys = Object.fromEntries(['checkpointTitle','checkpointScope','checkpointHint','checkpointLoadOnly',
    'checkpointSaved','checkpointDeleted','checkpointLoaded','checkpointImported','checkpointExported',
    'invalidCheckpoint','replaceCheckpointConfirm','deleteCheckpointConfirm','loadCheckpointConfirm']
    .map(key=>[key,key.replace('checkpoint','campaign').replace('Checkpoint','Campaign')]));
  const timeLabel = () => t('gameTime', { day: Math.floor(survival.minutes / 1440), hour: String(Math.floor(survival.minutes / 60) % 24).padStart(2, '0'), minute: String(survival.minutes % 60).padStart(2, '0') });
  const keys = new Set();
  const directions = { ArrowLeft: [-1, 0], ArrowRight: [1, 0], ArrowUp: [0, -1], ArrowDown: [0, 1] };
  const stop = () => { keys.clear(); activePointer = null; state = { ...state, held: false, pointer: null, elapsed: 0 }; };
  const codec = checkpointCodec(assets.shipWalk);
  const selectedCodec=()=>campaignMode ? campaignCodec : codec;
  const liveShip=()=>({position:outsideShip() ? SHIP_REENTRY : state.position,inventory,condition,minutes:survival.minutes});
  function restoreShip(next) {
    if(campaignMode)roomPopulation=inRoom()&&encounters.roomSeed!==null ? populateRoom(currentRoom(),encounters.roomSeed) : null;
    roomMessage='';
    stop();state={...createWalk(geometry()),position:inRoom() ? travel.roomPosition : inCity() ? travel.cityPosition : next.position,paused:true};
    inventory=next.inventory;condition=next.condition;survival={...createSurvival(condition),minutes:next.minutes};
    inventoryOpen=false;selected=null;equipmentOpen=false;help=false;previous=0;
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
      if (survival.sleeping || survival.forced || survival.dead) throw new Error('invalidCheckpoint');
      if(campaignMode) {
        if(!campaignStart)throw new Error('invalidCampaign');
        return {start:campaignStart,ship:codec.snapshot(liveShip()),equipment:campaignEquipment,encounters,
          travel:inRoom() ? {scene:'room',cityPosition:travel.cityPosition,roomPosition:state.position} : {scene:travel.scene,cityPosition:inCity() ? state.position : null}};
      }
      return codec.snapshot(liveShip());
    },
    restore: value => {
      const next=selectedCodec().snapshot(value); // Validate before replacing live state.
      if(campaignMode) {campaignStart=next.start;campaignEquipment=next.equipment;travel=next.travel;encounters=next.encounters;restoreShip(next.ship)}
      else restoreShip(next);
    },
    close: () => {
      if(campaignMode && !campaignStart) {api.hide();close();return}
      render(); root.querySelector(survival.dead ? '#sleep-saves' : inBank() ? '#bank-saves' : '#walk-saves').focus();
    },
  });
  function pause() { stop(); state.paused = true; if (open) render(); }
  function draw() {
    if (!open) return;
    const canvas = root.querySelector('canvas'), context = canvas.getContext('2d');
    const scale = stage.getBoundingClientRect().width / 640 * Math.min(devicePixelRatio || 1, 3);
    const width = Math.round(640 * scale), height = Math.round(480 * scale);
    if (canvas.width !== width || canvas.height !== height) { canvas.width = width; canvas.height = height; }
    context.setTransform(width / 640, 0, 0, height / 480, 0, 0);
    context.fillStyle = '#101411'; context.fillRect(0, 0, 640, 480); context.imageSmoothingEnabled = false;
    const b = outsideShip() ? CITY_BOUNDS : WALK_BOUNDS;
    const camera=inCity() ? cityCamera(state.position) : {x:0,y:0};
    if(inCity()) {
      const map=assets.cityMaps[campaignStart.shipLocation.cityId];
      cityWindow(map,camera).forEach((row,y)=>row.forEach((cell,x)=>{
        context.drawImage(assets.images[assets.catalog.tileBanks[`city-${cell.bank}`][cell.index]],b.x+x*35,b.y+y*40,35,40);
      }));
      const anchor=assets.cityGeometry.shipAnchor;
      context.save();context.beginPath();context.rect(b.x,b.y,b.width,b.height);context.clip();
      const x=b.x+(anchor.x-camera.x*28)*b.width/280,y=b.y+(anchor.y-7-camera.y*32)*b.height/192;
      context.fillRect(x,y,14*b.width/280,8*b.height/192);
      context.drawImage(assets.images[assets.catalog.images['landed-ship']],x,y,14*b.width/280,8*b.height/192);
      context.restore();
    } else context.drawImage(assets.images[assets.catalog.images[inRoom() ? `room-${currentRoom().index.toString().padStart(2,'0')}` : 'ship']], b.x, b.y, b.width, b.height);
    const sx = b.width / (inRoom() ? 140 : 280), sy = b.height / (inRoom() ? 96 : 192);
    if(inRoom())for(const actor of roomPopulation?.actors || []) {
      context.drawImage(assets.images[assets.catalog.images['room-npc']],b.x+actor.words[5]*sx,b.y+(actor.words[4]-7)*sy,7*sx,8*sy);
    }
    const x = b.x + (state.position.x-camera.x*28) * sx, y = b.y + (state.position.y-7-camera.y*32) * sy;
    context.strokeStyle = '#eab975'; context.lineWidth = 1;
    context.beginPath(); context.arc(x + 3 * sx, y + 4 * sy, 11, 0, Math.PI * 2); context.stroke();
    context.drawImage(assets.images[assets.catalog.images[inRoom() ? 'room-player' : inCity() ? 'city-player' : 'player']], x, y, 7 * sx, 8 * sy);
    root.dataset.x = state.position.x; root.dataset.y = state.position.y; root.dataset.paused = state.paused;
    const station = outsideShip() ? 0 : interactionAt(state.position);
    const accessible = storage();
    const bay = campaignMode && campaignStart ? bayAt() : null;
    const message = travelAvailable() ? t(inRoom() ? 'roomExitHint' : availableRoom() ? 'roomDoorHint' : bankAvailable() ? 'bankDoorHint' : inCity() ? 'cityBoardHint' : 'shipExitHint') : outsideShip() ? t(state.paused ? 'walkPaused' : inRoom() ? 'roomWalkHint' : 'cityWalkHint') : bay !== null ? t('equipmentReached', { name:t(`equipment${bay}`) }) : accessible ? t('storageReached', { storage: t(accessible) }) : t(state.paused ? 'walkPaused' : station ? 'walkStation' : 'walkHint');
    const status = root.querySelector('#walk-status');
    const statusMessage=inCity()&&roomMessage ? t(roomMessage) : message;
    if (status.textContent !== statusMessage) status.textContent = statusMessage;
    const button = root.querySelector('#walk-inventory');
    const label = t(accessible || 'inventoryTitle');
    if (button.textContent !== label) button.textContent = label;
    const engineering = root.querySelector('#walk-equipment');
    if (engineering) engineering.disabled = bay === null;
    const airlock=root.querySelector('#walk-airlock');if(airlock) {
      airlock.disabled=!travelAvailable();
      const label=t(inRoom() ? 'leaveRoom' : availableRoom() ? 'enterRoom' : bankAvailable() ? 'enterBank' : inCity() ? 'boardShip' : 'leaveShip');
      if(airlock.textContent!==label)airlock.textContent=label;
    }
    root.dataset.scene=campaignMode ? travel.scene : 'ship';
    root.dataset.room=inRoom() ? currentRoom().index : '';
    root.dataset.occupants=inRoom() ? roomPopulation?.actors.length || 0 : 0;
    root.dataset.minutes = survival.minutes; root.dataset.sleeping = survival.sleeping; root.dataset.dead = survival.dead;
    root.dataset.mode=campaignMode ? 'campaign' : 'walk';
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
    root.innerHTML = `<canvas aria-hidden="true"></canvas><header class="topline"><button id="walk-back" data-walk="back">← ${t('backShort')}</button><h1>${inRoom() ? t('roomTitle') : inCity() ? escapeHTML(assets.cityMaps[campaignStart.shipLocation.cityId].name) : t('walkTitle')}</h1><button id="walk-language" data-walk="language">${t('language')}</button></header>
      <p class="walk-note">${campaignMode && campaignStart ? escapeHTML(t('campaignIdentity',{name:campaignStart.character.name,seed:campaignStart.creation.seed})) : t('walkNote')}</p><p id="walk-clock"></p><div id="walk-surface" tabindex="0" role="button" aria-label="${t(campaignMode ? 'campaignControls' : 'walkControls')}"></div>
      <p id="walk-status" role="status"></p><footer class="walk-actions"><button id="walk-pause" data-walk="pause">${t(state.paused ? 'walkResume' : 'walkPause')}</button><button id="walk-inventory" data-walk="inventory">${t('inventoryTitle')}</button>${campaignMode ? `${outsideShip() ? '' : `<button id="walk-equipment" data-walk="equipment" disabled>${t('equipmentTitle')}</button>`}<button id="walk-airlock" data-walk="airlock" disabled>${t(inCity() ? 'boardShip' : 'leaveShip')}</button>` : ''}<button id="walk-saves" data-walk="checkpoints">${t('shipSaves')}</button>${campaignMode ? '' : `<button id="walk-reset" data-walk="reset">${t('walkReset')}</button>`}<button id="walk-help" data-walk="help">${t('help')} ?</button></footer>`;
    if (survival.sleeping || survival.dead) {
      for (const child of root.children) child.inert = true;
      root.insertAdjacentHTML('beforeend', `<div class="help-shade"><section class="help sleep-panel" role="dialog" aria-modal="true" aria-labelledby="sleep-title"><h2 id="sleep-title">${t(survival.dead ? 'conditionDeath' : survival.forced ? 'exhaustedSleep' : 'sleeping')}</h2><p id="sleep-clock">${timeLabel()}</p><p id="sleep-rest">${t('sleepRest', { value: condition.rest })}</p><p>${t(survival.dead ? (campaignMode ? 'campaignDeath' : 'deathScope') : 'sleepHint')}</p>${survival.dead ? `${campaignMode ? `<button id="sleep-back" data-walk="back">${t('backShort')}</button>` : `<button id="sleep-restart" data-walk="restart">${t('restartWalk')}</button>`}<button id="sleep-saves" data-walk="checkpoints">${t('shipSaves')}</button>` : `<button id="sleep-pause" data-walk="sleep-pause">${t(state.paused ? 'walkResume' : 'walkPause')}</button><button id="sleep-wake" data-walk="wake" ${survival.forced ? 'disabled' : ''}>${t('wake')}</button>`}</section></div>`);
      const panel = root.querySelector('.sleep-panel');
      (panel.querySelector(`#${focus || 'sleep-pause'}:not(:disabled)`) || panel.querySelector('button')).focus({ preventScroll: true });
    } else if (inBank()) {
      for(const child of root.children)child.inert=true;
      root.insertAdjacentHTML('beforeend',bankPanel({start:campaignStart,navigation:assets.campaignContent.navigation,t}));
      (root.querySelector('#bank-panel').querySelector(`[id="${focus || ''}"]`) || root.querySelector('#bank-leave')).focus({preventScroll:true});
    } else if (help) {
      for (const child of root.children) child.inert = true;
      root.insertAdjacentHTML('beforeend', `<div class="help-shade"><section class="help" role="dialog" aria-modal="true" aria-labelledby="walk-help-title"><h2 id="walk-help-title">${t('walkTitle')}</h2><p>${t(campaignMode ? 'campaignControls' : 'walkControls')}</p><p>${t(campaignMode ? 'campaignPlayScope' : 'walkScope')}</p><button id="walk-close-help" data-walk="close-help">${t('close')}</button></section></div>`);
      root.querySelector('#walk-close-help').focus();
    } else if (equipmentOpen) {
      for (const child of root.children) child.inert = true;
      root.insertAdjacentHTML('beforeend', equipmentPanel({ view:inspectEquipment(campaignEquipment,state.position,equipmentOffset), inventory, selected:equipmentSelected, moving:equipmentMoving, message:equipmentMessage, assets, t }));
      (root.querySelector('#equipment-panel').querySelector(`[id="${focus || ''}"]:not(:disabled)`) || root.querySelector(equipmentMoving ? '#equipment-cancel' : '#equipment-close')).focus({ preventScroll:true });
    } else if (inventoryOpen) {
      for (const child of root.children) child.inert = true;
      root.insertAdjacentHTML('beforeend', inventoryPanel({ inventory, condition, time: timeLabel(), storage: storage(), selected, message: inventoryMessage, assets, t }));
      (root.querySelector('#inventory-panel').querySelector(`[id="${focus || ''}"]:not(:disabled)`) || root.querySelector('#inventory-close')).focus({ preventScroll: true });
    } else if (focus) document.getElementById(focus)?.focus({ preventScroll: true });
    draw();
  }
  function loop(now) {
    if (!open) return;
    const before = `${survival.sleeping}/${survival.forced}/${survival.dead}`;
    survival = advanceSurvival(survival, previous ? now - previous : 0, state.paused || inBank() || checkpoints.active || help || equipmentOpen || (inventoryOpen && !survival.sleeping));
    condition = survival.condition;
    if (before !== `${survival.sleeping}/${survival.forced}/${survival.dead}`) { stop(); selected = null; render(); }
    if (keys.size && !state.paused) {
      let dx = 0, dy = 0;
      for (const key of keys) { dx += directions[key][0]; dy += directions[key][1]; }
      state.held = !!(dx || dy);
      state.pointer = { x: state.position.x + 3 + Math.sign(dx) * 2, y: state.position.y - 3 + Math.sign(dy) * 2 };
    }
    if (!survival.sleeping && !survival.dead && !inBank()) state = advanceWalk(state, previous ? now - previous : 0, geometry());
    previous = now;
    draw(); frame = requestAnimationFrame(loop);
  }
  function point(event) {
    const box = stage.getBoundingClientRect(), b = outsideShip() ? CITY_BOUNDS : WALK_BOUNDS;
    const camera=inCity() ? cityCamera(state.position) : {x:0,y:0};
    return { x: ((event.clientX - box.left) * 640 / box.width - b.x) * (inRoom() ? 140 : 280) / b.width+camera.x*28,
      y: ((event.clientY - box.top) * 480 / box.height - b.y) * (inRoom() ? 96 : 192) / b.height+camera.y*32 };
  }
  root.addEventListener('pointerdown', event => {
    if (event.target.id !== 'walk-surface' || event.button !== 0 || state.paused || help || activePointer !== null) return;
    event.preventDefault(); keys.clear(); activePointer = event.pointerId;
    event.target.setPointerCapture(event.pointerId); event.target.focus();
    state = { ...state, pointer: point(event), held: true };
  });
  root.addEventListener('pointermove', event => { if (event.pointerId === activePointer) state.pointer = point(event); });
  for (const name of ['pointerup', 'pointercancel', 'lostpointercapture']) root.addEventListener(name, event => { if (event.pointerId === activePointer) stop(); });
  root.addEventListener('keydown', event => {
    if (event.isComposing) return;
    if(inBank()) {
      if(event.key==='Escape'){event.preventDefault();leaveBank()}
      if(event.key==='Tab') {
        const buttons=[...root.querySelectorAll('#bank-panel button')];
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
      if (event.key === 'Escape') { event.preventDefault(); help = false; render(); root.querySelector('#walk-help').focus(); }
      return;
    }
    if (event.key === 'Escape') { event.preventDefault(); api.hide(); close(); return; }
    if (event.target.id === 'walk-surface' && event.key === 'Enter' && travelAvailable()) {event.preventDefault();changeScene();return}
    if (event.target.id === 'walk-surface' && event.key === 'Enter' && campaignMode && bayAt() !== null) { event.preventDefault(); openEquipment(); return; }
    if (event.target.id === 'walk-surface' && (event.key === 'Enter' || event.key.toLowerCase() === 'i')) { event.preventDefault(); openInventory(); return; }
    if (event.target.id === 'walk-surface' && directions[event.key]) { event.preventDefault(); keys.add(event.key); }
  });
  root.addEventListener('keyup', event => { if (directions[event.key]) { keys.delete(event.key); if (!keys.size) stop(); } });
  root.addEventListener('focusout', event => { if (event.target.id === 'walk-surface') stop(); });
  function openInventory() { stop(); state.paused = true; inventoryOpen = true; selected = null; inventoryMessage = ''; render(); }
  function changeScene() {
    if(!travelAvailable()||survival.sleeping||survival.dead)return;
    stop();
    roomMessage='';
    if(inRoom()) {
      encounters={...encounters,roomSeed:null};roomPopulation=null;
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
      encounters={randomState:population.randomState,roomSeed:population.seed};
      travel={scene:'room',cityPosition:{...state.position},roomPosition:{...room.spawn}};
      state={...createWalk(room),paused:true};previous=0;survival={...survival,elapsed:0};
      render();root.querySelector('#walk-surface').focus();return;
    }
    if(bankAvailable()) {
      travel={scene:'bank',cityPosition:{...state.position}};
      state.paused=true;previous=0;survival={...survival,elapsed:0};render();return;
    }
    const exiting=!inCity();travel={scene:exiting ? 'city' : 'ship',cityPosition:null};
    state={...createWalk(geometry()),position:{...(exiting ? assets.cityGeometry.spawn : SHIP_REENTRY)},paused:true};
    previous=0;survival={...survival,elapsed:0};render();root.querySelector('#walk-surface').focus();
  }
  function leaveBank() {
    stop();travel={scene:'city',cityPosition:{...state.position}};state.paused=true;
    previous=0;render();root.querySelector('#walk-surface').focus();
  }
  function closeInventory() { inventoryOpen = false; selected = null; inventoryMessage = ''; render(); root.querySelector('#walk-inventory').focus(); }
  function openEquipment() {
    if (!campaignMode || !campaignStart || bayAt() === null || survival.sleeping || survival.dead) return;
    stop(); state.paused=true; equipmentOpen=true; equipmentOffset=0; equipmentSelected=null; equipmentMoving=false;equipmentMessage='';render();
  }
  function closeEquipment() { equipmentOpen=false; equipmentSelected=null; render(); root.querySelector('#walk-equipment').focus(); }
  function finishSleep() {
    survival = wakeUp(survival);
    if (survival.sleeping || survival.dead) return;
    state.paused = true; inventoryOpen = true; inventoryMessage = 'wokeUp'; previous = 0;
    render(); root.querySelector('#inventory-sleep').focus();
  }
  root.addEventListener('click', event => {
    const component = event.target.closest('[data-equipment-container]');
    if (equipmentOpen && component) {
      const slot=component.dataset.equipmentContainer==='carried' ? {container:'carried',index:Number(component.dataset.equipmentIndex)} :
        {container:'installed',unit:Number(component.dataset.equipmentRow),socket:Number(component.dataset.equipmentSocket)};
      if (equipmentMoving) {
        const view=inspectEquipment(campaignEquipment,state.position,equipmentOffset);
        const result=exchangeEquipment(campaignEquipment,inventory,state.position,view.index,equipmentSelected,slot);
        campaignEquipment=result.equipment;inventory=result.inventory;equipmentMessage=result.message;
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
    const action = event.target.closest('[data-walk]')?.dataset.walk;
    if (!action) return;
    stop();
    if (action === 'checkpoints') {
      state.paused = true; survival = { ...survival, elapsed:0 }; selected = null;
      void checkpoints.show(); return;
    }
    if (action === 'sleep') { selected = null; survival = startSleep(survival); state.paused = false; previous = 0; render(); return; }
    if (action === 'wake') { finishSleep(); return; }
    if (action === 'sleep-pause') { state.paused = !state.paused; previous = 0; render(); return; }
    if (action === 'restart' && !campaignMode) {
      inventory = createInventory(assets.shipInventory); condition = createCondition(assets.shipInventory.condition);
      survival = createSurvival(condition); state = createWalk(assets.shipWalk); inventoryOpen = false; selected = null; previous = 0;
      render(); root.querySelector('#walk-surface').focus(); return;
    }
    if (action === 'back') { api.hide(); close(); return; }
    if (action === 'language') { language(); return; }
    if (action === 'leave-bank' && inBank()) {leaveBank();return}
    if (action === 'equipment') { openEquipment(); return; }
    if (action === 'airlock') {changeScene();return}
    if (action === 'close-equipment') { closeEquipment(); return; }
    if (action==='equipment-move' && equipmentOpen && equipmentSelected) {equipmentMoving=true;equipmentMessage='';render();return}
    if (action==='equipment-cancel' && equipmentOpen) {equipmentMoving=false;equipmentMessage='selectionCancelled';render();root.querySelector('#equipment-move').focus();return}
    if (equipmentOpen && ['equipment-next','equipment-previous'].includes(action)) {
      equipmentOffset=(equipmentOffset + (action==='equipment-next' ? 1 : 2)) % 3;
      equipmentSelected=null; equipmentMoving=false;equipmentMessage='';render(); return;
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
    if (action === 'pause') { state.paused = !state.paused; previous = 0; }
    if (action === 'help') { help = true; state.paused = true; }
    if (action === 'close-help') help = false;
    render();
    if (action === 'reset' || (action === 'pause' && !state.paused)) root.querySelector('#walk-surface').focus();
    if (action === 'close-help') root.querySelector('#walk-help').focus();
  });
  window.addEventListener('blur', () => { if (open) pause(); });
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
      const next=value ? campaignCodec.snapshot(value) : null;
      switchMode(true);
      if(next) {campaignStart=next.start;campaignEquipment=next.equipment;travel=next.travel;encounters=next.encounters;restoreShip(next.ship)}
      if(campaignStart)show();
    },
    showCampaignSaves() {switchMode(true);state.paused=true;show();void checkpoints.show()},
    hide() { stop();state.paused=true; open = false; help = false; equipmentOpen=false; inventoryOpen = false; selected = null; root.hidden = true; background.inert = false; cancelAnimationFrame(frame); },
  };
  return api;
}
