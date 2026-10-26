{ game_17 procedure16, $08D4..$0B3A, attributes $0B4C.
  Capture entry1 before input. Input selectors0/1 and both selector5 calls
  retain their original unconditional evaluation within the respective paths. }
procedure proc17_16;
var
  firststep, secondstep, oldfirst, oldsecond, index: integer;
  input0, input1, input5, ignored: integer;
  saved48, saved78: boolean;
begin
  with g17.items[1] do
  begin
    proc22_43(g17.words[98], g17.words[97]);
    firststep := 0;
    secondstep := 0;
    if (life <= 32) or data29.flags82[48] then
    begin
      saved48 := data29.flags82[48];
      saved78 := g17.words[78] = 1;
      input0 := proc22_2(0);
      input1 := proc22_2(1);
      if saved48 and saved78 and (odd(input0) or odd(input1)) then
      begin
        g17.words[78] := 0;
        delay := 0;
        data29.flags82[48] := false
      end
      else if delay > 0 then delay := delay - 1;
      if (delay = 0) and (g17.words[78] = 1) then
      begin
        if not data29.flags82[48] then
        begin
          index := 0;
          while index <= 3 do
          begin
            data29.bytes[122 + index] := 0;
            index := index + 1
          end
        end;
        data29.words[47] := 0;
        data29.words[46] := 0;
        g17.words[40] := 0;
        g17.words[41] := 0;
        g17.words[78] := 2;
        data29.flags82[48] := false
      end
      else if (delay <= 0) and (g17.words[94] = 1) then
      begin
        g17.words[42] := 1;
        data29.flags82[48] := false
      end
    end
    else
    begin
      if odd(proc22_2(4)) then
      begin
        firststep := proc22_34(g17.words[98] - 3 - first);
        secondstep := proc22_34(g17.words[97] + 3 - second);
        oldfirst := first;
        oldsecond := second;
        proc22_22(draw, code, firststep, secondstep, first, second);
        if (oldfirst = first) and (oldsecond = second) then
        begin
          proc22_41(g17.words[98], g17.words[97]);
          proc22_22(draw, code, firststep, secondstep, first, second);
          proc22_41(g17.words[98], g17.words[97])
        end
      end
      else
      begin
        firststep := 0;
        secondstep := 0
      end;
      if (first < g17.words[87] + 7) or (first > g17.words[86] - 12)
         or (second < g17.words[85] + 12) or (second > g17.words[84] - 8) then
        g17.words[42] := 1;
      ignored := proc22_2(5);
      input5 := proc22_2(5);
      if odd(input5) and active and (g17.words[78] < 2) then
      begin
        proc22_41(g17.words[98], g17.words[97]);
        proc17_14(1, g17.words[98] - 3, g17.words[97] + 3);
        if odd(g17.words[40]) then
        begin
          proc17_14(1, g17.words[98] - 3, g17.words[97] - 3);
          proc17_14(1, g17.words[98] - 3, g17.words[97] + 6);
          proc17_14(1, g17.words[98] + 3, g17.words[97] - 3);
          proc17_14(1, g17.words[98] - 6, g17.words[97] - 3);
          g17.words[75] := g17.words[75] - 1;
          if g17.words[75] = 0 then
          begin
            g17.words[40] := 0;
            data29.bytes[122] := 7;
            proc22_4(10, 10, 50, 0, 0, 0, 1);
            proc17_7
          end
        end;
        proc22_41(g17.words[98], g17.words[97]);
        g17.words[78] := 0
      end
    end;
    g17.words[90] := (g17.words[90] + 1) mod 7;
    { Both pointers were captured in the original. The trail index is read
      once here; the following stores contain no calls or index changes. }
    index := g17.words[90];
    g17.trail[index].first := first;
    g17.trail[index].second := second;
    g17.trail[index].word1 := firststep;
    g17.trail[index].word0 := secondstep;
    g17.words[89] := (g17.words[90] + 1) mod 7
  end
end;
