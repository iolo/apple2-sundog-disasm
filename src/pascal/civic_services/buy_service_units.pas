{ game_19 procedure18, $0E44..$1001, attributes $1014.
  Four value strings retain copies at7..38; nested19 uses slots39..46.
  Uppercasing is the original byte subtraction, not a locale conversion. }
procedure buy_service_units(alltext, itemname, verb, unitname: text15;
                    var price, quantity: integer);
var
  unit_cost: wordpair;       {39..40}
  units_needed: integer;      {41}
  quote_y: integer;         {42}
  quote_x: integer;      {43}
  found: integer;       {44}
  choice: integer;      {45}
  purchase_blocked: boolean;     {46}
  selected: integer;    {47}
  unit_button_text: text15;    {48..55}
  limit: integer;       {56}
  stop_purchase: boolean;
  cancel_poll: integer;
(*$include src/pascal/civic_services/paint_depot_quote.pas*)
begin
  clear_text_window;
  if price < 0 then
  begin
    write_wrapped_text('Your ');
    write_wrapped_text(itemname);
    write_wrapped_text(' isn''t here for us to ');
    write_wrapped_text(verb);
    exit(buy_service_units)
  end;
  if quantity = 16 then
  begin
    write_wrapped_text('Your ');
    write_wrapped_text(itemname);
    write_wrapped_text(' doesn''t need ');
    write_wrapped_text(verb);
    write_wrapped_text('ing');
    exit(buy_service_units)
  end;
  unit_button_text := unitname;
  units_needed := 1;
  limit := length(unit_button_text);
  while units_needed <= limit do
  begin
    unit_button_text[units_needed] := chr(ord(unit_button_text[units_needed]) - 32);
    units_needed := units_needed + 1
  end;
  units_needed := 16 - quantity;
  make_amount(unit_cost, 0, price);
  write_wrapped_text('Cost ');
  write_integer(price, 8, false);
  write_wrapped_text(' cr/');
  write_wrapped_text(unitname);
  text_newline;
  if unitname = 'load' then write_wrapped_text('You can use ')
  else write_wrapped_text('You need    ');
  quote_x := data29.text_x;
  quote_y := data29.text_y;
  paint_depot_quote;
  repeat
    reset_menu;
    if units_needed = 1 then
      add_service_button_row(g19.menu_bottom - 27, 2, 2, unit_button_text, 'STOP', '')
    else add_service_button_row(g19.menu_bottom - 27, 1, 3, alltext, unit_button_text, 'STOP');
    poll_service_menu(choice, found, data29.words[297], data29.bounds11, selected);
    if odd(selected) and (choice < 3) and not purchase_blocked then
      repeat
        quantity := quantity + 1;
        subtract_amount(unit_cost, g19.working_funds);
        if units_needed > 255 then units_needed := 255;
        units_needed := units_needed - 1;
        paint_depot_quote;
        stop_purchase := (choice = 2) or purchase_blocked;
        cancel_poll := poll_input(1)
      until stop_purchase or odd(cancel_poll);
    cancel_poll := poll_input(1)
  until odd(cancel_poll) or purchase_blocked or (choice = 3) or not odd(selected)
end;
