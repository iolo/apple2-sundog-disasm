{ game_18 procedure27, $1616..$1711, attributes $171E. }
procedure proc18_27;
var
  index: integer;
  randomv: integer;
  available: boolean;
begin
  if odd(g18a133[142]) then exit(proc18_27);
  with g18items[0] do begin
    if flags.bit5 then begin
      proc18_12(0);
      if not flags.bit5 then begin
        if (bytes9[0] = 1) and g18items[1].flags.bit3 then proc18_23(true)
        else begin
          g18items[bytes9[0]].flags.bit4 := true;
          { Capture this destination before random, as $1668..$1677 do. }
          with g18items[bytes9[0]].pair9 do begin
            randomv := proc22_3;
            low := 64 + randomv mod 192
          end;
          g18a112[125] := g18a112[125] - 1
        end;
        bytes9[0] := 0
      end
    end else begin
      available := g18a112[125] > 0;
      randomv := proc22_3;
      if available and (randomv mod 8 = 0) then begin
        index := 1;
        while index <= g18w132 do begin
          if g18items[index].flags.bit3 and not g18items[index].flags.bit4 then begin
            flags.bit5 := true;
            bytes9[0] := index;
            words[1] := g18items[index].words[5] + g18a112[115];
            words[0] := g18items[index].words[4] + g18a112[114];
            words[3] := words[1];
            words[2] := words[0];
            index := g18w132 + 1
          end else index := index + 1
        end
      end
    end
  end
end;
