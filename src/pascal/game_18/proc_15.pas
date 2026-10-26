{ game_18 procedure 15, $0AC2..$0B1F, attributes $0B2A, lexical level 2.
  Arguments: frame slot 2=index, slot 1=enabled. Library dependencies are
  defined in library_22/proc_14.pas, proc_19.pas, and native_interfaces.pas. }
procedure proc18_15(index: integer; enabled: boolean);
var
  first_low: integer;
  second_low: integer;
  first_high: integer;
  second_high: integer;
begin
  { $0AC2..$0ACF: NEQ 6 is Boolean inequality. }
  if enabled <> g18f98[index - 1] then
  begin
    { $0AD1..$0AF1: keep the original arithmetic grouping. }
    first_low := ((data29.words[14] - 2) + 29) + (28 * (index - 1));
    second_low := (data29.words[12] - 2) + 30;
    first_high := first_low + 5;
    second_high := second_low + 1;
    { $0AF3..$0AF7 }
    proc22_14(first_low, first_high, second_low, second_high);
    { $0AFA..$0B0A: do not cache a captured/global value across the native call. }
    if enabled then
      proc22_7(g18w146)
    else
      proc22_7(g18w144);
    { $0B0D..$0B17 }
    g18f98[index - 1] := enabled
  end;
  { $0B18..$0B1C: reset the four-word bounds on BOTH paths; mode zero means
    procedure 19 does not call native procedure 7 a second time. }
  proc22_19(data29.bounds11, 0)
  { $0B1F: RNP 0. }
end;
