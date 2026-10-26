{ library_27 procedure12, $03E8..$041C, attributes $0426. }
procedure proc27_12(index: integer);
begin
  if (data31.words[14] < index) and (index <= data31.words[15]) then
    with data31.items[index] do
    begin
      proc22_11(1);
      proc22_12(data31.words[12] + firstoff,
                 (data31.words[11] + secondoff) + 6);
      proc22_9(43)
    end
end;
