{ game_16 procedure26, $0AA4..$0B40, attributes $0B4A.
  Successive division exposes flag bits; FJP always tests bit0. Preserve the
  update/clamp/reset/selection order and the direction of two-word transfers. }
procedure proc16_26;
var
  bits: integer;
begin
  proc16_15(bits);
  if odd(bits) then g16.words[20] := 1;
  if odd(bits div 2) then g16.words[15] := 1;
  bits := bits div 4;
  case bits mod 4 of
    1: g16.words[33] := g16.words[33] + 1;
    2: g16.words[33] := g16.words[33] - 1;
    3: g16.words[33] := 4
  end;
  proc22_37(0, g16.words[33], 4);
  bits := bits div 4;
  if odd(bits) then
  begin
    g16.words[41] := 0;
    g16.words[18] := 0
  end;
  if odd(bits div 2) then proc16_11;
  bits := bits div 4;
  case bits mod 4 of
    1: proc28_3(g16.fund100, g16.cash104);
    2: proc28_2(g16.fund100, g16.cash104);
    3: g16.fund100 := g16.fund102
  end
end;
