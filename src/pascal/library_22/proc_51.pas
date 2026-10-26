{ library_22 procedure 51, $0A9A..$0B21, attributes $0B2C.
  Counter and buffer accesses are reread in their original order. }
procedure proc22_51(firstarg, secondarg: integer);
var
  secondpos, firstpos: integer;
begin
  if data29.words[20] > 1 then exit(proc22_51);
  if data29.words[20] > 0 then proc22_63(true);
  data29.words[20] := data29.words[20] + 1;
  proc22_17(true);
  proc22_19(data29.bounds3, 11);
  proc22_14(data29.words[6] + 2, data29.words[5] - 2,
            data29.words[4] + 1, data29.words[3] - 1);
  proc22_7(8);
  firstpos := firstarg - 10;
  proc22_37(1, firstpos, 19);
  secondpos := secondarg * 8 - 48;
  proc22_37(7, secondpos, 88);
  data29.addr373.bytes^[2000] := firstpos;
  data29.addr373.bytes^[2001] := secondpos;
  proc22_16(secondpos, firstpos);
  proc22_50(firstpos * 7 + 2, firstpos * 7 + 137,
            secondpos + 2, secondpos + 93);
  proc22_15(1);
  proc22_17(false)
end;
