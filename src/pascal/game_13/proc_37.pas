{ game_13 procedure37, $1A06..$1A3D, attributes $1A48; nested in36. }
procedure proc13_37(var caption: text15; planet: integer; ismark: boolean);
begin
  if planet > 0 then caption := data29.names24.planets^[planet]
  else if ismark then caption := 'warp point'
  else caption := 'deep space'
end;
