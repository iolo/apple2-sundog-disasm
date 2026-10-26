{ system_core0:20 $0552..$05A1, attributes$05AE. File pointer4, payload
  byte address3, width2, count1; locals5 index,6 file pointer.
  Data aliases the payload. Padding uses17, then width is clamped to count;
  it is not recomputed from a possibly modified string. Buffered output tests
  the low bit of flag2 before each byte. Direct output does not call IORESULT.
  Closed files set IO13 without modifying file flags. }
(*$I-*)
procedure sys0_20(var f: integer; data: s0bptr; width, count: integer);
var index: integer;
    view: s6fview;
begin
  sy0e.state^.words[0] := 0;
  view.word := @f;
  if odd(view.fileptr^.words[5]) then
  begin
    if width > count then
    begin
      sys0_17(f, 32, width - count);
      width := count
    end;
    if odd(view.fileptr^.words[29]) then
    begin
      index := 0;
      while odd(ord(index < width) and not view.fileptr^.words[2]) do
      begin
        view.fileptr^.current.bytes^[0] := data^[index];
        sys0_8(view.fileptr^);
        index := index + 1
      end
    end
    else unitwrite(view.fileptr^.words[7], data^[0], width, 0, 0)
  end
  else sy0e.state^.words[0] := 13
end;
(*$I+*)
