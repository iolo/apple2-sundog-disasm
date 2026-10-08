// Fresh character, natural city threat, source knockout/robbery and earlier-slot recovery.
// Geometry and exports are read-only; no campaign state is imported.
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
    const initial=await exportGame();
    await saves();await page.locator('#save-checkpoint-0').click();await settled();await page.locator('#checkpoint-back').click();
    await run(0);await page.locator('#walk-surface').focus();await page.keyboard.down('ArrowDown');await page.clock.runFor(200);await page.keyboard.up('ArrowDown');await page.locator('#walk-airlock').click();
    const encounters=[];
    for(let round=0;round<1&&(await state()).dead!=='true';round++) {
      let caught=false;
      for(let route=0;route<4&&!caught;route++)caught=(await walkToBuilding(route%2?3:5))===true;
      assert(caught,'Ordinary city walking reaches another natural chase');
      await run(10000);assert((await state()).encounter==='dialogue','Natural chase catches the unarmed fresh character');
      const threat=await exportGame();encounters.push({threat,context:(await activation(threat)).context});
      for(let i=0;i<4&&await page.locator('#dialogue-panel').count();i++) {
        if((await state()).dialogue==='33')await page.locator('#dialogue-reply-2').click();else await page.locator('#dialogue-cancel').click();
      }
      assert((await state()).encounter==='combat','Ordinary dialogue controls return to the natural encounter');
      await run(10000);last=await exportGame();encounters.at(-1).returned=last;
    }
    const lost=await exportGame();
    assert(lost.state.ship.condition.health<initial.state.ship.condition.health&&lost.state.ship.condition.health>0,'Actual enemy fire knocks out the unarmed fresh character');
    assert(lost.state.dialogue.cash===0&&lost.state.combat.ground===null&&lost.state.combat.defeat===null,'Source knockout commits robbery once and returns a living campaign');
    assert(JSON.stringify(lost.state.ship.inventory)===JSON.stringify(initial.state.ship.inventory),'Unarmed knockout preserves untouched stores and locker owners');
    assert(JSON.stringify(lost.state.economy.accounts)===JSON.stringify(initial.state.economy.accounts),'Robbery removes personal cash while preserving regional bank accounts');
    assert(JSON.stringify(lost.state.start)===JSON.stringify(initial.state.start),'Ordinary loss preserves immutable creation data');
    await saves();await page.locator('#save-checkpoint-1').click();await settled();await page.reload();await ready();await page.locator('#campaign-saves').click();await settled();await page.locator('#load-checkpoint-1').click();await settled();await page.locator('#checkpoint-back').click();
    assert(JSON.stringify((await exportGame()).state)===JSON.stringify(lost.state),'Fresh-page load retains exact ordinary injury and robbery');
    await page.clock.runFor(5000);assert(JSON.stringify((await exportGame()).state)===JSON.stringify(lost.state),'Paused restored loss freezes every campaign owner');
    await saves();await page.locator('#load-checkpoint-0').click();await settled();await page.locator('#checkpoint-back').click();
    assert(JSON.stringify((await exportGame()).state)===JSON.stringify(initial.state),'Explicit earlier-slot recovery restores the exact fresh character');
    await shipMove(54,86);assert((await state()).dead==='false'&&(await state()).scene==='ship','Earlier-slot recovery resumes ordinary ship movement');
    assert(errors.length===0,'No browser errors during ordinary ground loss and recovery');
    return {browser:browser.version(),checks:checks.length,results:checks,errors,pose:await state(),fixture:'fresh seed12345; ordinary city chase/catch, source dialogue, unarmed knockout, robbery and earlier-slot recovery; no state imports',states:{initial:await summarize(initial),encounters:await Promise.all(encounters.map(async e=>({context:e.context,threat:await summarize(e.threat),returned:await summarize(e.returned)}))),lost:await summarize(lost)}};

  } catch(e){await page.screenshot({path:'output/playwright/remake/ordinary-ground-failure.png'});return {status:'fail',failures:[e.message],checks:checks.length,errors,pose:await state(),last:last?await summarize(last):null};}
  finally{await context.close()}
}
