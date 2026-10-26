{ game_18 procedure 12, $0498..$075D, attributes $0778.
  Include in procedure 1 after procedures 2, 6, 10, and 11.
  WITH retains the original entry address across native calls. }
procedure proc18_12(index: integer);
var
  delta2, delta1, old2, old1, step2, step1: integer;
  randomv: integer;
  inbounds: boolean;
begin
  with g18items[index] do
  begin
    { $04A0..$0525: derive signed steps toward words 1/0. Keep word arithmetic. }
    if (words[5] <> words[1]) or (words[4] <> words[0]) then
    begin
      if index = 1 then
        proc22_41(g18a133[134], g18a133[133]);
      delta1 := words[1] - words[5];
      step1 := proc22_34(delta1);
      step1 := step1 + step1;
      if proc22_35(step1) > proc22_35(delta1) then step1 := delta1;
      delta2 := words[0] - words[4];
      step2 := proc22_34(delta2);
      step2 := step2 + step2;
      if proc22_35(step2) > proc22_35(delta2) then step2 := delta2;
      old1 := words[5];
      old2 := words[4];
      proc22_22(split6.high, split6.low, step1, step2, words[5], words[4]);
      if index = 1 then
      begin
        { $052D..$0568: retry only axes whose coordinates did not change. }
        if old1 <> words[5] then step1 := 0;
        if old2 <> words[4] then step2 := 0;
        proc22_22(split6.high, split6.low, proc22_34(step1),
                  proc22_34(step2), words[5], words[4]);
        proc22_41(g18a133[134], g18a133[133])
      end
      else if (old1 = words[5]) and (old2 = words[4]) then
      begin
        { $0578..$05AD: surround the second movement attempt with calls 41. }
        proc22_41(g18a133[134], g18a133[133]);
        proc22_22(split6.high, split6.low, step1, step2, words[5], words[4]);
        proc22_41(g18a133[134], g18a133[133]);
        if (old1 = words[5]) and (old2 = words[4]) then
        begin
          { $05B0..$05C4: the bounds call is evaluated on either flag value. }
          inbounds := proc18_2(words[5], words[4], g18b107);
          if (flags.high_byte = 3) and inbounds then
          begin
            words[1] := words[5];
            words[0] := words[4];
            words[3] := words[5];
            words[2] := words[4]
          end
          else
          begin
            { $05DE: FJP tests bit 0 of the random word, not nonzero. }
            randomv := proc22_3;
            if odd(randomv) then
            begin
              words[1] := words[5] + proc22_40(-7, 7);
              words[0] := words[4] + proc22_40(-7, 7);
              if words[1] = words[5] then
                words[0] := words[4] + proc22_40(-2, 2);
              if words[0] = words[4] then
                words[1] := words[5] + proc22_40(-2, 2)
            end
            else
            begin
              { $062D..$0641: reread the flag after procedure 10. }
              flags.bit5 := false;
              proc18_10(index);
              if not flags.bit5 then proc18_11(index)
            end
          end
        end
      end
      { All moving paths join $0643 and return at $075D. }
    end
    else if (words[3] <> words[1]) or (words[2] <> words[0]) then
    begin
      { $0645..$065C. }
      words[1] := words[3];
      words[0] := words[2]
    end
    else
    begin
      { $065E..$067D: only the first matching parent reference is cleared. }
      flags.bit5 := false;
      if index = g18a112[124] then g18a112[124] := 0
      else if index = g18a112[123] then g18a112[123] := 0;
      if flags.high_byte = 1 then
      begin
        words[3] := g18items[1].words[5];
        words[2] := g18items[1].words[4];
        flags.bit5 := true
      end
      else if flags.high_byte = 2 then
        proc18_6(index)
      else if flags.high_byte = 3 then
      begin
        flags.bit3 := true;
        flags.bit4 := false;
        bytes9[0] := 0;
        g18a112[125] := g18a112[125] + 1;
        flags.high_byte := 0
      end
      else if flags.high_byte >= 4 then
      begin
        { $06EF..$075C; old1/old2 are now row/column temporaries. }
        flags.bit2 := true;
        if g18items[1].flags.bit2 then
        begin
          old1 := (flags.high_byte - 4) div 2;
          old2 := (flags.high_byte + 1) mod 2;
          if g18refs[old1][old2] = 1 then
          begin
            if flags.bit0 then
            begin
              if flags.bit1 then g18a112[116] := 17
              else g18a112[116] := 22
            end
            else g18a112[116] := 21;
            g18a133[141] := 1;
            data29.bytes[550] := index
          end
        end;
        flags.high_byte := 0
      end
    end
  end
end;
