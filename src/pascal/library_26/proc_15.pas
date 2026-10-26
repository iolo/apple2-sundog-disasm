{ Both library26 variants: procedure15, $0000..$0012, attributes $001C;
  nested in14, accessing13 two lexical levels up. Store second word first. }
procedure proc26_15(index, second, first: integer);
begin
  positions[index].second := second;
  positions[index].first := first
end;
