{ library_25 procedure8, $02BC..$038D, attributes $039C.
  itemcode's address is passed but unused. Outputs may alias: store input0,
  then input1, and reread both. Flash cleanup uses the low bit of the count. }
procedure proc25_8(index: integer; var itemcode: integer; area: bounds4;
                   var input0, input1: integer);
var
  firstbase, secondbase, flashes, counter, work: integer;
begin
  firstbase := area.lower_first;
  secondbase := area.lower_second;
  with data30.items[index] do
    if tag.button then
    begin
      input0 := 1;
      input1 := 0;
      proc22_14(firstbase + bounds.lower_first,
                firstbase + bounds.upper_first,
                secondbase + bounds.lower_second,
                secondbase + bounds.upper_second);
      proc22_7(3)
    end
    else
    begin
      proc22_19(area, 0);
      proc22_11(1);
      flashes := 0;
      repeat
        data29.words[354] := data29.words[354] + 1;
        proc22_12(firstbase + words[3], secondbase + words[2]);
        proc22_9(words[1]);
        flashes := flashes + 1;
        counter := 0;
        while counter <= 70 do
        begin
          work := counter + counter - counter;
          counter := counter + 1
        end;
        input0 := proc22_2(0);
        input1 := proc22_2(1)
      until odd(input0) or odd(input1)
            or (data29.words[354] >= data29.words[353])
            or odd(data29.words[347]);
      if odd(input0) then proc22_4(30, 50, 10, 0, 0, 0, 0);
      if odd(flashes) then
      begin
        proc22_12(firstbase + words[3], secondbase + words[2]);
        proc22_9(words[1])
      end
    end
end;
