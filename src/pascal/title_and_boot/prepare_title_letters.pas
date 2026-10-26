{ Both library26 variants: procedure14, $001E..$0071, attributes $007C;
  nested in13;15 is its child. }
procedure prepare_title_letters;
(*$include src/pascal/title_and_boot/set_letter_path.pas*)
begin
  left_x := 0;
  right_x := 279;
  top_y := 44;
  bottom_y := top_y + 23;
  saved_strip := 1024;
  set_letter_path(0, 252, 0);
  set_letter_path(1, 245, 35);
  set_letter_path(2, 252, 70);
  set_letter_path(3, 245, 105);
  set_letter_path(4, 252, 140);
  set_letter_path(5, 245, 175);
  disk_blocks_io(16384, 12, 64, true)
end;
