{ game_12 procedure20, $10F6..$1107, attributes $1112; nested in1.
  Value caption copy occupies slots3..10 before any calls. }
procedure proc12_20(mode: integer; caption: text15);
begin
  proc12_2;
  g12.words[4] := mode;
  proc12_13(caption);
  proc12_2
end;
