{ game_18 procedure26, $149A..$1605, attributes $1614.
  Native selector4 produces canonical0/1 here; other raw flag tests use bit0. }
procedure proc18_26;
var
  pressed: integer;
begin
  with g18items[1] do begin
    proc22_43(g18a133[134], g18a133[133]);
    if odd(g18a133[141]) then proc18_23(true);
    pressed := proc22_2(4);
    if odd(g18a133[138]) <> odd(pressed) then begin
      g18a133[138] := pressed;
      if odd(g18a133[138]) then begin
        if odd(g18a133[136]) then flags.bit4 := g18w111 > 0
        else flags.bit4 := false;
        if g18items[0].bytes9[0] = 1 then g18items[0].flags.bit5 := false;
        proc18_5(1, true)
      end else begin
        if odd(g18a133[142]) then begin
          if (words[5] >= g18w131 + 45) and (words[4] > 65) then
            proc18_23(true)
          else if (words[5] < g18w131 + 28) and
                  (words[4] < g18a112[129] + 46) then begin
            data29.flags45[13] := true;
            g18a133[143] := 1
          end else if (words[5] < g18w131 + 35) and
                      (words[4] > g18a112[129] + 62) then begin
            data29.flags45[13] := false;
            g18a133[143] := 1
          end
        end else begin
          flags.bit3 := proc18_2(words[5], words[4], g18b107);
          flags.bit2 := (words[4] >= g18a112[128] - 2) and odd(g18a133[139]);
          if flags.bit2 then proc18_24
          else if odd(g18a133[136]) and (g18w111 > 0) then proc18_25
        end;
        if flags.bit3 and not flags.bit4 then begin
          g18a112[125] := g18a112[125] + 1;
          bytes9[0] := 0
        end
      end
    end;
    if odd(proc22_2(4)) then begin
      words[1] := g18a133[134] - 3;
      words[0] := g18a133[133] + 3;
      proc18_12(1);
      g18a133[143] := ord(odd(g18a133[143]) or
                          (words[5] < data29.words[14] + 10))
    end;
    if odd(proc22_2(1)) then proc18_23(false)
  end
end;
