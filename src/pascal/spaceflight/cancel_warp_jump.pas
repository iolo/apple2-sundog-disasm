{ game_13 procedure34, $1716..$1754, attributes $175E; nested in27. }
procedure cancel_warp_jump;
begin
  data29.warp_destination_system := 0;
  data29.flags82[0] := false;
  data29.warp_setting := 0;
  apply_bounds(data29.bnd339, 8);
  move_pen(data29.words[342] + 2, data29.words[340] + 10);
  draw_text('Warp cancelled')
end;
