{ library_22 procedure 45, $085E..$0879, attributes $0884. }
procedure text_newline;
begin
  data29.text_x := data29.words[14] + 2;
  data29.text_y := data29.text_y + 8;
  if data29.text_y > data29.words[11] then clear_text_window
end;
