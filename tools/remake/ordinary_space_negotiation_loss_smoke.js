// R10 ordinary space acceptance: a fresh character pays for fuel and cargo,
// produces a contact through powered flight, and uses normal saved points.
// No fixtures, state imports, RNG writes, damage writes or synthetic contacts.
// Route planning only reads geometry; all state changes use normal controls.
async browserPage => {
  const browser=browserPage.context().browser(),checks=[],errors=[],states={},lossSamples=[];let last=null;
  const context=await browser.newContext({viewport:{width:1280,height:720}}),page=await context.newPage();
  page.on('pageerror',e=>errors.push(e.stack||e.message));page.on('dialog',d=>d.accept());
  const assert=(ok,name)=>{if(!ok)throw Error(name);checks.push(name)};
  const ready=()=>page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
  const settled=()=>page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
  const state=()=>page.locator('#walk-screen').evaluate(el=>({...el.dataset}));
  const saves=async()=>{await page.locator(await page.locator('#dialogue-panel').count()?'#dialogue-saves':await page.locator('.sleep-panel').count()?'#sleep-saves':await page.locator('#navigation-panel').count()?'#nav-saves':await page.locator('#space-panel').count()?'#space-saves':await page.locator('#power-panel').count()?'#power-saves':await page.locator('#equipment-panel').count()?'#equipment-saves':['exchange','depot'].includes((await state()).scene)?'#service-saves':'#walk-saves').click();await settled()};
  const exported=async()=>{await saves();const pending=page.waitForEvent('download');await page.locator('#export-checkpoint').click();let text='';for await(const part of await(await pending).createReadStream())text+=part;await settled();await page.locator('#checkpoint-back').click();last=JSON.parse(text);return last};
  const reload=async(slot=0)=>{const before=await exported();await saves();await page.locator('#save-checkpoint-'+slot).click();await settled();await page.reload();await ready();await page.locator('#campaign-saves').click();await settled();await page.locator('#load-checkpoint-'+slot).click();await settled();await page.locator('#checkpoint-back').click();assert(JSON.stringify((await exported()).state)===JSON.stringify(before.state),'Fresh-page reload preserves the complete campaign state');return before};
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
  try {
    await page.addInitScript(()=>localStorage.setItem('sundog.locale','en'));await page.clock.install({time:new Date('2026-10-07T00:00:00Z')});await page.clock.pauseAt(new Date('2026-10-07T00:00:01Z'));await page.goto('http://127.0.0.1:8000/');await ready();
    await page.locator('#create-character').click();await page.locator('#character-name').fill('R10 pilot');await page.locator('#prepare-campaign').click();await page.locator('#campaign-seed').fill('12345');await page.locator('#start-campaign').click();const initial=await exported();
    await route('depart');await route('depot');await page.locator('#depot-refuel').click();await page.locator('#depot-all').click();await page.locator('#depot-confirm').click();await page.locator('#service-leave').click();await route('exchange');await buy();await buy();await page.locator('#exchange-cargo').click();
    const bought=await exported();const slots=bought.state.economy.exchange.warehouse.slots.map((c,i)=>c?.originCity==='city-01'?i:null).filter(i=>i!==null);assert(slots.length===2,'Two ordinary board purchases are available to load');
    for(const i of slots){await page.locator('#cargo-warehouse-'+i).click();await page.locator('#exchange-confirm').click()}
    const loaded=await reload();assert(loaded.state.pod.cargo.every(Boolean),'Both normally purchased lots are loaded');await page.locator('#service-leave').click();await route('dock');await route('navigation');
    await command('launch');await arrive();const orbit=await exported();
    await destination('system','point-0');await page.locator('#nav-run').click();
    for(let i=0;i<1024;i++) {
      await page.clock.runFor(250);const current=await state();
      if(current.contact==='true'||current.dead==='true'||!current.flight)break;
    }
    const contact=await exported();
    if((await state()).contact==='true') {await navigation();await page.locator('#nav-tactical').click()}
    const tactical=await exported();
    assert(contact.state.space.flags[40]&&tactical.state.space.view==='tactical','Powered flight naturally produces a contact and normal Navigation opens tactical controls');
    assert(tactical.state.resources.hull===15&&tactical.state.space.words[216]>0,'Encounter begins with legitimate initial hull and an actual living enemy');
    states.tactical=await reload(1);
    const run=async ms=>{if((await state()).paused==='true')await page.locator('#space-run').click();await page.clock.runFor(ms)};
    await run(1000);
    for(let i=0;i<100;i++) {
      const pose=await state();lossSamples.push({elapsedMs:(i+1)*1000,pose});
      if(pose.dead==='true')break;
      await page.clock.runFor(1000);
    }
    assert((await state()).dead==='true'&&await page.locator('#sleep-title').innerText()==='Ship destroyed','An unshielded ordinary encounter reaches the actual ship-destruction scene');
    states.dead=await reload(2);
    assert(states.dead.state.space.defeat?.reason==='shipDestroyed'&&states.dead.state.space.words[347]===1,'Ordinary destruction commits its durable defeat marker');
    assert(states.dead.state.ship.condition.health===states.tactical.state.ship.condition.health,'Ship destruction does not invent personal injury');
    await page.clock.runFor(5000);assert(JSON.stringify((await exported()).state)===JSON.stringify(states.dead.state),'Terminal time and all owners remain frozen after fresh-page reload');
    await page.screenshot({path:'output/playwright/remake/ordinary-space-death.png'});
    await saves();await page.locator('#load-checkpoint-1').click();await settled();await page.locator('#checkpoint-back').click();
    assert(JSON.stringify((await exported()).state)===JSON.stringify(states.tactical.state),'Explicit earlier-slot recovery restores the exact legitimate encounter');
    await page.locator('#space-comm').click();states.pending=await reload(2);
    assert(states.pending.state.space.communication.conversation?.context.kind===19,'Ordinary Comm freezes the actual kind19 enemy conversation');
    await page.clock.runFor(5000);assert(JSON.stringify((await exported()).state)===JSON.stringify(states.pending.state),'Ordinary Comm freezes flight, machinery and combat while waiting');
    await page.locator('#dialogue-reply-0').click();await page.locator('#dialogue-cancel').click();states.agreed=await reload(2);
    assert(states.agreed.state.space.communication.pending&&states.agreed.state.space.communication.ticks===6,'Ordinary Agree arms the source six-tick cargo deadline');
    assert(JSON.stringify(states.agreed.state.pod.cargo)===JSON.stringify(states.tactical.state.pod.cargo),'Agreement leaves purchased cargo aboard until explicit jettison');
    assert(states.agreed.state.dialogue.cash===states.tactical.state.dialogue.cash&&JSON.stringify(states.agreed.state.economy.accounts)===JSON.stringify(states.tactical.state.economy.accounts),'Cargo negotiation does not invent a cash or bank transfer');
    await page.locator('#space-shields').click();await page.locator('#space-shield-full').click();await page.locator('#space-menu-back').click();
    states.shields=await exported();assert(states.shields.state.resources.shields.targetCharge===255,'Normal shield controls request full charge from actual working equipment');
    await page.locator('#space-bolts').click();assert(await page.locator('#space-jettison-3').isEnabled(),'Normal bolt controls offer Both for the two purchased ordinary cargo lots');
    await page.locator('#space-jettison-3').click();states.jettisoned=await reload(2);
    assert(states.jettisoned.state.pod.cargo.every(c=>c===null)&&states.jettisoned.state.space.losses.length===2,'Explicit Both jettison removes and records both legitimate cargo lots');
    assert(states.jettisoned.state.space.communication.pending&&states.jettisoned.state.space.communication.ticks===6,'Jettison retains the source-owned negotiation deadline');
    assert(JSON.stringify(states.jettisoned.state.space.losses.map(v=>v.lot))===JSON.stringify([...states.tactical.state.pod.cargo].reverse()),'Cargo loss retains actual lot identity, quality, price and reverse slot order');
    await run(1000);states.escaped=await reload(2);
    assert(!states.escaped.state.space.flags[40]&&!states.escaped.state.space.defeat,'Jettison leads to an ordinary contact escape without destruction');
    assert(states.escaped.state.resources.shields.charge>0&&states.escaped.state.resources.fuel<states.jettisoned.state.resources.fuel,'Live power charges requested shields using actual fuel');
    assert(states.escaped.state.resources.hull===states.tactical.state.resources.hull,'Ordinary cargo escape preserves the initial hull');
    assert(states.escaped.state.space.losses.length===2&&states.escaped.state.pod.cargo.every(c=>c===null),'Escape and reload do not repeat the cargo loss');
    await page.screenshot({path:'output/playwright/remake/ordinary-space-escape.png'});
    const hash=async s=>page.evaluate(async value=>{
      const bytes=new Uint8Array(await crypto.subtle.digest('SHA-256',new TextEncoder().encode(JSON.stringify(value))));
      return Array.from(bytes,b=>b.toString(16).padStart(2,'0')).join('');
    },s);
    const project=async v=>({stateHash:await hash(v.state),ship:v.state.ship,resources:v.state.resources,space:v.state.space,equipment:v.state.equipment,
      machinery:v.state.machinery,engineering:v.state.engineering,flight:v.state.flight,regional:v.state.regional.shipLocation,
      pod:v.state.pod,accounts:v.state.economy.accounts,cash:v.state.dialogue.cash,randomState:v.state.encounters.randomState});
    Object.assign(states,{initial,loaded,orbit,contact});
    assert(Object.values(states).every(v=>JSON.stringify(v.state.start)===JSON.stringify(initial.state.start)),'Every ordinary branch preserves immutable creation data');
    assert(JSON.stringify(states.dead.state.pod.cargo)===JSON.stringify(states.tactical.state.pod.cargo)&&states.dead.state.space.losses.length===0,'Destruction does not manufacture jettison or transfer purchased cargo');
    assert(states.dead.state.dialogue.cash===states.tactical.state.dialogue.cash&&JSON.stringify(states.dead.state.economy.accounts)===JSON.stringify(states.tactical.state.economy.accounts),'Ordinary ship damage leaves personal cash and bank accounts independent');
    const projected={};for(const [n,v]of Object.entries(states))projected[n]=await project(v);
    return {browser:browser.version(),scope:'Fresh seed12345 character; ordinary paid fuel, purchased cargo, launch and sublight contact; explicit saved-point branches; no imports or state mutations outside UI',checks,failures:[],errors,creationHash:await hash(initial.state.start),lossSamples,pose:await state(),states:projected};
  }catch(error){return {browser:browser.version(),checks,failures:[error.stack||error.message],errors,last:last?{space:last.state.space,resources:last.state.resources,randomState:last.state.encounters.randomState}:null,pose:await state(),buttons:await page.locator('button').evaluateAll(els=>els.filter(e=>e.offsetParent).map(e=>({id:e.id,text:e.textContent,disabled:e.disabled})))}}finally{await context.close()}
}
