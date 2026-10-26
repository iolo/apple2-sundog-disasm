{ library_22 procedure 16, $00A8..$00B2, attributes $00BC. }
procedure set_window_image_origin(firstpos, secondpos: integer);
begin
  data29.words[371] := firstpos;
  data29.words[370] := secondpos
end;
