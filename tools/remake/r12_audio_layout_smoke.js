async browserPage => {
  const browser=browserPage.context().browser(),checks=[],errors=[],layouts=[];
  const assert=(condition,name)=>{if(!condition)throw Error(name);checks.push(name)};
  for(const viewport of [{width:1280,height:720},{width:390,height:844}]) {
    const context=await browser.newContext({viewport,locale:'en-US'});
    await context.addInitScript(() => {
      window.__audioStarts=0;
      window.AudioContext=class {
        state='running';currentTime=0;destination={};
        createGain(){return {gain:{value:0,setValueAtTime(){},linearRampToValueAtTime(){}},connect(){},disconnect(){}}}
        createOscillator(){return {frequency:{setValueAtTime(){}},connect(){},disconnect(){},start(){window.__audioStarts++},stop(){}}}
      };
    });
    const page=await context.newPage();
    page.on('pageerror',error=>errors.push(error.message));
    page.on('dialog',dialog=>dialog.accept());
    page.on('request',request=>{if(!request.url().startsWith('http://127.0.0.1:8000/'))errors.push('external request '+request.url())});
    await page.goto('http://127.0.0.1:8000/');
    await page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
    const visibleButtons=()=>page.evaluate(()=>{
      const viewport=document.querySelector('#viewport').getBoundingClientRect();
      return [...document.querySelectorAll('button')].filter(el=>!el.disabled&&el.getClientRects().length&&!el.closest('[inert]')&&getComputedStyle(el).visibility!=='hidden')
        .map(el=>{const r=el.getBoundingClientRect();return {id:el.id,left:r.left,top:r.top,right:r.right,bottom:r.bottom,inside:r.left>=viewport.left-1&&r.top>=viewport.top-1&&r.right<=viewport.right+1&&r.bottom<=viewport.bottom+1}});
    });
    const capture=async scene=>{const buttons=await visibleButtons();layouts.push({viewport,scene,buttons:buttons.map(({id,inside})=>({id,inside}))});
      assert(buttons.every(button=>button.inside),`${viewport.width} ${scene}: enabled controls inside stage`)};
    assert(await page.locator('#sound').getAttribute('aria-pressed')==='true',`${viewport.width} sound starts enabled`);
    await capture('title');
    await page.locator('#sound').click();
    assert(await page.locator('#sound').getAttribute('aria-pressed')==='false',`${viewport.width} sound mutes`);
    assert(await page.evaluate(()=>window.__audioStarts)===0,`${viewport.width} mute creates no oscillator`);
    await page.locator('#explore').click();
    assert(await page.evaluate(()=>window.__audioStarts)===0,`${viewport.width} muted navigation is silent`);
    await page.locator('#sound').click();
    assert(await page.evaluate(()=>window.__audioStarts)>0,`${viewport.width} enabling sound starts user-activated cue`);
    await page.locator('#language').click();
    const switched=await page.locator('html').getAttribute('lang');
    assert(switched==='ko',`${viewport.width} Korean switch (${switched}; errors: ${errors.join('; ')})`);
    await capture('Korean inspector');
    await page.locator('#help').click();
    await capture('Korean help');
    await page.locator('#help-sound').click();
    assert(await page.locator('#help-sound').getAttribute('aria-pressed')==='false',`${viewport.width} help can mute sound`);
    await page.locator('#help-sound').click();
    await page.locator('#close-help').click();
    await page.locator('#home').click();
    await page.locator('#create-character').click();
    await capture('Korean character');
    await page.locator('#character-name').fill('R12');
    await page.locator('#prepare-campaign').click();
    await capture('Korean campaign setup');
    if(viewport.width===390){await page.waitForTimeout(350);await page.screenshot({path:'output/playwright/remake/r12a-campaign-setup-ko-portrait.png'})}
    await page.locator('#campaign-seed').fill('12345');
    await page.locator('#start-campaign').click();
    assert(await page.locator('#walk-screen').isVisible(),`${viewport.width} campaign opens`);
    await capture('Korean ship');
    await page.locator('#walk-help').click();
    await capture('Korean campaign help');
    assert((await page.locator('.help-shade').innerText()).includes('밴빌'),`${viewport.width} campaign help describes colony objective`);
    await page.locator('#walk-close-help').click();
    await page.locator('#walk-sound').click();
    assert(await page.locator('#walk-sound').getAttribute('aria-pressed')==='false',`${viewport.width} ship mute`);
    await page.locator('#walk-saves').click();
    await page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
    await capture('Korean saves');
    assert(await page.locator('#checkpoint-sound').getAttribute('aria-pressed')==='false',`${viewport.width} saves show muted state`);
    await page.locator('#checkpoint-sound').click();
    assert(await page.locator('#checkpoint-sound').getAttribute('aria-pressed')==='true',`${viewport.width} saves can enable audio`);
    await page.locator('#checkpoint-back').click();
    await page.locator('#walk-sound').click();
    await page.reload();await page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
    assert(await page.locator('#sound').getAttribute('aria-pressed')==='false',`${viewport.width} mute survives reload`);
    await context.close();
  }
  return {browser:browser.version(),status:'pass',checks,errors,layouts};
}
