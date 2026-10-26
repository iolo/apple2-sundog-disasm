{ game_16 procedure6, $015C..$01B5, attributes $01C0.
  Capture the packed item address before its three stores. Preserve code,
  first-offset, second-offset store order and shared-origin reads after4. }
procedure proc16_6(itemcode, index, draw: integer);
var
  column: integer;
  row: integer;
  secondpos: integer;
  firstpos: integer;
begin
  row := (index - g16.words[46]) div 5;
  column := (index - g16.words[46]) mod 5;
  secondpos := 38 + row * 16;
  firstpos := 48 + 18 * column;
  with data31.items[index - g16.words[46] + data31.words[10] + 1] do
  begin
    code := itemcode;
    firstoff := firstpos;
    secondoff := secondpos
  end;
  if odd(draw) then
  begin
    proc27_4(itemcode);
    proc27_3(data29.words[14] + firstpos, data29.words[12] + secondpos)
  end
end;
