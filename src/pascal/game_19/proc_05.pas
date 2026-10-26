{ game_19 procedure5, $014C..$018C, attributes $0196.
  Capture the system row before comparisons and stores. MOV2 destinations
  precede their sources in the assembly. }
procedure proc19_5;
var
  table: g19addr;
begin
  table.word := data29.words[23];
  with table.rows^[data29.loc37.low4] do
  begin
    if proc28_6(amount6, g19.amount8) then
    begin
      g19.amount10 := amount6;
      amount6 := g19.amount8
    end
    else g19.amount10 := g19.amount8;
    proc28_2(data29.money46, g19.amount10)
  end
end;
