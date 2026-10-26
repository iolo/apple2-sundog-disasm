{ utility_disk1:32 $11D6..$124A, attributes$1256, nested in31.
  Slots1 caption address,2 y,3 x,4 row; value caption copy5..12.
  Locals13 xpos,14 unused,15 index,16 limit,17 key pointer. Read all ten
  caption bytes without checking length, and write only the low code byte. }
procedure util1_32(row, x, y: integer; caption: text15);
var
  xpos: integer;
  unused: integer;
  index: integer;
  limit: integer;
  key: utilkptr;
begin
  xpos := x;
  index := 0;
  limit := 9;
  while index <= limit do
  begin
    key := @namework.keys[row, index];
    proc22_18(key^.bounds, xpos, xpos + 13, y - 12, y);
    key^.code.low := ord(caption[index + 1]);
    proc22_19(key^.bounds, 11);
    proc22_18(key^.bounds, xpos + 1, xpos + 12, y - 11, y - 1);
    proc22_19(key^.bounds, 8);
    proc22_12(xpos + 3, y - 2);
    proc22_9(key^.code.low);
    xpos := xpos + 13;
    index := index + 1
  end
end;
