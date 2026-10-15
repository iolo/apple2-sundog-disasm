// Halt after the cloaker retreat, take the scheduled rescue, and resume world-one flight.
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
    assert(JSON.stringify(after.state)===JSON.stringify(before.state),'Fresh-page reload preserves the resumed flight');return after};
  try{
    await page.addInitScript(()=>localStorage.setItem('sundog.locale','en'));
    await page.clock.install({time:new Date('2026-10-16T00:00:00Z')});await page.clock.pauseAt(new Date('2026-10-16T00:00:01Z'));
    await page.goto('http://127.0.0.1:8000/');await ready();
    await page.locator('#create-character').click();await page.locator('#character-name').fill('Import shell');
    await page.locator('#prepare-campaign').click();await page.locator('#campaign-seed').fill('1');await page.locator('#start-campaign').click();
    await page.locator('#walk-saves').click();await settled();
    await page.locator('#checkpoint-file').setInputFiles('output/playwright/remake/r11-phase-eight-city07-good14-contact-cleared.json');
    await page.waitForFunction(()=>/imported/i.test(document.querySelector('#checkpoint-message')?.textContent||''));await page.locator('#checkpoint-back').click();
    const original=(await exported()).state;
    assert(!original.space.flags[40]&&!original.machinery.cloaked&&original.flight.motion?.type==='sublight'&&
      original.flight.refuelAt!==null&&original.resources.fuel<100&&original.pod.cargo[0]?.commodityId==='cargo-14',
      'The cleared contact is still in powered flight with a rescue due');
    await page.locator((await page.locator('#space-panel').count())?'#space-navigation':'#walk-navigation').click();await page.locator('#nav-halt').click();
    const halted=(await exported()).state;
    assert(halted.flight.motion===null&&!halted.resources.enginesPowered&&halted.flight.refuelAt!==null,
      'Ordinary Halt preserves the scheduled rescue while saving the remaining fuel');
    await page.locator('#nav-run').click();
    for(let i=0;i<512;i++){await page.clock.runFor(250);if(/Rescue delivered/.test(await page.locator('#nav-status').innerText()))break}
    assert((await exported()).state.resources.fuel>=200,'The scheduled rescue fills the stationary tank');
    if((await state()).paused!=='true')await page.locator('#nav-run').click();
    await page.locator('#nav-scale-system').click();await page.locator('#nav-destination').selectOption('world-01');
    await page.locator('#nav-select').click();await page.locator('#nav-confirm').click();
    const resumed=(await reload()).state;
    assert(resumed.flight.motion?.to.worldId==='world-01'&&resumed.resources.fuel>=200&&
      resumed.pod.cargo[0]?.commodityId==='cargo-14'&&resumed.resources.hull>0,
      'The paid carrier resumes from its intermediate orbit with cargo intact');
    const checkpoint=await exported('output/playwright/remake/r11-phase-eight-city07-good14-refueled-flight.json');
    assert(JSON.stringify(checkpoint.state)===JSON.stringify(resumed),'The refueled flight exports unchanged');
    assert(errors.length===0,'No uncaught errors on the timed midflight rescue');
    return{browser:browser.version(),checks,errors,failures:[],journey:{fuel:resumed.resources.fuel,
      progress:resumed.flight.motion.progress,duration:resumed.flight.motion.duration,
      shield:resumed.resources.shields.charge,minutes:resumed.ship.minutes}};
  }catch(error){await page.screenshot({path:'output/playwright/remake/r11-phase-eight-city07-good14-midflight-rescue-error.png'});
    return{browser:browser.version(),checks,errors,failures:[error.stack||error.message]}}
  finally{await context.close()}
}
