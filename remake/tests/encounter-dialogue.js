import { setupEncounterDialogue, setupCounterDialogue } from '../js/core/dialogue-state.js';
import { startEncounterDialogue, restoreEncounterDialogue, advanceEncounterDialogue,
  validateEncounterDialogueRecord } from '../js/core/encounter-dialogue.js';
import { dialoguePurchase } from '../js/core/dialogue-runner.js';
import { sourceRandom } from '../js/core/random.js';
import { createGroundCombat, resumeGroundCombat } from '../js/core/ground-combat.js';
import { dialogueMessage, dialoguePanel } from '../js/ui/dialogue.js';
import { translator } from '../js/ui/i18n.js';

export async function encounterDialogueTests(test,equal) {
  const [scripts,text,items,systems,ground]=await Promise.all(['dialogue','dialogue-text','items','dialogue-systems','ground-combat']
    .map(name=>fetch(`../data/${name}.json`).then(r=>r.json())));
  const content={scripts,text,items};
  const base={kind:16,system:systems.systems[0],attributes:[90,80,50,50,40],carried:[12,75,0,0],
    flags:Array(128).fill(false),workspace:{lastCity:0,mood:3,quantity:1,gate:0,item:0,actor:0},
    city:1,hour:4,surface:{x:10,y:6},cash:500,randomState:12345,sceneMiddle:3,bankBalance:20000,colonyProgress:0};
  const context=changes=>({...structuredClone(base),...changes});
  const setup=changes=>setupEncounterDialogue(context(changes));
  const fail=(run,message)=>{let actual;try{run()}catch(e){actual=e.message}equal(actual,message)};
  const after=(seed,count)=>{const r=sourceRandom(seed);for(let i=0;i<count;i++)r.next();return r.state};
  const step=(c,r,event)=>advanceEncounterDialogue(content,c,r,event);
  const complete=(c,inputs)=>{
    let result=startEncounterDialogue(content,c);
    for(const input of inputs)result=step(c,result.record,input);
    equal(result.record,null);equal(result.conversation.ended,true);return result.outcome;
  };

  await test('Encounter case table distinguishes attacker, visitor, post-fight and bank police entries',()=>{
    for(const [kind,entry] of [[15,51],[16,65],[18,49],[19,50],[22,33]]) {
      const s=setup({kind});equal(s.state.entry,entry);equal(s.state.kind,kind);
    }
    const s=setup({kind:19,sceneMiddle:1,city:0});equal(s.state.entry,64);
    equal([s.state.locals[100],s.state.locals[104],s.state.locals[106]],[0,20000,0]);
    equal(s.state.workspace.lastCity,0);equal(s.state.flags[80],false);
    equal(s.randomState,12345);
    fail(()=>setupCounterDialogue(context({kind:16})),'invalidDialogueSetup');
    fail(()=>setupCounterDialogue(context({kind:13,city:0})),'invalidDialogueSetup');
  });
  await test('Post-fight quote uses the rounded square root and signed Pascal multiplication',()=>{
    const literal=setup({kind:15});equal(literal.randomState,1580217);
    equal([literal.state.locals[40],literal.state.locals[100],literal.state.locals[106],literal.state.locals[108]],[112,112,112,'112 Cr']);
    for(let seed=1;seed<=128;seed++)for(const quantity of [1,2,3,4,5]) {
      const r=sourceRandom(seed),value=r.next()&3071;
      // Independent nearest-distance oracle: compare squared midpoints.
      let root=Math.floor(Math.sqrt(value));if(4*value>(2*root+1)**2)root++;
      const amount=base.system.local30*(60-root)*quantity*quantity;
      const s=setup({kind:15,randomState:seed,workspace:{...base.workspace,quantity}});
      equal([s.state.locals[40],s.state.locals[100],s.state.locals[106]],[amount,amount,amount]);
      equal(s.randomState,r.state);
    }
    const system={...base.system,local30:15};
    fail(()=>setup({kind:15,system,randomState:0,workspace:{...base.workspace,quantity:7}}),'unsupportedDialogueValuation');
    equal(setup({kind:15,system,randomState:0,workspace:{...base.workspace,quantity:9}}).state.locals[100],7364);
  });
  await test('Payment visitor draws eagerly for all colony and reward-flag combinations',()=>{
    for(const seed of [0,1,12345,0xffffffff])for(const colonyProgress of [0,1,2,255])for(const rewarded of [false,true]) {
      const flags=[...base.flags];flags[125]=rewarded;
      const before=JSON.stringify(flags),r=sourceRandom(seed),rare=r.next()%100<1;
      const reward=colonyProgress>1&&rare&&!rewarded,quote=reward ? 10000 : 5+r.next()%41;
      const s=setup({kind:18,flags,colonyProgress,randomState:seed});
      equal([s.state.entry,s.state.locals[100],s.state.locals[106]],[reward ? 224 : 49,quote,quote]);
      equal(s.state.flags[125],rewarded||reward);equal(s.randomState,r.state);equal(JSON.stringify(flags),before);
    }
  });
  await test('Unsupported reward target224 rejects before publishing source flags, cash or RNG',()=>{
    const c=context({kind:18,colonyProgress:2,randomState:0}),before=JSON.stringify(c);
    equal(setupEncounterDialogue(c).state.entry,224);
    fail(()=>startEncounterDialogue(content,c),'unsupportedDialogueState');equal(JSON.stringify(c),before);
  });
  await test('Ground police quotes every other scene from system valuation and owns bank money',()=>{
    for(let sceneMiddle=0;sceneMiddle<16;sceneMiddle++)if(sceneMiddle!==1) {
      const s=setup({kind:19,sceneMiddle,cash:1});equal(s.state.entry,50);
      equal([s.state.locals[100],s.state.locals[104],s.state.locals[106]],[3832,20000,3832]);
      equal(s.randomState,12345);
    }
    for(const change of [{kind:19,bankBalance:-1},{kind:19,bankBalance:undefined},{kind:18,colonyProgress:undefined},
      {sceneMiddle:16},{kind:17},{city:64}])fail(()=>setup(change),'invalidDialogueSetup');
  });
  await test('Encounter visitor restores referral mode, clears66 and preserves source quantity',()=>{
    const flags=[...base.flags];flags[66]=true;
    const s=setup({kind:22,flags,workspace:{...base.workspace,gate:1,item:235,quantity:3}});
    equal([s.state.locals[18],s.state.locals[20],s.state.locals[33],s.state.locals[41]],[true,true,4,235]);
    equal(s.state.flags[66],false);equal(s.state.workspace.quantity,3);equal(s.randomState,12345);equal(flags[66],true);
  });
  await test('Ground attacker Agree and Refuse retain distinct surrender and fight return flags',()=>{
    const c=context(),before=JSON.stringify(c);
    const surrender=complete(c,[{type:'reply',slot:0},{type:'cancel'}]);
    equal(surrender.flags.slice(48,52),[true,false,false,false]);equal(surrender.cash,500);equal(surrender.bankBalance,null);
    const fight=complete(c,[{type:'reply',slot:1},{type:'cancel'}]);
    equal(fight.flags.slice(48,52),[false,false,false,false]);equal(fight.cash,500);
    equal(JSON.stringify(c),before);
  });
  await test('Negotiated ground flee feeds the existing combat activation without regenerating actors',()=>{
    const arena={width:140,height:96,bounds:{left:0,right:139,top:0,bottom:95},glyphs:ground.glyphs,
      collisionRows:ground.glyphs[24],backgrounds:{ship:Array.from({length:96},()=>Array(20).fill(0))}};
    const condition=[255,100,200,0],initial=createGroundCombat({...base,kind:16,direction:0,condition},arena).state;
    const c=context({randomState:4});
    const outcome=complete(c,[{type:'reply',slot:1},{type:'reply',slot:0},{type:'cancel'}]);
    equal(outcome.flags[49],true);
    const resumed=resumeGroundCombat(initial,arena,{...outcome,condition});
    equal(resumed.state.mode,2);equal(resumed.state.flags[49],false);equal(resumed.draws,0);
    equal(resumed.state.actors,initial.actors);equal(resumed.state.history,initial.history);
    equal(resumed.state.randomState,outcome.randomState);
  });
  await test('Space Agree preserves the bank and personal cash, while a successful refusal returns49',()=>{
    const c=context({kind:19,sceneMiddle:1,city:0,workspace:{...base.workspace,mood:0,quantity:2}});
    const agreed=complete(c,[{type:'reply',slot:0},{type:'cancel'}]);
    equal(agreed.flags.slice(48,52),[false,false,false,true]);equal([agreed.cash,agreed.bankBalance],[500,20000]);
    const flee=complete({...c,randomState:1},[{type:'reply',slot:1},{type:'reply',slot:2},{type:'cancel'}]);
    equal(flee.flags[49],true);equal(flee.randomState,270844305);equal([flee.cash,flee.bankBalance],[500,20000]);
  });
  await test('Police fuel request debits only the supplied bank once and rejects insufficient balance atomically',()=>{
    const c=context({kind:19});
    const outcome=complete(c,[{type:'reply',slot:2},{type:'cancel'}]);
    equal([outcome.cash,outcome.bankBalance,outcome.flags[51]],[500,16168,true]);
    const poor={...c,bankBalance:1},r=startEncounterDialogue(content,poor),before=JSON.stringify({poor,r});
    fail(()=>step(poor,r.record,{type:'reply',slot:2}),'unsupportedDialogueMoney');equal(JSON.stringify({poor,r}),before);
  });
  await test('Payment visitor Yes debits personal cash and cannot alter a bank account',()=>{
    const c=context({kind:18}),r=startEncounterDialogue(content,c);
    equal(r.conversation.state.locals[100],37);equal(r.conversation.randomState!==after(12345,2),true);
    const outcome=complete(c,[{type:'reply',slot:1},{type:'cancel'}]);
    equal([outcome.cash,outcome.bankBalance,outcome.flags[49]],[463,null,true]);
  });
  await test('Post-fight search delivers the selected charged gift for zero credits into an empty slot',()=>{
    const c=context({kind:15,randomState:1}),root=startEncounterDialogue(content,c);
    const quote=root.conversation.state.locals[100];
    const found=step(c,root.record,{type:'reply',slot:2});
    equal(found.conversation.view.state,52);equal(dialoguePurchase(content,found.conversation).price,0);
    equal(found.conversation.panel.items,[237]);
    const before=JSON.stringify(found);fail(()=>step(c,found.record,{type:'purchase',slot:0}),'dialogueSlotOccupied');
    equal(JSON.stringify(found),before);
    const accepted=step(c,found.record,{type:'purchase',slot:2});equal(accepted.record,null);
    equal(accepted.outcome.carried,[12,75,237,0]);equal(accepted.outcome.cash,500+quote);
    equal(root.conversation.state.carried,c.carried);
  });
  await test('Open encounter replay derives exact views, pending balances and RNG after JSON round-trip',()=>{
    for(const c of [context(),context({kind:19,sceneMiddle:1,city:0}),context({kind:15,randomState:1}),context({kind:18})]) {
      const r=startEncounterDialogue(content,c),slot=c.kind===15 ? 2 : c.kind===18 ? 1 : 0;
      const next=step(c,r.record,{type:'reply',slot});equal(next.outcome,null);
      const restored=restoreEncounterDialogue(content,c,JSON.parse(JSON.stringify(next.record)),{randomState:next.conversation.randomState});
      equal(restored,next.conversation);equal(Object.keys(next.record),['seed','inputs']);
      fail(()=>restoreEncounterDialogue(content,c,next.record,{randomState:(next.conversation.randomState+1)>>>0}),'invalidEncounterDialogue');
    }
  });
  await test('Forged histories, terminal records, extra fields and bad inputs reject without changing owners',()=>{
    const c=context(),r=startEncounterDialogue(content,c),before=JSON.stringify({c,r});
    for(const record of [{...r.record,frame:{}},{seed:12345,inputs:[{type:'reply',slot:3}]},
      {seed:12345,inputs:[{type:'cancel',money:100}]},{seed:12345,inputs:Array(1025).fill({type:'cancel'})},
      {seed:12345,inputs:[{type:'offer',direction:'increase',step:2}]}])fail(()=>validateEncounterDialogueRecord(record),'invalidEncounterDialogue');
    fail(()=>restoreEncounterDialogue(content,c,{seed:1,inputs:[]}),'invalidEncounterDialogue');
    fail(()=>restoreEncounterDialogue(content,c,{seed:12345,inputs:[{type:'reply',slot:0},{type:'cancel'}]}),'invalidEncounterDialogue');
    fail(()=>step(c,r.record,{type:'reply',slot:2,flags:[]}),'invalidEncounterDialogue');
    equal(JSON.stringify({c,r}),before);
  });
  await test('Enemy banks93/96 and encounter panel present Korean text without changing source frames',async()=>{
    const [en,ko]=await Promise.all(['en','ko'].map(locale=>fetch(`../locales/${locale}.json`).then(r=>r.json())));
    const t=translator({en,ko},'ko'),frame=startEncounterDialogue(content,context()).conversation;
    for(const block of [93,96])for(const word of Object.keys(text.messages[block])) {
      frame.block=block;frame.view.word=Number(word);const before=JSON.stringify(frame);
      equal(/[가-힣]/.test(dialogueMessage(frame,t,'ko')),true);
      equal(/\{\w+\}/.test(dialogueMessage(frame,t,'ko')),false);equal(JSON.stringify(frame),before);
    }
    const assets={campaignContent:{dialogue:content},catalog:{itemImages:{}}};
    const panel=dialoguePanel({frame,assets,t,locale:'ko'});
    equal(panel.includes(t('encounterDialogueTitle')),true);equal(panel.includes(t('dialogueScope')),false);
  });
}
