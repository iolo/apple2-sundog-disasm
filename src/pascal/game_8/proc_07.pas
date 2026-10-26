{ game_8 procedure 7, $017E..$0249, attributes $0258.
  Saves/restores only the four bounds words; other drawing state is retained. }
procedure proc8_7;
var
  saved: bounds4;
  index, firstpos: integer;
  labeltxt: string[6];
begin
  saved := data29.bounds11;
  proc22_50(g8b38.lower_first, g8b38.upper_first,
            g8b38.lower_second, g8b38.upper_second);
  proc22_44;
  proc22_48('|Condition');
  proc22_45;
  proc22_45;
  index := 0;
  while index <= 3 do
  begin
    labeltxt := copy('Vigor Rest  HealthNoursh', index * 6 + 1, 6);
    proc22_48(labeltxt);
    firstpos := 7 * ((data29.words[19] + 6) div 7);
    proc22_18(g8bars[index], firstpos, firstpos + 32,
              data29.words[18] - 6, data29.words[18] - 1);
    proc22_45;
    if index = 0 then data29.words[18] := data29.words[18] + 4;
    index := index + 1
  end;
  index := 0;
  while index <= 3 do
  begin
    proc8_2(index);
    index := index + 1
  end;
  proc8_6(g8b26, 'Sleep');
  data29.bounds11 := saved;
  g8a3[15] := 1
end;
