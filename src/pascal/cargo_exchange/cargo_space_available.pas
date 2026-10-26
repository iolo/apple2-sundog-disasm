{ game_20 procedure26, $1522..$1578, attributes $1582. }
function cargo_space_available(var slot: integer): boolean;
begin
  cargo_space_available := true;
  find_empty_cargo_slot(slot, false);
  if (slot <= 0) and odd(g20.pods_available) then find_empty_cargo_slot(slot, true);
  if slot <= 0 then
  begin
    clear_text_window;
    write_wrapped_text('No space left in warehouse');
    if odd(g20.pods_available) then write_wrapped_text(' or pod');
    wait_exchange_buttons;
    cargo_space_available := false
  end
end;
