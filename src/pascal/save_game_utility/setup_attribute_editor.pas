{ utility_disk1:25 $0B4A..$0CFB, attributes$0D08. Four local words:
  1 x,2 y,3 index,4 loop limit. Initialize each attribute to30, then overwrite
  luck with0. Keep display reads after the corresponding text calls. }
procedure setup_attribute_editor;
var
  x: integer;
  y: integer;
  index: integer;
  limit: integer;
begin
  clear_text_window;
  write_wrapped_text('||Attribute setting\|\');
  write_wrapped_text('-- Select attribute with cursor\|\');
  write_wrapped_text('-- Use arrows to raise or lower\|\');
  write_wrapped_text('-- Press button 1 when done');
  wait_utility_input(9000);
  clear_text_window;
  write_wrapped_text('Strength     (S');
  stat_editor.caption_x := data29.text_x;
  stat_editor.first_bar_y := data29.text_y;
  write_wrapped_text('T):\|');
  x := data29.text_x;
  y := data29.text_y;
  text_newline;
  write_wrapped_text('Intelligence (IQ):\|\');
  write_wrapped_text('Dexterity    (DX):\|\');
  write_wrapped_text('Charisma     (CH):\|\');
  write_wrapped_text('Luck         (LK):');
  text_newline;
  text_newline;
  write_wrapped_text('Points: ');
  index := 0;
  limit := 4;
  while index <= limit do
  begin
    data29.bytes[94 + index] := 30;
    if index = 4 then data29.bytes[94 + index] := 0;
    assign_bounds(stat_editor.bars[index], x, x + 100, y - 6, y - 2);
    y := y + 16;
    draw_attribute_bar(index, 10);
    index := index + 1
  end;
  stat_editor.unspent_points := 440;
  assign_bounds(stat_editor.points, data29.text_x, data29.text_x + 55,
            data29.text_y - 6, data29.text_y - 2);
  draw_unspent_points;
  stat_editor.confirmed := 0
end;
