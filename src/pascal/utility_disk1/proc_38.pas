{ utility_disk1:38 $1620..$16E3, attributes$16F4, nested in31.
  VAR active slot1; locals2 column,3 row,4 y,5 x,6 unused,7 key pointer.
  Wait for input1 release initially; input1 deletion has priority over input0.
  Wait for input0 release after a key action before undoing its highlight. }
procedure util1_38(var active: boolean);
var
  column: integer;
  row: integer;
  y: integer;
  x: integer;
  unused: integer;
  key: utilkptr;
begin
  active := true;
  proc22_44;
  proc22_48('Name: ');
  proc22_42(x, y, 1, namework.cursor152);
  namework.done169 := false;
  util1_35;
  repeat until not odd(proc22_2(1));
  repeat
    proc22_43(x, y);
    if odd(proc22_2(1)) then util1_34(active)
    else if odd(proc22_2(0)) then
    begin
      proc22_41(x, y);
      column := (x - namework.words[155]) div 13;
      row := (y - namework.words[153]) div 12;
      proc22_4(5, 50, 10, 0, 0, 0, 0);
      key := @namework.keys[row, column];
      proc22_19(key^.bounds, 3);
      if key^.code.low = 96 then util1_35
      else if key^.code.low = 43 then util1_37
      else util1_36(key^.code.low);
      repeat until not odd(proc22_2(0));
      proc22_19(key^.bounds, 3);
      proc22_41(x, y)
    end
  until namework.done169 or (not active);
  proc22_41(x, y)
end;
