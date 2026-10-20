import { createCityMaps } from '../js/core/city-map.js';
import { createCityGeometry } from '../js/core/city-walk.js';
import { createPodGeometry } from '../js/core/city-pod.js';
import { canStand, tryStep } from '../js/core/ship-walk.js';
import { parkedPodGeometry, canBoardParkedPod, findPodFootExit } from '../js/core/parked-pod.js';

export async function parkedPodTests(test,equal) {
  const [maps,navigation,economy,location,data]=await Promise.all(
    ['maps','initial-navigation','initial-economy','initial-location','city-walk'].map(n=>fetch(`../data/${n}.json`).then(r=>r.json())));
  const map=createCityMaps(maps,navigation,economy)['city-01'],anchor={...location,position:location.shipPosition};
  const foot=createCityGeometry(map,data,anchor),pod=createPodGeometry(map,data,anchor);
  const pixel=(g,x,y)=>!!(g.backgrounds.ship[y][Math.floor(x/7)]&(1<<(x%7)));
  const blank=()=>({width:70,height:56,collisionRows:[0,0,0,0,0,0,0,1],
    backgrounds:{ship:Array.from({length:56},()=>Array(10).fill(0))}});
  const reject=f=>{let message;try{f()}catch(e){message=e.message}equal(message,'invalidParkedPod')};
  await test('Parked pods use visible orientation glyphs and pattern9 against the detached-ship background',()=>{
    const beforeFoot=JSON.stringify(foot),beforePod=JSON.stringify(pod),position={x:360,y:215};
    // Independent original visible-font vectors; collision masks15/17/19/21
    // must not be painted as solid parked bodies.
    const glyphs={14:[0,0,28,28,28,28,28,0],16:[0,0,0,62,62,62,0,0],
      18:[0,0,24,60,30,12,0,0],20:[0,0,12,30,60,24,0,0]};
    for(const heading of [14,16,18,20]) {
      const g=parkedPodGeometry(foot,pod,position,heading);
      for(let y=205;y<219;y++)for(let x=350;x<374;x++) {
        const dx=x-360,dy=y-208;
        const painted=dx>=0&&dx<7&&dy>=0&&dy<8&&!!(glyphs[heading][dy]&(1<<dx))&&x%2===0;
        equal(pixel(g,x,y),pixel(pod,x,y)!==!!painted);
      }
      equal(g.collisionRows,foot.collisionRows);
      equal(g.backgrounds.ship[100]===pod.backgrounds.ship[100],true);
      equal(g.backgrounds.ship[210]===pod.backgrounds.ship[210],false);
      // Returning on foot must not restore the attached pod at the ship.
      for(let y=204;y<=211;y++)for(let x=287;x<301;x++)equal(pixel(g,x,y),pixel(pod,x,y));
    }
    equal(JSON.stringify(foot),beforeFoot);equal(JSON.stringify(pod),beforePod);
    for(const [point,heading] of [[position,15],[{x:100,y:100},16],[{x:360.5,y:215},16]])reject(()=>parkedPodGeometry(foot,pod,point,heading));
  });
  await test('Pod disembark search preserves source column order, expanding scale and failure ownership',()=>{
    const g=blank(),p={x:30,y:28};equal(findPodFootExit(g,p),{x:27,y:25});
    // Block the first column entirely: the first cell in column two wins.
    for(let y=25;y<=31;y++)g.backgrounds.ship[y][3]|=1<<6;
    equal(findPodFootExit(g,p),{x:28,y:25});
    // One opening at(-6,+2) cannot be found at scale1. Scale2 must visit
    // it before an opening at(-4,-6), even though the latter has smaller Y.
    const solid=blank();solid.backgrounds.ship.forEach(row=>row.fill(127));
    for(const [x,y] of [[24,30],[26,22]])solid.backgrounds.ship[y][Math.floor(x/7)]&=~(1<<(x%7));
    const before=JSON.stringify(solid);equal(findPodFootExit(solid,p),{x:24,y:30});equal(JSON.stringify(solid),before);
    solid.backgrounds.ship.forEach(row=>row.fill(127));equal(findPodFootExit(solid,p),null);
    equal(findPodFootExit(g,{x:30.5,y:28}),null);equal(findPodFootExit(g,{x:70,y:28}),null);
  });
  await test('Parked pod boarding requires a clear foot position within both four-pixel bounds',()=>{
    const g=blank(),p={x:30,y:28};
    for(const x of [-4,0,4])for(const y of [-4,0,4])equal(canBoardParkedPod(g,{x:p.x+x,y:p.y+y},p),true);
    for(const [x,y] of [[-5,0],[5,0],[0,-5],[0,5]])equal(canBoardParkedPod(g,{x:p.x+x,y:p.y+y},p),false);
    g.backgrounds.ship[28][4]|=1<<2;
    equal(canBoardParkedPod(g,p,p),false);equal(canBoardParkedPod(g,{x:30.5,y:28},p),false);
  });
  await test('Real city disembarkation preserves the pod obstacle and allows a collision-checked walking return',()=>{
    // At departure the source's first clear position is a small pocket beside
    // the ship; boarding recovers it. A street parking position permits walking.
    const departure=parkedPodGeometry(foot,pod,pod.spawn,16),first=findPodFootExit(departure,pod.spawn);
    equal(first,{x:293,y:210});equal(canBoardParkedPod(departure,first,pod.spawn),true);
    const position={x:360,y:215},g=parkedPodGeometry(foot,pod,position,16),exit=findPodFootExit(g,position);
    equal(exit,{x:357,y:212});equal(canStand(g,exit),true);equal(canBoardParkedPod(g,exit,position),true);
    let blocked=0;
    for(let y=208;y<=219;y++)for(let x=354;x<=369;x++)if(canStand({...g,backgrounds:pod.backgrounds},{x,y})&&!canStand(g,{x,y}))blocked++;
    equal(blocked>0,true);
    const queue=[exit],seen=new Map([[`${exit.x}/${exit.y}`,null]]);let distant;
    for(let i=0;i<queue.length&&!distant;i++) {
      const p=queue[i];
      if(Math.abs(p.x-position.x)+Math.abs(p.y-position.y)>20){distant=p;break}
      for(const [dx,dy] of [[1,0],[-1,0],[0,1],[0,-1]]) {
        const q=tryStep(g,p,dx,dy),key=`${q.x}/${q.y}`;
        if(!seen.has(key)){seen.set(key,p);queue.push(q)}
      }
    }
    equal(!!distant,true);equal(canBoardParkedPod(g,distant,position),false);
    while(seen.get(`${distant.x}/${distant.y}`)) {
      const previous=seen.get(`${distant.x}/${distant.y}`);
      equal(tryStep(g,distant,previous.x-distant.x,previous.y-distant.y),previous);distant=previous;
    }
    equal(canBoardParkedPod(g,distant,position),true);equal(position,{x:360,y:215});
  });
}
