{ game_19 procedure17, $0C10..$0DC2, attributes $0DCE.
  Hold the entry system-row address through every menu call and final store.
  SYSTEM_CORE23 ($05F2) refuses an over-capacity append: a name longer than9
  yields just ' Bank', rather than its first9 characters plus that suffix. }
procedure proc19_17;
var
  systems: g19addr;
  heading: string[14];
begin
  systems.word := data29.words[23];
  with systems.rows^[data29.loc37.low4] do
  begin
    g19.amount10 := amount6;
    heading := '';
    if length(caption) <= 9 then heading := caption;
    heading := concat(heading, ' Bank');
    proc19_2(heading);
    proc22_46(0, 4);
    proc22_48('|     UNITELLER');
    proc22_45;
    repeat
      proc22_19(data29.bounds11, 0);
      proc22_46(0, 6);
      proc28_5('On hand:   ', data29.money46);
      proc22_46(0, 8);
      if proc28_6(g19.amount8, g19.amount10) then
        proc28_5('Deficit:   ', g19.amount10)
      else proc28_5('In bank:   ', g19.amount10);
      proc22_14(data29.words[14], data29.words[13],
                data29.words[12] + 40, data29.words[11]);
      proc22_7(8);
      proc25_2;
      g19.words[21] := g19.words[20] - 10;
      if proc28_6(data29.money46, g19.amount8) then
      begin
        proc25_3(1, 'DEPOSIT CASH', g19.words[23], g19.words[22],
                  g19.words[21], g19.words[21] + 10);
        g19.words[21] := g19.words[21] - 15
      end;
      if proc28_6(g19.amount10, g19.amount8) then
      begin
        proc25_3(2, 'WITHDRAW CASH', g19.words[23], g19.words[22],
                  g19.words[21], g19.words[21] + 10);
        g19.words[21] := g19.words[21] - 15;
        proc25_3(3, 'TRANSFER', g19.words[23], g19.words[22],
                  g19.words[21], g19.words[21] + 10)
      end;
      g19.words[25] := 0;
      g19.words[29] := 0;
      proc19_3(g19.words[25], g19.words[24], data29.words[297],
                data29.bounds11, g19.words[29]);
      case g19.words[25] of
        1: proc19_7(data29.money46, g19.amount10);
        2: proc19_7(g19.amount10, data29.money46);
        3: proc19_16(g19.amount10)
      end
    until not odd(g19.words[29]) or odd(data29.words[347]);
    amount6 := g19.amount10
  end
end;
