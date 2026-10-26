{ game_13 procedure46, $217A..$2209, attributes $221A; nested in1.
  Three nested map levels retain their title/pop order. After returning from
  a deeper level, store the full complement of word347, not a Boolean1/0.
  All12 location bytes are copied before flag31 is enabled. }
procedure proc13_46;
var
  mapok: integer; {1}
  maploc: g19loc; {2..7}
begin
  proc13_43('MAPS');
  maploc := data29.pos36;
  mapok := 0;
  data29.flags82[31] := true;
  repeat
    proc13_12(1, maploc, mapok, 0, 0);
    if odd(mapok) then
    begin
      proc13_43(data29.names23.systems^[maploc.fields.system].caption);
      repeat
        proc13_12(2, maploc, mapok, 0, 0);
        if odd(mapok) and (maploc.fields.planet > 0) then
        begin
          proc13_43(data29.names24.planets^[maploc.fields.planet]);
          repeat
            proc13_12(3, maploc, mapok, 0, 1)
          until (not odd(mapok)) or odd(data29.words[347]);
          proc13_44;
          mapok := -1 - data29.words[347]
        end
      until not odd(mapok);
      proc13_44;
      mapok := -1 - data29.words[347]
    end
  until not odd(mapok);
  proc13_44;
  data29.flags82[31] := false
end;
