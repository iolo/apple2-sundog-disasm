{ game_16 procedure29, $0D3E..$0D56, attributes $0D60.
  Read a replacement only for a positive condition; use the condition's low
  result bit, preserving the raw words returned by8's cases4/6. }
procedure proc16_29(var target: integer);
var
  replacement: integer;
  condition: integer;
begin
  proc16_15(condition);
  if condition > 0 then
  begin
    proc16_15(replacement);
    if not odd(proc16_8(condition)) then target := replacement
  end
end;
