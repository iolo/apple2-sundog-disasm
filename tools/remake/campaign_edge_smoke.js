// Uses valid exported campaign files with depleted active condition; all state
// enters through the normal import UI. See campaign_smoke.js for the base export.
async browserPage => {
  const browser=browserPage.context().browser(),checks=[],errors=[];
  const context=await browser.newContext({viewport:{width:1280,height:720}});
  const page=await context.newPage();
  page.on('pageerror',e=>errors.push(e.message));page.on('dialog',d=>d.accept());
  const assert=(ok,name)=>{if(!ok)throw Error(name);checks.push(name)};
  const settled=()=>page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
  const click=async id=>{await page.locator(id).click();await settled()};
  try {
    await page.clock.install();await page.goto('http://127.0.0.1:8000/');await page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
    await page.locator('#create-character').click();await page.locator('#character-name').fill('Random');await page.locator('#prepare-campaign').click();await page.locator('#start-campaign').click();
    const seed=Number(await page.locator('#walk-screen').getAttribute('data-seed'));
    assert(seed>0&&seed<=0xffffffff&&seed!==0x80000000,'Blank seed produces an explicit usable saved world seed');
    await page.locator('#walk-back').click();await page.locator('#create-character').click();
    assert(await page.evaluate(()=>document.activeElement.id)==='campaign-seed','Reopening the boarding form restores keyboard focus');
    await page.locator('#character-back').click();await page.locator('#resume-campaign').click();
    await page.locator('#walk-saves').click();await settled();
    await page.locator('#checkpoint-file').setInputFiles('output/playwright/remake/campaign-exhaustion.json');await settled();await click('#checkpoint-back');
    await page.locator('#walk-pause').click();await page.clock.runFor(1100);
    assert(await page.locator('#sleep-wake').isDisabled(),'Campaign exhaustion forces sleep');
    assert(await page.locator('#walk-saves').evaluate(el=>!!el.closest('[inert]')),'Campaign save controls cannot be used while sleeping');
    await page.keyboard.press('Escape');assert(await page.locator('#sleep-wake').isDisabled(),'Escape cannot bypass forced campaign sleep');
    await page.clock.runFor(13000);await page.locator('#sleep-wake').click();await page.locator('#inventory-close').click();
    assert(await page.locator('#walk-screen').getAttribute('data-paused')==='true','Waking pauses the campaign');
    await page.locator('#walk-saves').click();await settled();await click('#save-checkpoint-0');
    await page.locator('#checkpoint-file').setInputFiles('output/playwright/remake/campaign-death.json');await settled();await click('#checkpoint-back');
    await page.locator('#walk-pause').click();await page.clock.runFor(1100);
    assert(await page.locator('#sleep-restart').count()===0&&await page.locator('#sleep-back').isVisible(),'Ended campaign offers return and saved games, not a walkthrough reset');
    await page.locator('#sleep-saves').click();await settled();
    assert(await page.locator('#save-checkpoint-0').isDisabled()&&await page.locator('#export-checkpoint').isDisabled(),'Terminal campaign cannot overwrite a living save');
    await click('#load-checkpoint-0');await click('#checkpoint-back');
    assert(await page.locator('#walk-screen').getAttribute('data-dead')==='false'&&await page.locator('#walk-screen').getAttribute('data-paused')==='true','Living campaign reload clears terminal state and resumes paused');
    await page.locator('#walk-back').click();
    // Storage failure in a fresh document must preserve import/export as a fallback.
    await page.addInitScript(()=>Object.defineProperty(window,'indexedDB',{value:{open(){throw Error('blocked')}}}));
    await page.reload();await page.waitForFunction(()=>document.documentElement.dataset.ready==='true');await page.locator('#campaign-saves').click();await settled();
    assert((await page.locator('#checkpoint-message').innerText()).includes('unavailable'),'Campaign storage failure is reported');
    await page.locator('#checkpoint-file').setInputFiles('output/playwright/remake/campaign-export.json');await settled();
    assert(await page.locator('#save-checkpoint-0').isDisabled()&&await page.locator('#export-checkpoint').isEnabled(),'Imported campaign remains exportable when browser storage is blocked');
    await click('#retry-checkpoints');assert((await page.locator('#checkpoint-message').innerText()).includes('unavailable'),'Storage retry preserves the imported campaign');
    await click('#checkpoint-back');assert(await page.locator('#walk-screen').getAttribute('data-seed')==='12345','Storage failure does not prevent resuming an imported campaign');
    assert(errors.length===0,`No campaign edge errors: ${errors.join(', ')}`);
    return {browser:browser.version(),passed:checks.length,checks};
  } catch(error) {await page.screenshot({path:'output/playwright/remake/campaign-edge-failure.png'});throw Error(`${error.message}; last check: ${checks.at(-1)}`)}
  finally {await context.close()}
}
