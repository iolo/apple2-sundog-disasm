{ game_13 procedure36, $1A4A..$1C31, attributes $1C3C; nested in27.
  Slot2 captures the height predicate so the native mask still runs when
  that predicate is false. The two errors self-EXIT36 before movement writes.
  Retain signed delta wrap at strictly greater128/less than-128. }
procedure proc13_36(var place: g19loc);
var
  atheight: boolean; {2, originally unused}
  y: integer;       {3}
  x: integer;       {4}
  destbody: integer;{5}
  oldbody: integer; {6}
  distance: integer;{7}
  unused8: integer;
  destname: text15; {9..16}
  oldname: text15;  {17..24}
(*$include src/pascal/game_13/proc_37.pas*)
begin
  oldbody := data29.pos72.fields.planet;
  destbody := place.fields.planet;
  proc13_37(oldname, oldbody, (data29.pos72.fields.w0high = 43) and
                             (data29.pos72.fields.w0low mod 16 = 0));
  proc13_37(destname, destbody, true);
  proc13_28('IN-SYSTEM', oldname, destname);
  proc24_9;
  if data29.words[227] = 0 then
  begin
    proc13_29(0);
    exit(proc13_36)
  end
  else if data29.bytes[178 + 52] = 0 then
  begin
    proc13_29(5);
    exit(proc13_36)
  end;
  proc24_4(data29.pos72.fields.w0low, data29.pos72.fields.w0high, x, y);
  proc22_19(data29.bnd343, 0);
  x := (x - 3) + proc22_31(data29.words[346] + data29.words[345], 1);
  y := (y + 3) + proc22_31(data29.words[344] + data29.words[343], 1);
  proc22_12(x, y);
  proc22_11(1);
  if oldbody > 0 then proc22_9(data29.words[297])
  else
  begin
    atheight := data29.pos72.fields.w0high = 43;
    if (proc22_32(data29.pos72.fields.w0low, 15) = 0) and atheight then
      proc22_9(43)
  end;
  proc22_19(data29.bounds11, 0);
  data29.clock80 := data29.clock42;
  data29.pos66 := place;
  data29.flags82[1] := true;
  data29.words[204] := 2;
  data29.words[218] := data29.pos66.fields.system;
  data29.flags82[5] := true;
  data29.words[213] := data29.pos66.fields.w0low - data29.pos72.fields.w0low;
  if data29.words[213] > 128 then data29.words[213] := data29.words[213] - 256
  else if data29.words[213] < -128 then data29.words[213] := data29.words[213] + 256;
  data29.words[212] := data29.pos66.fields.w0high - data29.pos72.fields.w0high;
  distance := proc22_35(data29.words[212]) div 3 +
              proc22_31(proc22_35(data29.words[213]) *
                        (data29.pos66.fields.w0high + data29.pos72.fields.w0high), 8);
  data29.words[211] := proc22_30(distance, 2) + 1;
  data29.words[219] := data29.pos72.fields.w0high;
  data29.words[220] := data29.pos72.fields.w0low;
  data29.words[210] := 0;
  data29.pos72.fields.planet := 0;
  proc22_26(data29.clock80, 1 + proc22_31(data29.words[211], 1));
  proc22_48('ETA:   ');
  proc22_28(data29.clock80);
  proc22_45;
  proc24_9
end;
