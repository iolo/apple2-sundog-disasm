{ system6:7 $0674..$06AA, attributes$06B6. Source-entry pointer3,
  index2,directory pointer1; locals4 cursor,5 header pointer,6 lower limit.
  Shift from the last entry down before rereading source for the final copy.
  A source aliased into the directory therefore sees those preceding writes.
  Increment header word8 from its value AFTER the final13-word copy. }
procedure rt_add_dir_entry(var source: s6entry; index: integer; directory: s6dptr);
var
  cursor: integer;
  header: s6eptr;
  lower: integer;
begin
  header := @directory^[0];
  cursor := header^.words[8];
  lower := index;
  while cursor >= lower do
  begin
    directory^[cursor + 1] := directory^[cursor];
    cursor := cursor - 1
  end;
  directory^[index] := source;
  header^.words[8] := header^.words[8] + 1
end;
