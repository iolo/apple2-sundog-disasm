{ game_14 procedure3, $0012..$02A0, attributes $02AE.
  Value argument is slot1; locals2..7 retain original positions. The caption
  "Tactical Disply" is the original15-byte literal. No unselected titles or
  bounds are initialized. Arithmetic order retains signed word DIV. }
procedure proc14_3(mode: integer);
var
  second: integer;
  first: integer;
  index: integer;
  height: integer;
  x: integer;
  last: integer;
begin
  g14.words[104] := ord(mode <= 7);
  g14.words[103] := ord(mode = 7);
  if odd(g14.words[103]) then
  begin
    if data29.nibbles45[1] = 5 then
    begin
      first := arg2;
      second := arg1
    end
    else
    begin
      first := 21;
      second := 15
    end
  end;
  case mode of
    5: proc22_51(17, 13);
    6: proc22_51(17, 0);
    7: proc22_51(first, second);
    8,9,10: proc22_51(23, 7);
    11,12,13: proc22_51(23, 17)
  end;
  data31.words[12] := 7 * (data29.words[14] div 7);
  data31.words[11] := 8 * (data29.words[12] div 8);
  case mode of
    5,6: proc27_13(3);
    7: proc27_13(5);
    8,9,10,11,12,13: proc27_13(2)
  end;
  if odd(g14.words[103]) then height := 44 else height := 12;
  proc22_18(g14.title82, data31.words[12] + 39, data31.words[12] + 133,
            data31.words[11] + 2, data31.words[11] + height);
  if odd(g14.words[103]) then height := 47 else height := 15;
  if odd(g14.words[104]) then x := data31.words[12] + 40
  else x := data31.words[12] + 74;
  proc22_18(g14.panel78, x, data31.words[12] + 133,
            data31.words[11] + height, data31.words[11] + 80);
  proc22_19(g14.title82, 8);
  proc22_19(g14.panel78, 8);
  if not odd(g14.words[104]) then
  begin
    proc22_14(data31.words[12] + 40, data31.words[12] + 70,
              data31.words[11] + 14, data31.words[11] + 80);
    proc22_7(8);
    x := 7 * ((data31.words[12] + 40) div 7 + 1);
    proc22_18(g14.meter74, x, x + 6, data31.words[11] + 15, data31.words[11] + 80);
    x := x + 14;
    height := data31.words[11] + 19;
    index := 0;
    last := 3;
    while index <= last do
    begin
      proc22_18(g14.lamps86[index], x, x + 6, height, height + 7);
      height := height + 16;
      index := index + 1
    end
  end;
  if not odd(g14.words[104]) then
  begin
    g14.captions[0] := 'Warp Drives';
    g14.captions[1] := 'Sub-c Engines';
    g14.captions[2] := 'Ship''s Guns';
    g14.captions[3] := 'Tactical Disply';
    g14.captions[4] := 'Force Shields';
    g14.captions[5] := 'Pilotage'
  end
  else if not odd(g14.words[103]) then
  begin
    g14.captions[6] := 'Ship''s Locker';
    g14.captions[7] := 'Ship''s Stores'
  end;
  if odd(g14.words[104]) then g14.words[9] := 6 + (mode - 5)
  else g14.words[9] := (mode - 8) - 1;
  if odd(g14.words[103]) then g14.words[4] := 28 * (g14.words[9] - 1) + 20
  else g14.words[4] := 28 * g14.words[9]
end;
