{ game_12 procedure19, $10A8..$10EA, attributes $10F4; nested in1.
  Signed16-bit addition precedes clamping. Write VAR value before the flag. }
procedure adjust_tactical_setting(delta, setting_flag: integer; var value: integer);
begin
  if (data29.fuel_amount = 0) and (delta > 0) then
    play_sound(10, 40, 50, 0, 0, 0, 0)
  else
  begin
    delta := value + delta;
    if delta > 255 then delta := 255
    else if delta < 0 then delta := 0;
    value := delta;
    data29.flags82[setting_flag] := delta > 0
  end
end;
