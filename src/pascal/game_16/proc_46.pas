{ game_16 procedure46, $1A50..$1AB9, attributes $1AC4.
  Preserve the exact captions and high/low formatting choices. The original
  unused16 local bytes are omitted; no nested procedure consumes them. }
procedure proc16_46;
begin
  proc22_19(data31.bounds6, 8);
  proc22_12(data31.words[9], data31.words[6]);
  if (g16.words[105] = 0) and (g16.words[104] = 0) then proc22_10(' no money')
  else
  begin
    if g16.words[104] = 0 then proc22_39(g16.words[105], 8, false)
    else
    begin
      proc22_39(g16.words[104], 5, false);
      proc22_39(g16.words[105], 3, true)
    end;
    proc22_10(' Cr on hand')
  end;
  proc16_44;
  proc22_19(data31.bounds6, 8)
end;
