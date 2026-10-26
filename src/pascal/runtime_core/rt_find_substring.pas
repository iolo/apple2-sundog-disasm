{ system_core0:27 $06EA..$0745, attributes$0752. Parameters: needle4,
  source3, result1/2; locals5 limit,6 index,7 first character,8..48 temporary;
  RBP1. Needle is a borrowed string pointer, with NO entry value copy.
  Only the temporary length byte is initialized before scanning.
  SunDog CSP11 scans through the inclusive endpoint and returns displacement;
  a miss can still lead to comparison at the final candidate. Preserve this
  SCAN call and subsequent copy/compare, not a host POS replacement.
  Original temporary capacity80 is retained without adding a length guard.
  s exposes caller bytes; it is an extra source-level pointer, not a copy. }
function rt_find_substring(var needle: text80; var source: integer): integer;
label 999;
var limit, index, firstchar: integer;
    temp: s0str80;
    s: s0strptr;
begin
  s.word := @source;
  rt_find_substring := 0;
  if length(needle) > 0 then
  begin
    firstchar := ord(needle[1]);
    index := 1;
    limit := s.bytes^[0] - length(needle) + 1;
    temp.bytes[0] := length(needle);
    while index <= limit do
    begin
      index := index + scan(limit - index, = chr(firstchar), s.bytes^[index]);
      if index > limit then goto 999;
      moveleft(s.bytes^[index], temp.bytes[1], length(needle));
      if temp.text = needle then
      begin
        rt_find_substring := index;
        goto 999
      end;
      index := index + 1
    end
  end;
999:
end;
