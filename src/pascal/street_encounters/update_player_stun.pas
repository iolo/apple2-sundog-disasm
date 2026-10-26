{ game_17 procedure5, $0098..$00D0, attributes $00DA. }
procedure update_player_stun;
begin
  with g17.items[1] do
  begin
    if data29.flags82[48] then delay := 2 else delay := 10;
    g17.player_status := 1;
    if life = 0 then data29.nibbles45[1] := 12
  end
end;
