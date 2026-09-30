import { dialogueDictionary, dialoguePhrase, dialogueCaption, renderDialogueMessage } from '../js/core/dialogue-text.js';
import { sourceRandom } from '../js/core/random.js';

export async function dialogueTextTests(test,equal) {
  const content=await fetch('../data/dialogue-text.json').then(r=>r.json());
  const base={mood:3,mode18:false,workspace11:1,strings:{108:'123',124:'shunt'},
    places:{systems:Array.from({length:12},(_,i)=>`System${i+1}`),worlds:Array.from({length:18},(_,i)=>`World${i+1}`),system:1,world:1}};
  const dictionary=dialogueDictionary(content,94);
  const render=(word,seed=12345,context=base)=>renderDialogueMessage(content,dictionary,94,word,seed,context);
  const fail=(run,message)=>{let actual;try{run()}catch(e){actual=e.message}equal(actual,message)};
  const literal=(text,spaces=[],context=base,seed=12345,dict=dictionary)=>renderDialogueMessage(
    {messages:{94:{250:{text,spaces}}}},dict,94,250,seed,context);
  const noRandom={next(){throw new Error('Unexpected random draw')}};

  await test('Dialogue text contains 64 base entries, twelve supplements and 165 classified messages',()=>{
    equal(content.version,1);equal(content.base.length,64);equal(Object.keys(content.supplements).length,12);
    equal(Object.values(content.messages).reduce((n,b)=>n+Object.keys(b).length,0),165);
    equal(content.supplementStart,52);equal(content.messages[94][147].text,'*\x15,-?');
  });
  await test('Supplement loading replaces the tail; block98 preserves the preceding dictionary',()=>{
    const long=dialogueDictionary(content,95),short=dialogueDictionary(content,90,long);
    equal(long[60].text.length>0,true);equal(short[53],{text:'',spaces:[]});
    equal(short.slice(0,52),content.base.slice(0,52));
    equal(dialogueDictionary(content,98,long),long);
    equal(dialogueDictionary(content,98),content.base);
    const copy=dialogueDictionary(content,98,long);copy[52].spaces.push(999);
    equal(long[52].spaces.includes(999),false);
    fail(()=>dialogueDictionary(content,103),'invalidDialogueDictionary');
  });
  await test('All 25 fixed reply captions expand without a random draw',()=>{
    equal(Array.from({length:25},(_,i)=>dialogueCaption(dictionary,i)),[
      'Yes','No','Accept','Discuss it','Threaten','Charm','Bluff','Bribe','Buy','Sell','Information','Offer',
      'Agree','Refuse','Fast talk','Need fuel','Help','Claim no cash','Junk','Forget it','Search','Nothing',
      'Recommend','Uh huh','Dunno']);
    equal(dialogueCaption(dictionary,25),'');
    fail(()=>dialogueCaption(dictionary,26),'unsupportedDialogueAlternative');
    fail(()=>dialogueCaption(dictionary,-1),'invalidDialoguePhrase');
  });
  await test('Phrase boundaries count unmarked bytes65–96 before stripping space flags',()=>{
    const d=structuredClone(dictionary);
    d[1]={text:'aBz',spaces:[1]};
    let draws=0;
    equal(dialoguePhrase(d,1,-1,{next(){draws++;return 1}}),'ab ');equal(draws,1);
    d[1]={text:'a[b',spaces:[]};
    equal(dialoguePhrase(d,1,0,noRandom),'a[b'); // Count marker need not terminate rendering.
    equal(dialoguePhrase(d,1,1,noRandom),'b');
    d[1]={text:'ab`cd',spaces:[]};equal(dialoguePhrase(d,1,0,noRandom),'ab');
    equal(dialoguePhrase(d,1,1,noRandom),'cd');
    d[1]={text:'|\\~',spaces:[]};equal(dialoguePhrase(d,1,0,noRandom),"II'");
    d[1]={text:'~`',spaces:[0,1]};equal(dialoguePhrase(d,1,0,noRandom),'~ ` ');
  });
  await test('Empty dictionary phrases draw once when random; out-of-range indices draw nothing',()=>{
    const rng=sourceRandom(12345),reference=sourceRandom(12345);reference.next();
    equal(dialoguePhrase(dictionary,63,-1,rng),'');equal(rng.state,reference.state);
    equal(dialoguePhrase(dictionary,64,-1,noRandom),'');
    equal(dialoguePhrase(dictionary,42,0,noRandom),'what');
  });
  await test('Counter greetings expand nested phrases in source RNG order',()=>{
    equal(render(147,0),{text:'What can I serve you, mac? ',randomState:0});
    equal(render(147),{text:'What can I get you, fella? ',randomState:120478901});
    equal(render(147,0xffffffff),{text:'What do you wish, mac? ',randomState:4292886400});
    const rng=sourceRandom(12345);rng.next();rng.next();rng.next();
    equal(render(147).randomState,rng.state); // Entries21,3,50, in that order.
    equal(render(150),{text:'What else can I show you. ',randomState:12345});
    equal(render(160),{text:'Something else, fella? ',randomState:120478901});
    equal(render(163),{text:'What else, laser brain? ',randomState:1580217});
  });
  await test('Mood, speaker and mode substitutions select the original forms',()=>{
    for(let mood=0;mood<=4;mood++)
      equal(literal('-',[],{...base,mood},0).text,['Laser brain','Laser brain','Mac','Mac','Sir'][mood]);
    equal(literal('& ( /',[],base).text,'I me buy');
    equal(literal('& ( /',[],{...base,mode18:true,workspace11:2}).text,'We us sell');
  });
  await test('Sentence casing, source spacing and raw substitutions preserve their distinct paths',()=>{
    equal(literal('hello!how?fine.ok,yes').text,'Hello!How?Fine.Ok,yes');
    equal(literal('ab',[0,1]).text,'A b ');
    equal(literal('"hello').text,'O.K.hello');
    equal(literal('$abc').text,'123abc'); // String108 explicitly clears capitalization.
    equal(literal('%abc',[],{...base,strings:{124:'123'}}).text,'123Abc');
    equal(literal('%',[],{...base,strings:{124:'multi.word'}}).text,'Multi.word');
    equal(literal('@').text,''); // Dictionary index64 returns an empty phrase.
  });
  await test('Place names use the raw RNG low bit and reject the current place before copying',()=>{
    const kinds=new Set();
    for(const seed of [1,2,3,12345,0xffffffff]) {
      const rng=sourceRandom(seed),system=!!(rng.next()&1),names=system ? base.places.systems : base.places.worlds;
      kinds.add(system);
      const current=1+rng.next()%names.length;
      let next=current;while(next===current)next=1+rng.next()%names.length;
      const places={...base.places,[system ? 'system' : 'world']:current};
      equal(literal('#',[],{...base,places},seed),{text:names[next-1],randomState:rng.state,chosenPlaces:[names[next-1]]});
    }
    equal(kinds.size,2);
    fail(()=>literal('#',[],base,0),'dialoguePlaceUnavailable');
    equal(literal('#',[],{...base,places:{...base.places,world:2}},0),{text:'World1',randomState:0,chosenPlaces:['World1']});
  });
  await test('Missing setup substitutions and unsupported message addresses fail explicitly',()=>{
    fail(()=>literal('$',[],{...base,strings:{}}),'missingDialogueSubstitution');
    fail(()=>literal('#',[],{...base,places:null}),'missingDialoguePlaces');
    fail(()=>render(255),'unsupportedDialogueMessage');
    fail(()=>render(147,1,{...base,mood:5}),'invalidDialogueTextContext');
    const d=structuredClone(dictionary);d[1]={text:'\x01',spaces:[]};
    fail(()=>literal('\x01',[],base,1,d),'dialogueTextLimit');
  });
  await test('All165 messages expand deterministically across five moods and three seeds without mutating inputs',()=>{
    const before=JSON.stringify({content,base});let count=0;
    for(const [block,messages] of Object.entries(content.messages)) {
      const d=dialogueDictionary(content,Number(block)),saved=JSON.stringify(d);
      for(const word of Object.keys(messages))for(const seed of [1,12345,0xffffffff])for(let mood=0;mood<=4;mood++) {
        const context={...base,mood};
        const result=renderDialogueMessage(content,d,Number(block),Number(word),seed,context);
        equal(result,renderDialogueMessage(content,d,Number(block),Number(word),seed,context));
        equal(/[\x00-\x1f]/.test(result.text),false);count++;
      }
      equal(JSON.stringify(d),saved);
    }
    equal(count,2475);equal(JSON.stringify({content,base}),before);
  });
}
