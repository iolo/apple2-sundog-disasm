{ game_16 procedure12, $0584..$05AB, attributes $05B8.
  Add256 for each crossed threshold in parent47 onward. Preserve the scan
  without an invented upper bound; thresholds share the parent's raw frame. }
function proc16_12(index: integer): integer;
var
  band: integer;
  value: integer;
begin
  value := g16.table141.bytes^[index];
  band := 0;
  while index >= g16.words[47 + band] do
  begin
    value := value + 256;
    band := band + 1
  end;
  proc16_12 := value
end;
