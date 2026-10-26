{ game_21 procedure7, $01B0..$025C, attributes $0266.
  Copy six words before effects. A clipped point resets mode before self EXIT. }
procedure proc21_7(position: g19loc; glyph: integer; doubled: boolean);
var
  xcell, ycell, xpos, ypos: integer;
begin
  xcell := proc21_2(position.fields.kind2, arg6, 40);
  ycell := proc21_2(position.fields.kind3, arg5, 24);
  if (position.fields.city = data29.bits37.mid6) and
     (xcell < 10) and (ycell < 6) then
  begin
    xpos := 28 * xcell + position.fields.word4 mod 28;
    ypos := g21.words[21] * ycell + position.fields.w5low mod g21.words[21];
    if (xpos > 272) or (ypos < 8) then
    begin
      proc22_11(0);
      exit(proc21_7)
    end;
    if doubled then proc22_11(0) else proc22_11(1);
    proc22_12(xpos, ypos);
    proc22_9(glyph);
    if doubled then
    begin
      proc22_12(xpos + 7, ypos);
      proc22_9(glyph + 1);
      if data29.flags82[7] then
      begin
        proc22_11(1);
        proc22_12(xpos + 7, ypos);
        proc22_9(16)
      end
    end;
    proc22_11(0)
  end
end;
