{ library_28 procedure5, $00B2..$00F2, attributes $00FC. }
procedure proc28_5(caption: text15; value: wordpair);
begin
  proc22_48(caption);
  if value.first = 0 then proc22_49(value.second, 8, false)
  else if value.first > 0 then
  begin
    proc22_49(value.first, 5, false);
    proc22_49(value.second, 3, true)
  end
  else
  begin
    proc22_49(value.first, 5, false);
    proc22_49(-value.second, 3, true)
  end;
  proc22_45
end;
