{ game_20 procedure23, $0F24..$1244, attributes $1256.
  All outputs except selling are VAR. Buying requires cash strictly greater
  than the offer, not greater-or-equal. Caption padding writes bytes directly. }
procedure proc20_23(var slot: integer; var item: stock4; var caption: g20text;
                    var amount: wordpair; selling: boolean; var message: integer);
var
  valid, affordable: boolean;
  tries, negotiable, cursor, value, textlen, choice, found, selected: integer;
  paid: wordpair;
begin
  valid := false;
  tries := 0;
  negotiable := 1;
  repeat
    if selling then
    begin
      cursor := item.kind;
      valid := true
    end
    else
    begin
      if tries > 0 then slot := (slot + 1) mod 8;
      with g20.offers144[slot] do
      begin
        proc28_4(amount, word1 div 10, 100 * (word1 mod 10));
        affordable := proc28_6(g20.cash164, amount);
        valid := affordable and (kind > 0)
      end;
      tries := tries + 1
    end
  until valid or (tries = 8);
  if not valid then
  begin
    proc22_44;
    if odd(message) then proc22_48('No goods available or affordable');
    message := 0;
    amount := g20.zero160;
    fillchar(item, 4, 0);
    caption.text := g20.names19.names^[0];
    proc20_2;
    exit(proc20_23)
  end;
  message := 0;
  if not selling then
    with g20.offers144[slot] do
    begin
      item.kind := kind;
      item.category := origin;
      item.origin := data29.bits37.mid6;
      item.word1 := word1
    end
  else if not odd(g20.words[16]) then
    if (item.kind = 1) or (item.kind = 31) then negotiable := 0
    else
    begin
      value := proc20_16(item, true);
      proc28_4(amount, value div 10, 100 * (value mod 10))
    end;
  caption.text := g20.names19.names^[item.kind];
  textlen := length(caption.text);
  cursor := textlen + 1;
  while cursor <= 14 do
  begin
    caption.bytes[cursor] := 32;
    cursor := cursor + 1
  end;
  caption.bytes[0] := 14;
  if odd(g20.words[16]) then
  begin
    proc22_48('|  TO BE DELIVERED\|\|    ');
    proc22_48(caption.text);
    proc22_45;
    proc22_45;
    proc22_48('Demand:    ');
    negotiable := g20.stock22.values[item.kind];
    proc28_4(amount, 0, negotiable);
    if negotiable = 0 then proc22_48('none')
    else
    begin
      proc22_49(negotiable, 1, false);
      proc22_48(' unit');
      if negotiable <> 1 then proc22_47(115)
    end
  end
  else
  begin
    proc22_48('|  PRICE ON GOODS\|    ');
    proc22_48(caption.text);
    proc22_45;
    proc22_48('Quality:           ');
    proc22_47(72 - item.category);
    proc22_45;
    if negotiable = 0 then proc22_48('Item not negotiable ')
    else if selling then
    begin
      proc28_4(paid, item.word1 div 10, 100 * (item.word1 mod 10));
      proc28_5('Price paid: ', paid);
      proc28_5('Offered:    ', amount)
    end
    else proc28_5('Asking:     ', amount)
  end;
  if selling then
  begin
    proc25_2;
    if negotiable = 0 then
      proc20_9(g20.words[12] - 10, 2, 1, 'Exit', '', '')
    else if odd(g20.words[16]) then
      proc20_9(g20.words[12] - 10, 1, 2, 'Deliver', 'Withhold', '')
    else proc20_9(g20.words[12] - 10, 1, 2, 'Accept', 'Withdraw', '');
    proc20_8(choice, found, data29.words[297], data29.bounds11, selected);
    if choice <> 1 then amount := g20.zero160
  end
  else proc28_5('Your limit: ', g20.cash164)
end;
