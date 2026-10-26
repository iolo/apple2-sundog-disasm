{ game_16 procedure13, $0602..$06F2, attributes $0704.
  Keep the original12-byte local frame for nested14's glyph store at4.
  Bytes are written directly; no31-character clamp is added. The skip scan
  deliberately has no remaining-length guard. Length is written only at the
  end, so leading96 reads the destination's previous length byte at index0. }
procedure extract_phrase_variant(record_index, variant_index: integer; var decoded_text: g16text);
var
  variant_marker: integer;       {4, shared with14}
  output_length: integer;
  unused6: integer;
  bytes_left: integer;
  read_offset: integer;
  token_code: integer;       {9}
(*$include src/pascal/dialogue/pick_phrase_variant.pas*)
begin
  if record_index >= 64 then decoded_text.text := ''
  else
  begin
    read_offset := phrase_offset(record_index);
    bytes_left := phrase_offset(record_index + 1) - read_offset;
    output_length := 0;
    if variant_index < 0 then pick_phrase_variant(variant_index, read_offset, bytes_left);
    while variant_index > 0 do
    begin
      variant_marker := g16.phrase_bytes.bytes^[read_offset];
      if (variant_marker > 64) and (variant_marker < 97) then variant_index := variant_index - 1;
      read_offset := read_offset + 1;
      bytes_left := bytes_left - 1
    end;
    while bytes_left > 0 do
    begin
      token_code := g16.phrase_bytes.bytes^[read_offset];
      if token_code > 127 then
      begin
        token_code := token_code - 128;
        output_length := output_length + 1;
        if (token_code = 124) or (token_code = 92) then token_code := 73
        else if (65 <= token_code) and (token_code <= 90) then
        begin
          token_code := token_code + 32;
          bytes_left := 0
        end;
        decoded_text.bytes[output_length] := token_code;
        token_code := 32
      end
      else if (token_code = 124) or (token_code = 92) then token_code := 73
      else if token_code = 126 then token_code := 39
      else if (token_code >= 65) and (token_code <= 90) then
      begin
        token_code := token_code + 32;
        bytes_left := 0
      end
      else if token_code = 96 then
      begin
        token_code := decoded_text.bytes[output_length];
        output_length := output_length - 1;
        bytes_left := 0
      end;
      output_length := output_length + 1;
      decoded_text.bytes[output_length] := token_code;
      read_offset := read_offset + 1;
      bytes_left := bytes_left - 1
    end;
    decoded_text.bytes[0] := output_length
  end
end;
