{ game_20 procedure31, $180A..$18F3, attributes $18FC; nested in28.
  SCONCAT rejects an entire append exceeding its specified capacity. The
  first append has capacity9; the second has24. The title call retains its
  SAS15 capacity check, including failure for an overlong heading. }
procedure paint_exchange_heading;
var
  phase: integer;
  heading: string[24];
begin
  clear_text_window;
  if odd(g20.contract_mode) then suffix := ' Center'
  else suffix := ' Exch.';
  heading := '';
  if length(data29.names25.cities^[data29.bits37.mid6]) <= 9 then
    heading := data29.names25.cities^[data29.bits37.mid6];
  heading := concat(heading, suffix);
  flash_exchange_title(heading, g20.menu_left, g20.menu_right, g20.menu_bottom - 85);
  set_text_grid_position(0, 12);
  if odd(g20.contract_mode) then
  begin
    phase := data29.bytes[542];
    set_text_grid_position(0, 12);
    write_wrapped_text('|Phases remaining: ');
    write_integer(10 - phase, 1, false);
    set_text_grid_position(0, 15);
    write_wrapped_text('|||Items needed to\||complete Phase ');
    write_integer(phase, 1, false);
    write_text_glyph(58)
  end
  else
  begin
    set_text_grid_position(0, 14);
    write_wrapped_text('|\||Lots now selling:')
  end
end;
