{ game_16 procedure41, $1812..$19B2, attributes $19C6.
  Retain24 local bytes and slots consumed by42/43. The unused argument1 and
  locals3/4 hold captured predicates/masks so all original effectful calls run.
  work4 retains the original discarded pre-use item store as well. }
procedure proc16_41(index, unused: integer);
var
  savedflag: integer;   {3}
  work4: integer;
  held: integer;        {5}
  origin: integer;
  previous: integer;
  target: integer;
  itemcode: integer;
  ypos: integer;        {10}
  xpos: integer;
  drawy: integer;
  drawx: integer;
  fromsale: boolean;    {14}
(*$include src/pascal/game_16/proc_42.pas*)
(*$include src/pascal/game_16/proc_43.pas*)
begin
  proc22_41(g16.words[13], g16.words[12]);
  fromsale := index > data31.words[10];
  proc27_12(index);
  proc22_21(0, false);
  previous := 0;
  origin := index;
  proc16_40(previous, origin, 0);
  proc27_7(previous, index, held, drawx, drawy);
  repeat
    proc27_2(xpos, ypos);
    data29.words[354] := data29.words[354] + 1;
    if data29.words[354] >= data29.words[353] then
    begin
      proc22_21(0, false);
      proc16_30;
      proc22_21(0, false)
    end;
    if (xpos <> drawx) or (ypos <> drawy) then
    begin
      proc27_3(drawx, drawy);
      proc27_3(xpos, ypos);
      drawx := xpos;
      drawy := ypos
    end;
    if odd(proc22_2(0)) then
    begin
      proc27_8(xpos, ypos, itemcode, target);
      if target > 0 then
      begin
        savedflag := ord(target = data31.words[14]);
        work4 := ord(fromsale);
        unused := ord(proc28_6(g16.price106, g16.cash104));
        if odd(savedflag) and not (odd(work4) and odd(unused)) then
        begin
          work4 := held;
          proc27_11(1, held, drawx, drawy);
          if fromsale and (held = 0) then proc16_42
        end
        else if (itemcode = 2) and not fromsale then
          proc27_11(0, held, drawx, drawy)
        else if target >= data31.words[14] then
        begin
          if fromsale then
          begin
            if target <= data31.words[10] then
            begin
              if proc28_6(g16.price106, g16.cash104) then
              begin
                proc22_21(0, false);
                proc27_9('Not enough');
                proc22_10(' money');
                proc22_21(0, false)
              end
              else proc16_43
            end
            else if itemcode = 0 then proc16_43
          end
          else if target <= data31.words[10] then proc16_43
          else
          begin
            savedflag := g16.words[18];
            unused := proc22_32(held, 31);
            work4 := proc22_32(g16.words[41], 31);
            if (odd(savedflag) and (unused = work4)) or
               (not odd(g16.words[18]) and (itemcode = 0)) then proc16_43
          end
        end
      end
    end;
    unused := proc22_2(1)
  until (odd(unused) and (previous = 0)) or (held = 0) or odd(data29.words[347]);
  if held <> 0 then
  begin
    previous := held;
    proc27_7(held, origin, held, drawx, drawy);
    proc16_40(previous, origin, 0);
    proc22_21(0, false);
    proc27_12(origin);
    proc27_9('')
  end
  else
  begin
    proc22_21(0, false);
    proc27_12(target)
  end;
  proc27_4(0);
  g16.words[13] := drawx;
  g16.words[12] := drawy;
  proc22_41(drawx, drawy)
end;
