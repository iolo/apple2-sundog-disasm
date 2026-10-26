{ game_20 procedure27, $1584..$1660, attributes $1670.
  Poll input1 even after failed capacity check; random offer refresh also runs
  its random call in contract mode. Buying charges before storage selection. }
(*$warning goto false*)
procedure proc20_27(slot: integer);
label 1, 2;
var
  freeidx, choice, column, row, message, selected: integer;
  amount: wordpair;
  item: stock4;
  caption: g20text;
  room: boolean;
  input1: integer;
  randomv: integer;
begin
1:
    room := proc20_26(freeidx);
    input1 := proc22_2(1);
    if not (room and not (odd(input1) or odd(data29.words[347]))) then goto 2;
    proc25_2;
    proc20_9(g20.words[12] - 10, 1, 2, 'Buy', 'Pass', '');
    proc22_44;
    column := data29.words[19];
    row := data29.words[18];
    choice := 0;
    message := 1;
    repeat
      data29.words[19] := column;
      data29.words[18] := row;
      randomv := proc22_3;
      if (randomv mod 8 = 0) and not odd(g20.words[16]) then proc20_21(-1);
      proc20_23(slot, item, caption, amount, false, message);
      if amount <> g20.zero160 then
        proc20_8(choice, freeidx, data29.words[297], data29.bounds11, selected)
      else choice := 0;
      if choice = 2 then slot := (slot + 1) mod 8
    until (choice <> 2) or odd(data29.words[347]);
    if choice = 0 then exit(proc20_27);
    proc20_21(slot);
    if amount <> g20.zero160 then
    begin
      if not odd(g20.words[16]) then proc28_3(amount, g20.cash164);
      proc20_24(item, slot, amount, false);
      proc20_20(item.kind, false)
    end;
  goto 1;
2:
end;
(*$warning goto true*)
