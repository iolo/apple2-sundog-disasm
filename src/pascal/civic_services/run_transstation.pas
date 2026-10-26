{ game_19 procedure15, $09BC..$0B65, attributes $0B70.
  The initial unused system-row address calculation has no dereference or call.
  Table pointers below are refreshed at their original points of use. }
procedure run_transstation;
var
  target, rowpos, selected: integer;
  area: bounds4;
  systems: g19addr;
  planets: g19paddr;
begin
  pool_service_funds;
  open_service_title('TransStation');
  assign_bounds(area, data29.words[14], data29.words[13],
            data29.words[12] + 15, data29.words[11]);
  repeat
    g19.trip_completed := 0;
    apply_bounds(area, 8);
    apply_bounds(data29.bounds11, 0);
    rowpos := g19.menu_bottom - 10;
    reset_menu;
    planets.word := data29.words[24];
    if planets.rows^[data29.loc37.mid5].place7.low9 mod 8 > 1 then
    begin
      add_menu_button(1, 'TO CITY', g19.menu_left, g19.menu_right, rowpos, rowpos + 10);
      rowpos := rowpos - 15
    end;
    planets.word := data29.words[24];
    if data29.bits37.mid6 = planets.rows^[data29.loc37.mid5].place7.mid6 then
    begin
      systems.word := data29.words[23];
      if systems.rows^[data29.loc37.low4].bits5.low2 > 1 then
      begin
        add_menu_button(2, 'TO PLANET', g19.menu_left, g19.menu_right, rowpos, rowpos + 10);
        rowpos := rowpos - 15
      end;
      add_menu_button(3, 'TO SYSTEM', g19.menu_left, g19.menu_right, rowpos, rowpos + 10)
    end;
    g19.menu_action := 0;
    selected := 0;
    poll_service_menu(g19.menu_action, g19.menu_hit, data29.words[297], data29.bounds11, selected);
    target := 0;
    case g19.menu_action of
      1:
        begin
          planets.word := data29.words[24];
          with planets.rows^[data29.loc37.mid5].place7 do
            choose_service_destination(target, area, mid6, low9 mod 8, data29.bits37.mid6, g19.menu_action)
        end;
      2:
        begin
          systems.word := data29.words[23];
          with systems.rows^[data29.loc37.low4].bits5 do
            choose_service_destination(target, area, mid5, low2, data29.loc37.mid5, g19.menu_action)
        end;
      3: choose_service_destination(target, area, 1, 12, data29.loc37.low4, g19.menu_action)
    end;
    if target > 0 then book_passenger_transport(g19.menu_action, target, area)
  until not odd(selected) or odd(data29.words[347]) or odd(g19.trip_completed);
  if not odd(g19.trip_completed) then settle_service_funds
end;
