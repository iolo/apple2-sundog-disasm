{ system6:6 $0474..$05C9, attributes$05DA. Result1, VAR caption5,
  search word4, VAR directory pointer3; locals6 unit,7 numeric,8 valid,
  9 low time,10 digit index/high time,11 reused configuration/device view.
  #1..#20 selects a device; other names scan20 down through1. Search is a
  raw word: clearing its low bit must not canonicalize its other bits.
  A failed9 call is followed by IORESULT=0, which can still make valid true.
  The cached age check has only <=300 (unlike10, no lower-bound check).
  TIME keeps the original CSP9 zero-output behavior; see9's binding comment.
  The redundant branch at$0558 joins$055A and has no additional effect. }
(*$I-*)
function sys6_6(var caption: s4text7; search: integer;
                var directory: s4hptr): integer;
var
  unitnum: integer;
  numeric: boolean;
  valid: boolean;
  low: integer;
  scratch: integer;
  view: s6view;
begin
  sys6_6 := 0;
  directory := nil;
  valid := false;
  numeric := false;
  if length(caption) > 0 then
  begin
    if odd(ord(caption[1] = '#') and ord(length(caption) > 1)) then
    begin
      valid := true;
      unitnum := 0;
      scratch := 2;
      repeat
        if odd(ord(ord(caption[scratch]) >= 48) and
               ord(ord(caption[scratch]) <= 57)) then
          unitnum := unitnum * 10 + ord(caption[scratch]) - 48
        else valid := false;
        scratch := scratch + 1
      until odd(ord(scratch > length(caption)) or (not ord(valid)));
      numeric := odd(ord(valid) and ord(unitnum > 0) and ord(unitnum <= 20));
      search := search and (not ord(numeric))
    end;
    if not numeric then
    begin
      valid := false;
      unitnum := 20;
      repeat
        valid := caption = sy6e.units31[unitnum].caption;
        if not valid then unitnum := unitnum - 1
      until odd(ord(valid) or ord(unitnum = 0))
    end
  end;
  if valid then
    if odd(sy6e.units31[unitnum].flag4) then
    begin
      view.base := sy6e.state;
      valid := false;
      if view.config^.cache.directory <> nil then
        if caption = view.config^.cache.directory^[0].caption then
        begin
          time(scratch, low);
          valid := low - view.config^.cache.directory^[0].words[9] <= 300
        end;
      if not valid then
      begin
        valid := numeric;
        if sys6_9(unitnum) then
        begin
          if not numeric then
            valid := caption = view.config^.cache.directory^[0].caption
        end
        else valid := ioresult = 0
      end
    end;
  if odd((not ord(valid)) and search) then
  begin
    unitnum := 20;
    repeat
      view.device := @sy6e.units31[unitnum];
      if odd(view.device^.flag4) then
        if sys6_9(unitnum) then valid := caption = view.device^.caption;
      if not valid then unitnum := unitnum - 1
    until odd(ord(valid) or ord(unitnum = 0))
  end;
  if valid then
  begin
    view.device := @sy6e.units31[unitnum];
    sys6_6 := unitnum;
    if length(view.device^.caption) > 0 then caption := view.device^.caption;
    if odd(view.device^.flag4 and ord(sy6e.state^.directory <> nil)) then
    begin
      directory := sy6e.state^.directory;
      time(scratch, directory^.words[9])
    end
  end
end;
(*$I+*)
