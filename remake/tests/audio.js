import { createAudio } from '../js/platform/audio.js';

export async function audioTests(test, equal) {
  await test('Sound starts from a gesture, mutes immediately and remembers the choice', () => {
    const events=[],values=new Map();
    const storage={getItem:key=>values.get(key),setItem:(key,value)=>values.set(key,value)};
    class FakeAudio {
      state='running';currentTime=0;destination={};
      createGain(){const gain={gain:{value:0,setValueAtTime(){},linearRampToValueAtTime(){}},connect(){},disconnect(){}};events.push(gain);return gain}
      createOscillator(){return {frequency:{setValueAtTime(){}},connect(){},disconnect(){},start(){events.push('start')},stop(){}}}
    }
    const sound=createAudio({storage,Audio:FakeAudio});
    sound.play('select');equal(events.length,0); // No autoplay before a gesture.
    sound.play('select',true);equal(events.filter(event=>event==='start').length,1);
    sound.toggle();equal(sound.enabled,false);equal(events[0].gain.value,0);
    sound.play('warp',true);equal(events.filter(event=>event==='start').length,1);
    equal(createAudio({storage,Audio:FakeAudio}).enabled,false);
    sound.toggle();equal(events[0].gain.value,0.065);
    equal(events.filter(event=>event==='start').length,3);
    equal(createAudio({storage,Audio:FakeAudio}).enabled,true);
  });
  await test('Missing Web Audio keeps sound controls unavailable without breaking play', () => {
    const sound=createAudio({storage:{getItem:()=>null,setItem(){}},Audio:null});
    equal(sound.supported,false);sound.play('fire',true);equal(sound.activate(),false);
  });
}
