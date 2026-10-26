{ game_8 procedure15, $0696..$07B7, attributes $07C2. }
procedure proc8_15;
var
  saved: bounds4;
begin
  saved := data29.bounds11;
  proc22_50(g8b38.lower_first, g8b38.upper_first,
            g8b38.lower_second, g8b38.upper_second);
  proc22_44;
  g8a3[15] := 0;
  proc22_48('||LOCATION\');
  data29.words[18] := data29.words[18] + 4;
  proc22_48('City:\|');
  if data29.loc37.mid5 = 0 then proc22_48('deep space')
  else if data29.bits37.mid6 = 0 then begin
    if (data29.bits38.low6 = 0) and (data29.bits39.low5 = 0) then
      proc22_48('orbit')
    else proc22_48('surface')
  end else proc22_48(data29.names25.cities^[data29.bits37.mid6]);
  proc22_45;
  data29.words[18] := data29.words[18] + 4;
  proc22_48('Planet:\|');
  if data29.loc37.mid5 = 0 then proc22_48('space')
  else proc22_48(data29.names24.planets^[data29.loc37.mid5]);
  proc22_45;
  data29.words[18] := data29.words[18] + 4;
  proc22_48('System:\|');
  proc22_48(data29.names23.systems^[data29.loc37.low4].caption);
  proc22_45;
  proc8_11;
  proc8_7;
  proc22_50(saved.lower_first, saved.upper_first,
            saved.lower_second, saved.upper_second)
end;
