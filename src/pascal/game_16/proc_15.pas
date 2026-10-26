{ game_16 procedure15, $0706..$0718, attributes $0722.
  Store through the VAR address first, then reread/increment parent38 so
  aliasing that index retains the original behavior. }
procedure proc16_15(var value: integer);
begin
  value := g16.source140.bytes^[g16.words[38]];
  g16.words[38] := g16.words[38] + 1
end;
