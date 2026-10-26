{ utility_disk1:34 $1352..$1391, attributes$139C, nested in31.
  One VAR Boolean, no locals. Cancel only if already empty; otherwise blank
  the last byte, reduce count/length byte, and erase one displayed character. }
procedure util1_34(var active: boolean);
begin
  if namework.length171 > 0 then
  begin
    namework.namebytes[namework.length171] := 32;
    namework.length171 := namework.length171 - 1;
    namework.namebytes[0] := namework.length171;
    data29.words[19] := data29.words[19] - 6;
    proc22_47(32);
    data29.words[19] := data29.words[19] - 6
  end
  else active := false
end;
