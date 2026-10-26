{ game_19 procedure9, $03C0..$04E9, attributes $04F6.
  Preserve the two-column paging, skipped-item behavior, and exit predicate:
  a zero selection can satisfy it; no positive-index guard is added. }
procedure choose_service_destination(var chosen: integer; area: bounds4;
                   start, count, excluded, kind: integer);
var
  original, last, pagefirst, pageend, cursor, top, middle, rowpos, selected: integer;
  rightcol: boolean;
  caption: text15;
begin
  apply_bounds(area, 8);
  top := area.upper_second - area.lower_second - 4;
  middle := (g19.menu_left + g19.menu_right) div 2;
  pagefirst := start;
  original := count;
  last := start + count - 1;
  chosen := 0;
  repeat
    pageend := pagefirst + 5;
    if pageend > last then pageend := last;
    rowpos := top - 10;
    rightcol := false;
    reset_menu;
    cursor := pagefirst;
    while cursor <= pageend do
    begin
      if cursor <> excluded then
      begin
        lookup_place_caption(kind, cursor, caption);
        if rightcol then
        begin
          add_menu_button(cursor, caption, middle + 2, g19.menu_right, rowpos, rowpos + 10);
          rowpos := rowpos - 15
        end
        else if (cursor = pageend) or ((excluded = pageend) and (cursor = pageend - 1)) then
        begin
          add_menu_button(cursor, caption, g19.menu_left, g19.menu_right, rowpos, rowpos + 10);
          rowpos := rowpos - 15
        end
        else add_menu_button(cursor, caption, g19.menu_left, middle - 2, rowpos, rowpos + 10);
        rightcol := not rightcol
      end;
      cursor := cursor + 1
    end;
    if original > 6 then
      add_menu_button(255, 'OTHERS', g19.menu_left, g19.menu_right, rowpos, rowpos + 10);
    chosen := 0;
    poll_service_menu(chosen, rowpos, data29.words[297], area, selected);
    if chosen = 255 then
    begin
      pagefirst := pagefirst + 6;
      if pagefirst > last then pagefirst := start
    end
    else if chosen = excluded then play_sound(10, 50, 50, 0, 0, 0, 0)
  until ((chosen <= last) and (chosen <> excluded)) or odd(data29.words[347])
end;
