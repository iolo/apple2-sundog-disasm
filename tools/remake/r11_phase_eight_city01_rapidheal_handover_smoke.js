// Sell one surplus distorter from a failed ship unit at the home capital.
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
    (await page.locator('#dialogue-panel').count())?'#dialogue-saves':
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
        {canBoardParkedPod,findPodFootExit,parkedPodGeometry},{atCityBank,cityDoorAt},{roomAt,canLeaveRoom}]=await Promise.all([
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
        goal==='bankPark'?Math.abs(p.x-508)<=40&&Math.abs(p.y-559)<=40&&
          !!findPodFootExit(parkedPodGeometry(world.city(saved.ground.cityId,false),g,p,h),p):
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
      if(after.encounter){await settleEncounter();return route(goal,replans+1)}
      if(after.sleeping==='true'){await rest();return route(goal)}
      if(goal==='surface'&&after.scene==='surface'){assert(true,'City boundary enters the surface');return}
      if(Number(after.x)!==p.x||Number(after.y)!==p.y){
        if(replans>=12)throw Error(`Route ${goal} step ${i}/${points.length}: ${after.x},${after.y}, expected ${p.x},${p.y}; before ${JSON.stringify(before)}`);
        return route(goal,replans+1);
      }
    }
    assert(true,`${goal} reached through normal movement (${points.length} steps)`);
    const button=goal==='stores'?'#walk-inventory':['pod','bankPark'].includes(goal)?'#walk-pod':goal==='navigation'?'#walk-navigation':'#walk-airlock';assert(await page.locator(button).isEnabled(),`${goal} action is available`);await page.locator(button).click();
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
    await page.locator('#checkpoint-file').setInputFiles('output/playwright/remake/r11-phase-eight-city01-rapidheal-referral.json');
    await page.waitForFunction(()=>/imported/i.test(document.querySelector('#checkpoint-message')?.textContent||''));
    await page.locator('#checkpoint-back').click();
    const original=(await exported()).state;
    assert(original.colony.activePhase===8&&original.colony.receipts.length===51&&
      original.dialogue.workspace.item===10&&original.dialogue.flags[65]&&
      original.travel.scene==='room','The normal rapidheal referral is pending in the tavern');
    await roomWalk(30,60);
    let seated=false;
    for(const x of [90,118,80,53,16,43]){
      try {await roomWalk(x,60);await roomWalk(x,86);seated=true;break} catch {}
    }
    assert(seated,'A free tavern seat is reached for the referred buyer');
    for(let i=0;i<6&&await page.locator('#dialogue-panel').count()&&(await state()).dialogue!=='32';i++){
      if(await page.locator('#dialogue-continue').isEnabled())await page.locator('#dialogue-continue').click();
      else await page.locator('#dialogue-cancel').click();
    }
    if((await state()).paused==='true')await page.locator('#walk-pause').click();
    for(let i=0;i<300&&!await page.locator('#dialogue-panel').count();i++)await page.clock.runFor(250);
    assert((await state()).dialogue==='32','A referred buyer reaches the tavern table');
    const meeting=(await exported()).state;
    assert(meeting.dialogue.workspace.item===10&&meeting.dialogue.flags[65],
      `The spare-rapidheal referral survives tavern seating: ${JSON.stringify({workspace:meeting.dialogue.workspace,flags:meeting.dialogue.flags.slice(65,68),contact:meeting.ground?.roomTraffic?.tavern?.contact})}`);
    await page.locator('#dialogue-reply-1').click();
    assert((await state()).dialogue==='35','The buyer quotes the spare rapidheal');
    const quote=await page.locator('#dialogue-panel').innerText();
    await page.locator('#dialogue-reply-0').click();
    assert((await state()).dialogue==='37'&&await page.locator('[data-dialogue-sale="0"]').isEnabled(),
      'The carried spare rapidheal can be sold');
    await page.locator('[data-dialogue-sale="0"]').click();
    for(let i=0;i<6&&await page.locator('#dialogue-panel').count();i++)await page.locator('#dialogue-cancel').click();
    const sold=(await reload()).state;
    assert(sold.ship.inventory.carried[0]===0&&sold.dialogue.cash>0&&sold.colony.receipts.length===51,
      'Only the spare rapidheal leaves and the proceeds survive reload');
    const checkpoint=await exported('output/playwright/remake/r11-phase-eight-city01-rapidheal-sold.json');
    assert(JSON.stringify(checkpoint.state)===JSON.stringify(sold),'The rapidheal-sale checkpoint exports unchanged');
    assert(errors.length===0,'No uncaught errors during ordinary spare-item trade');
    return{browser:browser.version(),checks,errors,failures:[],journey:{quote,cash:sold.dialogue.cash,
      bank:sold.economy.accounts[0].balance,carried:sold.ship.inventory.carried}};
  }catch(error){await page.screenshot({path:'output/playwright/remake/r11-phase-eight-city01-rapidheal-handover-error.png'});return{browser:browser.version(),checks,errors,failures:[error.stack||error.message]}}
  finally{await context.close()}
}
