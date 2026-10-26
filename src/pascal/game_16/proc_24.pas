{ game_16 procedure24, $09A8..$0A92, attributes $0AA2.
  Nested25 sets the original limit/threshold slots2/3. Preserve the inclusive
  counted scan, all discarded byte reads, cached random choice, and the final
  conditionless alternative. A chosen alternative still consumes later bytes. }
procedure proc16_24(var target: integer);
var
  limit: integer;
  threshold: integer;
  candidate: integer;
  choice: integer;
  kind: integer;
  direct: boolean;
  chosen: boolean;
  stopidx: integer;
(*$include src/pascal/game_16/proc_25.pas*)
begin
  chosen := false;
  kind := target;
  direct := true;
  if (kind = 22) or (kind = 23) then
  begin
    kind := kind - 2;
    direct := false
  end;
  if (kind = 21) or (kind = 20) then
  begin
    if direct then
    begin
      if kind = 21 then
      begin
        proc16_15(target);
        chosen := not odd(g16.words[20])
      end;
      proc16_25(2, 2)
    end
    else if kind = 21 then proc16_25(3, 3)
    else proc16_25(2, 2);
    choice := 0;
    stopidx := limit;
    while choice <= stopidx do
    begin
      if chosen then proc16_15(candidate)
      else
      begin
        proc16_15(target);
        chosen := g16.words[33] >= threshold;
        threshold := threshold - 1
      end;
      choice := choice + 1
    end
  end
  else if kind <= 10 then
  begin
    if odd(g16.words[15]) then choice := g16.words[14]
    else
    begin
      choice := proc22_3;
      choice := choice mod target
    end;
    g16.words[15] := 0;
    g16.words[14] := choice;
    while kind > 0 do
    begin
      proc16_15(candidate);
      if choice = 0 then target := candidate;
      choice := choice - 1;
      kind := kind - 1
    end
  end
  else
  begin
    kind := kind - 10;
    repeat
      proc16_15(candidate);
      kind := kind - 1;
      if kind > 0 then proc16_15(threshold) else threshold := 0;
      if not chosen then
      begin
        chosen := odd(proc16_8(threshold));
        if chosen then target := candidate
      end
    until kind <= 0
  end
end;
