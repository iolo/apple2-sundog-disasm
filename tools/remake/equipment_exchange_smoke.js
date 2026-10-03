// Read-only imports derive walking routes; game changes use ordinary UI actions.
async browserPage => {
  const browser=browserPage.context().browser(),checks=[],errors=[];
  const context=await browser.newContext({viewport:{width:1280,height:720}});
  const page=await context.newPage();
  page.on('pageerror',e=>errors.push(e.message));page.on('dialog',d=>d.accept());
  const assert=(ok,name)=>{if(!ok)throw Error(name);checks.push(name)};
  const ready=()=>page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
  const settled=()=>page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
  const state=()=>page.locator('#walk-screen').evaluate(el=>({...el.dataset}));
  const exportGame=async()=>{
    await page.locator('#walk-saves').click();await settled();
    const pending=page.waitForEvent('download');await page.locator('#export-checkpoint').click();
    const download=await pending;let text='';
    for await(const part of await download.createReadStream())text+=part;
    await settled();await page.locator('#checkpoint-back').click();return JSON.parse(text).state;
  };
  const walkTo=async bay=>{
    const from=await state();
    const route=await page.evaluate(async({from,bay})=>{
      const {canStand}=await import('/js/core/ship-walk.js');
      const {equipmentBayAt}=await import('/js/core/equipment.js');
      const geometry=await fetch('/data/ship-walk.json').then(r=>r.json());
      const start={x:Number(from.x),y:Number(from.y)},key=p=>`${p.x},${p.y}`;
      const queue=[start],previous=new Map([[key(start),null]]);let target;
      for(let i=0;i<queue.length;i++) {
        const p=queue[i];if(equipmentBayAt(p)===bay){target=p;break}
        for(const [dx,dy] of [[1,0],[-1,0],[0,1],[0,-1]]) {
          const q={x:p.x+dx,y:p.y+dy};
          if(canStand(geometry,q)&&!previous.has(key(q))){previous.set(key(q),p);queue.push(q)}
        }
      }
      if(!target)throw Error('Unreachable bay');
      const path=[];for(let p=target;p;p=previous.get(key(p)))path.unshift(p);
      return path.filter((p,i)=>i>0&&(i===path.length-1 || p.x-path[i-1].x!==path[i+1].x-p.x || p.y-path[i-1].y!==path[i+1].y-p.y));
    },{from,bay});
    if((await state()).paused==='true')await page.locator('#walk-pause').click();
    const box=await page.locator('#stage').boundingBox();
    for(const point of route) {
      const before=await state(),distance=Math.max(Math.abs(point.x-Number(before.x)),Math.abs(point.y-Number(before.y)));
      await page.mouse.move(box.x+(32+(point.x+3.25)*640/280)*box.width/640,box.y+(46+(point.y-2.75)*2)*box.height/480);
      await page.mouse.down();await page.clock.runFor(distance*60+150);await page.mouse.up();
      const after=await state();if(Number(after.x)!==point.x||Number(after.y)!==point.y)throw Error(`Route stopped at ${after.x},${after.y}, expected ${JSON.stringify(point)}`);
    }
  };
  const move=async(from,to)=>{
    await page.locator(from).click();await page.locator('#equipment-move').click();await page.locator(to).click();
  };
  const rating=()=>page.locator('.equipment-rating').innerText();
  let fixture=0;
  const importValue=async value=>{
    // Make a fixture file without accessing application state. The CLI sandbox
    // has no Node Buffer; download a Blob, then use the ordinary import control.
    const pending=page.waitForEvent('download');
    await page.evaluate(value=>{
      const url=URL.createObjectURL(new Blob([JSON.stringify(value)],{type:'application/json'}));
      const link=document.createElement('a');link.href=url;link.download='fixture.json';link.click();
      setTimeout(()=>URL.revokeObjectURL(url),1000);
    },value);
    const path=`output/playwright/remake/equipment-import-${++fixture}.json`;
    await (await pending).saveAs(path);
    await page.locator('#checkpoint-file').setInputFiles(path);await settled();
  };
  try {
    await page.clock.install();await page.goto('http://127.0.0.1:8000/');await ready();
    await page.locator('#create-character').click();await page.locator('#character-name').fill('Mechanic');
    await page.locator('#prepare-campaign').click();await page.locator('#campaign-seed').fill('12345');await page.locator('#start-campaign').click();
    const initial=await exportGame();await walkTo(0);await page.locator('#walk-equipment').click();
    assert((await rating()).includes('14 / 16'),'Seed12345 starts with two shunted warp units');
    assert(await page.getByText('Spares',{exact:true}).count()===0,'Requirements table is no longer presented as spare inventory');
    await page.locator('#equipment-slot-1-1').click();
    assert((await page.locator('#equipment-message').innerText()).includes('Flux modulator'),'Inspection identifies the standard socket requirement');
    await page.locator('#equipment-move').click();
    assert(await page.evaluate(()=>document.activeElement.id)==='equipment-cancel','Starting a move keeps keyboard focus on the enabled Cancel control');
    await page.keyboard.press('Escape');
    assert(await page.locator('#equipment-panel').isVisible()&&await page.locator('#equipment-cancel').isDisabled()&&await page.evaluate(()=>document.activeElement.id)==='equipment-move'&&(await rating()).includes('14 / 16'),'Escape cancels a pending move without removing its component');
    await move('#equipment-slot-1-1','#equipment-carried-0');
    assert((await rating()).includes('10 / 16')&&(await page.locator('#equipment-carried-0').getAttribute('aria-label')).includes('Flux modulator'),'Removing a component transfers it to a pocket and disables its unit');
    await move('#equipment-carried-0','#equipment-slot-0-0');
    assert((await page.locator('#equipment-message').innerText()).includes('Does not fit')&&(await rating()).includes('10 / 16'),'Wrong socket rejects both writes');
    await move('#equipment-carried-0','#equipment-slot-0-1');
    assert((await rating()).includes('11 / 16')&&(await page.locator('#equipment-carried-0').getAttribute('aria-label')).includes('Shunt'),'Compatible occupied socket swaps the replaced shunt into the pocket');
    await move('#equipment-carried-0','#equipment-slot-1-1');
    assert((await rating()).includes('14 / 16'),'Installing the recovered shunt restores partial unit output');
    await page.locator('#equipment-slot-0-0').click();await page.locator('#equipment-move').click();
    const before=await state();await page.clock.runFor(3000);
    assert((await state()).minutes===before.minutes,'A pending exchange pauses survival time');
    await page.locator('#equipment-next').click();await page.locator('#equipment-previous').click();
    assert(await page.locator('#equipment-cancel').isDisabled()&&(await rating()).includes('14 / 16'),'Changing engineering frame cancels selection without moving items');
    await page.locator('#equipment-slot-0-0').click();await page.locator('#equipment-move').click();
    for(const lang of ['en','ko']) {
      if(await page.locator('html').getAttribute('lang')!==lang)await page.locator('#equipment-language').click();
      for(const [width,height] of [[640,480],[1280,720],[1920,1080],[390,844]]) {
        await page.setViewportSize({width,height});await page.clock.runFor(100);
        const fit=await page.locator('#equipment-panel').evaluate(root=>{
          const box=document.querySelector('#stage').getBoundingClientRect();
          const elements=[...root.querySelectorAll('button,p,h2,h3,table,footer')];
          const inside=elements.every(el=>{const b=el.getBoundingClientRect();return b.left>=box.left-1&&b.right<=box.right+1&&b.top>=box.top-1&&b.bottom<=box.bottom+1&&el.scrollWidth<=el.clientWidth+1});
          return inside&&root.querySelector('.equipment-bottom').getBoundingClientRect().bottom<=root.querySelector('footer').getBoundingClientRect().top;
        });
        assert(fit,`${lang} exchange panel fits without footer overlap at ${width}x${height}`);
        assert(await page.locator('#equipment-cancel').isEnabled(),'Pending move survives locale and resize');
        await page.screenshot({path:`output/playwright/remake/equipment-exchange-${lang}-${width}.png`,animations:'disabled'});
      }
    }
    await page.locator('#equipment-language').click();await page.setViewportSize({width:1280,height:720});
    await page.locator('#equipment-cancel').click();
    await page.locator('#equipment-close').click();const changed=await exportGame();
    assert(JSON.stringify(changed.start)===JSON.stringify(initial.start),'Component exchanges never mutate the creation record');
    assert(changed.equipment[0].units[0].components[1]===28&&changed.equipment[0].units[1].components[1]===23,'Changed installed components are present in the exported active state');
    const items=value=>[...value.equipment.flatMap(g=>g.units.flatMap(u=>u.components)),...Object.values(value.ship.inventory).flat()].sort((a,b)=>a-b);
    assert(JSON.stringify(items(changed))===JSON.stringify(items(initial)),'Complete installed and inventory item multiset is conserved');
    await page.locator('#walk-saves').click();await settled();await page.locator('#save-checkpoint-0').click();await settled();
    await page.reload();await ready();await page.locator('#campaign-saves').click();await settled();await page.locator('#load-checkpoint-0').click();await settled();await page.locator('#checkpoint-back').click();
    await page.locator('#walk-equipment').click();
    assert((await page.locator('#equipment-slot-0-1').getAttribute('aria-label')).includes('Flux modulator')&&(await page.locator('#equipment-slot-1-1').getAttribute('aria-label')).includes('Shunt'),'Fresh-page load restores repaired and cannibalized units');
    await page.locator('#equipment-close').click();await page.locator('#walk-saves').click();await settled();
    const envelope={format:'sundog-campaign',version:2,scope:'landed-engineering-1',slot:0,savedAt:new Date().toISOString(),state:changed};
    delete envelope.state.engineering;delete envelope.state.resources;delete envelope.state.pod;delete envelope.state.travel;delete envelope.state.encounters;delete envelope.state.dialogue;delete envelope.state.economy; // Exercise a genuine version2 import.
    const corrupt=JSON.parse(JSON.stringify(envelope));corrupt.state.equipment[0].performance=16;await importValue(corrupt);
    assert((await page.locator('#checkpoint-message').innerText()).includes('Invalid'),'False imported performance is rejected');
    await page.locator('#checkpoint-back').click();const intact=await exportGame();
    assert(JSON.stringify(intact.equipment)===JSON.stringify(changed.equipment),'Rejected import leaves the live repaired equipment intact');
    const legacy=JSON.parse(JSON.stringify(envelope));legacy.version=1;delete legacy.state.engineering;delete legacy.state.resources;delete legacy.state.pod;delete legacy.state.economy;legacy.scope='landed-ship-1';delete legacy.state.equipment;
    await page.locator('#walk-saves').click();await settled();await importValue(legacy);
    assert((await page.locator('#checkpoint-message').innerText()).includes('imported'),'Version1 campaign imports through the normal save UI');
    await page.locator('#checkpoint-back').click();const upgraded=await exportGame();
    assert(JSON.stringify(upgraded.equipment)===JSON.stringify(initial.equipment)&&JSON.stringify(upgraded.ship)===JSON.stringify(legacy.state.ship),'Legacy migration reconstructs equipment while preserving ship progress');
    await page.locator('#walk-saves').click();await settled();await importValue(envelope);await page.locator('#checkpoint-back').click();
    const restored=await exportGame();assert(JSON.stringify(restored.equipment)===JSON.stringify(changed.equipment),'Version2 JSON restores changed equipment after a legacy import');
    assert(errors.length===0,`No browser errors: ${errors.join(', ')}`);
    return {browser:browser.version(),passed:checks.length,checks};
  } catch(error) {await page.screenshot({path:'output/playwright/remake/equipment-exchange-failure.png'});throw Error(`${error.message}; last check: ${checks.at(-1)}`)}
  finally {await context.close()}
}
