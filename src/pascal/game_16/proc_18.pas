{ game_16 procedure18, $085E..$091E, attributes $0930.
  Nested in17, with22 nested here. Keep the unused slot2 and text at3 for22.
  The forward declaration in17 allows recursive text expansion through21. }
procedure proc16_18;
var
  spare2: integer;
  phrase: g16text;
(*$include src/pascal/game_16/proc_22.pas*)
begin
  if code >= 65 then proc16_20(code)
  else if code = 63 then
  begin
    proc16_20(code);
    capital := 1
  end
  else if (code >= 48) or (code < 32) then
  begin
    proc16_13(code, -1, phrase);
    proc16_21(phrase.text, true)
  end
  else
    case code of
      32, 39, 44: proc16_20(code);
      33, 46: begin
                proc16_20(code);
                capital := 1
              end;
      34: proc16_21('O.K.', false);
      35: begin
            proc16_16(phrase.short);
            proc16_21(phrase.text, false)
          end;
      36: begin
            proc16_21(g16.text108, false);
            capital := 0
          end;
      37: proc16_21(g16.caption124, false);
      38, 40: proc16_22(code, ord(data29.bytes[551] = 1), false);
      41, 42, 43: begin
                    proc16_13(code, 0, phrase);
                    proc16_21(phrase.text, false)
                  end;
      45: proc16_22(code, g16.words[33], true);
      47: proc16_22(code, g16.words[18], false)
    end
end;
