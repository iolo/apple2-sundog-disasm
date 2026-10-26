{ library_22 procedure49, $09DC..$0A27, attributes $0A34.
  Counted padding loop, unlike procedure39's length-tested loop. }
procedure write_integer(value, width: integer; zeroes: boolean);
var
  rendered: text15;
  pad_index: integer;
  text_length: integer;
  padding: string[1];
  field_width: integer;
begin
  integer_to_text(value, rendered);
  if zeroes then padding := '0' else padding := ' ';
  text_length := length(rendered);
  pad_index := text_length + 1;
  field_width := width;
  while pad_index <= field_width do
  begin
    rendered := concat(padding, rendered);
    pad_index := pad_index + 1
  end;
  write_wrapped_text(rendered)
end;
