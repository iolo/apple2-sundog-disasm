{ utility_disk1:15 $0398..$03D2, attributes$03DE; nested in14.
  Value caption copy occupies2..9, index10, remaining11 (20 local bytes).
  Read caption backwards, subtract64, store five bits, increment parent3.
  Spare bits and the ninth element of each three-word row are untouched. }
procedure decode_seed_row(seed_text: text15);
var
  packed_index: integer;
  source_index: integer;
begin
  source_index := length(seed_text);
  packed_index := 0;
  while source_index > 0 do
  begin
    seed_layout_frame.packed_seed_rows[seed_layout_frame.code_row][packed_index] := ord(seed_text[source_index]) - 64;
    packed_index := packed_index + 1;
    source_index := source_index - 1
  end;
  seed_layout_frame.code_row := seed_layout_frame.code_row + 1
end;
