{ game_21 procedure13, $067A..$06B4, attributes $06BE.
  The six-word value copy precedes both sequential VAR output stores. }
procedure proc21_13(var xpos, ypos: integer; position: g19loc);
begin
  xpos := 28 * proc21_2(position.fields.kind2, arg6, 40) + position.fields.word4 mod 28;
  ypos := g21.words[21] * proc21_2(position.fields.kind3, arg5, 24) +
          position.fields.w5low mod g21.words[21]
end;
