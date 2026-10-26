{ game_15 procedure8, $02E8..$0371, attributes $037C.
  Write through the EXISTING pointer26 before replacing it. Caller11 sets
  native entry7=3904, so the conditional raw call uses the reviewed screen
  initializer, with DATASEG29 word58 as its unused VAR argument. }
procedure proc15_8;
var
  block: integer;
begin
  g15.target26.text^ := '    ';
  g15.target26.word := 16384;
  proc22_53(g15.words[26], 4, data29.words[32] + 12, true);
  if odd(g15.words[11]) then callinit(data29.words[58], g15.words[7]);
  if data29.flags82[7] then block := data29.words[32]
  else block := data29.words[32] + 4;
  proc22_53(g15.words[26], 4, block, true);
  g15.target26.word := 6144;
  proc24_5;
  g15.words[13] := 22;
  proc22_18(data29.bounds327, 0, 0, 0, 0);
  proc22_18(data29.bnd307, 0, 0, 0, 0);
  proc22_18(data29.bnd303, 0, 0, 0, 0);
  proc22_19(data29.bounds7, 0);
  g15.words[7] := 5120
end;
