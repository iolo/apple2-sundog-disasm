// Fresh character, legitimate stores transfers and natural city encounter.
// Geometry and exported saves are read-only; no campaign state is imported.
async browserPage => {
  const browser=browserPage.context().browser(),checks=[],errors=[];
  const context=await browser.newContext({viewport:{width:1280,height:720},hasTouch:true});
  const page=await context.newPage();
  page.on('pageerror',e=>errors.push(e.message));page.on('requestfailed',r=>errors.push(r.url()));page.on('dialog',d=>d.accept());
  const assert=(ok,name)=>{if(!ok)throw Error(name);checks.push(name)};
  const ready=()=>page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
  const settled=()=>page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
  const state=()=>page.locator('#walk-screen').evaluate(el=>({...el.dataset}));
  const saves=async()=>{await page.locator(await page.locator('#dialogue-panel').count()?'#dialogue-saves':['transstation','depot','exchange'].includes((await state()).scene)?'#service-saves':'#walk-saves').click();await settled()};
  const exportGame=async()=>{
    await saves();const pending=page.waitForEvent('download');await page.locator('#export-checkpoint').click();
    let text='';for await(const part of await (await pending).createReadStream())text+=part;
    await settled();await page.locator('#checkpoint-back').click();return JSON.parse(text);
  };
  const run=async ms=>{if((await state()).paused==='true')await page.locator('#walk-pause').click();await page.clock.runFor(ms)};
  const shipMove=async(x,y)=>{
    await run(0);const box=await page.locator('#stage').boundingBox();
    await page.mouse.move(box.x+(32+(x+3.25)*640/280)*box.width/640,box.y+(46+(y-2.75)*2)*box.height/480);
    await page.mouse.down();for(let i=0;i<400;i++){await page.clock.runFor(16);const d=await state();if(Number(d.x)===x&&Number(d.y)===y)break}await page.mouse.up();
    const d=await state();assert(Number(d.x)===x&&Number(d.y)===y,`Ordinary ship walk reaches ${x},${y}`);
  };
  const activation=async value=>page.evaluate(async value=>{
    const [{loadAssets},{createGroundWorld},{regionalGroundStart},{restoreCampaignGroundHost}]=await Promise.all([import('/js/render/assets.js'),import('/js/core/campaign-ground.js'),import('/js/core/regional-world.js'),import('/js/core/ground-host.js')]);
    const a=await loadAssets(),world=createGroundWorld({...a.campaignContent,...a.campaignContent.ground},regionalGroundStart(value.state));
    return restoreCampaignGroundHost(value.state,world,a.campaignContent).encounter.activation;
  },value);
  const walkToBuilding=async type=>{
    const from=await state();
    const route=await page.evaluate(async ({from,type})=>{
      const [{canStand},{createCityMaps},{createCityGeometry},{cityDoorAt}]=await Promise.all([
        import('/js/core/ship-walk.js'),import('/js/core/city-map.js'),import('/js/core/city-walk.js'),import('/js/core/city-doors.js')]);
      const [maps,navigation,economy,location,content]=await Promise.all(['maps','initial-navigation','initial-economy','initial-location','city-walk'].map(n=>fetch(`/data/${n}.json`).then(r=>r.json())));
      const map=createCityMaps(maps,navigation,economy)['city-01'];
      const g=createCityGeometry(map,content,{...location,position:location.shipPosition});
      const start=Number(from.y)*g.width+Number(from.x),previous=new Int32Array(g.width*g.height).fill(-1),distance=new Int32Array(g.width*g.height).fill(2147483647),queue=[[0,start]];
      distance[start]=0;
      const offer=(cost,node)=>{queue.push([cost,node]);let i=queue.length-1;while(i){const parent=(i-1)>>1;if(queue[parent][0]<=cost)break;queue[i]=queue[parent];i=parent}queue[i]=[cost,node]};
      previous[start]=start;let end;
      while(queue.length) {
        const [cost,k]=queue[0],last=queue.pop();
        if(queue.length){let i=0;while(2*i+1<queue.length){let child=2*i+1;if(child+1<queue.length&&queue[child+1][0]<queue[child][0])child++;if(queue[child][0]>=last[0])break;queue[i]=queue[child];i=child}queue[i]=last}
        if(cost!==distance[k])continue;const p={x:k%g.width,y:Math.floor(k/g.width)};
        if(cityDoorAt(map,p)?.scene===6&&cityDoorAt(map,p)?.type===type){end=k;break}
        for(let dy=-1;dy<=1;dy++)for(let dx=-1;dx<=1;dx++) {
          if(!dx&&!dy)continue;
          const q={x:p.x+dx,y:p.y+dy},next=q.y*g.width+q.x;
          if(!canStand(g,q))continue;
          // Prefer eligible city terrain; native threat setup rejects tiles0/1.
          const tile=map.tiles[((Math.floor((q.y-3)/32)%24)+24)%24][((Math.floor((q.x+3)/28)%40)+40)%40]&15,nextCost=cost+(tile<2?30:1);
          if(nextCost<distance[next]){distance[next]=nextCost;previous[next]=k;offer(nextCost,next)}
        }
      }
      if(end===undefined)throw Error('No reachable building');
      const points=[];for(let k=end;k!==start;k=previous[k])points.unshift({x:k%g.width,y:Math.floor(k/g.width)});
      return points;
    },{from,type});
    if((await state()).paused==='true')await page.locator('#walk-pause').click();
    const box=await page.locator('#stage').boundingBox();
    for(const point of route) {
      const before=await state(),cx=Number(before.cameraX),cy=Number(before.cameraY);
      await page.mouse.move(box.x+(145+(point.x+3.5-cx*28)*1.25)*box.width/640,box.y+(126+(point.y-2.5-cy*32)*1.25)*box.height/480);
      await page.mouse.down();for(let t=0;t<10;t++){await page.clock.runFor(16);const n=await state();if(n.x!==before.x||n.y!==before.y)break}await page.mouse.up();
      const after=await state();if(after.encounter==='chase')return true;if(Number(after.x)!==point.x||Number(after.y)!==point.y)throw Error(`Route stopped at ${after.x},${after.y}, expected ${JSON.stringify(point)}; after ${JSON.stringify(after)}`);
    }
    return route.length;
  };
  const point=async(x,y)=>{const box=await page.locator('#stage').boundingBox();await page.mouse.move(box.x+(145+(x+.25)*1.25)*box.width/640,box.y+(126+(y+.25)*1.25)*box.height/480)};
  const reloadExact=async()=>{const before=await exportGame();await saves();await page.locator('#save-checkpoint-1').click();await settled();await page.reload();await ready();await page.locator('#campaign-saves').click();await settled();await page.locator('#load-checkpoint-1').click();await settled();await page.locator('#checkpoint-back').click();assert(JSON.stringify((await exportGame()).state)===JSON.stringify(before.state),'Fresh-page reload preserves the exact ordinary encounter state');return before};
  const summarize=async saved=>{
    const state=saved.state;
    const hashes=await page.evaluate(async state=>{
      const sha=async value=>Array.from(new Uint8Array(await crypto.subtle.digest('SHA-256',new TextEncoder().encode(JSON.stringify(value))))).map(n=>n.toString(16).padStart(2,'0')).join('');
      return {campaign:await sha(state),creation:await sha(state.start)};
    },state);
    return {version:saved.version,scope:saved.scope,hashes,travel:state.travel,ground:state.ground,ship:state.ship,cash:state.dialogue.cash,accounts:state.economy.accounts,randomState:state.encounters.randomState,combat:state.combat};
  };
  let last;
  try {
    await page.addInitScript(()=>localStorage.setItem('sundog.locale','en'));
    await page.clock.install({time:new Date('2026-10-08T00:00:00Z')});await page.clock.pauseAt(new Date('2026-10-08T00:00:01Z'));
    await page.goto('http://127.0.0.1:8000/');await ready();
    await page.locator('#create-character').click();await page.locator('#character-name').fill('Ground pilot');
    await page.locator('#prepare-campaign').click();await page.locator('#campaign-seed').fill('12345');await page.locator('#start-campaign').click();
    const initial=await exportGame();await shipMove(54,86);await page.locator('#walk-inventory').click();
    await page.locator('#slot-stores-11').click();await page.locator('#slot-carried-0').click();
    await page.locator('#slot-stores-10').click();await page.locator('#slot-carried-1').click();await page.locator('#inventory-close').click();
    const armed=await exportGame();assert(armed.state.ship.inventory.carried[0]===12&&armed.state.ship.inventory.carried[1]===235,'Actual stores transfers equip the laser and seven-charge shield');
    assert(armed.state.ship.inventory.stores[11]===0&&armed.state.ship.inventory.stores[10]===0,'Each item has exactly one legitimate owner');
    await saves();await page.locator('#save-checkpoint-0').click();await settled();await page.locator('#checkpoint-back').click();
    await shipMove(54,110);await run(0);await page.locator('#walk-surface').focus();await page.keyboard.down('ArrowDown');await page.clock.runFor(200);await page.keyboard.up('ArrowDown');await page.locator('#walk-airlock').click();
    const caught=await walkToBuilding(5);assert(caught===true,'Ordinary city walking produces a natural chase without state import');
    await run(10000);assert((await state()).encounter==='dialogue','Standing in the natural chase reaches source catch and mandatory conversation');
    const caughtState=await reloadExact();last=caughtState;
    assert((await state()).dialogue==='65','Natural catch starts the source threat conversation');
    for(let i=0;i<4&&await page.locator('#dialogue-panel').count();i++)await page.locator('#dialogue-cancel').click();
    assert((await state()).encounter==='combat','Ordinary refusal enters the same source combat activation');
    for(let count=0;count<200&&(await state()).encounter==='combat';count++) {
      last=await exportGame();const native=await activation(last),enemy=native.combat.actors[1];
      if(!enemy)break;
      await run(1);await point(enemy[1]+3,enemy[0]-3);await page.locator('#walk-surface').focus();
      await page.keyboard.down(' ');await page.clock.runFor(50);await page.keyboard.up(' ');
    }
    last=await exportGame();const result=await activation(last);
    await page.screenshot({path:'output/playwright/remake/ordinary-ground-fight.png'});
    assert((await state()).encounter==='dialogue'&&(await state()).dialogue==='51','Legitimate laser shots win the natural encounter and reach post-fight dialogue');
    const won=await reloadExact();await page.locator('#dialogue-cancel').click();const reward=await reloadExact();
    assert(reward.state.combat.rewards.length===1&&reward.state.dialogue.cash>armed.state.dialogue.cash,'Ordinary victory commits exactly one source reward');
    assert(reward.state.ship.inventory.carried[0]===12&&reward.state.ship.inventory.stores[11]===0,'Victory preserves the legitimate laser owner');
    assert(reward.state.ship.inventory.carried[1]===75&&reward.state.ship.condition.health===caughtState.state.ship.condition.health,'Five actual enemy shots consume five shield charges and preserve personal health');
    assert(JSON.stringify(reward.state.start)===JSON.stringify(initial.state.start),'Ordinary combat preserves immutable character creation');
    assert(errors.length===0,'Ordinary ground journey has no browser errors');
    return {browser:browser.version(),fixture:'fresh seed12345; ordinary stores transfers, city walking, refusal and laser controls; no state imports',checks:checks.length,results:checks,errors,pose:await state(),activation:{phase:result.phase,combat:result.combat,context:result.context,outcome:result.outcome,receipts:result.receipts},states:Object.fromEntries(await Promise.all(Object.entries({initial,armed,caught:caughtState,won,reward}).map(async([name,value])=>[name,await summarize(value)])))};

  } catch(e){await page.screenshot({path:'output/playwright/remake/ordinary-ground-failure.png'});return {status:'fail',failures:[e.message],checks:checks.length,errors,pose:await state(),last:last?await summarize(last):null};}
  finally{await context.close()}
}
