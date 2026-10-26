{ Both library26 variants: procedure15, $0000..$0012, attributes $001C;
  nested in14, accessing13 two lexical levels up. Store second word first. }
procedure set_letter_path(letter_index, start_x, target_x: integer);
begin
  letter_path[letter_index].second := start_x;
  letter_path[letter_index].first := target_x
end;
