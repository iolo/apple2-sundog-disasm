export function machineryPanel({resources:r,machinery,equipment,paused,message,time,t}) {
  const button=(id,action,label,disabled=false,extra='')=>`<button id="power-${id}" data-power="${action}" ${disabled?'disabled':''} ${extra}>${label}</button>`;
  return `<section id="power-panel" role="dialog" aria-modal="true" aria-labelledby="power-title">
    <header class="topline"><button id="power-close" data-walk="close-power">← ${t('backShort')}</button><h2 id="power-title">${t('powerTitle')}</h2><button id="power-language" data-walk="language">${t('language')}</button></header>
    <div class="power-content"><p id="power-resources">${t('powerResources',{hull:r.hull,fuel:r.fuel})} · ${time}</p>
    <section><h3>${t('equipment2')} <span>${t('powerCharge',{value:r.guns.charge})}</span></h3>
    ${button('guns','guns',t(r.guns.powered?'powerOff':'powerOn'),!r.guns.powered&&equipment[2].performance===0,`aria-pressed="${r.guns.powered}"`)} <span>${t('equipmentPerformance',{value:equipment[2].performance,max:16})}</span></section>
    <section><h3>${t('equipment4')} <span>${t('powerShieldCharge',{value:r.shields.charge,target:r.shields.targetCharge})}</span></h3>
    <div class="power-buttons">${button('shield-off','shields',t('powerOff'),false,'data-delta="-256"')}${button('shield-less','shields','-64',r.shields.targetCharge===0,'data-delta="-64"')}${button('shield-more','shields','+64',!r.fuel||equipment[4].performance===0||r.shields.targetCharge===255,'data-delta="64"')}${button('shield-full','shields',t('depotAll'),!r.fuel||equipment[4].performance===0||r.shields.targetCharge===255,'data-delta="256"')}</div></section>
    <section><h3>${t('powerCloaker')}</h3>${button('cloak','cloak',t(machinery.cloaked?'powerOff':'powerOn'),!machinery.cloaked&&!equipment[4].specialAvailable,`aria-pressed="${machinery.cloaked}"`)} <span>${t(equipment[4].specialAvailable?'powerCloakerAvailable':'machineryNoCloaker')}</span></section>
    <p id="power-message" role="status">${t(message||'powerHint')}</p></div>
    <footer class="power-actions"><button id="power-run" data-walk="power-run">${t(paused?'walkResume':'walkPause')}</button><button id="power-saves" data-walk="checkpoints">${t('shipSaves')}</button></footer></section>`;
}
