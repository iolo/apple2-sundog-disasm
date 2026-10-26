{ game_21 procedure30, $133C..$159C, attributes $15AE.
  Check one eight-block group with at most two reads; a persistent checksum
  failure displays the error code then loops forever, as at $1401.
  Shared modes/flags and VAR parameters are reread after calls and stores. }
procedure proc21_30;
label 1;
var
  checkptr: address16;  {slot1}
  attempts: integer;   {2}
  block: integer;      {3}
  system: g19addr;     {4}
begin
  proc22_21(data29.words[16], false);
  proc22_18(g21.area62, data29.words[10] + 4, data29.words[9] - 4,
                        data29.words[8] + 4, data29.words[7] - 4);
  if odd(arg1) then data29.nibbles45[1] := data29.nibbles45[2];
  if data29.nibbles45[2] = 3 then
  begin
    if data29.nibbles45[1] = 2 then
    begin
      g21.words[9] := 6144;
      block := data29.bytes[540];
      attempts := 2;
      proc22_23(g21.words[9] + proc22_31(data29.bytes[540], 2), checkptr.word);
      proc22_53(g21.words[9], 1, data29.words[30] + 9, true);
      repeat
        proc22_53(16384, 8, block - 3, true);
        callck21(g21.words[32], g21.words[9] + 64);
        attempts := attempts - 1
      until (checkptr.value^ = g21.words[32]) or (attempts <= 0);
      if checkptr.value^ <> g21.words[32] then
      begin
        proc22_19(data29.bounds7, 8);
        proc22_12(0, 10);
        proc22_39(117 + proc22_31(block, 3), 4, false);
1:      goto 1
      end;
      block := block + 8;
      if block = 48 then block := 56;
      data29.bytes[540] := block;
      proc22_23(20480, checkptr.word);
      fillchar(checkptr.bytes^, 2048, data29.words[293])
    end;
    if data29.bits73.mid6 = data29.bits37.mid6 then
    begin
      g21.words[17] := data29.pos72.fields.kind2;
      g21.words[16] := data29.pos72.fields.kind3;
      g21.words[15] := data29.words[76] mod 28;
      g21.words[14] := data29.pos72.fields.w5low mod 32
    end
    else
    begin
      g21.words[17] := -1;
      g21.words[16] := -1;
      g21.words[15] := -1;
      g21.words[14] := -1
    end;
    if (data29.pos228.fields.city = data29.bits37.mid6) and
       not data29.flags82[7] and data29.flags45[13] then
    begin
      g21.words[13] := data29.pos228.fields.kind2;
      g21.words[12] := data29.pos228.fields.kind3;
      g21.words[11] := data29.words[232] mod 28;
      g21.words[10] := data29.pos228.fields.w5low mod 32
    end
    else
    begin
      g21.words[13] := -1;
      g21.words[12] := -1;
      g21.words[11] := -1;
      g21.words[10] := -1
    end
  end;
  system.word := data29.words[23] + 20 * (data29.loc37.low4 - 1);
  g21.words[61] := system.rows^[1].nibbles8[3];
  g21.words[60] := system.rows^[1].nibbles8[4];
  g21.words[59] := system.rows^[1].nibbles8[5];
  proc21_23;
  g21.words[33] := ord(data29.nibbles45[2] = 4);
  if odd(g21.words[33]) then proc21_29 else proc21_27;
  g21.words[58] := data29.words[353];
  data29.words[353] := 15;
  g21.words[57] := data29.words[351];
  data29.words[351] := 1;
  proc21_25;
  data29.words[2] := 9;
  data29.nibbles45[1] := data29.nibbles45[2];
  data29.flags45[12] := data29.flags45[13];
  proc22_42(g21.words[19], g21.words[18], data29.words[298], g21.area62);
  arg1 := 0;
  arg2 := 0;
  g21.words[38] := proc22_2(4);
  g21.words[38] := proc22_2(0);
  g21.words[38] := 0;
  g21.words[34] := 0;
  data29.flags82[28] := false;
  g21.words[28] := 32767;
  g21.words[27] := 32767
end;
