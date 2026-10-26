{ game_20 procedure3, $002C..$0095, attributes $009E.
  Read the block before multiplying count/index. All copies use forward CSP2.
  Operation2 still reads the block; only operation3 writes it back. }
procedure proc20_3(block, count, index, operation: integer);
var
  offset: integer;
begin
  proc22_53(g20.addr21.word, 1, block, true);
  offset := count * index;
  case operation of
    1:
      begin
        if odd(g20.words[16]) then
          moveleft(g20.addr21.bytes^[288], g20.addr20.bytes^, 54);
        moveleft(g20.addr21.bytes^[offset], g20.stock22, count)
      end;
    3: moveleft(g20.stock22, g20.addr21.bytes^[offset], count);
    4: moveleft(g20.addr21.bytes^[offset], g20.stock38, count)
  end;
  if operation = 3 then proc22_53(g20.addr21.word, 1, block, false)
end;
