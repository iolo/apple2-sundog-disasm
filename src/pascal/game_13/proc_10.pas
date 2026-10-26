{ game_13 procedure10, $04D8..$0613, attributes $0620; nested in3.
  First input1 poll may self-EXIT before display updates; second poll always
  runs before the word347 test. Typed NEQ6 comparisons use only flag bit0. }
procedure proc13_10;
begin
  repeat
    data29.words[354] := data29.words[354] + 1;
    if data29.words[354] >= data29.words[353] then
    begin
      proc24_9;
      proc13_7;
      proc13_8(10, 13, data29.pos72)
    end;
    if odd(proc22_2(1)) then exit(proc13_10);
    if (g13s.words[5] > 0) and not data29.flags82[0] then
    begin
      g13s.words[5] := 0;
      proc22_19(g13s.charge14, 8);
      proc22_19(data29.bounds11, 0);
      proc22_46(13, 6);
      proc22_48('no charge');
      proc13_4(10, 15);
      proc22_48('(none)')
    end
    else if (g13s.words[5] = 1) and (data29.words[223] >= data29.words[222]) then
    begin
      g13s.words[5] := 2;
      proc22_19(g13s.charge14, 8);
      proc22_46(13, 6);
      proc22_48('charged');
      g13s.words[16] := g13s.words[16] - 6;
      proc22_19(g13s.charge14, 3);
      proc22_19(data29.bounds11, 0)
    end;
    if odd(g13s.words[7]) <> data29.flags82[1] then
    begin
      g13s.words[7] := 0;
      proc22_19(g13s.engine10, 8);
      proc22_46(13, 8);
      proc22_48('power off');
      proc13_4(10, 17);
      proc22_48('(none)')
    end;
    if odd(g13s.words[6]) <> data29.flags82[25] then
    begin
      g13s.words[6] := 0;
      proc22_46(0, 20);
      proc22_14(data29.words[19], data29.words[19] + 126,
                data29.words[18] - 7, data29.words[18]);
      proc22_7(8);
      proc22_19(data29.bounds11, 0)
    end
  until odd(proc22_2(1)) or odd(data29.words[347])
end;
