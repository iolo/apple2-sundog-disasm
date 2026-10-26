{ startup_7 procedure6, $02C0..$0395, attributes $03A2; nested in1.
  The one-word parent pointer copy,6140-byte fill, and raw negative addresses
  are deliberate. The six-block operation at$0302 is a WRITE (flag0).
  Preserve eight120-byte copies with128-byte spacing and parent loop slot14. }
procedure proc7_6;
var
  dest: integer; {1}
  src: integer; {2}
  address: integer; {3}
  unused: integer; {4}
  limit: integer; {5}
begin
  data29.words[15] := 2048;
  data29.words[33] := 16384;
  release(data29.addr33.bytes);
  address := -5887;
  proc22_23(address, data29.words[23]);
  address := address + 240;
  proc22_23(address, data29.words[24]);
  address := address + 288;
  proc22_23(address, data29.words[25]);
  s7.memory := data29.addr33;
  proc22_53(16384 + 512, 6, data29.words[30] + 3, false);
  proc26_4(16384 + 3584, -5887, 1440);
  fillchar(s7.memory.bytes^, 6140, 0);
  proc22_53(5632, 1, data29.words[30] + 1, true);
  data29.flags82[116] := false;
  data29.flags82[117] := false;
  proc22_20(1, 1, data29.words[15]);
  proc22_20(2, 0, data29.words[16]);
  src := data29.words[16];
  dest := 1024;
  s7.words[14] := 0;
  limit := 7;
  while s7.words[14] <= limit do
  begin
    proc26_4(src + s7.words[14] * 128, dest + s7.words[14] * 128, 120);
    s7.words[14] := s7.words[14] + 1
  end
end;
