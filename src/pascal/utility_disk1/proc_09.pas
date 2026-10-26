{ utility_disk1:9 $0A86..$0A95, attributes$0AA0. No parameters,34 local
  bytes. Slot2 selects the ten-block save area. Other locals retain their
  original initialization state; in particular13 first reads unknown slot9. }
procedure util1_9;
var initwork: utilinit;
(*$include src/pascal/utility_disk1/proc_10.pas*)
(*$include src/pascal/utility_disk1/proc_11.pas*)
(*$include src/pascal/utility_disk1/proc_12.pas*)
(*$include src/pascal/utility_disk1/proc_13.pas*)
(*$include src/pascal/utility_disk1/proc_14.pas*)
(*$include src/pascal/utility_disk1/proc_16.pas*)
(*$include src/pascal/utility_disk1/proc_17.pas*)
(*$include src/pascal/utility_disk1/proc_18.pas*)
(*$include src/pascal/utility_disk1/proc_19.pas*)
(*$include src/pascal/utility_disk1/proc_20.pas*)
(*$include src/pascal/utility_disk1/proc_21.pas*)
begin
  initwork.words[2] := data29.words[31] + 10 * u1.words[6];
  util1_21;
  util1_17;
  util1_18
end;
