// Ordinary UI actions in isolated browser storage; clock advances time only.
async browserPage => {
  const browser=browserPage.context().browser(),checks=[],errors=[];
  const context=await browser.newContext({viewport:{width:1280,height:720}});
  let page=await context.newPage(),accept=true;
  const watch=p=>{p.on('pageerror',e=>errors.push(e.message));p.on('dialog',d=>accept ? d.accept() : d.dismiss())};
  watch(page);
  const assert=(ok,name)=>{if(!ok)throw Error(name);checks.push(name)};
  const ready=()=>page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
  const settled=()=>page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
  const click=async id=>{await page.locator(id).click();await settled()};
  const state=()=>page.locator('#walk-screen').evaluate(el=>({...el.dataset}));
  const fit=async selector=>page.locator(selector).evaluate(el=>{
    const box=document.querySelector('#stage').getBoundingClientRect();
    return [...el.querySelectorAll('button,input:not([hidden]),.launch-form,.checkpoint-row,.draft-note,#character-message')]
      .filter(e=>e.getClientRects().length).every(e=>{const b=e.getBoundingClientRect();return b.left>=box.left-1&&b.right<=box.right+1&&b.top>=box.top-1&&b.bottom<=box.bottom+1&&e.scrollWidth<=e.clientWidth+1});
  });
  try {
    await page.clock.install();await page.goto('http://127.0.0.1:8000/');await ready();
    await page.locator('#campaign-saves').click();await settled();
    assert(await page.locator('#save-checkpoint-0').isDisabled()&&await page.locator('#export-checkpoint').isDisabled(),'Title opens load-only campaign slots without creating a character');
    await click('#checkpoint-back');assert(await page.locator('#walk-screen').isHidden(),'Closing empty saved games returns to title');
    await page.locator('#create-character').click();await page.locator('#prepare-campaign').click();
    assert((await page.locator('#character-message').innerText()).includes('Enter a name'),'Boarding validates the character before leaving the editor');
    await page.locator('#character-name').fill('선독 <b>');await page.locator('#plus-strength').click();
    await page.locator('#prepare-campaign').click();await page.locator('#campaign-seed').fill('0');
    await page.locator('#start-campaign').click();assert((await page.locator('#character-message').innerText()).includes('whole number'),'Invalid seed leaves character and session unchanged');
    await page.locator('#campaign-seed').fill('12345');accept=false;await page.locator('#start-campaign').click();accept=true;
    assert(await page.locator('#campaign-seed').isVisible(),'Unspent-points cancellation preserves the boarding form');
    for(const lang of ['en','ko']) {
      if(await page.locator('html').getAttribute('lang')!==lang)await page.locator('#character-language').click();
      for(const [width,height] of [[640,480],[1280,720],[390,844]]) {
        await page.setViewportSize({width,height});await page.clock.runFor(100);
        assert(await fit('#character-screen'),`${lang} boarding controls fit ${width}x${height}`);
        assert(await page.locator('#campaign-seed').inputValue()==='12345','Seed survives resize and locale change');
        await page.screenshot({path:`output/playwright/remake/boarding-${lang}-${width}.png`,animations:'disabled'});
      }
    }
    await page.setViewportSize({width:1280,height:720});await page.locator('#character-language').click();
    await page.locator('#start-campaign').click();
    assert((await state()).mode==='campaign'&&(await state()).seed==='12345'&&(await state()).paused==='true','Boarding creates the requested campaign and starts paused');
    assert(await page.locator('#walk-reset').count()===0,'Campaign cannot use walkthrough position reset');
    assert((await page.locator('.walk-note').innerText()).includes('선독 <b>')&&await page.locator('.walk-note b').count()===0,'Character name is displayed as text, not markup');
    await page.locator('#walk-pause').click();const box=await page.locator('#stage').boundingBox();
    await page.mouse.move(box.x+(32+57.25*640/280)*box.width/640,box.y+(46+83.25*2)*box.height/480);
    await page.mouse.down();await page.clock.runFor(2000);await page.mouse.up();await page.clock.runFor(62000);
    await page.locator('#walk-inventory').click();await page.locator('#slot-stores-10').click();await page.locator('#slot-carried-0').click();
    const item=await page.locator('#slot-carried-0').getAttribute('aria-label');
    const condition=await page.locator('[role=meter]').evaluateAll(els=>els.map(el=>el.getAttribute('aria-valuenow')));
    await page.locator('#inventory-close').click();await page.locator('#walk-saves').click();await settled();
    const saved=await state();assert(await page.locator('#checkpoint-title').innerText()==='Saved games','Ship opens campaign saves');
    for(let i=0;i<4;i++)await click(`#save-checkpoint-${i}`);
    assert(await page.locator('[data-checkpoint=load]:enabled').count()===4,'Four campaign slots save through the UI');
    const downloadPromise=page.waitForEvent('download');await click('#export-checkpoint');const download=await downloadPromise;
    await download.saveAs('output/playwright/remake/campaign-export.json');
    assert(download.suggestedFilename()==='sundog-campaign.json','Campaign exports with its own filename');
    await page.clock.runFor(5000);assert((await state()).minutes===saved.minutes,'Campaign save panel pauses the clock');
    for(const lang of ['en','ko']) {
      if(await page.locator('html').getAttribute('lang')!==lang)await click('#checkpoint-language');
      for(const [width,height] of [[640,480],[1280,720],[390,844]]) {
        await page.setViewportSize({width,height});await page.clock.runFor(100);
        assert(await fit('#checkpoint-screen'),`${lang} campaign slots fit ${width}x${height}`);
        await page.screenshot({path:`output/playwright/remake/campaign-saves-${lang}-${width}.png`});
      }
    }
    await click('#checkpoint-language');await page.setViewportSize({width:1280,height:720});
    await click('#checkpoint-back');await page.locator('#walk-back').click();
    assert(await page.locator('#resume-campaign').isVisible(),'Title offers the in-memory campaign');
    await page.locator('#explore').click();await page.locator('#begin-walk').click();
    assert((await state()).mode==='walk'&&(await state()).y==='110','Preview walkthrough owns a separate position');
    await page.locator('#walk-saves').click();await settled();
    assert(await page.locator('#checkpoint-title').innerText()==='Ship checkpoints'&&await page.locator('#load-checkpoint-0').isDisabled(),'Walkthrough checkpoint database remains separate');
    await click('#checkpoint-back');await page.locator('#walk-back').click();await page.locator('#home').click();await page.locator('#resume-campaign').click();
    assert((await state()).y===saved.y&&(await state()).minutes===saved.minutes,'Returning from preview preserves campaign progress');
    await page.close();page=await context.newPage();watch(page);await page.clock.install();await page.goto('http://127.0.0.1:8000/');await ready();
    assert(await page.locator('#resume-campaign').count()===0,'Fresh page does not silently restore a session');
    await page.locator('#campaign-saves').click();await settled();await click('#load-checkpoint-0');await click('#checkpoint-back');
    assert((await state()).y===saved.y&&(await state()).minutes===saved.minutes&&(await state()).paused==='true'&&(await state()).seed==='12345','Fresh page restores campaign identity, position and time paused');
    await page.locator('#walk-inventory').click();
    assert(await page.locator('#slot-carried-0').getAttribute('aria-label')===item,'Charged carried item survives campaign reload');
    assert(JSON.stringify(await page.locator('[role=meter]').evaluateAll(els=>els.map(el=>el.getAttribute('aria-valuenow'))))===JSON.stringify(condition),'Condition survives campaign reload');
    await page.locator('#inventory-close').click();await page.locator('#walk-saves').click();await settled();
    await page.locator('#checkpoint-file').setInputFiles('remake/tests/fixtures/future-draft.json');await settled();
    assert((await page.locator('#checkpoint-message').innerText()).includes('Invalid')&&(await state()).minutes===saved.minutes,'Foreign import is rejected without replacing live progress');
    await page.locator('#checkpoint-file').setInputFiles('output/playwright/remake/campaign-export.json');await settled();
    assert((await page.locator('#checkpoint-message').innerText()).includes('imported'),'Exported campaign imports through the UI');
    await click('#delete-checkpoint-3');assert(await page.locator('#load-checkpoint-3').isDisabled()&&await page.locator('#load-checkpoint-0').isEnabled(),'Campaign deletion affects only the selected slot');
    await context.setOffline(true);await click('#save-checkpoint-3');assert(await page.locator('#load-checkpoint-3').isEnabled(),'Campaign saves work offline');await context.setOffline(false);
    await click('#checkpoint-back');await page.locator('#walk-back').click();
    await page.locator('#create-character').click();await page.locator('#character-name').fill('Another');await page.locator('#prepare-campaign').click();await page.locator('#campaign-seed').fill('54321');
    // First accept unspent points, then cancel replacement of the active session.
    page.removeAllListeners('dialog');let dialogs=0;page.on('dialog',d=>++dialogs===1 ? d.accept() : d.dismiss());
    await page.locator('#start-campaign').click();assert(await page.locator('#campaign-seed').isVisible(),'Cancelling replacement keeps the active campaign');
    page.removeAllListeners('dialog');page.on('dialog',d=>d.accept());
    await page.locator('#character-back').click();await page.locator('#resume-campaign').click();assert((await state()).seed==='12345','Cancelled creation did not change the active seed');
    assert(errors.length===0,`No browser errors: ${errors.join(', ')}`);
    return {browser:browser.version(),passed:checks.length,checks};
  } catch(error) {await page.screenshot({path:'output/playwright/remake/campaign-failure.png'});throw Error(`${error.message}; last check: ${checks.at(-1)}`)}
  finally {await context.close()}
}
