// Combined R08 acceptance: fresh character, real engineering/service payments,
// loaded ground round trip, independent parking and reload. No campaign fixture.
// Route planning only reads geometry; all state changes use normal controls.
async browserPage => {
  const browser=browserPage.context().browser(),checks=[],errors=[];
  const context=await browser.newContext({viewport:{width:1280,height:720}}),page=await context.newPage();
  page.on('pageerror',e=>errors.push(e.stack||e.message));page.on('dialog',d=>d.accept());
  const assert=(ok,name)=>{if(!ok)throw Error(name);checks.push(name)};
  const ready=()=>page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
  const settled=()=>page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
  const state=()=>page.locator('#walk-screen').evaluate(el=>({...el.dataset}));
  const saves=async()=>{await page.locator(await page.locator('#power-panel').count()?'#power-saves':await page.locator('#equipment-panel').count()?'#equipment-saves':['exchange','depot'].includes((await state()).scene)?'#service-saves':'#walk-saves').click();await settled()};
  const exported=async()=>{await saves();const pending=page.waitForEvent('download');await page.locator('#export-checkpoint').click();let text='';for await(const part of await(await pending).createReadStream())text+=part;await settled();await page.locator('#checkpoint-back').click();return JSON.parse(text)};
  const reload=async()=>{const before=await exported();await saves();await page.locator('#save-checkpoint-0').click();await settled();await page.reload();await ready();await page.locator('#campaign-saves').click();await settled();await page.locator('#load-checkpoint-0').click();await settled();await page.locator('#checkpoint-back').click();assert(JSON.stringify((await exported()).state)===JSON.stringify(before.state),'Fresh-page reload preserves pod location, cargo, accounts and RNG');return before};
  const rations=[];
  async function eat() {
    if(Number((await state()).nourishment)>=80)return;
    if(!rations.length)throw Error('The ordinary journey has exhausted its carried food');
    await page.locator('#walk-inventory').click();await page.locator('#slot-carried-'+rations.shift()).click();await page.locator('#inventory-use').click();
    assert(Number((await state()).nourishment)>=80,'Owned carried food restores source nourishment without a new purchase');
    await page.locator('#inventory-close').click();
  }
  async function rest() {
    if((await state()).sleeping!=='true')return;
    if((await state()).paused==='true')await page.locator('#sleep-pause').click();
    for(let i=0;i<256&&Number((await state()).rest)<240;i++)await page.clock.runFor(250);
    assert(await page.locator('#sleep-wake').isEnabled(),'Actual forced rest recovers enough to wake without granting condition');
    await page.locator('#sleep-wake').click();await page.locator('#inventory-close').click();
    await page.locator('#walk-pause').click();await page.clock.runFor(100); // Observe released movement before a new pod press.
  }
  async function route(goal) {
    await rest();await eat();
    const from=await state(),saved=(await exported()).state;
    const points=await page.evaluate(async({from,goal,saved})=>{
      const [{loadAssets},{canStand,interactionAt},{tryPodStep,canDockPod,podExchangeAt,podServiceAt}]=await Promise.all([import('/js/render/assets.js'),import('/js/core/ship-walk.js'),import('/js/core/city-pod.js')]);
      const [{campaignFootGeometry},{canBoardParkedPod},{canBoardShip},{cityServiceAt},{detachedShipGeometry}]=await Promise.all([import('/js/core/campaign-pod.js'),import('/js/core/parked-pod.js'),import('/js/core/city-walk.js'),import('/js/core/city-doors.js'),import('/js/core/ship-walk.js')]);
      const {trySurfaceStep,surfaceCityAt}=await import('/js/core/surface-walk.js');const {nearbySurfacePod}=await import('/js/core/campaign-ground.js');const a=await loadAssets(),{createGroundWorld}=await import('/js/core/campaign-ground.js'),world=createGroundWorld({...a.campaignContent,...a.campaignContent.ground},saved.start),pod=from.transport==='pod',city=from.scene==='city',surface=from.scene==='surface',g=surface?world.surface(saved.ground.colonyPosition):city?(pod?world.city(saved.ground.cityId,false).pod:world.foot(saved)):(saved.pod.attached?a.shipWalk:detachedShipGeometry(a.shipWalk));
      let routeBounds=null;if(city&&goal!=='surface'){const size=world.size(saved.ground.cityId),half=Math.floor((size+1)/2);routeBounds={left:(12-size)*28+46,right:(17+size)*28+227,top:(7-half)*32+59,bottom:(11+half)*32+138}} // Stay inside source camera exit thresholds while routing to a city destination.
      const reached=(p,h)=>goal==='surface'?p.x<125:goal.startsWith('city-')?surfaceCityAt(g.map,p)?.cityId===goal:goal==='street'?p.x===360&&p.y===215:goal==='pod'?(surface?nearbySurfacePod(p,saved.pod.position):canBoardParkedPod(g,p,saved.pod.position)):goal==='footExchange'?cityServiceAt(a.cityGeometry.map,p)==='exchange':goal==='ship'?canBoardShip(g,p):goal==='airlock'?interactionAt(p)===4:goal==='stores'?interactionAt(p)===6:goal==='engineering'?interactionAt(p)===8:goal==='depot'?podServiceAt(g,p,h)==='depot':goal==='depart'?interactionAt(p)===3:goal==='dock'?canDockPod(g,p,h):podExchangeAt(g,p,h);
      const start=Number(from.y)*g.width+Number(from.x),queue=[start],seen=new Map([[start,null]]);let end=reached({x:Number(from.x),y:Number(from.y)},Number(from.heading))?start:undefined;
      for(let i=0;i<queue.length&&end===undefined;i++) {
        const k=queue[i],p={x:k%g.width,y:Math.floor(k/g.width)};
        for(let dy=-1;dy<=1;dy++)for(let dx=-1;dx<=1;dx++)if(dx||dy) {
          const next=surface?{position:trySurfaceStep(g,p,dx,dy),heading:26}:pod?tryPodStep(g,p,dx,dy):{position:{x:p.x+dx,y:p.y+dy}};
          if(!next||(!pod&&!surface&&!canStand(g,next.position)))continue;
          if(routeBounds&&(next.position.x<routeBounds.left||next.position.x>routeBounds.right||next.position.y<routeBounds.top||next.position.y>routeBounds.bottom))continue;
          const n=next.position.y*g.width+next.position.x;if(seen.has(n))continue;
          seen.set(n,{from:k,dx,dy});queue.push(n);
          if(reached(next.position,next.heading)){end=n;break}
        }
      }
      if(end===undefined)throw Error('No route '+goal);const result=[];
      for(let k=end;k!==start;){const n=seen.get(k);result.unshift({x:k%g.width,y:Math.floor(k/g.width),dx:n.dx,dy:n.dy});k=n.from}
      return result;
    },{from,goal,saved});
    if((await state()).paused==='true')await page.locator('#walk-pause').click();
    const box=await page.locator('#stage').boundingBox();
    for(let i=0;i<points.length;i++) {
      let p=points[i];
      await rest();await eat();if((await state()).paused==='true')await page.locator('#walk-pause').click();
      const before=await state();
      if(before.transport==='pod'||before.scene==='surface') {
        let steps=1;
        if(before.transport==='pod'&&p.x-Number(before.x)===p.dx&&p.y-Number(before.y)===p.dy) {
          // A held native pod direction moves one pixel, then two per tick.
          // Drive straight segments continuously rather than restarting each
          // pixel and charging a separate moving/idle clock cycle for it.
          while(i+steps<points.length&&steps<31&&points[i+steps].dx===p.dx&&points[i+steps].dy===p.dy&&points[i+steps].x-points[i+steps-1].x===p.dx&&points[i+steps].y-points[i+steps-1].y===p.dy)steps++;
          if(steps%2===0)steps--;p=points[i+steps-1];i+=steps-1;
        }
        await page.locator('#walk-surface').focus();
        const keys=[...(p.dx?[p.dx>0?'ArrowRight':'ArrowLeft']:[]),...(p.dy?[p.dy>0?'ArrowDown':'ArrowUp']:[])];
        for(const key of keys)await page.keyboard.down(key);
        for(let t=0;t<(steps+2)*5;t++){await page.clock.runFor(16);const n=await state();if(Number(n.x)===p.x&&Number(n.y)===p.y||n.sleeping==='true'||n.scene!==before.scene)break}
        for(const key of keys)await page.keyboard.up(key);await page.clock.runFor(100); // Ensure a source iteration observes release before the next pod press.
      } else {
        if(before.scene==='city') {
          const cx=Number(before.cameraX),cy=Number(before.cameraY);
          await page.mouse.move(box.x+(145+(p.x+3.5-cx*28)*1.25)*box.width/640,box.y+(126+(p.y-2.5-cy*32)*1.25)*box.height/480);
        }else await page.mouse.move(box.x+(32+(p.x+3.25)*640/280)*box.width/640,box.y+(46+(p.y-2.75)*2)*box.height/480);
        await page.mouse.down();
        if(before.scene==='city') {
          // Release after one source step: scrolling changes the map under a
          // stationary held pointer and can otherwise cause another step.
          for(let t=0;t<10;t++){await page.clock.runFor(16);const n=await state();if(n.x!==before.x||n.y!==before.y)break}
        } else await page.clock.runFor(100);
        await page.mouse.up();
      }
      const after=await state();if(after.sleeping==='true'){await rest();return route(goal)}if(goal==='surface'&&after.scene==='surface'){assert(true,'City boundary enters the surface through normal movement');return}if(Number(after.x)!==p.x||Number(after.y)!==p.y)throw Error(`Route ${goal}: ${after.x},${after.y}, expected ${p.x},${p.y}; before ${JSON.stringify(before)}; after ${JSON.stringify(after)}`);
    }
    assert(true,`${goal} reached through normal movement (${points.length} steps)`);
    if(goal==='street'){await page.locator('#walk-pause').click();return}
    const button=goal==='stores'?'#walk-inventory':goal==='engineering'?'#walk-equipment':goal==='pod'?'#walk-pod':'#walk-airlock';assert(await page.locator(button).isEnabled(),`${goal} action is available at the reached location`);await page.locator(button).click();
  }
  async function buy() {
    await page.locator('#exchange-offers').click();const s=(await exported()).state;
    const offer=s.economy.exchange.visit.offers.map((o,i)=>({o,i})).filter(v=>v.o&&v.o.price<s.dialogue.cash+s.economy.accounts[0].balance).sort((a,b)=>a.o.price-b.o.price)[0];
    if(!offer)throw Error('No affordable cargo');await page.locator(`#exchange-row-${offer.i}`).click();await page.locator('#exchange-confirm').click();
  }
  try {
    await page.addInitScript(()=>localStorage.setItem('sundog.locale','en'));await page.clock.install({time:new Date('2026-10-03T00:00:00Z')});await page.clock.pauseAt(new Date('2026-10-03T00:00:01Z'));await page.goto('http://127.0.0.1:8000/');await ready();
    await page.locator('#create-character').click();await page.locator('#character-name').fill('R08 pilot');await page.locator('#prepare-campaign').click();await page.locator('#campaign-seed').fill('12345');await page.locator('#start-campaign').click();
    const initial=await exported();
    await route('engineering');
    const move=async(from,to)=>{await page.locator(from).click();await page.locator('#equipment-move').click();await page.locator(to).click()};
    await move('#equipment-slot-1-1','#equipment-carried-0');
    assert((await page.locator('.equipment-rating').innerText()).includes('10 / 16'),'Removing a working part disables its unit');
    await move('#equipment-carried-0','#equipment-slot-0-1');
    assert((await page.locator('.equipment-rating').innerText()).includes('11 / 16'),'Working replacement restores the shunted unit');
    await move('#equipment-carried-0','#equipment-slot-1-1');
    assert((await page.locator('.equipment-rating').innerText()).includes('14 / 16'),'Recovered shunt restores partial output without inventing spare parts');
    const engineered=await reload();
    const items=s=>[...s.equipment.flatMap(g=>g.units.flatMap(u=>u.components)),...Object.values(s.ship.inventory).flat()].sort((a,b)=>a-b);
    assert(JSON.stringify(items(engineered.state))===JSON.stringify(items(initial.state)),'Component replacement conserves every installed and carried item');
    await route('depart');await route('depot');const serviceStart=await exported();
    await page.locator('#depot-repair').click();await page.locator('#depot-confirm').click();
    await page.locator('#depot-refuel').click();await page.locator('#depot-all').click();await page.locator('#depot-confirm').click();
    const serviced=await reload();
    assert(serviced.state.resources.hull===16&&serviced.state.resources.fuel===255,'The same ship receives hull repair and full refueling');
    assert(serviced.state.economy.accounts[0].balance===serviceStart.state.economy.accounts[0].balance-2657&&serviced.state.dialogue.cash===serviceStart.state.dialogue.cash,'Combined services charge source prices145 +16×157 to the local account');
    await page.locator('#service-leave').click();await route('dock');await route('engineering');await page.locator('#equipment-power').click();
    await page.locator('#power-guns').click();await page.locator('#power-shield-full').click();
    const configured=await exported();await page.locator('#power-run').click();await page.clock.runFor(1050);const powered=await exported();
    assert(powered.state.resources.fuel===configured.state.resources.fuel-12&&powered.state.resources.guns.charge===255&&powered.state.resources.shields.charge>0,'Repaired and serviced ship powers working systems with source fuel costs');
    await page.locator('#power-guns').click();await page.locator('#power-shield-off').click();
    await reload();
    await route('depart');await route('exchange');await buy();await buy();await page.locator('#exchange-cargo').click();
    for(const i of [0,1]){await page.locator(`#cargo-warehouse-${i}`).click();await page.locator('#exchange-confirm').click()}
    const loaded=await exported();assert(loaded.state.pod.cargo.every(Boolean),'Two normally purchased cargo lots are loaded before surface departure');
    await page.locator('#service-leave').click();await route('surface');const outbound=await reload();
    assert(outbound.version===29&&outbound.state.travel.scene==='surface'&&outbound.state.ground.cityId===null,'Version29 reloads the live surface scene');
    assert(outbound.state.ground.colonyPosition!==null,'First surface entry persists colony placement');
    for(const lang of ['en','ko']) {
      if((await page.locator('html').getAttribute('lang'))!==lang)await page.locator('#walk-language').click();
      for(const [width,height] of [[1280,720],[640,480],[390,844],[844,390]]) {
        await page.setViewportSize({width,height});await page.clock.runFor(100);
        await page.waitForFunction(()=>Math.abs(document.querySelector('#stage').getBoundingClientRect().width-Math.min(innerWidth,innerHeight*4/3))<1);
        assert(await page.locator('.walk-actions').evaluate(el=>{const r=el.getBoundingClientRect();return r.left>=0&&r.right<=innerWidth+1&&r.bottom<=innerHeight+1}),`${lang} surface controls fit ${width}x${height}`);
      }
    }
    await page.screenshot({path:'output/playwright/remake/r08-journey-ko.png'});await page.setViewportSize({width:1280,height:720});
    await page.locator('#walk-pod').click();const parked=await reload();
    assert(!parked.state.pod.occupied&&parked.state.ground.podCityId===null,'Parking preserves the loaded pod on the surface');
    await route('city-01');await reload();assert((await state()).transport==='foot','City entry on foot does not move or board the parked pod');
    assert(await page.locator('#walk-pod').isDisabled(),'A surface pod cannot be boarded remotely from a city');
    await route('ship');const aboard=await reload();assert(JSON.stringify(aboard.state.pod)===JSON.stringify(parked.state.pod),'Foot ship return preserves the remote surface pod and cargo');
    await page.locator('#walk-inventory').click();assert(await page.locator('#pod-manifest').count()===0,'Remote surface cargo is not exposed aboard the ship');await page.locator('#inventory-close').click();
    await route('stores');for(let i=0;i<4;i++){await page.locator('#slot-stores-'+(5+i)).click();await page.locator('#slot-carried-'+i).click();rations.push(i)}
    await page.locator('#inventory-close').click();const supplied=await exported();assert(supplied.state.ship.inventory.carried.every(b=>b===8)&&[5,6,7,8].every(i=>supplied.state.ship.inventory.stores[i]===0),'Four existing food rations transfer from real ship stores into carried slots');
    await route('airlock');await route('surface');await route('pod');const retrieved=await reload();
    assert(retrieved.state.pod.occupied&&JSON.stringify(retrieved.state.pod.cargo)===JSON.stringify(loaded.state.pod.cargo),'Foot surface return retrieves both purchased cargo lots');
    await route('city-02');const remote=await reload();assert(remote.state.ground.cityId==='city-02'&&remote.state.ground.podCityId==='city-02','Pod reaches and reloads another source city');
    await page.screenshot({path:'output/playwright/remake/r08-journey-destination-city.png'});
    await page.locator('#walk-pod').click();await reload();await page.locator('#walk-pod').click();await reload();
    await route('surface');await route('city-01');await route('dock');const returned=await reload();
    assert(returned.state.pod.attached&&!returned.state.pod.occupied&&JSON.stringify(returned.state.pod.cargo)===JSON.stringify(loaded.state.pod.cargo),'Cross-city surface return docks with both purchased cargo lots intact');
    assert(JSON.stringify(returned.state.ground.colonyPosition)===JSON.stringify(outbound.state.ground.colonyPosition),'Surface revisits retain the original colony placement');
    assert(JSON.stringify(returned.state.economy.accounts)===JSON.stringify(loaded.state.economy.accounts)&&returned.state.dialogue.cash===loaded.state.dialogue.cash,'Ground travel adds no payments or account changes');
    assert(returned.state.resources.hull===16&&JSON.stringify(returned.state.equipment)===JSON.stringify(engineered.state.equipment),'Loaded surface return preserves repaired hull and replaced components');
    assert(JSON.stringify(returned.state.start)===JSON.stringify(initial.state.start),'Combined journey preserves immutable creation data');
    assert(errors.length===0,'No uncaught combined engineering, servicing or ground travel errors');return {browser:browser.version(),checks,errors};
  }catch(error){await page.screenshot({path:'output/playwright/remake/r08-journey-error.png'});return {browser:browser.version(),checks,errors,failures:[error.message]}}
  finally {await context.close()}
}
