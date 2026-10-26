{ game_14 procedure12, $0796..$08C8, attributes $08D8.
  Slot2=start index; unused value parameter1 holds the fit result. Unused local3
  captures eligibility before the UNCONDITIONAL11 call. This retains20 local
  bytes and the original call order. Input1 is polled on every loop path. }
procedure proc14_12(start, unused: integer);
var
  reject: boolean;
  held: integer;
  lastitem: integer;
  lastcode: integer;
  target: integer;
  selected: integer;
  mousey: integer;
  mousex: integer;
  drawy: integer;
  drawx: integer;
begin
  proc27_12(start);
  proc14_2;
  lastcode := 0;
  lastitem := start;
  proc14_8(lastcode, lastitem);
  proc27_7(lastcode, start, held, drawx, drawy);
  repeat
    proc27_2(mousex, mousey);
    data29.words[354] := data29.words[354] + 1;
    if data29.words[354] >= data29.words[353] then proc14_9(drawx, drawy, held, true);
    if (mousex <> drawx) or (mousey <> drawy) then
    begin
      proc27_3(drawx, drawy);
      proc27_3(mousex, mousey);
      drawx := mousex;
      drawy := mousey
    end;
    if odd(proc22_2(0)) then
    begin
      proc27_8(mousex, mousey, selected, target);
      if target > 0 then
      begin
        if target = data31.words[14] then proc27_11(1, held, drawx, drawy)
        else if selected = 2 then proc27_11(0, held, drawx, drawy)
        else if selected = 3 then
        begin
          proc14_2;
          proc14_7;
          proc14_2;
          proc27_4(held)
        end
        else
        begin
          reject := not odd(g14.words[104]) and (target > data31.words[15]);
          unused := ord(proc14_11(held, target));
          if reject and not odd(unused) then
          begin
            proc14_2;
            proc27_9('Doesn''t fit');
            proc14_2
          end
          else if selected <> 3 then
          begin
            lastcode := held;
            lastitem := target;
            proc14_8(lastcode, lastitem);
            proc27_7(held, target, held, drawx, drawy);
            proc14_2;
            proc27_10(held);
            proc14_2
          end
        end
      end
    end
  until (odd(proc22_2(1)) and (lastcode = 0)) or (held = 0) or odd(data29.words[347]);
  if held <> 0 then
  begin
    lastcode := held;
    proc27_7(held, lastitem, held, drawx, drawy);
    proc14_8(lastcode, lastitem);
    proc14_2;
    proc27_12(lastitem);
    proc27_9('')
  end
  else
  begin
    proc14_2;
    proc27_12(target)
  end;
  proc27_4(0)
end;
