{ game_20 procedure24, $1258..$146A, attributes $1478.
  paid is copied on entry but otherwise unused. Selling returns pod indices
  as5/6; buying can fall back to the other storage and retains the wait call. }
procedure select_trade_storage(var item: stock4; var index: integer; paid: wordpair;
                    selling: boolean);
var
  choice, found, selected, column, row: integer;
  pods: boolean;
begin
  index := 0;
  clear_text_window;
  reset_menu;
  if odd(g20.pods_available) then
  begin
    add_exchange_buttons(2, 1, 2, 'Warehouse', 'Pod', '');
    set_text_grid_position(0, 5);
    if selling or odd(g20.contract_mode) then
    begin
      if odd(g20.contract_mode) then write_wrapped_text('|Deliver') else write_wrapped_text('|  Sell');
      write_wrapped_text(' from where?')
    end
    else write_wrapped_text('||||Store where?');
    poll_exchange_menu(choice, found, data29.words[297], data29.bounds11, selected)
  end
  else
  begin
    choice := 1;
    if selling then write_wrapped_text('|     WAREHOUSE')
  end;
  pods := choice = 2;
  set_text_grid_position(0, 5);
  if selling then
  begin
    if choice = 0 then exit(select_trade_storage);
    row := data29.text_y - 2;
    if odd(g20.contract_mode) then write_wrapped_text('|  Deliver') else write_wrapped_text('|    Sell');
    write_wrapped_text(' which?      ');
    column := data29.text_x;
    row := data29.text_y + 2;
    choose_cargo_slot(index, pods, column, row)
  end
  else
  begin
    if choice = 0 then pods := true;
    find_empty_cargo_slot(index, pods)
  end;
  if not selling then
  begin
    clear_text_window;
    if (index <= 0) and odd(g20.pods_available) then
    begin
      write_wrapped_text('No space in ');
      if pods then write_wrapped_text('pod.  ') else write_wrapped_text('warehouse.  ');
      pods := not pods;
      find_empty_cargo_slot(index, pods)
    end;
    write_wrapped_text('  Storing cargo in ');
    if pods then write_wrapped_text('pod.') else write_wrapped_text('warehouse.');
    wait_exchange_buttons
  end;
  if index > 0 then
    if selling then
      if pods then
      begin
        item := data29.stock234[index];
        index := index + 4
      end
      else item := g20.warehouse_items[index]
    else if pods then
    begin
      data29.stock234[index] := item;
      data29.labels238[index] := g20.cargo_names.names^[item.kind]
    end
    else g20.warehouse_items[index] := item
end;
