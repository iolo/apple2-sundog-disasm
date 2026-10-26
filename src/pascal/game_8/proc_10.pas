{ game_8 procedure10, $03AA..$04C1, attributes $04CE.
  Original local2 is unused. Keep hit uninitialized until proc27_8 writes it:
  the original exit path also reads that slot if the parent item is zero. }
procedure proc8_10(index: integer);
var
  unused2: integer;
  action: integer;
  hit: integer;
  code: integer;
  secondpos: integer;
  firstpos: integer;
  inputv: integer;
begin
  proc8_9(index);
  proc22_21(0, false);
  repeat
    proc27_2(firstpos, secondpos);
    data29.words[354] := data29.words[354] + 1;
    if data29.words[354] >= data29.words[353] then proc8_3(true, false);
    if (firstpos <> g8a3[7]) or (secondpos <> g8a3[6]) then begin
      proc27_3(g8a3[7], g8a3[6]);
      proc27_3(firstpos, secondpos);
      g8a3[7] := firstpos;
      g8a3[6] := secondpos
    end;
    if odd(proc22_2(0)) then begin
      proc27_8(firstpos, secondpos, code, hit);
      if hit > 0 then begin
        if hit <= data31.words[14] then begin
          action := 1;
          if code = 2 then action := 0
          else if hit = data31.words[13] then action := 2;
          proc27_11(action, g8a3[3], g8a3[7], g8a3[6])
        end else if hit > data31.words[14] then begin
          g8a3[5] := g8a3[3];
          g8a3[4] := hit;
          proc27_7(g8a3[3], hit, g8a3[3], g8a3[7], g8a3[6]);
          proc22_21(0, false);
          proc27_10(g8a3[3]);
          proc22_21(0, false)
        end
      end
    end;
    { $0469: input selector1 is always called before all exit predicates. }
    inputv := proc22_2(1)
  until (odd(inputv) and (g8a3[5] = 0)) or (g8a3[3] = 0) or
        odd(data29.words[347]);
  if g8a3[3] <> 0 then begin
    g8a3[5] := g8a3[3];
    proc27_7(g8a3[3], g8a3[4], g8a3[3], g8a3[7], g8a3[6]);
    proc22_21(0, false);
    proc27_12(g8a3[4]);
    proc27_9('')
  end else begin
    proc22_21(0, false);
    proc27_12(hit)
  end;
  proc27_4(0)
end;
