{ system6:9 $0258..$0395, attributes$03A6. Result1, unit3; locals4 index,
  5 valid,6 clock high,7 configuration,8 unit entry,9 header,10 file entry.
  Allocate exactly256 words if needed; read512 bytes at block79. Preserve
  count<=77 without enlarging that allocation. Sanitize entries only when
  the volume name differs; delete bad entries without advancing the index.
  Read the IO word directly (do not consume it via IORESULT). Failure clears
  the unit caption, sets word5=$7FFF, RELEASEs the cache and then stores nil.
  TIME is CSP9, vector$D112 -> native_shared.s $E819..$E832: it writes zero
  to both output words in this SunDog interpreter. Do not bind to a host clock. }
(*$I-*)
function rt_read_volume_directory(unitnum: integer): boolean;
var
  index: integer;
  valid: boolean;
  high: integer;
  state: s6view;
  device: ^s4unit;
  header: s6eptr;
  entry: s6eptr;
begin
  rt_read_volume_directory := false;
  state.base := sy6e.state;
  device := @sy6e.units31[unitnum];
  if state.config^.cache.block = nil then new(state.config^.cache.block);
  unitread(unitnum, state.config^.cache.block^, 512, 79, 0);
  valid := state.config^.words[0] = 0;
  if valid then
  begin
    header := @state.config^.cache.directory^[0];
    valid := false;
    if odd(ord(header^.words[0] = 0) and
           (ord(state.config^.flags29.format = 2) or
            ((ord(state.config^.flags29.format = 1) or
              ord(state.config^.flags29.format = 3)) and
             ord(header^.kind2.kind = 8)) or
            (ord(state.config^.flags29.format = 0) and
             ord(header^.kind2.kind = 0)))) then
      if odd(ord(length(header^.caption) > 0) and
             ord(length(header^.caption) <= 7) and
             ord(header^.words[8] >= 0) and ord(header^.words[8] <= 77)) then
      begin
        valid := true;
        if header^.caption <> device^.caption then
        begin
          index := 1;
          while index <= header^.words[8] do
          begin
            entry := @state.config^.cache.directory^[index];
            if odd(ord(length(entry^.caption) <= 0) or
                   ord(length(entry^.caption) > 15) or
                   ord(entry^.words[1] < entry^.words[0]) or
                   ord(entry^.words[11] > 512) or
                   ord(entry^.words[11] <= 0) or
                   ord(entry^.date12.high7 >= 100)) then
            begin
              valid := false;
              rt_remove_dir_entry(index, state.config^.cache.directory)
            end
            else index := index + 1
          end;
          if not valid then
          begin
            unitwrite(unitnum, state.config^.cache.directory^,
                      (header^.words[8] + 1) * 26, 79, 0);
            valid := state.config^.words[0] = 0
          end
        end
      end;
    if valid then
    begin
      device^.caption := header^.caption;
      device^.word5 := header^.words[7];
      time(high, header^.words[9])
    end
  end;
  rt_read_volume_directory := valid;
  if not valid then
  begin
    device^.caption := '';
    device^.word5 := 32767;
    release(state.config^.cache.block);
    state.config^.cache.block := nil
  end
end;
(*$I+*)
