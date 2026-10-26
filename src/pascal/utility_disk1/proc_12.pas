{ utility_disk1:12 $0248..$0326, attributes$0338, nested in9.
  Six words:1 value,2 field,3 system,4 pointer/outer limit,5 selected pointer,
  6 amount pointer/inner limit. System10 is fixed at6/5/6; other positions
  repeat perturbation until11 accepts. RNG calls and stores remain ordered. }
procedure util1_12;
var
  value: integer;
  field: integer;
  number: integer;
  work4: utilwork;
  selected: utilwork;
  work6: utilwork;
begin
  work4.system := @data29.tbl23.rows^[10];
  work4.system^.nibbles8[0] := 6;
  work4.system^.nibbles8[1] := 5;
  work4.system^.nibbles8[2] := 6;
  number := 1;
  work4.word := 12;
  while number <= work4.word do
  begin
    selected.system := @data29.tbl23.rows^[number];
    selected.system^.prefix8[5] := selected.system^.prefix8[5] and (-129);
    selected.system^.nibbles8[7] := 0;
    work6.word := selected.word + 12; { INC6: six words, twelve address bytes. }
    if number = data29.loc37.low4 then
      work6.amount^.first := 29 + (proc22_3 + 0) mod 3
    else work6.amount^.first := 3 + (proc22_3 + 0) mod 3;
    work6.amount^.second := (proc22_3 + 0) mod 1000;
    if number <> 10 then
      repeat
        field := 0;
        work6.word := 2;
        while field <= work6.word do
        begin
          value := selected.system^.nibbles8[field];
          case field of
            0: util1_10(value, 1, 12);
            1: util1_10(value, 1, 9);
            2: util1_10(value, 0, 10)
          end;
          selected.system^.nibbles8[field] := value;
          field := field + 1
        end
      until util1_11(number);
    number := number + 1
  end
end;
