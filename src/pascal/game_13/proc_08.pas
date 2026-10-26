{ game_13 procedure8, $0202..$0257, attributes $0262; nested in3.
  Capture the VAR location before positioning. In the planet path capture the
  name pointer before drawing, then reread its length afterward. The reference
  compiler uses the stable VAR parameter directly, omitting the original's
  private pointer copy in slot4. The name pointer occupies slot4 instead of5;
  locals shrink from4 to2 bytes. No callee receives the parameter slot's address,
  and no child or raw slot observer depends on these private local offsets. }
procedure proc13_8(column, row: integer; var place: g19loc);
var
  name: captionaddr;
begin
  with place do
  begin
    proc22_46(column, row);
    if fields.planet = 0 then
    begin
      proc22_49(fields.w0low, 3, true);
      proc22_48(' MARK ');
      proc22_49(14 + proc22_30(fields.w0high, 1), 3, true)
    end
    else
    begin
      name.word := data29.words[24] + (fields.planet - 1) * 16;
      proc22_48(name.table^[0]);
      proc13_4(length(name.table^[0]) + 10, row)
    end
  end
end;
