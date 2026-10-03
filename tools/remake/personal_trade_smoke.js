async browserPage => {
  const browser=browserPage.context().browser(),checks=[],errors=[];
  const context=await browser.newContext({viewport:{width:1280,height:720}}),page=await context.newPage();
  page.on('pageerror',e=>errors.push(e.message));page.on('dialog',d=>d.accept());
  const assert=(ok,name)=>{if(!ok)throw Error(name);checks.push(name)};
  const ready=()=>page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
  const settled=()=>page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
  const view=()=>page.locator('#walk-screen').getAttribute('data-dialogue');
  const saves=async()=>{await page.locator(await page.locator('#dialogue-panel').count() ? '#dialogue-saves' : '#walk-saves').click();await settled()};
  const exported=async()=>{
    await saves();const pending=page.waitForEvent('download');await page.locator('#export-checkpoint').click();
    let text='';for await(const part of await (await pending).createReadStream())text+=part;
    await settled();await page.locator('#checkpoint-back').click();return JSON.parse(text);
  };
  const reload=async()=>{
    await saves();await page.locator('#save-checkpoint-0').click();await settled();await page.reload();await ready();
    await page.locator('#campaign-saves').click();await settled();await page.locator('#load-checkpoint-0').click();await settled();await page.locator('#checkpoint-back').click();
  };
  async function fixture() {
    const pending=page.waitForEvent('download');
    await page.evaluate(async()=>{
      const [{loadAssets},{campaignSaveCodec},{createCharacter},{cityDoorAt},{cityReachability},{populateRoom},{initialRoomTraffic},{roomAt}]=await Promise.all([
        import('/js/render/assets.js'),import('/js/core/campaign-saves.js'),import('/js/core/character.js'),import('/js/core/city-doors.js'),
        import('/js/core/city-walk.js'),import('/js/core/room-actors.js'),import('/js/core/room-traffic.js'),import('/js/core/room-walk.js')]);
      const a=await loadAssets(),city=a.cityGeometry,reached=cityReachability(city);let street;
      outer:for(let y=7;y<city.height;y++)for(let x=3;x<city.width-7;x++)if(cityDoorAt(city.map,{x,y})?.type===8&&reached({x,y})){street={x,y};break outer}
      const codec=campaignSaveCodec(a.campaignContent,a.shipWalk,city),s=codec.create({...createCharacter(),name:'Visitor trade'},12345),room=roomAt(city.rooms,city.map,street);
      s.ship.position={x:54,y:118};s.ship.minutes=420;s.ship.inventory.carried=[139,235,23,0];s.dialogue.attributes=[30,40,50,30,81];
      s.dialogue.cash+=s.economy.accounts[0].balance;s.economy.accounts[0].balance=0;
      s.travel={scene:'room',cityPosition:street,roomPosition:{x:16,y:86}};
      const p=populateRoom(room,12345),traffic=initialRoomTraffic(p,room),w=traffic.actors[0].words;
      traffic.actors=[traffic.actors[0],traffic.actors.at(-1)];w.splice(0,6,86,43,86,43,86,43);w[7]=4;w[9]=0;
      s.encounters={randomState:2,roomSeed:12345,roomState:traffic,counter:{service:'idle',conversation:null}};
      const link=document.createElement('a');link.href=URL.createObjectURL(new Blob([JSON.stringify(codec.make(s,0))],{type:'application/json'}));link.download='personal-trade.json';link.click();
    });
    const path='output/playwright/remake/personal-trade.json';await(await pending).saveAs(path);
    if(await page.locator('#walk-screen').isVisible())await saves();else {await page.locator('#campaign-saves').click();await settled()}
    await page.locator('#checkpoint-file').setInputFiles(path);await settled();await page.locator('#checkpoint-back').click();
    const initial=await exported();await page.locator('#walk-talk').click();await page.locator('#dialogue-panel').waitFor();
    await page.locator('#dialogue-continue').click();await page.locator('#dialogue-reply-1').click();await page.locator('#dialogue-reply-1').click();
    assert(await view()==='130','Seated visitor reaches the source Buy/Sell menu');return initial;
  }
  try {
    await page.addInitScript(()=>localStorage.setItem('sundog.locale','en'));await page.clock.install();await page.goto('http://localhost:8000/');await ready();
    const initial=await fixture();await page.locator('#dialogue-reply-2').click();
    assert(await view()==='131','Sell asks which carried item to quote');await page.locator('#dialogue-item-0').click();
    assert(await view()==='35'&&await page.locator('#dialogue-sale').count()===0,'Quote alone has no transfer control');
    await page.locator('#dialogue-reply-0').click();
    assert(await view()==='37','Accept opens the source hand-over request');
    assert(await page.locator('[data-dialogue-sale="0"]').isEnabled()&&await page.locator('[data-dialogue-sale="1"]').isEnabled(),'Both shields match by type despite different charges');
    assert(await page.locator('[data-dialogue-sale="2"]').isDisabled()&&await page.locator('[data-dialogue-sale="3"]').isDisabled(),'Other item types and empty slots cannot be sold against this quote');
    const accepted=await exported();
    assert(accepted.state.dialogue.cash===initial.state.dialogue.cash&&JSON.stringify(accepted.state.ship.inventory)===JSON.stringify(initial.state.ship.inventory),'Accepting a quote changes neither cash nor inventory');
    for(const locale of ['en','ko']) {
      if(locale==='ko')await page.locator('#dialogue-language').click();
      for(const [width,height] of [[1280,720],[640,480],[390,844],[844,390]]) {
        await page.setViewportSize({width,height});await page.clock.runFor(50);
        await page.waitForFunction(()=>Math.abs(document.querySelector('#stage').getBoundingClientRect().width-Math.min(innerWidth,innerHeight*4/3))<1);
        assert(await page.locator('#dialogue-panel').evaluate(el=>{const r=el.getBoundingClientRect();return r.left>=0&&r.top>=0&&r.right<=innerWidth+1&&r.bottom<=innerHeight+1&&el.scrollWidth<=el.clientWidth}),`${locale} sale controls fit ${width}x${height}`);
      }
    }
    await page.screenshot({path:'output/playwright/remake/personal-sale-ko.png'});
    assert(JSON.stringify((await exported()).state)===JSON.stringify(accepted.state),'Language, resize and saves do not transfer the item or consume RNG');
    await page.setViewportSize({width:1280,height:720});await reload();
    assert(JSON.stringify((await exported()).state)===JSON.stringify(accepted.state),'Fresh page restores accepted sale before transfer');
    await page.locator('[data-dialogue-sale="1"]').focus();await page.keyboard.press('Enter');
    assert(await view()==='46','Keyboard hand-over runs the source post-sale continuation');
    const taken=await exported();assert(taken.version===20&&taken.scope==='landed-power-1'&&taken.state.encounters.counter.conversation.inputs.at(-1).type==='sale','Version20 stores the explicit sale input');
    assert(taken.state.economy.personalTrade.sold[11]===0,'Open conversation keeps sale proceeds in replay until return');
    await reload();assert(JSON.stringify((await exported()).state)===JSON.stringify(taken.state),'Fresh-page reload after hand-over preserves replay exactly');
    assert(await page.locator('#dialogue-sale').count()===0,'A completed transfer cannot be confirmed again');
    await page.locator('#dialogue-cancel').click();const done=await exported(),price=done.state.economy.personalTrade.proceeds[11];
    assert(JSON.stringify(done.state.ship.inventory.carried)==='[139,0,23,0]','Only the chosen full-charge shield leaves inventory');
    assert(done.state.economy.personalTrade.sold[11]===1&&price===600&&done.state.dialogue.cash===initial.state.dialogue.cash+price,'Return commits one sale and exactly 600 credits');
    assert(JSON.stringify(done.state.economy.accounts)===JSON.stringify(initial.state.economy.accounts)&&JSON.stringify(done.state.economy.exchange)===JSON.stringify(initial.state.economy.exchange),'Personal resale preserves bank accounts and warehouse');
    assert(done.state.dialogue.workspace.actor===2&&done.state.encounters.counter.conversation===null,'Return updates the visitor and clears replay history');
    const buyInitial=await fixture();await page.locator('#dialogue-reply-1').click();await page.locator('#dialogue-reply-0').click();
    assert(await view()==='37'&&await page.locator('[data-dialogue-purchase="3"]').isEnabled(),'Visitor purchase exposes the empty carried slot');
    await page.locator('[data-dialogue-purchase="3"]').click();const buying=await exported();await reload();
    assert(JSON.stringify((await exported()).state)===JSON.stringify(buying.state),'Visitor purchase survives fresh-page replay');
    for(let i=0;i<6&&await page.locator('#dialogue-panel').count();i++)await page.locator('#dialogue-cancel').click();
    const bought=await exported();assert(bought.state.ship.inventory.carried[3]>0&&bought.state.dialogue.cash<buyInitial.state.dialogue.cash,'Visitor purchase commits the item and cash debit');
    assert(bought.state.economy.personalTrade.sold.every(n=>n===0),'Purchasing does not record sale income');
    await fixture();await page.locator('#dialogue-reply-2').click();await page.locator('#dialogue-item-0').click();await page.locator('#dialogue-reply-0').click();
    const untransferred=await exported();for(let i=0;i<6&&await page.locator('#dialogue-panel').count();i++)await page.locator('#dialogue-cancel').click();
    const cancelled=await exported();assert(cancelled.state.dialogue.cash===untransferred.state.dialogue.cash&&JSON.stringify(cancelled.state.ship.inventory)===JSON.stringify(untransferred.state.ship.inventory)&&cancelled.state.economy.personalTrade.sold.every(n=>n===0),'Leaving before hand-over preserves the item, cash and sale ledger');
    assert(errors.length===0,'No uncaught visitor trade errors');return {browser:browser.version(),checks,errors};
  } finally {await context.close()}
}
