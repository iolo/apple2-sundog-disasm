{ game_20 procedure24, $1258..$146A, attributes $1478.
  paid is copied on entry but otherwise unused. Selling returns pod indices
  as5/6; buying can fall back to the other storage and retains the wait call. }
procedure proc20_24(var item: stock4; var index: integer; paid: wordpair;
                    selling: boolean);
var
  choice, found, selected, column, row: integer;
  pods: boolean;
begin
  index := 0;
  proc22_44;
  proc25_2;
  if odd(g20.words[17]) then
  begin
    proc20_9(2, 1, 2, 'Warehouse', 'Pod', '');
    proc22_46(0, 5);
    if selling or odd(g20.words[16]) then
    begin
      if odd(g20.words[16]) then proc22_48('|Deliver') else proc22_48('|  Sell');
      proc22_48(' from where?')
    end
    else proc22_48('||||Store where?');
    proc20_8(choice, found, data29.words[297], data29.bounds11, selected)
  end
  else
  begin
    choice := 1;
    if selling then proc22_48('|     WAREHOUSE')
  end;
  pods := choice = 2;
  proc22_46(0, 5);
  if selling then
  begin
    if choice = 0 then exit(proc20_24);
    row := data29.words[18] - 2;
    if odd(g20.words[16]) then proc22_48('|  Deliver') else proc22_48('|    Sell');
    proc22_48(' which?      ');
    column := data29.words[19];
    row := data29.words[18] + 2;
    proc20_12(index, pods, column, row)
  end
  else
  begin
    if choice = 0 then pods := true;
    proc20_11(index, pods)
  end;
  if not selling then
  begin
    proc22_44;
    if (index <= 0) and odd(g20.words[17]) then
    begin
      proc22_48('No space in ');
      if pods then proc22_48('pod.  ') else proc22_48('warehouse.  ');
      pods := not pods;
      proc20_11(index, pods)
    end;
    proc22_48('  Storing cargo in ');
    if pods then proc22_48('pod.') else proc22_48('warehouse.');
    proc20_2
  end;
  if index > 0 then
    if selling then
      if pods then
      begin
        item := data29.stock234[index];
        index := index + 4
      end
      else item := g20.ware52[index]
    else if pods then
    begin
      data29.stock234[index] := item;
      data29.labels238[index] := g20.names19.names^[item.kind]
    end
    else g20.ware52[index] := item
end;
