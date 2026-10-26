{ game_8 procedure17, $0944..$0ADC, attributes $0AF2.
  Local5 changes role from rest byte to item index on the later path; retain
  this reuse and the four-entry masked search even though the start is MOD3. }
procedure proc8_17;
var
  threshold: integer;
  start: integer;
  value: integer;
  phase: integer;
  work: integer;
  stamp: clock4;
  zeros: wordpair;
  inputv: integer;
  randomv: integer;
begin
  zeros.first := 0;
  zeros.second := 0;
  proc22_19(g8b26, 3);
  data29.bounds327 := data31.bounds6;
  proc22_19(data29.bounds327, 8);
  work := data29.bytes[119];
  data29.flags82[59] := true;
  phase := 0;
  stamp := data29.clock42;
  repeat
    data29.words[347] := 0;
    proc8_3(false, false);
    phase := phase + 1;
    if phase = 2 then begin
      if work < 255 then begin
        work := work + 1;
        data29.bytes[119] := work;
        if (work + 1) mod 8 = 0 then data29.flags82[60] := true
      end;
      phase := 0
    end;
    if (data29.nibbles45[2] = 10) and (work > 128) then
      data29.nibbles45[2] := 7;
    inputv := proc22_2(1)
  until odd(inputv) and (data29.nibbles45[2] <> 10);
  if data29.nibbles45[2] = 12 then g8a3[19] := 1
  else if data29.flags45[13] and
          ((data29.nibbles45[1] = 3) or (data29.nibbles45[1] = 5)) and
          not data29.flags82[57] then begin
    threshold := data29.tbl23.rows^[data29.loc37.low4].nibbles8[3];
    proc22_26(stamp, 10 + 4 * threshold);
    while proc22_27(stamp) do begin
      proc22_19(data31.bounds6, 8);
      randomv := proc22_3;
      randomv := proc22_32(randomv, 15);
      if threshold < randomv then begin
        randomv := proc22_3;
        if odd(randomv) and ((data29.words[46] <> zeros.first) or
                            (data29.words[47] <> zeros.second)) then
          data29.money46 := zeros
        else begin
          randomv := proc22_3;
          work := randomv mod 3;
          start := work;
          repeat
            value := data29.bytes[122 + work];
            if value > 0 then begin
              proc8_9(1 + work + data31.words[14]);
              proc22_21(0, false);
              proc27_3(g8a3[7], g8a3[6]);
              proc22_21(0, false);
              work := start
            end else work := proc22_32(work + 1, 3)
          until work = start
        end
      end;
      proc22_26(stamp, 60)
    end
  end;
  data29.flags82[59] := false;
  proc22_18(data29.bounds327, 0, 0, 0, 0);
  proc27_9('');
  proc22_19(g8b26, 3)
end;
