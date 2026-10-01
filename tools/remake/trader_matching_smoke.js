// Seeded pre-request tavern fixture; every referral, walk, arrival and trade uses UI.
async browserPage => {
  const browser=browserPage.context().browser(),checks=[],errors=[];
  const context=await browser.newContext({viewport:{width:1280,height:720}}),page=await context.newPage();
  page.on('pageerror',e=>errors.push(e.message));page.on('dialog',d=>d.accept());
  const assert=(ok,name)=>{if(!ok)throw Error(name);checks.push(name)};
  const ready=()=>page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
  const settled=()=>page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
  const state=()=>page.locator('#walk-screen').evaluate(el=>({...el.dataset}));
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
    const pending=page.waitForEvent('download');pending.catch(()=>{});
    await page.evaluate(async()=>{
      const [{loadAssets},{campaignSaveCodec},{createCharacter},{cityDoorAt},{cityReachability},{populateRoom},{initialRoomTraffic},{roomAt},{createRoomCounter,openRoomCounter}]=await Promise.all([
        import('/js/render/assets.js'),import('/js/core/campaign-saves.js'),import('/js/core/character.js'),import('/js/core/city-doors.js'),
        import('/js/core/city-walk.js'),import('/js/core/room-actors.js'),import('/js/core/room-traffic.js'),import('/js/core/room-walk.js'),import('/js/core/room-counter.js')]);
      const a=await loadAssets(),city=a.cityGeometry,reached=cityReachability(city);let street;
      outer:for(let y=7;y<city.height;y++)for(let x=3;x<city.width-7;x++)if(cityDoorAt(city.map,{x,y})?.type===8&&reached({x,y})){street={x,y};break outer}
      const codec=campaignSaveCodec(a.campaignContent,a.shipWalk,city),s=codec.create({...createCharacter(),name:'Trader pilot'},12345),room=roomAt(city.rooms,city.map,street);
      s.ship.position={x:54,y:118};s.ship.minutes=420;s.ship.inventory.carried=[139,235,0,0];s.dialogue.attributes=[30,40,50,30,81];
      s.dialogue.cash+=5000;s.economy.accounts[0].balance-=5000;
      s.travel={scene:'room',cityPosition:street,roomPosition:{x:30,y:31}};
      const p=populateRoom(room,0),traffic=initialRoomTraffic(p,room);traffic.actors=[traffic.actors.at(-1)];traffic.waiting=0;
      let frame=createRoomCounter(room,traffic,13,s.travel.roomPosition);frame.service='talking';
      frame=openRoomCounter(a.campaignContent.dialogue,room,frame,{...s.dialogue,system:a.campaignContent.dialogue.systems.systems[0],
        carried:s.ship.inventory.carried,city:1,hour:7,surface:s.start.playerLocation.surfacePosition});
      s.encounters={randomState:frame.randomState,roomSeed:0,roomState:frame.traffic,counter:{service:'talking',conversation:{seed:13,inputs:[]}}};
      const link=document.createElement('a');link.href=URL.createObjectURL(new Blob([JSON.stringify(codec.make(s,0))],{type:'application/json'}));link.download='trader-matching.json';link.click();
    });
    const path='output/playwright/remake/trader-matching.json';await(await pending).saveAs(path);
    if(await page.locator('#walk-screen').isVisible())await saves();else {await page.locator('#campaign-saves').click();await settled()}
    await page.locator('#checkpoint-file').setInputFiles(path);await settled();await page.locator('#checkpoint-back').click();
    return exported();
  }
  const walk=async(x,y)=>{
    if((await state()).paused==='true')await page.locator('#walk-pause').click();
    const box=await page.locator('#stage').boundingBox();
    await page.mouse.move(box.x+(145+(x+3.25)*2.5)*box.width/640,box.y+(126+(y-2.75)*2.5)*box.height/480);
    await page.mouse.down();
    for(let i=0;i<200;i++){await page.clock.runFor(50);const p=await state();if((Number(p.x)===x&&Number(p.y)===y)||p.dialogue)break}
    await page.mouse.up();
    const p=await state();assert(Number(p.x)===x&&Number(p.y)===y,`Walk to trader seating reaches ${x},${y} (actual ${p.x},${p.y}; dialogue ${p.dialogue})`);
  };
  async function request(selling,waitForTrader=true) {
    const initial=await fixture();
    await page.locator('#dialogue-reply-2').click();await page.locator('#dialogue-reply-2').click();
    await page.locator('[data-dialogue-offer="increase"][data-step="10"]').click();await page.locator('#dialogue-reply-2').click();
    assert(await view()==='26'&&await page.locator('#dialogue-reply-1').isEnabled()&&await page.locator('#dialogue-reply-2').isEnabled(),'Bartender Buy and Sell referrals are enabled');
    await page.locator(selling?'#dialogue-reply-2':'#dialogue-reply-1').click();
    await page.locator(selling?'[data-dialogue-item="139"]':'[data-dialogue-item="15"]').click();
    assert(await view()==='29','Bartender asks the player to sit after selecting an item');await page.locator('#dialogue-continue').click();
    const pending=await exported();assert(pending.state.dialogue.flags[65]&&pending.state.dialogue.flags[66]===selling&&pending.state.dialogue.workspace.item===(selling?139:15),'Request stores item and trading direction');
    assert(pending.state.dialogue.cash===initial.state.dialogue.cash-10&&JSON.stringify(pending.state.ship.inventory)===JSON.stringify(initial.state.ship.inventory),'Referral only charges the tip and does not transfer an item');
    await reload();assert(JSON.stringify((await exported()).state)===JSON.stringify(pending.state),'Pending referral survives a fresh-page reload');
    if(!waitForTrader)return {initial,pending};
    await walk(30,60);await walk(53,60);await walk(53,86);
    if((await state()).paused==='true')await page.locator('#walk-pause').click();
    for(let i=0;i<300&&!await page.locator('#dialogue-panel').count();i++)await page.clock.runFor(250);
    assert(await view()==='32','A visitor walks to the opposite seat and opens the referred-trader dialogue');
    const contact=await exported();assert(contact.state.encounters.roomState.tavern.contact.kind===17,'Referred conversation belongs to a live kind17 actor');
    await reload();assert(JSON.stringify((await exported()).state)===JSON.stringify(contact.state),'Referred actor and dialogue replay survive reload');
    return {initial,pending,contact};
  }
  try {
    await page.addInitScript(()=>localStorage.setItem('sundog.locale','en'));await page.clock.install({time:new Date('2026-10-01T00:00:00Z')});await page.clock.pauseAt(new Date('2026-10-01T00:00:01Z'));
    await page.goto('http://127.0.0.1:8000/');await ready();
    for(const selling of [true,false]) {
      const {pending}=await request(selling);
      await page.locator('#dialogue-reply-1').click();assert(await view()===(selling?'35':'34'),'Trader quotes the requested direction');
      await page.locator('#dialogue-reply-0').click();assert(await view()==='37','Acceptance opens explicit handover controls');
      const offer=await exported();
      if(selling) {
        assert(await page.locator('[data-dialogue-sale="0"]').isEnabled()&&await page.locator('[data-dialogue-sale="1"]').isEnabled(),'Requested shield accepts either charge level');
        assert(await page.locator('[data-dialogue-sale="2"]').isDisabled(),'Empty slots cannot fulfill the sale');
        for(const locale of ['en','ko']) {
          if(locale==='ko')await page.locator('#dialogue-language').click();
          for(const [width,height] of [[1280,720],[640,480],[390,844],[844,390]]) {
            await page.setViewportSize({width,height});await page.clock.runFor(50);
            assert(await page.locator('#dialogue-panel').evaluate(el=>{const r=el.getBoundingClientRect();return r.left>=0&&r.top>=0&&r.right<=innerWidth+1&&r.bottom<=innerHeight+1&&el.scrollWidth<=el.clientWidth&&[...el.querySelectorAll('button')].every(b=>{const q=b.getBoundingClientRect();return q.top>=r.top&&q.bottom<=r.bottom})}),`${locale} referral trade controls fit ${width}x${height}`);
          }
        }
        await page.screenshot({path:'output/playwright/remake/trader-matching-ko.png'});await page.setViewportSize({width:1280,height:720});
      }
      assert(JSON.stringify((await exported()).state)===JSON.stringify(offer.state),'Offer presentation and language changes preserve campaign state');
      await page.locator(selling?'[data-dialogue-sale="1"]':'[data-dialogue-purchase="2"]').focus();await page.keyboard.press('Enter');
      const paid=await exported();await reload();assert(JSON.stringify((await exported()).state)===JSON.stringify(paid.state),'Transferred item replays exactly after reload');
      for(let i=0;i<6&&await page.locator('#dialogue-panel').count();i++)await page.locator('#dialogue-cancel').click();
      const done=await exported();assert(!done.state.dialogue.flags[65]&&!done.state.dialogue.flags[66]&&done.state.dialogue.workspace.item===0,'Trade return clears the referral');
      assert(selling?JSON.stringify(done.state.ship.inventory.carried)==='[139,0,0,0]':(done.state.ship.inventory.carried[2]&31)===15,'Only the selected item slot changes');
      assert(selling?done.state.dialogue.cash>pending.state.dialogue.cash:done.state.dialogue.cash<pending.state.dialogue.cash,'Cash changes in the correct direction');
      assert(done.state.economy.personalTrade.sold[11]===(selling?1:0),'Gross sale ledger commits exactly once');
      assert(JSON.stringify(done.state.economy.accounts)===JSON.stringify(pending.state.economy.accounts)&&JSON.stringify(done.state.economy.exchange)===JSON.stringify(pending.state.economy.exchange),'Referral trades preserve accounts and cargo');
      await reload();assert(JSON.stringify((await exported()).state)===JSON.stringify(done.state),'Completed matching progress survives reload');
    }
    await request(true);const before=await exported();await page.locator('#dialogue-cancel').click();const refused=await exported();
    assert(!refused.state.dialogue.flags[65]&&refused.state.dialogue.cash===before.state.dialogue.cash&&JSON.stringify(refused.state.ship.inventory)===JSON.stringify(before.state.ship.inventory),'Refusal clears matching without a transfer');
    await request(true,false);await walk(30,60);await walk(12,56);await page.locator('#walk-airlock').click();
    const street=await exported();assert(street.state.travel.scene==='city'&&street.state.encounters.roomState===null,'Leaving a pending referral removes its room actors');
    await reload();assert(JSON.stringify((await exported()).state)===JSON.stringify(street.state),'Pending source flags outside the room survive reload without orphan actors');
    await page.locator('#walk-airlock').click();const fresh=await exported();
    assert(!fresh.state.dialogue.flags[65]&&!fresh.state.dialogue.flags[66]&&fresh.state.encounters.roomState.tavern.contact===null,'Fresh room entry clears the old referral and starts a new visit');
    assert(errors.length===0,'No uncaught matching errors');return {browser:browser.version(),checks,errors};
  } catch(e) {return {browser:browser.version(),checks,errors,failures:[e.message]}} finally {await context.close()}
}
