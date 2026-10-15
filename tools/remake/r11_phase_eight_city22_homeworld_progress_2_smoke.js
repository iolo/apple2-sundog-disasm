// Complete the interworld radioactive leg in short cloaked segments with ordinary rescues.
async browserPage => {
  const browser=browserPage.context().browser(),checks=[],errors=[];
  const context=await browser.newContext({viewport:{width:1280,height:720}}),page=await context.newPage();
  page.on('pageerror',e=>errors.push(e.stack||e.message));page.on('dialog',d=>d.accept());
  const assert=(ok,name)=>{if(!ok)throw Error(name);checks.push(name)};
  const ready=()=>page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
  const settled=()=>page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
  const state=()=>page.locator('#walk-screen').evaluate(el=>({...el.dataset}));
  const saves=async()=>{await page.locator((await page.locator('#navigation-panel').count())?'#nav-saves':
    (await page.locator('#space-panel').count())?'#space-saves':'#walk-saves').click();await settled()};
  const exported=async(path=null)=>{await saves();const pending=page.waitForEvent('download');await page.locator('#export-checkpoint').click();
    const download=await pending;if(path)await download.saveAs(path);let text='';for await(const part of await download.createReadStream())text+=part;
    await settled();await page.locator('#checkpoint-back').click();return JSON.parse(text)};
  const reload=async()=>{const before=await exported();await saves();await page.locator('#save-checkpoint-0').click();await settled();
    await page.reload();await ready();await page.locator('#campaign-saves').click();await settled();await page.locator('#load-checkpoint-0').click();
    await settled();await page.locator('#checkpoint-back').click();const after=await exported();
    assert(JSON.stringify(after.state)===JSON.stringify(before.state),'Fresh-page reload preserves the intermediate orbit');return after};
  const nav=async()=>{if(await page.locator('#navigation-panel').count())return;
    await page.locator((await page.locator('#space-panel').count())?'#space-navigation':'#walk-navigation').click()};
  const tactical=async()=>{if(await page.locator('#space-panel').count())return;await nav();await page.locator('#nav-tactical').click()};
  async function recoverSleep(){
    if((await state()).sleeping!=='true')return;
    if((await state()).paused==='true')await page.locator('#sleep-pause').click();
    for(let i=0;i<256&&Number((await state()).rest)<240;i++)await page.clock.runFor(250);
    assert(await page.locator('#sleep-wake').isEnabled(),'Ordinary forced rest recovers enough to wake');
    await page.locator('#sleep-wake').click();await page.locator('#inventory-close').click();
    await page.locator('#walk-pause').click();await page.clock.runFor(100);
    await nav();
  }
  try{
    await page.addInitScript(()=>localStorage.setItem('sundog.locale','en'));
    await page.clock.install({time:new Date('2026-10-16T00:00:00Z')});await page.clock.pauseAt(new Date('2026-10-16T00:00:01Z'));
    await page.goto('http://127.0.0.1:8000/');await ready();
    await page.locator('#create-character').click();await page.locator('#character-name').fill('Import shell');
    await page.locator('#prepare-campaign').click();await page.locator('#campaign-seed').fill('1');await page.locator('#start-campaign').click();
    await page.locator('#walk-saves').click();await settled();
    await page.locator('#checkpoint-file').setInputFiles('output/playwright/remake/r11-phase-eight-city22-homeworld-progress-1.json');
    await page.waitForFunction(()=>/imported/i.test(document.querySelector('#checkpoint-message')?.textContent||''));await page.locator('#checkpoint-back').click();
    const original=(await exported()).state;
    assert(original.colony.activePhase===8&&original.colony.receipts.length===51&&
      original.regional.shipLocation.systemId==='system-01'&&original.regional.shipLocation.cityId===null&&original.flight.motion===null&&
      original.resources.fuel>0&&!original.machinery.cloaked&&
      ['cargo-04','cargo-05'].every(id=>original.pod.cargo.some(c=>c?.commodityId===id))&&original.equipment[4].specialAvailable,
      'The launched two-lot carrier is ready for the cloaked homeworld approach');
    let segments=0,arrived=false;
    for(;segments<2;segments++){
      await nav();
      let ready=(await exported()).state;
      if(ready.resources.fuel<230){
        if(ready.flight.refuelAt===null){await page.locator('#nav-distress').click();await page.locator('#nav-confirm').click();ready=(await exported()).state}
        assert(ready.flight.refuelAt!==null,`Segment ${segments+2} has an ordinary rescue scheduled`);
        if((await state()).paused==='true')await page.locator('#nav-run').click();
        let contact=false;
        for(let i=0;i<1024;i++){
          await page.clock.runFor(250);const live=await state();
          if(live.dead==='true')throw Error('Pilot died while awaiting rescue');
          if(live.contact==='true'){contact=true;break}
          if(live.sleeping==='true'){await recoverSleep();if((await state()).paused==='true')await page.locator('#nav-run').click()}
          if(/Fuel 255\b/.test(await page.locator('#nav-resources').innerText()))break;
        }
        if(contact){const stopped=(await exported('output/playwright/remake/r11-phase-eight-city22-homeworld-rescue-contact.json')).state;
          assert(stopped.resources.hull>0&&['cargo-04','cargo-05'].every(id=>stopped.pod.cargo.some(c=>c?.commodityId===id)),
            'Rescue-wait contact retains both paid lots');
          return{browser:browser.version(),checks,errors,failures:[],journey:{contact:true,segments,
            fuel:stopped.resources.fuel,hull:stopped.resources.hull}}}
        if((await state()).paused!=='true')await page.locator('#nav-run').click();
        ready=(await exported()).state;
        assert(ready.resources.fuel>=230&&ready.flight.refuelAt===null,
          `Segment ${segments+2} rescue fills the stationary tank`);
      }
      await tactical();await page.locator('#space-cloak').click();
      assert((await exported()).state.machinery.cloaked,`Segment ${segments+2} starts under cloak`);
      await nav();await page.locator('#nav-scale-system').click();
      await page.locator('#nav-destination').selectOption('world-01');
      await page.locator('#nav-select').click();await page.locator('#nav-confirm').click();
      if((await state()).paused==='true')await page.locator('#nav-run').click();
      for(let i=0;i<2048;i++){
        await page.clock.runFor(250);const live=await state();
        if(live.dead==='true')throw Error('Ship destroyed on the cloaked homeworld leg');
        if(live.contact==='true')throw Error('Pirate contact appeared through the active cloaker');
        if(live.sleeping==='true'){await recoverSleep();if((await state()).paused==='true')await page.locator('#nav-run').click()}
        if(!live.flight){arrived=true;break}
        const resource=await page.locator('#nav-resources').innerText(),fuel=Number(resource.match(/Fuel (\d+)/)?.[1]);
        if(!Number.isFinite(fuel))throw Error(`Fuel unreadable: ${resource}`);
        if(fuel<=40)break;
      }
      if(!arrived)await page.locator('#nav-halt').click();
      if((await exported()).state.machinery.cloaked){await tactical();await page.locator('#space-cloak').click()}
      const progress=(await exported('output/playwright/remake/r11-phase-eight-city22-homeworld-progress-2.json')).state;
      assert(progress.resources.hull===16&&['cargo-04','cargo-05'].every(id=>progress.pod.cargo.some(c=>c?.commodityId===id))&&
        !progress.machinery.cloaked,`Segment ${segments+2} preserves both paid lots`);
      if(arrived)break;
    }
    const stopped=(await reload()).state;
    assert(stopped.flight.motion===null&&['cargo-04','cargo-05'].every(id=>stopped.pod.cargo.some(c=>c?.commodityId===id))&&
      (stopped.regional.shipLocation.worldId==='world-01'||stopped.regional.shipLocation.worldId===null),
      'Two cloaked segments preserve the cargo and stationary checkpoint');
    const checkpoint=await exported('output/playwright/remake/r11-phase-eight-city22-homeworld-progress-2.json');
    assert(JSON.stringify(checkpoint.state)===JSON.stringify(stopped),'The cloaked segment checkpoint exports unchanged');
    assert(errors.length===0,'No uncaught errors on the cloaked segments');
    return{browser:browser.version(),checks,errors,failures:[],journey:{contact:false,segments:segments+1,
      arrived,orbit:stopped.regional.shipLocation.orbit,fuel:stopped.resources.fuel,
      condition:stopped.ship.condition,minutes:stopped.ship.minutes}};
  }catch(error){await page.screenshot({path:'output/playwright/remake/r11-phase-eight-city22-homeworld-progress-error-2.png'});
    return{browser:browser.version(),checks,errors,failures:[error.stack||error.message]}}
  finally{await context.close()}
}
