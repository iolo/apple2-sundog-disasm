{ game_12 procedure19, $10A8..$10EA, attributes $10F4; nested in1.
  Signed16-bit addition precedes clamping. Write VAR value before the flag. }
procedure proc12_19(delta, flag: integer; var value: integer);
begin
  if (data29.words[227] = 0) and (delta > 0) then
    proc22_4(10, 40, 50, 0, 0, 0, 0)
  else
  begin
    delta := value + delta;
    if delta > 255 then delta := 255
    else if delta < 0 then delta := 0;
    value := delta;
    data29.flags82[flag] := delta > 0
  end
end;
