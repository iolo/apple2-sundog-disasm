{ game_20 procedure12, $06DE..$0811, attributes $0820.
  Build labels once, then repeat selection for empty entries. The empty flag
  is only assigned for positive choices; zero exits without needing its value. }
procedure proc20_12(var chosen: integer; pods: boolean; column, row: integer);
var
  index, found, selected: integer;
  empty: boolean;
begin
  proc22_14(data29.words[14], data29.words[13], row - 8, data29.words[11]);
  proc22_7(8);
  proc22_19(data29.bounds11, 0);
  data29.words[19] := column;
  data29.words[18] := row;
  if pods then
  begin
    proc22_48('Pod contents:\');
    g20.words[15] := g20.words[12] - 39
  end
  else g20.words[15] := g20.words[12] - 51;
  proc25_2;
  index := 1;
  if pods then
    while index <= 2 do
    begin
      with data29.stock234[index] do
        proc25_3(index, g20.names19.names^[kind], g20.words[14] + 4,
                  g20.words[13] - 4, g20.words[15], g20.words[15] + 9);
      g20.words[15] := g20.words[15] + 14;
      index := index + 1
    end
  else
    while index <= 4 do
    begin
      with g20.ware52[index] do
        proc25_3(index, g20.names19.names^[kind], g20.words[14] + 4,
                  g20.words[13] - 4, g20.words[15], g20.words[15] + 9);
      g20.words[15] := g20.words[15] + 14;
      index := index + 1
    end;
  repeat
    chosen := 0;
    proc20_8(chosen, found, data29.words[297], data29.bounds11, selected);
    if chosen > 0 then
    begin
      if pods then empty := data29.stock234[chosen].kind = 0
      else empty := g20.ware52[chosen].kind = 0;
      if empty then proc22_4(10, 40, 50, 0, 0, 0, 0)
    end
  until (chosen = 0) or not empty or odd(data29.words[347])
end;
