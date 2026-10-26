{ library_27 procedure 10, $0276..$02BA, attributes $02C4.
  Word1 holds an existing address of 32 consecutive 16-byte strings. }
procedure proc27_10(code: integer);
var
  index: integer;
begin
  index := proc22_32(proc22_35(code), 31);
  proc27_9(data31.captions.table^[index]);
  if (index = 11) or (index = 13) then
  begin
    index := proc22_31(proc22_35(code), 5);
    if index > 0 then
    begin
      proc22_10(' (');
      proc22_39(index, 1, false);
      proc22_9(41)
    end
  end
end;
