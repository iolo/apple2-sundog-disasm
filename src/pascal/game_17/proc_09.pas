{ game_17 procedure9, $0212..$03CC, attributes $03DC. }
procedure proc17_9;
var
  index, random1, random2, delayval: integer;
begin
  fillchar(g17.items[0], 70, 0);
  with g17.items[1] do
  begin
    first := g17.words[87] + 67;
    second := g17.words[85] + 51;
    draw := 22;
    code := 24;
    proc17_3(1);
    delay := 0;
    life := data29.bytes[120] * data29.bytes[94] div 90;
    radius := data29.bytes[96] div 10;
    if life <= 32 then life := 33;
    active := true
  end;
  index := 0;
  while index <= 6 do
  begin
    with g17.trail[index] do
    begin
      first := g17.items[1].first;
      second := g17.items[1].second;
      word1 := 0;
      word0 := 0
    end;
    index := index + 1
  end;
  data29.bytes[548] := 0;
  data29.bytes[549] := 4;
  data29.bytes[550] := 2;
  data29.bytes[551] := g17.words[94] - 1;
  data29.bytes[552] := 0;
  data29.flags82[65] := false;
  data29.flags82[66] := false;
  index := 2;
  while index <= g17.words[94] do
  begin
    with g17.items[index] do
    begin
      draw := 23;
      code := 24;
      life := proc22_40(70, 250);
      random1 := proc22_3;
      random1 := random1 mod 5;
      random2 := proc22_3;
      radius := random1 + random2 mod 5;
      delayval := proc22_40(10, 15);
      delay := delayval - radius;
      first := g17.items[1].first;
      second := g17.items[1].second;
      if index > 2 then proc17_8(index)
      else
      begin
        case data29.words[292] div 3 of
          0: first := first - 7;
          2: first := first + 7
        end;
        case data29.words[292] mod 3 of
          0: second := second - 8;
          2: second := second + 8
        end
      end;
      proc17_3(index);
      active := true
    end;
    index := index + 1
  end
end;
