{ game_12 procedure21, $1114..$1260, attributes $1270; nested in1.
  WITH captures the cargo pointer before sound/printing. Its private slot6
  replaces original slot5 in the first loop; display still uses slot6.
  Scratch5 saves the unconditional random call, then a system-row pointer,
  then the display bound. No caller/child observes these temporary slots. }
procedure proc12_21(action: integer);
var
  removed: integer; {2}
  slot: integer; {3}
  other: integer; {4}
  scratch: g12scratch; {5}
begin
  if action > 0 then
    repeat
      slot := action;
      if slot = 3 then slot := 2;
      with data29.stock234[slot] do
      begin
        proc22_4(255, 1, 20, 0, 0, 0, 1);
        removed := kind;
        kind := 0;
        category := 0;
        origin := 1
      end;
      other := data29.stock234[3 - slot].kind;
      scratch.word := proc22_3;
      if (removed > 1) and ((other < 2) or (other = 31) or odd(scratch.word)) then
      begin
        data29.words[215] := 128;
        data29.words[207] := 1;
        scratch.word := data29.words[23] + 20 * (data29.loc73.low4 - 1);
        scratch.row^.nibbles8[7] := 0;
        data29.flags82[44] := false;
        data29.flags82[46] := true;
        data29.flags82[47] := true
      end;
      data29.labels238[slot] := '';
      action := action - 2
    until action <= 0
  else proc12_20(2, 'JETTISON');
  proc12_2;
  proc22_44;
  proc22_48('|*** BOLTS ARMED ***\|Pod contents:\|');
  slot := 1;
  scratch.word := 2;
  while slot <= scratch.word do
  begin
    with data29.stock234[slot] do
    begin
      proc22_49(slot, 1, false);
      proc22_48(':  ');
      if kind = 0 then proc22_48('nothing')
      else proc22_48(data29.labels238[slot]);
      proc22_48('\|')
    end;
    slot := slot + 1
  end;
  proc12_2
end;
