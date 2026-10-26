{ game_16 procedure26, $0AA4..$0B40, attributes $0B4A.
  Successive division exposes flag bits; FJP always tests bit0. Preserve the
  update/clamp/reset/selection order and the direction of two-word transfers. }
procedure apply_dialog_flags;
var
  bits: integer;
begin
  read_dialog_byte(bits);
  if odd(bits) then g16.words[20] := 1;
  if odd(bits div 2) then g16.reuse_choice := 1;
  bits := bits div 4;
  case bits mod 4 of
    1: g16.response_level := g16.response_level + 1;
    2: g16.response_level := g16.response_level - 1;
    3: g16.response_level := 4
  end;
  clamp_word(0, g16.response_level, 4);
  bits := bits div 4;
  if odd(bits) then
  begin
    g16.trade_item_code := 0;
    g16.selling_mode := 0
  end;
  if odd(bits div 2) then choose_trade_item;
  bits := bits div 4;
  case bits mod 4 of
    1: subtract_amount(g16.offer_amount, g16.cash_amount);
    2: add_amount(g16.offer_amount, g16.cash_amount);
    3: g16.offer_amount := g16.zero_amount
  end
end;
