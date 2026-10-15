// Restore food in the continuing twelve-receipt phase-three campaign.
// Browser-side geometry is read only; every campaign mutation uses live UI.
async browserPage => {
  const browser=browserPage.context().browser(),checks=[],errors=[];
  const context=await browser.newContext({viewport:{width:1280,height:720}}),page=await context.newPage();
  page.on('pageerror',e=>errors.push(e.stack||e.message));page.on('console',m=>{if(m.type()==='error')errors.push(m.text())});page.on('dialog',d=>d.accept());
  const assert=(ok,name)=>{if(!ok)throw Error(name);checks.push(name)};
  const ready=()=>page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
  const settled=()=>page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
  const state=()=>page.locator('#walk-screen').evaluate(el=>({...el.dataset}));
  const saves=async()=>{await page.locator((await page.locator('#bank-panel').count())?'#bank-saves':
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
  async function settleEncounter() {
    for(let i=0;i<12;i++){
      const scene=(await state()).encounter;
      if(!scene)return;
      if(scene==='chase'){
        if((await state()).paused==='true')await page.locator('#walk-pause').click();
        await page.locator('#walk-surface').focus();
        await page.keyboard.down('ArrowLeft');await page.keyboard.down('ArrowDown');
        await page.clock.runFor(4000);
        await page.keyboard.up('ArrowLeft');await page.keyboard.up('ArrowDown');
      }else if(scene==='dialogue'){
        if(await page.locator('#dialogue-reply-1').isVisible())await page.locator('#dialogue-reply-1').click();
        else if(await page.locator('#dialogue-continue').isEnabled())await page.locator('#dialogue-continue').click();
        else await page.locator('#dialogue-cancel').click();
      }else throw Error(`Ground encounter requires combat: ${scene}`);
    }
    assert((await state()).encounter==='','Ordinary controls resolve the city ground encounter');
  }
  async function route(goal,replans=0) {
    await settleEncounter();
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
        goal==='dock'?canDockPod(g,p,h):goal==='stores'?interactionAt(p)===6:interactionAt(p)===3;
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
      if(after.encounter){await settleEncounter();return route(goal,replans+1)}
      if(after.sleeping==='true'){await rest();return route(goal)}
      if(goal==='surface'&&after.scene==='surface'){assert(true,'City boundary enters the surface');return}
      if(Number(after.x)!==p.x||Number(after.y)!==p.y){
        if(replans>=12)throw Error(`Route ${goal} step ${i}/${points.length}: ${after.x},${after.y}, expected ${p.x},${p.y}; before ${JSON.stringify(before)}`);
        return route(goal,replans+1);
      }
    }
    assert(true,`${goal} reached through normal movement (${points.length} steps)`);
    const button=goal==='stores'?'#walk-inventory':goal==='pod'?'#walk-pod':'#walk-airlock';assert(await page.locator(button).isEnabled(),`${goal} action is available`);await page.locator(button).click();
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
    for(const x of [40,50,70,90,110,20,30]){
      try{await roomWalk(x,40);await roomWalk(x,31);if(await page.locator('#walk-talk').isEnabled())return}catch{}
    }
    throw Error(`No open tavern counter position: ${JSON.stringify(await state())}`);
  }
  try{
    await page.addInitScript(()=>localStorage.setItem('sundog.locale','en'));
    await page.clock.install({time:new Date('2026-10-15T00:00:00Z')});await page.clock.pauseAt(new Date('2026-10-15T00:00:01Z'));
    await page.goto('http://127.0.0.1:8000/');await ready();
    await page.locator('#create-character').click();await page.locator('#character-name').fill('Import shell');
    await page.locator('#prepare-campaign').click();await page.locator('#campaign-seed').fill('1');await page.locator('#start-campaign').click();
    await page.locator('#walk-saves').click();await settled();
    await page.locator('#checkpoint-file').setInputFiles('output/playwright/remake/r11-phase-four-city26-two-delivered.json');
    await page.waitForFunction(()=>/imported/i.test(document.querySelector('#checkpoint-message')?.textContent||''));
    await page.locator('#checkpoint-back').click();
    const original=(await exported()).state;
    assert(original.start.creation.seed===12345&&original.colony.activePhase===4&&original.colony.receipts.length===21&&
      original.ship.condition.nourishment===71,'The twenty-one-receipt campaign survives for the final phase-four lots');
    await page.locator('#service-leave').click();await route('surface');await route('city-02');
    await page.locator('#walk-pod').click();
    assert((await state()).transport==='foot','The pod parks before walking to city services');
    await route('tavern');
    assert((await state()).scene==='room','The source tavern door opens a live room');
    await approachCounter();
    await page.locator('#walk-talk').click();await page.clock.runFor(2000);
    assert((await state()).dialogue==='16','The bartender opens the ordinary food menu');
    await page.locator('#dialogue-item-0').click();
    await page.locator('[data-dialogue-purchase=\"3\"]').click();
    await page.locator('#dialogue-cancel').click();
    await page.locator('#walk-inventory').click();await page.locator('#slot-carried-3').click();
    await page.locator('#inventory-use').click();await page.locator('#inventory-close').click();
    assert(Number((await state()).nourishment)>original.ship.condition.nourishment,
      'The first purchased ration restores nourishment before departure');
    await page.locator('#walk-talk').click();
    for(let i=0;i<256&&(await state()).dialogue!=='16';i++)await page.clock.runFor(250);
    assert((await state()).dialogue==='16','The bartender offers a second ration');
    await page.locator('#dialogue-item-0').click();
    await page.locator('[data-dialogue-purchase=\"3\"]').click();rations.push(3);
    await page.locator('#dialogue-cancel').click();
    const purchased=(await exported()).state;
    assert((purchased.ship.inventory.carried[3]&31)===8&&purchased.dialogue.cash<original.dialogue.cash,
      'The bartender sells a food ration for carried cash');
    await roomWalk(40,40);await roomWalk(12,56);
    assert(await page.locator('#walk-airlock').isEnabled(),'Tavern exit is reachable after purchasing food');
    await page.locator('#walk-airlock').click();
    await exported('output/playwright/remake/r11-phase-four-two-left-food-bought.json');
    await route('pod');
    const supplied=await reload();
    assert(supplied.state.ship.condition.nourishment>original.ship.condition.nourishment&&
      (supplied.state.ship.inventory.carried[3]&31)===8,
      'Purchased food restores nourishment and a carried ration survives reload');
    assert(supplied.state.colony.receipts.length===21&&supplied.state.colony.activePhase===4,
      'Food resupply preserves every earlier Center receipt');
    const checkpoint=await exported('output/playwright/remake/r11-phase-four-two-left-resupplied.json');
    assert(JSON.stringify(checkpoint.state)===JSON.stringify(supplied.state),'The resupplied campaign exports unchanged');
    assert(errors.length===0,'No uncaught errors on the ordinary bank and tavern loop');
    return{browser:browser.version(),checks,errors,failures:[],journey:{minutes:supplied.state.ship.minutes,
      cash:supplied.state.dialogue.cash,condition:supplied.state.ship.condition,carried:supplied.state.ship.inventory.carried}};
  }catch(error){await page.screenshot({path:'output/playwright/remake/r11-phase-four-two-left-resupply-error.png'});return{browser:browser.version(),checks,errors,failures:[error.stack||error.message]}}
  finally{await context.close()}
}
