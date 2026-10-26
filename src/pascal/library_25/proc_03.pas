{ library_25 procedure3, $0014..$007A, attributes $0084.
  Saturating counts reuse the last caption/item; do not reject a full table. }
procedure proc25_3(code: integer; caption: text15;
                  lowerfirst, upperfirst, lowersecond, uppersecond: integer);
begin
  if data30.nlabels < 8 then data30.nlabels := data30.nlabels + 1;
  if data30.nitems < 21 then data30.nitems := data30.nitems + 1;
  data30.captions[data30.nlabels] := caption;
  with data30.items[data30.nitems] do
  begin
    tag.code := code;
    tag.button := true;
    tag.caption := data30.nlabels;
    bounds.lower_first := lowerfirst;
    bounds.upper_first := upperfirst;
    bounds.lower_second := lowersecond;
    bounds.upper_second := uppersecond
  end
end;
