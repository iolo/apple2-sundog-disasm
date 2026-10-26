{ game_16 procedure39, $1252..$13D4, attributes $13E2; nested in37.
  The system row amount begins at word6, overlapping its caption. Capture30
  before random/mask/root calls. Case18 always calls8(101), even if byte541<=1. }
procedure start_dialog_context;
var
  cash_rows: g16addr;
  saved_context_value: integer;
  random_value: integer;
begin
  g16.price_numerator := 30;
  g16.price_denominator := 26 + (data29.bits38.low6 + data29.bits39.low5) mod 9;
  if dialog_kind = 19 then
  begin
    cash_rows.word := data29.words[23];
    g16.cash_amount := cash_rows.rows^[data29.loc37.low4].bank_balance
  end
  else g16.cash_amount := data29.money46;
  g16.trade_item_code := 0;
  case dialog_kind of
    12: dispatch_dialog_action(16, 0);
    13: dispatch_dialog_action(80, 0);
    14: dispatch_dialog_action(81, 0);
    15: begin
          saved_context_value := g16.price_scale;
          random_value := random_word;
          random_value := word_and(random_value, 3071);
          random_value := rounded_word_sqrt(random_value);
          g16.context_amount := saved_context_value * (60 - random_value);
          g16.context_amount := g16.context_amount * sqr(data29.bytes[551]);
          set_trade_price(g16.context_amount, 1);
          g16.trade_item_code := 0;
          dispatch_dialog_action(51, 0)
        end;
    16: dispatch_dialog_action(65, 0);
    17, 22: begin
              g16.words[20] := ord(data29.bytes[552] <> 0);
              g16.selling_mode := ord(data29.flags82[66]);
              data29.flags82[66] := false;
              g16.response_level := 4;
              g16.trade_item_code := data29.bytes[548];
              if dialog_kind = 17 then dispatch_dialog_action(32, 0) else dispatch_dialog_action(33, 0)
            end;
    18: begin
          saved_context_value := ord(data29.bytes[541] > 1);
          random_value := test_dialog_condition(101);
          if odd(saved_context_value) and odd(random_value) and not data29.flags82[125] then
          begin
            set_trade_price(10000, 1);
            data29.flags82[125] := true;
            dispatch_dialog_action(224, 0)
          end
          else
          begin
            set_trade_price(random_between(5, 45), 1);
            dispatch_dialog_action(49, 0)
          end
        end;
    19: if data29.nibbles45[1] = 1 then dispatch_dialog_action(64, 0)
        else
        begin
          set_trade_price(479 * g16.price_scale, 1);
          dispatch_dialog_action(50, 0)
        end;
    21: dispatch_dialog_action(48, 0);
    23: begin
          set_trade_price(8 * g16.price_scale + 3, 1);
          if amount_greater(g16.offer_amount, g16.cash_amount) then g16.offer_amount := g16.cash_amount;
          dispatch_dialog_action(96, 0)
        end
  end
end;
