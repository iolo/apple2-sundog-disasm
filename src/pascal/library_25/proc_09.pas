{ library_25 procedure9, $00C6..$016F, attributes $0178.
  Nested in6; parent slots6/7 are offsets and8/9 are caption coordinates. }
procedure proc25_9(itemnum: integer);
begin
  with data30.items[itemnum] do
  begin
    proc22_11(3);
    proc22_14(firstbase + bounds.lower_first - 2,
              firstbase + bounds.upper_first + 2,
              secondbase + bounds.lower_second - 2,
              secondbase + bounds.upper_second + 2);
    proc22_7(10);
    proc22_14(firstbase + bounds.lower_first,
              firstbase + bounds.upper_first,
              secondbase + bounds.lower_second,
              secondbase + bounds.upper_second);
    proc22_7(8);
    firsttext := bounds.lower_first +
      (1 + bounds.upper_first - bounds.lower_first
       - 6 * length(data30.captions[tag.caption])) div 2;
    secondtext := bounds.upper_second -
      (1 + bounds.upper_second - bounds.lower_second - 8) div 2;
    proc22_12(firstbase + firsttext, secondbase + secondtext);
    proc22_10(data30.captions[tag.caption])
  end
end;
