{ startup_7 procedure4, $00E2..$0135, attributes $0140; nested in1.
  Ordered global initialization and the parent's raw-overlay load parameters. }
procedure reset_game_runtime;
begin
  data29.words[293] := 0;
  data29.words[297] := 1;
  data29.words[298] := 2;
  data29.words[296] := 8;
  data29.words[295] := 9;
  data29.words[350] := 0;
  data29.words[349] := 0;
  data29.words[347] := 0;
  data29.words[292] := 0;
  data29.words[354] := 0;
  data29.words[352] := 0;
  data29.words[353] := 5;
  data29.words[351] := 1;
  s7.words[7] := 3904;
  s7.words[6] := 32767;
  s7.words[4] := 153
end;
