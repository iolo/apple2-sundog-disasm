// Fresh character discovers Banville and makes two phase-one deliveries using controls.
// Browser-side geometry is read only; every campaign mutation uses live UI.
async browserPage => {
  const browser=browserPage.context().browser(),checks=[],errors=[];
  const context=await browser.newContext({viewport:{width:1280,height:720}}),page=await context.newPage();
  page.on('pageerror',e=>errors.push(e.stack||e.message));page.on('dialog',d=>d.accept());
  const assert=(ok,name)=>{if(!ok)throw Error(name);checks.push(name)};
  const ready=()=>page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
  const settled=()=>page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
  const state=()=>page.locator('#walk-screen').evaluate(el=>({...el.dataset}));
  const saves=async()=>{await page.locator((await page.locator('#service-panel').count())?'#service-saves':'#walk-saves').click();await settled()};
  const exported=async()=>{await saves();const pending=page.waitForEvent('download');await page.locator('#export-checkpoint').click();let text='';for await(const part of await(await pending).createReadStream())text+=part;await settled();await page.locator('#checkpoint-back').click();return JSON.parse(text)};
  const reload=async()=>{const before=await exported();await saves();await page.locator('#save-checkpoint-0').click();await settled();await page.reload();await ready();await page.locator('#campaign-saves').click();await settled();await page.locator('#load-checkpoint-0').click();await settled();await page.locator('#checkpoint-back').click();const after=await exported();assert(JSON.stringify(after.state)===JSON.stringify(before.state),'Fresh-page save reload preserves Center progress');return after};
  async function rest() {
    if((await state()).sleeping!=='true')return;
    if((await state()).paused==='true')await page.locator('#sleep-pause').click();
    for(let i=0;i<256&&Number((await state()).rest)<240;i++)await page.clock.runFor(250);
    assert(await page.locator('#sleep-wake').isEnabled(),'Ordinary forced rest recovers enough to wake');
    await page.locator('#sleep-wake').click();await page.locator('#inventory-close').click();
    await page.locator('#walk-pause').click();await page.clock.runFor(100);
  }
  const rations=[0,1,2,3];
  async function eat() {
    if(Number((await state()).nourishment)>=80)return;
    if(!rations.length)throw Error('The ordinary journey exhausted its carried food');
    await page.locator('#walk-inventory').click();await page.locator('#slot-carried-'+rations.shift()).click();
    await page.locator('#inventory-use').click();await page.locator('#inventory-close').click();
  }
  async function route(goal) {
    await rest();await eat();
    const from=await state(),saved=(await exported()).state;
    const points=await page.evaluate(async({from,goal,saved})=>{
      const [{loadAssets},{canStand,interactionAt},{tryPodStep,podServiceAt}]=await Promise.all([import('/js/render/assets.js'),import('/js/core/ship-walk.js'),import('/js/core/city-pod.js')]);
      const {trySurfaceStep,surfaceCityAt}=await import('/js/core/surface-walk.js');
      const {regionalGroundStart}=await import('/js/core/regional-world.js'),{createGroundWorld}=await import('/js/core/campaign-ground.js');
      const a=await loadAssets(),world=createGroundWorld({...a.campaignContent,...a.campaignContent.ground},regionalGroundStart(saved),{completedPhase:saved.colony.completedPhase});
      const pod=from.transport==='pod',city=from.scene==='city',surface=from.scene==='surface';
      const g=surface?world.surface(saved.ground.colonyPosition):city?(pod?world.city(saved.ground.cityId,false).pod:world.foot(saved)):a.shipWalk;
      let routeBounds=null;
      if(city&&goal!=='surface'){
        const size=world.size(saved.ground.cityId),half=Math.floor((size+1)/2);
        routeBounds={left:(12-size)*28+46,right:(17+size)*28+227,top:(7-half)*32+59,bottom:(11+half)*32+138};
      }
      const reached=(p,h)=>goal==='surface'?p.x<(saved.ground.cityId==='city-60'?420:125):goal.startsWith('city-')?surfaceCityAt(g.map,p)?.cityId===goal:goal==='colony'?podServiceAt(g,p,h)==='colony':goal==='exchange'?podServiceAt(g,p,h)==='exchange':goal==='stores'?interactionAt(p)===6:interactionAt(p)===3;
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
        for(let t=0;t<(steps+2)*5;t++){await page.clock.runFor(16);const n=await state();if(n.encounter)throw Error(`Ground encounter ${n.encounter} on route ${goal} step ${i}`);if(Number(n.x)===p.x&&Number(n.y)===p.y||n.sleeping==='true'||n.scene!==before.scene)break}
        for(const key of keys)await page.keyboard.up(key);await page.clock.runFor(100);
      }else{
        if(before.scene==='city'){
          const cx=Number(before.cameraX),cy=Number(before.cameraY);
          await page.mouse.move(box.x+(145+(p.x+3.5-cx*28)*1.25)*box.width/640,box.y+(126+(p.y-2.5-cy*32)*1.25)*box.height/480);
        }else await page.mouse.move(box.x+(32+(p.x+3.25)*640/280)*box.width/640,box.y+(46+(p.y-2.75)*2)*box.height/480);
        await page.mouse.down();
        if(before.scene==='city')for(let t=0;t<10;t++){await page.clock.runFor(16);const n=await state();if(n.x!==before.x||n.y!==before.y)break}
        else await page.clock.runFor(100);
        await page.mouse.up();
      }
      const after=await state();
      if(after.sleeping==='true'){await rest();return route(goal)}
      if(goal==='surface'&&after.scene==='surface'){assert(true,'City boundary enters the surface');return}
      if(Number(after.x)!==p.x||Number(after.y)!==p.y)throw Error(`Route ${goal} step ${i}/${points.length}: ${after.x},${after.y}, expected ${p.x},${p.y}; before ${JSON.stringify(before)}`);
    }
    assert(true,`${goal} reached through normal movement (${points.length} steps)`);
    const button=goal==='stores'?'#walk-inventory':'#walk-airlock';assert(await page.locator(button).isEnabled(),`${goal} action is available`);await page.locator(button).click();
  }
  async function buyRequirements(ids) {
    for(let attempt=0;attempt<30;attempt++) {
      const s=(await exported()).state;
      const owned=new Set(s.economy.exchange.warehouse.slots.filter(Boolean).map(c=>Number(c.commodityId.slice(6))));
      const needed=ids.filter(id=>!owned.has(id));if(!needed.length)return;
      const entry=s.economy.exchange.visit.offers.map((o,i)=>({o,i})).find(v=>v.o&&needed.includes(Number(v.o.commodityId.slice(6)))&&v.o.price<s.dialogue.cash+s.economy.accounts[0].balance);
      if(entry){await page.locator(`#exchange-row-${entry.i}`).click();await page.locator('#exchange-confirm').click()}
      else {await page.locator('#service-leave').click();await page.locator('#walk-airlock').click()}
    }
    const s=(await exported()).state;
    throw Error(`The starting exchange did not offer all phase-1 goods: ${JSON.stringify({owned:s.economy.exchange.warehouse.slots.map(c=>c?.commodityId),supply:[8,9,11,13].map(i=>s.economy.exchange.market.supply[i-1]),offers:s.economy.exchange.visit.offers.map(o=>o?.commodityId),cash:s.dialogue.cash,bank:s.economy.accounts[0].balance})}`);
  }
  async function deliverPod() {
    for(let i=0;i<2;i++){
      await page.locator(`[data-colony-container="pod"][data-colony-slot="${i}"][data-colony-action="deliver"]`).click();
      await page.locator('#colony-confirm').click();
    }
  }
  try{
    await page.addInitScript(()=>localStorage.setItem('sundog.locale','en'));
    await page.clock.install({time:new Date('2026-10-15T00:00:00Z')});await page.clock.pauseAt(new Date('2026-10-15T00:00:01Z'));
    await page.goto('http://127.0.0.1:8000/');await ready();
    await page.locator('#create-character').click();await page.locator('#character-name').fill('R11 scout');
    await page.locator('#prepare-campaign').click();await page.locator('#campaign-seed').fill('12345');await page.locator('#start-campaign').click();
    await route('stores');for(let i=0;i<4;i++){
      await page.locator(`#slot-stores-${5+i}`).click();await page.locator(`#slot-carried-${i}`).click();
    }
    await page.locator('#inventory-close').click();
    await route('depart');await route('exchange');await buyRequirements([8,9,11]);
    const bought=(await exported()).state;
    assert([8,9,11].every(id=>bought.economy.exchange.warehouse.slots.some(c=>c?.commodityId===`cargo-${String(id).padStart(2,'0')}`)),'Three required goods are bought at ordinary exchange prices');
    await page.locator('#exchange-cargo').click();for(const i of [0,1]){await page.locator(`#cargo-warehouse-${i}`).click();await page.locator('#exchange-confirm').click()}
    await page.locator('#service-leave').click();await route('surface');const found=await exported();
    assert(found.state.ground.colonyPosition!==null,'First surface visit locates Banville');
    await route('city-60');assert((await state()).scene==='city','Pod enters Banville from the surface');
    await route('colony');const center=await reload();
    assert(center.version===30&&center.state.travel.scene==='colony','Version 30 reloads the Center scene');
    assert(center.state.colony.activePhase===1&&center.state.colony.completedPhase===0,'First Center visit starts phase 1 exactly once');
    assert(await page.locator('#colony-requirements').count()===1,'Center shows current requirements');
    await deliverPod();const halfway=await reload();
    assert(halfway.state.colony.receipts.length===2&&halfway.state.colony.activePhase===1,'First two purchased lots are delivered and persist across reload');
    assert(errors.length===0,'No uncaught errors on the fresh Banville journey');
    return{browser:browser.version(),checks,errors,failures:[],journey:{colonyPosition:center.state.ground.colonyPosition,minutes:halfway.state.ship.minutes,receipts:halfway.state.colony.receipts.length}};
  }catch(error){await page.screenshot({path:'output/playwright/remake/r11-discovery-error.png'});return{browser:browser.version(),checks,errors,failures:[error.stack||error.message]}}
  finally{await context.close()}
}
