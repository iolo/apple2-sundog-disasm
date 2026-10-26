{ game_13 procedure47, $232C..$2442, attributes $244E; nested in1.
  Retain all28 local bytes. Child48 uses otherwise unused slots2..4 for a
  mandatory table read. Input7 controls repetition independently of result6.
  The action9 redraw can clear result6 via procedure12's early return; preserve
  that effect before deciding whether to call travel27. }
procedure proc13_47;
var
  navzero: integer; {1}
  navflag: boolean; {2}
  navrow: g13rowptr; {3}
  navcount: integer; {4}
  navhit: integer;  {5}
  navok: integer;   {6}
  navinput: integer; {7}
  navact: integer;  {8}
  navloc: g19loc;   {9..14}
(*$include src/pascal/game_13/proc_48.pas*)
(*$include src/pascal/game_13/proc_49.pas*)
begin
  navzero := 0;
  proc13_43('NAVIGATE');
  if data29.flags82[1] then
  begin
    navloc := data29.pos66;
    proc13_12(2, navloc, navok, 1, 1)
  end;
  data29.words[349] := 1;
  repeat
    proc13_48;
    navact := 0;
    proc22_19(data29.bnd335, 8);
    proc13_45(navact, navhit, data29.words[297], data29.bnd335, navinput);
    if odd(data29.words[347]) then navact := 0;
    navok := navinput;
    navloc := data29.pos36;
    case navact of
      1: proc13_46;
      2, 3, 4:
        begin
          data29.flags82[32] := navact = 2;
          data29.flags82[39] := (navact = 2) or
                               ((navact = 4) and (not data29.flags82[21]));
          proc13_49(3);
          navact := 4
        end;
      6: proc13_49(2);
      8: proc13_49(1);
      9: if data29.words[203] = 1 then
         begin
           data29.flags82[0] := false;
           proc13_12(1, navloc, navok, 1, 1)
         end
    end;
    if navact < 4 then navok := 0;
    if odd(navok) and (not odd(data29.words[347])) and (navact <> 255) then
      proc13_27(navact, navloc)
  until (not odd(navinput)) or odd(data29.words[347]);
  if not data29.flags82[5] then
    proc13_12(data29.words[203], data29.pos72, navinput, 1, 1);
  proc13_44;
  data29.words[349] := 0
end;
