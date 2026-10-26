{ game_20 procedure4, $00A0..$01F2, attributes $0202.
  CSP11 at E6CF scans for a nonzero byte. Continue only when all14 bytes
  were zero, including padding. Phase9 exits before updating phase bytes. }
procedure finish_delivery_phase;
var
  phase, index, item: integer;
  phases: g20phases;
begin
  if scan(14, <> chr(0), g20.demand_levels.bytes) <> 14 then exit(finish_delivery_phase);
  phase := data29.bytes[542];
  if phase > 0 then
  begin
    clear_text_window;
    write_wrapped_text('|\|\|\|Phase ');
    write_integer(phase, 1, false);
    write_wrapped_text(' now complete\|');
    data29.flags82[114] := true;
    if phase = 9 then
    begin
      write_wrapped_text('||You have fulfilled your contract.');
      data29.nibbles45[2] := 13;
      data29.nibbles45[1] := 13;
      wait_exchange_buttons;
      exit(finish_delivery_phase)
    end;
    if phase > 0 then
    begin
      make_amount(g20.phase_bonus, g20.bonus_accumulator div 10, 100 * (g20.bonus_accumulator mod 10));
      add_amount(g20.phase_bonus, g20.trading_cash);
      write_captioned_amount('Bonus paid: ', g20.phase_bonus);
      g20.bonus_accumulator := 0;
      write_wrapped_text('||Starting Phase ');
      write_integer(phase + 1, 1, false);
      wait_exchange_buttons
    end
  end;
  data29.bytes[541] := phase;
  data29.bytes[542] := phase + 1;
  moveleft(g20.phase_table.bytes^, phases, 54);
  index := 0;
  while index <= 7 do
  begin
    item := phases[phase][index];
    if item > 0 then g20.demand_levels.values[item] := g20.demand_levels.values[item] + 1;
    index := index + 1
  end
end;
