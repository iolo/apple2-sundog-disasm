import { groundChaseGeometry } from '../core/ground-chase.js';

// Source low-seven-bit rows and glyphs, projected into the existing city view.
// The underlying campaign map remains the encounter's frozen return location.
export function drawGroundEncounter(context,activation,content,bounds,aim=null) {
  const chase=activation.phase==='chase',arena=chase?groundChaseGeometry(activation.chase,content.chase):activation.arena;
  if(!arena)return;
  const window=chase?activation.chase.window:arena.bounds,sx=bounds.width/280,sy=bounds.height/192;
  context.save();context.beginPath();context.rect(bounds.x,bounds.y,bounds.width,bounds.height);context.clip();
  context.fillStyle='#101411';
  context.fillRect(bounds.x+window.left*sx,bounds.y+window.top*sy,(window.right-window.left+1)*sx,(window.bottom-window.top+1)*sy);
  context.fillStyle='#e6e1ce';
  for(let y=window.top;y<=window.bottom;y++)for(let x=window.left;x<=window.right;x++)
    if(arena.backgrounds.ship[y][Math.floor(x/7)]&(1<<(x%7)))context.fillRect(bounds.x+x*sx,bounds.y+y*sy,sx,sy);
  const actors=chase?[[activation.chase.player,22],[activation.chase.enemy,23]]:
    activation.combat.actors.map(a=>[{x:a[1],y:a[0]},a[2]>>>8]);
  for(const [position,glyph] of actors) {
    const rows=(chase?content.chase:content.ground).glyphs[glyph];
    for(let y=0;y<8;y++)for(let x=0;x<7;x++)if(rows[y]&(1<<x))
      context.fillRect(bounds.x+(position.x+x)*sx,bounds.y+(position.y-7+y)*sy,sx,sy);
  }
  // A presentation outline distinguishes the combat window; it is not a wall.
  context.strokeStyle='#969d8c';context.lineWidth=1;
  context.strokeRect(bounds.x+window.left*sx,bounds.y+window.top*sy,(window.right-window.left+1)*sx,(window.bottom-window.top+1)*sy);
  if(!chase&&aim) {
    context.strokeStyle='#eab975';context.beginPath();
    const x=bounds.x+aim.x*sx,y=bounds.y+aim.y*sy;
    context.moveTo(x-5,y);context.lineTo(x+5,y);context.moveTo(x,y-5);context.lineTo(x,y+5);context.stroke();
  }
  context.restore();
}
