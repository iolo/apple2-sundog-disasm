{ game_19 procedure9, $03C0..$04E9, attributes $04F6.
  Preserve the two-column paging, skipped-item behavior, and exit predicate:
  a zero selection can satisfy it; no positive-index guard is added. }
procedure proc19_9(var chosen: integer; area: bounds4;
                   start, count, excluded, kind: integer);
var
  original, last, pagefirst, pageend, cursor, top, middle, rowpos, selected: integer;
  rightcol: boolean;
  caption: text15;
begin
  proc22_19(area, 8);
  top := area.upper_second - area.lower_second - 4;
  middle := (g19.words[23] + g19.words[22]) div 2;
  pagefirst := start;
  original := count;
  last := start + count - 1;
  chosen := 0;
  repeat
    pageend := pagefirst + 5;
    if pageend > last then pageend := last;
    rowpos := top - 10;
    rightcol := false;
    proc25_2;
    cursor := pagefirst;
    while cursor <= pageend do
    begin
      if cursor <> excluded then
      begin
        proc19_8(kind, cursor, caption);
        if rightcol then
        begin
          proc25_3(cursor, caption, middle + 2, g19.words[22], rowpos, rowpos + 10);
          rowpos := rowpos - 15
        end
        else if (cursor = pageend) or ((excluded = pageend) and (cursor = pageend - 1)) then
        begin
          proc25_3(cursor, caption, g19.words[23], g19.words[22], rowpos, rowpos + 10);
          rowpos := rowpos - 15
        end
        else proc25_3(cursor, caption, g19.words[23], middle - 2, rowpos, rowpos + 10);
        rightcol := not rightcol
      end;
      cursor := cursor + 1
    end;
    if original > 6 then
      proc25_3(255, 'OTHERS', g19.words[23], g19.words[22], rowpos, rowpos + 10);
    chosen := 0;
    proc19_3(chosen, rowpos, data29.words[297], area, selected);
    if chosen = 255 then
    begin
      pagefirst := pagefirst + 6;
      if pagefirst > last then pagefirst := start
    end
    else if chosen = excluded then proc22_4(10, 50, 50, 0, 0, 0, 0)
  until ((chosen <= last) and (chosen <> excluded)) or odd(data29.words[347])
end;
