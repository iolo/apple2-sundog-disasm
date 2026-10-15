// Land the paid system-eleven radioactive lot at Banville through ordinary pilotage.
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
    assert(JSON.stringify(after.state)===JSON.stringify(before.state),'Fresh-page reload preserves the Banville landing');return after};
  try{
    await page.addInitScript(()=>localStorage.setItem('sundog.locale','en'));
    await page.clock.install({time:new Date('2026-10-16T00:00:00Z')});await page.clock.pauseAt(new Date('2026-10-16T00:00:01Z'));
    await page.goto('http://127.0.0.1:8000/');await ready();
    await page.locator('#create-character').click();await page.locator('#character-name').fill('Import shell');
    await page.locator('#prepare-campaign').click();await page.locator('#campaign-seed').fill('1');await page.locator('#start-campaign').click();
    await page.locator('#walk-saves').click();await settled();
    await page.locator('#checkpoint-file').setInputFiles('output/playwright/remake/r11-phase-nine-city17-radio-furs-home-approach-3.json');
    await page.waitForFunction(()=>/imported/i.test(document.querySelector('#checkpoint-message')?.textContent||''));await page.locator('#checkpoint-back').click();
    const original=(await exported()).state;
    assert(original.regional.shipLocation.worldId==='world-01'&&original.regional.shipLocation.cityId===null&&
      ['cargo-02','cargo-28'].every(id=>original.pod.cargo.some(c=>c?.commodityId===id&&c.originCity==='city-17'))&&
      original.colony.receipts.length===57&&original.resources.fuel>0,
      'The radioactive-furs carrier is in homeworld orbit with landing fuel');
    await page.locator((await page.locator('#space-panel').count())?'#space-navigation':'#walk-navigation').click();
    await page.locator('#nav-scale-planet').click();await page.locator('#nav-destination').selectOption('city-60');
    await page.locator('#nav-select').click();await page.locator('#nav-confirm').click();
    await page.locator('#nav-run').click();
    for(let i=0;i<128;i++){await page.clock.runFor(250);if(!(await state()).flight)break}
    assert(!(await state()).flight,'Ordinary pilotage completes the Banville landing');
    const landed=(await reload()).state;
    assert(landed.regional.shipLocation.cityId==='city-60'&&
      ['cargo-02','cargo-28'].every(id=>landed.pod.cargo.some(c=>c?.commodityId===id&&c.originCity==='city-17'))&&
      landed.resources.hull===16&&landed.colony.receipts.length===57,
      'Radioactives and furs/silks land at Banville intact');
    const checkpoint=await exported('output/playwright/remake/r11-phase-nine-city17-radio-furs-banville-landed.json');
    assert(JSON.stringify(checkpoint.state)===JSON.stringify(landed),'The radioactive-furs carrier landing exports unchanged');
    assert(errors.length===0,'No uncaught errors on the Banville landing');
    return{browser:browser.version(),checks,errors,failures:[],journey:{fuel:landed.resources.fuel,hull:landed.resources.hull,
      bank:landed.economy.accounts[0].balance,condition:landed.ship.condition,minutes:landed.ship.minutes}};
  }catch(error){await page.screenshot({path:'output/playwright/remake/r11-phase-nine-city17-radio-furs-banville-land-error.png'});
    return{browser:browser.version(),checks,errors,failures:[error.stack||error.message]}}
  finally{await context.close()}
}
