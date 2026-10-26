{ game_18 procedure 13, $077A..$08FA, attributes $0906.
  Frame slot 1 is initially_placed; slot 2 is the address of index.
  An unsuccessful placement sets index to -1 and exits this procedure. }
procedure proc18_13(var index: integer; initially_placed: boolean);
var
  remaining, secondpos, firstpos: integer;
  randomv: integer;
  failed, hit: boolean;
begin
  if index > g18a112[113] then
  begin
    index := -1;
    exit(proc18_13)
  end;
  { $078A: capture the entry address before any calls or changes to index. }
  with g18items[index] do
  begin
    randomv := proc22_3;
    flags.bit0 := (randomv mod 8) = 0;
    split8.high := 0;
    randomv := proc22_3;
    split8.low := randomv mod 5;
    flags.bit1 := false;
    if initially_placed then
    begin
      { $07BF..$0820. }
      proc18_9(index, firstpos, secondpos, remaining);
      if remaining = 0 then
      begin
        index := -1;
        g18a112[124] := 0;
        exit(proc18_13)
      end;
      words[5] := firstpos;
      words[4] := secondpos;
      words[3] := words[5];
      words[2] := words[4];
      words[1] := words[3];
      words[0] := words[2];
      flags.bit5 := false;
      flags.bit3 := true;
      flags.bit4 := true;
      randomv := proc22_3;
      bytes9[0] := 2 + (randomv mod 250)
    end
    else
    begin
      { $0823..$0859: try the packed grid, random placement, then grid again. }
      randomv := proc22_3;
      if (randomv mod 3) = 0 then
        proc18_8(index, firstpos, secondpos, remaining)
      else remaining := 0;
      if remaining = 0 then
        proc18_9(index, firstpos, secondpos, remaining);
      if remaining = 0 then
        proc18_8(index, firstpos, secondpos, remaining);
      { $085B..$0877: the collision call occurs even when remaining is zero. }
      failed := remaining = 0;
      hit := proc18_3(24, g18a112[127], g18a112[126] + 5);
      if failed or hit then
      begin
        g18a112[124] := 0;
        index := -1;
        exit(proc18_13)
      end;
      words[5] := g18a112[127];
      words[4] := g18a112[126] + 5;
      if odd(g18a133[140]) then
      begin
        words[1] := firstpos;
        words[0] := secondpos + 10 * proc22_34(words[4] - secondpos)
      end
      else
      begin
        words[1] := firstpos + proc22_34(words[5] - firstpos) *
                    proc22_35(secondpos - words[4]);
        words[0] := secondpos
      end;
      words[3] := firstpos;
      words[2] := secondpos;
      flags.bit5 := true;
      flags.bit3 := false;
      flags.bit4 := false;
      bytes9[0] := 0
    end;
    { $08E8..$08F8: common tail, reached only after successful placement. }
    split6.high := 23;
    split6.low := 24;
    proc18_4(index)
  end
end;
