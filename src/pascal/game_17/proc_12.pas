{ game_17 procedure12, $0528..$05FD, attributes $0606.
  Keep exactly one local word, count in slot1. This slot has the same physical
  address as child11's slot2 under the original call-frame allocator.
  The raw save includes memory beyond the declared parent frame; see notes. }
procedure proc17_12;
var
  count: integer;
begin
  if odd(g17.words[41]) then
    data29.bytes[122 + g17.words[77]] := 11 + proc22_30(g17.words[76], 5);
  if odd(g17.words[40]) then
    data29.bytes[122] := 13 + proc22_30(g17.words[75], 5);
  data29.bytes[120] := 90 * g17.items[1].life div data29.bytes[94];
  count := 2 * data29.bytes[120];
  if count < data29.bytes[118] then data29.bytes[118] := count;
  if (data29.nibbles45[2] < 7) or (data29.nibbles45[2] > 10) then
  begin
    proc22_52;
    proc22_19(data29.bounds7, 0);
    if not odd(data29.words[347]) then
    begin
      data29.nibbles45[2] := data29.nibbles45[1];
      data29.nibbles45[1] := 5;
      data29.nibbles45[0] := 11
    end;
    data29.words[351] := g17.words[81];
    arg1 := 0
  end
  else
  begin
    g17.saved43 := data29.bounds11;
    count := proc22_24(g17.words[99]) - proc22_24(count);
    g17.ptr100.word := -9408;
    moveleft(g17, g17.ptr100.bytes^, count)
  end
end;
