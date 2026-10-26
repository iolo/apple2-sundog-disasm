{ Both library26 variants: procedure17, $06EC..$0753, attributes $0764;
  nested in7. Retain both busy-wait loops and reread the character after
  the output call before deciding whether to play its sound. }
procedure proc26_17;
var
  textlen: integer; {1}
  delay: integer; {2}
  index: integer; {3}
  limit: integer; {4}
  waitend: integer; {5}
begin
  proc22_50(60, 270, 98, 110);
  textlen := ord(caption[0]);
  delay := 1;
  limit := 2500;
  while delay <= limit do delay := delay + 1;
  index := 1;
  limit := textlen;
  while index <= limit do
  begin
    proc22_47(ord(caption[index]));
    if ord(caption[index]) <> 32 then proc22_4(1, 255, 2, 0, 0, 1, 1);
    delay := 1;
    waitend := 200;
    while delay <= waitend do delay := delay + 1;
    index := index + 1
  end
end;
