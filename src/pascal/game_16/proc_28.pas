{ game_16 procedure28, $0BDE..$0D2E, attributes $0D3C.
  Parent23's work is original slot10. Original14-byte local allocation remains;
  two unused slots capture the random result and parent30 before that call. }
procedure proc16_28;
var
  spare1: integer;
  randomv: integer;
  code: integer;
  before30: integer;
  spare5: integer;
  spare6: integer;
  spare7: integer;
begin
  proc16_15(code);
  case code of
    0: begin
         proc22_12(g16.words[71] + 20, g16.words[69] + 8);
         proc22_10('` ` ` ` `');
         proc22_12(g16.words[71] + 20, g16.words[69] + 16);
         proc16_4(g16.fund102);
         proc22_12(g16.words[71] + 20, g16.words[69] + 24);
         proc22_10('& & & & &');
         g16.words[95] := 1;
         g16.words[90] := 1;
         g16.words[96] := 2;
         g16.words[91] := 1;
         before30 := g16.words[30];
         randomv := proc22_3;
         proc28_4(g16.price106, 0, before30 * (5 + randomv mod 63));
         g16.words[17] := 1
       end;
    1: begin
         if odd(g16.words[18]) then work := 0
         else
         begin
           if g16.words[41] = 0 then g16.words[41] := g16.words[35] - 32;
           if (g16.words[41] = 11) or (g16.words[41] = 13) then
             g16.words[41] := g16.words[41] + 224;
           work := g16.words[41]
         end;
         if arg1 <> 15 then proc16_3(g16.words[41], 0);
         proc16_7(work, work, 1);
         proc16_15(g16.words[95])
       end;
    2, 3: begin
            g16.words[18] := ord(code = 2);
            g16.words[19] := 1;
            proc16_15(g16.words[95]);
            proc16_15(g16.words[96]);
            if not odd(g16.words[18]) then
            begin
              proc16_15(g16.words[28]);
              proc16_15(g16.words[27]);
              if g16.words[27] < g16.words[28] then
                g16.words[27] := g16.words[87 + g16.words[27]];
              proc16_7(g16.words[28], g16.words[27], 1)
            end
          end;
    5, 6, 7: proc16_15(g16.words[53 + (code - 5)])
  end
end;
