{ game_13 procedure50, $2450..$245D, attributes $2468; nested in1.
  Row index4 and threshold3 precede the two result words; return Boolean in1.
  Read unsigned byte24 of the28-byte row at DATASEG29 word90. }
function group_below_limit(component_group, threshold: integer): boolean;
begin
  group_below_limit := data29.bytes[178 + (28 * component_group + 24)] <= threshold
end;
