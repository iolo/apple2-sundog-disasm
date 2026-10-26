{ library_24 procedure13, $0690..$0A8D, attributes $0AAA.
  Retains the original damage-loop variable reuse and effectful call order.
  Byte offsets are relative to DATASEG29, whose word90 starts at byte178. }
procedure proc24_13;
var
  base: integer;
  offset: integer;
  group: integer;
  column: integer;
  saved: integer;
  work: integer;
  before: integer;
  randomv: integer;
  testflag: boolean;
  savedflag: boolean;
begin
  if (data29.words[217] > 128) or (data29.words[216] = 0) then begin
    data29.flags82[40] := false;
    if data29.nibbles45[2] >= 2 then begin
      proc22_12(32, 103);
      proc22_11(0);
      proc22_9(32);
      proc22_11(1)
    end else proc22_19(data29.bnd303, 5)
  end;
  saved := data29.words[216];
  if (data29.words[215] > 0) and (data29.nibbles45[2] <> 1) then begin
    before := data29.words[206];
    data29.words[206] := proc22_32(before + proc22_30(data29.words[209], 3), 1023);
    before := data29.words[205];
    data29.words[205] := proc22_32(before + proc22_30(data29.words[208], 3), 1023);
    before := data29.words[217];
    data29.words[217] := before + proc22_30(data29.words[207], 2);
    if data29.words[217] < 5 then data29.words[217] := 5;
    data29.words[215] := data29.words[215] - 4
  end else if data29.words[215] <= 0 then begin
    proc24_11(data29.words[209]);
    proc24_11(data29.words[208]);
    { $075C..$0786: both random-producing calls always execute. }
    testflag := saved < proc22_40(20, 80);
    testflag := testflag or (data29.loc73.mid5 > 0);
    savedflag := data29.flags82[12];
    randomv := proc22_3;
    testflag := testflag or (savedflag and odd(randomv)) or data29.flags82[29];
    if testflag then begin
      data29.words[207] := 2;
      data29.words[215] := 130;
      data29.flags82[44] := false;
      data29.flags82[29] := false;
      if data29.flags82[12] then data29.flags82[46] := true
    end else begin
      work := proc22_31(data29.bytes[371] + 40, 1);
      if data29.words[217] < 40 then data29.words[207] := 1
      else if data29.words[217] >= work then data29.words[207] := -1
      else begin
        randomv := proc22_3;
        data29.words[207] := proc22_32(randomv, 1) - 1
      end;
      if data29.words[207] < 0 then
        data29.words[215] := data29.words[217] - 10
      else begin
        randomv := proc22_3;
        data29.words[215] := randomv mod (work - data29.words[217]);
        data29.bytes[371] := work
      end;
      if data29.words[214] = 0 then begin
        data29.words[207] := proc22_30(data29.words[207], 1);
        data29.words[215] := proc22_31(data29.words[215], 1)
      end
    end
  end;
  { $084C: processing a pending event and scheduling one are distinct paths. }
  if data29.flags82[45] then begin
    data29.flags82[45] := false;
    data29.flags82[43] := true;
    before := data29.words[217];
    testflag := before < proc22_40(15, 70);
    randomv := proc22_3;
    if testflag and odd(randomv) then begin
      if data29.nibbles45[2] = 1 then begin
        proc22_19(data29.bnd343, 3);
        proc22_19(data29.bnd343, 3)
      end;
      randomv := proc22_3;
      work := 1 + proc22_32(randomv, 3);
      offset := proc22_30(data29.words[214], 1);
      work := proc22_30(work, offset + 9);
      if work <= 0 then work := 32767;
      work := work div data29.words[217];
      if work <= data29.words[225] then begin
        proc22_4(5, 50, 50, 0, 0, 0, 1);
        data29.words[225] := data29.words[225] - work
      end else begin
        proc22_4(5, 80, 50, 0, 0, 0, 1);
        work := work - data29.words[225];
        data29.words[225] := 0;
        { $08FD: execute at least once; work is also the selected byte below. }
        repeat
          randomv := proc22_3;
          group := proc22_32(randomv, 7);
          if group = 7 then group := 6;
          base := 28 * group;
          if data29.bytes[178 + base + 24] = 0 then group := 6;
          { $0922 changes group only: deliberately do not recompute base. }
          if group = 6 then begin
            before := data29.bytes[178 + base + 24];
            randomv := proc22_3;
            offset := before - (randomv mod 3 + 1);
            if offset <= 0 then begin
              offset := 0;
              work := 0;
              data29.words[347] := 1;
              proc22_19(data29.bounds7, 3);
              proc22_17(true);
              proc22_19(data29.bounds3, 3);
              proc22_17(false);
              data29.nibbles45[2] := 12
            end;
            data29.bytes[178 + base + 24] := offset
          end else begin
            column := data29.bytes[178 + base + 27];
            randomv := proc22_3;
            offset := 5 * proc22_32(randomv, 3);
            if data29.bytes[178 + base + offset + column] <>
               data29.bytes[178 + base + 26] then begin
              randomv := proc22_3;
              column := proc22_32(randomv, 3)
            end;
            offset := offset + column;
            work := data29.bytes[178 + base + offset];
            if work = 23 then begin
              column := base;
              repeat
                testflag := data29.bytes[178 + column] = 23;
                randomv := proc22_3;
                if testflag and odd(randomv) then
                  data29.bytes[178 + column] := 23 + 128;
                column := column + 1
              until column = base + 20
            end;
            if (work > 7) and (work < 128) then begin
              data29.bytes[178 + base + 25] := offset;
              data29.bytes[178 + base + offset] := work + 128;
              proc24_8(group)
            end
          end;
          work := work - 512
        until work <= 0
      end;
      proc24_7(data29.bnd315, data29.words[225], 4, 5)
    end
  end else if data29.flags82[44] and not data29.flags82[12] then begin
    before := data29.words[217];
    testflag := before < proc22_40(15, 70);
    randomv := proc22_3;
    data29.flags82[45] := testflag and odd(randomv)
  end;
  { $0A51: independent phase signal, then restore the saved word216. }
  if not data29.flags82[2] and (data29.words[352] = 2) then begin
    proc22_4(15, 150, 20, 253, 0, 0, 0);
    if data29.nibbles45[2] >= 2 then begin
      proc22_12(32, 103);
      proc22_11(1);
      proc22_9(42)
    end
  end;
  data29.words[216] := saved
end;
