{ library_22 procedure 42, $079A..$07F9, attributes $0804.
  The value bounds parameter is copied before any external-data writes. }
procedure proc22_42(var firstpos, secondpos: integer; code: integer;
                    bounds: bounds4);
(*$include src/pascal/library_22/proc_62.pas*)
begin
  data29.words[374] := code;
  proc22_18(data29.bounds375, bounds.lower_first + 3, bounds.upper_first - 5,
            bounds.lower_second + 5, bounds.upper_second - 3);
  proc22_62(data29.words[378], data29.words[377] - data29.words[378],
            140, data29.words[380], data29.words[369]);
  proc22_62(data29.words[376], data29.words[375] - data29.words[376],
            96, data29.words[379], data29.words[368]);
  proc22_19(data29.bounds375, 0);
  proc22_61(firstpos, secondpos);
  proc22_41(firstpos, secondpos)
end;
