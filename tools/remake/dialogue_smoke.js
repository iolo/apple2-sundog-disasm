async browserPage => {
  const browser=browserPage.context().browser(),checks=[],errors=[];
  const context=await browser.newContext({viewport:{width:1280,height:720}}),page=await context.newPage();
  page.on('pageerror',e=>errors.push(e.message));page.on('dialog',d=>d.accept());
  const assert=(value,name)=>{if(!value)throw Error(name);checks.push(name)};
  const settled=()=>page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
  const exportGame=async()=>{
    await page.locator(await page.locator('#dialogue-panel').count() ? '#dialogue-saves' : '#walk-saves').click();await settled();
    const pending=page.waitForEvent('download',{timeout:3000}).catch(()=>null);await page.locator('#export-checkpoint').click();
    const downloaded=await pending;if(!downloaded)throw Error('Export failed: '+await page.locator('#checkpoint-message').innerText()+'; '+errors.join('; '));
    let text='';for await(const part of await downloaded.createReadStream())text+=part;
    await settled();await page.locator('#checkpoint-back').click();return JSON.parse(text);
  };
  try {
    await page.addInitScript(()=>localStorage.setItem('sundog.locale','en'));
    await page.clock.install();await page.goto('http://localhost:8000/');
    await page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
    const download=page.waitForEvent('download');
    await page.evaluate(async()=>{
      const [{loadAssets},{campaignSaveCodec},{createCharacter},{populateRoom},{initialRoomTraffic}]=await Promise.all([
        import('/js/render/assets.js'),import('/js/core/campaign-saves.js'),import('/js/core/character.js'),
        import('/js/core/room-actors.js'),import('/js/core/room-traffic.js')]);
      const assets=await loadAssets(),codec=campaignSaveCodec(assets.campaignContent,assets.shipWalk,assets.cityGeometry);
      const state=codec.create({...createCharacter(),name:'Counter test'},12345),room=assets.cityGeometry.rooms[15],p=populateRoom(room,12345);
      state.ship.position={x:54,y:118};state.travel={scene:'room',cityPosition:{x:311,y:267},roomPosition:{x:14,y:71}};
      state.encounters={randomState:p.randomState,roomSeed:p.seed,roomState:initialRoomTraffic(p),counter:{service:'idle',conversation:null}};
      const link=document.createElement('a');link.href=URL.createObjectURL(new Blob([JSON.stringify(codec.make(state,0))],{type:'application/json'}));link.download='dialogue-fixture.json';link.click();
    });
    await (await download).saveAs('output/playwright/remake/dialogue-fixture.json');
    await page.locator('#campaign-saves').click();await settled();
    await page.locator('#checkpoint-file').setInputFiles('output/playwright/remake/dialogue-fixture.json');await settled();
    await page.locator('#checkpoint-back').click();
    assert(await page.locator('#walk-talk').isEnabled(),'Imported controlled room fixture offers counter interaction');
    await page.locator('#walk-talk').click();await page.clock.runFor(1800);
    await page.locator('#dialogue-panel').waitFor();
    assert((await page.locator('#dialogue-text').innerText()).includes('What can'),'Staff arrival opens the original English greeting');
    await page.locator('#dialogue-reply-2').click();
    assert(await page.locator('#walk-screen').getAttribute('data-dialogue')==='160','Information reply reaches equipment information state160');
    await page.locator('#dialogue-item-0').click();
    assert(await page.locator('#walk-screen').getAttribute('data-dialogue')==='161','First item reaches its source description');
    const english=await page.locator('#dialogue-text').innerText(),saved=await exportGame();
    assert(saved.version===17&&saved.state.encounters.counter.conversation.inputs.length===2,'Mid-conversation export stores version17 replay inputs');
    await page.locator('#dialogue-language').click();
    assert(await page.locator('html').getAttribute('lang')==='ko','Conversation language switches to Korean');
    const korean=await page.locator('#dialogue-text').innerText();
    assert(/[가-힣]/.test(korean)&&korean!==english,'Same item description renders in Korean');
    assert(JSON.stringify((await exportGame()).state)===JSON.stringify(saved.state),'Locale switching and opening saves do not change conversation state');
    for(const [width,height] of [[640,480],[1280,720],[1920,1080],[390,844]]) {
      await page.setViewportSize({width,height});await page.clock.runFor(50);
      await page.waitForFunction(()=>Math.abs(document.querySelector('#stage').getBoundingClientRect().width-Math.min(innerWidth,innerHeight*4/3))<1);
      const fit=await page.locator('#dialogue-panel').evaluate(el=>{
        const r=el.getBoundingClientRect(),root=document.documentElement;
        return r.left>=0&&r.top>=0&&r.right<=innerWidth+1&&r.bottom<=innerHeight+1&&root.scrollWidth<=innerWidth&&root.scrollHeight<=innerHeight;
      });assert(fit,`Korean dialogue fits ${width}x${height}`);
    }
    await page.screenshot({path:'output/playwright/remake/dialogue-ko-390.png'});
    await page.setViewportSize({width:1280,height:720});
    await page.locator('#dialogue-saves').click();await settled();await page.locator('#save-checkpoint-0').click();await settled();
    await page.reload();await page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
    await page.locator('#campaign-saves').click();await settled();await page.locator('#load-checkpoint-0').click();await settled();await page.locator('#checkpoint-back').click();
    assert(await page.locator('#dialogue-text').innerText()===english,'Reload restores exact English message from the saved seed and inputs');
    assert(JSON.stringify((await exportGame()).state)===JSON.stringify(saved.state),'Fresh page restores all mid-conversation campaign fields');
    await page.locator('#dialogue-continue').click();
    assert(await page.locator('#walk-screen').getAttribute('data-dialogue')==='162','Continue advances the information branch');
    await page.locator('#dialogue-cancel').click();await page.locator('#dialogue-cancel').click();
    assert(await page.locator('#dialogue-panel').count()===0,'Leaving the conversation restores the room');
    const returned=await exportGame();assert(returned.state.encounters.counter.service==='served'&&returned.state.encounters.counter.conversation===null,'Return commits speaker state and clears replay history');
    assert(returned.state.start.credits===saved.state.start.credits&&JSON.stringify(returned.state.ship.inventory)===JSON.stringify(saved.state.ship.inventory),'Information dialogue preserves money and inventory');
    assert(errors.length===0,'No uncaught browser errors');
    return {browser:browser.version(),checks,errors,branch:{english,korean}};
  } finally {await context.close()}
}
