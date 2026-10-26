{ game_19 procedure18, $0E44..$1001, attributes $1014.
  Four value strings retain copies at7..38; nested19 uses slots39..46.
  Uppercasing is the original byte subtraction, not a locale conversion. }
procedure proc19_18(alltext, itemname, verb, unitname: text15;
                    var price, quantity: integer);
var
  cost: wordpair;       {39..40}
  needed: integer;      {41}
  row: integer;         {42}
  column: integer;      {43}
  found: integer;       {44}
  choice: integer;      {45}
  blocked: boolean;     {46}
  selected: integer;    {47}
  upperunit: text15;    {48..55}
  limit: integer;       {56}
  stopnow: boolean;
  key: integer;
(*$include src/pascal/game_19/proc_19.pas*)
begin
  proc22_44;
  if price < 0 then
  begin
    proc22_48('Your ');
    proc22_48(itemname);
    proc22_48(' isn''t here for us to ');
    proc22_48(verb);
    exit(proc19_18)
  end;
  if quantity = 16 then
  begin
    proc22_48('Your ');
    proc22_48(itemname);
    proc22_48(' doesn''t need ');
    proc22_48(verb);
    proc22_48('ing');
    exit(proc19_18)
  end;
  upperunit := unitname;
  needed := 1;
  limit := length(upperunit);
  while needed <= limit do
  begin
    upperunit[needed] := chr(ord(upperunit[needed]) - 32);
    needed := needed + 1
  end;
  needed := 16 - quantity;
  proc28_4(cost, 0, price);
  proc22_48('Cost ');
  proc22_49(price, 8, false);
  proc22_48(' cr/');
  proc22_48(unitname);
  proc22_45;
  if unitname = 'load' then proc22_48('You can use ')
  else proc22_48('You need    ');
  column := data29.words[19];
  row := data29.words[18];
  proc19_19;
  repeat
    proc25_2;
    if needed = 1 then
      proc19_4(g19.words[20] - 27, 2, 2, upperunit, 'STOP', '')
    else proc19_4(g19.words[20] - 27, 1, 3, alltext, upperunit, 'STOP');
    proc19_3(choice, found, data29.words[297], data29.bounds11, selected);
    if odd(selected) and (choice < 3) and not blocked then
      repeat
        quantity := quantity + 1;
        proc28_3(cost, g19.amount10);
        if needed > 255 then needed := 255;
        needed := needed - 1;
        proc19_19;
        stopnow := (choice = 2) or blocked;
        key := proc22_2(1)
      until stopnow or odd(key);
    key := proc22_2(1)
  until odd(key) or blocked or (choice = 3) or not odd(selected)
end;
