{ game_12 procedure18, $0FCA..$1096, attributes $10A6; nested in1.
  Original $0FCF..$0FE1 reads cargo kind BEFORE checking slot>0. With both
  pods occupied it reads index0 (word232). Disable range checks and retain
  this order; do not add a guard or a stop-flag exit to the tractor loop. }
procedure proc12_18;
var slot: integer;
begin
  proc12_2;
  slot := 2;
  while (data29.stock234[slot].kind > 0) and (slot > 0) do slot := slot - 1;
  proc22_44;
  if not odd(g12.words[27]) then proc22_48('Out of range')
  else if slot = 0 then proc22_48('No room')
  else
  begin
    proc22_48('Activating tractor\');
    data29.words[207] := -4;
    proc12_2;
    repeat
      data29.words[354] := data29.words[354] + 1;
      proc12_12
    until data29.words[217] = 1;
    proc12_2;
    proc22_48('Cargo loaded');
    data29.stock234[slot] := g12.cargo34;
    data29.labels238[slot] := 'Unknown';
    g12.words[27] := 0;
    data29.flags82[36] := false
  end;
  proc12_2
end;
