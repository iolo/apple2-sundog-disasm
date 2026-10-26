{ game_19 procedure16, $0B72..$0C04, attributes $0C0E.
  Capture the destination row after the amount picker returns, then retain
  that address through the balance addition and store. }
procedure proc19_16(var available: wordpair);
var
  target: integer;
  balance, transfer: wordpair;
  area: bounds4;
  systems: g19addr;
begin
  proc22_18(area, data29.words[14], data29.words[13],
            data29.words[12] + 23, data29.words[11]);
  proc19_9(target, area, 1, 12, data29.loc37.low4, 3);
  if target > 0 then
  begin
    proc22_19(area, 8);
    proc22_19(data29.bounds11, 0);
    proc22_46(0, 8);
    proc22_48('Transfer to ');
    systems.word := data29.words[23];
    proc22_48(systems.rows^[target].caption);
    proc22_45;
    transfer := g19.amount8;
    proc19_7(available, transfer);
    systems.word := data29.words[23];
    with systems.rows^[target] do
    begin
      balance := amount6;
      proc28_2(transfer, balance);
      amount6 := balance
    end
  end;
  proc22_19(area, 8);
  proc22_19(data29.bounds11, 0)
end;
