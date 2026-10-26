{ startup_7 procedure7, $03A4..$0420, attributes $042C; nested in1.
  Retain26-byte frame, raw overlay call, MOV2 seed restore and five square
  probes. Any mismatch sets flag22; later matches do not clear it. }
procedure restore_play_state;
var
  unused1: integer;
  unused2: integer;
  probe_index: integer; {3}
  unused4: array[4..12] of integer;
  last_probe: integer; {13}
begin
  data29.words[354] := 0;
  data29.words[352] := 0;
  load_buffer_pair(0, 0, data29.words[16]);
  call_state_transform(data29.transform56, s7.words[7]);
  data29.words[353] := 15;
  data29.flags82[22] := false;
  if data29.flags82[7] then data29.words[294] := data29.words[296]
  else data29.words[294] := data29.words[295];
  data29.seed21 := data29.seed64;
  data29.flags82[30] := true;
  probe_index := 1;
  last_probe := 5;
  while probe_index <= last_probe do
  begin
    if sqr(probe_index) <> s7.memory.bytes^[sqr(probe_index)] then data29.flags82[22] := true;
    probe_index := probe_index + 1
  end
end;
