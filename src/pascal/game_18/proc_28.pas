{ game_18 procedure28, $1720..$17E1, attributes $17F0.
  The computed entry address in original local2 is never dereferenced. }
procedure proc18_28;
var
  index: integer;
  randomv: integer;
begin
  if odd(g18a133[142]) then exit(proc18_28);
  if (g18a112[124] > 1) or (g18a112[123] > 1) then begin
    if g18a112[124] > 1 then proc18_12(g18a112[124]);
    if g18a112[123] > 1 then proc18_12(g18a112[123])
  end else begin
    randomv := proc22_3;
    if randomv mod g18a112[122] = 0 then begin
      index := 2 + g18a112[113] div 2;
      randomv := proc22_3;
      if ((randomv mod g18w132 < index) and (g18w132 < index)) or
         (g18w132 = 1) then begin
        index := g18w132 + 1;
        proc18_13(index, false);
        if index > 0 then begin
          g18a112[124] := index;
          g18w132 := index
        end
      end else begin
        g18a112[124] := proc22_40(2, g18w132);
        if data29.flags82[65] then proc18_10(g18a112[124])
        else begin
          randomv := proc22_3;
          if odd(randomv) or not odd(g18a133[139]) then proc18_11(g18a112[124])
          else proc18_10(g18a112[124])
        end
      end
    end
  end
end;
