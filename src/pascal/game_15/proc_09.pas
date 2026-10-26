{ game_15 procedure9, $037E..$0488, attributes $0498.
  Table at DATASEG29 word24 has16-byte rows. Capture each row before writing
  its byte12; byte11 is an UNSIGNED packed8-bit multiplier. Preserve signed
  word overflow followed by repeated +256, then low-byte truncation.
  Reread the table pointer for every row and every later selected lookup. }
procedure proc15_9;
var
  value: integer;
  index: integer;
  delta: integer;
  unused4: array[4..6] of integer;
  last: integer;
  row: address16;
begin
  if data29.words[44] <> data29.clock42.day then
  begin
    delta := proc22_35(data29.clock42.day - data29.words[44]);
    data29.words[44] := data29.clock42.day;
    index := 1;
    last := 18;
    while index <= last do
    begin
      row.word := data29.words[24] + (index - 1) * 16;
      value := row.bytes^[12] + row.bytes^[11] * delta;
      while value < 0 do value := value + 256;
      row.bytes^[12] := value;
      index := index + 1
    end;
    if data29.loc37.mid5 <> 0 then
    begin
      row.word := data29.words[24];
      data29.pos36.fields.w0low := row.bytes^[(data29.loc37.mid5 - 1) * 16 + 12]
    end;
    data29.pos72.fields.w0low := data29.pos36.fields.w0low;
    if data29.loc67.mid5 <> 0 then
    begin
      row.word := data29.words[24];
      data29.bytes[130] := row.bytes^[(data29.loc67.mid5 - 1) * 16 + 12]
    end;
    if data29.flags82[7] then
      data29.pos228.fields.w0low := data29.pos72.fields.w0low
    else
    begin
      { No nonzero guard on this selector in the original. }
      row.word := data29.words[24];
      data29.pos228.fields.w0low :=
        row.bytes^[(data29.pos228.fields.planet - 1) * 16 + 12]
    end
  end;
  { The date-equal path also performs this flag restoration. }
  if odd(g15.words[11]) then
  begin
    data29.flags82[30] := false;
    data29.flags82[g15.words[13]] := odd(g15.words[10]);
    g15.words[11] := 0
  end
end;
