const wrap=(n,size)=>((n%size)+size)%size;

// Game21 proc26/28, then proc12 $0571–$0666. Cameras are tile origins;
// positions are whole-map pixels. Horizontal scrolling has priority over Y.
export function groundCameraAt(position,surface=false) {
  let y=wrap(Math.floor(position.y/(surface?24:32))-(surface?4:3),24);
  // Proc28 $12B3–$12BF resets an initial surface origin above20 to0.
  // Subsequent scrolling still wraps modulo24 in proc12.
  if(surface&&y>20)y=0;
  return {x:wrap(Math.floor(position.x/28)-5,40),y};
}
export function scrollGroundCamera(camera,position,surface=false) {
  const tileHeight=surface?24:32;
  const x=wrap(position.x-camera.x*28,1120),y=wrap(position.y-camera.y*tileHeight,24*tileHeight);
  const column=Math.floor((x+3)/7),row=Math.floor((y-3)/8);
  let dx=0,dy=0;
  if(column<7)dx=-1;else if(column>32)dx=1;else if(row<7)dy=-1;else if(row>16)dy=1;
  const attempted={x:camera.x+dx,y:camera.y+dy};
  return {attempted,camera:{x:wrap(attempted.x,40),y:wrap(attempted.y,24)},scrolled:!!(dx||dy)};
}

export function groundWindow(map,camera,surface=false) {
  return Array.from({length:surface?8:6},(_,dy)=>Array.from({length:10},(_,dx)=>{
    const x=wrap(camera.x+dx,40),y=wrap(camera.y+dy,24);
    return {x,y,tile:map.tiles[y][x]};
  }));
}
