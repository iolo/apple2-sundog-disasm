{ system4:3 $00E0..$0371, attributes$0380. No parameters,332 local bytes.
  Load optional288-byte MISCINFO and copy only words29/30, control31..36 and
  keys37..47 into the runtime configuration. Preserve all flag writes and
  registration call order. Slot160 is reused for the raw concat temporary;
  core0:23 appends to it with capacities6 then12 before the SAS6 copy. }
(*$I-*)
procedure sys4_3;
var work3: s4conf;
(*$include src/pascal/system_4/proc_04.pas*)
(*$include src/pascal/system_4/proc_05.pas*)
(*$include src/pascal/system_4/proc_06.pas*)
begin
  sys4_4(syse.name25);
  syse.powers20[0] := 1;
  syse.powers20[1] := 10;
  syse.powers20[2] := 100;
  syse.powers20[3] := 1000;
  syse.powers20[4] := 10000;
  work3.filename := '*SYSTEM.MISCINFO';
  sys6_2(s4work.words[15], nil, -1);
  sys6_4(s4work.words[15], work3.filename, 1, nil);
  if odd(s4work.words[20]) then
  begin
    unitread(s4work.words[22], work3.misc, 288, s4work.words[31], 0);
    work3.state158 := syse.state;
    work3.state158^.words[29] := work3.misc.word29;
    work3.state158^.words[30] := work3.misc.word30;
    work3.state158^.control := work3.misc.control31;
    work3.state158^.keys := work3.misc.keys37;
    sys4_4(syse.name25)
  end;
  sys6_5(s4work.words[15], 0);
  unitclear(1);
  work3.state158 := syse.state;
  work3.state158^.words[1] := 0;
  work3.state158^.words[0] := 0;
  work3.state158^.words[3] := 0;
  work3.view159.keys := @work3.state158^.keys;
  work3.index157 := 0;
  work3.words[160] := 255;
  while work3.index157 <= work3.words[160] do
  begin
    syse.flags157[work3.index157] := false;
    work3.index157 := work3.index157 + 1
  end;
  syse.flags157[work3.view159.keys^.bytes[16]] := true;
  sys4_6(0, work3.view159.keys^.bytes[7]);
  sys4_6(1, work3.view159.keys^.bytes[6]);
  sys4_6(3, work3.view159.keys^.bytes[5]);
  sys4_6(2, work3.view159.keys^.bytes[4]);
  sys4_6(11, work3.view159.keys^.bytes[12]);
  sys4_6(8, work3.view159.keys^.bytes[8]);
  sys4_6(9, work3.view159.keys^.bytes[15]);
  sys4_6(10, work3.view159.keys^.bytes[14]);
  sys4_6(13, work3.view159.keys^.words[9]);
  sys4_6(12, work3.view159.keys^.bytes[17]);
  work3.view159.control := @work3.state158^.control;
  sys4_5(0, work3.view159.control^.bytes[5]);
  sys4_5(1, work3.view159.control^.bytes[4]);
  sys4_5(2, work3.view159.control^.bytes[3]);
  sys4_5(4, work3.view159.control^.bytes[1]);
  sys4_5(3, work3.view159.control^.bytes[2]);
  sys4_5(5, work3.view159.control^.bytes[6]);
  sys4_5(6, work3.view159.control^.bytes[9]);
  sys4_5(7, work3.view159.control^.bytes[8]);
  syse.flags157[work3.view159.control^.bytes[0]] := true;
  work3.index157 := 0;
  work3.words[160] := 31;
  while work3.index157 <= work3.words[160] do
  begin
    syse.flags157[work3.index157] := true;
    work3.index157 := work3.index157 + 1
  end;
  syse.flags157[13] := false;
  syse.flags157[7] := false;
  syse.short525.text := '   ';
  if work3.view159.control^.flags5[5] then
    syse.short525.bytes[1] := work3.view159.control^.bytes[0]
  else syse.short525.bytes[1] := 0;
  syse.short525.bytes[2] := work3.view159.control^.bytes[6];
  work3.words[160] := 0;
  sys0_23(work3.temp160.words[0], syse.short525.words[0], 6);
  sys0_23(work3.temp160.words[0], syse.short525.words[0], 12);
  syse.short525.text := work3.temp160.text;
  syse.short525.bytes[0] := 5;
  syse.short521.text := syse.short525.text;
  if work3.view159.control^.bytes[3] <> 0 then syse.short521.bytes[0] := 2
end;
(*$I+*)
