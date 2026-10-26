{ game_16 procedure38, $1222..$1244, attributes $1250; nested in37. }
procedure proc16_38(first, last, value, maximum: integer);
var
  flagidx: integer;
  lastflag: integer;
begin
  flagidx := first;
  lastflag := last;
  while flagidx <= lastflag do
  begin
    data29.flags82[flagidx] := value <= maximum;
    value := value + 1;
    flagidx := flagidx + 1
  end
end;
