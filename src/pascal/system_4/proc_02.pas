{ system4:2 $0000..$0053, attributes$005E. No parameters,752 local bytes.
  Initialize file3 with buffer303 and kind-1. Read fixed-address byte>$7F
  before opening SYSTEM.CHARSET; preserve the result store into slot43.
  The conditional close at$0047 is followed by the unconditional close$004D,
  which is also the original nonlocal-exit cleanup target. Core callees are
  recovered; their identifiers retain segment/procedure identity. }
procedure sys4_2;
var work2: s4load;
begin
  sys0_3(work2.words[3], work2.buffer[0], -1);
  work2.flagptr.word := -16606;
  if work2.flagptr.bytes^[0] > 127 then
  begin
    sys0_5(work2.words[3], 'SYSTEM.CHARSET', 1, nil);
    work2.target.word := 2048;
    work2.words[43] := sys0_28(work2.words[3], work2.target.bytes, 0, 2, -1, true);
    sys0_6(work2.words[3], 0)
  end;
  sys0_6(work2.words[3], 0)
end;
