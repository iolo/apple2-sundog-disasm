{ library_28 procedure5, $00B2..$00F2, attributes $00FC. }
procedure write_captioned_amount(caption: text15; value: wordpair);
begin
  write_wrapped_text(caption);
  if value.first = 0 then write_integer(value.second, 8, false)
  else if value.first > 0 then
  begin
    write_integer(value.first, 5, false);
    write_integer(value.second, 3, true)
  end
  else
  begin
    write_integer(value.first, 5, false);
    write_integer(-value.second, 3, true)
  end;
  text_newline
end;
