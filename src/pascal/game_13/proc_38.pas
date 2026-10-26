{ game_13 procedure38, $1C3E..$1CEF, attributes $1CFA; nested in27.
  Copy the complete location before rendering; subsequent reads remain live. }
procedure proc13_38;
begin
  data29.flags82[1] := false;
  data29.pos66 := data29.pos72;
  proc22_19(data29.bnd339, 8);
  proc22_50(data29.words[342], data29.words[341],
            data29.words[340], data29.words[339]);
  proc22_48('Sub-light engines turned off\');
  proc22_48('Current location:  ');
  if data29.pos72.fields.planet = 0 then
  begin
    proc22_49(data29.pos72.fields.w0low, 3, true);
    proc22_48(' MARK ');
    proc22_49(14 + proc22_30(data29.pos72.fields.w0high, 1), 3, true)
  end
  else proc22_48(data29.names24.planets^[data29.pos72.fields.planet]);
  proc22_45
end;
