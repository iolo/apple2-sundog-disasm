{ Game 18:11, $041A..$048C, attributes $0496. One index argument. }
procedure proc18_11(index: integer);
begin
  with g18items[index] do                   { $041A..$0420 }
  begin
    flags.high_byte := 2;                  { $0422..$0428 }
    words[3] := g18a112[127];               { $0429..$042F }
    words[2] := g18a112[126] - 5;           { $0430..$0438 }
    words[1] := words[5];                   { $0439..$043E }
    words[0] := words[4];                   { $043F..$0442 }
    flags.bit1 := false;                   { $0443..$0449 }
    if (not flags.bit4) and (bytes9[0] = 0) and flags.bit3 then
    begin                                  { $044A..$0461 }
      g18a112[125] := g18a112[125] - 1;     { $0463..$0468 }
      if g18items[0].bytes9[0] = g18a112[124] then
        g18items[0].flags.bit5 := false    { $046B..$0487 }
    end;
    proc18_5(index, true)                   { $0488..$048A }
  end
end;
