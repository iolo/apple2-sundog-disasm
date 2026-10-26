{ library_25 procedure4, $0086..$00BB, attributes $00C4.
  Sprite entries retain caption/spare bits and their unused final word. }
procedure proc25_4(code, imagecode, firstpos, secondpos: integer);
begin
  if data30.nitems < 21 then data30.nitems := data30.nitems + 1;
  with data30.items[data30.nitems] do
  begin
    tag.code := code;
    tag.button := false;
    words[1] := imagecode;
    words[3] := firstpos;
    words[2] := secondpos
  end
end;
