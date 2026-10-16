async browserPage => {
  const browser=browserPage.context().browser(),checks=[],errors=[],layouts=[];
  const files=[
    ['colony ending','output/playwright/remake/r11-phase-nine-cryo57-delivered.json'],
    ['exchange','output/playwright/remake/r11-phase-nine-city17-radio-furs-loaded.json'],
    ['bank','output/playwright/remake/r11-phase-eight-city52-system10-funded.json'],
    ['depot','output/playwright/remake/r11-phase-five-city01-depot.json'],
    ['room','output/playwright/remake/r11-phase-eight-city01-gun-node-handover.json'],
    ['surface','output/playwright/remake/r11-phase-three-world08-surface.json'],
    ['tactical','output/playwright/remake/space-fixture.json'],
    ['ground combat','output/playwright/remake/r11-phase-four-pilotage-ground-combat.json'],
  ];
  for(const [name,file] of files)for(const locale of ['en','ko']) {
    const context=await browser.newContext({viewport:{width:1280,height:720},locale:locale==='ko'?'ko-KR':'en-US'}),page=await context.newPage();
    page.on('pageerror',error=>errors.push(`${name} ${locale}: ${error.message}`));page.on('dialog',dialog=>dialog.accept());
    page.on('request',request=>{if(!request.url().startsWith('http://127.0.0.1:8000/'))errors.push(`${name} ${locale}: external request ${request.url()}`)});
    await page.goto('http://127.0.0.1:8000/');await page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
    await page.locator('#create-character').click();await page.locator('#character-name').fill('R12 inspector');
    await page.locator('#prepare-campaign').click();await page.locator('#campaign-seed').fill('1');await page.locator('#start-campaign').click();
    await page.locator('#walk-saves').click();await page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
    await page.locator('#checkpoint-file').setInputFiles(file);
    try {await page.waitForFunction(()=>/imported|가져왔습니다/i.test(document.querySelector('#checkpoint-message')?.textContent||''),null,{timeout:5000})}
    catch {throw Error(`${name} ${locale}: import message ${await page.locator('#checkpoint-message').innerText()}`)}
    await page.locator('#checkpoint-back').click();
    for(const viewport of [{width:1280,height:720},{width:390,height:844}]){
      await page.setViewportSize(viewport);
      await page.waitForFunction(width=>window.innerWidth===width,viewport.width);
      const buttons=await page.evaluate(()=>{
        const v=document.querySelector('#viewport').getBoundingClientRect();
        return [...document.querySelectorAll('button')].filter(el=>!el.disabled&&el.getClientRects().length&&!el.closest('[inert]')&&getComputedStyle(el).visibility!=='hidden')
          .map(el=>{const r=el.getBoundingClientRect(),inside=r.left>=v.left-1&&r.right<=v.right+1&&r.top>=v.top-1&&r.bottom<=v.bottom+1;
            let scroll=el.parentElement,reachable=false;
            while(scroll&&!reachable&&scroll!==document.body){const style=getComputedStyle(scroll),s=scroll.getBoundingClientRect();
              reachable=/auto|scroll/.test(style.overflowY)&&scroll.scrollHeight>scroll.clientHeight&&s.left>=v.left-1&&s.right<=v.right+1&&s.top>=v.top-1&&s.bottom<=v.bottom+1;
              scroll=scroll.parentElement}
            return {id:el.id,inside,reachable:inside||reachable,rect:[r.left,r.top,r.right,r.bottom]}});
      });
      layouts.push({name,locale,viewport,buttons:buttons.map(button=>({id:button.id,reachable:button.reachable}))});
      const outside=buttons.filter(button=>!button.reachable).map(button=>button.id);
      if(outside.length)throw Error(`${name} ${locale} ${viewport.width}: clipped controls ${outside.join(', ')}`);
      checks.push(`${name} ${locale} ${viewport.width}: ${buttons.length} enabled controls inside stage`);
      if(viewport.width===390)await page.screenshot({path:`output/playwright/remake/r12a-${name.replace(/ /g,'-')}-${locale}-portrait.png`});
      if(name==='exchange'&&viewport.width===390&&await page.locator('#exchange-row-7').isEnabled()){
        await page.locator('#exchange-row-7').click();
        if(!await page.locator('#exchange-cancel').isVisible())throw Error('Scrolled exchange row cannot open review');
        await page.locator('#exchange-cancel').click();
        checks.push(`exchange ${locale}: bottom offer reached through bounded scrolling`);
      }
      if(name==='exchange'&&viewport.width===390){
        await page.locator('#modal-sound').click();
        if(await page.locator('#modal-sound').getAttribute('aria-pressed')!=='false')throw Error('Exchange modal sound did not mute');
        await page.locator('#modal-sound').click();
        checks.push(`exchange ${locale}: sound toggle works inside modal`);
      }
    }
    await context.close();
  }
  return {browser:browser.version(),status:'pass',checks,errors,layouts};
}
