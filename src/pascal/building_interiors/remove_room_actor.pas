{ Game 18:6, $0122..$019F, attributes $01AC. Removes an indexed entry.
  DATASEG29 address(word271)+10 is byte offset 550 from the data base. }
procedure remove_room_actor(index: integer);
var
  source_index: integer;
  last_actor: integer;
(*$include src/pascal/building_interiors/fix_removed_actor_index.pas*)
begin
  toggle_room_actor(index);                          { $0122..$0123 }
  selected_actor := data29.bytes[550];             { $0125..$012B }
  if index = selected_actor then                   { $012F..$013E }
    data29.bytes[550] := 0
  else if index < selected_actor then              { $0140..$0153 }
    data29.bytes[550] := selected_actor - 1;
  selected_actor := data29.bytes[550];             { $0154..$015A }
  source_index := index + 1;                      { $015E..$0161 }
  last_actor := actor_count;                          { $0163..$0167: captured bound. }
  while source_index <= last_actor do                   { $0169..$0189 }
  begin
    room_actors[source_index - 1] := room_actors[source_index]; { $016E..$017C: MOV 10. }
    reindex_room_references(source_index - 1, false);
    source_index := source_index + 1
  end;
  fix_removed_actor_index(room_layout_state[124]);                    { $018B..$018E }
  fix_removed_actor_index(room_layout_state[123]);                    { $0190..$0193 }
  actor_count := actor_count - 1                    { $0195..$019B: after both calls. }
end;
