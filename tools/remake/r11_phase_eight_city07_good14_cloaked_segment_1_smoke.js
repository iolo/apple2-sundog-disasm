// Complete the interworld spice leg in short cloaked segments with ordinary rescues.
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
  try{
    await page.addInitScript(()=>localStorage.setItem('sundog.locale','en'));
    await page.clock.install({time:new Date('2026-10-16T00:00:00Z')});await page.clock.pauseAt(new Date('2026-10-16T00:00:01Z'));
    await page.goto('http://127.0.0.1:8000/');await ready();
    await page.locator('#create-character').click();await page.locator('#character-name').fill('Import shell');
    await page.locator('#prepare-campaign').click();await page.locator('#campaign-seed').fill('1');await page.locator('#start-campaign').click();
    await page.locator('#walk-saves').click();await settled();
    await page.locator('#checkpoint-file').setInputFiles('output/playwright/remake/r11-phase-eight-city07-good14-contact-cleared-3.json');
    await page.waitForFunction(()=>/imported/i.test(document.querySelector('#checkpoint-message')?.textContent||''));await page.locator('#checkpoint-back').click();
    const original=(await exported()).state;
    assert(original.colony.activePhase===8&&original.colony.receipts.length===47&&
      !original.space.flags[40]&&original.flight.motion?.type==='sublight'&&
      original.pod.cargo[0]?.commodityId==='cargo-14'&&original.equipment[4].specialAvailable,
      'Three pirate retreats leave the paid spices and installed cloaker intact');
    await tactical();await page.locator('#space-shields').click();await page.locator('#space-shield-off').click();
    await page.locator('#space-menu-back').click();
    assert((await exported()).state.resources.shields.targetCharge===0,'Shields power down for the cloaked-only passage');
    let segments=0,arrived=false;
    for(;segments<1;segments++){
      await nav();
      if((await exported()).state.flight.motion)await page.locator('#nav-halt').click();
      let waiting=(await exported()).state;
      assert(waiting.flight.motion===null&&!waiting.resources.enginesPowered,
        `Segment ${segments+1} halts without losing the paid cargo`);
      if(waiting.flight.refuelAt===null){await page.locator('#nav-distress').click();await page.locator('#nav-confirm').click();waiting=(await exported()).state}
      assert(waiting.flight.refuelAt!==null,`Segment ${segments+1} has an ordinary rescue scheduled`);
      if((await state()).paused==='true')await page.locator('#nav-run').click();
      for(let i=0;i<512;i++){
        await page.clock.runFor(250);const live=await state();
        if(live.dead==='true')throw Error('Pilot died while awaiting rescue');
        if(Number(live.minutes)>=waiting.flight.refuelAt)break;
      }
      if((await state()).paused!=='true')await page.locator('#nav-run').click();
      const rescued=(await exported()).state;
      assert(rescued.flight.refuelAt===null&&rescued.resources.fuel>=230,
        `Segment ${segments+1} rescue fills the stationary tank`);
      await tactical();await page.locator('#space-cloak').click();
      assert((await exported()).state.machinery.cloaked,`Segment ${segments+1} starts under cloak`);
      await nav();await page.locator('#nav-scale-system').click();
      await page.locator('#nav-destination').selectOption('world-01');await page.locator('#nav-select').click();await page.locator('#nav-confirm').click();
      if((await state()).paused==='true')await page.locator('#nav-run').click();
      for(let i=0;i<2048;i++){
        await page.clock.runFor(250);const live=await state();
        if(live.dead==='true')throw Error('Ship destroyed on the cloaked interworld leg');
        if(live.contact==='true')throw Error('Pirate contact appeared through the active cloaker');
        if(!live.flight){arrived=true;break}
        const resource=await page.locator('#nav-resources').innerText(),fuel=Number(resource.match(/Fuel (\d+)/)?.[1]);
        if(!Number.isFinite(fuel))throw Error(`Fuel unreadable: ${resource}`);
        if(fuel<=40)break;
      }
      if(!arrived){await page.locator('#nav-halt').click();await tactical();await page.locator('#space-cloak').click();
        assert(!(await exported()).state.machinery.cloaked,`Segment ${segments+1} turns cloak off before rescue`);
        await exported(`output/playwright/remake/r11-phase-eight-city07-good14-cloaked-segment-1.json`)}
      else break;
    }
    assert(!arrived,'The planned cloaked segment halts before world-one orbit');
    const stopped=(await reload()).state;
    assert(stopped.regional.shipLocation.orbit.angle===166&&stopped.flight.motion===null&&
      !stopped.machinery.cloaked&&stopped.pod.cargo[0]?.commodityId==='cargo-14'&&
      stopped.resources.fuel>0&&stopped.colony.receipts.length===47,
      'The paid spices remain safe at the intermediate orbit');
    const checkpoint=await exported('output/playwright/remake/r11-phase-eight-city07-good14-cloaked-segment-1.json');
    assert(JSON.stringify(checkpoint.state)===JSON.stringify(stopped),'The cloaked segment exports unchanged');
    assert(errors.length===0,'No uncaught errors on the cloaked segment');
    return{browser:browser.version(),checks,errors,failures:[],journey:{segment:1,orbit:stopped.regional.shipLocation.orbit,
      fuel:stopped.resources.fuel,condition:stopped.ship.condition,minutes:stopped.ship.minutes}};
  }catch(error){await page.screenshot({path:'output/playwright/remake/r11-phase-eight-city07-good14-cloaked-segment-1-error.png'});
    return{browser:browser.version(),checks,errors,failures:[error.stack||error.message]}}
  finally{await context.close()}
}
