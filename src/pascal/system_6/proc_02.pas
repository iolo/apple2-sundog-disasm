{ system6:2 $06B8..$0708, attributes$0712. VAR file3, buffer pointer2,
  kind1; original local4 captures the file address. Preserve store order:
  flags3/5/2/1 precede the buffer assignment. Kinds0/-2 clear buffer byte1,
  set width1, and only kind0 sets flag3. Other negative kinds discard buffer;
  positive kinds use twice the supplied width. The buffer view adds one local
  pointer without changing the original file storage or argument widths. }
procedure sys6_2(var f: integer; buffer: s6wptr; kind: integer);
var
  view: s6fview;
  data: s6bview;
begin
  view.word := @f;
  view.fileptr^.words[3] := 0;
  view.fileptr^.words[5] := 0;
  view.fileptr^.words[2] := 1;
  view.fileptr^.words[1] := 1;
  data.word := buffer;
  view.fileptr^.current.bytes := data.bytes;
  if odd(ord(kind = 0) or ord(kind = -2)) then
  begin
    view.fileptr^.current.bytes^[1] := 0;
    view.fileptr^.words[4] := 1;
    if kind = 0 then view.fileptr^.words[3] := 1
  end
  else if kind < 0 then
  begin
    view.fileptr^.current.bytes := nil;
    view.fileptr^.words[4] := 0
  end
  else view.fileptr^.words[4] := kind + kind
end;
