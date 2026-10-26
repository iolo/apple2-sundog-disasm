{ game_12 procedure15, $0CE6..$0F3B, attributes $0F50; nested in1.
  Child16 shares slots3/4/5. WITH captures cargo in compiler slot19.
  Retain conditionally uninitialized shield/code slots and aliased outputs.
  After menu construction, dead private slots1/2 save BOTH poll polls. }
procedure proc12_15;
var
  index: integer; {1}
  count: integer; {2}
  right: integer; {3}
  left: integer; {4}
  top: integer; {5}
  shield: integer; {6}
  code: integer; {7}
  item: integer; {8}
  poll: integer; {9}
  caption: text15; {10..17}
  limit: integer; {18}
(*$include src/pascal/game_12/proc_16.pas*)
begin
  proc12_2;
  proc25_2;
  top := 5;
  left := 4;
  right := 62;
  if g12.words[4] = 0 then
  begin
    item := 1;
    poll := 0;
    if (g12.words[6] > 0) and data29.flags82[7] then
    begin
      proc12_16(4, 'JETTISON');
      item := item + 1
    end;
    if g12.words[6] > 1 then
    begin
      proc12_16(3, 'GUNS');
      item := item + 1
    end;
    if g12.words[6] > 2 then
    begin
      shield := item;
      proc12_16(2, 'SHIELDS');
      item := item + 1;
      if data29.flags82[20] then
        if data29.flags82[12] then
        begin
          proc12_16(6, 'CLOAK');
          poll := 1
        end
        else proc12_16(5, 'CLOAK')
    end;
    proc12_16(7, 'COMM')
  end
  else if g12.words[4] = 1 then
  begin
    if data29.words[224] < 255 then
    begin
      proc12_16(17, 'FULL SHLDS');
      proc12_16(8, 'SHIELDS `')
    end;
    if data29.words[224] > 0 then proc12_16(9, 'SHIELDS &');
    if data29.flags82[4] then proc12_16(10, 'SHLDS OFF')
  end
  else if g12.words[4] = 2 then
  begin
    count := 0;
    caption := 'DUMP  ';
    index := 1;
    limit := 2;
    while index <= limit do
    begin
      with data29.stock234[index] do
        if (kind > 0) and (kind < 31) then
        begin
          caption[6] := chr(48 + index);
          proc12_16(10 + index, caption);
          count := count + 1
        end;
      index := index + 1
    end;
    if count = 2 then proc12_16(13, 'DUMP BOTH')
  end
  else if g12.words[4] = 3 then
  begin
    proc12_16(14, 'LASER');
    proc12_16(15, 'CANNON');
    if odd(g12.words[27]) then proc12_16(16, 'TRACTOR');
    if (g12.words[6] > 2) and (data29.words[227] > 0) then
    begin
      if data29.flags82[4] then proc12_16(10, 'SHLDS OFF');
      if (data29.words[224] < 255) and not odd(g12.words[27]) then
        proc12_16(17, 'FULL SHLDS')
    end
  end;
  proc22_19(data29.bnd335, 8);
  proc25_6(data29.bnd335);
  if g12.words[4] = 0 then
  begin
    if odd(poll) then proc25_8(item, code, data29.bnd335, poll, poll);
    if data29.flags82[4] then proc25_8(shield, code, data29.bnd335, poll, poll)
  end;
  proc12_2;
  repeat
    proc12_12;
    index := proc22_2(0);
    count := proc22_2(1)
  until not (odd(index) or odd(count));
  proc22_42(g12.words[2], g12.words[1], g12.words[41], data29.bnd335)
end;
