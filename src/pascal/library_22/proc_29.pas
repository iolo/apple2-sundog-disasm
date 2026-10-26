{ library_22 procedure29, $0450..$0572, attributes $0582.
  Nested60 accesses adjustment/sum/index at the original parent slots2/3/6. }
procedure proc22_29;
var
  unused1: integer;
  adjust: integer;       { 2 }
  total: integer;        { 3 }
  value: integer;        { 4 }
  unused5: integer;
  index: integer;        { 6 }
  oldhour: integer;      { 7 }
  last: integer;         { 8 }
(*$include src/pascal/library_22/proc_60.pas*)
begin
  data29.words[354] := 0;
  oldhour := data29.clock42.hour;
  proc22_26(data29.clock42, data29.words[351]);
  if data29.words[329] > 0 then
  begin
    proc22_19(data29.bounds327, 0);
    proc22_12(data29.words[330] + 3, data29.words[327]);
    proc22_28(data29.clock42)
  end;
  while oldhour <> data29.clock42.hour do
  begin
    value := data29.bytes[118];
    total := 0;
    unused1 := 0;
    adjust := 0;
    index := (value - 128) div 32;
    if index < 0 then index := 0;
    proc22_60(1, '4234');
    proc22_60(2, '1000');
    proc22_60(3, '1123');
    if adjust < 0 then value := value + adjust
    else value := value + 2 * proc22_34(total div 3 - value);
    if value <= 0 then
    begin
      data29.bytes[118] := 0;
      data29.nibbles45[2] := 12;
      data29.words[347] := 1
    end
    else
    begin
      if value > 255 then value := 255;
      data29.bytes[118] := value
    end;
    index := 0;
    last := 4;
    while index <= last do
    begin
      value := data29.bytes[94 + index];
      adjust := data29.bytes[94 + (index + 5)] - value;
      total := proc22_34(adjust) * data29.bytes[94 + (index + 10)];
      if proc22_35(adjust) < proc22_35(total) then total := adjust;
      data29.bytes[94 + index] := value + total;
      index := index + 1
    end;
    oldhour := (oldhour + 1) mod 24;
    data29.flags82[60] := true
  end
end;
