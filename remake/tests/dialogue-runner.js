import { setupCounterDialogue, evaluateDialoguePredicate } from '../js/core/dialogue-state.js';
import { reduceDialogueEffect } from '../js/core/dialogue-effects.js';
import { startCounterConversation, enterDialogueState, advanceDialogue } from '../js/core/dialogue-runner.js';
import { renderDialogueMessage } from '../js/core/dialogue-text.js';
import { sourceRandom } from '../js/core/random.js';
import { dialogueMessage } from '../js/ui/dialogue.js';
import { translator } from '../js/ui/i18n.js';

export async function dialogueRunnerTests(test,equal) {
  const [scripts,text,items,systems]=await Promise.all(['dialogue','dialogue-text','items','dialogue-systems']
    .map(name=>fetch(`../data/${name}.json`).then(r=>r.json())));
  const content={scripts,text,items};
  const input={kind:13,system:systems.systems[0],attributes:[30,40,50,30,81],carried:[12,141,139,140],
    flags:Array(128).fill(false),workspace:{lastCity:0,mood:3,quantity:1,gate:0},city:1,hour:4,
    surface:{x:10,y:6},cash:500,randomState:12345};
  const start=(changes={})=>startCounterConversation(content,setupCounterDialogue({...input,...changes}));
  const effect=(frame,operation)=>reduceDialogueEffect(frame,operation,items);
  const control=(frame,code)=>effect(frame,{type:'controls',code}).frame;
  const action=(frame,opcode,operands=[])=>effect(frame,{type:'action',action:{opcode,operands}}).frame;
  const builtin=(frame,code,step)=>effect(frame,{type:'builtin',code,step});
  const advance=(frame,input)=>advanceDialogue(content,frame,input);
  const fail=(fn,message)=>{let actual;try{fn()}catch(e){actual=e.message}equal(actual,message)};
  const after=(seed,n)=>{const r=sourceRandom(seed);for(let i=0;i<n;i++)r.next();return r.state};

  await test('Every counter and information message has a Korean presentation without changing source text or RNG',async()=>{
    const [en,ko]=await Promise.all(['en','ko'].map(locale=>fetch(`../locales/${locale}.json`).then(r=>r.json())));
    const t=translator({en,ko},'ko'),frame=start();frame.state.locals[41]=23;frame.state.locals[106]=420;
    for(const block of [94,98,99])for(const word of Object.keys(text.messages[block])) {
      frame.block=block;frame.view.word=Number(word);const before=JSON.stringify(frame);
      const message=dialogueMessage(frame,t,'ko');
      equal(/[가-힣]/.test(message),true);equal(/\{\w+\}/.test(message),false);
      equal(dialogueMessage(frame,t,'en'),frame.view.text);equal(JSON.stringify(frame),before);
    }
  });

  await test('Both real counter roots execute redirects, greeting text and item-list actions',()=>{
    for(const kind of [13,14]) {
      const setup=setupCounterDialogue({...input,kind}),before=JSON.stringify(setup);
      const frame=startCounterConversation(content,setup),v=frame.state.locals;
      equal(frame.view.state,kind===13 ? 82 : 83);equal(frame.view.word,147);
      equal(frame.view.text,'What can I get you, fella? ');equal(frame.randomState,2536397490);
      equal(frame.view.replies,[{slot:2,caption:10,text:'Information',target:kind===13 ? 144 : 160}]);
      equal(frame.panel,{kind:'items',items:kind===13 ? [10,11] : [23,24,25,26,27,28,29,30,31]});
      equal(v[53],[kind===13 ? 82 : 83,0,0]);equal([v[100],v[104],v[19]],[0,500,true]);
      equal(JSON.stringify(setup),before);
    }
  });
  await test('Counter item quote, acceptance and continuation retain exact text and RNG',()=>{
    const original=start(),before=JSON.stringify(original);
    const quote=advance(original,{type:'item',item:10});
    equal([quote.view.state,quote.view.word,quote.view.text,quote.randomState],
      [84,247,'That will be 420 Cr for a rapidheal. ',2536331557]);
    equal(quote.view.replies.map(r=>[r.slot,r.text,r.target]),[[1,'Buy',85],[2,'Forget it',9]]);
    const accepted=advance(quote,{type:'reply',slot:1});
    equal([accepted.view.state,accepted.view.text,accepted.randomState],[85,'Here you are, captain. ',615289458]);
    equal(accepted.panel,{kind:'items',items:[10]});equal(accepted.view.replies,[]);
    equal(accepted.state.locals[95].slice(0,3),[9,-1,-1]);
    equal(accepted.state.locals[104],500);equal(accepted.state.carried,input.carried);
    fail(()=>advance(accepted,{type:'item',item:10}),'invalidDialogueItem'); // Transfer is a separate, unported operation.
    const back=advance(quote,{type:'reply',slot:2});equal(back.view.state,82);equal(back.state.locals[41],0);
    equal(JSON.stringify(original),before);
  });
  await test('Information bank98 retains dictionary, continuation9 returns to the counter',()=>{
    const original=start(),info=advance(original,{type:'reply',slot:2});
    equal([info.block,info.view.state,info.view.text],[98,144,'What can I tell you about? ']);
    equal(info.dictionary,original.dictionary);equal(info.randomState,original.randomState);
    const detail=advance(info,{type:'item',item:10});equal(detail.view.state,146);
    const more=advance(detail,{type:'timeout'});equal(more.view.state,147);
    equal(advance(more,{type:'reply',slot:2}).view.state,82);
    const equipment=start({kind:14}),other=advance(equipment,{type:'reply',slot:2});
    equal([other.block,other.view.state],[99,160]);equal(other.dictionary===equipment.dictionary,false);
    equal(advance(other,{type:'item',item:23}).view.state,161);
  });
  await test('Counter timeout and close resolve source flags and return workspace without campaign writes',()=>{
    const original=start(),waiting=advance(original,{type:'timeout'});
    equal([waiting.view.state,waiting.view.text,waiting.randomState],[87,'May I help you or not? ',2536331557]);
    equal(waiting.state.locals[33],2);equal(waiting.state.locals[20],true);
    const closed=advance(waiting,{type:'reply',slot:2});
    equal([closed.ended,closed.state.flags[49],closed.state.workspace.mood,closed.state.workspace.gate],[true,true,2,1]);
    equal(closed.state.locals[104],500);equal(closed.state.carried,input.carried);
    fail(()=>advance(closed,{type:'cancel'}),'dialogueAlreadyEnded');
    equal(advance(original,{type:'cancel'}).randomState,original.randomState);
  });
  await test('All packed control bytes preserve caller state and apply independent mood and money fields',()=>{
    const frame=start();frame.state.locals[100]=20;frame.state.locals[102]=7;
    const before=JSON.stringify(frame);
    for(let code=0;code<256;code++) {
      const next=control(frame,code),v=next.state.locals,mood=(code>>2)&3;
      equal(v[33],[3,4,2,4][mood]);equal(v[20],!!(code&1));equal(v[15],!!(code&2));
      equal(v[104],[500,480,520,500][code>>6]);equal(v[100],code>=192 ? 7 : 20);
      if(code&32){equal(v[41]>0,true);equal(v[108],`${v[106]} Cr`)}
      else equal(v[41],0);
    }
    equal(JSON.stringify(frame),before);
    const sticky=control(control(frame,3),0);equal([sticky.state.locals[20],sticky.state.locals[15]],[true,true]);
    for(const [mood,code,want] of [[0,8,0],[4,4,4]]) {
      frame.state.locals[33]=mood;equal(control(frame,code).state.locals[33],want);
    }
  });
  await test('Item reset precedes selection; a repeating rejected RNG fails atomically',()=>{
    const frame=start();frame.randomState=0;frame.state.locals[41]=10;frame.state.locals[18]=true;
    const next=control(frame,48);equal([next.state.locals[41],next.state.locals[18]],[12,false]);
    frame.state.flags[92]=true;const before=JSON.stringify(frame);
    fail(()=>control(frame,48),'dialogueItemUnavailable');equal(JSON.stringify(frame),before);
  });
  await test('Higher-kind item valuation eagerly runs both predicates and reverses selling direction',()=>{
    for(const selling of [false,true]) {
      const frame=start();frame.state.kind=17;frame.state.locals[41]=12;frame.state.locals[18]=selling;
      // With intelligence40, predicate30's first threshold is80; choose a seed that passes it.
      frame.randomState=0;
      const next=control(frame,32),v=next.state.locals;
      equal([v[4],v[5],v[36]],selling ? [24,20,-1] : [20,24,1]);
      equal(next.randomState,after(0,3));equal(v[41],12);
      // Nonzero seed lets the draw count distinguish eager evaluation from skipped calls.
      frame.randomState=12345;
      const rng=sourceRandom(frame.randomState);rng.next();
      const first=evaluateDialoguePredicate(30,frame.state,rng.state,items);
      const second=evaluateDialoguePredicate(166,first.state,first.randomState,items);
      equal(control(frame,32).randomState,second.randomState);
    }
    const free=start();free.state.kind=15;free.state.locals[41]=12;free.state.locals[100]=90;
    const next=control(free,32);equal([next.state.locals[100],next.state.locals[106],next.state.locals[108]],[0,0,'0 Cr']);
  });
  await test('Actions create charged-item displays, inventory choices and continuation slots',()=>{
    const frame=start();frame.state.locals[41]=11;
    const shown=action(frame,1,[9]);equal(shown.state.locals[41],235);equal(shown.panel.items,[235]);
    frame.state.locals[41]=0;frame.state.locals[35]=45;
    equal(action(frame,1,[9]).panel.items,[237]);
    const inventory=action(frame,2,[9,10]);
    equal(inventory.panel,{kind:'inventory',items:input.carried});
    equal([inventory.state.locals[18],inventory.state.locals[19]],[true,true]);
    inventory.state.locals[41]=12;
    equal(action(inventory,1,[9]).panel.items,Array(15).fill(0));
    const list=action(frame,3,[9,10,23,2]);equal(list.panel.items,[23,24,25,26,27,28,29,30,31]);
    let slots=frame;for(let opcode=5;opcode<=7;opcode++)slots=action(slots,opcode,[80+opcode]);
    equal(slots.state.locals[53],[85,86,87]);equal(action(frame,4),frame);
  });
  await test('Offer actions replace two reply buttons, consume one draw and preserve the third',()=>{
    const frame=start();frame.view.replies=[{slot:0},{slot:1},{slot:2}];
    const rng=sourceRandom(frame.randomState),amount=8*(5+rng.next()%63),offering=action(frame,0);
    equal(offering.panel,{kind:'offer'});equal(offering.offerControls,true);
    equal(offering.view.replies,[{slot:2}]);equal(offering.state.locals[95].slice(0,2),[1,2]);
    equal([offering.state.locals[106],offering.state.locals[17],offering.randomState],[amount,true,rng.state]);
    const reset=enterDialogueState(content,offering,82);equal(reset.offerControls,false);
    fail(()=>advance(reset,{type:'offer',direction:'increase',step:1}),'invalidDialogueOffer');
  });
  await test('Offer builtins enforce cash limits, decimal steps and source baseline-copy direction',()=>{
    const frame=action(start(),0);frame.state.locals[100]=490;frame.state.locals[102]=7;
    const delay=frame.state.locals[43];
    equal(advance(frame,{type:'offer',direction:'increase',step:10}).state.locals[100],500);
    equal(advance(frame,{type:'offer',direction:'increase',step:100}).state.locals[100],490);
    equal(advance(frame,{type:'offer',direction:'decrease',step:1000}).state.locals[100],7);
    equal(advance(frame,{type:'offer',direction:'decrease',step:100}).state.locals[100],390);
    for(const step of [1,10,100,1000,10000])equal(builtin(frame,1,step).frame.state.locals[43],delay+1);
    fail(()=>advance(frame,{type:'offer',direction:'increase',step:2}),'missingDialogueOfferStep');
  });
  await test('Exit builtins and continuation slots preserve their distinct source return effects',()=>{
    const frame=start();frame.state.locals[41]=12;frame.state.locals[18]=true;frame.state.locals[53]=[82,83,84];
    for(const code of [0,3,4,5,6,7,8])equal(builtin(frame,code).frame.ended,true);
    const selected=builtin(frame,3).frame;
    equal([selected.state.flags[65],selected.state.flags[66],selected.state.workspace.item],[true,true,12]);
    equal(builtin(frame,5).frame.state.flags[51],true);equal(builtin(frame,6).frame.state.flags[51],false);
    equal(builtin(frame,7).frame.state.flags.slice(48,51),[false,false,false]);
    equal(builtin(frame,8).frame.state.flags[48],true);
    for(let code=9;code<=11;code++)equal(builtin(frame,code).redirect,82+code-9);
    for(let code=12;code<=15;code++)equal(builtin(frame,code).frame,frame);
    frame.state.kind=17;frame.state.locals[18]=false;frame.state.locals[20]=true;frame.state.locals[102]=600;
    const rng=sourceRandom(frame.randomState),flag=!!(rng.next()&1),closed=enterDialogueState(content,frame,4);
    equal([closed.state.flags[92],closed.randomState],[flag,rng.state]);
    equal([closed.state.locals[104],closed.state.workspace.item,closed.state.workspace.gate],[600,0,1]);
    equal([closed.state.flags[65],closed.state.flags[66]],[false,false]);
  });
  await test('Rendering draws precede transition predicates; actions overwrite reply targets last',()=>{
    const frame=start(),custom=structuredClone(content),bank=custom.scripts.banks[4];
    const record=bank.records.find(r=>r.offset===bank.entries[2]);
    record.controls=0;record.selection={kind:'literal',value:147};record.action={opcode:3,operands:[89,84,10,0]};
    record.transitions=[{state:0,unless:{predicate:150,state:9}},{state:0,unless:{predicate:150,state:9}}];
    record.replies=[0,1,2].map(caption=>({caption,transition:{state:9,unless:null}}));
    const rendered=renderDialogueMessage(text,frame.dictionary,94,147,frame.randomState,
      {mood:3,mode18:false,workspace11:1,strings:{108:'',124:''}});
    const first=evaluateDialoguePredicate(150,frame.state,rendered.randomState,items);
    const second=evaluateDialoguePredicate(150,first.state,first.randomState,items);
    const result=enterDialogueState(custom,frame,82);
    equal(result.randomState,second.randomState);equal(result.view.text,rendered.text);
    equal(result.state.locals[95].slice(3),[first.value ? 0 : 9,second.value ? 0 : 9]);
    equal(result.view.replies.map(r=>r.target),[89,84,9]);
  });
  await test('Redirect cycles, invalid inputs and malformed actions publish no partial frame',()=>{
    const frame=start(),before=JSON.stringify(frame),custom=structuredClone(content);
    const record=custom.scripts.banks[4].records.find(r=>r.offset===custom.scripts.banks[4].entries[2]);
    record.redirect=true;record.selection={kind:'literal',value:82};record.controls=4;
    fail(()=>enterDialogueState(custom,frame,82),'dialogueRedirectLimit');
    for(const input of [{type:'reply',slot:0},{type:'item',item:12},{type:'item',item:0},{type:'offer',direction:'increase',step:1},{type:'bogus'}]) {
      const errors={reply:'invalidDialogueReply',item:'invalidDialogueItem',offer:'invalidDialogueOffer',bogus:'invalidDialogueInput'};
      fail(()=>advance(frame,input),errors[input.type]);
    }
    for(const [opcode,operands] of [[8,[]],[1,[]],[3,[9,10,23,9]],[5,[256]]])
      fail(()=>action(frame,opcode,operands),opcode===3 ? 'unsupportedDialogueItemList' : 'invalidDialogueAction');
    fail(()=>control(frame,256),'invalidDialogueControls');
    fail(()=>enterDialogueState(content,frame,224),'unsupportedDialogueState');
    equal(JSON.stringify(frame),before);
    frame.state.locals[100]=501;const snapshot=JSON.stringify(frame);
    fail(()=>control(frame,64),'unsupportedDialogueMoney');equal(JSON.stringify(frame),snapshot);
  });
}
