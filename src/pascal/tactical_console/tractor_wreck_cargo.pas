{ game_12 procedure18, $0FCA..$1096, attributes $10A6; nested in1.
  Original $0FCF..$0FE1 reads cargo kind BEFORE checking slot>0. With both
  pods occupied it reads index0 (word232). Disable range checks and retain
  this order; do not add a guard or a stop-flag exit to the tractor loop. }
procedure tractor_wreck_cargo;
var cargo_slot: integer;
begin
  swap_tactical_buffers;
  cargo_slot := 2;
  while (data29.stock234[cargo_slot].kind > 0) and (cargo_slot > 0) do cargo_slot := cargo_slot - 1;
  clear_text_window;
  if not odd(g12.wreck_cargo_present) then write_wrapped_text('Out of range')
  else if cargo_slot = 0 then write_wrapped_text('No room')
  else
  begin
    write_wrapped_text('Activating tractor\');
    data29.words[207] := -4;
    swap_tactical_buffers;
    repeat
      data29.words[354] := data29.words[354] + 1;
      tick_tactical_controls
    until data29.target_range = 1;
    swap_tactical_buffers;
    write_wrapped_text('Cargo loaded');
    data29.stock234[cargo_slot] := g12.cargo34;
    data29.labels238[cargo_slot] := 'Unknown';
    g12.wreck_cargo_present := 0;
    data29.flags82[36] := false
  end;
  swap_tactical_buffers
end;
