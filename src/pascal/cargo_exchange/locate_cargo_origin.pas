{ game_20 procedure19, $0ACA..$0B5B, attributes $0B68; nested in16.
  Exhausted searches leave parent10=19 and parent9=13; no fallback invented. }
procedure locate_cargo_origin(origin_city: integer);
var
  found: boolean;
  pmap: g19paddr;
  systems: g19addr;
begin
  origin_planet := 1;
  found := false;
  while not found and (origin_planet <= 18) do
  begin
    pmap.word := data29.words[24];
    with pmap.rows^[origin_planet].place7 do
      if (mid6 <= origin_city) and (origin_city < mid6 + low9 mod 8) then found := true
      else origin_planet := origin_planet + 1
  end;
  origin_system := 1;
  found := false;
  while not found and (origin_system <= 12) do
  begin
    systems.word := data29.words[23];
    with systems.rows^[origin_system].bits5 do
      if (mid5 <= origin_planet) and (origin_planet < mid5 + low2) then found := true
      else origin_system := origin_system + 1
  end
end;
