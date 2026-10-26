{ library_22 procedure 19, $020C..$021F, attributes $022A, lexical level 1.
  Frame slots: 1=mode, 2=incoming bounds pointer, 3..6=local value copy.
  The four-word aggregate is copied before any global writes. }
procedure proc22_19(bounds: bounds4; mode: integer);
begin
  { $020C..$020F: the compiler's value-parameter copy implements MOV 4.
    $0211..$0215: local words 6,5,4,3 passed in that order. }
  proc22_14(bounds.lower_first, bounds.upper_first,
            bounds.lower_second, bounds.upper_second);
  { $0217..$021D }
  if mode <> 0 then
    proc22_7(mode)
  { $021F: RNP 0. }
end;
