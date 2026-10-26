{ library_22 procedure 14, $0088..$009C, attributes $00A6, lexical level 1.
  Frame slots 4,3,2,1 are the four arguments in source order.
  The unused two-byte local allocation is not a semantic variable. }
procedure set_clip_bounds(first_low, first_high, second_low, second_high: integer);
begin
  data29.words[363] := first_low;    { $0088..$0089 }
  data29.words[362] := first_high;   { $008D..$008E }
  data29.words[360] := second_low;   { $0092..$0093 }
  data29.words[361] := second_high   { $0097..$0098; RNP 0 at $009C. }
end;
