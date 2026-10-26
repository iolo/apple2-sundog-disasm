{ game_19 procedure7, $01F8..$036E, attributes $037A.
  Both amounts are VAR. The initial available copy occurs after menu setup;
  the accumulated amount is committed even when the menu is cancelled. }
procedure proc19_7(var available, destination: wordpair);
var
  code, found, selected: integer;
  choice, remaining, total: wordpair;
begin
  proc25_2;
  proc19_4(g19.words[20] - 25, 1, 3, 'ALL', '100', '1000');
  proc19_4(g19.words[20] - 10, 4, 3, '10000', '50000', 'CLEAR');
  proc28_4(total, 0, 0);
  remaining := available;
  proc22_14(data29.words[14], data29.words[13],
            data29.words[12] + g19.words[20] - 50, data29.words[11]);
  proc22_7(8);
  proc22_19(data29.bounds11, 0);
  repeat
    data29.words[19] := data29.words[14] + g19.words[23];
    data29.words[18] := data29.words[12] + g19.words[20] - 48;
    proc22_45;
    proc28_5('AMOUNT:    ', total);
    proc28_5('AVAILABLE: ', remaining);
    proc19_3(code, found, data29.words[297], data29.bounds11, selected);
    proc28_4(choice, 0, 0);
    if odd(selected) and (0 < code) and (code < 7) then
    begin
      case code of
        1: choice := remaining;
        2: choice.second := 100;
        3: choice.first := 1;
        4: choice.first := 10;
        5: choice.first := 50;
        6:
          begin
            proc28_4(total, 0, 0);
            remaining := available;
            proc28_4(choice, 0, 0)
          end
      end;
      if not proc28_6(choice, remaining) then
      begin
        proc28_3(choice, remaining);
        proc28_2(choice, total)
      end
      else proc22_4(10, 40, 50, 0, 0, 0, 0)
    end
  until not odd(selected) or (code = 7) or odd(data29.words[347]);
  proc28_2(total, destination);
  available := remaining;
  proc22_14(data29.words[14], data29.words[13],
            data29.words[12] + g19.words[20] - 50, data29.words[11]);
  proc22_7(8);
  proc22_19(data29.bounds11, 0);
  selected := 1
end;
