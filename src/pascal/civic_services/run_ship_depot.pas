{ game_19 procedure25, $121C..$130E, attributes $131A.
  The first SCONCAT capacity is9: an overlong city name contributes no text.
  The original dispatch runs before the selected/cancel exit test. }
procedure run_ship_depot;
var
  heading: text15;
  rowpos, choice, found, selected: integer;
begin
  pool_service_funds;
  heading := '';
  if length(data29.names25.cities^[data29.bits37.mid6]) <= 9 then
    heading := data29.names25.cities^[data29.bits37.mid6];
  heading := concat(heading, ' Depot');
  open_service_title(heading);
  g19.depot_unit_factor := g19.depot_rating + g19.transport_rate + (16 - g19.repair_discount);
  set_text_window(data29.words[14], data29.words[13], data29.words[12] + 17, data29.words[11]);
  repeat
    reset_menu;
    rowpos := g19.menu_bottom - 57;
    add_menu_button(1, 'REFUEL SHIP', g19.menu_left, g19.menu_right, rowpos, rowpos + 10);
    rowpos := rowpos + 15;
    add_menu_button(2, 'REPAIR SHIP', g19.menu_left, g19.menu_right, rowpos, rowpos + 10);
    rowpos := rowpos + 15;
    add_menu_button(3, 'BUY AUX FUEL', g19.menu_left, g19.menu_right, rowpos, rowpos + 10);
    rowpos := rowpos + 15;
    poll_service_menu(choice, found, data29.words[297], data29.bounds11, selected);
    case choice of
      1: refuel_at_depot;
      2: repair_at_depot;
      3: buy_auxiliary_fuel
    end
  until not odd(selected) or odd(data29.words[347]);
  settle_service_funds
end;
