{ game_15 procedure4, $0080..$020D, attributes $0218.
  Retain drawing/state-update order and the four original label literals. }
procedure proc15_4;
var
  value: integer;
begin
  proc22_6;
  proc22_17(false);
  proc22_19(data29.bounds7, 10);
  proc22_18(data29.bounds327, 128, 186, 107, 116);
  proc22_18(data29.bnd307, 245, 265, 4, 13);
  proc22_18(data29.bnd303, 14, 62, 4, 13);
  proc15_2(data29.bnd331, 8);
  proc15_3(data29.bnd323, 'FUEL');
  proc15_3(data29.bnd319, 'GUNS');
  proc15_3(data29.bnd315, 'SHLD');
  proc15_3(data29.bnd311, 'WARP');
  proc15_2(data29.bnd335, 8);
  proc22_14(data29.words[346] - 7, data29.words[345] + 7,
            data29.words[344] - 8, data29.words[343] + 8);
  proc22_7(9);
  proc15_2(data29.bnd343, 8);
  proc15_2(data29.bnd339, 8);
  if data29.flags82[40] then proc22_19(data29.bnd303, 9)
  else proc22_19(data29.bnd303, 5);
  proc22_14(data29.words[330] - 7, data29.words[329] + 9,
            data29.words[328], data29.words[335] + 1);
  proc22_7(8);
  proc22_14(data29.words[330] - 7, data29.words[329] + 7,
            data29.words[328], data29.words[327]);
  proc22_7(8);
  proc22_12(data29.words[330] + 3, data29.words[327]);
  proc22_28(data29.clock42);
  proc24_7(data29.bnd323, data29.words[227], 8, 10);
  proc24_7(data29.bnd319, data29.words[226], 4, 6);
  proc24_7(data29.bnd315, data29.words[225], 4, 5);
  proc24_7(data29.bnd311, data29.words[223], 8, 9);
  proc22_19(data29.bnd307, 8);
  if not data29.flags82[1] then
  begin
    if data29.loc73.mid5 > 0 then value := 0
    else value := proc22_30(data29.bytes[143] + 7, 1);
    proc22_11(3);
    proc22_12(data29.words[310] + 2, data29.words[307]);
    proc22_39(value, 3, true)
  end;
  proc24_9
end;
