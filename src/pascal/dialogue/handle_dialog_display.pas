{ game_16 procedure28, $0BDE..$0D2E, attributes $0D3C.
  Parent23's work is original slot10. Original14-byte local allocation remains;
  two unused slots capture the random result and parent30 before that call. }
procedure handle_dialog_display;
var
  spare1: integer;
  random_value: integer;
  display_command: integer;
  saved_price_scale: integer;
  spare5: integer;
  spare6: integer;
  spare7: integer;
begin
  read_dialog_byte(display_command);
  case display_command of
    0: begin
         move_pen(g16.words[71] + 20, g16.words[69] + 8);
         draw_text('` ` ` ` `');
         move_pen(g16.words[71] + 20, g16.words[69] + 16);
         draw_dialog_amount(g16.zero_amount);
         move_pen(g16.words[71] + 20, g16.words[69] + 24);
         draw_text('& & & & &');
         g16.choice0_action := 1;
         g16.choice0_label := 1;
         g16.choice1_action := 2;
         g16.choice1_label := 1;
         saved_price_scale := g16.price_scale;
         random_value := random_word;
         make_amount(g16.item_price, 0, saved_price_scale * (5 + random_value mod 63));
         g16.amount_controls := 1
       end;
    1: begin
         if odd(g16.selling_mode) then scratch_word := 0
         else
         begin
           if g16.trade_item_code = 0 then g16.trade_item_code := g16.selected_caption - 32;
           if (g16.trade_item_code = 11) or (g16.trade_item_code = 13) then
             g16.trade_item_code := g16.trade_item_code + 224;
           scratch_word := g16.trade_item_code
         end;
         if dialog_kind <> 15 then set_trade_price(g16.trade_item_code, 0);
         list_trade_items(scratch_word, scratch_word, 1);
         read_dialog_byte(g16.choice0_action)
       end;
    2, 3: begin
            g16.selling_mode := ord(display_command = 2);
            g16.trade_active := 1;
            read_dialog_byte(g16.choice0_action);
            read_dialog_byte(g16.choice1_action);
            if not odd(g16.selling_mode) then
            begin
              read_dialog_byte(g16.first_trade_code);
              read_dialog_byte(g16.last_trade_code);
              if g16.last_trade_code < g16.first_trade_code then
                g16.last_trade_code := g16.words[87 + g16.last_trade_code];
              list_trade_items(g16.first_trade_code, g16.last_trade_code, 1)
            end
          end;
    5, 6, 7: read_dialog_byte(g16.words[53 + (display_command - 5)])
  end
end;
