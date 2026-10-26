{ game_19 procedure15, $09BC..$0B65, attributes $0B70.
  The initial unused system-row address calculation has no dereference or call.
  Table pointers below are refreshed at their original points of use. }
procedure proc19_15;
var
  target, rowpos, selected: integer;
  area: bounds4;
  systems: g19addr;
  planets: g19paddr;
begin
  proc19_5;
  proc19_2('TransStation');
  proc22_18(area, data29.words[14], data29.words[13],
            data29.words[12] + 15, data29.words[11]);
  repeat
    g19.words[28] := 0;
    proc22_19(area, 8);
    proc22_19(data29.bounds11, 0);
    rowpos := g19.words[20] - 10;
    proc25_2;
    planets.word := data29.words[24];
    if planets.rows^[data29.loc37.mid5].place7.low9 mod 8 > 1 then
    begin
      proc25_3(1, 'TO CITY', g19.words[23], g19.words[22], rowpos, rowpos + 10);
      rowpos := rowpos - 15
    end;
    planets.word := data29.words[24];
    if data29.bits37.mid6 = planets.rows^[data29.loc37.mid5].place7.mid6 then
    begin
      systems.word := data29.words[23];
      if systems.rows^[data29.loc37.low4].bits5.low2 > 1 then
      begin
        proc25_3(2, 'TO PLANET', g19.words[23], g19.words[22], rowpos, rowpos + 10);
        rowpos := rowpos - 15
      end;
      proc25_3(3, 'TO SYSTEM', g19.words[23], g19.words[22], rowpos, rowpos + 10)
    end;
    g19.words[25] := 0;
    selected := 0;
    proc19_3(g19.words[25], g19.words[24], data29.words[297], data29.bounds11, selected);
    target := 0;
    case g19.words[25] of
      1:
        begin
          planets.word := data29.words[24];
          with planets.rows^[data29.loc37.mid5].place7 do
            proc19_9(target, area, mid6, low9 mod 8, data29.bits37.mid6, g19.words[25])
        end;
      2:
        begin
          systems.word := data29.words[23];
          with systems.rows^[data29.loc37.low4].bits5 do
            proc19_9(target, area, mid5, low2, data29.loc37.mid5, g19.words[25])
        end;
      3: proc19_9(target, area, 1, 12, data29.loc37.low4, g19.words[25])
    end;
    if target > 0 then proc19_12(g19.words[25], target, area)
  until not odd(selected) or odd(data29.words[347]) or odd(g19.words[28]);
  if not odd(g19.words[28]) then proc19_6
end;
