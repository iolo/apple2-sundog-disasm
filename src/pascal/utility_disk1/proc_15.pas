{ utility_disk1:15 $0398..$03D2, attributes$03DE; nested in14.
  Value caption copy occupies2..9, index10, remaining11 (20 local bytes).
  Read caption backwards, subtract64, store five bits, increment parent3.
  Spare bits and the ninth element of each three-word row are untouched. }
procedure util1_15(caption: text15);
var
  index: integer;
  remaining: integer;
begin
  remaining := length(caption);
  index := 0;
  while remaining > 0 do
  begin
    work14.codes18[work14.words[3]][index] := ord(caption[remaining]) - 64;
    index := index + 1;
    remaining := remaining - 1
  end;
  work14.words[3] := work14.words[3] + 1
end;
