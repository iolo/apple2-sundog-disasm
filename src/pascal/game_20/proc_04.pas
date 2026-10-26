{ game_20 procedure4, $00A0..$01F2, attributes $0202.
  CSP11 at E6CF scans for a nonzero byte. Continue only when all14 bytes
  were zero, including padding. Phase9 exits before updating phase bytes. }
procedure proc20_4;
var
  phase, index, item: integer;
  phases: g20phases;
begin
  if scan(14, <> chr(0), g20.stock22.bytes) <> 14 then exit(proc20_4);
  phase := data29.bytes[542];
  if phase > 0 then
  begin
    proc22_44;
    proc22_48('|\|\|\|Phase ');
    proc22_49(phase, 1, false);
    proc22_48(' now complete\|');
    data29.flags82[114] := true;
    if phase = 9 then
    begin
      proc22_48('||You have fulfilled your contract.');
      data29.nibbles45[2] := 13;
      data29.nibbles45[1] := 13;
      proc20_2;
      exit(proc20_4)
    end;
    if phase > 0 then
    begin
      proc28_4(g20.bonus162, g20.words[2] div 10, 100 * (g20.words[2] mod 10));
      proc28_2(g20.bonus162, g20.cash164);
      proc28_5('Bonus paid: ', g20.bonus162);
      g20.words[2] := 0;
      proc22_48('||Starting Phase ');
      proc22_49(phase + 1, 1, false);
      proc20_2
    end
  end;
  data29.bytes[541] := phase;
  data29.bytes[542] := phase + 1;
  moveleft(g20.addr20.bytes^, phases, 54);
  index := 0;
  while index <= 7 do
  begin
    item := phases[phase][index];
    if item > 0 then g20.stock22.values[item] := g20.stock22.values[item] + 1;
    index := index + 1
  end
end;
