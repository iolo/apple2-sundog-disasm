{ game_16 procedure39, $1252..$13D4, attributes $13E2; nested in37.
  The system row amount begins at word6, overlapping its caption. Capture30
  before random/mask/root calls. Case18 always calls8(101), even if byte541<=1. }
procedure proc16_39;
var
  cashrows: g16addr;
  before: integer;
  randomv: integer;
begin
  g16.words[5] := 30;
  g16.words[4] := 26 + (data29.bits38.low6 + data29.bits39.low5) mod 9;
  if arg1 = 19 then
  begin
    cashrows.word := data29.words[23];
    g16.cash104 := cashrows.rows^[data29.loc37.low4].amount6
  end
  else g16.cash104 := data29.money46;
  g16.words[41] := 0;
  case arg1 of
    12: proc16_34(16, 0);
    13: proc16_34(80, 0);
    14: proc16_34(81, 0);
    15: begin
          before := g16.words[30];
          randomv := proc22_3;
          randomv := proc22_32(randomv, 3071);
          randomv := proc22_36(randomv);
          g16.words[40] := before * (60 - randomv);
          g16.words[40] := g16.words[40] * sqr(data29.bytes[551]);
          proc16_3(g16.words[40], 1);
          g16.words[41] := 0;
          proc16_34(51, 0)
        end;
    16: proc16_34(65, 0);
    17, 22: begin
              g16.words[20] := ord(data29.bytes[552] <> 0);
              g16.words[18] := ord(data29.flags82[66]);
              data29.flags82[66] := false;
              g16.words[33] := 4;
              g16.words[41] := data29.bytes[548];
              if arg1 = 17 then proc16_34(32, 0) else proc16_34(33, 0)
            end;
    18: begin
          before := ord(data29.bytes[541] > 1);
          randomv := proc16_8(101);
          if odd(before) and odd(randomv) and not data29.flags82[125] then
          begin
            proc16_3(10000, 1);
            data29.flags82[125] := true;
            proc16_34(224, 0)
          end
          else
          begin
            proc16_3(proc22_40(5, 45), 1);
            proc16_34(49, 0)
          end
        end;
    19: if data29.nibbles45[1] = 1 then proc16_34(64, 0)
        else
        begin
          proc16_3(479 * g16.words[30], 1);
          proc16_34(50, 0)
        end;
    21: proc16_34(48, 0);
    23: begin
          proc16_3(8 * g16.words[30] + 3, 1);
          if proc28_6(g16.fund100, g16.cash104) then g16.fund100 := g16.cash104;
          proc16_34(96, 0)
        end
  end
end;
