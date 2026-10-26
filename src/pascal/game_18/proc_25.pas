{ game_18 procedure 25, $1438..$148D, attributes $1498, lexical level 2.
  Complete body; depends on recovered procedures 2 and 15 and parent storage. }
procedure proc18_25;
var
  value: integer;
begin
  { $1438..$1440: DATASEG29 word82 + floor(57/16), bit 57 mod 16. }
  data29.flags82[57] := false;
  { $1441..$1447 }
  with g18items[1] do
  begin
    { $1449..$1454: the two zero words reserve the function's return storage. }
    if proc18_2(words[5], words[4], g18b103) then
    begin
      { $1456..$1463: preserve the nested subtraction before signed division. }
      value := ((words[5] - (g18w131 - 2)) div 28) + 1;
      { $1465..$1472: unequal values do NOT trigger procedure 15. }
      if value = g18w111 then
        proc18_15(g18w111, true)
    end
    else
    begin
      { $1474..$1478: native effects inside procedure 15 precede these reads. }
      proc18_15(g18w111, false);
      { $147A..$148C }
      data29.flags82[57] :=
        proc18_2(words[5], words[4], g18b99)
    end
  end
  { $148D: RNP 0. }
end;
