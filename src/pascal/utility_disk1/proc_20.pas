{ utility_disk1:20 $085C..$08D8, attributes$08E8, nested in9.
  Three locals1 index,2 base,3 limit. Preserve partial writes to bands6/7. }
procedure util1_20;
var
  index: integer;
  base: integer;
  limit: integer;
begin
  base := 6 * 28;
  index := 15;
  limit := 19;
  while index <= limit do
  begin
    data29.bytes[178 + base + index] := 23;
    index := index + 1
  end;
  data29.bytes[178 + base + 24] := 13 + (proc22_3 + 0) mod 4;
  base := 7 * 28;
  index := 0;
  limit := 4;
  while index <= limit do
  begin
    data29.bytes[178 + base + index] := 10;
    index := index + 1
  end;
  index := 5;
  limit := 9;
  while index <= limit do
  begin
    data29.bytes[178 + base + index] := 8;
    index := index + 1
  end;
  data29.bytes[178 + base + 10] := 11 + 224;
  data29.bytes[178 + base + 11] := 12
end;
