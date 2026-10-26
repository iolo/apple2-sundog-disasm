{ game_19 procedure16, $0B72..$0C04, attributes $0C0E.
  Capture the destination row after the amount picker returns, then retain
  that address through the balance addition and store. }
procedure send_bank_transfer(var available: wordpair);
var
  dest_system: integer;
  balance, transfer_amount: wordpair;
  area: bounds4;
  systems: g19addr;
begin
  assign_bounds(area, data29.words[14], data29.words[13],
            data29.words[12] + 23, data29.words[11]);
  choose_service_destination(dest_system, area, 1, 12, data29.loc37.low4, 3);
  if dest_system > 0 then
  begin
    apply_bounds(area, 8);
    apply_bounds(data29.bounds11, 0);
    set_text_grid_position(0, 8);
    write_wrapped_text('Transfer to ');
    systems.word := data29.words[23];
    write_wrapped_text(systems.rows^[dest_system].caption);
    text_newline;
    transfer_amount := g19.zero_funds;
    pick_transfer_amount(available, transfer_amount);
    systems.word := data29.words[23];
    with systems.rows^[dest_system] do
    begin
      balance := bank_balance;
      add_amount(transfer_amount, balance);
      bank_balance := balance
    end
  end;
  apply_bounds(area, 8);
  apply_bounds(data29.bounds11, 0)
end;
