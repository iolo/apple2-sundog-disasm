{ game_21 procedure38, $1A24..$1B8D, attributes $1B9A.
  Keep22-byte local layout for nested39's bounds and the original deposit
  flag at slot2. That flag is written only when input0 is true; the original
  has no initialization or reset on a false input0. Do not invent one.
  Cancelled destination selection restores both original money words. }
procedure proc21_38;
var
  cancel: integer;       {1}
  deposit: integer;      {2: deliberately not initialized, as in the listing}
  selected: integer;     {3}
  cost: integer;         {4}
  button: bounds4;       {5..8}
  cash: wordpair;        {9..10}
  rowaddr: integer;      {11: calculated but unused}
(*$include src/pascal/game_21/proc_39.pas*)
begin
  g21.words[34] := 0;
  proc21_5;
  proc22_41(g21.words[19], g21.words[18]);
  proc22_51(proc22_33(arg4, 1), arg3);
  rowaddr := data29.words[23] + 20 * (data29.loc37.low4 - 1);
  cost := 10 + 4 * g21.words[60] - 2 * g21.words[59];
  if cost < 10 then cost := 10;
  cash := data29.money46;
  proc22_44;
  proc21_39('Public TelePort', true);
  proc22_45;
  proc22_45;
  proc22_48('|||||Cost:  ');
  proc22_49(cost, 3, false);
  proc22_48(' Cr\|\');
  proc22_48('|||Deposit money and\||select destination.\|\');
  proc21_39('Deposit money', false);
  selected := 0;
  proc22_42(g21.words[19], g21.words[18], data29.words[297], data29.bounds11);
  repeat
    proc22_43(g21.words[19], g21.words[18]);
    if odd(proc22_2(0)) then
      deposit := ord((button.lower_first <= g21.words[19]) and
                     (g21.words[19] <= button.upper_first) and
                     (button.lower_second <= g21.words[18]) and
                     (g21.words[18] <= button.upper_second));
    cancel := proc22_2(1)
  until odd(deposit) or odd(cancel);
  proc22_41(g21.words[19], g21.words[18]);
  if odd(deposit) then
  begin
    proc22_4(30, 50, 10, 0, 0, 0, 0);
    proc22_19(button, 3);
    if proc21_37(cost) then proc21_33(selected)
  end;
  proc22_52;
  if odd(selected) then proc21_36
  else data29.money46 := cash;
  proc22_42(g21.words[19], g21.words[18], data29.words[298], g21.area62);
  proc21_5
end;
