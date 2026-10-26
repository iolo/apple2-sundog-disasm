{ game_16 procedure5, $0118..$0150, attributes $015A.
  Draw the full encoded item caption before masking its code. The16 unused
  local bytes have no nested consumer and are omitted. }
procedure proc16_5(code, index: integer);
begin
  proc27_10(code);
  code := proc22_32(code, 31);
  if (index > data31.words[10]) and (code > 5) and (arg1 <> 15) then
  begin
    index := 6 * length(g16.text108);
    proc22_12(data31.words[8] - index, data31.words[6]);
    proc22_10(g16.text108)
  end
end;
