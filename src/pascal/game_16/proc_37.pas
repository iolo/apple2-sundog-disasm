{ game_16 procedure37, $13E4..$171C, attributes $172A.
  Keep48 local bytes. The captured system-row pointer uses compiler slot24;
  formerly unused slots hold the address view and loop bound. Trailing equal
  table offsets are scanned without a lower bound, as in the original. }
procedure proc16_37;
var
  table: g16addr;
  unused2: integer;
  unused3: integer;
  unused4: integer;
  unused5: integer;
  index: integer;
  lastbyte: integer;
  stopidx: integer;
  unused9: array[9..23] of integer;
(*$include src/pascal/game_16/proc_38.pas*)
(*$include src/pascal/game_16/proc_39.pas*)
begin
  fillchar(g16.words[53], 6, chr(0));
  g16.words[8] := data29.words[26];
  g16.words[9] := g16.words[8] + 2;
  g16.saved64 := data29.bounds11;
  g16.saved56 := data29.bounds327;
  proc22_18(data29.bounds327, 0, 0, 0, 0);
  g16.words[42] := data29.words[353];
  data29.words[353] := 150;
  g16.words[45] := data29.words[351];
  data29.words[351] := 1;
  proc28_4(g16.fund102, 0, 0);
  g16.price106 := g16.fund102;
  g16.fund100 := g16.fund102;
  g16.words[22] := 0;
  g16.words[18] := 0;
  g16.text108 := '';
  g16.caption124 := '';
  g16.words[14] := 0;
  g16.words[15] := 0;
  table.word := data29.words[23];
  with table.rows^[data29.loc37.low4] do
  begin
    g16.words[16] := ord(bits5.flag7);
    g16.words[32] := nibbles8[3];
    g16.words[30] := nibbles8[4];
    g16.words[31] := nibbles8[5];
    g16.words[29] := nibbles8[7]
  end;
  if not odd(arg3) then arg3 := arg3 + proc22_34(20 - arg3);
  proc22_51(arg3, arg2);
  data31.words[12] := 7 * (data29.words[14] div 7);
  data31.words[11] := 8 * (data29.words[12] div 8);
  proc27_13(1);
  g16.words[34] := data31.words[16];
  proc22_18(g16.dialog60, data31.words[12] + 39, data31.words[12] + 133,
              data31.words[11] + 2, data31.words[11] + 80);
  proc22_19(g16.dialog60, 8);
  proc22_18(g16.panel68, data31.words[12] + 39, data31.words[12] + 133,
              data31.words[11] + 32, data31.words[11] + 80);
  proc22_19(g16.panel68, 8);
  data29.flags82[117] := false;
  g16.words[20] := ord(data29.bytes[552] <> 0);
  g16.words[33] := data29.bytes[549];
  g16.words[87] := 11 + (16 - g16.words[32]) div 6;
  g16.words[88] := 15 + (16 - g16.words[32]) div 2;
  g16.words[89] := 23 + 2 * ((g16.words[31] - 1) div 3);
  proc16_38(88, 89, 8, 9);
  if data29.bytes[544] <> data29.pos36.fields.city then
  begin
    data29.flags82[80] := (data29.clock42.hour < 3) or (data29.clock42.hour > 6);
    proc16_38(90, 94, 10, g16.words[87]);
    proc16_38(95, 102, 15, g16.words[88]);
    proc16_38(103, 111, 23, g16.words[89]);
    data29.bytes[544] := data29.pos36.fields.city
  end;
  proc22_18(g16.buttons72[2], g16.words[71] + 2, g16.words[70] - 2,
              g16.words[68] - 14, g16.words[68] - 2);
  proc22_18(g16.buttons72[1], g16.words[71] + 2, g16.words[70] - 2,
              g16.words[68] - 30, g16.words[68] - 18);
  proc22_18(g16.buttons72[0], g16.words[71] + 2, g16.words[70] - 2,
              g16.words[69] + 2, g16.words[68] - 34);
  data29.flags82[117] := false;
  proc22_23(18432, g16.source140.word);
  proc22_23(18432 + 512, g16.table141.word);
  proc22_53(18432 + 512, 2, g16.words[8], true);
  g16.words[47] := 0;
  proc16_31(0, 0, 0);
  index := 64;
  lastbyte := g16.table141.bytes^[index];
  while lastbyte = g16.table141.bytes^[index - 1] do index := index - 1;
  g16.words[26] := index;
  g16.words[39] := -1;
  g16.words[7] := 0;
  g16.words[6] := 0;
  index := 0;
  stopidx := 3;
  while index <= stopidx do
  begin
    if data29.bytes[122 + index] = 12 then g16.words[7] := g16.words[7] + 1
    else if proc22_32(data29.bytes[122 + index], 31) = 13 then
      g16.words[7] := g16.words[7] + 2
    else if proc22_32(data29.bytes[122 + index], 31) = 11 then
      g16.words[6] := g16.words[6] + 2;
    index := index + 1
  end;
  proc27_6(0);
  g16.words[40] := g16.words[30];
  proc16_39;
  proc22_11(1);
  proc22_42(g16.words[13], g16.words[12], 2, data31.bounds2);
  g16.words[24] := 0
end;
