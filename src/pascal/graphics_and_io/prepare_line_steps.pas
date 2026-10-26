{ Library 22:58, $00BE..$00E8, attributes $00F2; nested in procedure 57.
  Seven word arguments; writes its parent's frame slots 5..12. }
procedure prepare_line_steps(startmaj, endmajor, stepmaj, startmin, stepmin,
                    majdelta, mindelta: integer);
begin
  majorpos := startmaj;                 { $00BE..$00BF: parent 12 }
  majorend := endmajor;                 { $00C2..$00C3: parent 10 }
  majorstep := stepmaj;                 { $00C6..$00C7: parent 11 }
  minorpos := startmin;                 { $00CA..$00CB: parent 9 }
  minorstep := stepmin;                 { $00CE..$00CF: parent 8 }
  axisinc := mindelta + mindelta;       { $00D2..$00D5: parent 6 }
  error := axisinc - majdelta;          { $00D8..$00DD: parent 7 }
  diaginc := error - majdelta           { $00E0..$00E5: parent 5 }
end;
