// Declared power/condition fixtures exercise controlled phases and edge cases.
// The depot regression separately covers ordinary purchases, driving and power use.
async browserPage => {
  const browser=browserPage.context().browser(),checks=[],errors=[];
  const context=await browser.newContext({viewport:{width:1280,height:720}});
  const page=await context.newPage();
  page.on('pageerror',e=>errors.push(e.message));page.on('dialog',d=>d.accept());
  const assert=(ok,name)=>{if(!ok)throw Error(name);checks.push(name)};
  const ready=()=>page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
  const settled=()=>page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
  const state=()=>page.locator('#walk-screen').evaluate(el=>({...el.dataset}));
  const exportGame=async()=>{
    await page.locator(await page.locator('#power-panel').count()?'#power-saves':await page.locator('#equipment-panel').count()?'#equipment-saves':'#walk-saves').click();await settled();
    const pending=page.waitForEvent('download');await page.locator('#export-checkpoint').click();
    const download=await pending;let text='';
    for await(const part of await download.createReadStream())text+=part;
    await settled();await page.locator('#checkpoint-back').click();return JSON.parse(text);
  };
  const move=async(from,to)=>{
    await page.locator(from).click();await page.locator('#equipment-move').click();await page.locator(to).click();
  };
  const rating=()=>page.locator('.equipment-rating').innerText();
  let fixture=0;
  const importValue=async value=>{
    // Make a fixture file without accessing application state. The CLI sandbox
    // has no Node Buffer; download a Blob, then use the ordinary import control.
    const pending=page.waitForEvent('download');
    await page.evaluate(value=>{
      const url=URL.createObjectURL(new Blob([JSON.stringify(value)],{type:'application/json'}));
      const link=document.createElement('a');link.href=url;link.download='fixture.json';link.click();
      setTimeout(()=>URL.revokeObjectURL(url),1000);
    },value);
    const path=`output/playwright/remake/equipment-import-${++fixture}.json`;
    await (await pending).saveAs(path);
    await page.locator('#checkpoint-file').setInputFiles(path);await settled();
  };
  const openPower=async()=>{await page.locator('#walk-equipment').click();await page.locator('#equipment-power').click()};
  const resumeFor=async ms=>{await page.locator('#power-run').click();await page.clock.runFor(ms)};
  const load=async value=>{
    const selector=await page.locator('#power-panel').count()?'#power-saves':await page.locator('#equipment-panel').count()?'#equipment-saves':await page.locator('#sleep-saves').count()?'#sleep-saves':'#walk-saves';
    await page.locator(selector).click();await settled();await importValue(value);await page.locator('#checkpoint-back').click();
  };
  try {
    await page.addInitScript(()=>localStorage.setItem('sundog.locale','en'));await page.clock.install({time:new Date('2026-10-03T00:00:00Z')});await page.clock.pauseAt(new Date('2026-10-03T00:00:01Z'));
    await page.goto('http://127.0.0.1:8000/');await ready();
    const fixture=await page.evaluate(async()=>{
      const [{loadAssets},{campaignSaveCodec},{createCharacter}]=await Promise.all([import('/js/render/assets.js'),import('/js/core/campaign-saves.js'),import('/js/core/character.js')]);
      const a=await loadAssets(),codec=campaignSaveCodec(a.campaignContent,a.shipWalk,a.cityGeometry),s=codec.create({...createCharacter(),name:'Power fixture'},12345);
      s.ship.position={x:109,y:67};s.resources.fuel=16;s.pod.cargo=[{commodityId:'cargo-01',quality:7,originWorld:'world-01',pricePaid:0},null];return codec.make(s,0);
    });
    await page.locator('#campaign-saves').click();await settled();await importValue(fixture);await page.locator('#checkpoint-back').click();await openPower();
    assert(await page.locator('#power-cloak').isDisabled(),'Cloaker cannot activate without a working special component');
    await page.locator('#power-guns').click();await page.locator('#power-shield-full').click();
    const enabled=await exportGame();assert(enabled.version===24&&enabled.scope==='ground-encounters-1'&&enabled.state.resources.guns.powered&&enabled.state.resources.shields.targetCharge===255,'Version24 saves active gun and shield controls');
    await resumeFor(300);const first=await exportGame();
    assert(first.state.machinery.phase===1&&first.state.ship.minutes===enabled.state.ship.minutes+1&&first.state.resources.fuel===12,'First power phase advances the clock once and pays gun charging fuel');
    assert(first.state.resources.guns.charge===Math.min(255,(enabled.state.equipment[2].performance+1)*16),'Gun charge follows actual installed performance');
    await page.clock.runFor(1000);assert(JSON.stringify((await exportGame()).state)===JSON.stringify(first.state),'Saving and paused power inspection stop resource and clock updates');
    await resumeFor(300);const second=await exportGame();assert(second.state.machinery.phase===2&&second.state.resources.fuel===8&&second.state.resources.shields.charge===enabled.state.equipment[4].performance*8,'Second phase charges shields and pays maintenance');
    await page.locator('#power-saves').click();await settled();await page.locator('#save-checkpoint-0').click();await settled();await page.reload();await ready();await page.locator('#campaign-saves').click();await settled();await page.locator('#load-checkpoint-0').click();await settled();await page.locator('#checkpoint-back').click();
    assert(JSON.stringify((await exportGame()).state)===JSON.stringify(second.state),'Fresh reload preserves the partial phase, charges and fuel exactly');
    await openPower();await resumeFor(1300);const refueled=await exportGame();
    assert(refueled.state.pod.cargo[0]===null&&refueled.state.resources.fuel===255&&refueled.state.resources.shields.charge===255,'Running machinery automatically consumes the attached auxiliary load at depletion');
    assert(JSON.stringify(refueled.state.economy)===JSON.stringify(second.state.economy)&&JSON.stringify(refueled.state.encounters)===JSON.stringify(second.state.encounters),'Power and automatic refueling change no money or landed RNG');
    await page.locator('#power-guns').click();await page.locator('#power-shield-off').click();await resumeFor(1050);const off=await exportGame();
    assert(!off.state.resources.guns.powered&&off.state.resources.guns.charge<255&&off.state.resources.shields.charge===0&&off.state.resources.fuel===255,'Disabled guns discharge and zero-target shields fall without further fuel cost');
    for(const lang of ['en','ko']) {
      if(await page.locator('html').getAttribute('lang')!==lang)await page.locator('#power-language').click();
      for(const [width,height] of [[1280,720],[640,480],[390,844],[844,390]]) {
        await page.setViewportSize({width,height});await page.clock.runFor(100);await page.waitForFunction(()=>Math.abs(document.querySelector('#stage').getBoundingClientRect().width-Math.min(innerWidth,innerHeight*4/3))<1);
        assert(await page.locator('#power-panel').evaluate(root=>{const box=document.querySelector('#stage').getBoundingClientRect();return [...root.querySelectorAll('button,p,h2,h3,footer')].every(el=>{const b=el.getBoundingClientRect();return b.left>=box.left-1&&b.right<=box.right+1&&b.top>=box.top-1&&b.bottom<=box.bottom+1&&el.scrollWidth<=el.clientWidth+1})&&root.querySelector('.power-content').getBoundingClientRect().bottom<=root.querySelector('footer').getBoundingClientRect().top}),`${lang} machinery controls fit ${width}x${height}`);
      }
    }
    await page.screenshot({path:'output/playwright/remake/machinery-ko.png'});await page.setViewportSize({width:1280,height:720});await page.clock.runFor(100);await page.locator('#power-language').click();
    await page.locator('#power-close').focus();await page.keyboard.press('Shift+Tab');assert(await page.locator('#power-saves').evaluate(el=>el===document.activeElement),'Keyboard focus remains inside the machinery panel');
    const bad=structuredClone(off);bad.state.machinery.phase=4;await load(bad);assert(JSON.stringify((await exportGame()).state)===JSON.stringify(off.state),'Invalid phase import leaves active resources and state unchanged');
    const legacy=structuredClone(fixture);legacy.version=19;delete legacy.state.combat;delete legacy.state.regional;delete legacy.state.flight;delete legacy.state.ground;delete legacy.state.pod?.occupied;legacy.scope='landed-failures-1';delete legacy.state.machinery;await load(legacy);
    assert(JSON.stringify((await exportGame()).state)===JSON.stringify(fixture.state),'Version19 imports with an empty power phase and unchanged cargo/resources');
    const damaged=structuredClone(fixture);damaged.state.ship.inventory.carried=[0,0,0,0];
    const g=damaged.state.equipment[2];g.units=g.units.map((u,i)=>({components:i===0?[...g.spares]:[0,0,0,0],performance:i===0?4:0}));g.performance=4;g.specialAvailable=false;damaged.state.resources.guns={charge:200,powered:true};
    await load(damaged);await page.locator('#walk-equipment').click();await move('#equipment-slot-0-0','#equipment-carried-0');
    const failed=await exportGame();assert(failed.state.resources.guns.charge===0&&!failed.state.resources.guns.powered,'Removing the last working gun unit immediately clears its charge and power');
    await page.locator('#equipment-power').click();assert(await page.locator('#power-guns').isDisabled(),'Inoperative system cannot be powered back on');
    const cloak=structuredClone(fixture),shields=cloak.state.equipment[4];shields.units[0]={components:[...shields.spares],performance:4};shields.units[0].components[1]=21;shields.performance=shields.units.reduce((n,u)=>n+u.performance,0);shields.specialAvailable=true;
    await load(cloak);await openPower();await page.locator('#power-cloak').click();await resumeFor(800);const cloaked=await exportGame();
    assert(cloaked.state.machinery.cloaked&&cloaked.state.resources.fuel===4,'A working installed cloaker enables and spends12 fuel on phase3');
    await load(cloaked);assert(JSON.stringify((await exportGame()).state)===JSON.stringify(cloaked.state),'Reload preserves the active cloaker and its consumed fuel');
    await openPower();await page.locator('#power-cloak').click();await resumeFor(1050);const uncloaked=await exportGame();
    assert(!uncloaked.state.machinery.cloaked&&uncloaked.state.resources.fuel===4,'Switching the cloaker off stops its fuel cost');
    const exhausted=structuredClone(fixture);exhausted.state.ship.minutes=59;exhausted.state.ship.condition.rest=1;await load(exhausted);
    await page.locator('#walk-pause').click();await page.clock.runFor(400);assert(await page.locator('#sleep-wake').isDisabled(),'The aboard clock enters forced sleep at exhaustion');await page.clock.runFor(400);assert((await state()).sleeping==='true','Forced sleep continues without a save-validator error at zero rest');
    await page.locator('#sleep-pause').click();await page.clock.runFor(16);
    // Forced sleep intentionally cannot save/import; wake normally before the next fixture.
    await page.locator('#sleep-pause').click();await page.clock.runFor(13000);await page.locator('#sleep-wake').click();await page.locator('#inventory-close').click();
    const dead=structuredClone(fixture);dead.state.ship.minutes=59;dead.state.ship.condition={vigor:1,rest:1,health:1,nourishment:1};await load(dead);await page.locator('#walk-pause').click();await page.clock.runFor(500);
    assert((await state()).dead==='true'&&await page.locator('#sleep-saves').isVisible(),'Death stops machinery and retains the load-recovery controls');await page.clock.runFor(500);
    await load(fixture);assert(JSON.stringify((await exportGame()).state)===JSON.stringify(fixture.state),'A living save restores cleanly after death');
    assert(errors.length===0,'No uncaught machinery browser errors');return {browser:browser.version(),checks,errors};
  }catch(e){await page.screenshot({path:'output/playwright/remake/machinery-error.png'});return {browser:browser.version(),checks,errors,failures:[e.message]}}
  finally{await context.close()}
}
