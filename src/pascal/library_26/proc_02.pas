{ Both library26 variants: procedure2, $01D0..$01E9, attributes $01F4.
  Copy value caption before RELEASE. CSP33 receives the ADDRESS of DATA29
  word35; SunDog's $D6C6 handler restores heap$5A/$5B and clears$BDE6/$BDE7.
  Then place caption at$4000 and transfer to the nonreturning boot routine. }
procedure proc26_2(caption: text15);
begin
  release(data29.text35.text);
  data29.text35.word := 16384;
  data29.text35.text^ := caption;
  proc26_8
end;
