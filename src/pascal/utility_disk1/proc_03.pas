{ utility_disk1:3 $1BEC..$1E07, attributes$1E1A. Slots1 full,2 slot;
  locals3 index,4 y/raw string address,5 x,6 selected,7 limit,8..13 label.
  Invalid slots self-exit before any effects. Raw string arguments92/41 at
  $1C73/$1C8E/$1DE8 are addresses, not literal punctuation. Reuse dead y
  storage to expose those addresses; do not replace them with character calls.
  The reference compiler adds a four-byte COPY temporary at14..15, yielding
  26 local bytes instead of22. No original access refers to those new slots;
  declared locals retain their positions. Exact frame/byte identity is not
  claimed for this compiler result. }
procedure util1_3(slot: integer; full: boolean);
var
  index: integer;
  y: utiltext;
  x: integer;
  selected: utilptr;
  limit: integer;
  labeltxt: string[11];
begin
  if (slot < 0) or (slot > 3) then exit(util1_3);
  if full then
  begin
    x := 140 * (slot div 2);
    y.word := 39 + 76 * (slot mod 2);
    proc22_14(4 + x, 137 + x, 4 + y.word, 72 + y.word);
    if u1.slots[slot].words[8] = 3 then proc22_7(7)
    else proc22_7(4);
    proc22_50(6 + x, 135 + x, 5 + y.word, 71 + y.word)
  end;
  proc22_19(data29.bounds11, 4);
  selected := @u1.slots[slot];
  proc22_48('Game ');
  proc22_49(slot + 1, 1, false);
  proc22_48(': ');
  util1_44(selected^.words[8]);
  y.word := 92;
  proc22_48(y.caption^);
  if selected^.words[8] <> 0 then
  begin
    proc22_48('Name: ');
    proc22_48(selected^.caption);
    y.word := 92;
    proc22_48(y.caption^);
    if full then
    begin
      proc22_48('Status: ');
      if selected^.words[9] = 0 then proc22_48('find colony')
      else
      begin
        proc22_48('Phase ');
        proc22_49(selected^.words[9], 1, false);
        proc22_45
      end;
      proc22_48('Date:   ');
      proc22_28(selected^.stamp16);
      proc22_45;
      proc22_48('Loc:    ');
      if selected^.place18.fields.planet = 0 then proc22_48('deep space')
      else
      begin
        if selected^.place18.fields.city = 0 then proc22_48('orbit')
        else proc22_48(data29.names25.cities^[selected^.place18.fields.city]);
        proc22_45;
        proc22_48('||||||||');
        proc22_48(data29.names24.planets^[selected^.place18.fields.planet])
      end;
      proc22_45;
      proc22_48('||||||||');
      proc22_48(data29.names23.systems^[selected^.place18.fields.system].caption)
    end
    else
    begin
      proc22_48('Attr:   ');
      index := 0;
      limit := 4;
      while index <= limit do
      begin
        labeltxt := copy('STIQDXCHLK', 1 + index * 2, 2);
        proc22_48(labeltxt);
        proc22_47(61);
        if index < 4 then proc22_49(selected^.attrs10[index], 3, false)
        else proc22_48(' ??');
        proc22_48(' (');
        proc22_49(selected^.attrs10[index + 5], 3, false);
        y.word := 41;
        proc22_48(y.caption^);
        if index < 4 then proc22_48('\||||||||');
        index := index + 1
      end
    end
  end
end;
