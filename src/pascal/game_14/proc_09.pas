{ game_14 procedure9, $068C..$071D, attributes $072A.
  Retain all toggle/draw calls, the initial pending update before the descending
  scan, and parent slots5..8 used by nested10. }
procedure proc14_9(cursorx, cursory, heldcode: integer; active: boolean);
var
  savedy: integer;
  savedx: integer;
  index: integer;
  offset: integer;
(*$include src/pascal/game_14/proc_10.pas*)
begin
  if active then proc14_2;
  if data29.nibbles45[1] <= 2 then proc24_9 else proc22_29;
  if active then proc14_2;
  if not odd(g14.words[104]) then
  begin
    offset := g14.words[4] + 25;
    index := data29.bytes[178 + offset];
    if index < 20 then
    begin
      if active then proc27_3(cursorx, cursory);
      data29.bytes[178 + offset] := 31;
      savedx := data29.words[14];
      savedy := data29.words[12];
      if not active then proc14_2;
      proc22_11(1);
      proc14_10;
      index := 19;
      while index >= 0 do
      begin
        if data29.bytes[178 + (g14.words[4] + index)] > 127 then proc14_10;
        index := index - 1
      end;
      if not active then proc14_2;
      proc24_8(g14.words[9]);
      proc14_5;
      if active then
      begin
        proc27_4(heldcode);
        proc27_3(cursorx, cursory)
      end
    end
  end
end;
