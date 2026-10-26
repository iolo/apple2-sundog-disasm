{ game_17 procedure7, $0132..$01B9, attributes $01C4. }
procedure proc17_7;
var
  saved, kind, index: integer;
begin
  index := 0;
  g17.items[1].active := false;
  g17.words[40] := 0;
  while index < 4 do
  begin
    kind := proc22_32(data29.bytes[122 + index], 31);
    if (kind = 12) or (kind = 13) then
    begin
      if index <> 0 then
      begin
        saved := data29.bytes[122];
        data29.bytes[122] := data29.bytes[122 + index];
        data29.bytes[122 + index] := saved;
        if g17.words[77] = 0 then g17.words[77] := index
      end;
      index := 5;
      g17.items[1].active := true;
      g17.words[40] := ord(kind = 13);
      if odd(g17.words[40]) then
        g17.words[75] := proc22_31(data29.bytes[122], 5)
    end
    else index := index + 1
  end
end;
