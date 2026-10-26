{ library_25 procedure6, $017A..$01D4, attributes $01E0.
  Preserve slots6..9 for its nested child. The value-copy bounds occupy2..5. }
procedure proc25_6(area: bounds4);
var
  secondbase: integer; {6}
  firstbase: integer;  {7}
  secondtext: integer; {8}
  firsttext: integer;  {9}
  index: integer;      {10}
  last: integer;       {11}
(*$include src/pascal/library_25/proc_09.pas*)
begin
  proc22_19(area, 0);
  proc22_13(0);
  firstbase := area.lower_first;
  secondbase := area.lower_second;
  index := 1;
  last := data30.nitems;
  while index <= last do
  begin
    if data30.items[index].tag.button then proc25_9(index)
    else
      with data30.items[index] do
      begin
        proc22_11(0);
        proc22_12(firstbase + words[3], secondbase + words[2]);
        proc22_9(words[1])
      end;
    index := index + 1
  end
end;
