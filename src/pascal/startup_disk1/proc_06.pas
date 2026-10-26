{ startup_disk1 procedure6, entry$0182, body$0184..$01CB,
  load$01D3..$01D6, release$01CE, RNP$01D8, attributes$01E6.
  Retain unused local word. MARK saves heap pointer in35 then34; RELEASE
  installs$4000. Header byte6 minus3 selects the raw screen-init block.
  This is a repeat loop even when initial state is already>=11.
  Nonlocal EXIT must enter the segment22 release epilogue at$01CE. }
procedure boot1_6;
var unused: integer;
begin
  rtldseg(22);
  mark(data29.text35.text);
  mark(data29.addr34.bytes);
  data29.words[33] := 16384;
  release(data29.addr33.bytes);
  proc22_53(16384, 1, 80, true);
  proc22_54(data29.addr33.bytes^[6] - 3);
  proc7_1(true);
  repeat
    if data29.nibbles45[2] <= 2 then boot1_3
    else boot1_4
  until data29.nibbles45[2] >= 11;
  proc7_1(false);
  rtrlseg(22)
end;
