{ library_24 procedure15, $0BE2..$0DF4, attributes $0E04.
  Preserve parent slot15 sharing with nested16. It can overwrite the saved
  word223 value while nested17 runs, before the later comparison reads it. }
procedure proc24_15(var amount: integer);
var
  cost223: integer;      { 2 }
  delta223: integer;     { 3 }
  randomv: integer;      { 4: originally unused }
  delta225: integer;     { 5 }
  cost226: integer;      { 6 }
  delta226: integer;     { 7 }
  savedflag: boolean;    { 8: originally unused }
  timeok: boolean;       { 9: originally unused }
  unused10: array[10..14] of integer;
  index: integer;        { 15 }
  last: integer;         { 16 }
(*$include src/pascal/library_24/proc_16.pas*)
(*$include src/pascal/library_24/proc_17.pas*)
begin
  if odd(data29.words[352]) then
  begin
    cost226 := 0;
    if (amount > 0) and (data29.bytes[258] > 0) and data29.flags82[2] then
    begin
      proc24_14(delta226, data29.words[226],
                  proc22_30(data29.bytes[258] + 1, 4), 255, 1);
      if delta226 > 0 then cost226 := 4
    end
    else if data29.words[226] > 0 then delta226 := -8
    else delta226 := 0;
    if delta226 <> 0 then
      proc24_17(data29.words[226], delta226, cost226, 255, data29.bnd319, 4, 6, 4)
  end;
  if data29.words[352] = 2 then
  begin
    if data29.words[225] <> data29.words[224] then
    begin
      proc24_14(delta225, data29.words[225],
                  proc22_30(data29.bytes[314], 3), data29.words[224], 1);
      proc24_17(data29.words[225], delta225, 0, data29.words[224], data29.bnd315, 4, 5, 7)
    end;
    if data29.words[224] > 0 then
      amount := amount - proc22_31(data29.words[224] + 1, 6)
  end;
  if (data29.words[352] = 3) and data29.flags82[12] then amount := amount - 12;
  if data29.words[352] = 4 then
    if data29.words[223] <> data29.words[222] then
    begin
      if data29.words[223] < data29.words[222] then
      begin
        randomv := proc22_3;
        if proc22_32(randomv, 15) < data29.bytes[202] then
          proc24_14(delta223, data29.words[223], 8, data29.words[222], 1)
        else delta223 := 0;
        cost223 := 2
      end
      else
      begin
        proc24_14(delta223, data29.words[223], -4, data29.words[222], -1);
        cost223 := 0
      end;
      index := data29.words[223];
      proc24_17(data29.words[223], delta223, cost223, data29.words[222],
                  data29.bnd311, 8, 9, 11);
      if odd(data29.words[349]) and data29.flags82[0] and
         (data29.words[223] = data29.words[222]) and (index < data29.words[222]) then
        data29.words[350] := 1
    end;
  proc24_16;
  if (amount = 0) and (data29.words[227] > 0) then
  begin
    index := 0;
    last := 4;
    while index <= last do
    begin
      if (index <> 2) or ((index = 0) and (data29.words[223] < data29.words[222])) then
      begin
        data29.flags82[index] := false;
        data29.flags82[index + 8] := false;
        if index = 0 then data29.words[222] := 0
      end;
      index := index + 1
    end;
    data29.words[224] := 0
  end;
  { The timestamp function is called even when flag25 is false. }
  savedflag := data29.flags82[25];
  timeok := proc22_27(data29.clock78);
  if savedflag and timeok then
  begin
    amount := 255;
    proc22_4(6, 20, 50, 0, 1, 10, 0);
    data29.flags82[25] := false;
    data29.words[350] := 1;
    if data29.flags82[40] then
    begin
      data29.words[215] := 128;
      data29.words[207] := 4
    end
  end
end;
