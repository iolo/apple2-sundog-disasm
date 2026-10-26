{ game_20 procedure21, $0D36..$0F10, attributes $0F22.
  Each offer uses21 caption bytes and a two-word record. Its high byte is
  quality, whereas stock4.origin in a cargo item denotes its source city.
  Keep the final random call even in contract mode or when tries are exhausted.
  Contract wrap to kind0 still indexes levels: IXP5,3 receives -1 and the
  supplied interpreter uses quotient0/remainder1, reading bits3..5 of word0.
  Retain this unchecked operation; a bounds guard would change the original. }
procedure refresh_market_offer(slot: integer);
var
  offset, modulus, tries, used, digits, cursor, padcount: integer;
  labeltext: text15;
  levels: g20levels;
  item: stock4;
  success: boolean;
  randomv: integer;
  first: integer;
  available: integer;
  separator: integer;
(*$include src/pascal/cargo_exchange/offer_already_listed.pas*)
begin
  if slot < 0 then
  begin
    randomv := random_word;
    slot := randomv mod 8
  end;
  offset := 21 * slot;
  with g20.market_offers[slot] do
  begin
    if odd(g20.contract_mode) then
    begin
      modulus := 32;
      levels := g20.demand_levels;
      if slot > 0 then kind := g20.market_offers[slot - 1].kind else kind := 1;
      if kind < 1 then kind := 1;
      origin := 7
    end
    else
    begin
      modulus := 31;
      levels := g20.supply_levels;
      randomv := random_word;
      first := randomv mod 4 + 1;
      randomv := random_word;
      origin := first + (randomv mod 4 + 1) - 1;
      kind := random_between(1, modulus)
    end;
    tries := 32;
    repeat
      success := false;
      repeat
        kind := (kind + 1) mod modulus;
        if kind < 2 then
          if odd(g20.contract_mode) then tries := 0 else kind := 2;
        if levels.values[kind] > 0 then success := not offer_already_listed(slot)
        else tries := tries - 1
      until success or (tries <= 0);
      available := levels.values[kind];
      randomv := random_word
    until (available > randomv mod 7) or odd(g20.contract_mode) or (tries <= 0);
    item.kind := kind;
    item.category := origin;
    item.origin := 0;
    { item.word1 is left untouched; the non-selling price path does not use it. }
    if tries <= 0 then
    begin
      kind := 0;
      origin := 0;
      word1 := 0;
      padcount := 21
    end
    else
    begin
      labeltext := g20.cargo_names.names^[kind];
      used := length(labeltext);
      moveleft(labeltext[1], g20.ticker_bytes[offset], used);
      if odd(g20.contract_mode) then
      begin
        separator := 58;
        word1 := g20.demand_levels.values[kind]
      end
      else
      begin
        separator := 45;
        word1 := cargo_unit_price(item, false)
      end;
      g20.ticker_bytes[offset + used] := separator;
      used := used + 1;
      integer_to_text(word1, labeltext);
      digits := length(labeltext);
      moveleft(labeltext[1], g20.ticker_bytes[offset + used], digits);
      used := used + digits;
      offset := offset + used;
      padcount := 21 - used
    end;
    cursor := 1;
    while cursor <= padcount do
    begin
      g20.ticker_bytes[offset] := 46;
      offset := offset + 1;
      cursor := cursor + 1
    end
  end
end;
