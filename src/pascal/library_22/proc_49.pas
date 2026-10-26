{ library_22 procedure49, $09DC..$0A27, attributes $0A34.
  Counted padding loop, unlike procedure39's length-tested loop. }
procedure proc22_49(value, width: integer; zeroes: boolean);
var
  rendered: text15;
  cursor: integer;
  textlen: integer;
  padding: string[1];
  last: integer;
begin
  proc22_38(value, rendered);
  if zeroes then padding := '0' else padding := ' ';
  textlen := length(rendered);
  cursor := textlen + 1;
  last := width;
  while cursor <= last do
  begin
    rendered := concat(padding, rendered);
    cursor := cursor + 1
  end;
  proc22_48(rendered)
end;
