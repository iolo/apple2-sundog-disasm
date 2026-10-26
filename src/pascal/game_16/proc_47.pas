{ game_16 procedure47, $1AC6..$1B84, attributes $1B8E.
  Preserve ordered mode stores, two-word cash transfers, and both discarded
  polling calls at the end. System-row address is captured for its MOV2. }
procedure proc16_47;
var
  system: g19addr;
  polled: integer;
begin
  data29.words[353] := g16.words[42];
  proc22_41(g16.words[13], g16.words[12]);
  proc22_52;
  if not odd(data29.words[347]) then
  begin
    data29.nibbles45[2] := data29.nibbles45[1];
    data29.nibbles45[1] := data29.nibbles45[0];
    data29.nibbles45[0] := 11;
    if data29.nibbles45[2] = 0 then data29.nibbles45[1] := 9
  end;
  if arg1 = 19 then
  begin
    system.word := data29.words[23] + 20 * (data29.loc37.low4 - 1);
    system.rows^[1].amount6 := g16.cash104
  end
  else
  begin
    if proc28_6(g16.fund102, g16.cash104) then g16.cash104 := g16.fund102;
    data29.money46 := g16.cash104
  end;
  data29.words[351] := g16.words[45];
  data29.bounds327 := g16.saved56;
  data29.bytes[549] := g16.words[33];
  data29.bytes[552] := g16.words[20];
  data29.bounds11 := g16.saved64;
  polled := proc22_2(4);
  polled := proc22_2(5)
end;
