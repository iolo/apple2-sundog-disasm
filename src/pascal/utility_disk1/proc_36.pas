{ utility_disk1:36 $13C0..$1421, attributes$142C, nested in31.
  One value word, no locals. Space toggles shift only in unshifted mode;
  shifted nonspace subtracts32. At capacity only sound runs. }
procedure util1_36(code: integer);
begin
  if namework.length171 < 15 then
  begin
    namework.length171 := namework.length171 + 1;
    namework.namebytes[0] := namework.length171;
    if odd(namework.shift170) then
    begin
      if code <> 32 then code := code - 32;
      namework.shift170 := 0;
      proc22_19(namework.keys[2, 7].bounds, 3)
    end
    else if code = 32 then util1_35;
    namework.namebytes[namework.length171] := code;
    proc22_47(code)
  end
  else proc22_4(20, 100, 10, 0, 0, 0, 0)
end;
