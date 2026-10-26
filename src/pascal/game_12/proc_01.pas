{ game_12 procedure1, $1374..$1562, attributes $1578.
  All22 children share this94-byte frame;16 is nested in15. No segment
  load/release occurs here: game13 supplies the enclosing runtime context.
  Counter354 is tested by BIT0, not nonzero. Input1's close path skips
  dispatch/rebuild; only a positive menu hit reaches the rebuild below. }
procedure proc12_1;
var g12: g12frame;
(*$include src/pascal/game_12/proc_02.pas*)
(*$include src/pascal/game_12/proc_03.pas*)
(*$include src/pascal/game_12/proc_04.pas*)
(*$include src/pascal/game_12/proc_05.pas*)
(*$include src/pascal/game_12/proc_06.pas*)
(*$include src/pascal/game_12/proc_07.pas*)
(*$include src/pascal/game_12/proc_08.pas*)
(*$include src/pascal/game_12/proc_09.pas*)
(*$include src/pascal/game_12/proc_10.pas*)
(*$include src/pascal/game_12/proc_11.pas*)
(*$include src/pascal/game_12/proc_12.pas*)
(*$include src/pascal/game_12/proc_13.pas*)
(*$include src/pascal/game_12/proc_14.pas*)
(*$include src/pascal/game_12/proc_15.pas*)
(*$include src/pascal/game_12/proc_17.pas*)
(*$include src/pascal/game_12/proc_18.pas*)
(*$include src/pascal/game_12/proc_19.pas*)
(*$include src/pascal/game_12/proc_20.pas*)
(*$include src/pascal/game_12/proc_21.pas*)
(*$include src/pascal/game_12/proc_22.pas*)
(*$include src/pascal/game_12/proc_23.pas*)
begin
  proc12_13('TACTICAL');
  proc12_9;
  proc12_15;
  g12.words[12] := 0;
  repeat
    data29.words[354] := data29.words[354] + 1;
    if odd(data29.words[354]) then proc12_12
    else proc22_43(g12.words[2], g12.words[1]);
    proc22_19(data29.bnd335, 0);
    if odd(proc22_2(1)) then
    begin
      if g12.words[4] = 0 then g12.words[12] := 1
      else
      begin
        if g12.words[4] = 2 then
        begin
          proc12_2;
          proc12_4;
          proc12_2
        end;
        g12.words[4] := 0;
        proc12_14;
        proc12_15;
        g12.words[12] := proc22_2(1)
      end
    end
    else if odd(proc22_2(0)) then
    begin
      proc25_7(g12.words[2] - g12.words[10], g12.words[1] - g12.words[9],
                   g12.words[7], g12.words[8]);
      if g12.words[8] > 0 then
      begin
        proc22_4(30, 50, 10, 0, 0, 0, 0);
        proc22_41(g12.words[2], g12.words[1]);
        proc12_12;
        proc25_8(g12.words[8], g12.words[7], data29.bnd335,
                     g12.words[13], g12.words[13]);
        case g12.words[7] of
          2: if data29.words[227] = 0 then proc22_4(10, 40, 50, 0, 0, 0, 0)
             else proc12_20(1, 'SHIELDS');
          3: proc12_20(3, 'GUNS');
          4: proc12_21(0);
          5: proc12_23;
          6: data29.flags82[12] := false;
          7: proc12_22;
          8: proc12_19(64, 4, data29.words[224]);
          9: proc12_19(-64, 4, data29.words[224]);
          10: proc12_19(-256, 4, data29.words[224]);
          11, 12, 13: proc12_21(g12.words[7] - 10);
          14, 15: begin
                    g12.words[30] := ord(g12.words[7] = 14);
                    proc12_17
                  end;
          16: proc12_18;
          17: proc12_19(256, 4, data29.words[224])
        end;
        if not odd(g12.words[12]) then proc12_15
      end
    end
  until odd(g12.words[12]) or odd(data29.words[347]);
  if odd(g12.words[28]) then data29.flags82[44] := true;
  data29.nibbles45[1] := 1;
  proc22_21(data29.words[16], false);
  if g12.words[36] = 0 then data29.words[203] := 2
  else data29.words[203] := g12.words[36];
  data29.flags82[5] := false;
  if odd(data29.words[347]) and (data29.nibbles45[2] = 10) then
  begin
    data29.nibbles45[2] := 2;
    data29.nibbles45[1] := 0
  end
  else if data29.nibbles45[2] <> 9 then
  begin
    proc22_19(data29.bnd343, 8);
    if not odd(data29.words[347]) then data29.nibbles45[2] := 0;
    data29.nibbles45[0] := 11;
    proc22_19(data29.bnd339, 8)
  end;
  proc22_21(data29.words[15], true);
  proc12_14
end;
