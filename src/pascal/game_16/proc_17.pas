{ game_16 procedure17, $0932..$0985, attributes $0992.
  Retain the104-byte frame: nested18..21 share next5, printed10, capital12,
  and line13. High-bit stream bytes expand once, then emit a space. }
procedure proc16_17(index: integer);
var
  unused2: integer;
  glyph: integer;
  remaining: integer;
  next: integer;
  saved: bounds4;
  printed: integer;
  unused11: integer;
  capital: integer;
  line: g16line;
procedure proc16_18(code: integer); forward;
(*$include src/pascal/game_16/proc_19.pas*)
(*$include src/pascal/game_16/proc_20.pas*)
(*$include src/pascal/game_16/proc_21.pas*)
(*$include src/pascal/game_16/proc_18.pas*)
begin
  saved := data29.bounds11;
  data29.bounds11 := g16.dialog60;
  printed := 0;
  g16.words[38] := index * 2;
  proc16_15(remaining);
  next := 1;
  capital := 1;
  unused11 := 0;
  while remaining > 0 do
  begin
    proc16_15(glyph);
    if glyph > 127 then
    begin
      glyph := glyph - 128;
      proc16_18(glyph);
      glyph := 32
    end;
    proc16_18(glyph);
    remaining := remaining - 1
  end;
  proc16_19;
  data29.bounds11 := saved
end;
