{ Library 22:57, $00F4..$015F, attributes $016A. Arguments in slots 4..1.
  Prepares axis/error terms and delegates plotting to native procedure 56.
  Explicit signed subtraction/negation retains the original word operations. }
procedure proc22_57(first0, second0, first1, second1: integer);
var
  diaginc: integer;                     { Slot 5 }
  axisinc: integer;
  error: integer;
  minorstep: integer;
  minorpos: integer;
  majorend: integer;
  majorstep: integer;
  majorpos: integer;                    { Slot 12 }
  delta2: integer;
  delta1: integer;
  unused15: integer;                   { Original unused slot; keeps nested map. }
  step2: integer;
  step1: integer;
  steep: boolean;
  back2: boolean;
  back1: boolean;
(*$include src/pascal/library_22/proc_58.pas*)
begin
  delta1 := first1 - first0;            { $00F4..$0100 }
  if delta1 < 0 then delta1 := -delta1;
  delta2 := second1 - second0;          { $0102..$010E }
  if delta2 < 0 then delta2 := -delta2;
  steep := delta2 > delta1;             { $0110..$0113 }
  back2 := second0 > second1;           { $0115..$0118 }
  back1 := first0 > first1;             { $011A..$011D }
  if back1 then step1 := -1 else step1 := 1; { $011F..$012A }
  if back2 then step2 := -1 else step2 := 1; { $012C..$0137 }
  if steep then                        { $0139..$0151 }
    proc22_58(second0, second1, step2, first0, step1, delta2, delta1)
  else
    proc22_58(first0, first1, step1, second0, step2, delta1, delta2);
  proc22_56(majorpos, majorstep, majorend, minorpos, minorstep,
             error, axisinc, diaginc, steep)     { $0153..$015D }
end;
