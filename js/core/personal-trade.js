// Gross proceeds from completed personal-item sales, separate from cash and
// immutable creation assets. This is validated progress, not an anti-cheat log.
export const initialPersonalTrade=()=>({sold:Array(32).fill(0),proceeds:Array(32).fill(0)});
const keys=(v,names)=>v&&typeof v==='object'&&!Array.isArray(v)&&Object.keys(v).length===names.length&&names.every(k=>Object.hasOwn(v,k));
const count=n=>Number.isSafeInteger(n)&&n>=0&&n<=1000000000;
const array=a=>Array.isArray(a)&&a.length===32&&Object.keys(a).length===32&&Array.from(a).every(Number.isSafeInteger);
export const saleItem=byte=>Number.isInteger(byte)&&byte>=10&&byte<=255&&(byte&31)>=10&&(byte&31)!==14;
function bounds(items,type) {
  const item=items?.[type];
  if(item?.sourceIndex!==type||!Number.isInteger(item.valueByte)||item.valueByte<1||item.valueByte>255)throw new Error('invalidPersonalTrade');
  // Game16 price scale: stimulants use value*3 capped at42, other types at128.
  return [item.valueByte*(type>=15&&type<=22 ? 3 : 1),item.valueByte*(type>=15&&type<=22 ? 126 : 128)];
}
export function validatePersonalTrade(value,items) {
  if(!keys(value,['sold','proceeds'])||!array(value.sold)||!array(value.proceeds))throw new Error('invalidPersonalTrade');
  let total=0;
  for(let type=0;type<32;type++) {
    const n=value.sold[type],p=value.proceeds[type];
    if(!count(n)||p<0)throw new Error('invalidPersonalTrade');
    if(!saleItem(type)) {if(n!==0||p!==0)throw new Error('invalidPersonalTrade')}
    else if(n!==0||p!==0) {
      const [min,max]=bounds(items,type);
      if(p<n*min||p>n*max||p%min!==0)throw new Error('invalidPersonalTrade');
    }
    total+=p;
  }
  if(!Number.isSafeInteger(total))throw new Error('invalidPersonalTrade');
  return {sold:[...value.sold],proceeds:[...value.proceeds]};
}
export function recordPersonalSales(previous,sales,items) {
  const next=validatePersonalTrade(previous,items);
  if(!Array.isArray(sales))throw new Error('invalidPersonalTrade');
  for(const sale of sales) {
    if(!keys(sale,['item','price'])||!saleItem(sale.item)||!Number.isInteger(sale.price))throw new Error('invalidPersonalTrade');
    const type=sale.item&31,[min,max]=bounds(items,type);
    if(sale.price<min||sale.price>max||sale.price%min!==0)throw new Error('invalidPersonalTrade');
    next.sold[type]++;next.proceeds[type]+=sale.price;
  }
  return validatePersonalTrade(next,items);
}
