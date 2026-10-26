{ game_13 procedure50, $2450..$245D, attributes $2468; nested in1.
  Row index4 and threshold3 precede the two result words; return Boolean in1.
  Read unsigned byte24 of the28-byte row at DATASEG29 word90. }
function proc13_50(index, threshold: integer): boolean;
begin
  proc13_50 := data29.bytes[178 + (28 * index + 24)] <= threshold
end;
