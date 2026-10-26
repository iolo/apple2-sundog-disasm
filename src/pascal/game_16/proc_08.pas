{ game_16 procedure8, $025E..$0493, attributes $04A8.
  Integer result preserves raw parent20/18 words in cases4/6. Negative input
  returns without writing its result, as in the original; do not add a default.
  Original locals4..8 are kept, including9's shared roll at8. Added temporaries
  retain pre-random values and both unconditional calls in case18.
  Failed cases1/16/17 change code to0 and dispatch the fallback once; that arm
  changes code to-1. The input0 path itself returns1 without any random call. }
function proc16_8(code: integer): integer;
var
  difference: integer;  {4}
  selector: integer;    {5}
  chance: integer;      {6}
  unused7: integer;
  roll: integer;        {8, shared with nested9}
  randomv: integer;
  before5: integer;
  before36: integer;
  firstres: boolean;
  secondres: boolean;
(*$include src/pascal/game_16/proc_09.pas*)
(*$include src/pascal/game_16/proc_10.pas*)
begin
  selector := 0;
  chance := 0;
  if code = 0 then proc16_8 := 1
  else if code > 0 then
  begin
    proc16_8 := 0;
    if code >= 200 then
    begin
      selector := code - 200;
      code := 20
    end
    else if code >= 100 then
    begin
      chance := code - 100;
      code := 19
    end
    else if code >= 90 then
    begin
      selector := code - 90;
      code := 15
    end
    else if code >= 20 then
    begin
      chance := code mod 10;
      if chance = 0 then chance := 10;
      chance := chance * 10;
      selector := (code - 20) div 10;
      if selector >= 4 then code := selector + 13 else code := 16
    end;
    repeat
      case code of
        0: begin
             proc16_8 := ord(proc16_10(4, 40));
             code := -1
           end;
        1: if proc16_10(3, 40) then
           begin
             g16.words[17] := 0;
             if proc16_9(g16.words[33] * 15) then proc16_8 := 1 else code := 0
           end;
        2: proc16_8 := ord(g16.words[33] = 0);
        3: if (g16.cash104.first = g16.fund102.first) and
              (g16.cash104.second = g16.fund102.second) then proc16_8 := 1
           else proc16_8 := ord(proc16_10(3, 40));
        4: proc16_8 := g16.words[20];
        5: proc16_8 := ord(proc16_10(4, 0));
        6: proc16_8 := g16.words[18];
        7: if g16.words[5] <> g16.words[4] then
           begin
             difference := proc22_35(g16.words[5] - g16.words[4]);
             randomv := proc22_3;
             if randomv mod 10 < difference then
             begin
               if difference > 4 then difference := 4;
               before5 := g16.words[5];
               before36 := g16.words[36];
               randomv := proc22_3;
               g16.words[5] := before5 - before36 * (randomv mod difference + 1);
               proc16_3(g16.words[41], 0);
               proc16_8 := 1
             end
           end;
        8: if proc28_6(g16.price106, g16.fund100) then
             proc28_3(g16.fund100, g16.price106)
           else proc16_8 := 1;
        9: begin
             firstres := g16.words[41] < 128;
             randomv := proc22_32(g16.words[41], 31);
             proc16_8 := ord(firstres or (randomv < 15))
           end;
        10: begin
              chance := 20 * (g16.words[7] + g16.words[6] - data29.bytes[551]);
              proc16_8 := ord(proc16_9(chance))
            end;
        11: if data29.flags82[80] then proc16_8 := 1
            else if proc16_10(3, -20) then
            begin
              data29.flags82[80] := true;
              proc16_8 := 1
            end;
        12, 13, 14: ;
        15: proc16_8 := ord(arg1 = selector + 12);
        16: if proc16_10(selector, chance - 60) then proc16_8 := 1 else code := 0;
        17: if proc16_9(chance + (g16.words[33] - 2) * 20) then
              proc16_8 := 1 else code := 0;
        18: begin
              firstres := proc16_9(g16.words[29] * 10);
              secondres := proc16_9(chance);
              proc16_8 := ord(firstres and secondres)
            end;
        19: proc16_8 := ord(proc16_9(chance));
        20: proc16_8 := ord(g16.words[41] = selector)
      end
    until code <> 0
  end
end;
