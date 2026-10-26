{ library_27 procedure 11, $0346..$03DB, attributes $03E6.
  Slots5..12 retained to make the nested procedure's lexical accesses explicit. }
procedure apply_item_action(action: integer; var itemcode, firstpos, secondpos: integer);
var
  byteidx: integer;    { 5 }
  basecode: integer;   { 6 }
  amount: integer;     { 7 }
  index: integer;      { 8 }
  change: integer;     { 9 }
  highcode: boolean;   { 10 }
  changed: boolean;    { 11 }
  clearit: boolean;    { 12 }
(*$include src/pascal/item_panels/apply_matching_item_effect.pas*)
begin
  select_drawing_buffer(0, false);
  basecode := itemcode mod 32;
  byteidx := basecode - 15;
  highcode := itemcode > 127;
  clearit := false;
  changed := false;
  if action = 0 then clearit := true
  else if action = 2 then apply_matching_item_effect(10, 2)
  else if action = 1 then
  begin
    apply_matching_item_effect(8, 3);
    apply_matching_item_effect(9, -1);
    apply_matching_item_effect(15, -3);
    apply_matching_item_effect(16, -1);
    apply_matching_item_effect(17, -2);
    apply_matching_item_effect(18, -2)
  end;
  if changed then
    if amount > 0 then
    begin
      change := data29.bytes[118 + amount] + change;
      clamp_word(0, change, 255);
      data29.bytes[118 + amount] := change;
      data29.flags82[60] := true
    end;
  if clearit then
  begin
    write_item_caption('');
    itemcode := 0
  end;
  select_drawing_buffer(0, false);
  if clearit then plot_item_icon(firstpos, secondpos)
end;
