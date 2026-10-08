// R09 acceptance: fresh character, paid fuel, purchased cargo and a two-system
// flight/trading round trip with fresh-page reloads. No campaign fixture.
// Route planning only reads geometry; all state changes use normal controls.
async browserPage => {
  const browser=browserPage.context().browser(),checks=[],errors=[];
  const context=await browser.newContext({viewport:{width:1280,height:720}}),page=await context.newPage();
  page.on('pageerror',e=>errors.push(e.stack||e.message));page.on('dialog',d=>d.accept());
  const assert=(ok,name)=>{if(!ok)throw Error(name);checks.push(name)};
  const ready=()=>page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
  const settled=()=>page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
  const state=()=>page.locator('#walk-screen').evaluate(el=>({...el.dataset}));
  const saves=async()=>{await page.locator(await page.locator('#navigation-panel').count()?'#nav-saves':await page.locator('#space-panel').count()?'#space-saves':await page.locator('#power-panel').count()?'#power-saves':await page.locator('#equipment-panel').count()?'#equipment-saves':['exchange','depot'].includes((await state()).scene)?'#service-saves':'#walk-saves').click();await settled()};
  const exported=async()=>{await saves();const pending=page.waitForEvent('download');await page.locator('#export-checkpoint').click();let text='';for await(const part of await(await pending).createReadStream())text+=part;await settled();await page.locator('#checkpoint-back').click();return JSON.parse(text)};
  const reload=async()=>{const before=await exported();await saves();await page.locator('#save-checkpoint-0').click();await settled();await page.reload();await ready();await page.locator('#campaign-saves').click();await settled();await page.locator('#load-checkpoint-0').click();await settled();await page.locator('#checkpoint-back').click();assert(JSON.stringify((await exported()).state)===JSON.stringify(before.state),'Fresh-page reload preserves pod location, cargo, accounts and RNG');return before};
  async function route(goal) {
    const from=await state(),saved=(await exported()).state;
    const points=await page.evaluate(async({from,goal,saved})=>{
      const [{loadAssets},{canStand,interactionAt},{tryPodStep,canDockPod,podExchangeAt,podServiceAt}]=await Promise.all([import('/js/render/assets.js'),import('/js/core/ship-walk.js'),import('/js/core/city-pod.js')]);
      const [{campaignFootGeometry},{canBoardParkedPod},{canBoardShip},{cityServiceAt},{detachedShipGeometry}]=await Promise.all([import('/js/core/campaign-pod.js'),import('/js/core/parked-pod.js'),import('/js/core/city-walk.js'),import('/js/core/city-doors.js'),import('/js/core/ship-walk.js')]);
      const {trySurfaceStep,surfaceCityAt}=await import('/js/core/surface-walk.js');const {nearbySurfacePod}=await import('/js/core/campaign-ground.js');const a=await loadAssets(),{createGroundWorld}=await import('/js/core/campaign-ground.js'),world=createGroundWorld({...a.campaignContent,...a.campaignContent.ground},(await import('/js/core/regional-world.js')).regionalGroundStart(saved)),pod=from.transport==='pod',city=from.scene==='city',surface=from.scene==='surface',g=surface?world.surface(saved.ground.colonyPosition):city?(pod?world.city(saved.ground.cityId,false).pod:world.foot(saved)):(saved.pod.attached?a.shipWalk:detachedShipGeometry(a.shipWalk));
      let routeBounds=null;if(city&&goal!=='surface'){const size=world.size(saved.ground.cityId),half=Math.floor((size+1)/2);routeBounds={left:(12-size)*28+46,right:(17+size)*28+227,top:(7-half)*32+59,bottom:(11+half)*32+138}} // Stay inside source camera exit thresholds while routing to a city destination.
      const reached=(p,h)=>goal==='surface'?p.x<125:goal.startsWith('city-')?surfaceCityAt(g.map,p)?.cityId===goal:goal==='street'?p.x===360&&p.y===215:goal==='pod'?(surface?nearbySurfacePod(p,saved.pod.position):canBoardParkedPod(g,p,saved.pod.position)):goal==='footExchange'?cityServiceAt(world.city(saved.ground.cityId,saved.pod.attached).map,p)==='exchange':goal==='ship'?canBoardShip(g,p):goal==='airlock'?interactionAt(p)===4:goal==='navigation'?interactionAt(p)===1:goal==='engineering'?interactionAt(p)===8:goal==='depot'?podServiceAt(g,p,h)==='depot':goal==='depart'?interactionAt(p)===3:goal==='dock'?canDockPod(g,p,h):podExchangeAt(g,p,h);
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
    for(const p of points) {
      const before=await state();
      if(before.transport==='pod'||before.scene==='surface') {
        await page.locator('#walk-surface').focus();
        const keys=[...(p.dx?[p.dx>0?'ArrowRight':'ArrowLeft']:[]),...(p.dy?[p.dy>0?'ArrowDown':'ArrowUp']:[])];
        for(const key of keys)await page.keyboard.down(key);
        for(let t=0;t<10;t++){await page.clock.runFor(16);const n=await state();if(n.x!==before.x||n.y!==before.y)break}
        for(const key of keys)await page.keyboard.up(key);await page.clock.runFor(50); // Let the source host observe the released movement button.
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
      const after=await state();if(goal==='surface'&&after.scene==='surface'){assert(true,'City boundary enters the surface through normal movement');return}if(Number(after.x)!==p.x||Number(after.y)!==p.y)throw Error(`Route ${goal}: ${after.x},${after.y}, expected ${p.x},${p.y}`);
    }
    assert(true,`${goal} reached through normal movement (${points.length} steps)`);
    if(goal==='street'){await page.locator('#walk-pause').click();return}
    const button=goal==='navigation'?'#walk-navigation':goal==='engineering'?'#walk-equipment':goal==='pod'?'#walk-pod':'#walk-airlock';assert(await page.locator(button).isEnabled(),`${goal} action is available at the reached location`);await page.locator(button).click();
  }
  async function buy() {
    await page.locator('#exchange-offers').click();const s=(await exported()).state;
    // Pricing is a read-only plan; live purchases still use the normal board.
    const selected=await page.evaluate(async s=>{const {loadAssets}=await import('/js/render/assets.js'),a=await loadAssets(),{quoteExchangeCargo,exchangeLocation}=await import('/js/core/exchange.js'),market=s.start.economy.markets.find(m=>m.cityId==='city-09'),originLocation=exchangeLocation(a.campaignContent.exchange,'city-01'),location=exchangeLocation(a.campaignContent.exchange,'city-09');return s.economy.exchange.visit.offers.map((o,i)=>({o,i,quote:o?quoteExchangeCargo({commodityId:o.commodityId,quality:o.quality,originCity:'city-01',pricePaid:o.price},{market,location,originLocation,items:a.campaignContent.dialogue.items},'sell'):0})).filter(v=>v.o&&v.o.price<s.dialogue.cash+s.economy.accounts[0].balance&&v.quote>v.o.price).sort((a,b)=>(b.quote-b.o.price)-(a.quote-a.o.price))[0]},s);
    if(!selected)throw Error('No affordable profitable cargo');await page.locator(`#exchange-row-${selected.i}`).click();await page.locator('#exchange-confirm').click();
  }
  async function navigation() {if(await page.locator('#navigation-panel').count())return;await page.locator(await page.locator('#space-panel').count()?'#space-navigation':'#walk-navigation').click()}
  async function command(type) {await navigation();await page.locator('#nav-'+type).click();await page.locator('#nav-confirm').click()}
  async function destination(scale,id) {await navigation();await page.locator('#nav-scale-'+scale).click();await page.locator('#nav-destination').selectOption(id);await page.locator('#nav-select').click();await page.locator('#nav-confirm').click()}
  async function arrive() {await page.locator('#nav-run').click();for(let i=0;i<1024;i++){await page.clock.runFor(250);if(!(await state()).flight)break}assert(!(await state()).flight,'The confirmed journey reaches its destination through the live clock')}
  async function charge() {await page.locator('#nav-run').click();for(let i=0;i<256;i++){await page.clock.runFor(250);if(await page.locator('#nav-warp').isEnabled())break}assert(await page.locator('#nav-warp').isEnabled(),'Warp engine reaches its requested charge through the live power phases')}
  try {
    await page.addInitScript(()=>localStorage.setItem('sundog.locale','en'));await page.clock.install({time:new Date('2026-10-07T00:00:00Z')});await page.clock.pauseAt(new Date('2026-10-07T00:00:01Z'));await page.goto('http://127.0.0.1:8000/');await ready();
    await page.locator('#create-character').click();await page.locator('#character-name').fill('R09 trader');await page.locator('#prepare-campaign').click();await page.locator('#campaign-seed').fill('12345');await page.locator('#start-campaign').click();const initial=await exported();
    await route('depart');await route('depot');await page.locator('#depot-refuel').click();await page.locator('#depot-all').click();await page.locator('#depot-confirm').click();await page.locator('#service-leave').click();await route('exchange');await buy();await buy();await page.locator('#exchange-cargo').click();
    const bought=await exported();const slots=bought.state.economy.exchange.warehouse.slots.map((c,i)=>c?.originCity==='city-01'?i:null).filter(i=>i!==null);assert(slots.length===2,'Two ordinary board purchases are available to load');
    for(const i of slots){await page.locator('#cargo-warehouse-'+i).click();await page.locator('#exchange-confirm').click()}
    const loaded=await reload(),homeMarket=loaded.state.economy.exchange.market,totalPaid=loaded.state.pod.cargo.reduce((n,c)=>n+c.pricePaid,0);assert(loaded.state.pod.cargo.every(Boolean),'Both normally purchased lots are loaded');await page.locator('#service-leave').click();await route('dock');await route('navigation');
    await command('launch');await arrive();const orbit=await exported();await destination('star','system-02');await charge();await command('warp');const failed=await reload();assert(failed.state.flight.lastEvent==='flightGravityFailure'&&JSON.stringify(failed.state.regional.shipLocation)===JSON.stringify(orbit.state.regional.shipLocation)&&failed.state.resources.warp.charge===0,'Warp in a gravity field fails and consumes the real accumulated charge');await navigation();
    await destination('system','point-0');await page.locator('#nav-run').click();for(let i=0;i<32;i++){await page.clock.runFor(250);if(Number((await state()).flightProgress)>0)break}const mid=await reload();assert(mid.state.flight.motion?.type==='sublight'&&mid.state.flight.motion.progress>0,'Mid-sublight reload preserves the live journey');await navigation();await arrive();const point=await exported();assert(point.state.regional.shipLocation.orbit.radius===43&&point.state.regional.shipLocation.worldId===null,'Travel reaches a safe source warp point');
    await destination('star','system-02');await charge();await command('warp');const jumped=await reload();assert(jumped.state.regional.shipLocation.systemId==='system-02'&&jumped.state.flight.lastEvent==='flightWarpComplete','Actual charged jump reaches system02');assert(JSON.stringify(jumped.state.pod.cargo)===JSON.stringify(loaded.state.pod.cargo),'Jump retains both purchased cargo lots');await navigation();
    await destination('system','world-03');await arrive();await destination('planet','city-09');await arrive();const landing=await reload();assert(landing.state.regional.shipLocation.cityId==='city-09'&&landing.state.ground.worldId==='world-03','Foreign capital landing reloads the correct regional ground domain');await route('depart');await route('exchange');const entered=await exported();assert(entered.state.economy.exchange.market.cityId==='city-09','Foreign exchange owns its actual stock');assert(JSON.stringify(entered.state.regional.cities.find(c=>c.market.cityId==='city-01').market)===JSON.stringify(homeMarket),'Home market survives in the dormant archive');
    await page.locator('#exchange-cargo').click();for(const i of [0,1]){await page.locator('#cargo-pod-'+i).click();await page.locator('#exchange-confirm').click()}
    const stored=await reload();assert(stored.state.pod.cargo.every(c=>c===null),'Cargo unloads into the foreign warehouse without duplication');await page.locator('#exchange-warehouse').click();
    const sellSlots=stored.state.economy.exchange.warehouse.slots.map((c,i)=>c?.originCity==='city-01'?i:null).filter(i=>i!==null),bankBefore=stored.state.economy.accounts[1].balance;
    for(const i of sellSlots){await page.locator('#exchange-row-'+i).click();await page.locator('#exchange-confirm').click()}
    const sold=await reload();assert(sold.state.regional.cargoProceeds>totalPaid,'Cross-system settlement makes a profit on ordinary purchased cargo');assert(sold.state.economy.accounts[1].balance===bankBefore+sold.state.regional.cargoProceeds&&sold.state.economy.accounts[0].balance===stored.state.economy.accounts[0].balance,'Foreign sale credits only the visited system account');
    await page.locator('#service-leave').click();await route('depot');const fuelBefore=await exported();await page.locator('#depot-refuel').click();await page.locator('#depot-all').click();await page.locator('#depot-confirm').click();const serviced=await reload();assert(serviced.state.resources.fuel===255&&serviced.state.economy.accounts[1].balance<fuelBefore.state.economy.accounts[1].balance,'Foreign depot refuels the landed ship from the visited account');await page.locator('#service-leave').click();await route('dock');await route('navigation');
    await command('launch');await arrive();await destination('system','point-0');await arrive();await destination('star','system-01');await charge();await command('warp');await destination('system','world-01');await arrive();await destination('planet','city-01');await arrive();const returned=await reload();assert(returned.state.regional.shipLocation.systemId==='system-01'&&returned.state.ground.cityId==='city-01','Return flight lands at the home capital');assert(JSON.stringify(returned.state.start)===JSON.stringify(initial.state.start),'Creation data remains immutable throughout the full journey');assert(returned.state.regional.cargoProceeds===sold.state.regional.cargoProceeds,'Sale proceeds survive both return flight and reload');
    await route('depart');await route('exchange');const home=await reload();assert(JSON.stringify(home.state.economy.exchange.market)===JSON.stringify(homeMarket),'Home stock is restored without a duplicate refresh during the same day');assert(home.state.economy.exchange.warehouse.slots.every(c=>c===null),'Sold cargo does not reappear in the home warehouse');
    return {browser:browser.version(),checks,failures:[],errors,journey:{origin:'system-01/world-01/city-01',destination:'system-02/world-03/city-09',pricePaid:totalPaid,saleProceeds:sold.state.regional.cargoProceeds,minutes:home.state.ship.minutes,fuel:home.state.resources.fuel}};
  }catch(error){return {browser:browser.version(),checks,failures:[error.stack||error.message],errors}}finally{await context.close()}
}
