{ utility_disk1:4 $1E3E..$1EE3, attributes$1EF0. Result slots1/2,
  locals3 tone,4 middle,5 selected pointer. No prompt for an empty slot.
  Preserve the second state read after menu calls and both mode3 inversions. }
function util1_4: boolean;
var
  tone: integer;
  middle: integer;
  selected: utilptr;
begin
  util1_4 := true;
  selected := @u1.slots[u1.words[6]];
  if selected^.words[8] > 0 then
  begin
    proc22_14(data29.words[14], data29.words[13],
              data29.words[11] - 30, data29.words[11]);
    proc22_7(8);
    proc22_19(data29.bounds11, 0);
    proc22_46(7, 16);
    proc22_48('Delete?');
    middle := (u1.words[10] + u1.words[9]) div 2;
    proc25_2;
    proc25_3(1, 'Yes', u1.words[10], middle - 2,
              u1.words[7] - 10, u1.words[7]);
    proc25_3(2, 'No', middle + 2, u1.words[9],
              u1.words[7] - 10, u1.words[7]);
    if selected^.words[8] = 3 then
    begin
      proc22_19(data29.bounds11, 3);
      tone := 14
    end
    else tone := 7;
    proc22_4(10, 100, 40, 252, 1, tone, 0);
    if tone = 14 then proc22_19(data29.bounds11, 3);
    proc26_5(u1.words[11], 0);
    util1_4 := u1.words[11] = 1
  end
end;
