{ system6:8 $0628..$0666, attributes$0672. Index2,directory pointer1;
  locals3 cursor,4 header pointer,5 limit. Shift ascending13-word records,
  clear only the last entry's string length through SAS15, then decrement
  header word8. No invented range check or whole-entry clearing. }
procedure sys6_8(index: integer; directory: s6dptr);
var
  cursor: integer;
  header: s6eptr;
  limit: integer;
begin
  header := @directory^[0];
  cursor := index;
  limit := header^.words[8] - 1;
  while cursor <= limit do
  begin
    directory^[cursor] := directory^[cursor + 1];
    cursor := cursor + 1
  end;
  directory^[header^.words[8]].caption := '';
  header^.words[8] := header^.words[8] - 1
end;
