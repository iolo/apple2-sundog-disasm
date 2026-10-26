{ game_18 procedure23, $114A..$1363, attributes $1370.
  Parent arguments4/3/2 hold addresses; caller-owned words remain aliased.
  Choice false opens the recovered game8 scope after preserving bounds. }
procedure proc18_23(chosen: boolean);
var
  direction: integer;
  saved: bounds4;
  xpos: address16;
  ypos: address16;
  resultp: address16;
begin
  xpos.word := arg4;
  ypos.word := arg3;
  resultp.word := arg2;
  if not odd(data29.words[347]) then begin
    data29.nibbles45[0] := data29.nibbles45[1];
    data29.nibbles45[1] := data29.nibbles45[2]
  end;
  g18a133[143] := 1;
  g18a112[119] := xpos.value^;
  g18a112[118] := ypos.value^;
  proc22_37(10, xpos.value^, 39);
  proc22_37(7, ypos.value^, 23);
  direction := 5 - 3 * proc22_34(xpos.value^ - 20) -
               proc22_34(ypos.value^ - 12);
  case direction of
    1, 2, 4, 5: begin
      xpos.value^ := xpos.value^ - 2;
      ypos.value^ := ypos.value^ - 2
    end;
    3, 6: begin
      xpos.value^ := xpos.value^ - 2;
      ypos.value^ := ypos.value^ + 2
    end;
    7, 8: begin
      xpos.value^ := xpos.value^ + 2;
      ypos.value^ := ypos.value^ - 2
    end;
    9: begin
      xpos.value^ := xpos.value^ + 2;
      ypos.value^ := ypos.value^ + 2
    end
  end;
  if not odd(xpos.value^) then
    xpos.value^ := xpos.value^ + proc22_34(20 - xpos.value^);
  if chosen then begin
    if odd(g18a133[142]) then data29.nibbles45[2] := 8
    else begin
      data29.nibbles45[2] := 9;
      g18items[1].flags.bit4 := true
    end;
    if odd(g18a133[141]) then begin
      resultp.value^ := g18a112[116];
      g18w147 := data29.bytes[550]
    end else begin
      g18w147 := 0;
      resultp.value^ := 21;
      case arg1 of
        8: resultp.value^ := 12;
        9: resultp.value^ := 13;
        10: resultp.value^ := 14;
        11: resultp.value^ := 23;
        16: begin resultp.value^ := 7; g18w147 := 1 end
      end
    end;
    with g18items[g18w147] do begin
      data29.bytes[548] := split8.high;
      data29.bytes[549] := split8.low;
      data29.bytes[550] := g18w147;
      data29.bytes[551] := 1;
      data29.bytes[552] := ord(flags.bit1)
    end
  end else begin
    if not odd(data29.words[347]) then data29.nibbles45[2] := 7;
    if data29.nibbles45[2] <> 12 then begin
      proc22_41(g18a133[134], g18a133[133]);
      saved := data29.bounds11;
      proc8_1(xpos.value^, ypos.value^);
      proc22_42(g18a133[134], g18a133[133], data29.words[298], saved);
      data29.bounds11 := saved;
      g18a133[143] := ord(data29.nibbles45[2] > 10)
    end
  end
end;
