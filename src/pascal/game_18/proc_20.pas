{ game_18 procedure 20, $0E0C..$0EA5, attributes $0EB0.
  Selects the four-block buffer path or the table/grid setup path. }
procedure proc18_20;
var
  secondpos, firstpos: integer;
  buffer, argaddr: address16;
begin
  if arg1 = 16 then
  begin
    buffer.word := 6144;
    proc22_53(6144, 4, data29.words[32] + 8, true);
    argaddr.word := arg4;
    firstpos := argaddr.value^ - 10;
    proc22_37(1, firstpos, 19);
    argaddr.word := arg3;
    secondpos := argaddr.value^ * 8 - 48;
    proc22_37(8, secondpos, 88);
    proc22_16(secondpos, firstpos);
    data29.words[20] := 1;
    proc22_15(1);
    buffer.bytes^[2000] := firstpos;
    buffer.bytes^[2001] := secondpos;
    proc22_50(firstpos * 7 + 2, firstpos * 7 + 137,
              secondpos + 2, secondpos + 93);
    g18w131 := data29.words[14];
    g18a112[130] := data29.words[13];
    g18a112[129] := data29.words[12];
    g18a112[128] := data29.words[11]
  end
  else
  begin
    proc18_16;
    if odd(g18a133[139]) then proc18_18
    else if odd(g18a133[136]) then proc18_19
  end
end;
