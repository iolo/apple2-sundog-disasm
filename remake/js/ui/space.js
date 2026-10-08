import { campaignShipSource } from '../core/campaign-space.js';
import { shipTacticalControls } from '../core/ship-tactical.js';
import { escapeHTML } from './html.js';

export function spacePanel({state,paused,time,message,t}) {
  const record=state.space.tactical.record,controls=shipTacticalControls(campaignShipSource(state),record);
  const pulling=record.wreck?.tractorSlot!==null&&!!record.wreck;
  const button=(id,label,action,disabled=false,extra='')=>`<button id="space-${id}" data-space="${action}" ${disabled||pulling?'disabled':''} ${extra}>${t(label)}</button>`;
  let commands;
  if(record.menu===1)commands=[['off','powerOff',-256],['less','spaceShieldLess',-64],['more','spaceShieldMore',64],['full','depotAll',256]].map(([id,label,delta])=>button(`shield-${id}`,label,'shields',delta>0&&(!state.resources.fuel||!state.equipment[4].performance||state.resources.shields.targetCharge===255),`data-delta="${delta}"`)).join('');
  else if(record.menu===2)commands=[1,2,3].map(selection=>button(`jettison-${selection}`,selection===3?'spaceBoth':`spacePod${selection}`,'jettison',selection===3?!record.jettisonChoices.every(Boolean):!record.jettisonChoices[selection-1],`data-selection="${selection}"`)).join('');
  else if(record.menu===3)commands=button('laser','spaceLaser','laser',!controls.guns,'aria-pressed="'+(record.firing&&record.focused)+'"')+button('cannon','spaceCannon','cannon',!controls.guns,'aria-pressed="'+(record.firing&&!record.focused)+'"')+button('gun-off','powerOff','gun-off',!record.firing)+button('tractor','spaceTractor','tractor',!controls.tractor)+button('fire','spaceFire','fire',!record.firing);
  else commands=button('shields','equipment4','menu',!controls.shields,'data-menu="1"')+button('guns','equipment2','menu',!controls.guns,'data-menu="3"')+button('bolts','spaceJettison','menu',!controls.jettison,'data-menu="2"')+button('comm','spaceComm','comm',!controls.comm)+button('cloak','powerCloaker','cloak',!controls.cloak,`aria-pressed="${state.machinery.cloaked}"`);
  return `<section id="space-panel" role="dialog" aria-modal="true" aria-labelledby="space-title">
    <header class="topline">${button('navigation','navigationTitle','navigation')}<h1 id="space-title">${t('spaceTitle')}</h1><button id="space-language" data-walk="language">${t('language')}</button></header>
    <p id="space-resources"></p><p id="space-clock">${time}</p>
    <div class="space-workspace"><canvas id="space-surface" width="320" height="200" tabindex="0" role="button" aria-label="${escapeHTML(t('spaceControls'))}"></canvas><div class="space-readings"><p id="space-contact"></p><p id="space-range"></p><p id="space-salvage"></p>${record.menu===2?state.pod.cargo.map((lot,i)=>`<p>${t('spacePod'+(i+1))}: ${lot?escapeHTML(t('cargo'+lot.commodityId.slice(6))):t('exchangeEmpty')}</p>`).join(''):`<div class="space-pan" aria-label="${t('spacePan')}">${[['up','↑',0,-8],['left','←',-8,0],['right','→',8,0],['down','↓',0,8]].map(([id,label,x,y])=>`<button id="space-pan-${id}" data-space-x="${x}" data-space-y="${y}" aria-label="${t('spacePan'+id)}" ${!record.firing||pulling?'disabled':''}>${label}</button>`).join('')}</div>`}</div></div>
    <p id="space-status" role="status">${message?t(message):t(pulling?'spacePulling':record.menu===2?'spaceBoltsArmed':record.firing?'spaceFireHint':'spaceHint')}</p>
    <div class="space-commands">${record.menu?button('menu-back','backShort','menu',false,'data-menu="0"'):''}${commands}</div>
    <footer class="space-actions"><button id="space-run" data-space="run">${t(paused?'walkResume':'walkPause')}</button><button id="space-saves" data-walk="checkpoints">${t('shipSaves')}</button><button id="space-help" data-walk="help">${t('help')} ?</button></footer>
  </section>`;
}

// Display-only contact symbols. Aim, visibility, damage and range come from
// the source owners; drawing never advances RNG or manufactures a hit.
export function drawSpace(panel,state,t,time) {
  if(!panel||!state.space?.tactical)return;
  const record=state.space.tactical.record,w=state.space.words,r=state.resources;
  const controls=shipTacticalControls(campaignShipSource(state),record),canvas=panel.querySelector('#space-surface'),c=canvas.getContext('2d');
  c.fillStyle='#080b09';c.fillRect(0,0,320,200);c.strokeStyle='#314135';c.lineWidth=1;
  for(const radius of [35,70,100]){c.beginPath();c.ellipse(160,100,radius*1.3,radius*.9,0,0,Math.PI*2);c.stroke()}
  c.strokeStyle=record.firing?'#eab975':'#969d8c';c.beginPath();c.moveTo(148,100);c.lineTo(172,100);c.moveTo(160,88);c.lineTo(160,112);c.stroke();
  if(controls.sensorTarget) {
    const x=160+((w[206]>>1)-256)*2,y=100+((w[205]>>1)-256)*2;
    const radius=Math.max(3,Math.min(18,130-w[217]));c.strokeStyle='#e6e1ce';
    c.beginPath();c.moveTo(x-radius,y);c.lineTo(x,y-radius/2);c.lineTo(x+radius,y);c.lineTo(x,y+radius/2);c.closePath();c.stroke();
  }
  if(record.wreck?.present){c.strokeStyle='#eab975';c.strokeRect(156,96,8,8)}
  panel.querySelector('#space-resources').textContent=t('spaceResources',{hull:r.hull,fuel:r.fuel,gun:r.guns.charge,shield:r.shields.charge,target:r.shields.targetCharge});
  panel.querySelector('#space-clock').textContent=time;
  panel.querySelector('#space-contact').textContent=t(controls.sensorTarget?'spaceTarget':'spaceContact',{value:record.sensors,health:w[216],type:w[214]+1});
  panel.querySelector('#space-range').textContent=controls.rangePlots&&record.contact?t('spaceRange',{value:w[217]}):t(state.space.flags[40]?'spaceContactPresent':'spaceClear');
  panel.querySelector('#space-salvage').textContent=record.wreck?.present?t('spaceWreck',{cargo:t(`cargo${record.wreck.lot.commodityId.slice(6)}`)}):'';
}
