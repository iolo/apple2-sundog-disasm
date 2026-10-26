{ utility_disk1:29 $0E04..$1007, attributes$101C. VAR selection1,32 local
  bytes. Locals2 direction,3/4 cursor y/x,5 saved points,6 candidate points,
  7 rejected value,8 edited value,9 next selection,10 minimum,11..14 arrow
  coordinates,15 unused poll result,16 selection-found flag,17 bar pointer.
  Direction2 is initially unspecified and may be read when input1 is set.
  Integer masks retain the eager poll4 in the adjustment test and all full-word
  input results. Keep the unused poll at$0FA6 and reject candidate points <=0. }
procedure util1_29(var selection: integer);
var editwork: u29frame;
begin
  if selection < 4 then editwork.words[10] := 30
  else editwork.words[10] := 0;
  editwork.words[6] := data29.bytes[94 + selection];
  editwork.words[16] := 0;
  attrwork.words[34] := 0;
  editwork.words[8] := editwork.words[6];
  editwork.words[9] := 0;
  editwork.words[5] := attrwork.words[8];
  util1_23(selection, 9);
  editwork.bar := @attrwork.bars[selection];
  proc22_19(data29.bounds11, 0);
  proc22_12(editwork.bar^.lower_first - 7, editwork.bar^.upper_second + 1);
  proc22_9(38);
  editwork.words[12] := editwork.bar^.lower_first - 7 + 3;
  editwork.words[11] := editwork.bar^.upper_second + 1 - 3;
  proc22_12(editwork.bar^.upper_first + 2, editwork.bar^.upper_second + 2);
  proc22_9(96);
  editwork.words[14] := editwork.bar^.upper_first + 2 + 3;
  editwork.words[13] := editwork.bar^.upper_second + 1 - 3;
  proc22_39(editwork.words[8], 3, false);
  while not odd(proc22_2(4)) do begin end;
  repeat
    proc22_42(editwork.words[4], editwork.words[3], 2, data29.bounds11);
    repeat
      proc22_43(editwork.words[4], editwork.words[3]);
      attrwork.words[34] := proc22_2(1)
    until odd(proc22_2(4) or attrwork.words[34]);
    proc22_41(editwork.words[4], editwork.words[3]);
    if not odd(attrwork.words[34]) then
    begin
      if proc22_35(editwork.words[4] - editwork.words[12]) +
         proc22_35(editwork.words[3] - editwork.words[11]) < 10 then
        editwork.words[2] := -1
      else if proc22_35(editwork.words[4] - editwork.words[14]) +
              proc22_35(editwork.words[3] - editwork.words[13]) < 10 then
        editwork.words[2] := 1
      else
      begin
        editwork.words[2] := 0;
        util1_28(editwork.words[4], editwork.words[3], editwork.words[9]);
        editwork.words[16] := ord(editwork.words[9] >= 0)
      end
    end;
    while odd(ord(editwork.words[8] + editwork.words[2] >= editwork.words[10])
              and ord(editwork.words[2] <> 0)
              and proc22_2(4)
              and not (attrwork.words[34] or editwork.words[16])) do
    begin
      editwork.words[8] := editwork.words[8] + editwork.words[2];
      if editwork.words[2] < 0 then
        editwork.words[6] := attrwork.words[8] + util1_27(editwork.words[8] + 1)
      else
        editwork.words[6] := attrwork.words[8] - util1_27(editwork.words[8]);
      if editwork.words[6] <= 0 then
      begin
        editwork.words[8] := editwork.words[8] - editwork.words[2];
        editwork.words[7] := editwork.words[8]
      end
      else attrwork.words[8] := editwork.words[6];
      if editwork.words[8] > 0 then
      begin
        proc22_14(editwork.bar^.lower_first,
                  editwork.bar^.lower_first + editwork.words[8],
                  editwork.bar^.lower_second, editwork.bar^.upper_second);
        proc22_7(9)
      end;
      proc22_14(editwork.bar^.lower_first + editwork.words[8],
                editwork.bar^.upper_first,
                editwork.bar^.lower_second, editwork.bar^.upper_second);
      proc22_7(8);
      proc22_19(data29.bounds11, 0);
      proc22_12(editwork.bar^.upper_first + 8, editwork.bar^.upper_second + 2);
      proc22_39(editwork.words[8], 3, false);
      util1_24;
      editwork.words[15] := proc22_2(4)
    end
  until odd(attrwork.words[34] or editwork.words[16]);
  proc22_19(data29.bounds11, 0);
  data29.bytes[94 + selection] := editwork.words[8];
  proc22_12(editwork.bar^.lower_first - 7, editwork.bar^.upper_second + 1);
  proc22_9(32);
  proc22_12(editwork.bar^.upper_first + 2, editwork.bar^.upper_second + 2);
  proc22_10('    ');
  util1_23(selection, 10);
  util1_24;
  if odd(attrwork.words[34] or ord(editwork.words[9] = selection)) then
    selection := -1
  else selection := editwork.words[9]
end;
