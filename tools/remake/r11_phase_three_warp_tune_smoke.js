// Cannibalize an already-disabled engine unit to restore a second warp unit.
async browserPage => {
  const browser=browserPage.context().browser(),checks=[],errors=[];
  const context=await browser.newContext({viewport:{width:1280,height:720}}),page=await context.newPage();
  page.on('pageerror',e=>errors.push(e.stack||e.message));page.on('dialog',d=>d.accept());
  const assert=(ok,name)=>{if(!ok)throw Error(name);checks.push(name)};
  const ready=()=>page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
  const settled=()=>page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
  const saves=async()=>{await page.locator((await page.locator('#equipment-panel').count())?'#equipment-saves':'#walk-saves').click();await settled()};
  const exported=async(path=null)=>{await saves();const pending=page.waitForEvent('download');await page.locator('#export-checkpoint').click();const download=await pending;if(path)await download.saveAs(path);let text='';for await(const part of await download.createReadStream())text+=part;await settled();await page.locator('#checkpoint-back').click();return JSON.parse(text)};
  const reload=async()=>{const before=await exported();await saves();await page.locator('#save-checkpoint-0').click();await settled();await page.reload();await ready();await page.locator('#campaign-saves').click();await settled();await page.locator('#load-checkpoint-0').click();await settled();await page.locator('#checkpoint-back').click();const after=await exported();assert(JSON.stringify(after.state)===JSON.stringify(before.state),'Fresh-page save reload preserves the engineering exchange');return after};
  async function move(from,to){await page.locator(from).click();await page.locator('#equipment-move').click();await page.locator(to).click()}
  try{
    await page.addInitScript(()=>localStorage.setItem('sundog.locale','en'));
    await page.goto('http://127.0.0.1:8000/');await ready();
    await page.locator('#create-character').click();await page.locator('#character-name').fill('Import shell');
    await page.locator('#prepare-campaign').click();await page.locator('#campaign-seed').fill('1');await page.locator('#start-campaign').click();
    await page.locator('#walk-saves').click();await settled();
    await page.locator('#checkpoint-file').setInputFiles('output/playwright/remake/r11-phase-three-warp-repaired.json');
    await page.waitForFunction(()=>/imported/i.test(document.querySelector('#checkpoint-message')?.textContent||''));
    await page.locator('#checkpoint-back').click();
    const original=(await exported()).state;
    assert(original.equipment[0].performance===3&&original.equipment[1].units[1].performance===0&&
      original.equipment[1].units[1].components[0]===31&&original.ship.inventory.carried[1]===0&&
      original.colony.receipts.length===13,'A sound control node is available in an already-disabled engine unit');
    await page.locator('#walk-equipment').click();await page.locator('#equipment-next').click();
    assert(await page.locator('#equipment-panel').getAttribute('data-group')==='sub-c-engines','The next ordinary engineering frame is the engine group');
    await move('#equipment-slot-1-0','#equipment-carried-1');
    const salvaged=(await exported()).state;
    assert(salvaged.ship.inventory.carried[1]===31&&salvaged.equipment[1].performance===original.equipment[1].performance,
      'Moving the sound node from an offline engine costs no working engine output');
    await page.locator('#equipment-previous').click();
    assert(await page.locator('#equipment-panel').getAttribute('data-group')==='warp-drives','The warp frame reopens for installation');
    await move('#equipment-carried-1','#equipment-slot-1-0');
    const tuned=(await exported()).state;
    assert(tuned.equipment[0].units[1].components[0]===31&&tuned.equipment[0].performance===7&&
      tuned.equipment[1].performance===original.equipment[1].performance&&tuned.ship.inventory.carried[1]===7,
      'Normal component exchange restores a second warp unit without harming sublight output');
    await page.locator('#equipment-close').click();
    const stable=(await reload()).state;
    assert(stable.equipment[0].performance===7&&stable.colony.receipts.length===13,
      'Warp output 7 and thirteen receipts survive a fresh-page reload');
    const checkpoint=await exported('output/playwright/remake/r11-phase-three-warp-tuned.json');
    assert(JSON.stringify(checkpoint.state)===JSON.stringify(stable),'The tuned ship checkpoint exports unchanged');
    assert(errors.length===0,'No uncaught errors on the normal component exchange');
    return{browser:browser.version(),checks,errors,failures:[],journey:{warpPerformance:stable.equipment[0].performance,
      enginePerformance:stable.equipment[1].performance,carried:stable.ship.inventory.carried}};
  }catch(error){await page.screenshot({path:'output/playwright/remake/r11-phase-three-warp-tune-error.png'});return{browser:browser.version(),checks,errors,failures:[error.stack||error.message]}}
  finally{await context.close()}
}
