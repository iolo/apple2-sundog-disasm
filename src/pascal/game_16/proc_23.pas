{ game_16 procedure23, $0D62..$0E3C, attributes $0E4C.
  Retain its20-byte frame, including work10 shared with28. Header flag tests
  use low bits after division. Save the byte cursor around dialogue17, and
  retain the early self EXIT before any option processing. }
procedure proc16_23(var value: integer);
var
  cursor: integer;
  flags: integer;
  phraseid: integer;
  unused5: integer;
  unused6: integer;
  action: integer;
  captionid: integer;
  count: integer;
  work: integer;
  last: integer;
(*$include src/pascal/game_16/proc_24.pas*)
(*$include src/pascal/game_16/proc_26.pas*)
(*$include src/pascal/game_16/proc_27.pas*)
(*$include src/pascal/game_16/proc_28.pas*)
(*$include src/pascal/game_16/proc_29.pas*)
begin
  data31.words[16] := data31.words[10];
  g16.words[19] := 0;
  g16.words[38] := g16.source140.bytes^[value mod 16];
  proc16_15(work);
  flags := work div 16;
  count := work div 4 mod 4;
  g16.words[43] := 2 * (work mod 4);
  proc16_26;
  if odd(flags div 2) and (count = 0) then
  begin
    proc16_15(value);
    proc16_24(value);
    g16.words[21] := 1;
    if flags >= 8 then proc16_28;
    exit(proc16_23)
  end;
  proc16_15(phraseid);
  if phraseid < 30 then proc16_24(phraseid);
  work := g16.words[38];
  proc16_17(phraseid);
  g16.words[38] := work;
  cursor := 3;
  last := 4;
  while cursor <= last do
  begin
    proc16_15(g16.words[95 + cursor]);
    if odd(flags) then proc16_29(g16.words[95 + cursor]);
    cursor := cursor + 1
  end;
  work := 0;
  while work < 3 - count do
  begin
    proc16_27(work, -1, -1);
    work := work + 1
  end;
  g16.words[22] := 0;
  while count > 0 do
  begin
    g16.words[22] := 1;
    proc16_15(captionid);
    proc16_15(action);
    if odd(flags div 2) then proc16_29(action);
    proc16_27(work, action, captionid);
    count := count - 1;
    work := work + 1
  end;
  if flags >= 8 then proc16_28
end;
