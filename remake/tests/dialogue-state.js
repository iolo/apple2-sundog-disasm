import { setupCounterDialogue, evaluateDialoguePredicate } from '../js/core/dialogue-state.js';
import { dialogueRecord, selectDialogueValue } from '../js/core/dialogue.js';
import { sourceRandom } from '../js/core/random.js';

export async function dialogueStateTests(test,equal) {
  const [systems,catalog,items]=await Promise.all(['dialogue-systems','dialogue','items'].map(name=>fetch(`../data/${name}.json`).then(r=>r.json())));
  const input={kind:13,system:systems.systems[0],attributes:[30,40,50,30,81],carried:[12,141,139,140],
    flags:Array(128).fill(false),workspace:{lastCity:0,mood:3,quantity:1,gate:0},city:1,hour:4,
    surface:{x:10,y:6},cash:500,randomState:12345};
  const setup=changes=>setupCounterDialogue({...input,...changes});
  const base=()=>setup().state;
  const run=(code,state=base(),seed=12345)=>evaluateDialoguePredicate(code,state,seed,items);
  const fail=(fn,message)=>{let actual;try{fn()}catch(e){actual=e.message}equal(actual,message)};
  const rolls=seed=>{const r=sourceRandom(seed);return Array.from({length:3},()=>r.next()%100)};
  const pick=predicate=>{for(let seed=1;seed<100000;seed++)if(predicate(rolls(seed)))return seed;throw Error('No test seed')};
  const after=(seed,n)=>{const r=sourceRandom(seed);for(let i=0;i<n;i++)r.next();return r.state};

  await test('Counter setup initializes both entries without a random draw',()=>{
    for(const kind of [13,14])for(const randomState of [0,12345,0xffffffff]) {
      const result=setup({kind,randomState}),v=result.state.locals;
      equal(result.randomState,randomState);equal(result.state.entry,kind===13 ? 80 : 81);
      equal([v[4],v[5],v[6],v[7]],[33,30,2,3]); // Exact item12, masked13/11, damaged12 ignored.
      equal([v[14],v[15],v[18],v[20],v[33]],[0,false,false,false,3]);
      equal([v[100],v[102],v[104],v[106]],[0,0,500,0]);
      equal([v[108],v[124],v[53],v[87]],['','',[0,0,0],[11,17,31]]);
      equal([v[17],v[36]],[null,null]); // Not assigned by the supported source setup path.
    }
  });
  await test('New-city flag thresholds and hour boundaries follow the source fill loops',()=>{
    for(const hour of [0,2,3,4,6,7,23]) {
      const {state}=setup({hour});equal(state.flags[80],hour<3||hour>6);
      equal(state.flags.slice(88,95),[true,true,true,true,false,false,false]);
      equal(state.flags.slice(95,103),[true,true,true,false,false,false,false,false]);
      equal(state.flags.slice(103,112),Array(9).fill(true));
      equal(state.workspace.lastCity,1);
    }
    const system={...input.system,local31:0,local32:0};
    equal(setup({system}).state.locals[87],[13,23,23]); // Pascal DIV truncates toward zero.
  });
  await test('Same-city setup preserves persistent flags while always resetting117 and filling88/89',()=>{
    const flags=Array.from({length:128},(_,i)=>!!(i&1));flags[80]=true;
    const workspace={...input.workspace,lastCity:1,gate:255};
    const before=JSON.stringify({flags,workspace});
    const {state}=setup({flags,workspace});
    equal(state.locals[20],true);
    for(let i=0;i<128;i++)equal(state.flags[i],i===117 ? false : [88,89].includes(i) ? true : flags[i]);
    state.attributes[0]=255;state.workspace.quantity=0;
    equal(JSON.stringify({flags,workspace}),before);equal(input.attributes[0],30);
  });
  await test('Literal, mood, gate, mode, item and kind predicates do not draw',()=>{
    const s=base();s.locals[18]=true;s.locals[20]=true;s.locals[41]=13;
    for(const [code,value] of [[-1,false],[0,true],[2,false],[4,true],[6,true],[9,true],[12,false],[13,false],
      [14,false],[90,false],[91,true],[92,false],[200,false],[213,true],[255,false]]) {
      const result=run(code,s);equal(result.value,value);equal(result.draws,0);equal(result.randomState,12345);
    }
    s.locals[41]=143;equal(run(9,s).value,false);
    s.locals[41]=142;equal(run(9,s).value,true);
  });
  await test('Percent predicates always draw and preserve strict threshold boundaries',()=>{
    for(let seed=1;seed<=50;seed++)for(const code of [19,80,81,89,100,101,147,199]) {
      const threshold=code===19 ? 0 : code<90 ? (code%10||10)*10 : code-100;
      const result=run(code,base(),seed);equal(result.value,rolls(seed)[0]<threshold);
      equal(result.draws,1);equal(result.randomState,after(seed,1));
    }
    equal(run(100,base(),0).value,false);equal(run(101,base(),0).value,true);
  });
  await test('Luck checks halve luck on success and failure using the pre-check attribute',()=>{
    const s=base();s.attributes[4]=41;
    for(const success of [false,true]) {
      const seed=pick(r=>(r[0]<41)===success),result=run(5,s,seed);
      equal(result.value,success);equal(result.state.attributes[4],20);equal(result.draws,1);
      equal(s.attributes[4],41);
    }
  });
  await test('Charisma predicate1 only retries luck after its second check fails',()=>{
    const s=base();s.locals[17]=true;
    const firstFail=run(1,s,pick(r=>r[0]>=70));
    equal([firstFail.value,firstFail.draws,firstFail.state.locals[17],firstFail.state.attributes[4]],[false,1,true,81]);
    const bothPass=run(1,s,pick(r=>r[0]<70&&r[1]<45));
    equal([bothPass.value,bothPass.draws,bothPass.state.locals[17],bothPass.state.attributes[4]],[true,2,false,81]);
    const retry=run(1,s,pick(r=>r[0]<70&&r[1]>=45));
    equal([retry.value,retry.draws,retry.state.locals[17],retry.state.attributes[4]],[true,3,false,40]);
  });
  await test('Encoded attribute and mood failures retry luck without converting every false result',()=>{
    for(const code of [29,69]) {
      const s=base();s.locals[33]=0;
      const seed=pick(r=>r[0]>=60),result=run(code,s,seed);
      equal(result.value,true);equal(result.draws,2);equal(result.state.attributes[4],40);
      equal(result.randomState,after(seed,2));
    }
    const s=base();s.locals[102]=500;
    equal(run(3,s).draws,0);equal(run(3,s).value,true);
    s.locals[102]=0;const failCharisma=run(3,s,pick(r=>r[0]>=70));
    equal(failCharisma.value,false);equal(failCharisma.draws,1);equal(failCharisma.state.attributes[4],81);
  });
  await test('System compound checks eagerly draw twice; cached predicate11 skips later rolls',()=>{
    const s=base();s.locals[29]=0;
    for(const code of [18,70,79]){const result=run(code,s);equal(result.value,false);equal(result.draws,2)}
    s.flags[80]=false;s.attributes[3]=100;
    const result=run(11,s,0);equal(result.value,true);equal(result.state.flags[80],true);equal(result.draws,1);
    equal(run(11,result.state,result.randomState).draws,0);
    equal(s.flags[80],false);
  });
  await test('Inventory score, internal offer subtraction and valuation refresh preserve source fields',()=>{
    const s=base();s.workspace.quantity=6;
    equal(run(10,s,0).value,false);equal(run(10,s,0).draws,1);
    s.locals[106]=100;s.locals[100]=40;
    const left=run(8,s);equal(left.value,false);equal(left.state.locals[106],60);equal(left.draws,0);
    s.locals[106]=40;equal(run(8,s).value,true);equal(run(8,s).state.locals[106],40);
    s.locals[4]=20;s.locals[5]=30;s.locals[36]=1;s.locals[41]=12;
    const result=run(7,s,0);equal(result.value,true);equal(result.state.locals[5],29);equal(result.draws,2);
    equal(result.state.locals[106],22*items[12].valueByte);
    equal(result.state.locals[108],`${22*items[12].valueByte} Cr`);
    equal(result.state.locals[124],items[12].name);equal(result.state.locals[100],40);
    s.locals[5]=20;equal(run(7,s).draws,0);
    s.locals[5]=30;s.locals[36]=null;fail(()=>run(7,s,0),'missingDialogueValuation');
  });
  await test('Valuation pricing applies item masks, flag multipliers and all three scale caps',()=>{
    for(const [item,flag,cap,multiplier] of [[8,true,128,1],[8,false,64,2],[15,true,42,3],[22,false,42,3]]) {
      const s=base();s.locals[4]=1;s.locals[5]=1000;s.locals[30]=15;s.locals[36]=1;
      s.locals[41]=item+128;s.flags[80+item]=flag;s.locals[100]=123;
      const result=run(7,s,0);
      equal(result.state.locals[106],cap*multiplier*items[item].valueByte);
      equal(result.state.locals[124],items[item].name);equal(result.state.locals[100],123);
      equal(result.state.locals[104],500);equal(result.draws,2);
    }
    const s=base();s.locals[4]=0;s.locals[5]=-2;s.locals[36]=1;s.locals[41]=8;s.flags[88]=true;
    const result=run(7,s,0);equal([result.state.locals[4],result.state.locals[5]],[1,0]);
    equal(result.state.locals[106],items[8].valueByte);
    s.locals[4]=20;s.locals[5]=30;
    fail(()=>evaluateDialoguePredicate(7,s,0),'missingDialogueItems');
  });
  await test('Every byte predicate resolves on initialized working state without mutating the caller',()=>{
    const s=base();s.locals[36]=1;
    const snapshot=JSON.stringify(s);
    for(let code=0;code<=255;code++)for(const seed of [0,12345,0xffffffff]) {
      const result=run(code,s,seed);equal(typeof result.value,'boolean');
      equal(result.randomState,after(seed,result.draws));equal(result.draws<=3,true);
    }
    equal(JSON.stringify(s),snapshot);
  });
  await test('Counter entry predicate100 consumes one draw even when both redirect choices agree',()=>{
    for(const kind of [13,14]) {
      const {state,randomState}=setup({kind});let current=state,seed=randomState,calls=[];
      const record=dialogueRecord(catalog,state.entry);
      const result=selectDialogueValue(record.selection,{mood:3,gate:false,randomIndex:0,reuseRandom:false},null,code=>{
        const next=run(code,current,seed);calls.push(code);current=next.state;seed=next.randomState;
        return next.value;
      });
      equal(result.value,kind===13 ? 82 : 83);equal(calls,[100]);equal(seed,after(randomState,1));
    }
  });
  await test('Malformed setup and working states fail before publishing any changes',()=>{
    for(const change of [{kind:12},{hour:24},{cash:-1},{flags:[]},{carried:[1]},{system:{}}])
      fail(()=>setup(change),'invalidDialogueSetup');
    fail(()=>run(256),'invalidDialoguePredicateState');
    const s=base();s.locals[106]=-1;fail(()=>run(8,s),'invalidDialoguePredicateState');
  });
}
