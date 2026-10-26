{ utility_disk1:22 $1168..$11C6, attributes$11D4. No parameters,70 local
  bytes. Poll0 and poll1 on every inner iteration, even with a saved selection.
  Child29 may set parent34, so test it again before opening confirmation30. }
procedure util1_22;
var attrwork: u22frame;
(*$include src/pascal/utility_disk1/proc_23.pas*)
(*$include src/pascal/utility_disk1/proc_24.pas*)
(*$include src/pascal/utility_disk1/proc_25.pas*)
(*$include src/pascal/utility_disk1/proc_26.pas*)
(*$include src/pascal/utility_disk1/proc_27.pas*)
(*$include src/pascal/utility_disk1/proc_28.pas*)
(*$include src/pascal/utility_disk1/proc_29.pas*)
(*$include src/pascal/utility_disk1/proc_30.pas*)
begin
  util1_25;
  attrwork.words[7] := -1;
  repeat
    proc22_42(attrwork.words[4], attrwork.words[3], 2, data29.bounds11);
    repeat
      proc22_43(attrwork.words[4], attrwork.words[3]);
      attrwork.words[33] := proc22_2(0) or ord(attrwork.words[7] <> -1);
      attrwork.words[34] := proc22_2(1)
    until odd(attrwork.words[34] or attrwork.words[33]);
    proc22_41(attrwork.words[4], attrwork.words[3]);
    if odd(attrwork.words[33]) then
    begin
      if attrwork.words[7] = -1 then
        util1_28(attrwork.words[4], attrwork.words[3], attrwork.words[7]);
      if attrwork.words[7] >= 0 then util1_29(attrwork.words[7])
    end;
    if odd(attrwork.words[34]) then util1_30
  until odd(attrwork.words[35]);
  util1_26
end;
