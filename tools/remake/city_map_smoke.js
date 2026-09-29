// Browser inspection uses normal UI controls; imports below only read assets.
async browserPage => {
  const browser=browserPage.context().browser(),checks=[],errors=[];
  const context=await browser.newContext({viewport:{width:1280,height:720}});
  const page=await context.newPage();
  page.on('pageerror',error=>errors.push(error.message));
  page.on('response',response=>{if(response.status()>=400)errors.push(`${response.status()} ${response.url()}`)});
  const assert=(condition,name)=>{if(!condition)throw Error(name);checks.push(name)};
  const ready=()=>page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
  const resize=async(width,height)=>{
    await page.setViewportSize({width,height});
    await page.waitForFunction(()=>Math.abs(document.querySelector('#stage').getBoundingClientRect().width-Math.min(innerWidth,innerHeight*4/3))<1);
  };
  try {
    await page.goto('http://127.0.0.1:8000/');await ready();
    if(await page.locator('html').getAttribute('lang')!=='en')await page.locator('#language').click();
    await page.locator('#explore').click();await page.locator('#nav-cities').click();
    await page.locator('#bank').selectOption('3');await page.locator('#city-mode').click();
    assert(await page.locator('.scene-heading h1').innerText()==='Drahew'&&await page.locator('#bank').count()===0,'City view names Drahew and selects banks automatically');
    await page.locator('#inspect').focus();await page.keyboard.press('Enter');
    const first=await page.locator('.selection').innerText();
    assert(first.startsWith('Column 21 · Row 13'),'Keyboard selection uses the full map coordinates');
    await page.locator('#city-right').click();
    assert(await page.locator('.selection').innerText()==='Select a point to inspect'&&await page.evaluate(()=>document.activeElement.id)==='city-right','Panning clears stale selection and preserves control focus');
    await page.locator('#inspect').focus();await page.keyboard.press('Enter');
    assert((await page.locator('.selection').innerText()).startsWith('Column 22 · Row 13'),'East moves the camera exactly one tile');
    await page.locator('#city-left').click();
    for(let i=0;i<17;i++)await page.locator('#city-left').click();
    await page.locator('#inspect').click({position:{x:2,y:2}});
    assert((await page.locator('.selection').innerText()).startsWith('Column 39 · Row 10'),'Camera wraps west across column zero');
    await page.keyboard.press('ArrowRight');await page.keyboard.press('ArrowRight');
    assert((await page.locator('.selection').innerText()).startsWith('Column 1 · Row 10'),'Selection resolves the wrapped portion of the window');
    await page.locator('#next').click();
    await page.locator('#inspect').focus();await page.keyboard.press('Enter');
    assert((await page.locator('.selection').innerText()).startsWith('Column 21 · Row 13'),'Changing city recenters the camera');
    await page.locator('#city-mode').click();
    assert(await page.locator('#bank').inputValue()==='3','Stored layout retains its manual bank selection');
    await page.locator('#city-mode').click();
    const names=await page.evaluate(async()=>{
      const data=await fetch('data/initial-economy.json').then(r=>r.json());return data.cities.map(c=>c.name);
    });
    await context.setOffline(true);
    for(let i=1;i<57;i++) {
      assert(await page.locator('.scene-heading h1').innerText()===names[i]&&await page.locator('.city-surface').count()===1,`Ordinary city ${i+1} renders in city view`);
      await page.locator('#next').click();
    }
    for(let i=58;i<=60;i++) {
      assert(await page.locator('#city-mode').isDisabled()&&await page.locator('#bank').count()===1&&await page.locator('.city-surface').count()===0,`Record ${i} stays available as a stored layout`);
      await page.locator('#next').click();
    }
    assert(await page.locator('.scene-heading h1').innerText()==='Drahew'&&await page.locator('.city-surface').count()===1,'Wraparound restores the city-view preference');
    assert(true,'All city views and stored-only fallbacks work after disconnecting the network');
    await context.setOffline(false);
    // Choose a world with a different second bank to visually review variants.
    for(let i=0;i<6;i++)await page.locator('#next').click();
    for(const lang of ['en','ko']) {
      if(await page.locator('html').getAttribute('lang')!==lang)await page.locator('#language').click();
      for(const [width,height] of [[640,480],[1280,720],[390,844],[844,390]]) {
        await resize(width,height);
        await page.locator('#inspect').focus();await page.keyboard.press('Enter');
        const selection=await page.locator('.selection').innerText();
        const fit=await page.evaluate(()=>{
          const stage=document.querySelector('#stage').getBoundingClientRect();
          const elements=[...document.querySelectorAll('#interface button,#interface select,.scene-heading,.selection,.inspect-surface')];
          return {overflow:elements.filter(el=>{const b=el.getBoundingClientRect();return !(b.left>=stage.left-1&&b.right<=stage.right+1&&b.top>=stage.top-1&&b.bottom<=stage.bottom+1&&el.scrollWidth<=el.clientWidth+1)}).map(el=>el.id||el.className),
            footer:document.querySelector('.scene-controls').getBoundingClientRect().bottom<document.querySelector('.bottomline').getBoundingClientRect().top,
            heading:document.querySelector('.scene-heading').getBoundingClientRect().bottom<=document.querySelector('#inspect').getBoundingClientRect().top,
            viewport:document.documentElement.scrollWidth===innerWidth&&document.documentElement.scrollHeight===innerHeight};
        });
        if(fit.overflow.length||!fit.footer||!fit.heading||!fit.viewport) {
          await page.screenshot({path:'output/playwright/remake/city-fit-failure.png',animations:'disabled'});
          throw Error(`${lang} ${width}×${height}: ${JSON.stringify(fit)}`);
        }
        assert(true,`${lang} city view fits ${width}×${height} without clipping or overlapping text`);
        await page.locator('#language').click();await page.locator('#language').click();
        assert(await page.locator('.selection').innerText()===selection,`${lang} locale changes preserve the camera and selected tile at ${width}×${height}`);
        await page.locator('#city-mode').click();await page.locator('#inspect').focus();await page.keyboard.press('Enter');
        const storedFits=await page.evaluate(()=>{
          const controls=document.querySelector('.scene-controls'),box=controls.getBoundingClientRect();
          return box.bottom<document.querySelector('.bottomline').getBoundingClientRect().top&&
            [...controls.querySelectorAll('button,select,p')].every(el=>{const b=el.getBoundingClientRect();return b.left>=box.left&&b.right<=box.right&&el.scrollWidth<=el.clientWidth+1});
        });
        assert(storedFits,`${lang} stored city controls fit ${width}×${height}`);
        await page.locator('#city-mode').click();
      }
      await page.screenshot({path:`output/playwright/remake/city-view-${lang}.png`,animations:'disabled'});
    }
    await resize(1280,720);
    await page.locator('#city-mode').click();
    await page.screenshot({path:'output/playwright/remake/city-stored-ko.png',animations:'disabled'});
    await page.keyboard.press('Escape');
    assert(await page.locator('#create-character').isVisible(),'Escape returns to the title');
    await page.goto('http://127.0.0.1:8000/tests/');
    await page.waitForFunction(()=>document.documentElement.dataset.result);
    const unitResults=(await page.locator('#results').innerText()).split('\n');
    assert(await page.locator('html').getAttribute('data-result')==='pass',`All ${unitResults.length} browser rule groups pass`);
    const touch=await browser.newContext({viewport:{width:390,height:844},hasTouch:true,isMobile:true});
    try {
      const p=await touch.newPage();await p.goto('http://127.0.0.1:8000/');await p.waitForFunction(()=>document.documentElement.dataset.ready);
      await p.locator('#explore').tap();await p.locator('#nav-cities').tap();await p.locator('#city-mode').tap();
      await p.locator('#city-right').tap();await p.locator('#inspect').tap({position:{x:3,y:3}});
      assert(/^(Column|열) 17/.test(await p.locator('.selection').innerText()),'Touch pans and selects the corresponding map cell');
    } finally {await touch.close()}
    assert(errors.length===0,'No browser exceptions or failed asset requests');
    return {browser:await browser.version(),checks,unitResults,errors};
  } finally {await context.close()}
}
