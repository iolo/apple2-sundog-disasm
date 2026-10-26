{ game_16 procedure18, $085E..$091E, attributes $0930.
  Nested in17, with22 nested here. Keep the unused slot2 and text at3 for22.
  The forward declaration in17 allows recursive text expansion through21. }
procedure expand_dialog_token;
var
  spare2: integer;
  phrase: g16text;
(*$include src/pascal/dialogue/emit_phrase_record.pas*)
begin
  if code >= 65 then append_dialog_char(code)
  else if code = 63 then
  begin
    append_dialog_char(code);
    capitalize_next := 1
  end
  else if (code >= 48) or (code < 32) then
  begin
    extract_phrase_variant(code, -1, phrase);
    emit_dialog_phrase(phrase.text, true)
  end
  else
    case code of
      32, 39, 44: append_dialog_char(code);
      33, 46: begin
                append_dialog_char(code);
                capitalize_next := 1
              end;
      34: emit_dialog_phrase('O.K.', false);
      35: begin
            choose_foreign_place(phrase.short);
            emit_dialog_phrase(phrase.text, false)
          end;
      36: begin
            emit_dialog_phrase(g16.price_text, false);
            capitalize_next := 0
          end;
      37: emit_dialog_phrase(g16.item_caption, false);
      38, 40: emit_phrase_record(code, ord(data29.bytes[551] = 1), false);
      41, 42, 43: begin
                    extract_phrase_variant(code, 0, phrase);
                    emit_dialog_phrase(phrase.text, false)
                  end;
      45: emit_phrase_record(code, g16.response_level, true);
      47: emit_phrase_record(code, g16.selling_mode, false)
    end
end;
