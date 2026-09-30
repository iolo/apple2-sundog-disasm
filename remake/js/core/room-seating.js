// Game18 procedures8/24. Seat numbers are the source actor actions4..9;
// derive reservations from actors instead of persisting a second slot table.
export const isTavern=room=>room.index>=4&&room.index<=7;
export const initialTavern=()=>({playerSeat:null,secondary:0,contact:null});
export const oppositeSeat=seat=>4+((seat-4)^1);
export const seatTarget=(room,seat)=>room.fixtures.seats.find(s=>s.action===seat);

export function playerSeatAt(room,player) {
  if(!isTavern(room)||player.y<room.fixtures.seats[0].y-2)return null;
  const left=room.fixtures.seats[0].x-3,right=room.fixtures.seats[5].x+7,width=right-left;
  const group=Math.trunc((player.x+3-left)*3/width);
  if(group<0||group>2)return null;
  const side=Math.abs(player.x-(left+Math.trunc(group*width/3)))<10 ? 0 : 1;
  return 4+2*group+side;
}

export function actorSeat(room,w) {
  if(w[7]&32)return (w[7]>>>8)>=4 ? w[7]>>>8 : null;
  if(!(w[7]&4))return null;
  return room.fixtures.seats.find(s=>s.x===w[5]&&s.y===w[4])?.action??null;
}

export function seatOccupants(room,state) {
  const seats=Array(6).fill(0);
  if(state.tavern?.playerSeat!==null&&state.tavern?.playerSeat!==undefined)seats[state.tavern.playerSeat-4]=1;
  for(const a of state.actors)if(a.slot>1) {
    const seat=actorSeat(room,a.words);
    if(seat!==null) {
      if(seats[seat-4])throw new Error('invalidCampaign');
      seats[seat-4]=a.slot;
    }
  }
  return seats;
}
