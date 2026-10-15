// Preserve the unique city-49 cryogen by conceding the paid pod lot to the pirate.
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
  const exported=async(path=null)=>{await saves();const pending=page.waitForEvent('download');await page.locator('#export-checkpoint').click();const download=await pending;if(path)await download.saveAs(path);let text='';for await(const part of await download.createReadStream())text+=part;await settled();await page.locator('#checkpoint-back').click();return JSON.parse(text)};
  try{
    await page.addInitScript(()=>localStorage.setItem('sundog.locale','en'));
    await page.clock.install({time:new Date('2026-10-16T00:00:00Z')});await page.clock.pauseAt(new Date('2026-10-16T00:00:01Z'));
    await page.goto('http://127.0.0.1:8000/');await ready();
    await page.locator('#create-character').click();await page.locator('#character-name').fill('Import shell');
    await page.locator('#prepare-campaign').click();await page.locator('#campaign-seed').fill('1');await page.locator('#start-campaign').click();
    await page.locator('#walk-saves').click();await settled();
    await page.locator('#checkpoint-file').setInputFiles('output/playwright/remake/r11-phase-eight-city49-home-approach-contact.json');
    await page.waitForFunction(()=>/imported/i.test(document.querySelector('#checkpoint-message')?.textContent||''));await page.locator('#checkpoint-back').click();
    const original=(await exported()).state;
    assert(original.space.flags[40]&&original.resources.hull===16&&original.pod.cargo[0]?.commodityId==='cargo-31'&&
      original.pod.cargo[1]?.commodityId==='cargo-02','Both lots enter the first homeworld contact in fixed pod slots');
    if(await page.locator('#navigation-panel').count())await page.locator('#nav-tactical').click();
    else {await page.locator('#walk-navigation').click();await page.locator('#nav-tactical').click()}
    await page.locator('#space-comm').click();await page.locator('#dialogue-reply-0').click();await page.locator('#dialogue-cancel').click();
    await page.locator('#space-bolts').click();await page.locator('#space-jettison-2').click();
    const conceded=(await exported()).state;
    assert(conceded.pod.cargo[0]?.commodityId==='cargo-31'&&conceded.pod.cargo[1]===null&&
      conceded.space.losses.some(e=>e.lot.commodityId==='cargo-02'&&e.count===1),
      'Ordinary pod-slot jettison records the paid cargo loss and keeps the distinct cryogen');
    for(let i=0;i<256;i++){
      if((await state()).paused==='true')await page.locator('#space-run').click();
      await page.clock.runFor(50);
      if((await state()).dead==='true')throw Error('Pirate attack destroyed the cryogen carrier');
      if((await state()).contact!=='true')break;
    }
    assert((await state()).contact!=='true','The pirate retreats after taking the valuable pod lot');
    const safe=(await exported('output/playwright/remake/r11-phase-eight-city49-home-cryo-only-clear.json')).state;
    assert(safe.resources.hull>0&&safe.pod.cargo[0]?.commodityId==='cargo-31'&&safe.pod.cargo[1]===null,
      'The carrier and unique cryogen survive the concession');
    assert(errors.length===0,'No uncaught errors during the source cargo concession');
    return{browser:browser.version(),checks,errors,failures:[],journey:{minutes:safe.ship.minutes,hull:safe.resources.hull,
      fuel:safe.resources.fuel,shield:safe.resources.shields.charge,progress:safe.flight.motion?.progress??null}};
  }catch(error){await page.screenshot({path:'output/playwright/remake/r11-phase-eight-city49-home-jettison-error.png'});return{browser:browser.version(),checks,errors,failures:[error.stack||error.message]}}
  finally{await context.close()}
}
