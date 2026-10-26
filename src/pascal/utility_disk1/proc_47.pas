{ utility_disk1:47 $1F44..$1FD7, attributes$1FE2. One local pointer captured
  before display; each status condition rereads through it after menu calls. }
procedure util1_47;
var selected: utilptr;
begin
  selected := @u1.slots[u1.words[6]];
  util1_3(u1.words[6], false);
  u1.words[10] := 4;
  u1.words[9] := data29.words[13] - data29.words[14] - 4;
  u1.words[7] := data29.words[11] - data29.words[12] - 3;
  proc25_2;
  u1.words[8] := u1.words[7] - 10;
  if selected^.words[8] = 0 then util1_45('Start new game', 1);
  if (selected^.words[8] > 0) and (selected^.words[8] < 4) then
    util1_45('Play game', 2);
  if selected^.words[8] > 0 then util1_45('Delete game', 3);
  if selected^.words[8] = 5 then util1_45('Certificate', 4)
end;
