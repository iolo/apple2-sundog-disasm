// Game16 procedures24/25/29/34. This is the selection layer, not a complete
// conversation runner. Callers must render messages before resolving following
// predicates: dictionary expansion and predicates can consume the shared RNG.

export function dialogueRecord(catalog, state) {
  if(!Number.isInteger(state)||state<16||state>223)throw new Error('unsupportedDialogueState');
  const bank=catalog.banks[Math.trunc(state/16)-1],offset=bank?.entries[state%16];
  const record=offset&&bank.records.find(r=>r.offset===offset);
  if(!record)throw new Error('unsupportedDialogueState');
  // A caller may prepare a conversation without mutating the shared catalogue.
  return {block:bank.block,state,...structuredClone(record)};
}

function testPredicate(predicate, evaluate) {
  if(predicate===0)return true; // Procedure8 $0264–$026C.
  if(typeof evaluate!=='function')throw new Error('missingDialoguePredicate');
  const result=evaluate(predicate);
  if(typeof result!=='boolean')throw new Error('invalidDialoguePredicate');
  return result;
}

// Context mirrors outer locals33/20/14/15. local20 is a persistent selector
// gate, not an expression to evaluate. No shared world state is mutated here.
export function selectDialogueValue(selection, previous, random, evaluate) {
  if(!previous||!Number.isInteger(previous.mood)||previous.mood<0||previous.mood>4||
    typeof previous.gate!=='boolean'||typeof previous.reuseRandom!=='boolean'||
    !Number.isInteger(previous.randomIndex)||previous.randomIndex<0||previous.randomIndex>9)
    throw new Error('invalidDialogueContext');
  const context={...previous};
  let value;
  switch(selection.kind) {
    case 'literal': value=selection.value;break;
    case 'random': {
      const count=selection.values.length;
      const index=context.reuseRandom ? context.randomIndex : random.next()%count;
      context.randomIndex=index;context.reuseRandom=false;
      // Native leaves the selector itself in the result when a reused index
      // exceeds this list; it does not wrap or draw again ($0A41–$0A5C).
      value=selection.values[index]??count;
      break;
    }
    case 'conditional':
      value=selection.fallback;
      for(const choice of selection.choices)if(testPredicate(choice.predicate,evaluate)){value=choice.value;break}
      break;
    case 'mood': {
      if(selection.code===21&&!context.gate)value=selection.fallback;
      else value=selection.values[Math.max(0,(selection.code===23 ? 3 : 2)-context.mood)];
      break;
    }
    default: throw new Error('unsupportedDialogueSelector');
  }
  return {value,context};
}

// Procedure29 replaces a transition when its nonzero predicate is FALSE.
export function dialogueTransition(transition, evaluate) {
  const override=transition.unless;
  return override&&override.predicate!==0&&!testPredicate(override.predicate,evaluate) ? override.state : transition.state;
}
