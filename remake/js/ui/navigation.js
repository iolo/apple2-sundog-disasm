import { currentShipLocation,warpRequirement } from '../core/regional-world.js';
import { flightMode,flightOrbit,sublightDuration } from '../core/campaign-flight.js';
import { escapeHTML } from './html.js';

export function navigationDestinations(state,content,scale) {
  const ship=currentShipLocation(state),mode=flightMode(state);
  if(scale==='star')return content.navigation.systems.filter(s=>s.id!==ship.systemId).map(s=>({id:s.id,name:s.name,action:{type:'setWarp',systemId:s.id},detail:warpRequirement(state.start.systems,ship.systemId,s.id),disabled:warpRequirement(state.start.systems,ship.systemId,s.id)>255}));
  if(scale==='system')return [...content.navigation.worlds.filter(w=>content.navigation.systems.find(s=>s.id===ship.systemId).worldIds.includes(w.id)).map(w=>({id:w.id,name:w.name,action:{type:'sublight',worldId:w.id},detail:sublightDuration(ship.orbit,flightOrbit(state,content,w.id)),disabled:mode==='landed'||ship.worldId===w.id&&ship.orbit.angle===flightOrbit(state,content,w.id).angle&&ship.orbit.radius===w.orbitalRadius})),...Array.from({length:16},(_,i)=>({id:`point-${i}`,name:String(i+1),action:{type:'sublight',angle:i*16},detail:sublightDuration(ship.orbit,{angle:i*16,radius:43}),disabled:mode==='landed'||ship.worldId===null&&ship.orbit.angle===i*16&&ship.orbit.radius===43}))];
  return [...content.economy.cities,...(state.regional.colonyPosition?[content.economy.colonyCity]:[])].filter(c=>c.worldId===ship.worldId).map(c=>({id:c.id,name:c.name,action:{type:mode==='landed'?'cityFlight':'land',cityId:c.id},detail:mode==='landed'?20:5,disabled:c.id===ship.cityId||c.id!==content.exchange.worlds.find(w=>w.id===ship.worldId)?.capitalCityId&&!state.equipment[5].specialAvailable}));
}

export function navigationPanel({state,content,scale='system',draft=null,message='',paused,time,t,choice=null}) {
  const ship=currentShipLocation(state),mode=flightMode(state),motion=state.flight.motion,warp=state.resources.warp;
  const system=content.navigation.systems.find(s=>s.id===ship.systemId).name,world=content.navigation.worlds.find(w=>w.id===ship.worldId)?.name;
  const destinations=navigationDestinations(state,content,scale),busy=!!motion;
  const option=draft?.id&&destinations.find(d=>d.id===draft.id),target=option?option.name:t(`nav${draft?.action?.type??'Destination'}`);
  return `<div class="help-shade"><section id="navigation-panel" role="dialog" aria-modal="true" aria-labelledby="navigation-title">
    <header class="topline"><button id="nav-close" data-nav="close">← ${t('backShort')}</button><h1 id="navigation-title">${t('navigationTitle')}</h1><button id="nav-language" data-walk="language">${t('language')}</button></header>
    <p id="nav-location">${escapeHTML([system,world,t(`nav${mode}`)].filter(Boolean).join(' · '))}</p>
    <p id="nav-resources">${t('navResources',{fuel:state.resources.fuel,charge:warp.charge,target:warp.targetCharge})} · ${time}</p>
    <nav class="nav-scales" aria-label="${t('navScale')}">${['star','system','planet'].map(s=>`<button id="nav-scale-${s}" data-nav-scale="${s}" aria-pressed="${scale===s}" ${s==='planet'&&!ship.worldId?'disabled':''}>${t(`nav${s}`)}</button>`).join('')}</nav>
    <div class="nav-workspace"><canvas id="nav-chart" aria-hidden="true" width="320" height="250"></canvas><div class="nav-destinations">${draft?`<h2>${escapeHTML(target)}</h2><p>${option?t(scale==='star'?'navChargeNeeded':'navEta',{value:option.detail}):t('navReview')}</p><button id="nav-cancel" data-nav="cancel">${t('bankCancel')}</button><button id="nav-confirm" data-nav="confirm">${t('bankConfirm')}</button>`:`<label for="nav-destination">${t('navDestination')}</label><select id="nav-destination" size="6" ${busy?'disabled':''}>${destinations.map(d=>`<option value="${d.id}" ${d.id===(destinations.some(d=>d.id===choice&&!d.disabled)?choice:destinations.find(d=>!d.disabled)?.id)?'selected':''} ${d.disabled?'disabled':''}>${scale==='system'&&d.id.startsWith('point-')?t('navPoint',{value:d.name}):escapeHTML(d.name)} · ${scale==='star'?d.detail:t('navListTime',{value:d.detail})}</option>`).join('')}</select><button id="nav-select" data-nav="select" ${busy||!destinations.some(d=>!d.disabled)?'disabled':''}>${t('navReviewButton')}</button>`}</div></div>
    <p id="nav-status" role="status">${message?t(message):motion?t('navTravelling',{name:t(`nav${motion.type}`),value:motion.duration-motion.progress}):state.flight.refuelAt!==null?t('navRescueEta',{value:state.flight.refuelAt-state.ship.minutes}):warp.charging?t(warp.charge>=warp.targetCharge?'navWarpReady':'navCharging'):t(state.flight.lastEvent??'navHint')}</p>
    <div class="nav-commands">${mode==='landed'?`<button id="nav-launch" data-nav="launch" ${busy||draft?'disabled':''}>${t('navlaunch')}</button>`:''}<button id="nav-warp" data-nav="warp" ${busy||draft||mode==='landed'||!warp.charging||warp.charge<warp.targetCharge?'disabled':''}>${t('navwarp')}</button><button id="nav-cancel-warp" data-nav="cancelWarp" ${!warp.charging||draft?'disabled':''}>${t('navCancelWarp')}</button>${motion?.type==='sublight'?`<button id="nav-halt" data-nav="halt">${t('navhalt')}</button>`:mode!=='landed'?`<button id="nav-distress" data-nav="distress" ${state.flight.refuelAt!==null||draft?'disabled':''}>${t('navdistress')}</button>`:''}</div>
    <footer class="nav-actions"><button id="nav-run" data-nav="run">${t(paused?'walkResume':'walkPause')}</button><button id="nav-saves" data-walk="checkpoints">${t('shipSaves')}</button></footer>
  </section></div>`;
}

