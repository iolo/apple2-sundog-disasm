{ game_12 procedure14, $0C72..$0CAC, attributes $0CB6; nested in1.
  Unlike13, flag35 suppresses the origin snapshot as well as drawing. }
procedure proc12_14;
begin
  if not data29.flags82[35] then
  begin
    proc22_18(data29.bnd335, data29.words[338], data29.words[337],
                data29.words[336] - 15, data29.words[335]);
    proc22_19(data29.bnd335, 8);
    g12.words[10] := data29.words[338];
    g12.words[9] := data29.words[336]
  end
end;
