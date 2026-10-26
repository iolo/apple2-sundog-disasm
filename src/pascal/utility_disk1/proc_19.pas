{ utility_disk1:19 $078A..$084C, attributes$085A, nested in9.
  Six value words, eight locals7..14. DATA29 word90 begins at byte178.
  Both integer AND/OR expressions force the original RNG calls, including
  the discarded fifth-item test and the test when part=0. }
procedure util1_19(band, first, second, third, end26, end27: integer);
var
  total: integer;
  level: integer;
  replacement: integer;
  part: integer;
  unused: integer;
  offset: integer;
  index: integer;
  limit: integer;
begin
  band := band * 28;
  total := 0;
  index := 0;
  limit := 4;
  while index <= limit do
  begin
    offset := 5 * index;
    data29.bytes[178 + band + offset] := 31;
    data29.bytes[178 + band + offset + 1] := first;
    data29.bytes[178 + band + offset + 2] := second;
    data29.bytes[178 + band + offset + 3] := third;
    if odd(ord(index < 4) and ord((proc22_3 + 0) mod 3 = 0)) then
    begin
      part := (proc22_3 + 0) mod 4;
      if odd(ord(part = 0) or proc22_3) then
      begin
        if odd(proc22_3) then replacement := 0 else replacement := 7;
        level := 0
      end
      else
      begin
        replacement := 23;
        level := 3
      end;
      data29.bytes[178 + band + offset + part] := replacement
    end
    else level := 4;
    data29.bytes[178 + band + offset + 4] := level;
    total := total + level;
    index := index + 1
  end;
  data29.bytes[178 + band + 24] := total - 4;
  data29.bytes[178 + band + 25] := 0;
  data29.bytes[178 + band + 26] := end26;
  data29.bytes[178 + band + 27] := end27
end;
