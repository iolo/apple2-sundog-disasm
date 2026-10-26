{ game_20 procedure22, $0CE0..$0D28, attributes $0D34; nested in21.
  Scan all eight offers, comparing kind and high byte; category is ignored. }
function proc20_22(searchidx: integer): boolean;
var
  scanidx: integer;
begin
  proc20_22 := false;
  with g20.offers144[searchidx] do
  begin
    scanidx := 0;
    while scanidx <= 7 do
    begin
      if scanidx <> searchidx then
        if (kind = g20.offers144[scanidx].kind) and
           (origin = g20.offers144[scanidx].origin) then proc20_22 := true;
      scanidx := scanidx + 1
    end
  end
end;
