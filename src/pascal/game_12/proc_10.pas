{ game_12 procedure10, $0876..$09AE, attributes $09BC; nested in1.
  Inputs2/1 are horizontal/vertical motion. After applying those inputs,
  reuse their private value slots for two visibility predicates so both
  original absolute-value calls run. Speed3 remains available for drawing. }
procedure proc12_10(horizontal, vertical: integer);
var speed: integer; {3}
begin
  if odd(g12.words[29]) or odd(g12.words[31]) or odd(g12.words[27]) then
  begin
    proc22_11(1);
    proc22_19(data29.bnd343, 0);
    g12.words[45] := g12.words[45] - horizontal;
    g12.words[44] := g12.words[44] - vertical;
    if odd(g12.words[31]) then
    begin
      if data29.words[215] > 0 then
      begin
        data29.words[217] := data29.words[217] + data29.words[207];
        if data29.words[217] < 5 then data29.words[217] := 5;
        data29.words[215] := data29.words[215] - 1
      end;
      speed := 3 - proc22_31(data29.words[217], 5);
      data29.words[206] := proc22_32(data29.words[206] + horizontal + horizontal +
                                     speed * data29.words[209], 1023);
      data29.words[205] := proc22_32(data29.words[205] + vertical + vertical +
                                     speed * data29.words[208], 1023)
    end;
    if g12.words[6] > 1 then
    begin
      if odd(g12.words[31]) then
      begin
        g12.words[20] := proc22_31(data29.words[206], 1) - 256;
        g12.words[19] := proc22_31(data29.words[205], 1) - 256;
        horizontal := ord(proc22_35(g12.words[20]) < 65);
        vertical := ord(proc22_35(g12.words[19]) < 45);
        if odd(horizontal) and odd(vertical) and (data29.words[217] < 108) then
        begin
          proc22_12(g12.words[18] + g12.words[20], g12.words[17] + g12.words[19]);
          callsky(g12.words[43], 2518);
          proc22_9(g12.words[16] + speed);
          g12.words[32] := 1
        end
        else
        begin
          callsky(g12.words[43], 2518);
          g12.words[32] := 0;
          g12.words[3] := 2
        end
      end
      else callsky(g12.words[43], 2518)
    end
    else proc22_19(data29.bnd343, 8)
  end
end;
