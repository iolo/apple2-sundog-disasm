// Continue the phase-six campaign through ordinary UI controls and checkpoint reloads.
async browserPage => {
  const browser=browserPage.context().browser(),checks=[],errors=[];
  const context=await browser.newContext({viewport:{width:1280,height:720}}),page=await context.newPage();
  page.on('pageerror',e=>errors.push(e.stack||e.message));page.on('dialog',d=>d.accept());
  const assert=(ok,name)=>{if(!ok)throw Error(name);checks.push(name)};
  const ready=()=>page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
  const settled=()=>page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
  const state=()=>page.locator('#walk-screen').evaluate(el=>({...el.dataset}));
  const saves=async()=>{await page.locator((await page.locator('#navigation-panel').count())?'#nav-saves':
    (await page.locator('#space-panel').count())?'#space-saves':
    (await page.locator('#bank-panel').count())?'#bank-saves':
    (await page.locator('#service-panel').count())?'#service-saves':'#walk-saves').click();await settled()};
  const exported=async(path=null)=>{await saves();const pending=page.waitForEvent('download');await page.locator('#export-checkpoint').click();const download=await pending;if(path)await download.saveAs(path);let text='';for await(const part of await download.createReadStream())text+=part;await settled();await page.locator('#checkpoint-back').click();return JSON.parse(text)};
  const reload=async()=>{const before=await exported();await saves();await page.locator('#save-checkpoint-0').click();await settled();await page.reload();await ready();await page.locator('#campaign-saves').click();await settled();await page.locator('#load-checkpoint-0').click();await settled();await page.locator('#checkpoint-back').click();const after=await exported();assert(JSON.stringify(after.state)===JSON.stringify(before.state),'Fresh-page save reload preserves Center progress');return after};
  async function rest() {
    if((await state()).sleeping!=='true')return;
    if((await state()).paused==='true')await page.locator('#sleep-pause').click();
    for(let i=0;i<256&&Number((await state()).rest)<240;i++)await page.clock.runFor(250);
    assert(await page.locator('#sleep-wake').isEnabled(),'Ordinary forced rest recovers enough to wake');
    await page.locator('#sleep-wake').click();await page.locator('#inventory-close').click();
    await page.locator('#walk-pause').click();await page.clock.runFor(100);
  }
  const rations=[];
  async function eat() {
    if(Number((await state()).nourishment)>=80)return;
    if(!rations.length)return;
    await page.locator('#walk-inventory').click();await page.locator('#slot-carried-'+rations.shift()).click();
    await page.locator('#inventory-use').click();await page.locator('#inventory-close').click();
  }
  async function route(goal,replans=0) {
    await rest();await eat();
    const from=await state(),saved=(await exported()).state;
    const points=await page.evaluate(async({from,goal,saved})=>{
      const [{loadAssets},{canStand,interactionAt},{tryPodStep,podServiceAt,canDockPod},
        {canBoardParkedPod},{atCityBank,cityDoorAt},{roomAt,canLeaveRoom}]=await Promise.all([
        import('/js/render/assets.js'),import('/js/core/ship-walk.js'),import('/js/core/city-pod.js'),
        import('/js/core/parked-pod.js'),import('/js/core/city-doors.js'),import('/js/core/room-walk.js')]);
      const {trySurfaceStep,surfaceCityAt}=await import('/js/core/surface-walk.js');
      const {regionalGroundStart}=await import('/js/core/regional-world.js'),{createGroundWorld}=await import('/js/core/campaign-ground.js');
      const a=await loadAssets(),world=createGroundWorld({...a.campaignContent,...a.campaignContent.ground},regionalGroundStart(saved),{completedPhase:saved.colony.completedPhase});
      const pod=from.transport==='pod',city=from.scene==='city',surface=from.scene==='surface',room=from.scene==='room';
      const g=surface?world.surface(saved.ground.colonyPosition):city?(pod?world.city(saved.ground.cityId,false).pod:world.foot(saved)):
        room?roomAt(a.cityGeometry.rooms,world.city(saved.ground.cityId,saved.pod.attached).map,saved.travel.cityPosition):a.shipWalk;
      let routeBounds=null;
      if(city&&goal!=='surface'){
        const size=world.size(saved.ground.cityId),half=Math.floor((size+1)/2);
        routeBounds={left:(12-size)*28+46,right:(17+size)*28+227,top:(7-half)*32+59,bottom:(11+half)*32+138};
      }
      const reached=(p,h)=>goal==='surface'?p.x<(12-world.size(saved.ground.cityId))*28+46:goal.startsWith('city-')?surfaceCityAt(g.map,p)?.cityId===goal:
        goal==='bank'?atCityBank(g.map,p):goal==='tavern'?cityDoorAt(g.map,p)?.type===8:
        goal==='pod'?canBoardParkedPod(g,p,saved.pod.position):goal==='roomExit'?canLeaveRoom(g,p):
        goal==='colony'?podServiceAt(g,p,h)==='colony':goal==='exchange'?podServiceAt(g,p,h)==='exchange':
        goal==='depot'?podServiceAt(g,p,h)==='depot':goal==='dock'?canDockPod(g,p,h):
        goal==='navigation'?interactionAt(p)===1:goal==='stores'?interactionAt(p)===6:interactionAt(p)===3;
      const start=Number(from.y)*g.width+Number(from.x),queue=[start],seen=new Map([[start,null]]);let end=reached({x:Number(from.x),y:Number(from.y)},Number(from.heading))?start:undefined;
      for(let i=0;i<queue.length&&end===undefined;i++){
        const k=queue[i],p={x:k%g.width,y:Math.floor(k/g.width)};
        for(let dy=-1;dy<=1;dy++)for(let dx=-1;dx<=1;dx++)if(dx||dy){
          const next=surface?{position:trySurfaceStep(g,p,dx,dy),heading:26}:pod?tryPodStep(g,p,dx,dy):{position:{x:p.x+dx,y:p.y+dy}};
          if(!next||(!pod&&!surface&&!canStand(g,next.position)))continue;
          if(routeBounds&&(next.position.x<routeBounds.left||next.position.x>routeBounds.right||next.position.y<routeBounds.top||next.position.y>routeBounds.bottom))continue;
          const n=next.position.y*g.width+next.position.x;if(seen.has(n))continue;
          seen.set(n,{from:k,dx,dy});queue.push(n);
          if(reached(next.position,next.heading)){end=n;break}
        }
      }
      if(end===undefined)throw Error('No route to '+goal);const result=[];
      for(let k=end;k!==start;){const n=seen.get(k);result.unshift({x:k%g.width,y:Math.floor(k/g.width),dx:n.dx,dy:n.dy});k=n.from}
      return result;
    },{from,goal,saved});
    if((await state()).paused==='true')await page.locator('#walk-pause').click();
    const box=await page.locator('#stage').boundingBox();
    for(let i=0;i<points.length;i++){
      let p=points[i];await rest();await eat();if((await state()).paused==='true')await page.locator('#walk-pause').click();
      const before=await state();
      if(before.transport==='pod'||before.scene==='surface'){
        let steps=1;
        if(before.transport==='pod'&&p.x-Number(before.x)===p.dx&&p.y-Number(before.y)===p.dy){
          while(i+steps<points.length&&steps<31&&points[i+steps].dx===p.dx&&points[i+steps].dy===p.dy&&points[i+steps].x-points[i+steps-1].x===p.dx&&points[i+steps].y-points[i+steps-1].y===p.dy)steps++;
          if(steps%2===0)steps--;p=points[i+steps-1];i+=steps-1;
        }
        await page.locator('#walk-surface').focus();const keys=[...(p.dx?[p.dx>0?'ArrowRight':'ArrowLeft']:[]),...(p.dy?[p.dy>0?'ArrowDown':'ArrowUp']:[])];
        for(const key of keys)await page.keyboard.down(key);
        for(let t=0;t<(steps+2)*5;t++){
          await page.clock.runFor(16);const n=await state();
          if(n.encounter)throw Error(`Ground encounter ${n.encounter} on route ${goal} step ${i}`);
          const crossed=(actual,target,direction)=>direction===0||direction>0?actual>=target:actual<=target;
          if(crossed(Number(n.x),p.x,p.dx)&&crossed(Number(n.y),p.y,p.dy)||n.sleeping==='true'||n.scene!==before.scene)break;
        }
        for(const key of keys)await page.keyboard.up(key);await page.clock.runFor(100);
      }else{
        if(before.scene==='city'){
          const cx=Number(before.cameraX),cy=Number(before.cameraY);
          await page.mouse.move(box.x+(145+(p.x+3.5-cx*28)*1.25)*box.width/640,box.y+(126+(p.y-2.5-cy*32)*1.25)*box.height/480);
        }else if(before.scene==='room')await page.mouse.move(box.x+(145+(p.x+3.25)*2.5)*box.width/640,box.y+(126+(p.y-2.75)*2.5)*box.height/480);
        else await page.mouse.move(box.x+(32+(p.x+3.25)*640/280)*box.width/640,box.y+(46+(p.y-2.75)*2)*box.height/480);
        await page.mouse.down();
        if(before.scene==='city')for(let t=0;t<10;t++){await page.clock.runFor(16);const n=await state();if(n.x!==before.x||n.y!==before.y)break}
        else await page.clock.runFor(100);
        await page.mouse.up();
      }
      const after=await state();
      if(after.sleeping==='true'){await rest();return route(goal)}
      if(goal==='surface'&&after.scene==='surface'){assert(true,'City boundary enters the surface');return}
      if(Number(after.x)!==p.x||Number(after.y)!==p.y){
        if(replans>=12)throw Error(`Route ${goal} step ${i}/${points.length}: ${after.x},${after.y}, expected ${p.x},${p.y}; before ${JSON.stringify(before)}`);
        return route(goal,replans+1);
      }
    }
    assert(true,`${goal} reached through normal movement (${points.length} steps)`);
    const button=goal==='stores'?'#walk-inventory':goal==='pod'?'#walk-pod':goal==='navigation'?'#walk-navigation':'#walk-airlock';assert(await page.locator(button).isEnabled(),`${goal} action is available`);await page.locator(button).click();
  }
  async function buyRequirements(ids) {
    for(let attempt=0;attempt<30;attempt++) {
      const s=(await exported()).state;
      const owned=new Set(s.economy.exchange.warehouse.slots.filter(Boolean).map(c=>Number(c.commodityId.slice(6))));
      const needed=ids.filter(id=>!owned.has(id));if(!needed.length)return;
      const account=s.economy.accounts.find(a=>a.systemId===s.regional.shipLocation.systemId);
      const entry=s.economy.exchange.visit.offers.map((o,i)=>({o,i})).find(v=>v.o&&needed.includes(Number(v.o.commodityId.slice(6)))&&v.o.price<s.dialogue.cash+account.balance);
      if(entry){await page.locator(`#exchange-row-${entry.i}`).click();await page.locator('#exchange-confirm').click()}
      else {await page.locator('#service-leave').click();await page.locator('#walk-airlock').click()}
    }
    const s=(await exported()).state;
    throw Error(`The exchange did not offer phase-two goods: ${JSON.stringify({owned:s.economy.exchange.warehouse.slots.map(c=>c?.commodityId),supply:[10,21].map(i=>s.economy.exchange.market.supply[i-1]),offers:s.economy.exchange.visit.offers.map(o=>o?.commodityId),cash:s.dialogue.cash,bank:s.economy.accounts[1].balance})}`);
  }
  async function deliverPod() {
    for(let i=0;i<2;i++){
      await page.locator(`[data-colony-container="pod"][data-colony-slot="${i}"][data-colony-action="deliver"]`).click();
      await page.locator('#colony-confirm').click();
    }
  }
  async function roomWalk(x,y){
    if((await state()).paused==='true')await page.locator('#walk-pause').click();
    const box=await page.locator('#stage').boundingBox();
    for(let attempt=0;attempt<4;attempt++){
      await page.mouse.move(box.x+(145+(x+3.25)*2.5)*box.width/640,box.y+(126+(y-2.75)*2.5)*box.height/480);
      await page.mouse.down();await page.clock.runFor(2200);await page.mouse.up();
      const p=await state();if(Number(p.x)===x&&Number(p.y)===y)return;
    }
    throw Error(`Room walk did not reach ${x},${y}: ${JSON.stringify(await state())}`);
  }
  async function approachCounter(){
    for(const x of [50,70,90,110,20,30,40]){
      try{await roomWalk(x,40);await roomWalk(x,31);if(await page.locator('#walk-talk').isEnabled())return x}catch{}
    }
    throw Error(`No open tavern counter position: ${JSON.stringify(await state())}`);
  }
  async function navigation() {if(await page.locator('#navigation-panel').count())return;
    await page.locator(await page.locator('#space-panel').count()?'#space-navigation':'#walk-navigation').click()}
  async function command(type) {await navigation();await page.locator('#nav-'+type).click();await page.locator('#nav-confirm').click()}
  async function destination(scale,id) {await navigation();await page.locator('#nav-scale-'+scale).click();
    await page.locator('#nav-destination').selectOption(id);await page.locator('#nav-select').click();await page.locator('#nav-confirm').click()}
  async function arrive() {await page.locator('#nav-run').click();
    for(let i=0;i<1024;i++){await page.clock.runFor(250);if(!(await state()).flight)break}
    assert(!(await state()).flight,'The selected flight reaches its destination through the live clock')}
  async function charge() {await page.locator('#nav-run').click();
    for(let i=0;i<256;i++){await page.clock.runFor(250);if(await page.locator('#nav-warp').isEnabled())break}
    assert(await page.locator('#nav-warp').isEnabled(),'The warp engine charges through live power phases')}
  try{
    await page.addInitScript(()=>localStorage.setItem('sundog.locale','en'));
    await page.clock.install({time:new Date('2026-10-15T00:00:00Z')});await page.clock.pauseAt(new Date('2026-10-15T00:00:01Z'));
    await page.goto('http://127.0.0.1:8000/');await ready();
    await page.locator('#create-character').click();await page.locator('#character-name').fill('Import shell');
    await page.locator('#prepare-campaign').click();await page.locator('#campaign-seed').fill('1');await page.locator('#start-campaign').click();
    await page.locator('#walk-saves').click();await settled();
    await page.locator('#checkpoint-file').setInputFiles('output/playwright/remake/r11-phase-seven-city01-market.json');
    await page.waitForFunction(()=>/imported/i.test(document.querySelector('#checkpoint-message')?.textContent||''));
    await page.locator('#checkpoint-back').click();
    const initial=(await exported()).state;
    assert(initial.colony.activePhase===7&&initial.colony.receipts.length===37&&initial.economy.accounts[0].balance===11517&&
      initial.economy.exchange.market.cityId==='city-01','Phase-seven funding begins from the verified home market checkpoint');
    const rounds=[];
    async function candidates(s){return page.evaluate(async s=>{
      const {loadAssets}=await import('/js/render/assets.js'),a=await loadAssets();
      const {quoteExchangeCargo,exchangeLocation}=await import('/js/core/exchange.js');
      const market=s.economy.exchange.market,home=s.regional.cities.find(c=>c.market.cityId==='city-01').market,
        originLocation=exchangeLocation(a.campaignContent.exchange,'city-04'),location=exchangeLocation(a.campaignContent.exchange,'city-01'),
        bank=s.economy.accounts[0].balance;
      return s.economy.exchange.visit.offers.map((o,i)=>({o,i,quote:o?quoteExchangeCargo({commodityId:o.commodityId,quality:o.quality,originCity:'city-04',pricePaid:o.price},{market:home,location,originLocation,items:a.campaignContent.dialogue.items},'sell'):0}))
        .filter(v=>v.o&&v.o.price<=bank&&v.quote-v.o.price>=700&&
          !(v.o.commodityId==='cargo-27'&&market.supply[26]<=1))
        .sort((a,b)=>(b.quote-b.o.price)-(a.quote-a.o.price));
    },s)}
    async function buyOne(minimumVisits=96){
      for(let visit=0;visit<minimumVisits;visit++){
        const s=(await exported()).state,list=await candidates(s);
        if(list.length){const chosen=list[0];await page.locator(`#exchange-row-${chosen.i}`).click();await page.locator('#exchange-confirm').click();
          const after=(await exported()).state;
          assert(after.economy.exchange.warehouse.slots.some(c=>c?.originCity==='city-04'&&c.commodityId===chosen.o.commodityId&&c.quality===chosen.o.quality),
            `Normal board purchase stores profitable ${chosen.o.commodityId} quality ${chosen.o.quality}`);
          return chosen;
        }
        await page.locator('#service-leave').click();await page.locator('#walk-airlock').click();
      }
      return null;
    }
    for(let round=1;round<=1;round++){
      const before=(await exported()).state,openingBank=before.economy.accounts[0].balance;
      await page.locator('#service-leave').click();
      await route('dock');await route('navigation');await destination('planet','city-04');await arrive();await rest();
      if(await page.locator('#navigation-panel').count())await page.locator('#nav-close').click();
      await route('depart');await route('exchange');
      assert((await exported()).state.economy.exchange.market.cityId==='city-04',`Trade round ${round} reaches city 04`);
      const selected=[];const first=await buyOne(128);assert(!!first,`Trade round ${round} finds a profitable affordable lot`);selected.push(first);
      if((await exported()).state.economy.accounts[0].balance>=3000){const second=await buyOne(48);if(second)selected.push(second)}
      const bought=(await exported()).state,slots=bought.economy.exchange.warehouse.slots.map((c,i)=>c?.originCity==='city-04'?i:null).filter(i=>i!==null);
      assert(slots.length===selected.length&&slots.length<=2,`Trade round ${round} owns only its selected source lots`);
      await page.locator('#exchange-cargo').click();for(const slot of slots){await page.locator(`#cargo-warehouse-${slot}`).click();await page.locator('#exchange-confirm').click()}
      const loaded=(await exported()).state;
      assert(loaded.pod.cargo.filter(c=>c?.originCity==='city-04').length===selected.length,`Trade round ${round} loads all paid lots`);
      await exported(`output/playwright/remake/r11-phase-seven-trade-${round}-loaded.json`);
      await page.locator('#service-leave').click();await route('dock');await route('navigation');await destination('planet','city-01');await arrive();await rest();
      if(await page.locator('#navigation-panel').count())await page.locator('#nav-close').click();
      await route('depart');await route('exchange');await page.locator('#exchange-cargo').click();
      const podSlots=(await exported()).state.pod.cargo.map((c,i)=>c?.originCity==='city-04'?i:null).filter(i=>i!==null);
      for(const slot of podSlots){await page.locator(`#cargo-pod-${slot}`).click();await page.locator('#exchange-confirm').click()}
      await page.locator('#exchange-warehouse').click();
      const sellSlots=(await exported()).state.economy.exchange.warehouse.slots.map((c,i)=>c?.originCity==='city-04'?i:null).filter(i=>i!==null);
      assert(sellSlots.length===selected.length,`Trade round ${round} unloads every source lot`);
      for(const slot of sellSlots){await page.locator(`#exchange-row-${slot}`).click();await page.locator('#exchange-confirm').click()}
      const sold=(await reload()).state,profit=sold.economy.accounts[0].balance-openingBank;
      assert(profit>0&&sold.pod.cargo.every(c=>c===null),`Trade round ${round} makes a positive normal-sale profit: ${profit}`);
      const checkpoint=await exported(`output/playwright/remake/r11-phase-seven-trade-${round}-sold.json`);
      assert(JSON.stringify(checkpoint.state)===JSON.stringify(sold),`Trade round ${round} checkpoint exports unchanged`);
      rounds.push({round,openingBank,closingBank:sold.economy.accounts[0].balance,profit,lots:selected.map(v=>({commodityId:v.o.commodityId,quality:v.o.quality,price:v.o.price,quote:v.quote}))});
    }
    assert(errors.length===0,'No uncaught errors during the phase-seven funding batch');
    return{browser:browser.version(),checks,errors,failures:[],journey:{rounds,bank:rounds.at(-1).closingBank}};
  }catch(error){await page.screenshot({path:'output/playwright/remake/r11-phase-seven-trade-loop-2-error.png'});return{browser:browser.version(),checks,errors,failures:[error.stack||error.message]}}
  finally{await context.close()}
}
