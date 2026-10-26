{ game_13 procedure42, $1FFC..$201D, attributes $2028; nested in1.
  raw13 denotes the entry's eight local words. Copy the value caption before
  reading the parent's bounds, then advance parent slot6 after the menu call. }
procedure proc13_42(code: integer; caption: text15);
begin
  proc25_3(code, caption, raw13[8], raw13[7], raw13[6], raw13[6] + 10);
  raw13[6] := raw13[6] + 15
end;
