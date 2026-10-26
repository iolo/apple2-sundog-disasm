{ game_19 procedure25, $121C..$130E, attributes $131A.
  The first SCONCAT capacity is9: an overlong city name contributes no text.
  The original dispatch runs before the selected/cancel exit test. }
procedure proc19_25;
var
  heading: text15;
  rowpos, choice, found, selected: integer;
begin
  proc19_5;
  heading := '';
  if length(data29.names25.cities^[data29.bits37.mid6]) <= 9 then
    heading := data29.names25.cities^[data29.bits37.mid6];
  heading := concat(heading, ' Depot');
  proc19_2(heading);
  g19.words[15] := g19.words[14] + g19.words[13] + (16 - g19.words[12]);
  proc22_50(data29.words[14], data29.words[13], data29.words[12] + 17, data29.words[11]);
  repeat
    proc25_2;
    rowpos := g19.words[20] - 57;
    proc25_3(1, 'REFUEL SHIP', g19.words[23], g19.words[22], rowpos, rowpos + 10);
    rowpos := rowpos + 15;
    proc25_3(2, 'REPAIR SHIP', g19.words[23], g19.words[22], rowpos, rowpos + 10);
    rowpos := rowpos + 15;
    proc25_3(3, 'BUY AUX FUEL', g19.words[23], g19.words[22], rowpos, rowpos + 10);
    rowpos := rowpos + 15;
    proc19_3(choice, found, data29.words[297], data29.bounds11, selected);
    case choice of
      1: proc19_20;
      2: proc19_21;
      3: proc19_24
    end
  until not odd(selected) or odd(data29.words[347]);
  proc19_6
end;
