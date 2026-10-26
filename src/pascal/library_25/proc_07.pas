{ library_25 procedure7, $0210..$02AD, attributes $02BA.
  Output index is cleared before code; on hit code is stored before index.
  Both distance calls run on the sprite path before their results combine. }
procedure proc25_7(firstpos, secondpos: integer; var code, found: integer);
var
  index: integer;
  nearfirst, nearsecond: boolean;
begin
  found := 0;
  code := 0;
  index := 1;
  while (index <= data30.nitems) and (found = 0) do
    with data30.items[index] do
    begin
      if tag.button then
      begin
        if (bounds.lower_first <= firstpos) and (firstpos <= bounds.upper_first)
           and (bounds.lower_second <= secondpos + 2)
           and (secondpos - 2 <= bounds.upper_second) then
        begin
          code := tag.code;
          found := index
        end
        else index := index + 1
      end
      else
      begin
        nearfirst := proc22_35(firstpos - words[3]) < 8;
        nearsecond := proc22_35(secondpos - words[2]) < 8;
        if nearfirst and nearsecond then
        begin
          code := tag.code;
          found := index
        end
        else index := index + 1
      end
    end
end;
