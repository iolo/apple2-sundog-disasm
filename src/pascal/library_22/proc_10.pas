{ library_22 procedure 10, $001C..$0044, attributes $0050.
  SAS 80 copies the incoming string before any native calls. }
procedure proc22_10(caption: text80);
var
  cursor, last: integer;
begin
  last := length(caption);
  cursor := 1;
  while cursor <= last do
  begin
    proc22_9(ord(caption[cursor]));
    cursor := cursor + 1
  end
end;
