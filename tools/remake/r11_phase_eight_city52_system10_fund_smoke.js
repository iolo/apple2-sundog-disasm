// Transfer a reserve for the advanced-part purchase while carrying city-52 cryogen.
async browserPage => {
  const browser=browserPage.context().browser(),checks=[],errors=[];
  const context=await browser.newContext({viewport:{width:1280,height:720}}),page=await context.newPage();
  page.on('pageerror',e=>errors.push(e.stack||e.message));page.on('dialog',d=>d.accept());
  const assert=(ok,name)=>{if(!ok)throw Error(name);checks.push(name)};
  const ready=()=>page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
  const settled=()=>page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
  const saves=async()=>{await page.locator((await page.locator('#bank-panel').count())?'#bank-saves':'#walk-saves').click();await settled()};
  const exported=async(path=null)=>{await saves();const pending=page.waitForEvent('download');await page.locator('#export-checkpoint').click();const download=await pending;if(path)await download.saveAs(path);let text='';for await(const part of await download.createReadStream())text+=part;await settled();await page.locator('#checkpoint-back').click();return JSON.parse(text)};
  try{
    await page.addInitScript(()=>localStorage.setItem('sundog.locale','en'));
    await page.clock.install({time:new Date('2026-10-16T00:00:00Z')});await page.clock.pauseAt(new Date('2026-10-16T00:00:01Z'));
    await page.goto('http://127.0.0.1:8000/');await ready();
    await page.locator('#create-character').click();await page.locator('#character-name').fill('Import shell');
    await page.locator('#prepare-campaign').click();await page.locator('#campaign-seed').fill('1');await page.locator('#start-campaign').click();
    await page.locator('#walk-saves').click();await settled();
    await page.locator('#checkpoint-file').setInputFiles('output/playwright/remake/r11-phase-eight-city52-cloaker-cash.json');
    await page.waitForFunction(()=>/imported/i.test(document.querySelector('#checkpoint-message')?.textContent||''));await page.locator('#checkpoint-back').click();
    const original=(await exported()).state;
    assert(original.dialogue.cash===6000&&original.economy.accounts[10].balance===3775&&
      original.pod.cargo[0]?.originCity==='city-52','The bank withdrawal and city-52 cryogen resume unchanged');
    await page.locator('#bank-transfer').click();await page.locator('#bank-destination').selectOption('system-10');
    await page.locator('#bank-step-1000').click();await page.locator('#bank-step-1000').click();
    await page.locator('#bank-confirm').click();
    const funded=(await exported('output/playwright/remake/r11-phase-eight-city52-system10-funded.json')).state;
    assert(funded.dialogue.cash===6000&&funded.economy.accounts[10].balance===1775&&
      funded.economy.accounts[9].balance===3357&&funded.pod.cargo[0]?.originCity==='city-52',
      'The normal transfer funds system ten and preserves both launch reserves');
    assert(errors.length===0,'No uncaught errors on the system-ten transfer');
    return{browser:browser.version(),checks,errors,failures:[],journey:{cash:funded.dialogue.cash,
      system10Bank:funded.economy.accounts[9].balance,system11Bank:funded.economy.accounts[10].balance}};
  }catch(error){await page.screenshot({path:'output/playwright/remake/r11-phase-eight-city52-system10-fund-error.png'});return{browser:browser.version(),checks,errors,failures:[error.stack||error.message]}}
  finally{await context.close()}
}
