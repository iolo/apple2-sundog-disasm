{ game_16 procedure3, $0080..$00D6, attributes $00E0.
  Direct amount updates100; item mode updates caption124. Both update106 and
  the price text. The implicit concat temporary is34 chars, then SAS31 stores
  back into108. Preserve the formatter's15-char view of that same buffer. }
procedure proc16_3(value, direct: integer);
var
  price: integer;
begin
  if odd(direct) then
  begin
    price := value;
    proc28_4(g16.fund100, 0, price)
  end
  else
  begin
    price := proc16_2(value);
    g16.caption124 := data31.captions.table^[proc22_32(value, 31)]
  end;
  proc28_4(g16.price106, 0, price);
  proc22_38(price, g16.short108);
  g16.text108 := concat(g16.text108, ' Cr')
end;
