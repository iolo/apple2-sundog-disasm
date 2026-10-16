// Reopen saved milestones from the ordinary R11 journey in the release build.
async browserPage => {
  const browser=browserPage.context().browser(),checks=[],errors=[];
  const stages=[
    ['phase one','output/playwright/remake/r11-phase-one-checkpoint.json',2,4],
    ['phase two','output/playwright/remake/r11-phase-two-complete.json',3,10],
    ['phase five','output/playwright/remake/r11-phase-five-complete.json',6,30],
    ['phase eight','output/playwright/remake/r11-phase-eight-complete.json',9,53],
    ['ending','output/playwright/remake/r11-phase-nine-cryo57-delivered.json',10,61],
  ];
  const assert=(condition,name)=>{if(!condition)throw Error(name);checks.push(name)};
  const activeLayout=async(page,name,locale)=>{
    const layout=await page.locator('#service-panel').evaluate(panel=>{
      const box=element=>{const r=element.getBoundingClientRect();return {left:r.left,top:r.top,right:r.right,bottom:r.bottom}};
      const stage=box(document.querySelector('#stage')),outer=box(panel),req=box(panel.querySelector('#colony-requirements')),
        hint=box([...panel.children].find(node=>node.tagName==='P'&&!node.id)),cargo=box(panel.querySelector('.cargo-columns')),
        message=box(panel.querySelector('#colony-message')),footer=box(panel.querySelector('footer'));
      return {fits:outer.left>=stage.left-1&&outer.right<=stage.right+1&&outer.top>=stage.top-1&&outer.bottom<=stage.bottom+1,
        ordered:req.bottom<=hint.top+1&&hint.bottom<=cargo.top+1&&cargo.bottom<=message.top+1&&message.bottom<=footer.top+1&&footer.bottom<=outer.bottom+1};
    });
    assert(layout.fits&&layout.ordered,`${name}: ${locale} Center sections do not overlap`);
    await page.locator('#colony-requirements > div').last().scrollIntoViewIfNeeded();
    await page.locator('.cargo-columns .colony-lot').last().scrollIntoViewIfNeeded();
    const reached=await page.locator('.cargo-columns .colony-lot').last().evaluate(row=>{
      const r=row.getBoundingClientRect(),c=row.closest('.cargo-columns').getBoundingClientRect();
      return r.top>=c.top-1&&r.bottom<=c.bottom+1;
    });
    assert(reached,`${name}: ${locale} last cargo row is scroll-reachable`);
  };
  for(const [name,file,phase,receipts] of stages) {
    const context=await browser.newContext({viewport:{width:1280,height:720},locale:'en-US'}),page=await context.newPage();
    page.on('pageerror',error=>errors.push(`${name}: ${error.message}`));
    page.on('dialog',dialog=>dialog.accept());
    await page.goto('http://127.0.0.1:8000/');await page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
    await page.locator('#create-character').click();await page.locator('#character-name').fill('R13');
    await page.locator('#prepare-campaign').click();await page.locator('#campaign-seed').fill('1');
    await page.locator('#start-campaign').click();await page.locator('#walk-saves').click();
    await page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
    await page.locator('#checkpoint-file').setInputFiles(file);
    await page.waitForFunction(()=>/imported/i.test(document.querySelector('#checkpoint-message')?.textContent||''));
    await page.locator('#checkpoint-back').click();
    assert(await page.locator('#service-panel').isVisible(),`${name}: imported Center is reachable`);
    if(phase===10)assert((await page.locator('#colony-ending-summary').innerText()).includes(String(receipts)),`${name}: ${receipts} deliveries visible`);
    else {assert((await page.locator('#colony-phase').innerText()).startsWith(`Phase ${phase} `),`${name}: phase ${phase} visible`);
      await activeLayout(page,name,'English desktop')}
    await page.locator('#service-language').click();
    assert(await page.locator('html').getAttribute('lang')==='ko',`${name}: Korean switch preserves the Center`);
    if(phase===10)assert((await page.locator('#colony-ending-summary').innerText()).includes(String(receipts)),`${name}: Korean ending retains ${receipts} deliveries`);
    else assert((await page.locator('#colony-phase').innerText()).startsWith(`${phase}단계`),`${name}: Korean phase ${phase} retained`);
    await page.setViewportSize({width:390,height:844});
    if(phase<10)await activeLayout(page,name,'Korean portrait');
    if(['phase five','ending'].includes(name))await page.screenshot({path:`output/playwright/remake/r13-${name.replace(/ /g,'-')}-ko.png`});
    await page.locator('#service-saves').click();
    await page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
    assert(await page.locator('#save-checkpoint-0').isEnabled(),`${name}: imported campaign validates for slot save`);
    await page.locator('#save-checkpoint-0').click();
    await page.waitForFunction(()=>/saved|저장했습니다/i.test(document.querySelector('#checkpoint-message')?.textContent||''));
    const exportState=async()=>{
      const pending=page.waitForEvent('download');await page.locator('#export-checkpoint').click();
      const download=await pending;let raw='';for await(const part of await download.createReadStream())raw+=part;
      await page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
      return JSON.parse(raw);
    };
    const before=await exportState();
    assert(before.version===30&&before.scope==='colony-contract-1'&&before.state.colony.activePhase===phase&&
      before.state.colony.receipts.length===receipts&&before.state.travel.scene==='colony',
      `${name}: version30 export retains phase ${phase} and ${receipts} receipts`);
    await page.reload();await page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
    await page.locator('#campaign-saves').click();
    await page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
    await page.locator('#load-checkpoint-0').click();
    await page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
    await page.locator('#checkpoint-back').click();
    assert(await page.locator('#service-panel').isVisible(),`${name}: fresh-page save resumes Center`);
    await page.locator('#service-saves').click();
    await page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
    const after=await exportState();
    assert(JSON.stringify(after.state)===JSON.stringify(before.state),`${name}: complete campaign state survives fresh-page reload`);
    await context.close();
  }
  assert(!errors.length,`No browser errors: ${errors.join('; ')}`);
  return {browser:browser.version(),status:'pass',checks,errors};
}
