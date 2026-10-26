{ game_20 procedure22, $0CE0..$0D28, attributes $0D34; nested in21.
  Scan all eight offers, comparing kind and high byte; category is ignored. }
function offer_already_listed(offer_index: integer): boolean;
var
  other_index: integer;
begin
  offer_already_listed := false;
  with g20.market_offers[offer_index] do
  begin
    other_index := 0;
    while other_index <= 7 do
    begin
      if other_index <> offer_index then
        if (kind = g20.market_offers[other_index].kind) and
           (origin = g20.market_offers[other_index].origin) then offer_already_listed := true;
      other_index := other_index + 1
    end
  end
end;
