{ startup_7 procedure5, $0142..$02B4, attributes $02BE; nested in1.
  Retain three unused local words. Library26 is recovered source; load of
  raw transform precedes switching to the play disk and graphics setup. }
procedure proc7_5;
var unused: array[1..3] of integer;
begin
  data29.words[32] := 26;
  data29.words[30] := data29.words[32] + 16;
  data29.words[29] := data29.words[30] + 10;
  data29.words[28] := data29.words[29] + 9;
  data29.words[27] := data29.words[28] + 15;
  data29.words[26] := data29.words[27] + 9;
  proc22_18(data29.bounds7, 0, 279, 0, 191);
  proc22_18(data29.bounds3, 0, 139, 0, 95);
  proc22_17(true);
  proc22_19(data29.bounds3, 8);
  proc22_17(false);
  data29.words[1] := 0;
  proc22_13(0);
  proc22_12(0, 0);
  proc22_11(0);
  proc22_16(0, 0);
  proc22_53(s7.words[7], 1, s7.words[4], true);
  data29.words[16] := 4096;
  proc22_20(0, 0, data29.words[16]);
  proc26_6(true);
  proc7_3(false);
  proc22_52;
  proc22_18(data29.bnd299, 72, 235, 0, 7);
  proc22_18(data29.bnd343, 84, 223, 8, 103);
  proc22_18(data29.bnd339, 4, 274, 120, 187);
  proc22_18(data29.bnd335, 4, 71, 18, 115);
  proc22_18(data29.bnd331, 236, 274, 18, 115);
  proc22_18(data29.bnd307, 245, 265, 4, 13);
  proc22_18(data29.bnd303, 14, 62, 4, 13);
  proc22_18(data29.bounds327, 0, 0, 0, 0);
  proc22_18(data29.bnd323, data29.words[334] + 2, data29.words[334] + 8,
              data29.words[331] - 97, data29.words[331] - 33);
  proc22_18(data29.bnd319, data29.words[334] + 12, data29.words[334] + 18,
              data29.words[331] - 97, data29.words[331] - 33);
  proc22_18(data29.bnd315, data29.words[334] + 22, data29.words[334] + 28,
              data29.words[331] - 97, data29.words[331] - 33);
  proc22_18(data29.bnd311, data29.words[334] + 32, data29.words[334] + 38,
              data29.words[331] - 97, data29.words[331] - 33)
end;
