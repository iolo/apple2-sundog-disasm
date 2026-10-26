{ library_24 procedure6, $00A8..$00E9, attributes $00F6.
  Three packed nibbles at system-row word8 supply coordinates. Preserve the
  first-minus-second difference,16-bit square/sum, then library22:36's integer
  rounded square root. The raw row pointer is reread for each input on each iteration.
  Added address-view locals have no nested consumers. }
function proc24_6(first, second: integer): integer;
var
  index: integer;       {original5}
  total: integer;       {6}
  last: integer;        {7}
  firstrow: g19addr;
  otherrow: g19addr;
begin
  total := 0;
  index := 0;
  last := 2;
  while index <= last do
  begin
    firstrow.word := data29.words[23] + 20 * (first - 1);
    otherrow.word := data29.words[23] + 20 * (second - 1);
    total := total + sqr(firstrow.rows^[1].nibbles8[index] -
                         otherrow.rows^[1].nibbles8[index]);
    index := index + 1
  end;
  proc24_6 := proc22_36(total)
end;
