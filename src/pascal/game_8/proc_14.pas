{ game_8 procedure14, $05CC..$0687, attributes $0694. }
procedure proc8_14;
var
  saved: bounds4;
  index: integer;
  labels: text15;
  last: integer;
begin
  saved := data29.bounds11;
  proc22_50(g8b38.lower_first, g8b38.upper_first,
            g8b38.lower_second, g8b38.upper_second);
  proc22_44;
  g8a3[15] := 0;
  labels := 'STIQDXCHLK';
  proc22_48('|Attributes\');
  data29.words[18] := data29.words[18] + 4;
  index := 0;
  last := 4;
  while index <= last do begin
    proc22_48(copy(labels, 1 + index * 2, 2));
    proc22_48(':');
    if index < 4 then begin
      proc22_49(data29.bytes[94 + index], 3, false);
      proc22_48(' /')
    end else proc22_48('|?? /');
    proc22_49(data29.bytes[94 + index + 5], 3, false);
    if index < 4 then begin
      proc22_45;
      data29.words[18] := data29.words[18] + 4
    end;
    index := index + 1
  end;
  proc8_11;
  proc8_7;
  proc22_50(saved.lower_first, saved.upper_first,
            saved.lower_second, saved.upper_second)
end;
