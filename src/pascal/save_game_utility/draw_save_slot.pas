{ utility_disk1:3 $1BEC..$1E07, attributes$1E1A. Slots1 full,2 slot;
  locals3 index,4 y/raw string address,5 x,6 selected,7 limit,8..13 label.
  Invalid slots self-exit before any effects. Raw string arguments92/41 at
  $1C73/$1C8E/$1DE8 are addresses, not literal punctuation. Reuse dead y
  storage to expose those addresses; do not replace them with character calls.
  The reference compiler adds a four-byte COPY temporary at14..15, yielding
  26 local bytes instead of22. No original access refers to those new slots;
  declared locals retain their positions. Exact frame/byte identity is not
  claimed for this compiler result. }
procedure draw_save_slot(slot_index: integer; show_summary: boolean);
var
  index: integer;
  y: utiltext;
  x: integer;
  save_record: utilptr;
  limit: integer;
  labeltxt: string[11];
begin
  if (slot_index < 0) or (slot_index > 3) then exit(draw_save_slot);
  if show_summary then
  begin
    x := 140 * (slot_index div 2);
    y.word := 39 + 76 * (slot_index mod 2);
    set_clip_bounds(4 + x, 137 + x, 4 + y.word, 72 + y.word);
    if u1.slots[slot_index].words[8] = 3 then draw_clip_pattern(7)
    else draw_clip_pattern(4);
    set_text_window(6 + x, 135 + x, 5 + y.word, 71 + y.word)
  end;
  apply_bounds(data29.bounds11, 4);
  save_record := @u1.slots[slot_index];
  write_wrapped_text('Game ');
  write_integer(slot_index + 1, 1, false);
  write_wrapped_text(': ');
  write_save_status(save_record^.words[8]);
  y.word := 92;
  write_wrapped_text(y.caption^);
  if save_record^.words[8] <> 0 then
  begin
    write_wrapped_text('Name: ');
    write_wrapped_text(save_record^.caption);
    y.word := 92;
    write_wrapped_text(y.caption^);
    if show_summary then
    begin
      write_wrapped_text('Status: ');
      if save_record^.words[9] = 0 then write_wrapped_text('find colony')
      else
      begin
        write_wrapped_text('Phase ');
        write_integer(save_record^.words[9], 1, false);
        text_newline
      end;
      write_wrapped_text('Date:   ');
      draw_clock(save_record^.saved_clock);
      text_newline;
      write_wrapped_text('Loc:    ');
      if save_record^.saved_location.fields.planet = 0 then write_wrapped_text('deep space')
      else
      begin
        if save_record^.saved_location.fields.city = 0 then write_wrapped_text('orbit')
        else write_wrapped_text(data29.names25.cities^[save_record^.saved_location.fields.city]);
        text_newline;
        write_wrapped_text('||||||||');
        write_wrapped_text(data29.names24.planets^[save_record^.saved_location.fields.planet])
      end;
      text_newline;
      write_wrapped_text('||||||||');
      write_wrapped_text(data29.names23.systems^[save_record^.saved_location.fields.system].caption)
    end
    else
    begin
      write_wrapped_text('Attr:   ');
      index := 0;
      limit := 4;
      while index <= limit do
      begin
        labeltxt := copy('STIQDXCHLK', 1 + index * 2, 2);
        write_wrapped_text(labeltxt);
        write_text_glyph(61);
        if index < 4 then write_integer(save_record^.stored_attributes[index], 3, false)
        else write_wrapped_text(' ??');
        write_wrapped_text(' (');
        write_integer(save_record^.stored_attributes[index + 5], 3, false);
        y.word := 41;
        write_wrapped_text(y.caption^);
        if index < 4 then write_wrapped_text('\||||||||');
        index := index + 1
      end
    end
  end
end;
