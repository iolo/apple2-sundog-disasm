{ game_17 procedure17, $0B4E..$0D52, attributes $0D62.
  Entry addresses stay captured across calls and record compaction. Removing
  an entry decrements the scan index before the common increment. }
procedure proc17_17;
var
  index, trailidx, randomv, oldfirst, oldsecond: integer;
begin
  index := 2;
  while index <= g17.words[94] do
  begin
    randomv := proc22_3;
    trailidx := randomv mod 7;
    proc22_43(g17.words[98], g17.words[97]);
    { Keep the original post-input comparison, even though a stable count
      would make index=count+2 impossible inside this loop. }
    if index = g17.words[94] + 2 then proc17_16;
    with g17.items[index] do
    begin
      if delay > 0 then delay := delay - 1;
      if life <= 32 then
      begin
        if delay <= 0 then
        begin
          proc17_3(index);
          if life > 0 then
          begin
            draw := 23;
            proc17_3(index);
            life := 33
          end
          else
          begin
            proc17_4(index);
            index := index - 1
          end
        end
      end
      else
      begin
        g17.words[95] := proc22_35(g17.trail[trailidx].first - first)
                        + proc22_35(g17.trail[trailidx].second - second);
        if (g17.words[78] = 2) or data29.flags82[50] then
        begin
          g17.words[93] := proc22_34(first - g17.trail[trailidx].first);
          g17.words[92] := proc22_34(second - g17.trail[trailidx].second)
        end
        else if (g17.words[95] > 35) or (g17.words[78] = 1) then
        begin
          g17.words[93] := proc22_34(g17.trail[trailidx].first - first);
          g17.words[92] := proc22_34(g17.trail[trailidx].second - second)
        end
        else
        begin
          g17.words[93] := 0;
          g17.words[92] := 0;
          randomv := proc22_3;
          if odd(randomv) then g17.words[93] := g17.trail[trailidx].word1
          else g17.words[92] := g17.trail[trailidx].word0
        end;
        oldfirst := first;
        oldsecond := second;
        proc22_22(draw, code, g17.words[93], g17.words[92], first, second);
        if (oldfirst = first) and (oldsecond = second) then
        begin
          proc22_41(g17.words[98], g17.words[97]);
          proc22_22(draw, code, g17.words[93], g17.words[92], first, second);
          if (oldfirst = first) and (oldsecond = second)
             and (g17.words[78] = 2) then
          begin
            proc17_3(1);
            proc22_22(draw, code, g17.words[93], g17.words[92], first, second);
            proc17_3(1)
          end;
          proc22_41(g17.words[98], g17.words[97])
        end;
        if (first < g17.words[87] + 5) or (first > g17.words[86] - 12)
           or (second < g17.words[85] + 10) or (second > g17.words[84] - 5) then
        begin
          proc17_4(index);
          index := index - 1
        end
        else if (g17.words[78] = 0) and (delay <= 0)
                and not data29.flags82[50] then
        begin
          proc17_14(index, g17.trail[trailidx].first, g17.trail[trailidx].second);
          { The call may shift records. Write through the previously captured
            entry address and read its current radius after that call. }
          delay := 10 - radius
        end
      end
    end;
    index := index + 1
  end
end;
