{ library_22 procedure 50, $0A36..$0A55, attributes $0A60. }
procedure set_text_window(firstlow, firsthigh, secondlow, secondhigh: integer);
begin
  assign_bounds(data29.bounds11, firstlow, firsthigh, secondlow, secondhigh);
  apply_bounds(data29.bounds11, 0);
  data29.text_x := firstlow + 2;
  data29.text_y := secondlow + 10;
  data29.text_right := firsthigh
end;
