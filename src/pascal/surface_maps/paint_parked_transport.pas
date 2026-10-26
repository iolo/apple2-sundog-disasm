{ game_21 procedure8, $0268..$0293, attributes $029C. }
procedure paint_parked_transport;
begin
  if data29.nibbles45[2] = 3 then
    if data29.flags45[13] and not data29.flags82[7] then
      draw_parked_marker(data29.pos228, data29.bytes[507], false)
end;
