{ game_16 procedure21, $07EC..$0835, attributes $0842.
  Copy the value string with SAS31 before reading its length. Expansion walks
  that copy with a saved limit. Literal mode processes the first byte even for
  an empty string, then performs the original MOVELEFT(length-1). }
procedure proc16_21(caption: g16str; expand: boolean);
var
  cursor: integer;
  last: integer;
begin
  last := length(caption);
  if expand then
  begin
    cursor := 1;
    while cursor <= last do
    begin
      proc16_18(ord(caption[cursor]));
      cursor := cursor + 1
    end
  end
  else
  begin
    proc16_20(ord(caption[1]));
    moveleft(caption[2], line.bytes[next], last - 1);
    next := next + last - 1
  end
end;
