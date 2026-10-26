{ system6:13 $0714..$07F6, attributes$0804. VAR file1; locals2 extended,
  3 file pointer. Preserve all raw flag tests and stores. In the dirty-buffer
  path, the second write requires extended AND kind3 AND the LOW BIT of
  word13, not a nonzero block number. There are no IORESULT/IOCHECK calls.
  The flag29-false branch skips the word31:=512 store but still resets13. }
(*$I-*)
procedure rt_flush_file(var f: integer);
var
  extended: boolean;
  view: s6fview;
begin
  view.word := @f;
  view.fileptr^.words[14] := 0;
  view.fileptr^.words[1] := 0;
  view.fileptr^.words[2] := 0;
  if odd(view.fileptr^.words[6]) then
  begin
    extended := view.fileptr^.words[13] > view.fileptr^.words[12];
    if extended then view.fileptr^.words[12] := view.fileptr^.words[13];
    if odd(view.fileptr^.words[29]) then
    begin
      if extended then view.fileptr^.words[30] := view.fileptr^.words[31]
      else if view.fileptr^.words[13] = view.fileptr^.words[12] then
        if view.fileptr^.words[31] >= view.fileptr^.words[30] then
        begin
          extended := true;
          view.fileptr^.words[30] := view.fileptr^.words[31]
        end;
      if odd(view.fileptr^.words[32]) then
      begin
        view.fileptr^.words[32] := 0;
        view.fileptr^.words[15] := 1;
        if extended then
          fillchar(view.fileptr^.sector33[view.fileptr^.words[31]],
                   512 - view.fileptr^.words[31], 0);
        unitwrite(view.fileptr^.words[7], view.fileptr^.sector33, 512,
                  view.fileptr^.words[16] + view.fileptr^.words[13] - 1, 0);
        if odd(ord(extended) and
               ord(view.fileptr^.entry16.kind2.kind = 3) and
               view.fileptr^.words[13]) then
        begin
          view.fileptr^.words[12] := view.fileptr^.words[12] + 1;
          fillchar(view.fileptr^.sector33, 512, 0);
          unitwrite(view.fileptr^.words[7], view.fileptr^.sector33, 512,
                    view.fileptr^.words[16] + view.fileptr^.words[13], 0)
        end
      end;
      view.fileptr^.words[31] := 512
    end;
    view.fileptr^.words[13] := 0;
    if odd(view.fileptr^.words[29] and
           ord(view.fileptr^.entry16.kind2.kind = 3)) then
      view.fileptr^.words[13] := 2
  end
end;
(*$I+*)
