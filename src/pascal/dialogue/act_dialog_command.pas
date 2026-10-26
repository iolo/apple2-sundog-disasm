{ game_16 procedure33, $0F7C..$1108, attributes $1118.
  Preserve VAR rereads and the flag index captured before random. The amount
  adjustment retains its decimal step loop and original comparison direction. }
procedure act_dialog_command(var command_code: integer);
var
  digit_x: integer;
  amount_step: integer;
  step_amount: wordpair;
begin
  case command_code of
    0, 4: begin
            data29.flags82[49] := true;
            g16.exit_requested := 1;
            if command_code = 4 then
            begin
              if not odd(g16.selling_mode) and (g16.trade_item_code < 23) and (dialog_kind = 17) then
              begin
                digit_x := 80 + g16.trade_item_code;
                amount_step := random_word;
                data29.flags82[digit_x] := odd(amount_step)
              end;
              data29.bytes[552] := 0;
              data29.flags82[65] := false;
              data29.flags82[66] := false;
              data29.bytes[548] := 0
            end
          end;
    1, 2: begin
            g16.dialog_timeout := g16.dialog_timeout + 1;
            amount_step := 10000;
            digit_x := g16.cursor_x + 9;
            while (amount_step > 0) and (digit_x > g16.words[71] + 38) do
            begin
              amount_step := amount_step div 10;
              digit_x := digit_x - 12
            end;
            make_amount(step_amount, 0, amount_step);
            if command_code = 1 then
            begin
              add_amount(step_amount, g16.offer_amount);
              if amount_greater(g16.offer_amount, g16.cash_amount) then subtract_amount(step_amount, g16.offer_amount)
            end
            else if amount_greater(step_amount, g16.offer_amount) then g16.offer_amount := g16.zero_amount
            else subtract_amount(step_amount, g16.offer_amount);
            apply_bounds(g16.trade_bounds, 0);
            move_pen(g16.words[71] + 20, g16.words[69] + 16);
            draw_dialog_amount(g16.offer_amount);
            apply_bounds(data29.bounds11, 0)
          end;
    3: begin
         g16.exit_requested := 1;
         data29.flags82[65] := true;
         data29.flags82[66] := odd(g16.selling_mode);
         data29.bytes[548] := g16.trade_item_code
       end;
    5, 6: begin
            g16.exit_requested := 1;
            data29.flags82[51] := command_code = 5
          end;
    7: begin
         data29.flags82[50] := false;
         data29.flags82[48] := false;
         data29.flags82[49] := false;
         g16.exit_requested := 1
       end;
    8: begin
         g16.exit_requested := 1;
         data29.flags82[48] := true
       end;
    9, 10, 11: begin
                 g16.redirect_requested := 1;
                 command_code := g16.words[53 + (command_code - 9)]
               end
  end
end;
