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
  try{
    await page.addInitScript(()=>localStorage.setItem('sundog.locale','en'));
    await page.clock.install({time:new Date('2026-10-16T00:00:00Z')});await page.clock.pauseAt(new Date('2026-10-16T00:00:01Z'));
    await page.goto('http://127.0.0.1:8000/');await ready();
    await page.locator('#create-character').click();await page.locator('#character-name').fill('Import shell');
    await page.locator('#prepare-campaign').click();await page.locator('#campaign-seed').fill('1');await page.locator('#start-campaign').click();
    await page.locator('#walk-saves').click();await settled();
    await page.locator('#checkpoint-file').setInputFiles('output/playwright/remake/r11-phase-eight-clothing-world08-cloaked-progress-7.json');
    await page.waitForFunction(()=>/imported/i.test(document.querySelector('#checkpoint-message')?.textContent||''));await page.locator('#checkpoint-back').click();
    const original=(await exported()).state;
    assert(original.colony.activePhase===8&&original.colony.receipts.length===51&&
      original.regional.shipLocation.systemId==='system-05'&&original.regional.shipLocation.worldId===null&&
      original.regional.shipLocation.orbit.angle===22&&original.regional.shipLocation.orbit.radius===14&&
      original.flight.motion===null&&original.resources.fuel>=20&&!original.machinery.cloaked&&
      original.pod.cargo[0]?.commodityId==='cargo-26'&&original.equipment[4].specialAvailable,
      'The clothing carrier is one short cloaked step from world eight');
    await tactical();await page.locator('#space-cloak').click();
    assert((await exported()).state.machinery.cloaked,'The final world-eight hop starts under cloak');
    await nav();await page.locator('#nav-scale-system').click();
    await page.locator('#nav-destination').selectOption('world-08');await page.locator('#nav-select').click();
    await page.locator('#nav-confirm').click();if((await state()).paused==='true')await page.locator('#nav-run').click();
    for(let i=0;i<256;i++){await page.clock.runFor(250);const live=await state();
      if(live.dead==='true')throw Error('Ship destroyed on the final cloaked hop');
      if(live.contact==='true')throw Error('Pirate contact appeared through the cloaker');
      if(!live.flight)break}
    const arrived=(await exported()).state;
    assert(arrived.regional.shipLocation.worldId==='world-08'&&arrived.flight.motion===null&&
      arrived.resources.hull===16&&arrived.pod.cargo[0]?.commodityId==='cargo-26',
      'The paid clothing reaches world-eight orbit intact');
    if(arrived.machinery.cloaked){await tactical();await page.locator('#space-cloak').click()}
    const stopped=(await reload()).state;
    assert(stopped.regional.shipLocation.worldId==='world-08'&&!stopped.machinery.cloaked,
      'Cloak is off at the destination orbit');
    const checkpoint=await exported('output/playwright/remake/r11-phase-eight-clothing-world08-orbit.json');
    assert(JSON.stringify(checkpoint.state)===JSON.stringify(stopped),'The world-eight orbit exports unchanged');
    assert(errors.length===0,'No uncaught errors on the final cloaked hop');
    return{browser:browser.version(),checks,errors,failures:[],journey:{orbit:stopped.regional.shipLocation.orbit,
      fuel:stopped.resources.fuel,condition:stopped.ship.condition,minutes:stopped.ship.minutes}};
  }catch(error){await page.screenshot({path:'output/playwright/remake/r11-phase-eight-clothing-world08-orbit-error.png'});
    return{browser:browser.version(),checks,errors,failures:[error.stack||error.message]}}
  finally{await context.close()}
}
