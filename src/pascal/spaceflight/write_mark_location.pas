{ game_13 procedure22, $0D54..$0D7C, attributes $0D86; nested in21.
  Input2 is printed second, input1 first. }
procedure write_mark_location(markvalue, locvalue: integer);
begin
  write_wrapped_text('Loc:   ');
  write_integer(locvalue, 3, true);
  write_wrapped_text(' MARK ');
  write_integer(markvalue, 3, true);
  text_newline
end;
