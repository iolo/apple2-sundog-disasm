import { initialPersonalTrade, validatePersonalTrade, recordPersonalSales } from '../js/core/personal-trade.js';
import { setupCounterDialogue } from '../js/core/dialogue-state.js';
import { startCounterConversation, advanceDialogue, dialogueSale } from '../js/core/dialogue-runner.js';

export async function personalTradeTests(test,equal) {
  const [scripts,text,items,systems]=await Promise.all(['dialogue','dialogue-text','items','dialogue-systems'].map(n=>fetch(`../data/${n}.json`).then(r=>r.json())));
  const content={scripts,text,items},reject=(fn,want)=>{let error;try{fn()}catch(e){error=e.message}equal(error,want)};
  const advance=(f,input)=>advanceDialogue(content,f,input);
  const setup=()=>setupCounterDialogue({kind:21,system:systems.systems[0],attributes:[30,40,50,30,81],carried:[139,235,23,0],
    flags:Array(128).fill(false),workspace:{lastCity:0,mood:3,quantity:1,gate:0,item:0,actor:2},city:1,hour:7,surface:{x:10,y:6},cash:5000,randomState:2});
  function trading() {
    let f=startCounterConversation(content,setup());
    for(const input of [{type:'timeout'},{type:'reply',slot:1},{type:'reply',slot:1}])f=advance(f,input);
    equal(f.view.state,130);return f;
  }
  function accepted() {
    let f=advance(trading(),{type:'reply',slot:2});equal(f.view.state,131);
    f=advance(f,{type:'item',item:139});equal(f.view.state,35);equal(f.state.locals[106],600);
    return advance(f,{type:'reply',slot:0});
  }
  await test('Visitor sale pays only on transfer, matches low item bits and removes the selected charged byte',()=>{
    const f=accepted(),before=JSON.stringify(f);equal(dialogueSale(content,f),{item:139,price:600,cash:5000});
    equal(f.state.sales,[]);equal(f.state.carried,[139,235,23,0]);
    const sold=advance(f,{type:'sale',slot:1});equal(sold.state.carried,[139,0,23,0]);equal(sold.state.locals[104],5600);
    equal(sold.state.sales,[{item:235,price:600}]);equal(sold.view.state,46);equal(JSON.stringify(f),before);
    reject(()=>advance(sold,{type:'sale',slot:0}),'invalidDialogueSale');
    const done=advance(sold,{type:'cancel'});equal(done.ended,true);equal(done.state.carried,sold.state.carried);equal(done.state.locals[104],5600);
    equal(advance(f,{type:'cancel'}).state.sales,[]);
  });
  await test('Invalid visitor sale slots, unaccepted quotes and cash overflow leave items, cash and RNG untouched',()=>{
    const f=accepted(),before=JSON.stringify(f);
    for(const slot of [-1,4,0.5,2,3])reject(()=>advance(f,{type:'sale',slot}),'invalidDialogueSale');
    reject(()=>advance(trading(),{type:'sale',slot:0}),'invalidDialogueSale');equal(JSON.stringify(f),before);
    f.state.locals[104]=32767999-599;const full=JSON.stringify(f);
    reject(()=>advance(f,{type:'sale',slot:0}),'dialogueCashOverflow');equal(JSON.stringify(f),full);
    f.state.locals[104]--;equal(advance(f,{type:'sale',slot:0}).state.locals[104],32767999);
  });
  await test('Visitors also sell through explicit purchase confirmation and retain the source continuation',()=>{
    let f=advance(trading(),{type:'reply',slot:1});equal(f.view.state,34);
    f=advance(f,{type:'reply',slot:0});equal(f.view.state,37);
    const price=f.state.locals[106],item=f.panel.items[0],next=advance(f,{type:'purchase',slot:3});
    equal(next.state.carried,[139,235,23,item]);equal(next.state.locals[104],5000-price);equal(next.state.sales,[]);
  });
  await test('Personal trade ledger counts complete sales by item type and validates native price bounds',()=>{
    const zero=initialPersonalTrade(),before=JSON.stringify(zero),next=recordPersonalSales(zero,[{item:139,price:600},{item:235,price:700},{item:151,price:84}],items);
    equal(next.sold[11],2);equal(next.proceeds[11],1300);equal(next.sold[23],1);equal(next.proceeds[23],84);equal(JSON.stringify(zero),before);
    equal(validatePersonalTrade(JSON.parse(JSON.stringify(next)),items),next);
    for(const sale of [{item:8,price:2},{item:14,price:0},{item:139,price:1},{item:139,price:12900},{item:15,price:100},
      {item:139,price:600,extra:1},{item:139,price:-100}])reject(()=>recordPersonalSales(zero,[sale],items),'invalidPersonalTrade');
    for(const mutate of [s=>s.extra=true,s=>s.sold.pop(),s=>s.sold[0]=1,s=>s.proceeds[11]=100,s=>s.sold[11]=-1,
      s=>{s.sold[11]=1000000001;s.proceeds[11]=100000000100},s=>s.sold[11]=0.5]) {
      const bad=initialPersonalTrade();mutate(bad);reject(()=>validatePersonalTrade(bad,items),'invalidPersonalTrade');
    }
    next.sold[11]=1000000000;next.proceeds[11]=100000000000;
    reject(()=>recordPersonalSales(next,[{item:139,price:600}],items),'invalidPersonalTrade');
  });
}
