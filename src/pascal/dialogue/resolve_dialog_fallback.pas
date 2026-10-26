{ game_16 procedure29, $0D3E..$0D56, attributes $0D60.
  Read a replacement only for a positive condition; use the condition's low
  result bit, preserving the raw words returned by8's cases4/6. }
procedure resolve_dialog_fallback(var target: integer);
var
  replacement: integer;
  condition: integer;
begin
  read_dialog_byte(condition);
  if condition > 0 then
  begin
    read_dialog_byte(replacement);
    if not odd(test_dialog_condition(condition)) then target := replacement
  end
end;
