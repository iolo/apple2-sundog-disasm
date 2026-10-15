// Clear the first phase-eight homeworld pirate with Comm and a charged laser.
async browserPage => {
  const browser=browserPage.context().browser(),checks=[],errors=[],samples=[];
  const context=await browser.newContext({viewport:{width:1280,height:720}}),page=await context.newPage();
  page.on('pageerror',e=>errors.push(e.stack||e.message));page.on('dialog',d=>d.accept());
  const assert=(ok,name)=>{if(!ok)throw Error(name);checks.push(name)};
  const ready=()=>page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
  const settled=()=>page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
  const state=()=>page.locator('#walk-screen').evaluate(el=>({...el.dataset}));
  const saves=async()=>{await page.locator((await page.locator('#navigation-panel').count())?'#nav-saves':
    (await page.locator('#space-panel').count())?'#space-saves':'#walk-saves').click();await settled()};
  const exported=async(path=null)=>{await saves();const pending=page.waitForEvent('download');await page.locator('#export-checkpoint').click();const download=await pending;if(path)await download.saveAs(path);let text='';for await(const part of await download.createReadStream())text+=part;await settled();await page.locator('#checkpoint-back').click();return JSON.parse(text)};
  const reload=async()=>{const before=await exported();await saves();await page.locator('#save-checkpoint-0').click();await settled();await page.reload();await ready();await page.locator('#campaign-saves').click();await settled();await page.locator('#load-checkpoint-0').click();await settled();await page.locator('#checkpoint-back').click();const after=await exported();assert(JSON.stringify(after.state)===JSON.stringify(before.state),'Fresh-page save reload preserves the pirate result');return after};
  try{
    await page.addInitScript(()=>localStorage.setItem('sundog.locale','en'));
    await page.clock.install({time:new Date('2026-10-16T00:00:00Z')});await page.clock.pauseAt(new Date('2026-10-16T00:00:01Z'));
    await page.goto('http://127.0.0.1:8000/');await ready();
    await page.locator('#create-character').click();await page.locator('#character-name').fill('Import shell');
    await page.locator('#prepare-campaign').click();await page.locator('#campaign-seed').fill('1');await page.locator('#start-campaign').click();
    await page.locator('#walk-saves').click();await settled();
    await page.locator('#checkpoint-file').setInputFiles('output/playwright/remake/r11-phase-eight-city49-home-approach-contact.json');
    await page.waitForFunction(()=>/imported/i.test(document.querySelector('#checkpoint-message')?.textContent||''));
    await page.locator('#checkpoint-back').click();
    const original=(await exported()).state;
    assert(original.space.flags[40]&&original.resources.shields.charge===255&&original.resources.hull===16&&
      original.pod.cargo.map(c=>c?.commodityId).sort().join(',')==='cargo-02,cargo-31',
      'The protected paid pair resumes at the first homeworld pirate contact');
    if(await page.locator('#navigation-panel').count())await page.locator('#nav-tactical').click();
    else {await page.locator('#walk-navigation').click();await page.locator('#nav-tactical').click()}
    await page.locator('#space-comm').click();await page.locator('#dialogue-reply-0').click();await page.locator('#dialogue-cancel').click();
    assert((await exported()).state.space.communication.pending,'Ordinary Comm opens a safe aiming interval');
    await page.locator('#space-guns').click();await page.locator('#space-laser').click();
    const box=await page.locator('#space-surface').boundingBox();
    const move=async(dx,dy)=>page.mouse.move(box.x+box.width*(.5+Math.max(-7.9,Math.min(7.9,dx))/16),
      box.y+box.height*(.5+Math.max(-7.9,Math.min(7.9,dy))/16));
    if((await state()).paused==='true')await page.locator('#space-run').click();
    await move(8,8);await page.mouse.down({button:'right'});
    let held=true,current=await state(),shots=0,hits=0;
    for(let i=0;i<450&&current.contact==='true';i++){
      if(current.paused==='true')await page.locator('#space-run').click();
      const x=Number(current.shipTargetX),y=Number(current.shipTargetY),range=Number(current.shipRange);
      const miss=Math.abs(x-512)+Math.abs(y-512),tolerance=Math.max(0,4-(range>>5));
      if(Number(current.shipGun)>=224&&Math.abs(x-512)+Math.abs(y+2-512)<=tolerance){
        const beforeHealth=Number(current.shipHealth);
        if(held){await page.mouse.up({button:'right'});held=false}
        await page.locator('#space-fire').focus();await page.keyboard.press('Enter');
        await page.clock.runFor(200);shots++;
        current=await state();
        if(Number(current.shipHealth)<beforeHealth)hits++;
        samples.push({i,x,y,range,miss,shots,hits,gun:Number(current.shipGun),paused:current.paused,
          enemy:Number(current.shipHealth),hull:Number(current.shipHull)});
        if(current.contact!=='true')break;
        if(current.paused==='true')await page.locator('#space-run').click();
        await move(0,0);await page.mouse.down({button:'right'});held=true;
      }else{
        const dx=Math.max(-8,Math.min(8,Math.round((512-x)/4))),
          dy=Math.max(-8,Math.min(8,Math.round((510-y)/4)));
        await move(dx,dy);await page.clock.runFor(50);
        current=await state();
        if(i%5===0||miss<=8)samples.push({i,x:Number(current.shipTargetX),y:Number(current.shipTargetY),range:Number(current.shipRange),
          miss:Math.abs(Number(current.shipTargetX)-512)+Math.abs(Number(current.shipTargetY)-512),
          gun:Number(current.shipGun),paused:current.paused,enemy:Number(current.shipHealth),hull:Number(current.shipHull),shots,hits});
      }
      if(current.dead==='true')throw Error(`Ship destroyed while pointer-aiming: ${JSON.stringify({shots,hits,miss})}`);
    }
    if(held)await page.mouse.up({button:'right'});
    assert(shots>0&&hits>0,'Fine pointer aiming scores at least one live laser hit');
    const won=(await reload()).state;
    assert(!won.space.flags[40]&&!won.space.defeat&&won.resources.hull>0&&
      won.pod.cargo.map(c=>c?.commodityId).sort().join(',')==='cargo-02,cargo-31',
      'Ordinary precision fire clears the pirate without losing either lot');
    const checkpoint=await exported('output/playwright/remake/r11-phase-eight-city49-home-contact-cleared.json');
    assert(JSON.stringify(checkpoint.state)===JSON.stringify(won),'The precise-contact checkpoint exports unchanged');
    assert(errors.length===0,'No uncaught errors during pointer-aimed pirate combat');
    return{browser:browser.version(),checks,errors,failures:[],samples,journey:{minutes:won.ship.minutes,
      hull:won.resources.hull,shield:won.resources.shields.charge,shots,hits,enemy:won.space.words[216],cargo:won.pod.cargo}};
  }catch(error){await page.screenshot({path:'output/playwright/remake/r11-phase-eight-city49-home-precise-pirate-error.png'});return{browser:browser.version(),checks,errors,failures:[error.stack||error.message],samples}}
  finally{await context.close()}
}
