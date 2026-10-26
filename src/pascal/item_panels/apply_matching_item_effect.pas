{ library_27 procedure14, $02C6..$0338, attributes $0344; nested in11. }
procedure apply_matching_item_effect(matchcode, delta: integer);
var
  randomv: integer;
  oldbyte: integer;
begin
  if basecode = matchcode then
  begin
    amount := word_abs(delta);
    clearit := true;
    changed := true;
    change := word_sign(delta) * 80;
    if (byteidx >= 0) and not highcode then
      data29.bytes[94 + byteidx] := 100
    else if matchcode = 9 then
    begin
      index := 1;
      while index <= 3 do
      begin
        { Read the byte before native3, as in $0312..$0322. }
        oldbyte := data29.bytes[94 + index];
        randomv := random_word;
        data29.bytes[94 + index] := oldbyte - (3 + word_and(randomv, 7));
        index := index + 1
      end
    end
  end
end;
