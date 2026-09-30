async browserPage => {
  const browser=browserPage.context().browser(),checks=[],errors=[];
  const context=await browser.newContext({viewport:{width:1280,height:720}}),page=await context.newPage();
  page.on('pageerror',e=>errors.push(e.message));page.on('dialog',d=>d.accept());
  const assert=(ok,name)=>{if(!ok)throw Error(name);checks.push(name)};
  const ready=()=>page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
  const settled=()=>page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
  const state=()=>page.locator('#walk-screen').evaluate(el=>({...el.dataset}));
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
  const walk=async(x,y)=>{
    if((await state()).paused==='true')await page.locator('#walk-pause').click();
    const box=await page.locator('#stage').boundingBox();
    await page.mouse.move(box.x+(145+(x+3.25)*2.5)*box.width/640,box.y+(126+(y-2.75)*2.5)*box.height/480);
    await page.mouse.down();await page.clock.runFor(2200);await page.mouse.up();
    const p=await state();assert(Number(p.x)===x&&Number(p.y)===y,`Tavern walk reaches ${x},${y}`);
  };
  const importFixture=async(kind)=>{
    const pending=page.waitForEvent('download');
    const fixture=await page.evaluate(async(kind)=>{
      const [{loadAssets},{campaignSaveCodec},{createCharacter},{cityDoorAt},{cityReachability},{populateRoom},{initialRoomTraffic},{roomAt},{createRoomCounter,openRoomCounter}]=await Promise.all([
        import('/js/render/assets.js'),import('/js/core/campaign-saves.js'),import('/js/core/character.js'),
        import('/js/core/city-doors.js'),import('/js/core/city-walk.js'),import('/js/core/room-actors.js'),
        import('/js/core/room-traffic.js'),import('/js/core/room-walk.js'),import('/js/core/room-counter.js')]);
      const assets=await loadAssets(),city=assets.cityGeometry,reached=cityReachability(city);
      let street;outer:for(let y=7;y<city.height;y++)for(let x=3;x<city.width-7;x++)
        if(cityDoorAt(city.map,{x,y})?.type===8&&reached({x,y})){street={x,y};break outer}
      const codec=campaignSaveCodec(assets.campaignContent,assets.shipWalk,city),s=codec.create({...createCharacter(),name:'Tavern visit'},12345);
      const room=roomAt(city.rooms,city.map,street);
      s.ship.position={x:54,y:118};s.ship.minutes=420;s.travel={scene:'city',cityPosition:street};s.encounters.randomState=0;
      s.dialogue.attributes=[30,40,50,30,81];
      if(kind!=='street') {
        s.travel={scene:'room',cityPosition:street,roomPosition:{x:16,y:86}};
        const p=populateRoom(room,12345),traffic=initialRoomTraffic(p,room),w=traffic.actors[0].words;
        traffic.actors=[traffic.actors[0],traffic.actors.at(-1)];w.splice(0,6,86,43,86,43,86,43);w[7]=4;w[9]=0;
        if(kind==='arrival'){w[4]=80;w[7]=5*256+33;w[8]=4;traffic.active=2;traffic.tavern.playerSeat=4}
        s.encounters={randomState:kind==='arrival' ? 12345 : 2,roomSeed:12345,roomState:traffic,counter:{service:'idle',conversation:null}};
      }
      if(kind==='tip') {
        const p=populateRoom(room,0);s.travel.roomPosition={x:30,y:31};
        let frame=createRoomCounter(room,initialRoomTraffic(p,room),13,s.travel.roomPosition);frame.service='talking';
        frame=openRoomCounter(assets.campaignContent.dialogue,room,frame,{...s.dialogue,system:assets.campaignContent.dialogue.systems.systems[0],
          carried:s.ship.inventory.carried,city:1,hour:7,surface:s.start.playerLocation.surfacePosition});
        s.encounters={randomState:frame.randomState,roomSeed:0,roomState:frame.traffic,counter:{service:'talking',conversation:{seed:13,inputs:[]}}};
      }
      if(kind==='empty') {
        s.travel.roomPosition={x:43,y:82};const p=populateRoom(room,0);
        s.encounters={randomState:12345,roomSeed:0,roomState:initialRoomTraffic(p,room),counter:{service:'idle',conversation:null}};
      }
      const a=document.createElement('a');a.href=URL.createObjectURL(new Blob([JSON.stringify(codec.make(s,0))],{type:'application/json'}));a.download=`tavern-${kind}.json`;a.click();
      return {street,room:room.index};
    },kind);
    const path=`output/playwright/remake/tavern-${kind}.json`;await(await pending).saveAs(path);
    if(await page.locator('#walk-screen').isVisible())await saves();else {await page.locator('#campaign-saves').click();await settled()}
    await page.locator('#checkpoint-file').setInputFiles(path);await settled();await page.locator('#checkpoint-back').click();return fixture;
  };
  try {
    await page.addInitScript(()=>localStorage.setItem('sundog.locale','en'));await page.clock.install();await page.goto('http://127.0.0.1:8000/');await ready();
    const fixture=await importFixture('street');await page.locator('#walk-airlock').click();
    assert((await state()).room===String(fixture.room),'Type8 street door opens its source-selected tavern layout');
    const entered=await exported();assert(entered.version===10&&entered.state.encounters.roomState.tavern.playerSeat===null,'Fresh entry exports version10 tavern state');
    await walk(30,40);await walk(30,31);await page.locator('#walk-talk').click();await page.clock.runFor(2000);
    assert((await state()).dialogue==='16','Bartender approaches and opens source dialogue16');
    assert(await page.locator('#dialogue-item-0').isDisabled(),'Food purchase is gated before unsupported acceptance');
    await page.locator('#dialogue-language').click();assert(/[가-힣]/.test(await page.locator('#dialogue-text').innerText()),'Bartender greeting is localized');
    await page.locator('#dialogue-cancel').click();assert((await exported()).state.encounters.counter.service==='served','Bartender returns to the same live visit');
    await importFixture('empty');await walk(43,86);
    assert((await exported()).state.encounters.roomState.tavern.playerSeat===5,'Releasing pointer movement at a table claims the source seat');
    if(await page.locator('#dialogue-panel').count())await page.locator('#dialogue-cancel').click();
    await walk(43,60);assert((await exported()).state.encounters.roomState.tavern.playerSeat===null,'Walking away releases the player seat');
    await importFixture('seated');await page.locator('#walk-talk').click();
    assert((await state()).dialogue==='128','Sitting opposite a visitor opens the source social branch');
    await page.locator('#dialogue-reply-1').click();assert((await state()).dialogue==='176','Accepting a chat reaches small talk');
    await page.locator('#dialogue-reply-2').click();assert((await state()).dialogue==='192','Responding reaches a source joke');
    if(/[가-힣]/.test(await page.locator('#dialogue-text').innerText()))await page.locator('#dialogue-language').click();
    const english=await page.locator('#dialogue-text').innerText();await page.locator('#dialogue-language').click();
    const korean=await page.locator('#dialogue-text').innerText();
    assert(/[가-힣]/.test(korean)&&!/\{\w+\}/.test(korean),'Joke question renders in Korean without placeholders');
    for(const [width,height] of [[640,480],[390,844],[844,390]]) {
      await page.setViewportSize({width,height});await page.clock.runFor(50);
      await page.waitForFunction(()=>Math.abs(document.querySelector('#stage').getBoundingClientRect().width-Math.min(innerWidth,innerHeight*4/3))<1);
      const fits=await page.locator('#dialogue-panel').evaluate(el=>{const r=el.getBoundingClientRect();return r.left>=0&&r.top>=0&&r.right<=innerWidth+1&&r.bottom<=innerHeight+1});
      assert(fits,`Tavern dialogue fits ${width}x${height}`);
    }
    await page.setViewportSize({width:1280,height:720});await page.clock.runFor(50);
    const saved=await exported();await reload();assert(JSON.stringify((await exported()).state)===JSON.stringify(saved.state),'Fresh-page IndexedDB reload preserves speaker, seat, joke and exact RNG');
    // Locale is a user setting, separate from the save and this fixture's init script.
    if(!/[가-힣]/.test(await page.locator('#dialogue-text').innerText()))await page.locator('#dialogue-language').click();
    await page.locator('#dialogue-continue').click();assert((await state()).dialogue==='193','Continue gives the matching source punchline');
    await page.screenshot({path:'output/playwright/remake/tavern-joke-ko.png'});
    await page.locator('#dialogue-continue').click();await page.locator('#dialogue-cancel').click();
    const returned=await exported();assert(returned.state.encounters.roomState.tavern.secondary===2&&returned.state.dialogue.workspace.actor===2,'Conversation return resumes the actual visitor');
    assert(returned.state.dialogue.cash===saved.state.dialogue.cash,'Social conversation preserves active cash');
    await walk(16,60);await walk(12,56);await page.locator('#walk-airlock').click();
    assert((await state()).scene==='city','Leaving returns to the original street');await page.locator('#walk-airlock').click();
    const reentered=await exported();assert(reentered.state.encounters.roomState.tavern.playerSeat===null&&reentered.state.encounters.roomState.tavern.contact===null,'Reentry creates a fresh visit without an orphan contact');
    await importFixture('arrival');const approach=await exported();await reload();
    assert(JSON.stringify((await exported()).state)===JSON.stringify(approach.state),'A reserved seat and moving visitor survive a fresh-page reload');
    await page.locator('#walk-pause').click();await page.clock.runFor(350);
    assert((await state()).dialogue==='33','An arriving visitor initiates source kind22 dialogue');
    await page.locator('#dialogue-reply-2').click();assert((await exported()).state.encounters.roomState.tavern.secondary===2,'Declining the visitor resumes departure or counter movement');
    await importFixture('tip');const beforeTip=await exported();
    await page.locator('#dialogue-reply-2').click();await page.locator('#dialogue-reply-2').click();
    assert((await state()).dialogue==='23','Bartender tip branch exposes offer controls');
    await page.locator('[data-dialogue-offer="increase"][data-step="10"]').click();
    assert((await page.locator('[role="group"]').innerText()).includes('10'),'Tip controls update the offered amount');
    const offered=await exported();await reload();assert(JSON.stringify((await exported()).state)===JSON.stringify(offered.state),'Mid-offer save restores the amount and RNG');
    await page.locator('#dialogue-reply-2').click();assert((await state()).dialogue==='26','Tip acceptance reaches the information choices');
    await page.locator('#dialogue-cancel').click();const tipped=await exported();
    assert(tipped.state.dialogue.cash===beforeTip.state.dialogue.cash-10,'Bartender return commits the ten-credit tip once');
    assert(errors.length===0,'Tavern flow has no uncaught page errors');
    return {browser:browser.version(),checks,errors,branch:{english,korean},fixture};
  } finally {await context.close()}
}
