{ utility_disk1:23 $0AA2..$0AE9, attributes$0AF4. Parameters2 index,1 mode;
  locals3 value,4 bar pointer. Bounds are addressed again for the initial clear. }
procedure util1_23(index, mode: integer);
var
  value: integer;
  bar: ^bounds4;
begin
  bar := @attrwork.bars[index];
  value := data29.bytes[94 + index];
  proc22_19(attrwork.bars[index], 8);
  if value > 0 then
  begin
    proc22_14(bar^.lower_first, bar^.lower_first + value,
              bar^.lower_second, bar^.upper_second);
    proc22_7(mode)
  end;
  proc22_19(data29.bounds11, 0);
  proc22_12(bar^.upper_first + 8, bar^.lower_second - 2);
  proc22_39(value, 3, false)
end;
