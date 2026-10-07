// Read-only source geometry finds a route; all live changes use normal UI.
async browserPage => {
  const browser=browserPage.context().browser(),checks=[],errors=[];
  const context=await browser.newContext({viewport:{width:1280,height:720},hasTouch:true});
  const page=await context.newPage();
  page.on('pageerror',e=>errors.push(e.message));page.on('requestfailed',r=>errors.push(r.url()));page.on('dialog',d=>d.accept());
  const assert=(ok,name)=>{if(!ok)throw Error(name);checks.push(name)};
  const ready=()=>page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
  const settled=()=>page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
  const state=()=>page.locator('#walk-screen').evaluate(el=>({...el.dataset}));
  const saves=async()=>{await page.locator((await state()).scene==='bank' ? '#bank-saves' : '#walk-saves').click();await settled()};
  const exportGame=async()=>{
    await saves();const pending=page.waitForEvent('download');await page.locator('#export-checkpoint').click();
    let text='';for await(const part of await (await pending).createReadStream())text+=part;
    await settled();await page.locator('#checkpoint-back').click();return JSON.parse(text);
  };
  try {
    await page.clock.install({time:new Date('2026-10-01T00:00:00Z')});await page.clock.pauseAt(new Date('2026-10-01T00:00:01Z'));await page.goto('http://127.0.0.1:8000/');await ready();
    await page.locator('#create-character').click();await page.locator('#character-name').fill('Bank pilot');
    await page.locator('#prepare-campaign').click();await page.locator('#campaign-seed').fill('12345');await page.locator('#start-campaign').click();
    const initial=await exportGame();
    await page.locator('#walk-pause').click();await page.locator('#walk-surface').focus();
    await page.keyboard.down('ArrowDown');await page.clock.runFor(200);await page.keyboard.up('ArrowDown');
    await page.locator('#walk-airlock').click();
    const from=await state();
    assert(from.scene==='city'&&await page.locator('#bank-panel').count()===0,'Bank cannot be entered remotely from the ship airlock');
    const route=await page.evaluate(async from=>{
      const [{canStand},{createCityMaps},{createCityGeometry},{atCityBank}]=await Promise.all([
        import('/js/core/ship-walk.js'),import('/js/core/city-map.js'),import('/js/core/city-walk.js'),import('/js/core/city-doors.js')]);
      const [maps,navigation,economy,location,content]=await Promise.all(['maps','initial-navigation','initial-economy','initial-location','city-walk'].map(n=>fetch(`/data/${n}.json`).then(r=>r.json())));
      const map=createCityMaps(maps,navigation,economy)['city-01'];
      const g=createCityGeometry(map,content,{...location,position:location.shipPosition});
      const start=Number(from.y)*g.width+Number(from.x),previous=new Int32Array(g.width*g.height).fill(-1),queue=[start];
      previous[start]=start;let end;
      for(let i=0;i<queue.length;i++) {
        const k=queue[i],p={x:k%g.width,y:Math.floor(k/g.width)};
        if(atCityBank(map,p)){end=k;break}
        for(let dy=-1;dy<=1;dy++)for(let dx=-1;dx<=1;dx++) {
          if(!dx&&!dy)continue;
          const q={x:p.x+dx,y:p.y+dy},next=q.y*g.width+q.x;
          if(previous[next]===-1&&canStand(g,q)){previous[next]=k;queue.push(next)}
        }
      }
      if(end===undefined)throw Error('No reachable bank');
      const points=[];for(let k=end;k!==start;k=previous[k])points.unshift({x:k%g.width,y:Math.floor(k/g.width)});
      return points;
    },from);
    await page.locator('#walk-pause').click();
    const box=await page.locator('#stage').boundingBox();
    for(const point of route) {
      const before=await state(),cx=Number(before.cameraX),cy=Number(before.cameraY);
      await page.mouse.move(box.x+(145+(point.x+3.25-cx*28)*1.25)*box.width/640,box.y+(126+(point.y-2.75-cy*32)*1.25)*box.height/480);
      await page.mouse.down();await page.clock.runFor(100);await page.mouse.up();
      const after=await state();if(Number(after.x)!==point.x||Number(after.y)!==point.y)throw Error(`Route stopped at ${after.x},${after.y}, expected ${JSON.stringify(point)}`);
    }
    assert(await page.locator('#walk-airlock').innerText()==='Enter bank','Walking to the original bank door changes the contextual action');
    const outside=await exportGame();
    await page.locator('#walk-airlock').tap();
    assert((await state()).scene==='bank'&&await page.locator('#bank-panel').isVisible(),'Touch opens the bank at a reachable source door');
    const original=await exportGame(),cash=original.state.dialogue.cash,balance=original.state.economy.accounts[0].balance;
    const expectMoney=async(expectedCash,expectedBalance,name)=>{
      assert(await page.locator('#bank-cash').innerText()===String(expectedCash)&&await page.locator('#bank-balance').innerText()===String(expectedBalance),name);
    };
    const reopen=async()=>{
      await saves();await page.locator('#save-checkpoint-0').click();await settled();
      await page.reload();await ready();await page.locator('#campaign-saves').click();await settled();
      await page.locator('#load-checkpoint-0').click();await settled();await page.locator('#checkpoint-back').click();
    };
    const importGame=async value=>{
      await saves();const pending=page.waitForEvent('download');
      await page.evaluate(value=>{const a=document.createElement('a');a.href=URL.createObjectURL(new Blob([JSON.stringify(value)],{type:'application/json'}));a.download='banking-import.json';a.click();setTimeout(()=>URL.revokeObjectURL(a.href),1000)},value);
      await (await pending).saveAs('output/playwright/remake/banking-import.json');
      await page.locator('#checkpoint-file').setInputFiles('output/playwright/remake/banking-import.json');await settled();
      const message=await page.locator('#checkpoint-message').innerText();await page.locator('#checkpoint-back').click();return message;
    };
    assert(original.version===23&&original.scope==='regional-flight-1','Banking exports version23 with active accounts');
    assert(original.state.economy.accounts.length===12,'All twelve original system accounts initialize');
    await page.locator('#bank-deposit').click();
    assert(await page.locator('#bank-confirm').isDisabled(),'Zero-amount confirmation is disabled');
    await page.locator('#bank-step-100').click();
    await expectMoney(cash,balance,'Preparing a deposit leaves both balances unchanged');
    assert(JSON.stringify((await exportGame()).state)===JSON.stringify(original.state),'Saving a pending amount does not move credits');
    await reopen();
    assert(await page.locator('#bank-deposit').isVisible()&&await page.locator('#bank-confirm').count()===0,'Fresh load discards an uncommitted amount');
    await page.locator('#bank-deposit').click();await page.locator('#bank-step-all').click();
    await page.keyboard.press('Escape');
    assert((await state()).scene==='bank'&&await page.locator('#bank-deposit').isVisible(),'Escape cancels the draft without leaving the bank');
    assert(JSON.stringify((await exportGame()).state)===JSON.stringify(original.state),'Cancellation preserves all campaign fields');
    await page.locator('#bank-deposit').click();await page.locator('#bank-step-all').click();await page.locator('#bank-step-clear').click();
    assert(await page.locator('#bank-confirm').isDisabled(),'CLEAR resets the prepared amount');
    await page.locator('#bank-step-all').click();await page.locator('#bank-confirm').tap();
    await expectMoney(0,balance+cash,'Deposit ALL commits the exact remainder, including sub-hundred credits');
    assert(await page.locator('#bank-deposit').isDisabled(),'Empty carried cash disables deposit');
    await page.locator('#bank-withdraw').click();await page.locator('#bank-step-1000').click();await page.locator('#bank-confirm').click();
    await expectMoney(1000,balance+cash-1000,'Withdrawal moves 1000 credits from the local account to cash');
    const funded=await exportGame();assert(funded.state.dialogue.cash>funded.state.start.credits,'Active cash can exceed creation cash after a funded withdrawal');
    await reopen();assert(JSON.stringify((await exportGame()).state)===JSON.stringify(funded.state),'Fresh-page reload retains withdrawn cash and reduced account exactly');
    await page.locator('#bank-transfer').click();
    assert(await page.locator('#bank-destination option').count()===11&&await page.locator('#bank-destination option[value="system-01"]').count()===0,'Transfer offers all eleven other systems');
    await page.locator('#bank-destination').selectOption('system-12');await page.locator('#bank-step-1000').click();
    await page.locator('#bank-saves').focus();await page.keyboard.press('Tab');
    assert(await page.evaluate(()=>document.activeElement.id)==='bank-language','Transfer form traps forward focus');
    await page.keyboard.press('Tab');assert(await page.evaluate(()=>document.activeElement.id)==='bank-destination','Transfer destination participates in keyboard focus');
    for(const lang of ['en','ko']) {
      if(await page.locator('html').getAttribute('lang')!==lang)await page.locator('#bank-language').click();
      for(const [width,height] of [[640,480],[1280,720],[1920,1080],[390,844],[844,390]]) {
        await page.setViewportSize({width,height});await page.clock.runFor(100);
        await page.waitForFunction(()=>Math.abs(document.querySelector('#stage').getBoundingClientRect().width-Math.min(innerWidth,innerHeight*4/3))<1);
        const fits=await page.locator('#bank-panel').evaluate(el=>{
          const stage=document.querySelector('#stage').getBoundingClientRect(),b=el.getBoundingClientRect();
          return b.left>=stage.left-1&&b.right<=stage.right+1&&b.top>=stage.top-1&&b.bottom<=stage.bottom+1&&el.scrollHeight<=el.clientHeight+1&&[...el.querySelectorAll('button,h2,p,dt,dd,select')].every(e=>e.scrollWidth<=e.clientWidth+1);
        });
        if(!fits){
          await page.screenshot({path:'output/playwright/remake/bank-transfer-overflow.png'});
          const detail=await page.locator('#bank-panel').evaluate(el=>({box:el.getBoundingClientRect().toJSON(),scroll:el.scrollHeight,client:el.clientHeight,overflow:[...el.querySelectorAll('*')].filter(e=>e.scrollWidth>e.clientWidth+1).map(e=>({id:e.id,tag:e.tagName,scroll:e.scrollWidth,client:e.clientWidth}))}));
          throw Error(`${lang} transfer form ${width}x${height}: ${JSON.stringify(detail)}`);
        }
        assert(fits,`${lang} transfer form fits ${width}x${height}`);
      }
      await page.evaluate(()=>document.fonts.ready);await page.clock.runFor(100);
      await page.screenshot({path:`output/playwright/remake/bank-transfer-${lang}.png`,animations:'disabled'});
    }
    if(await page.locator('html').getAttribute('lang')!=='en')await page.locator('#bank-language').click();
    assert(await page.locator('#bank-destination').inputValue()==='system-12'&&(await page.locator('#bank-amount').innerText()).includes('1000 Cr'),'Language and viewport changes preserve the pending transfer');
    await page.locator('#bank-confirm').click();
    const transferred=await exportGame();
    assert(transferred.state.economy.accounts[11].balance===original.state.economy.accounts[11].balance+1000,'Transfer credits the chosen system account');
    await expectMoney(1000,balance+cash-2000,'Transfer debits only the local account without a fee');
    for(let i=1;i<11;i++)if(transferred.state.economy.accounts[i].balance!==original.state.economy.accounts[i].balance)throw Error('Unrelated account changed');
    assert(JSON.stringify(transferred.state.encounters)===JSON.stringify(original.state.encounters)&&JSON.stringify(transferred.state.ship)===JSON.stringify(original.state.ship)&&JSON.stringify(transferred.state.start)===JSON.stringify(original.state.start)&&JSON.stringify(transferred.state.equipment)===JSON.stringify(original.state.equipment),'Bank actions preserve RNG, time, inventory, equipment and creation');
    const wealth=s=>s.dialogue.cash+s.economy.accounts.reduce((sum,a)=>sum+a.balance,0);
    assert(wealth(transferred.state)===wealth(original.state),'The deposit/withdraw/transfer loop conserves every credit');
    await reopen();assert(JSON.stringify((await exportGame()).state)===JSON.stringify(transferred.state),'Fresh-page reload preserves all system balances');
    const forged=structuredClone(transferred);forged.state.economy.accounts[11].balance++;
    assert((await importGame(forged)).includes('Invalid'),'Import rejects invented wealth');
    assert(JSON.stringify((await exportGame()).state)===JSON.stringify(transferred.state),'Rejected import leaves the active transaction result intact');
    const legacy=structuredClone(original);legacy.version=11;delete legacy.state.regional;delete legacy.state.flight;delete legacy.state.ground;delete legacy.state.pod?.occupied;delete legacy.state.machinery;delete legacy.state.engineering;delete legacy.state.resources;delete legacy.state.pod;legacy.scope='landed-services-1';delete legacy.state.economy;
    assert((await importGame(legacy)).includes('imported'),'Version11 bank visit migrates through normal import UI');
    const migratedBank=structuredClone(original.state);migratedBank.ground.camera=await page.evaluate(async p=>(await import('/js/core/ground-camera.js')).groundCameraAt(p),migratedBank.travel.cityPosition);
    assert(JSON.stringify((await exportGame()).state)===JSON.stringify(migratedBank),'Legacy migration seeds original accounts without changing prior cash or other state');
    assert((await importGame(transferred)).includes('imported'),'Valid version23 transfer progress imports');
    await page.locator('#bank-withdraw').click();await page.locator('#bank-step-all').click();await page.locator('#bank-confirm').click();
    assert(await page.locator('#bank-withdraw').isDisabled()&&await page.locator('#bank-transfer').isDisabled(),'Zero account disables withdrawal and transfer');
    const emptied=await exportGame();
    await page.locator('#bank-leave').click();await page.locator('#walk-airlock').click();
    assert(JSON.stringify((await exportGame()).state)===JSON.stringify(emptied.state),'Street exit and reentry preserve emptied accounts and carried cash');
    assert(errors.length===0,'No browser exceptions or failed requests');
    return {browser:browser.version(),checks,errors,initialCash:cash,initialBalance:balance};
  } finally {await context.close()}
}
