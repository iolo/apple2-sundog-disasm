// Explicit depleted-condition HTTP fixtures test rare UI transitions. These
// replace only the test context's initial asset response, never production data.
async browserPage => {
  const browser=browserPage.context().browser(),checks=[],errors=[];
  const assert=(ok,name)=>{if(!ok)throw new Error(name);checks.push(name)};
  for(const scenario of ['exhaustion','death']) {
    const context=await browser.newContext({viewport:{width:640,height:480},hasTouch:true});
    const page=await context.newPage();page.on('pageerror',e=>errors.push(e.message));page.on('dialog',d=>d.accept());
    try {
      await page.route('**/data/ship-inventory.json',async route=>{
        const response=await route.fetch(),data=await response.json();
        data.condition=scenario==='death'?{vigor:1,rest:1,health:1,nourishment:1}:{vigor:128,rest:1,health:180,nourishment:200};
        await route.fulfill({response,json:data});
      });
      await page.clock.install();await page.goto('http://127.0.0.1:8000/');await page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
      if(await page.locator('html').getAttribute('lang')!=='en')await page.locator('[data-action=language]').tap();
      await page.locator('#explore').tap();await page.locator('#begin-walk').tap();
      if(scenario==='death') {
        await page.locator('#walk-saves').tap();await page.locator('#save-checkpoint-0').tap();
        await page.waitForFunction(()=>!document.querySelector('#checkpoint-back').disabled);
        await page.locator('#checkpoint-back').tap();await page.locator('#walk-pause').tap();
      }
      await page.clock.runFor(60500);
      assert(await page.evaluate(()=>document.querySelector('.sleep-panel').contains(document.activeElement)),`${scenario}: automatic dialog takes focus`);
      if(scenario==='exhaustion') {
        assert(await page.locator('#sleep-wake').isDisabled(),'Exhaustion prevents waking early');
        await page.keyboard.press('Escape');assert(await page.locator('#sleep-title').innerText()==='Exhausted — sleeping','Escape cannot bypass forced sleep');
        await page.clock.runFor(13000);assert(await page.locator('#sleep-wake').isEnabled(),'Recovered rest unlocks waking');
        await page.locator('#sleep-wake').tap();assert(await page.locator('#inventory-panel').count()===1,'Touch wakes from recovered exhaustion');
      } else {
        assert(await page.locator('#walk-screen').getAttribute('data-dead')==='true','Zero vigor enters terminal state');
        const minutes=await page.locator('#walk-screen').getAttribute('data-minutes');await page.clock.runFor(5000);
        assert(await page.locator('#walk-screen').getAttribute('data-minutes')===minutes,'Terminal state freezes the clock');
        await page.keyboard.press('Escape');assert(await page.locator('#sleep-restart').count()===1,'Escape cannot resume a dead walkthrough');
        await page.locator('#sleep-saves').tap();await page.waitForFunction(()=>!document.querySelector('#checkpoint-back').disabled);
        assert(await page.locator('#save-checkpoint-0').isDisabled()&&await page.locator('#export-checkpoint').isDisabled(),'Terminal state cannot replace a living checkpoint');
        await page.keyboard.press('Escape');assert(await page.evaluate(()=>document.activeElement.id==='sleep-saves'),'Closing terminal checkpoints restores dialog focus');
        await page.locator('#sleep-saves').tap();await page.locator('#load-checkpoint-0').tap();await page.waitForFunction(()=>!document.querySelector('#checkpoint-back').disabled);
        await page.locator('#checkpoint-back').tap();await page.clock.runFor(100);
        assert(await page.locator('#walk-screen').getAttribute('data-dead')==='false'&&await page.locator('#walk-screen').getAttribute('data-paused')==='true','Touch checkpoint load clears terminal state and remains paused');
        await page.locator('#walk-pause').tap();await page.clock.runFor(60500);
        await page.locator('#sleep-restart').tap();await page.locator('#walk-inventory').tap();
        assert(await page.locator('#walk-screen').getAttribute('data-minutes')==='0'&&await page.locator('#walk-screen').getAttribute('data-dead')==='false','Restart clears terminal state and time');
      }
    } catch(error) {await page.screenshot({path:`output/playwright/remake/survival-${scenario}-failure.png`});throw error}
    finally {await context.close()}
  }
  assert(errors.length===0,`No browser errors: ${errors.join(', ')}`);
  return {browser:browser.version(),passed:checks.length,checks,fixtures:'HTTP response replacements for initial depleted condition; no production hooks'};
}
