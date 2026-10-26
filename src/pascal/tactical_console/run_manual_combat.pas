{ game_12 procedure17, $0F52..$0FBC, attributes $0FC8; nested in1.
  Preserve the extra input1 poll/store before clearing manual mode. }
procedure run_manual_combat;
begin
  data29.flags82[2] := true;
  g12.manual_mode := 1;
  g12.words[47] := -1;
  apply_bounds(data29.bnd343, 0);
  set_glyph_mode(1);
  repeat
    if odd(poll_input(0)) then fire_tactical_weapon;
    data29.words[354] := data29.words[354] + 1;
    tick_tactical_controls
  until odd(poll_input(1)) or odd(data29.words[347]);
  g12.manual_mode := poll_input(1);
  data29.flags82[2] := false;
  g12.manual_mode := 0;
  g12.words[47] := 0;
  if not odd(g12.target_present) then call_sky_overlay(g12.background_address, 2518)
end;
