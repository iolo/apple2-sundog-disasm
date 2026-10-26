{ utility_disk1:7 $18A0..$1951, attributes$1962. One Boolean parameter,
  one Boolean local. Check disk before prompting. Open a window only if this
  routine has not opened one and word20 is zero; close only that window. }
procedure util1_7(utility: boolean);
var opened: boolean;
begin
  opened := false;
  while not util1_41(utility) do
  begin
    if (not opened) and (data29.words[20] = 0) then
    begin
      opened := true;
      proc22_51(20, 12)
    end;
    proc22_44;
    proc22_48('Please flip to the \|\');
    if utility = true then proc22_48('||||UTILITY')
    else proc22_48('||||||PLAY');
    proc22_48(' SIDE\|\of the disk and press either button\|\|');
    repeat until odd(proc22_2(0) or proc22_2(1))
  end;
  if opened then proc22_52
end;
