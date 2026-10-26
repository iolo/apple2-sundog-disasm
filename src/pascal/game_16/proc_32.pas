{ game_16 procedure32, $0ED8..$0F69, attributes $0F7A.
  Header16 skips all work. Copy each record leftward before storing its next
  byte offset; odd source positions advance to the next even byte. Preserve
  forward propagation through table64 and rebuild the six raw thresholds. }
procedure proc16_32;
var
  block: address16;
  target: integer;
  count: integer;
  index: integer;
  source: integer;
  left: integer;
begin
  proc22_23(18432, block.word);
  if block.bytes^[0] <> 16 then
  begin
    left := block.bytes^[16];
    source := block.bytes^[17];
    source := source + source;
    index := g16.words[26];
    while left > 0 do
    begin
      count := block.bytes^[source];
      target := proc16_12(index);
      moveleft(block.bytes^[source + 1], g16.table141.bytes^[target], count);
      g16.table141.bytes^[index + 1] := (target + count) mod 256;
      source := source + 1 + count;
      if odd(source) then source := source + 1;
      index := index + 1;
      left := left - 1
    end;
    while index < 64 do
    begin
      g16.table141.bytes^[index + 1] := g16.table141.bytes^[index];
      index := index + 1
    end;
    g16.words[47] := 0;
    proc16_31(0, 0, 0)
  end
end;
