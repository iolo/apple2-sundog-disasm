{ game_19 procedure6, $0198..$01ED, attributes $01F6.
  Original EQU12,2 compares four bytes. The two signed-word equalities here
  are equivalent bitwise equality tests without intervening side effects. }
procedure proc19_6;
var
  table: g19addr;
begin
  table.word := data29.words[23];
  with table.rows^[data29.loc37.low4] do
    if (amount6.first = g19.amount8.first) and
       (amount6.second = g19.amount8.second) then
    begin
      if proc28_6(g19.amount10, data29.money46) then
        proc28_3(data29.money46, g19.amount10)
      else
      begin
        data29.money46 := g19.amount10;
        g19.amount10 := g19.amount8
      end;
      amount6 := g19.amount10
    end
    else data29.money46 := g19.amount10
end;
