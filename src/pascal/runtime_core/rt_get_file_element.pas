{ system_core0:7 $00FE..$0213, attributes$0226. File pointer1; original
  locals2 index,7 unit,9 echo,10 continuing,11 character,12 file pointer.
  Unused locals3..6/8 omitted. sy0e: s4env aliases the shared runtime ancestor;
  state^.words[0] is the same IO word as system2's sysio^.
  Repeated spaces return early while count14 remains positive. Buffered read
  failure and direct IO failure share flags2:=1,1:=1; closed files also set
  error13. Direct input reads one BYTE into a zero-high-byte integer, echoes
  only unmasked characters, and maps the configured stop byte to zero on unit1.
  Do not cache current-buffer pointers across system2 or recursive core calls.
  Complete the declaration from io_forwards.pas after the system2 bodies. }
(*$I-*)
procedure rt_get_file_element;
label 900, 999;
var index, unitnum: integer;
    echo, continuing: boolean;
    code: integer;
    fileptr: sysfptr;
begin
  sy0e.state^.words[0] := 0;
  fileptr := @f;
  if not odd(fileptr^.words[5]) then
  begin
    sy0e.state^.words[0] := 13;
    goto 900
  end;
  if fileptr^.words[14] > 0 then
  begin
    fileptr^.words[14] := fileptr^.words[14] - 1;
    if fileptr^.words[14] > 0 then goto 999
  end;
  if odd(fileptr^.words[29]) then
  begin
    if rt_fetch_buffered(f) then goto 900
  end
  else
  begin
    echo := fileptr^.words[7] = 1;
    if echo then unitnum := 2 else unitnum := fileptr^.words[7];
    continuing := true;
    code := 32;
    index := 0;
    while odd(ord(index < fileptr^.words[4]) and ord(continuing)) do
    begin
      unitread(unitnum, code, 1, 0, 0);
      if ioresult <> 0 then goto 900;
      if echo then
        if not sy0e.flags157[code] then
          unitwrite(fileptr^.words[7], code, 1, 0, 0);
      if code = sy0e.state^.keys.bytes[8] then
      begin
        if fileptr^.words[7] = 1 then code := 0;
        continuing := false
      end;
      fileptr^.current.bytes^[index] := code;
      index := index + 1
    end
  end;
  if fileptr^.words[4] = 1 then
  begin
    fileptr^.words[1] := 0;
    if fileptr^.words[3] <> 0 then fileptr^.words[3] := 2;
    if fileptr^.current.bytes^[0] = 13 then
    begin
      fileptr^.current.bytes^[0] := 32;
      fileptr^.words[1] := 1;
      goto 999
    end;
    if fileptr^.words[7] > 2 then
      if rt_decode_spaces(f) then goto 999;
    if fileptr^.current.bytes^[0] = 0 then
    begin
      if odd(fileptr^.words[29] and ord(fileptr^.entry16.kind2.kind = 3)) then
        rt_skip_text_page(f)
      else
      begin
        fileptr^.current.bytes^[0] := 32;
        goto 900
      end
    end
  end;
  goto 999;
900:
  fileptr^.words[2] := 1;
  fileptr^.words[1] := 1;
999:
end;
(*$I+*)
