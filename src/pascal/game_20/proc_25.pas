{ game_20 procedure25, $147A..$1514, attributes $1520.
  Retain the bonus accumulator snapshot before price/shift calls. The initial
  unused paid value and message word are not given invented initial values. }
procedure proc20_25;
var
  slot, cursor, message: integer;
  amount: wordpair;
  item: stock4;
  caption: g20text;
  before: integer;
  price: integer;
begin
  proc20_24(item, slot, amount, true);
  if slot = 0 then exit(proc20_25);
  proc22_44;
  proc20_23(slot, item, caption, amount, true, message);
  if amount <> g20.zero160 then
  begin
    proc20_20(item.kind, true);
    if odd(g20.words[16]) then
    begin
      before := g20.words[2];
      price := proc20_16(item, true);
      g20.words[2] := before + proc22_31(price, 2);
      proc20_4;
      cursor := 0;
      while cursor <= 7 do
      begin
        proc20_21(cursor);
        cursor := cursor + 1
      end
    end
    else proc28_2(amount, g20.cash164);
    fillchar(item, 4, 0);
    if slot > 4 then data29.stock234[slot - 4] := item
    else g20.ware52[slot] := item
  end
end;
