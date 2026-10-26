{ game_21 procedure19, $09EA..$0ADA, attributes $0AE8.
  Nested20 uses coordinates at parent slots5/4. Raw char tables retain their
  one-based offsets. Cases14/15 make both calls, with a fresh flag read. }
procedure proc21_19(var changed: integer);
var
  code: integer;         {2}
  spare3: integer;
  ypos: integer;         {4}
  xpos: integer;         {5}
  yspec: string[8];       {6..10}
  xspec: string[8];       {11..15}
(*$include src/pascal/game_21/proc_20.pas*)
begin
  xpos := (g21.words[26] - 3) mod 28;
  ypos := (g21.words[25] + 3) mod g21.words[21];
  code := arg2 mod 16;
  xspec := 'ABAA';
  yspec := 'OPOU';
  data29.nibbles45[1] := data29.nibbles45[2];
  case code of
    7: begin
         proc21_20(data29.flags45[13], 14, 30, 3, 1);
         g21.words[34] := ord(arg2 = 1)
       end;
    8, 9, 10, 11:
       proc21_20(data29.flags45[13], ord(xspec[code - 7]) - 64,
                   ord(yspec[code - 7]) - 64, 5, code);
    12: proc21_20(data29.flags45[13], 6, 28, 6, 1);
    13: proc21_20(data29.flags45[13], 1, 18, 6, 2);
    14: begin
          proc21_20(data29.flags45[13], 1, 15, 6, 3);
          proc21_20(not data29.flags45[13], 2, 22, 6, 3)
        end;
    15: begin
          proc21_20(not data29.flags45[13], 14, 21, 6, 4);
          proc21_20(data29.flags45[13], 2, 15, 6, 5)
        end
  end;
  changed := ord(data29.nibbles45[1] <> data29.nibbles45[2])
end;
