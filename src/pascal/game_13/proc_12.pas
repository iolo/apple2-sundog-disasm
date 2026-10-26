{ game_13 procedure12, $12E6..$1437, attributes $1448; nested in1.
  Parameters5..1: kind, VAR destloc/result, mode2/mode1 low-bit flags.
  The six local words are shared by the rendering/selection descendants.
  Preserve both self EXIT paths, the repeat condition, and flag0's temporary
  setting around the system-map redraw. Unknown kinds retain the result. }
procedure proc13_12(kind: integer; var destloc: g19loc;
                    var result: integer; mode2, mode1: integer);
var mapstate: array[6..11] of integer;
(*$include src/pascal/game_13/proc_13.pas*)
(*$include src/pascal/game_13/proc_18.pas*)
begin
  result := 0;
  mapstate[11] := ord(data29.flags82[21]);
  if not data29.flags82[39] then proc13_13(kind, destloc)
  else data29.flags82[39] := false;
  if odd(mode2) and odd(mode1) then exit(proc13_12);
  repeat
    proc13_18(kind, destloc, result, -1 - mode1)
  until odd(mode2) or not (odd(mode1) and odd(result)) or
        odd(data29.words[347]);
  if not odd(mode2) then exit(proc13_12);
  proc22_17(false);
  proc22_13(0);
  proc22_19(data29.bnd339, 8);
  proc22_50(data29.words[342], data29.words[341],
              data29.words[340], data29.words[339]);
  if not odd(result) then proc22_48('No destination selected\')
  else
  begin
    case kind of
      1: begin
           result := ord((destloc.fields.system <> data29.loc73.low4) or
                         data29.flags82[18]);
           if odd(result) then
           begin
             data29.words[221] := destloc.fields.system;
             data29.flags82[0] := true;
             proc13_13(kind, data29.pos72);
             data29.flags82[0] := false
           end
         end;
      2: if destloc.fields.planet > 0 then
           result := ord(destloc.fields.planet <> data29.loc73.mid5)
         else result := ord((destloc.fields.w0high <> data29.pos72.fields.w0high) or
                            (destloc.fields.w0low <> data29.pos72.fields.w0low));
      3: result := ord(destloc.fields.city <> data29.pos72.fields.city)
    end;
    if not odd(result) then proc22_48('Current location selected\')
  end
end;
