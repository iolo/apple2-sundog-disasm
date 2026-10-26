{ Both library26 variants: procedure13, $01C0..$01C4, attributes $01CE.
  Preserve17 local words shared by14/16 and grandchild15. }
procedure animate_title_letters;
var
  bottom_y: integer; {1}
  top_y: integer; {2}
  right_x: integer; {3}
  left_x: integer; {4}
  saved_strip: integer; {5}
  letter_path: array[0..5] of wordpair; {6..17}
(*$include src/pascal/title_and_boot/prepare_title_letters.pas*)
(*$include src/pascal/title_and_boot/move_title_letters.pas*)
begin
  prepare_title_letters;
  move_title_letters
end;
