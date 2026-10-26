{ game_16 procedure8, $025E..$0493, attributes $04A8.
  Integer result preserves raw parent20/18 words in cases4/6. Negative input
  returns without writing its result, as in the original; do not add a default.
  Original locals4..8 are kept, including9's shared roll at8. Added temporaries
  retain pre-random values and both unconditional calls in case18.
  Failed cases1/16/17 change code to0 and dispatch the fallback once; that arm
  changes code to-1. The input0 path itself returns1 without any random call. }
function test_dialog_condition(test_code: integer): integer;
var
  price_gap: integer;  {4}
  test_arg: integer;    {5}
  chance_percent: integer;      {6}
  unused7: integer;
  percent_roll: integer;        {8, shared with nested9}
  random_value: integer;
  prior_numerator: integer;
  prior_direction: integer;
  first_test: boolean;
  second_test: boolean;
(*$include src/pascal/dialogue/roll_dialog_chance.pas*)
(*$include src/pascal/dialogue/test_player_attribute.pas*)
begin
  test_arg := 0;
  chance_percent := 0;
  if test_code = 0 then test_dialog_condition := 1
  else if test_code > 0 then
  begin
    test_dialog_condition := 0;
    if test_code >= 200 then
    begin
      test_arg := test_code - 200;
      test_code := 20
    end
    else if test_code >= 100 then
    begin
      chance_percent := test_code - 100;
      test_code := 19
    end
    else if test_code >= 90 then
    begin
      test_arg := test_code - 90;
      test_code := 15
    end
    else if test_code >= 20 then
    begin
      chance_percent := test_code mod 10;
      if chance_percent = 0 then chance_percent := 10;
      chance_percent := chance_percent * 10;
      test_arg := (test_code - 20) div 10;
      if test_arg >= 4 then test_code := test_arg + 13 else test_code := 16
    end;
    repeat
      case test_code of
        0: begin
             test_dialog_condition := ord(test_player_attribute(4, 40));
             test_code := -1
           end;
        1: if test_player_attribute(3, 40) then
           begin
             g16.amount_controls := 0;
             if roll_dialog_chance(g16.response_level * 15) then test_dialog_condition := 1 else test_code := 0
           end;
        2: test_dialog_condition := ord(g16.response_level = 0);
        3: if (g16.cash_amount.first = g16.zero_amount.first) and
              (g16.cash_amount.second = g16.zero_amount.second) then test_dialog_condition := 1
           else test_dialog_condition := ord(test_player_attribute(3, 40));
        4: test_dialog_condition := g16.words[20];
        5: test_dialog_condition := ord(test_player_attribute(4, 0));
        6: test_dialog_condition := g16.selling_mode;
        7: if g16.price_numerator <> g16.price_denominator then
           begin
             price_gap := word_abs(g16.price_numerator - g16.price_denominator);
             random_value := random_word;
             if random_value mod 10 < price_gap then
             begin
               if price_gap > 4 then price_gap := 4;
               prior_numerator := g16.price_numerator;
               prior_direction := g16.price_direction;
               random_value := random_word;
               g16.price_numerator := prior_numerator - prior_direction * (random_value mod price_gap + 1);
               set_trade_price(g16.trade_item_code, 0);
               test_dialog_condition := 1
             end
           end;
        8: if amount_greater(g16.item_price, g16.offer_amount) then
             subtract_amount(g16.offer_amount, g16.item_price)
           else test_dialog_condition := 1;
        9: begin
             first_test := g16.trade_item_code < 128;
             random_value := word_and(g16.trade_item_code, 31);
             test_dialog_condition := ord(first_test or (random_value < 15))
           end;
        10: begin
              chance_percent := 20 * (g16.item12_13_weight + g16.item11_weight - data29.bytes[551]);
              test_dialog_condition := ord(roll_dialog_chance(chance_percent))
            end;
        11: if data29.flags82[80] then test_dialog_condition := 1
            else if test_player_attribute(3, -20) then
            begin
              data29.flags82[80] := true;
              test_dialog_condition := 1
            end;
        12, 13, 14: ;
        15: test_dialog_condition := ord(dialog_kind = test_arg + 12);
        16: if test_player_attribute(test_arg, chance_percent - 60) then test_dialog_condition := 1 else test_code := 0;
        17: if roll_dialog_chance(chance_percent + (g16.response_level - 2) * 20) then
              test_dialog_condition := 1 else test_code := 0;
        18: begin
              first_test := roll_dialog_chance(g16.words[29] * 10);
              second_test := roll_dialog_chance(chance_percent);
              test_dialog_condition := ord(first_test and second_test)
            end;
        19: test_dialog_condition := ord(roll_dialog_chance(chance_percent));
        20: test_dialog_condition := ord(g16.trade_item_code = test_arg)
      end
    until test_code <> 0
  end
end;
