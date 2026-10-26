{ game_12 procedure3, $0012..$005D, attributes $0068; nested in1.
  Signed word arithmetic and positive-width guard precede both fills. }
procedure proc12_3;
var
  width: integer; {1}
  unused2: integer;
begin
  if odd(g12.words[31]) then
  begin
    width := (data29.words[216] + 2) div 3;
    if width > 0 then
    begin
      proc22_14(g12.words[40], g12.words[40] + width,
                  g12.words[38], g12.words[37]);
      if width > 43 then proc22_7(5) else proc22_7(6);
      proc22_14(g12.words[40] + width + 1, g12.words[39],
                  g12.words[38], g12.words[37]);
      proc22_7(4)
    end
  end
end;
