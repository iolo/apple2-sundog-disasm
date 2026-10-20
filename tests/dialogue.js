import { dialogueRecord, selectDialogueValue, dialogueTransition } from '../js/core/dialogue.js';
import { sourceRandom } from '../js/core/random.js';

export async function dialogueTests(test,equal) {
  const catalog=await fetch('../data/dialogue.json').then(r=>r.json());
  const base={mood:3,gate:false,randomIndex:0,reuseRandom:false};
  const fails=(run,message)=>{let error;try{run()}catch(e){error=e.message}equal(error,message)};
  const noRandom={next(){throw new Error('Unexpected RNG draw')}};
  await test('Dialogue catalogue addresses all 96 records across thirteen original banks',()=>{
    equal(catalog.version,1);equal(catalog.banks.length,13);
    let count=0;
    for(const [index,bank] of catalog.banks.entries()) {
      equal(bank.block,90+index);equal(bank.entries.length,16);
      for(const [entry,offset] of bank.entries.entries())if(offset) {
        const record=dialogueRecord(catalog,(index+1)*16+entry);
        equal(record.offset,offset);equal(record.block,bank.block);count++;
        equal(record.transitions.length,record.redirect ? 0 : 2);
        equal(record.delayUnits%2,0);
        equal(record.action!==null,record.mode>=8);
      }
    }
    equal(count,96);
    const record=dialogueRecord(catalog,80);record.selection.fallback=255;
    equal(dialogueRecord(catalog,80).selection.fallback,82);
  });
  await test('Dialogue lookup rejects builtins, absent entries and unexported banks',()=>{
    for(const state of [-1,0,7,15,90,223,224,255,NaN,80.1,'80'])
      fails(()=>dialogueRecord(catalog,state),'unsupportedDialogueState');
  });
  await test('Counter dispatch tests predicate100 and selects states82/83 without resolving actions',()=>{
    for(const [state,normal] of [[80,82],[81,83]]) {
      const record=dialogueRecord(catalog,state);
      equal(record.redirect,true);equal(record.action,{opcode:5,operands:[normal]});
      equal(selectDialogueValue(record.selection,base,noRandom,()=>true).value,normal);
      equal(selectDialogueValue(record.selection,base,noRandom,()=>false).value,normal);
      // Both branches in the stored selector currently point to the same state;
      // predicate100 must still run (it may have gameplay side effects).
      const calls=[];selectDialogueValue(record.selection,base,noRandom,p=>{calls.push(p);return true});
      equal(calls,[100]);
    }
  });
  await test('Mood selector21 uses its prefix as fallback text without testing it',()=>{
    for(const state of [82,83]) {
      const record=dialogueRecord(catalog,state);
      equal(record.selection,{kind:'mood',code:21,fallback:147,values:[150,160,163]});
      for(let mood=0;mood<=4;mood++) {
        equal(selectDialogueValue(record.selection,{...base,mood},noRandom).value,147);
        equal(selectDialogueValue(record.selection,{...base,mood,gate:true},noRandom).value,[163,160,150,150,150][mood]);
      }
    }
  });
  await test('All four mood selectors preserve their different thresholds and gate behavior',()=>{
    for(const gate of [false,true])for(const code of [20,21,22,23])for(let mood=0;mood<=4;mood++) {
      const selection={kind:'mood',code,fallback:99,values:code===23 ? [40,41,42,43] : [40,41,42]};
      const expected=code===21&&!gate ? 99 : (code===23 ? [43,42,41,40,40] : [42,41,40,40,40])[mood];
      const context={...base,gate,mood,reuseRandom:true,randomIndex:7};
      equal(selectDialogueValue(selection,context,noRandom),{value:expected,context});
    }
  });
  await test('Random selectors consume exactly one draw including singleton lists',()=>{
    for(let count=1;count<=10;count++)for(const seed of [0,1,12345,0xffffffff]) {
      const values=Array.from({length:count},(_,i)=>30+i),rng=sourceRandom(seed),reference=sourceRandom(seed);
      const index=reference.next()%count;
      equal(selectDialogueValue({kind:'random',values},base,rng),{value:values[index],context:{...base,randomIndex:index}});
      equal(rng.state,reference.state);equal(base.randomIndex,0);
    }
  });
  await test('Random reuse clears only its one-shot flag and preserves an out-of-range native result',()=>{
    const selection={kind:'random',values:[40,50,60]};
    for(let index=0;index<=9;index++) {
      const context={...base,reuseRandom:true,randomIndex:index};
      equal(selectDialogueValue(selection,context,noRandom),{
        value:[40,50,60][index]??3,context:{...context,reuseRandom:false}});
      equal(context.reuseRandom,true);
    }
  });
  await test('Conditional selectors stop predicate evaluation at the first match',()=>{
    const selection={kind:'conditional',choices:[{value:40,predicate:80},{value:41,predicate:81}],fallback:42};
    for(const [match,value,calls] of [[80,40,[80]],[81,41,[80,81]],[0,42,[80,81]]]) {
      const seen=[];
      equal(selectDialogueValue(selection,base,noRandom,p=>{seen.push(p);return p===match}).value,value);
      equal(seen,calls);
    }
    equal(selectDialogueValue({...selection,choices:[{value:43,predicate:0}]},base,noRandom).value,43);
    equal(selectDialogueValue({...selection,choices:[]},base,noRandom).value,42);
  });
  await test('Transition overrides trigger on false predicates and skip zero predicates',()=>{
    const transition=dialogueRecord(catalog,85).transitions[0];
    equal(transition,{state:0,unless:{predicate:2,state:86}});
    equal(dialogueTransition(transition,()=>true),0);
    equal(dialogueTransition(transition,()=>false),86);
    equal(dialogueTransition({state:87,unless:null}),87);
    equal(dialogueTransition({state:88,unless:{predicate:0,state:89}}),88);
  });
  await test('Every stored selection and transition resolves without changing its record or caller context',()=>{
    const snapshot=JSON.stringify(catalog);
    for(const bank of catalog.banks)for(const record of bank.records) {
      for(const gate of [false,true])for(let mood=0;mood<=4;mood++) {
        const context={...base,gate,mood},before={...context},rng=sourceRandom(12345);
        const {value}=selectDialogueValue(record.selection,context,rng,p=>!!(p&1));
        equal(Number.isInteger(value)&&value>=0&&value<=255,true);equal(context,before);
        for(const t of [...record.transitions,...record.replies.map(r=>r.transition)]) {
          equal(dialogueTransition(t,()=>true),t.state);
          equal(dialogueTransition(t,()=>false),t.unless?.state??t.state);
        }
      }
    }
    equal(JSON.stringify(catalog),snapshot);
  });
  await test('Missing predicate support and invalid dialogue context fail explicitly',()=>{
    const selection={kind:'conditional',choices:[{value:40,predicate:80}],fallback:42};
    fails(()=>selectDialogueValue(selection,base,noRandom),'missingDialoguePredicate');
    fails(()=>selectDialogueValue(selection,base,noRandom,()=>1),'invalidDialoguePredicate');
    for(const change of [{mood:-1},{mood:5},{gate:1},{randomIndex:-1},{randomIndex:10},{reuseRandom:0}])
      fails(()=>selectDialogueValue(selection,{...base,...change},noRandom),'invalidDialogueContext');
    fails(()=>selectDialogueValue({kind:'unknown'},base,noRandom),'unsupportedDialogueSelector');
  });
}
