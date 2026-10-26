{ game_16 procedure13, $0602..$06F2, attributes $0704.
  Keep the original12-byte local frame for nested14's glyph store at4.
  Bytes are written directly; no31-character clamp is added. The skip scan
  deliberately has no remaining-length guard. Length is written only at the
  end, so leading96 reads the destination's previous length byte at index0. }
procedure proc16_13(index, skip: integer; var dest: g16text);
var
  glyph: integer;       {4, shared with14}
  used: integer;
  unused6: integer;
  left: integer;
  cursor: integer;
  token: integer;       {9}
(*$include src/pascal/game_16/proc_14.pas*)
begin
  if index >= 64 then dest.text := ''
  else
  begin
    cursor := proc16_12(index);
    left := proc16_12(index + 1) - cursor;
    used := 0;
    if skip < 0 then proc16_14(skip, cursor, left);
    while skip > 0 do
    begin
      glyph := g16.table141.bytes^[cursor];
      if (glyph > 64) and (glyph < 97) then skip := skip - 1;
      cursor := cursor + 1;
      left := left - 1
    end;
    while left > 0 do
    begin
      token := g16.table141.bytes^[cursor];
      if token > 127 then
      begin
        token := token - 128;
        used := used + 1;
        if (token = 124) or (token = 92) then token := 73
        else if (65 <= token) and (token <= 90) then
        begin
          token := token + 32;
          left := 0
        end;
        dest.bytes[used] := token;
        token := 32
      end
      else if (token = 124) or (token = 92) then token := 73
      else if token = 126 then token := 39
      else if (token >= 65) and (token <= 90) then
      begin
        token := token + 32;
        left := 0
      end
      else if token = 96 then
      begin
        token := dest.bytes[used];
        used := used - 1;
        left := 0
      end;
      used := used + 1;
      dest.bytes[used] := token;
      cursor := cursor + 1;
      left := left - 1
    end;
    dest.bytes[0] := used
  end
end;
