{ game_20 procedure30, $16F4..$17FD, attributes $1808; nested in28.
  Snapshot selected before the unconditional input1 call. Flash input passes
  the same selected address twice, as at $17D4/$17D6. }
procedure proc20_30(viewmode: integer; var picked: integer);
var
  firstbase, secondbase, firstpos, secondpos, found, selected: integer;
  area: bounds4;
  stopnow: boolean;
  key: integer;
begin
  proc22_18(area, data29.words[14], data29.words[13],
              data29.words[12] + 20, data29.words[11] - 20);
  proc25_2;
  if odd(g20.words[16]) then
    if odd(g20.words[17]) then
      proc20_9(10, 2, 2, 'Delivery', 'Warehouse', '')
    else proc20_9(10, 0, 1, 'Exit center', '', '')
  else if viewmode = 0 then
    proc20_9(10, 4, 2, 'Exchange', 'Warehouse', '')
  else proc20_9(10, 1, 2, 'Buy', 'Sell', '');
  proc25_6(area);
  proc22_42(firstpos, secondpos, data29.words[297], area);
  firstbase := area.lower_first;
  secondbase := area.lower_second;
  found := 0;
  selected := 0;
  picked := 0;
  repeat
    proc20_29;
    proc22_43(firstpos, secondpos);
    if odd(proc22_2(0)) then
    begin
      proc25_7(firstpos - firstbase, secondpos - secondbase, picked, found);
      if found > 0 then
      begin
        proc25_8(found, picked, area, selected, selected);
        proc22_4(10, 50, 30, 0, 0, 0, 0);
        selected := 1
      end
    end;
    stopnow := odd(selected);
    key := proc22_2(1)
  until stopnow or odd(key) or odd(data29.words[347]);
  proc22_41(firstpos, secondpos)
end;
