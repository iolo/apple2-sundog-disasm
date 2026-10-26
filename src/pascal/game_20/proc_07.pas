{ game_20 procedure7, $0442..$0508, attributes $0512.
  Preserve disk operation order and the final bank pointer re-evaluation. }
procedure proc20_7;
var
  city: integer;
  systems: g19addr;
begin
  if odd(g20.words[16]) then moveleft(g20.words[2], data29.bytes[546], 2);
  city := data29.bits37.mid6 - 1;
  g20.ptr18.rows^[city] := g20.ware52;
  proc22_53(5120, 2, data29.words[30] + 3, false);
  proc22_53(5120 + 512, 1, data29.words[30] + 1, true);
  g20.addr21.word := 22528 + 1024;
  proc20_3(data29.words[30] + 5 + city div 16, 32, city mod 16, 3);
  systems.word := data29.words[23];
  if proc28_6(g20.zero160, systems.rows^[data29.loc37.low4].amount6) then
    data29.money46 := g20.cash164
  else
  begin
    if proc28_6(g20.cash164, data29.money46) then
      proc28_3(data29.money46, g20.cash164)
    else
    begin
      data29.money46 := g20.cash164;
      g20.cash164 := g20.zero160
    end;
    systems.word := data29.words[23];
    systems.rows^[data29.loc37.low4].amount6 := g20.cash164
  end
end;
