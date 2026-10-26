{ system6:3 $0806..$082C, attributes$0836. VAR file1, local view2.
  Clear the runtime IO word before capturing file1. An open file is flushed;
  a positive-width file then calls core7 when flag3 is exactly0, otherwise
  stores1 into flag3. Do not introduce an IORESULT check between these steps. }
procedure sys6_3(var f: integer);
var view: s6fview;
begin
  sy6e.state^.words[0] := 0;
  view.word := @f;
  if odd(view.fileptr^.words[5]) then
  begin
    sys6_13(f);
    if view.fileptr^.words[4] > 0 then
    begin
      if view.fileptr^.words[3] = 0 then sys0_7(view.fileptr^)
      else view.fileptr^.words[3] := 1
    end
  end
end;
