{ library_22 procedure 18, $01EA..$01FF, attributes $020A.
  VAR bounds address is frame slot 5; the four scalar words are slots 4..1.
  All arguments are captured before the stores, preserving possible aliases. }
procedure assign_bounds(var bounds: bounds4; firstlow, firsthigh,
                    secondlow, secondhigh: integer);
begin
  bounds.lower_first := firstlow;
  bounds.upper_first := firsthigh;
  bounds.lower_second := secondlow;
  bounds.upper_second := secondhigh
end;
