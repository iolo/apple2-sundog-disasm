{ game_16 procedure38, $1222..$1244, attributes $1250; nested in37. }
procedure fill_item_availability(first_flag, final_flag, item_code, max_item_code: integer);
var
  flag_index: integer;
  final_index: integer;
begin
  flag_index := first_flag;
  final_index := final_flag;
  while flag_index <= final_index do
  begin
    data29.flags82[flag_index] := item_code <= max_item_code;
    item_code := item_code + 1;
    flag_index := flag_index + 1
  end
end;
