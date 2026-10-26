{ library_27 procedure 5, $00C2..$00F2, attributes $00FC.
  A full table overwrites its last entry. No count clamp or new error is added. }
procedure append_panel_item(newcode, firstpos, secondpos: integer);
begin
  if data31.words[16] < 28 then data31.words[16] := data31.words[16] + 1;
  with data31.items[data31.words[16]] do
  begin
    code := newcode mod 256;
    firstoff := firstpos;
    secondoff := secondpos
  end
end;
