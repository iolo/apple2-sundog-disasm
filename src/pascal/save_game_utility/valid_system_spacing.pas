{ utility_disk1:11 $01CA..$023A, attributes$0246, nested in9.
  Result1/2, argument3; locals4 index,5 selected pointer,6 limit. Compare with
  earlier systems and system10. Integer AND retains both absolute-value calls.
  Return false through self EXIT on the first nearby pair. }
function valid_system_spacing(system_index: integer): boolean;
var
  index: integer;
  selected: utilwork;
  limit: integer;
begin
  valid_system_spacing := true;
  selected.system := @data29.tbl23.rows^[system_index];
  index := 1;
  limit := 12;
  while index <= limit do
  begin
    if (index < system_index) or (index = 10) then
      if odd(ord(word_abs(selected.system^.nibbles8[0] -
                           data29.tbl23.rows^[index].nibbles8[0]) < 2) and
             ord(word_abs(selected.system^.nibbles8[1] -
                           data29.tbl23.rows^[index].nibbles8[1]) < 2)) then
      begin
        valid_system_spacing := false;
        exit(valid_system_spacing)
      end;
    index := index + 1
  end
end;
