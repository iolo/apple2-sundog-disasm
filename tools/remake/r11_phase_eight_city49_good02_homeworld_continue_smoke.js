// Run the paid world-two radioactive carrier toward world one through ordinary flight.
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
  try{
    await page.addInitScript(()=>localStorage.setItem('sundog.locale','en'));
    await page.clock.install({time:new Date('2026-10-16T00:00:00Z')});await page.clock.pauseAt(new Date('2026-10-16T00:00:01Z'));
    await page.goto('http://127.0.0.1:8000/');await ready();
    await page.locator('#create-character').click();await page.locator('#character-name').fill('Import shell');
    await page.locator('#prepare-campaign').click();await page.locator('#campaign-seed').fill('1');await page.locator('#start-campaign').click();
    await page.locator('#walk-saves').click();await settled();
    await page.locator('#checkpoint-file').setInputFiles('output/playwright/remake/r11-phase-eight-city49-good02-homeworld-contact-cleared.json');
    await page.waitForFunction(()=>/imported/i.test(document.querySelector('#checkpoint-message')?.textContent||''));await page.locator('#checkpoint-back').click();
    const original=(await exported()).state;
    assert(original.colony.activePhase===8&&original.colony.receipts.length===50&&
      original.flight.motion?.to.worldId==='world-01'&&original.pod.cargo[0]?.commodityId==='cargo-02'&&
      original.resources.shields.charge===128,'The charged and fueled paid carrier has world one selected');
    if(!await page.locator('#navigation-panel').count())await page.locator(await page.locator('#space-panel').count()?'#space-navigation':'#walk-navigation').click();
    if((await state()).paused==='true')await page.locator('#nav-run').click();
    let contact=false;
    for(let i=0;i<2048;i++){
      await page.clock.runFor(250);const live=await state();
      if(live.contact==='true'){contact=true;break}
      if(live.dead==='true')throw Error('The paid carrier was destroyed during the world-one approach');
      if(!live.flight)break;
    }
    const stopped=(await exported()).state;
    assert(stopped.resources.hull>0&&stopped.pod.cargo[0]?.commodityId==='cargo-02'&&
      (contact||stopped.regional.shipLocation.worldId==='world-01'||stopped.resources.fuel===0),
      'Ordinary flight reaches a contact, fuel stop or world-one orbit with radioactives intact');
    const checkpoint=await exported('output/playwright/remake/r11-phase-eight-city49-good02-homeworld-continue-stop.json');
    assert(JSON.stringify(checkpoint.state)===JSON.stringify(stopped),'The radioactive approach checkpoint exports unchanged');
    assert(errors.length===0,'No uncaught errors on the protected radioactive approach');
    return{browser:browser.version(),checks,errors,failures:[],journey:{contact,stalled:stopped.resources.fuel===0,world:stopped.regional.shipLocation.worldId,
      fuel:stopped.resources.fuel,hull:stopped.resources.hull,shield:stopped.resources.shields.charge,
      refuelAt:stopped.flight.refuelAt,minutes:stopped.ship.minutes}};
  }catch(error){await page.screenshot({path:'output/playwright/remake/r11-phase-eight-city49-good02-homeworld-continue-error.png'});
    return{browser:browser.version(),checks,errors,failures:[error.stack||error.message]}}
  finally{await context.close()}
}
