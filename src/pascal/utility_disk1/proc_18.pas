{ utility_disk1:18 $0680..$077E, attributes$0788, nested in9.
  Locals1 saved low byte,2 saved word40. Reuse1 as a pointer before its save;
  recompute it for every original table access, preserving alias/order effects.
  Copy location four times with temporary coordinates147/115, then restore. }
procedure util1_18;
var
  scratch: utilwork;
  savedx: integer;
begin
  scratch.word := data29.words[24] + (data29.loc37.mid5 - 1) * 16;
  data29.bytes[71] := scratch.planet^.bytes[13];
  scratch.word := data29.words[24] + (data29.loc37.mid5 - 1) * 16;
  data29.bytes[70] := scratch.planet^.bytes[12];
  scratch.word := data29.words[24] + (data29.loc37.mid5 - 1) * 16;
  data29.bits37.mid6 := scratch.planet^.flags7.firstcity;
  scratch.word := data29.words[24] + (data29.loc37.mid5 - 1) * 16;
  data29.bits38.low6 := 10 + scratch.planet^.bytes[10] mod 20;
  scratch.word := data29.words[24] + (data29.loc37.mid5 - 1) * 16;
  data29.bits39.low5 := 6 + scratch.planet^.bytes[10] div 20;
  scratch.word := data29.words[25] + (data29.bits37.mid6 - 1) * 12;
  data29.bytes[75] := scratch.city^.fields5.low6;
  scratch.word := data29.words[25] + (data29.bits37.mid6 - 1) * 12;
  data29.bytes[77] := scratch.city^.fields5.middle5;
  savedx := data29.words[40];
  scratch.word := data29.bytes[80];
  data29.words[40] := 140 + 7;
  data29.bytes[80] := 96 + 19;
  data29.pos72 := data29.pos36;
  data29.pos66 := data29.pos36;
  data29.pos228 := data29.pos36;
  u1.slots[u1.words[6]].place18 := data29.pos36;
  data29.words[40] := savedx;
  data29.bytes[80] := scratch.word
end;
