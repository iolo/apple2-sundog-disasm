{ game_19 procedure26, $131C..$13A0, attributes $13AA. }
procedure proc19_26;
var
  table: g19addr;
begin
  proc22_51(data29.words[40] div 7, data29.bytes[80] div 8);
  g19.words[17] := data29.words[353];
  data29.words[353] := 60;
  g19.words[16] := data29.words[351];
  data29.words[351] := 1;
  g19.words[28] := 0;
  proc22_44;
  g19.words[23] := 4;
  g19.words[22] := data29.words[13] - data29.words[14] - 4;
  g19.words[20] := data29.words[11] - data29.words[12] - 2;
  proc28_4(g19.amount8, 0, 0);
  table.word := data29.words[23];
  with table.rows^[data29.loc37.low4] do
  begin
    g19.words[14] := nibbles8[3];
    g19.words[13] := nibbles8[4];
    g19.words[12] := nibbles8[5]
  end
end;
