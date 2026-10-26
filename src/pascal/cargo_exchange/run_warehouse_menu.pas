{ game_20 procedure13, $08CC..$0A60, attributes $0A6E.
  Parent row/column slots6/7 feed nested14/15. All item moves copy two words;
  the pod caption is refreshed whenever podidx>0, including failed stores. }
procedure run_warehouse_menu;
var
  selected: integer;
  found: integer;
  choice: integer;
  unused: array[4..5] of integer;
  text_row: integer;
  text_column: integer;
  warehouse_index: integer;
  pod_index: integer;
  saved_cargo: stock4;
(*$include src/pascal/cargo_exchange/clear_warehouse_text.pas*)
(*$include src/pascal/cargo_exchange/list_warehouse_stock.pas*)
begin
  clear_text_window;
  flash_exchange_title('WAREHOUSE', g20.menu_left, g20.menu_right, g20.menu_bottom - 85);
  text_newline;
  text_newline;
  text_newline;
  text_newline;
  text_column := data29.text_x;
  text_row := data29.text_y;
  repeat
    list_warehouse_stock(text_column, text_row);
    reset_menu;
    add_exchange_buttons(g20.menu_bottom - 70, 1, 3, 'Store', 'Fetch', 'Swap');
    poll_exchange_menu(choice, found, data29.words[297], data29.bounds11, selected);
    if not odd(selected) then exit(run_warehouse_menu);
    selected := ord(choice = 3);
    fillchar(saved_cargo, 4, 0);
    pod_index := 0;
    case choice of
      1, 3:
        begin
          choose_cargo_slot(pod_index, true, text_column, text_row);
          if pod_index > 0 then
          begin
            if odd(selected) then choose_cargo_slot(warehouse_index, false, text_column, text_row)
            else find_empty_cargo_slot(warehouse_index, false);
            if warehouse_index > 0 then
            begin
              if odd(selected) then saved_cargo := g20.warehouse_items[warehouse_index];
              g20.warehouse_items[warehouse_index] := data29.stock234[pod_index];
              data29.stock234[pod_index] := saved_cargo
            end
            else if not odd(selected) then
            begin
              clear_warehouse_text;
              write_wrapped_text('No room to store in warehouse.');
              wait_exchange_buttons
            end
          end
        end;
      2:
        begin
          choose_cargo_slot(warehouse_index, false, text_column, text_row);
          if warehouse_index > 0 then
          begin
            find_empty_cargo_slot(pod_index, true);
            if pod_index > 0 then
            begin
              data29.stock234[pod_index] := g20.warehouse_items[warehouse_index];
              g20.warehouse_items[warehouse_index] := saved_cargo
            end
            else
            begin
              clear_warehouse_text;
              write_wrapped_text('No room to fetch to pod.');
              wait_exchange_buttons
            end
          end
        end
    end;
    if pod_index > 0 then
      data29.labels238[pod_index] := g20.cargo_names.names^[data29.stock234[pod_index].kind]
  until odd(data29.words[347])
end;
