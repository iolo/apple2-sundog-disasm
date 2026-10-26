{ Include after storage, core string types, and system_types. Core12 passes
  its unbounded editing index into a raw byte view of temp7. Preserve the
  surrounding frame because an oversized index can read the following pointer
  word; do not replace this with a separately allocated/extended string. }
s0numin = record
  code3: integer;
  digits4: boolean;
  minus5: boolean;
  index6: integer;
  temp7: s0str80;
  file48: sysfptr
end;
