{ utility_disk1:12 $0248..$0326, attributes$0338, nested in9.
  Six words:1 value,2 field,3 system,4 pointer/outer limit,5 selected pointer,
  6 amount pointer/inner limit. System10 is fixed at6/5/6; other positions
  repeat perturbation until11 accepts. RNG calls and stores remain ordered. }
procedure place_world_systems;
var
  axis_value: integer;
  axis_index: integer;
  system_index: integer;
  work4: utilwork;
  selected: utilwork;
  work6: utilwork;
begin
  work4.system := @data29.tbl23.rows^[10];
  work4.system^.nibbles8[0] := 6;
  work4.system^.nibbles8[1] := 5;
  work4.system^.nibbles8[2] := 6;
  system_index := 1;
  work4.word := 12;
  while system_index <= work4.word do
  begin
    selected.system := @data29.tbl23.rows^[system_index];
    selected.system^.prefix8[5] := selected.system^.prefix8[5] and (-129);
    selected.system^.nibbles8[7] := 0;
    work6.word := selected.word + 12; { INC6: six words, twelve address bytes. }
    if system_index = data29.loc37.low4 then
      work6.amount^.first := 29 + (random_word + 0) mod 3
    else work6.amount^.first := 3 + (random_word + 0) mod 3;
    work6.amount^.second := (random_word + 0) mod 1000;
    if system_index <> 10 then
      repeat
        axis_index := 0;
        work6.word := 2;
        while axis_index <= work6.word do
        begin
          axis_value := selected.system^.nibbles8[axis_index];
          case axis_index of
            0: perturb_system_axis(axis_value, 1, 12);
            1: perturb_system_axis(axis_value, 1, 9);
            2: perturb_system_axis(axis_value, 0, 10)
          end;
          selected.system^.nibbles8[axis_index] := axis_value;
          axis_index := axis_index + 1
        end
      until valid_system_spacing(system_index);
    system_index := system_index + 1
  end
end;
