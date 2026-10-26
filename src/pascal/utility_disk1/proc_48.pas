{ utility_disk1:48 $1FE4..$2022, attributes$202C. Four local bytes:
  unused word1, keepgoing2. Both confirmation and name-entry acceptance must
  succeed before initialization9 and attribute editing22. }
procedure util1_48;
var
  unused: integer;
  keepgoing: boolean;
begin
  if util1_4 then
  begin
    proc22_44;
    util1_31(keepgoing);
    if keepgoing then
    begin
      proc22_48('Initializing new game -- please wait');
      util1_9;
      util1_22
    end
  end
end;
