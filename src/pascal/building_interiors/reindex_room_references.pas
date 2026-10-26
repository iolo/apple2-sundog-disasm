{ game_18 procedure 5, $0068..$00E2, attributes $00F0, lexical level 2.
  See docs/decompilation/game_18.md. Include within the original parent scope.
  Arguments occupy frame slots 2=index and 1=clear_reference. }
procedure reindex_room_references(index: integer; clear_reference: boolean);
var
  search_value: integer;
  replacement: integer;
  row_index: integer;
  column_index: integer;
begin
  { $0068..$006E: capture the address once, before changing packed fields. }
  with room_actors[index] do
  begin
    { $0070..$0076 }
    if flags.bit2 then
    begin
      { $0078..$0090 }
      if clear_reference then
      begin
        replacement := 0;
        flags.bit2 := false;
        search_value := index
      end
      else
      begin
        replacement := index;
        search_value := index + 1
      end;
      { $0092..$00CF: only the first two nibbles of each of three words.
        Explicit while loops preserve the observed bounds and increment order. }
      row_index := 0;
      while row_index <= 2 do
      begin
        column_index := 0;
        while column_index <= 1 do
        begin
          if counter_slots[row_index][column_index] = search_value then
            counter_slots[row_index][column_index] := replacement;
          column_index := column_index + 1
        end;
        row_index := row_index + 1
      end
    end;
    { $00D1..$00E1: executes even when bit2 was initially clear. }
    if clear_reference then
    begin
      flags.bit5 := true;
      flags.bit3 := false
    end
  end
  { $00E2: RNP 0. }
end;
