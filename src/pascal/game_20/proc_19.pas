{ game_20 procedure19, $0ACA..$0B5B, attributes $0B68; nested in16.
  Exhausted searches leave parent10=19 and parent9=13; no fallback invented. }
procedure proc20_19(city: integer);
var
  found: boolean;
  pmap: g19paddr;
  systems: g19addr;
begin
  srcplan := 1;
  found := false;
  while not found and (srcplan <= 18) do
  begin
    pmap.word := data29.words[24];
    with pmap.rows^[srcplan].place7 do
      if (mid6 <= city) and (city < mid6 + low9 mod 8) then found := true
      else srcplan := srcplan + 1
  end;
  srcsys := 1;
  found := false;
  while not found and (srcsys <= 12) do
  begin
    systems.word := data29.words[23];
    with systems.rows^[srcsys].bits5 do
      if (mid5 <= srcplan) and (srcplan < mid5 + low2) then found := true
      else srcsys := srcsys + 1
  end
end;
