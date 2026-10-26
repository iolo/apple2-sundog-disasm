{ utility_disk1:21 $08EA..$0A74, attributes$0A84, nested in9.
  Locals1/2 unused,3..10 saved name,11 limit. Save caption before clearing
 512 bytes at global36, then restore it. Parent slot10 is the loop counter.
  Preserve byte-write order, RNG calls and six band-initializer arguments. }
procedure util1_21;
var
  unused: array[1..2] of integer;
  caption: text15;
  limit: integer;
begin
  caption := data29.name255;
  fillchar(data29.words[36], 512, 0);
  data29.name255 := caption;
  initwork.words[10] := 0;
  limit := 3;
  while initwork.words[10] <= limit do
  begin
    data29.bytes[126 + initwork.words[10]] := (proc22_3 + 0) mod 256;
    data29.bytes[118 + initwork.words[10]] := 255;
    initwork.words[10] := initwork.words[10] + 1
  end;
  initwork.words[10] := 0;
  limit := 3;
  while initwork.words[10] <= limit do
  begin
    data29.bytes[94 + initwork.words[10] + 10] := 5;
    initwork.words[10] := initwork.words[10] + 1
  end;
  data29.bytes[108] := 1;
  data29.bytes[110] := 88;
  data29.bytes[111] := 4;
  data29.bytes[112] := 251;
  data29.bytes[113] := 185;
  data29.bytes[114] := 64;
  data29.bytes[115] := 4;
  data29.bytes[116] := 189;
  data29.bytes[117] := 243;
  data29.nibbles45[2] := 2;
  data29.nibbles45[1] := 11;
  data29.nibbles45[0] := 11;
  data29.flags45[13] := true;
  data29.flags45[12] := true;
  data29.loc37.low4 := 1;
  data29.loc37.mid5 := 1;
  data29.words[40] := 54;
  data29.bytes[80] := 110;
  data29.words[47] := (proc22_3 + 0) mod 900;
  data29.words[46] := 0;
  data29.words[203] := 3;
  data29.words[218] := data29.loc73.mid5;
  data29.flags82[7] := true;
  data29.flags82[120] := true;
  util1_19(0, 28, 26, 30, 0, 0);
  util1_19(1, 28, 30, 24, 0, 0);
  util1_19(2, 24, 26, 29, 19, 2);
  util1_19(3, 27, 25, 26, 20, 2);
  util1_19(4, 24, 28, 28, 21, 1);
  util1_19(5, 25, 27, 25, 22, 2);
  util1_20;
  initwork.words[10] := 1;
  limit := 2;
  while initwork.words[10] <= limit do
  begin
    data29.labels238[initwork.words[10]] := 'nothing';
    initwork.words[10] := initwork.words[10] + 1
  end;
  data29.bytes[507] := 17;
  data29.bytes[506] := 16
end;
