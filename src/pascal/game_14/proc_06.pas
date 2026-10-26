{ game_14 procedure6, $040E..$04D4, attributes $04E2.
  WITH captures each stock row before any drawing calls, as original slot9.
  Caption-table index is kind itself, not kind-1; city names use origin-1. }
procedure proc14_6;
var
  saved: bounds4;
  line: integer;
  index: integer;
  names: captionaddr;
  last: integer;
begin
  saved := data29.bounds11;
  data29.bounds11 := g14.title82;
  proc22_44;
  proc22_48('|||||CARGO');
  proc22_23(5120, names.word);
  index := 1;
  last := 2;
  while index <= last do
  begin
    with data29.stock234[index] do
      if kind > 0 then
      begin
        line := 4 * index - 1;
        proc22_46(0, line);
        if data29.labels238[index] = 'Unknown' then
          data29.labels238[index] := names.table^[kind];
        proc22_48(data29.labels238[index]);
        if (kind > 1) and (origin > 0) then
        begin
          proc22_46(0, line + 2);
          proc22_48('from ');
          proc22_48(data29.names25.cities^[origin])
        end
      end;
    index := index + 1
  end;
  proc22_50(saved.lower_first, saved.upper_first, saved.lower_second, saved.upper_second)
end;
