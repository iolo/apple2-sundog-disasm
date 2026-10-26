{ game_8 procedure16, $07C4..$0934, attributes $0942.
  save is a one-word VAR flag, represented as integer to alias parent slot19.
  Its writes are 0/1; tests retain the interpreter's low-bit convention. }
procedure proc8_16(var save: integer);
var
  saved: bounds4;
  secondpos: integer;
  firstpos: integer;
  enabled: boolean;
  toggled: boolean;
  cancel: integer;
  hit: boolean;
begin
  saved := data29.bounds11;
  proc22_50(g8b38.lower_first, g8b38.upper_first,
            g8b38.lower_second, g8b38.upper_second);
  proc22_44;
  proc22_48('The game is frozen.');
  enabled := not data29.flags45[13] or (data29.nibbles45[1] <> 5);
  if enabled then proc8_6(g8b22, 'Save game');
  proc22_42(firstpos, secondpos, data29.words[297], data29.bounds11);
  save := 0;
  cancel := 0;
  repeat
    proc22_41(firstpos, secondpos);
    if data29.flags82[122] then proc8_6(g8b26, 'Sound is off')
    else proc8_6(g8b26, 'Sound is on');
    proc22_41(firstpos, secondpos);
    toggled := false;
    repeat
      proc22_43(firstpos, secondpos);
      if odd(proc22_2(0)) then begin
        hit := proc8_5(firstpos, secondpos, g8b22);
        save := ord(hit and enabled);
        toggled := proc8_5(firstpos, secondpos, g8b26)
      end else cancel := proc22_2(1)
    until odd(save) or odd(cancel) or toggled;
    if odd(save) then proc22_19(g8b22, 3)
    else if toggled then begin
      proc22_19(g8b26, 3);
      data29.flags82[122] := not data29.flags82[122]
    end
  until odd(save) or odd(cancel);
  proc22_41(firstpos, secondpos);
  if odd(save) then begin
    data29.nibbles45[2] := 11;
    if data29.nibbles45[1] = 5 then begin
      if data29.nibbles45[0] = 11 then begin
        if data29.bits37.mid6 = 0 then data29.nibbles45[0] := 4
        else data29.nibbles45[0] := 3
      end;
      data29.nibbles45[1] := data29.nibbles45[0]
    end;
    proc22_52;
    exit(proc8_1)
  end;
  proc22_44;
  proc8_7;
  proc22_50(saved.lower_first, saved.upper_first,
            saved.lower_second, saved.upper_second)
end;
