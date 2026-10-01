async browserPage => {
  const browser=browserPage.context().browser(),checks=[],errors=[];
  const context=await browser.newContext({viewport:{width:1280,height:720}}),page=await context.newPage();
  page.on('pageerror',e=>errors.push(e.message));page.on('dialog',d=>d.accept());
  const assert=(value,name)=>{if(!value)throw Error(name);checks.push(name)};
  const settled=()=>page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
  const exportGame=async()=>{
    await page.locator(await page.locator('#dialogue-panel').count() ? '#dialogue-saves' : '#walk-saves').click();await settled();
    const pending=page.waitForEvent('download',{timeout:3000});await page.locator('#export-checkpoint').click();
    let text='';for await(const part of await (await pending).createReadStream())text+=part;
    await settled();await page.locator('#checkpoint-back').click();return JSON.parse(text);
  };
  const reload=async()=>{
    await page.locator('#dialogue-saves').click();await settled();await page.locator('#save-checkpoint-0').click();await settled();
    await page.reload();await page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
    await page.locator('#campaign-saves').click();await settled();await page.locator('#load-checkpoint-0').click();await settled();await page.locator('#checkpoint-back').click();
  };
  async function fixture(mode) {
    const download=page.waitForEvent('download');
    await page.evaluate(async mode=>{
      const [{loadAssets},{campaignSaveCodec},{createCharacter},{populateRoom},{initialRoomTraffic}]=await Promise.all([
        import('/js/render/assets.js'),import('/js/core/campaign-saves.js'),import('/js/core/character.js'),
        import('/js/core/room-actors.js'),import('/js/core/room-traffic.js')]);
      const assets=await loadAssets(),codec=campaignSaveCodec(assets.campaignContent,assets.shipWalk,assets.cityGeometry);
      const s=codec.create({...createCharacter(),name:'Purchase test'},12345),room=assets.cityGeometry.rooms[15],p=populateRoom(room,12345);
      s.ship.position={x:54,y:118};s.travel={scene:'room',cityPosition:{x:311,y:267},roomPosition:{x:14,y:71}};
      s.encounters={randomState:p.randomState,roomSeed:p.seed,roomState:initialRoomTraffic(p),counter:{service:'idle',conversation:null}};
      s.ship.inventory.carried=mode==='full' ? [12,141,139,140] : [0,0,139,140];
      if(mode==='poor')s.dialogue.cash=0;
      else {s.dialogue.cash+=s.economy.accounts[0].balance;s.economy.accounts[0].balance=0}
      const link=document.createElement('a');link.href=URL.createObjectURL(new Blob([JSON.stringify(codec.make(s,0))],{type:'application/json'}));link.download='shop-fixture.json';link.click();
    },mode);
    await (await download).saveAs('output/playwright/remake/shop-fixture.json');
    await page.locator(await page.locator('#walk-screen').isVisible() ? '#walk-saves' : '#campaign-saves').click();await settled();
    await page.locator('#checkpoint-file').setInputFiles('output/playwright/remake/shop-fixture.json');await settled();await page.locator('#checkpoint-back').click();
    const initial=await exportGame();
    await page.locator('#walk-talk').click();await page.clock.runFor(1800);await page.locator('#dialogue-panel').waitFor();
    return initial;
  }
  const accept=async()=>{await page.locator('#dialogue-item-0').click();await page.locator('#dialogue-reply-1').click()};
  try {
    await page.addInitScript(()=>localStorage.setItem('sundog.locale','en'));
    await page.clock.install();await page.goto('http://localhost:8000/');await page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
    const initial=await fixture('ready');await page.locator('#dialogue-item-0').click();
    assert(await page.locator('#dialogue-purchase').count()===0,'A quote does not transfer goods');
    assert(await page.locator('#dialogue-reply-1').isEnabled(),'Shop Buy reply is enabled');
    await page.locator('#dialogue-reply-1').click();
    const offered=await exportGame();
    assert(JSON.stringify(offered.state.ship.inventory)===JSON.stringify(initial.state.ship.inventory)&&offered.state.dialogue.cash===initial.state.dialogue.cash,'Accepting a quote leaves payment and inventory unchanged');
    assert(await page.locator('[data-dialogue-purchase="0"]').isEnabled()&&await page.locator('[data-dialogue-purchase="2"]').isDisabled(),'Only empty carried destinations can be chosen');
    for(const locale of ['en','ko']) {
      if(locale==='ko')await page.locator('#dialogue-language').click();
      for(const [width,height] of [[1280,720],[640,480],[390,844],[844,390]]) {
        await page.setViewportSize({width,height});await page.clock.runFor(50);
        await page.waitForFunction(()=>Math.abs(document.querySelector('#stage').getBoundingClientRect().width-Math.min(innerWidth,innerHeight*4/3))<1);
        assert(await page.locator('#dialogue-panel').evaluate(el=>{const r=el.getBoundingClientRect();return r.left>=0&&r.top>=0&&r.right<=innerWidth+1&&r.bottom<=innerHeight+1&&el.scrollWidth<=el.clientWidth}),`${locale} purchase controls fit ${width}x${height}`);
      }
    }
    await page.screenshot({path:'output/playwright/remake/shop-purchase-ko.png'});
    assert(JSON.stringify((await exportGame()).state)===JSON.stringify(offered.state),'Language and viewport changes preserve the offer and RNG');
    await page.setViewportSize({width:1280,height:720});await reload();
    assert(JSON.stringify((await exportGame()).state)===JSON.stringify(offered.state),'Fresh-page reload restores the accepted offer');
    await page.locator('[data-dialogue-purchase="0"]').focus();await page.keyboard.press('Enter');
    assert(await page.locator('#walk-screen').getAttribute('data-dialogue')==='83','Keyboard purchase returns to the source equipment-shop root');
    const bought=await exportGame();
    assert(bought.version===15&&bought.scope==='landed-personal-trade-1'&&bought.state.encounters.counter.conversation.inputs.at(-1).type==='purchase','Version15 stores the explicit purchase input');
    await reload();assert(JSON.stringify((await exportGame()).state)===JSON.stringify(bought.state),'Fresh-page reload after transfer preserves replay and RNG');
    await accept();assert(await page.locator('[data-dialogue-purchase="0"]').isDisabled(),'Replayed purchase occupies its destination');
    const working=await page.locator('#dialogue-purchase').innerText();assert(working.includes('Cash:'),'Purchase panel shows working cash after the prior transfer');
    await page.locator('[data-dialogue-purchase="1"]').click();await page.locator('#dialogue-cancel').click();
    const ended=await exportGame();
    assert(JSON.stringify(ended.state.ship.inventory.carried)==='[23,23,139,140]','Leaving commits both transfers without changing existing charge bytes');
    assert(ended.state.dialogue.cash<initial.state.dialogue.cash&&JSON.stringify(ended.state.economy)===JSON.stringify(initial.state.economy),'Shop payment uses cash and preserves bank accounts and warehouse');
    assert(ended.state.encounters.counter.conversation===null,'Completed conversation removes replay history');
    for(const mode of ['poor','full']) {
      const before=await fixture(mode);await accept();
      assert(await page.locator('[data-dialogue-purchase]:enabled').count()===0,`${mode} purchase has no enabled destination`);
      assert((await page.locator('#dialogue-purchase').innerText()).includes(mode==='poor' ? 'Not enough cash' : 'No empty carried slot'),`${mode} purchase explains the failure`);
      await page.locator('#dialogue-cancel').click();
      // A source cancellation can ask whether to continue; finish through its ordinary timeout/cancel path.
      for(let i=0;i<5&&await page.locator('#dialogue-panel').count();i++)await page.locator('#dialogue-cancel').click();
      const after=await exportGame();assert(after.state.dialogue.cash===before.state.dialogue.cash&&JSON.stringify(after.state.ship.inventory)===JSON.stringify(before.state.ship.inventory),`${mode} cancellation preserves cash and inventory`);
    }
    assert(errors.length===0,'No uncaught purchase UI errors');return {browser:browser.version(),checks,errors};
  } finally {await context.close()}
}
