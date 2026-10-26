{ library_24 procedure9, $0E06..$0E50, attributes $0E5A.
  Shared update entry: save amount before the clock call, update it through
  both VAR callers, test the resulting flag40, then store and draw it. }
procedure proc24_9;
var
  amount: integer;
begin
  amount := data29.words[227];
  data29.words[352] := data29.words[352] mod 4;
  if data29.words[352] = 0 then proc22_29;
  data29.words[352] := data29.words[352] + 1;
  proc24_12(amount);
  proc24_15(amount);
  if data29.flags82[40] then proc24_13;
  data29.words[227] := amount;
  proc24_7(data29.bnd323, data29.words[227], 8, 10)
end;
