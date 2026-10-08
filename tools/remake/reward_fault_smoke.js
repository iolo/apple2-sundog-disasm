// Declared isolated source-fault conversation and the real checkpoint panel.
// The fixture codec stores context/replay; this is not a live colony save.
async browserPage => {
  const browser=browserPage.context().browser(),checks=[],errors=[];
  const context=await browser.newContext({viewport:{width:640,height:480}}),page=await context.newPage();
  page.on('pageerror',e=>errors.push(e.message));page.on('requestfailed',r=>errors.push(r.url()));page.on('dialog',d=>d.accept());
  const assert=(ok,name)=>{if(!ok)throw Error(name);checks.push(name)};
  const ready=()=>page.waitForFunction(()=>document.documentElement.dataset.ready==='true');
  const settled=()=>page.waitForFunction(()=>document.querySelector('#checkpoint-back')?.disabled===false);
  const install=async()=>{
    const [{startEncounterDialogue,restoreEncounterDialogue,advanceEncounterDialogue},{dialoguePanel},{translator},{checkpointScreen},{openCheckpointStore}]=await Promise.all([
      import('/js/core/encounter-dialogue.js'),import('/js/ui/dialogue.js'),import('/js/ui/i18n.js'),import('/js/ui/checkpoints.js'),import('/js/core/checkpoints.js')]);
    const [scripts,text,items,systems,catalog,en,ko]=await Promise.all(['data/dialogue.json','data/dialogue-text.json','data/items.json','data/dialogue-systems.json','data/catalog.json','locales/en.json','locales/ko.json'].map(p=>fetch(p).then(r=>r.json())));
    const content={scripts,text,items},assets={campaignContent:{dialogue:content},catalog};
    const old=document.querySelector('#interface'),ui=old.cloneNode(false);old.replaceWith(ui);
    let locale='en',setup,result;
    const t=(key,values)=>translator({en,ko},locale)(key,values);
    const render=()=>{
      document.documentElement.lang=locale;
      ui.innerHTML=result.outcome?'<p id="encounter-return">Returned</p>':dialoguePanel({frame:result.conversation,assets,t,locale,encounter:true});
      (ui.querySelector('#dialogue-cancel')??ui.querySelector('#dialogue-saves'))?.focus();
    };
    const snapshot=()=>({context:structuredClone(setup),record:structuredClone(result.record),randomState:result.conversation.randomState});
    const validate=value=>{
      if(value?.format!=='declared-dialogue-replay'||value.version!==1||!Number.isInteger(value.slot)||value.slot<0||value.slot>3||
        !value.state||Object.keys(value.state).sort().join(',')!=='context,randomState,record')throw Error('invalidCheckpoint');
      restoreEncounterDialogue(content,value.state.context,value.state.record,{randomState:value.state.randomState});
      return structuredClone(value);
    };
    const codec={validate,make:(state,slot)=>validate({format:'declared-dialogue-replay',version:1,slot,savedAt:new Date().toISOString(),state}),
      parse:raw=>validate(JSON.parse(raw))};
    const checkpoints=checkpointScreen({stage:document.querySelector('#stage'),background:ui,codec,t,
      snapshot,restore:state=>{setup=state.context;result={record:state.record,conversation:restoreEncounterDialogue(content,setup,state.record,{randomState:state.randomState}),outcome:null}},
      close:render,language:()=>{locale=locale==='en'?'ko':'en';checkpoints.render()},
      openStore:()=>openCheckpointStore(codec,'sundog-declared-dialogue-fault'),describe:value=>`Declared dialogue fixture / seed${value.state.record.seed}`});
    ui.addEventListener('click',event=>{
      const button=event.target.closest('button');if(!button)return;
      if(button.id==='dialogue-language'){locale=locale==='en'?'ko':'en';render();return}
      if(button.id==='dialogue-saves'){void checkpoints.show();return}
      let input;
      if(button.dataset.dialogueReply!==undefined)input={type:'reply',slot:Number(button.dataset.dialogueReply)};
      else if(button.dataset.dialogue)input={type:button.dataset.dialogue};
      if(input){result=advanceEncounterDialogue(content,setup,result.record,input);render()}
    });
    ui.addEventListener('keydown',event=>{
      if(event.key==='Escape'&&result.conversation.fault)event.preventDefault();
      if(event.key==='Tab'){
        const buttons=[...ui.querySelectorAll('button:not(:disabled)')],i=buttons.indexOf(document.activeElement);
        event.preventDefault();buttons[(i+(event.shiftKey?-1:1)+buttons.length)%buttons.length]?.focus();
      }
    });
    window.rewardFaultFixture={open(fault=true,language='en') {
      locale=language;setup={kind:fault?18:16,system:systems.systems[0],attributes:[90,80,50,50,40],carried:[12,75,0,0],
        flags:Array(128).fill(false),workspace:{lastCity:0,mood:3,quantity:1,gate:0,item:0,actor:0},city:1,hour:4,surface:{x:10,y:6},
        cash:500,sceneMiddle:3,bankBalance:20000,colonyProgress:fault?2:0,randomState:fault?23:12345};
      result=startEncounterDialogue(content,setup);render();
    },get state(){return structuredClone(result)}};
    window.rewardFaultFixture.open(false);
  };
  const open=(fault=true,locale='en')=>page.evaluate(args=>window.rewardFaultFixture.open(...args),[fault,locale]);
  const state=()=>page.evaluate(()=>window.rewardFaultFixture.state);
  try {
    await page.clock.install();await page.goto('http://127.0.0.1:8000/');await ready();await page.evaluate(install);
    await page.locator('#dialogue-saves').click();await settled();await page.locator('#save-checkpoint-0').click();await settled();await page.locator('#checkpoint-back').click();
    for(const [width,height] of [[640,480],[390,844],[844,390],[1920,1080]]) {
      await page.setViewportSize({width,height});
      await page.waitForFunction(()=>Math.abs(document.querySelector('#stage').getBoundingClientRect().width-Math.min(innerWidth,innerHeight*4/3))<1);
      for(const locale of ['en','ko']) {
        await open(true,locale);
        const fits=await page.locator('#dialogue-panel').evaluate(el=>{const r=el.getBoundingClientRect();return r.left>=0&&r.top>=0&&r.right<=innerWidth+1&&r.bottom<=innerHeight+1&&el.scrollWidth<=el.clientWidth+1});
        assert(fits,`${locale} stopped conversation fits ${width}x${height}`);
        assert(!await page.locator('#dialogue-cancel,#dialogue-continue,[data-dialogue-reply],[data-dialogue-purchase]').count(),`${locale} fault offers no fabricated continuation or payout at ${width}x${height}`);
        const message=await page.locator('#dialogue-text').innerText();
        assert(locale==='ko'?/[가-힣]/.test(message):message.includes('earlier save'),`${locale} recovery instruction renders at ${width}x${height}`);
        assert(await page.locator('#dialogue-saves').isEnabled(),`${locale} fault retains checkpoint access at ${width}x${height}`);
        assert(await page.locator('#dialogue-exit').isEnabled()&&await page.locator('#dialogue-exit').getAttribute('data-walk')==='back',`${locale} fault retains the existing menu action without requiring a save at ${width}x${height}`);
      }
    }
    await page.setViewportSize({width:390,height:844});await open(true,'ko');const failed=await state();
    await page.screenshot({path:'output/playwright/remake/r10y-reward-fault-ko-390.png'});
    assert(failed.conversation.randomState===379799&&failed.conversation.state.locals[104]===500&&failed.outcome===null,'Fault owns exactly two native RNG draws, unchanged cash and no source return');
    const before=JSON.stringify(failed);await page.locator('#dialogue-language').click();await page.keyboard.press('Escape');await page.clock.runFor(10000);
    assert(JSON.stringify(await state())===before,'Locale, Escape and elapsed browser time preserve the stopped conversation');
    await page.keyboard.press('Tab');assert(await page.locator('#dialogue-language').evaluate(el=>el===document.activeElement),'Fault keyboard focus cycles through its available controls');
    await page.screenshot({path:'output/playwright/remake/r10y-reward-fault-390.png'});
    await page.locator('#dialogue-saves').click();await settled();await page.locator('#save-checkpoint-1').click();await settled();
    const pending=page.waitForEvent('download');await page.locator('#export-checkpoint').click();let exported='';for await(const chunk of await(await pending).createReadStream())exported+=chunk;
    const saved=JSON.parse(exported);assert(Object.keys(saved.state).sort().join(',')==='context,randomState,record'&&Object.keys(saved.state.record).join(',')==='seed,inputs','Fixture export stores replay inputs, not a trusted fault or interpreter frame');
    await page.reload();await ready();await page.evaluate(install);await page.locator('#dialogue-saves').click();await settled();await page.locator('#load-checkpoint-1').click();await settled();await page.locator('#checkpoint-back').click();
    assert(JSON.stringify(await state())===before,'Fresh-page IndexedDB load reconstructs the exact stopped source conversation');
    await page.locator('#dialogue-saves').click();await settled();await page.locator('#load-checkpoint-0').click();await settled();await page.locator('#checkpoint-back').click();
    assert(!(await state()).conversation.fault&&(await state()).conversation.view.state===65,'Explicit earlier checkpoint restores a playable source conversation');
    await page.locator('#dialogue-cancel').click();await page.locator('#dialogue-cancel').click();
    assert((await state()).record===null&&(await state()).outcome.cash===500,'Ordinary earlier-dialogue controls resume without an invented reward');
    assert(errors.length===0,'Stopped dialogue and checkpoint journey has no browser errors');
    return {browser:browser.version(),fixture:'isolated declared kind18/colony2/RNG23 source conversation; real panel and IndexedDB checkpoint UI with fixture codec; no ordinary colony reachability claimed',checks:checks.length,results:checks,errors,fault:failed.conversation.fault,randomState:failed.conversation.randomState,cash:failed.conversation.state.locals[104]};
  } finally {await context.close()}
}
