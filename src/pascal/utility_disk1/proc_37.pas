{ utility_disk1:37 $142E..$160C, attributes$161E, nested in31.
  Locals1..4 saved cursor,5..8 saved display,9 index,10 width,11 height,
  12 choice,13 y,14 duplicate,15 limit. Trim length byte without updating
  parent length171, as in the original. Compare all four names regardless
  of slot state. Restore both bounds before cursor calls on global5/4. }
procedure util1_37;
var
  savedcur: bounds4;
  savedscr: bounds4;
  index: integer;
  width: integer;
  height: integer;
  choice: integer;
  y: integer;
  duplicate: boolean;
  limit: integer;
begin
  savedscr := data29.bounds11;
  savedcur := namework.cursor152;
  proc22_51(20, 12);
  while (namework.namebytes[1] = 32) and (namework.namebytes[0] > 0) do
    delete(namework.name161, 1, 1);
  index := namework.namebytes[0];
  while (index > 0) and (namework.namebytes[index] = 32) do index := index - 1;
  namework.namebytes[0] := index;
  proc22_45;
  proc22_48('Your character name is:  ');
  proc22_48(namework.name161);
  proc22_45;
  proc22_45;
  duplicate := false;
  index := 0;
  limit := 3;
  while index <= limit do
  begin
    if (namework.name161 = u1.slots[index].caption) and (index <> u1.words[6]) then
      duplicate := true;
    index := index + 1
  end;
  if namework.namebytes[0] = 0 then
  begin
    proc22_48('You must choose a name.  Please do so.');
    namework.done169 := false;
    util1_5(3000)
  end
  else if duplicate then
  begin
    proc22_48('This name is already in use.  Please choose another.');
    namework.done169 := false;
    util1_5(3000)
  end
  else
  begin
    proc22_48('Is this correct?');
    proc25_2;
    height := data29.words[11] - data29.words[12] - 3;
    width := data29.words[13] - data29.words[14] - 4;
    y := height - 25;
    proc25_3(1, 'Yes', 4, width, y, y + 10);
    y := y + 15;
    proc25_3(2, 'No', 4, width, y, y + 10);
    proc26_5(choice, 0);
    namework.done169 := choice = 1
  end;
  proc22_52;
  data29.bounds11 := savedscr;
  namework.cursor152 := savedcur;
  proc22_42(u1.words[5], u1.words[4], 1, namework.cursor152);
  proc22_41(u1.words[5], u1.words[4]);
  if not namework.done169 then
  begin
    proc22_44;
    proc22_48('Name: ');
    proc22_48(namework.name161)
  end
end;
