{ system_core0:28 $0754..$0842, attributes$0850. File pointer8, buffer7,
  byte offset6, blocks5, disk block4, reading3, result1/2; locals9 file,
  10 entry. File-backed requests default a negative block to word13 and may
  extend via33 before clipping; that call's result is deliberately discarded.
  Direct-device reads scan backward for nonzero data and round its extent to
  blocks. Preserve SCAN's negative count, including its inclusive endpoint
  one byte before the payload when all requested bytes are zero. No special
  zero-block guard or wider arithmetic is introduced. Helper36 consumes its
  own IORESULT;28 then performs the second original IORESULT check. }
(*$I-*)
function sys0_28(var f: integer; buffer: s0bptr;
                 offset, blocks, block: integer; reading: boolean): integer;
var view: s6fview;
    entry: syseptr;
begin
  sys0_28 := 0;
  sy0e.state^.words[0] := 0;
  view.word := @f;
  if odd(view.fileptr^.words[5] and ord(blocks >= 0)) then
  begin
    if odd(view.fileptr^.words[6]) then
    begin
      entry := @view.fileptr^.entry16;
      if block < 0 then block := view.fileptr^.words[13];
      block := entry^.words[0] + block;
      if block + blocks > entry^.words[1] then
        if not reading then
          if sys0_33(view.fileptr^) then begin end;
      if block + blocks > entry^.words[1] then blocks := entry^.words[1] - block;
      view.fileptr^.words[2] := ord(block >= entry^.words[1]);
      if not odd(view.fileptr^.words[2]) then
      begin
        sys0_36(view.fileptr^.words[7], buffer, offset, blocks, block, reading);
        if ioresult = 0 then
        begin
          if not reading then view.fileptr^.words[15] := 1;
          sys0_28 := blocks;
          block := block + blocks;
          view.fileptr^.words[2] := ord(block = entry^.words[1]);
          view.fileptr^.words[13] := block - entry^.words[0];
          if view.fileptr^.words[13] > view.fileptr^.words[12] then
            view.fileptr^.words[12] := view.fileptr^.words[13]
        end
      end
    end
    else
    begin
      sys0_28 := blocks;
      sys0_36(view.fileptr^.words[7], buffer, offset, blocks, block, reading);
      if ioresult = 0 then
      begin
        if reading then
        begin
          block := blocks * 512;
          block := block + scan(-block, <> chr(0), buffer^[offset + block - 1]);
          block := (block + 512 - 1) div 512;
          sys0_28 := block;
          view.fileptr^.words[2] := ord(block < blocks)
        end
      end
      else sys0_28 := 0
    end
  end
  else sy0e.state^.words[0] := 13
end;
(*$I+*)
