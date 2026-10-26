{ game_16 procedure47, $1AC6..$1B84, attributes $1B8E.
  Preserve ordered mode stores, two-word cash transfers, and both discarded
  polling calls at the end. System-row address is captured for its MOV2. }
procedure finish_dialog_session;
var
  system: g19addr;
  polled: integer;
begin
  data29.words[353] := g16.saved_tick_limit;
  toggle_pointer_glyph(g16.cursor_x, g16.cursor_y);
  pop_text_window;
  if not odd(data29.words[347]) then
  begin
    data29.nibbles45[2] := data29.nibbles45[1];
    data29.nibbles45[1] := data29.nibbles45[0];
    data29.nibbles45[0] := 11;
    if data29.nibbles45[2] = 0 then data29.nibbles45[1] := 9
  end;
  if dialog_kind = 19 then
  begin
    system.word := data29.words[23] + 20 * (data29.loc37.low4 - 1);
    system.rows^[1].bank_balance := g16.cash_amount
  end
  else
  begin
    if amount_greater(g16.zero_amount, g16.cash_amount) then g16.cash_amount := g16.zero_amount;
    data29.money46 := g16.cash_amount
  end;
  data29.words[351] := g16.saved_time_step;
  data29.bounds327 := g16.saved_clock_bounds;
  data29.bytes[549] := g16.response_level;
  data29.bytes[552] := g16.words[20];
  data29.bounds11 := g16.saved_text_bounds;
  polled := poll_input(4);
  polled := poll_input(5)
end;