export function drawNavigation(canvas,state,content,scale) {
  if(!canvas)return;const c=canvas.getContext('2d'),ship=currentShipLocation(state),w=320,h=250;
  c.fillStyle='#101411';c.fillRect(0,0,w,h);c.strokeStyle='#314135';c.fillStyle='#d2bfa0';c.font='12px Mulmaru';
  const labels=[];
  const mark=(x,y,label,current=false)=>{
    c.fillStyle=current?'#eab975':'#b0b6a5';c.beginPath();c.arc(x,y,current?4:2,0,Math.PI*2);c.fill();
    const width=c.measureText(label).width,candidates=[[x+6,y-5],[x+6,y+14],[x+6,y-22],[x-width-6,y-5],[x-width-6,y+14],[x+6,y+29]];
    const [lx,ly]=candidates.find(([a,b])=>a>=3&&a+width<=w-3&&b>=14&&b<h-3&&!labels.some(r=>a<r.x+r.w+3&&a+width+3>r.x&&b-12<r.y+3&&b+3>r.y-12))??[Math.max(3,Math.min(w-width-3,x+6)),Math.max(14,Math.min(h-3,y-5))];
    labels.push({x:lx,y:ly,w:width});c.fillText(label,lx,ly);
  };
  if(scale==='star') {
    const systems=state.start.systems,minX=Math.min(...systems.map(s=>s.position.x)),maxX=Math.max(...systems.map(s=>s.position.x)),minY=Math.min(...systems.map(s=>s.position.y)),maxY=Math.max(...systems.map(s=>s.position.y));
    const pos=s=>({x:18+(s.position.x-minX)*220/(maxX-minX||1),y:24+(s.position.y-minY)*198/(maxY-minY||1)}),from=systems.find(s=>s.id===ship.systemId);
    for(const s of systems)if(s.id!==from.id&&warpRequirement(systems,from.id,s.id)<=255){const a=pos(from),b=pos(s);c.beginPath();c.moveTo(a.x,a.y);c.lineTo(b.x,b.y);c.stroke()}
    for(const s of systems){const p=pos(s);mark(p.x,p.y,content.navigation.systems.find(n=>n.id===s.id).name,s.id===ship.systemId)}
  } else if(scale==='system') {
    const orbit=o=>({x:160+Math.cos(o.angle*Math.PI/128)*o.radius*2.6,y:125+Math.sin(o.angle*Math.PI/128)*o.radius*2.6});
    c.beginPath();c.arc(160,125,43*2.6,0,2*Math.PI);c.stroke();mark(160,125,'+');
    for(let i=0;i<16;i++){const p=orbit({angle:i*16,radius:43});mark(p.x,p.y,String(i+1))}
    for(const world of content.navigation.worlds.filter(w=>content.navigation.systems.find(s=>s.id===ship.systemId).worldIds.includes(w.id))){const p=orbit(flightOrbit(state,content,world.id));mark(p.x,p.y,world.name)}
    const p=orbit(ship.orbit);mark(p.x,p.y,'◆',true);
  } else {
    for(const marker of content.ground.surfaceWalk.cities.filter(c=>c.worldId===ship.worldId)){const city=content.economy.cities.find(c=>c.id===marker.cityId);mark(12+marker.position.x*7,12+marker.position.y*9,city.name,ship.cityId===city.id)}
    if(ship.worldId==='world-01'&&state.regional.colonyPosition){const p=state.regional.colonyPosition;mark(12+p.x*7,12+p.y*9,content.economy.colonyCity.name,ship.cityId==='city-60')}
  }
}
