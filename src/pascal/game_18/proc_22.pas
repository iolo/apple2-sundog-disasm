{ game_18 procedure 22, $1068..$113C, attributes $1148. }
procedure proc18_22;
var
  count: integer;
  saved: address16;
begin
  if (data29.nibbles45[2] < 7) or (data29.nibbles45[2] > 10) then
  begin
    if odd(g18a133[142]) then
    begin
      proc22_15(1);
      data29.words[20] := 0
    end
    else proc22_52;
    proc22_19(data29.bounds7, 0);
    if not odd(data29.words[347]) then
    begin
      if data29.nibbles45[2] = 11 then
      begin
        if data29.nibbles45[0] <> 11 then
          data29.nibbles45[1] := data29.nibbles45[0]
        else if data29.bits37.mid6 <> 0 then data29.nibbles45[1] := 3
        else data29.nibbles45[1] := 4
      end
      else
      begin
        data29.nibbles45[2] := data29.nibbles45[1];
        data29.nibbles45[1] := 5
      end;
      data29.nibbles45[0] := 11
    end;
    data29.words[351] := g18a112[117];
    data29.words[353] := g18a112[112];
    data29.flags82[57] := false
  end
  else
  begin
    g18a148[152] := -9408;
    count := proc22_24(g18a148[151]) - proc22_24(g18items[0].words[0]);
    saved.word := g18a148[152];
    moveleft(g18items, saved.bytes^, count);
    data29.bytes[551] := 1
  end
end;
