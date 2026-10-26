{ game_8 procedure 6, $012C..$0171, attributes $017C.
  Bounds and caption are value parameters; incoming storage may alias globals. }
procedure proc8_6(bounds: bounds4; caption: text15);
var
  firstpos: integer;
begin
  proc22_14(bounds.lower_first - 2, bounds.upper_first + 2,
            bounds.lower_second - 2, bounds.upper_second + 2);
  proc22_7(10);
  proc22_19(bounds, 8);
  firstpos := ((bounds.lower_first + bounds.upper_first) -
               6 * length(caption)) div 2;
  proc22_11(3);
  proc22_12(firstpos, bounds.upper_second - 2);
  proc22_10(caption);
  proc22_11(1)
end;
