// Repel the world-two pirate through the installed cloaker and tactical UI.
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
    assert(JSON.stringify(after.state)===JSON.stringify(before.state),'Fresh-page reload preserves the cloaker result');return after};
  try{
    await page.addInitScript(()=>localStorage.setItem('sundog.locale','en'));
    await page.clock.install({time:new Date('2026-10-16T00:00:00Z')});await page.clock.pauseAt(new Date('2026-10-16T00:00:01Z'));
    await page.goto('http://127.0.0.1:8000/');await ready();
    await page.locator('#create-character').click();await page.locator('#character-name').fill('Import shell');
    await page.locator('#prepare-campaign').click();await page.locator('#campaign-seed').fill('1');await page.locator('#start-campaign').click();
    await page.locator('#walk-saves').click();await settled();
    await page.locator('#checkpoint-file').setInputFiles('output/playwright/remake/r11-phase-eight-city07-good14-approach-stop.json');
    await page.waitForFunction(()=>/imported/i.test(document.querySelector('#checkpoint-message')?.textContent||''));await page.locator('#checkpoint-back').click();
    const original=(await exported()).state;
    assert(original.space.flags[40]&&original.equipment[4].specialAvailable&&
      original.pod.cargo[0]?.commodityId==='cargo-14'&&original.resources.shields.charge===255,
      'The pirate contact begins with paid spices, full shields and a working cloaker');
    await page.locator('#walk-navigation').click();await page.locator('#nav-tactical').click();
    assert(await page.locator('#space-cloak').isEnabled(),'The installed cloaker remains available in combat');
    await page.locator('#space-cloak').click();
    assert((await exported()).state.machinery.cloaked,'Normal tactical controls activate cloak during contact');
    if((await state()).paused==='true')await page.locator('#space-run').click();
    for(let i=0;i<600;i++){
      await page.clock.runFor(50);const live=await state();
      if(live.dead==='true')throw Error('Ship destroyed while cloaking the pirate contact');
      if(live.contact!=='true')break;
    }
    assert((await state()).contact!=='true','The pirate retreats from the active cloaker');
    await page.locator('#space-cloak').click();
    const cleared=(await reload()).state;
    assert(!cleared.space.flags[40]&&!cleared.machinery.cloaked&&cleared.resources.hull>0&&
      cleared.pod.cargo[0]?.commodityId==='cargo-14'&&cleared.colony.receipts.length===47,
      'The cloaker is off after preserving the paid lot and prior deliveries');
    const checkpoint=await exported('output/playwright/remake/r11-phase-eight-city07-good14-contact-cleared.json');
    assert(JSON.stringify(checkpoint.state)===JSON.stringify(cleared),'The cleared contact exports unchanged');
    assert(errors.length===0,'No uncaught errors while repelling the pirate');
    return{browser:browser.version(),checks,errors,failures:[],journey:{fuel:cleared.resources.fuel,hull:cleared.resources.hull,
      shield:cleared.resources.shields.charge,minutes:cleared.ship.minutes,refuelAt:cleared.flight.refuelAt,
      motion:cleared.flight.motion?.progress}};
  }catch(error){await page.screenshot({path:'output/playwright/remake/r11-phase-eight-city07-good14-cloak-contact-error.png'});
    return{browser:browser.version(),checks,errors,failures:[error.stack||error.message]}}
  finally{await context.close()}
}
