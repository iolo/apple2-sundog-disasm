// All game changes use ordinary UI actions; the virtual clock controls time.
async browserPage => {
  const browser=browserPage.context().browser(),checks=[],errors=[];
  const context=await browser.newContext({viewport:{width:1280,height:720},hasTouch:true});
  const page=await context.newPage();
  page.on('pageerror',e=>errors.push(e.message));page.on('dialog',d=>d.accept());
  const assert=(ok,name)=>{if(!ok)throw Error(name);checks.push(name)};
  const ready=()=>page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
  const settled=()=>page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
  const state=()=>page.locator('#walk-screen').evaluate(el=>({...el.dataset}));
  const move=async(key,ms)=>{
    if((await state()).paused==='true')await page.locator('#walk-pause').click();
    await page.locator('#walk-surface').focus();await page.keyboard.down(key);await page.clock.runFor(ms);await page.keyboard.up(key);
  };
  const exportGame=async()=>{
    await page.locator('#walk-saves').click();await settled();
    const pending=page.waitForEvent('download');await page.locator('#export-checkpoint').click();
    let text='';for await(const part of await (await pending).createReadStream())text+=part;
    await settled();await page.locator('#checkpoint-back').click();return JSON.parse(text);
  };
  try {
    await page.clock.install();await page.goto('http://127.0.0.1:8000/');await ready();
    if(await page.locator('html').getAttribute('lang')!=='en')await page.locator('#language').click();
    await page.locator('#create-character').click();await page.locator('#character-name').fill('Airlock pilot');
    await page.locator('#prepare-campaign').click();await page.locator('#campaign-seed').fill('12345');await page.locator('#start-campaign').click();
    assert((await state()).scene==='ship'&&await page.locator('#walk-airlock').isDisabled(),'New campaign starts inside; remote airlock use is disabled');
    const initial=await exportGame();
    for(let i=0;i<6&&await page.locator('#walk-airlock').isDisabled();i++)await move('ArrowDown',60);
    assert(await page.locator('#walk-airlock').isEnabled(),'Walking to the source airlock enables Leave ship');
    await page.locator('#walk-surface').focus();await page.keyboard.press('Enter');
    let s=await state();
    assert(s.scene==='city'&&s.x==='287'&&s.y==='217'&&s.paused==='true','Enter leaves the ship at the source-derived exterior anchor, paused');
    assert(await page.locator('#walk-equipment').count()===0&&await page.locator('#walk-airlock').isDisabled(),'Exterior equipment access is absent and boarding needs close proximity');
    const departed=await exportGame();
    assert(departed.version===3&&departed.scope==='landed-city-1'&&departed.state.travel.scene==='city','City export carries version3 scene state');
    assert(JSON.stringify(departed.state.start)===JSON.stringify(initial.state.start)&&JSON.stringify(departed.state.equipment)===JSON.stringify(initial.state.equipment)&&JSON.stringify(departed.state.ship.inventory)===JSON.stringify(initial.state.ship.inventory),'Exit preserves creation, active equipment and inventory');
    assert(JSON.stringify(departed.state.ship.position)===JSON.stringify({x:54,y:118}),'Exterior save retains the canonical interior reentry anchor');
    await page.locator('#walk-inventory').click();
    assert(await page.locator('#slot-carried-0').isVisible()&&await page.locator('#slot-locker-0').count()===0&&await page.locator('#slot-stores-0').count()===0,'Outside inventory exposes carried items without remote ship storage');
    await page.locator('#inventory-close').click();
    await page.locator('#walk-pause').click();
    const box=await page.locator('#stage').boundingBox();
    await page.mouse.move(box.x+357.5*box.width/640,box.y+273.5*box.height/480);
    await page.mouse.down();await page.clock.runFor(220);await page.mouse.up();
    assert(Number((await state()).x)>287&&(await state()).y==='217','Pointer hold uses city camera coordinates and release stops input');
    await move('ArrowRight',450);s=await state();
    assert(Number(s.x)>287&&s.scene==='city','City keyboard walking advances the player on clear ground');
    await page.clock.runFor(2000);const active=await state();
    assert(Number(active.minutes)>Number(departed.state.ship.minutes),'Survival time advances while exploring outside');
    await page.locator('#walk-pause').click();const paused=await state();await page.clock.runFor(3000);
    assert((await state()).minutes===paused.minutes&&(await state()).x===paused.x,'Pause stops city movement and survival time');
    const citySave=await exportGame();
    await page.locator('#walk-saves').click();await settled();await page.locator('#save-checkpoint-0').click();await settled();
    await page.reload();await ready();await page.locator('#campaign-saves').click();await settled();await page.locator('#load-checkpoint-0').click();await settled();await page.locator('#checkpoint-back').click();
    s=await state();assert(s.scene==='city'&&Number(s.x)===citySave.state.travel.cityPosition.x&&Number(s.y)===citySave.state.travel.cityPosition.y&&s.paused==='true','Fresh-page load restores the exterior position and stays paused');
    assert(JSON.stringify((await exportGame()).state)===JSON.stringify(citySave.state),'Reload roundtrips all city campaign state');
    await page.locator('#walk-back').click();await page.locator('#explore').click();await page.locator('#begin-walk').click();
    assert((await state()).scene==='ship'&&(await state()).mode==='walk','Preview walkthrough remains separate from the exterior campaign');
    await page.locator('#walk-back').click();await page.locator('#home').click();await page.locator('#resume-campaign').click();
    assert((await state()).scene==='city'&&Number((await state()).x)===citySave.state.travel.cityPosition.x,'Resuming campaign after preview restores its city position');
    for(const lang of ['en','ko']) {
      if(await page.locator('html').getAttribute('lang')!==lang)await page.locator('#walk-language').click();
      for(const [width,height] of [[640,480],[1280,720],[390,844],[844,390]]) {
        await page.setViewportSize({width,height});await page.clock.runFor(100);
        const fits=await page.locator('#walk-screen').evaluate(root=>{
          const box=document.querySelector('#stage').getBoundingClientRect();
          const controls=[...root.querySelectorAll('button,#walk-status,.walk-note,#walk-surface')];
          return controls.every(el=>{const b=el.getBoundingClientRect();return b.left>=box.left-1&&b.right<=box.right+1&&b.top>=box.top-1&&b.bottom<=box.bottom+1&&el.scrollWidth<=el.clientWidth+1})&&
            root.querySelector('#walk-status').getBoundingClientRect().bottom<root.querySelector('.walk-actions').getBoundingClientRect().top;
        });
        assert(fits,`${lang} exterior view fits ${width}×${height}`);
        assert((await state()).scene==='city'&&Number((await state()).x)===citySave.state.travel.cityPosition.x,`${lang} viewport changes retain exterior state at ${width}×${height}`);
      }
      await page.screenshot({path:`output/playwright/remake/city-walk-${lang}.png`,animations:'disabled'});
    }
    await page.setViewportSize({width:1280,height:720});await page.clock.runFor(100);
    // Return along the clear southern edge, then approach the ship's southwest.
    for(let i=0;i<30&&Number((await state()).x)>285;i++)await move('ArrowLeft',70);
    for(let i=0;i<3&&await page.locator('#walk-airlock').isDisabled();i++)await move('ArrowUp',70);
    assert(await page.locator('#walk-airlock').isEnabled(),`Approaching the southwest airlock enables boarding (${JSON.stringify(await state())})`);
    await page.locator('#walk-airlock').tap();s=await state();
    assert(s.scene==='ship'&&s.x==='54'&&s.y==='118'&&s.paused==='true','Touch boarding restores the source interior position and pauses');
    const returned=await exportGame();
    assert(returned.state.travel.scene==='ship'&&returned.state.travel.cityPosition===null&&JSON.stringify(returned.state.equipment)===JSON.stringify(initial.state.equipment),'Reentry clears exterior position and preserves equipment');
    for(const lang of ['en','ko']) {
      if(await page.locator('html').getAttribute('lang')!==lang)await page.locator('#walk-language').click();
      for(const [width,height] of [[640,480],[390,844]]) {
        await page.setViewportSize({width,height});await page.clock.runFor(100);
        assert(await page.locator('.walk-actions').evaluate(el=>{
          const box=el.getBoundingClientRect();return [...el.children].every(e=>{const b=e.getBoundingClientRect();return b.left>=box.left-1&&b.right<=box.right+1&&e.scrollWidth<=e.clientWidth+1});
        }),`${lang} ship footer including Leave ship fits ${width}×${height}`);
      }
    }
    // A second round trip exercises departure after the source reentry position.
    await page.locator('#walk-airlock').tap();
    assert((await state()).scene==='city'&&(await state()).x==='287'&&(await state()).y==='217','A second departure returns to the same exterior airlock');
    await page.locator('#walk-saves').click();await settled();
    const bad=JSON.parse(JSON.stringify(citySave));bad.state.travel.cityPosition={x:287,y:211};
    const pending=page.waitForEvent('download');
    await page.evaluate(value=>{const a=document.createElement('a');a.href=URL.createObjectURL(new Blob([JSON.stringify(value)],{type:'application/json'}));a.download='invalid-city.json';a.click();setTimeout(()=>URL.revokeObjectURL(a.href),1000)},bad);
    await (await pending).saveAs('output/playwright/remake/invalid-city.json');
    await page.locator('#checkpoint-file').setInputFiles('output/playwright/remake/invalid-city.json');await settled();
    await page.waitForFunction(()=>/Invalid|잘못/.test(document.querySelector('#checkpoint-message').textContent));
    assert(true,'A wall-position import reports validation failure');
    await page.locator('#checkpoint-back').click();
    assert((await state()).scene==='city'&&(await state()).x==='287'&&(await state()).y==='217','Invalid wall-position import leaves the current campaign intact');
    await page.goto('http://127.0.0.1:8000/tests/');await page.waitForFunction(()=>document.documentElement.dataset.result);
    const unitResults=(await page.locator('#results').innerText()).split('\n');
    assert(await page.locator('html').getAttribute('data-result')==='pass',unitResults.filter(s=>s.startsWith('FAIL')).join('\n')||'All browser rule groups pass');
    assert(errors.length===0,`No browser exceptions: ${errors.join(', ')}`);
    return {browser:browser.version(),checks,unitResults,errors};
  } catch(error) {await page.screenshot({path:'output/playwright/remake/city-walk-failure.png',animations:'disabled'});throw Error(`${error.message}; last check: ${checks.at(-1)}`)}
  finally {await context.close()}
}
