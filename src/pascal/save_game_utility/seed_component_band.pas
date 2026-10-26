{ utility_disk1:19 $078A..$084C, attributes$085A, nested in9.
  Six value words, eight locals7..14. DATA29 word90 begins at byte178.
  Both integer AND/OR expressions force the original RNG calls, including
  the discarded fifth-item test and the test when part=0. }
procedure seed_component_band(band_offset, first, second, third, end26, end27: integer);
var
  condition_total: integer;
  part_condition: integer;
  part_code: integer;
  part_index: integer;
  unused: integer;
  offset: integer;
  index: integer;
  limit: integer;
begin
  band_offset := band_offset * 28;
  condition_total := 0;
  index := 0;
  limit := 4;
  while index <= limit do
  begin
    offset := 5 * index;
    data29.bytes[178 + band_offset + offset] := 31;
    data29.bytes[178 + band_offset + offset + 1] := first;
    data29.bytes[178 + band_offset + offset + 2] := second;
    data29.bytes[178 + band_offset + offset + 3] := third;
    if odd(ord(index < 4) and ord((random_word + 0) mod 3 = 0)) then
    begin
      part_index := (random_word + 0) mod 4;
      if odd(ord(part_index = 0) or random_word) then
      begin
        if odd(random_word) then part_code := 0 else part_code := 7;
        part_condition := 0
      end
      else
      begin
        part_code := 23;
        part_condition := 3
      end;
      data29.bytes[178 + band_offset + offset + part_index] := part_code
    end
    else part_condition := 4;
    data29.bytes[178 + band_offset + offset + 4] := part_condition;
    condition_total := condition_total + part_condition;
    index := index + 1
  end;
  data29.bytes[178 + band_offset + 24] := condition_total - 4;
  data29.bytes[178 + band_offset + 25] := 0;
  data29.bytes[178 + band_offset + 26] := end26;
  data29.bytes[178 + band_offset + 27] := end27
end;
