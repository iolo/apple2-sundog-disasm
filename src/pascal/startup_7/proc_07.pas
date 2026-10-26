{ startup_7 procedure7, $03A4..$0420, attributes $042C; nested in1.
  Retain26-byte frame, raw overlay call, MOV2 seed restore and five square
  probes. Any mismatch sets flag22; later matches do not clear it. }
procedure proc7_7;
var
  unused1: integer;
  unused2: integer;
  index: integer; {3}
  unused4: array[4..12] of integer;
  limit: integer; {13}
begin
  data29.words[354] := 0;
  data29.words[352] := 0;
  proc22_20(0, 0, data29.words[16]);
  callxform(data29.transform56, s7.words[7]);
  data29.words[353] := 15;
  data29.flags82[22] := false;
  if data29.flags82[7] then data29.words[294] := data29.words[296]
  else data29.words[294] := data29.words[295];
  data29.seed21 := data29.seed64;
  data29.flags82[30] := true;
  index := 1;
  limit := 5;
  while index <= limit do
  begin
    if sqr(index) <> s7.memory.bytes^[sqr(index)] then data29.flags82[22] := true;
    index := index + 1
  end
end;
