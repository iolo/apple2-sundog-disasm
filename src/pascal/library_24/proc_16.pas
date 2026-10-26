{ library_24 procedure16, $0ACE..$0B4C, attributes $0B58; nested in15.
  index is the original parent slot15, also used by the caller across calls. }
procedure proc24_16;
begin
  if amount <= 0 then
  begin
    index := 1;
    if data29.flags82[7] then
      while (amount <= 0) and (index < 3) do
      begin
        if data29.stock234[index].kind = 1 then
        begin
          amount := amount + 255;
          data29.stock234[index].kind := 0;
          data29.labels238[index] := '';
          index := 3
        end
        else index := index + 1
      end;
    if amount < 0 then amount := 0
  end
end;
