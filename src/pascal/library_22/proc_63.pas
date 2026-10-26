{ library_22 procedure 63, $0A62..$0A8E, attributes $0A98.
  CSP 2 copies 2048 bytes in increasing address order, including overlap effects.
  DATASEG29 words 372/373 contain addresses, not embedded buffer storage. }
procedure proc22_63(save: boolean);
begin
  if save then
  begin
    moveleft(data29.addr373.bytes^, data29.addr372.bytes^, 2048);
    data29.flags82[116] := false
  end
  else
    moveleft(data29.addr372.bytes^, data29.addr373.bytes^, 2048)
end;
