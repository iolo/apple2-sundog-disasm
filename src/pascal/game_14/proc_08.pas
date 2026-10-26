{ game_14 procedure8, $0598..$060B, attributes $0616.
  Slot2=code,1=index. Write the base code before recalculating/drawing; only
  afterward restore a high code and pending index. Raw accesses are byte stores. }
procedure proc14_8(code, index: integer);
var
  address: integer;
  value: integer;
  offset: integer;
begin
  if index > data31.words[15] then
  begin
    offset := (index - data31.words[15]) - 1;
    if not odd(g14.words[104]) then
    begin
      offset := 5 * (offset div 4) + offset mod 4;
      value := code mod 32
    end
    else value := code;
    address := offset + g14.words[4];
    data29.bytes[178 + address] := value;
    if not odd(g14.words[104]) then
    begin
      proc24_8(g14.words[9]);
      proc14_5;
      if code > 127 then
      begin
        data29.bytes[178 + (g14.words[4] + 25)] := offset;
        data29.bytes[178 + address] := code
      end
    end
  end
  else if index > data31.words[14] then
  begin
    offset := (index - data31.words[14]) - 1;
    data29.bytes[122 + offset] := code
  end
end;
