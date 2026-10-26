{ game_13 procedure13, $0C2A..$0C92, attributes $0C9C; nested in12.
  Parameters: viewkind2, VAR chosenloc1. Preserve44 local bytes, including
  redraw23 and selector24. Children15/16 also use procedure12's mapstate,
  an array[6..11] of integer occupying its six local words.
  LNOT complements the entire word: redraw23 is -1 or -2, not1 or0. }
procedure proc13_13(viewkind: integer; var chosenloc: g19loc);
var
  unused: array[3..22] of integer;
  redraw: integer;   {23}
  selector: integer; {24}
(*$include src/pascal/game_13/proc_14.pas*)
(*$include src/pascal/game_13/proc_15.pas*)
(*$include src/pascal/game_13/proc_16.pas*)
begin
  proc24_9;
  if viewkind = 3 then selector := chosenloc.fields.planet
  else selector := chosenloc.fields.system;
  redraw := -2 + ord((not data29.flags82[5]) or
                    (data29.words[203] <> viewkind) or
                    (data29.words[218] <> selector));
  data29.flags82[5] := true;
  data29.words[203] := viewkind;
  data29.words[218] := selector;
  case viewkind of
    1: proc13_14(chosenloc);
    2: proc13_15(chosenloc);
    3: proc13_16(chosenloc)
  end
end;
