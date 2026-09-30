import { sourceRandom } from './random.js';

// Game16 proc32 replaces entries52 onward. Block98 deliberately skips loading
// a supplement, retaining the preceding bank's dictionary (or the fresh base).
export function dialogueDictionary(content, block, previous=content.base) {
  if(!Number.isInteger(block)||block<90||block>102||previous.length!==64)
    throw new Error('invalidDialogueDictionary');
  if(block===98)return structuredClone(previous);
  const supplement=content.supplements[block];
  if(!supplement)throw new Error('invalidDialogueDictionary');
  return structuredClone([...content.base.slice(0,content.supplementStart),...supplement,
    ...Array.from({length:64-content.supplementStart-supplement.length},()=>({text:'',spaces:[]}))]);
}

// Procedures13/14. The choice is zero-based; negative means a random choice.
// Markers are counted BEFORE stripping bit7, including [ \ ] ^ _ and backtick.
export function dialoguePhrase(dictionary, index, choice, random) {
  if(!Number.isInteger(index)||index<0||!Number.isInteger(choice))throw new Error('invalidDialoguePhrase');
  if(index>=64)return '';
  const entry=dictionary[index];
  if(!entry)throw new Error('invalidDialogueDictionary');
  const spaces=new Set(entry.spaces);
  const marker=i=>!spaces.has(i)&&entry.text.charCodeAt(i)>=65&&entry.text.charCodeAt(i)<=96;
  let offset=0;
  if(choice<0) {
    let count=1;
    for(let i=0;i<entry.text.length;i++)if(marker(i))count++;
    choice=random.next()%count; // Even empty/single-choice entries draw once.
  }
  while(choice>0&&offset<entry.text.length)if(marker(offset++))choice--;
  // Native would read beyond the entry for an invalid explicit alternative.
  // Reject that unsupported request instead of reading unrelated dictionary text.
  if(choice>0)throw new Error('unsupportedDialogueAlternative');
  let result='';
  for(let i=offset;i<entry.text.length;i++) {
    let char=entry.text[i],end=false;
    if(char==='|'||char==='\\')char='I';
    else if(char>='A'&&char<='Z'){char=char.toLowerCase();end=true}
    else if(!spaces.has(i)&&char==='~')char="'";
    else if(!spaces.has(i)&&char==='`')break; // Rewrites the previous output byte; no append.
    result+=char+(spaces.has(i) ? ' ' : '');
    if(end)break;
  }
  return result;
}

// Procedure27 captions choose a fixed alternative from entry0 and capitalize
// only its first character. They do not consume the gameplay random stream.
export function dialogueCaption(dictionary, index) {
  if(!Number.isInteger(index)||index<0)throw new Error('invalidDialoguePhrase');
  const value=dialoguePhrase(dictionary,0,index,null);
  return value ? value[0].toUpperCase()+value.slice(1) : '';
}

// Procedures16–22. English source expansion only; localization belongs to the
// future conversation presenter. Strings108/124 are supplied by dialogue setup,
// not inferred from immutable campaign credits. All RNG is local until success.
export function renderDialogueMessage(content, dictionary, block, word, seed, context) {
  const message=content.messages[block]?.[word];
  if(!Number.isInteger(block)||!Number.isInteger(word)||!message)throw new Error('unsupportedDialogueMessage');
  if(!context||!Number.isInteger(context.mood)||context.mood<0||context.mood>4||
    typeof context.mode18!=='boolean'||!Number.isInteger(context.workspace11))throw new Error('invalidDialogueTextContext');
  const random=sourceRandom(seed);
  let text='',capital=true,budget=8192;
  const chosenPlaces=[];
  function emit(char) {
    if(capital&&char.charCodeAt(0)>=97)char=String.fromCharCode(char.charCodeAt(0)-32);
    if(char.charCodeAt(0)>=65||char===',')capital=false;
    text+=char;
    if(text.length>8192)throw new Error('dialogueTextLimit');
  }
  function raw(value) {
    if(typeof value!=='string')throw new Error('missingDialogueSubstitution');
    if(value){emit(value[0]);text+=value.slice(1)}
  }
  function place() {
    const p=context.places;
    if(!p||p.systems?.length!==12||p.worlds?.length!==18||
      !Number.isInteger(p.system)||p.system<1||p.system>12||
      !Number.isInteger(p.world)||p.world<1||p.world>18||
      ![...p.systems,...p.worlds].every(n=>typeof n==='string'&&n.length>0))
      throw new Error('missingDialoguePlaces');
    const system=!!(random.next()&1),names=system ? p.systems : p.worlds,current=system ? p.system : p.world;
    const seen=new Set();
    for(;;) {
      if(seen.has(random.state))throw new Error('dialoguePlaceUnavailable');
      seen.add(random.state);
      const index=1+random.next()%names.length;
      if(index!==current)return names[index-1];
    }
  }
  function phrase(index,choice,recursive,depth) {
    const value=dialoguePhrase(dictionary,index,choice,random);
    if(recursive)for(const char of value)token(char.charCodeAt(0),depth+1);
    else raw(value);
  }
  function token(code,depth=0) {
    if(--budget<0||depth>32)throw new Error('dialogueTextLimit');
    if(code>=65){emit(String.fromCharCode(code));return}
    if(code===63){emit('?');capital=true;return}
    if(code>=48||code<32){phrase(code,-1,true,depth);return}
    switch(code) {
      case 32:case 39:case 44:emit(String.fromCharCode(code));break;
      case 33:case 46:emit(String.fromCharCode(code));capital=true;break;
      case 34:raw('O.K.');break;
      case 35:{const name=place();chosenPlaces.push(name);raw(name);break}
      case 36:raw(context.strings?.[108]);capital=false;break;
      case 37:raw(context.strings?.[124]);break;
      case 38:case 40:phrase(code,Number(context.workspace11===1),false,depth);break;
      case 41:case 42:case 43:phrase(code,0,false,depth);break;
      case 45:phrase(code,context.mood,true,depth);break;
      case 47:phrase(code,Number(context.mode18),false,depth);break;
    }
  }
  const spaces=new Set(message.spaces);
  for(let i=0;i<message.text.length;i++) {
    token(message.text.charCodeAt(i));
    if(spaces.has(i))token(32);
  }
  if(text.length>8192)throw new Error('dialogueTextLimit');
  return {text,randomState:random.state,...(chosenPlaces.length ? {chosenPlaces} : {})};
}
