{ library_22 procedure 44, $0836..$0852, attributes $085C. }
procedure clear_text_window;
begin
  apply_bounds(data29.bounds11, 8);
  data29.text_x := data29.words[14] + 2;
  data29.text_y := data29.words[12] + 10;
  data29.text_right := data29.words[13]
end;
