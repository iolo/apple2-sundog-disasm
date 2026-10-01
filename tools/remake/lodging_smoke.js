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
    const p=await state();assert(Number(p.x)===x&&Number(p.y)===y,`Lodging walk reaches ${x},${y}`);
  };
  try {
    await page.addInitScript(()=>localStorage.setItem('sundog.locale','en'));
    await page.clock.install();await page.goto('http://127.0.0.1:8000/');await ready();
    const pending=page.waitForEvent('download');
    const fixture=await page.evaluate(async()=>{
      const [{loadAssets},{campaignSaveCodec},{createCharacter},{cityDoorAt},{cityReachability}]=await Promise.all([
        import('/js/render/assets.js'),import('/js/core/campaign-saves.js'),import('/js/core/character.js'),
        import('/js/core/city-doors.js'),import('/js/core/city-walk.js')]);
      const assets=await loadAssets(),city=assets.cityGeometry,reached=cityReachability(city);
      let street;outer:for(let y=7;y<city.height;y++)for(let x=3;x<city.width-7;x++)
        if(cityDoorAt(city.map,{x,y})?.type===11&&reached({x,y})){street={x,y};break outer}
      const codec=campaignSaveCodec(assets.campaignContent,assets.shipWalk,city),state=codec.create({...createCharacter(),name:'Lodging visit'},12345);
      state.ship.position={x:54,y:118};state.ship.minutes=7*60;state.travel={scene:'city',cityPosition:street};state.encounters.randomState=0;
      const a=document.createElement('a');a.href=URL.createObjectURL(new Blob([JSON.stringify(codec.make(state,0))],{type:'application/json'}));a.download='lodging-street.json';a.click();
      return {street,cash:state.dialogue.cash,fee:8*assets.campaignContent.dialogue.systems.systems[0].local30+3};
    });
    await (await pending).saveAs('output/playwright/remake/lodging-street.json');
    await page.locator('#campaign-saves').click();await settled();await page.locator('#checkpoint-file').setInputFiles('output/playwright/remake/lodging-street.json');await settled();await page.locator('#checkpoint-back').click();
    await page.locator('#walk-airlock').click();
    assert((await state()).room==='1'&&(await state()).y==='61','Type11 door opens the original lodging layout and entry anchor');
    await walk(21,71);await page.locator('#walk-talk').click();await page.clock.runFor(2000);await page.locator('#dialogue-panel').waitFor();
    assert(await page.locator('#walk-screen').getAttribute('data-dialogue')==='96','Clerk starts lodging dialogue96');
    await page.locator('#dialogue-reply-1').click();const english=await page.locator('#dialogue-text').innerText();
    assert(english.includes(`${fixture.fee} Cr`),'Clerk quotes the source system fee');
    await page.locator('#dialogue-language').click();const korean=await page.locator('#dialogue-text').innerText();
    assert(/[가-힣]/.test(korean)&&korean.includes(String(fixture.fee)),'The same rental quote is localized in Korean');
    for(const [width,height] of [[640,480],[390,844],[844,390]]) {
      await page.setViewportSize({width,height});await page.clock.runFor(50);
      await page.waitForFunction(()=>Math.abs(document.querySelector('#stage').getBoundingClientRect().width-Math.min(innerWidth,innerHeight*4/3))<1);
      const fits=await page.locator('#dialogue-panel').evaluate(el=>{const r=el.getBoundingClientRect();return r.left>=0&&r.top>=0&&r.right<=innerWidth+1&&r.bottom<=innerHeight+1});
      assert(fits,`Lodging dialogue fits ${width}x${height}`);
    }
    await page.setViewportSize({width:1280,height:720});await page.locator('#dialogue-reply-1').click();
    assert(await page.locator('#walk-screen').getAttribute('data-dialogue')==='100','Pay reaches the source rental acceptance');
    const paid=await exported();assert(paid.version===12&&paid.state.dialogue.cash===fixture.cash,'Version12 mid-payment save retains replayable pre-return cash');
    await reload();assert(JSON.stringify((await exported()).state)===JSON.stringify(paid.state),'Mid-payment IndexedDB reload preserves the exact replay and cash');
    await page.locator('#dialogue-continue').click();
    const rented=await exported(),number=rented.state.travel.lodging.rented,x=28+28*(number-1);
    assert(rented.state.dialogue.cash===fixture.cash-fixture.fee&&rented.state.start.credits===fixture.cash,'Returning from payment debits active cash once and preserves creation data');
    assert(number>=1&&number<=4&&rented.state.travel.lodging.openMask===(1<<(number-1)),'Rental opens the assigned room');
    await walk(x,40);await walk(x,22);
    const bedroom=await exported();assert(bedroom.state.travel.lodging.openMask===0&&bedroom.state.dialogue.flags[57],'The door closes behind the player and records the source bedroom flag');
    await reload();assert(JSON.stringify((await exported()).state)===JSON.stringify(bedroom.state),'A closed-bedroom save survives fresh-page loading');
    await page.locator('#walk-language').click();await page.screenshot({path:'output/playwright/remake/lodging-bedroom-ko.png'});
    await walk(x,40);assert((await exported()).state.travel.lodging.openMask===(1<<(number-1)),'Approaching from inside reopens the rented door');
    await walk(x,55);await walk(20,61);await walk(12,61);await page.locator('#walk-airlock').click();
    const left=await exported();assert(left.state.travel.scene==='city'&&JSON.stringify(left.state.travel.cityPosition)===JSON.stringify(fixture.street),'Leaving lodging returns to the same city doorway');
    assert(left.state.dialogue.cash===fixture.cash-fixture.fee&&!left.state.dialogue.flags[57],'Exit preserves cash and clears the bedroom flag');
    await page.locator('#walk-airlock').click();const again=await exported();
    assert(again.state.travel.lodging.rented===0&&again.state.travel.lodging.openMask===0&&again.state.dialogue.cash===left.state.dialogue.cash,'A new visit resets room rental access without refunding cash');
    const bank=structuredClone(again);bank.state.travel={scene:'bank',cityPosition:{x:369,y:299}};
    bank.state.encounters={randomState:bank.state.encounters.randomState,roomSeed:null,roomState:null,counter:null};
    await saves();const bankDownload=page.waitForEvent('download');
    await page.evaluate(value=>{const a=document.createElement('a');a.href=URL.createObjectURL(new Blob([JSON.stringify(value)],{type:'application/json'}));a.download='lodging-bank.json';a.click()},bank);
    await (await bankDownload).saveAs('output/playwright/remake/lodging-bank.json');
    await page.locator('#checkpoint-file').setInputFiles('output/playwright/remake/lodging-bank.json');await settled();await page.locator('#checkpoint-back').click();
    assert(await page.locator('#bank-cash').innerText()===String(fixture.cash-fixture.fee),'Bank visit import displays the active cash remaining after lodging payment');
    assert(errors.length===0,'No uncaught browser errors');
    return {browser:browser.version(),checks,errors,branch:{english,korean},fixture};
  } finally {await context.close()}
}
