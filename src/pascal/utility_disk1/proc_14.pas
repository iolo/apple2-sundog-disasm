{ utility_disk1:14 $03E0..$057F, attributes$0590, nested in9.
  100-byte frame with code rows18..44 and reused slot46. Source templates
  have28-byte stride, output rows32. Copy the second seven words FIRST.
  Flush/clear at16 rows; the final54-byte code copy and two-row advance are
  preserved without invented padding, flushes or initialization of spare bits. }
procedure util1_14;
var work14: u14frame;
(*$include src/pascal/utility_disk1/proc_15.pas*)
begin
  proc22_23(2048, work14.buffer10.word);
  proc22_23(2048 + 512, work14.template9.word);
  proc22_53(2048 + 512, 1, data29.words[30], true);
  data29.bytes[544] := 0;
  work14.words[2] := (work14.template9.bytes^[504] + 5) mod 18;
  work14.template9.bytes^[504] := work14.words[2];
  data29.bytes[543] := work14.words[2];
  fillchar(work14.buffer10.bytes^, 512, 0);
  work14.words[7] := 0;
  work14.words[5] := 3;
  work14.words[8] := 1;
  work14.words[46] := 18;
  while work14.words[8] <= work14.words[46] do
  begin
    work14.words[1] := (work14.words[2] + (work14.words[8] - 1)) mod 18 + 1;
    work14.planet47.word := data29.words[24] + (work14.words[8] - 1) * 16;
    work14.source48.template := @work14.template9.table^[work14.words[1]];
    work14.words[4] := 1;
    work14.limit49 := work14.planet47.planet^.flags7.count;
    while work14.words[4] <= work14.limit49 do
    begin
      work14.dest50.row := @work14.buffer10.rows^[work14.words[7]];
      work14.dest50.row^.second := work14.source48.template^.second;
      work14.dest50.row^.first := work14.source48.template^.first;
      work14.dest50.row^.flag14 := -16;
      work14.dest50.row^.bytes15.high := 0;
      work14.dest50.row^.bytes15.low := 0;
      work14.words[7] := work14.words[7] + 1;
      if work14.words[7] = 16 then
      begin
        proc22_53(2048, 1, initwork.words[2] + work14.words[5], false);
        work14.words[7] := 0;
        fillchar(work14.buffer10.bytes^, 512, 0);
        work14.words[5] := work14.words[5] + 1
      end;
      work14.words[4] := work14.words[4] + 1
    end;
    work14.words[8] := work14.words[8] + 1
  end;
  work14.words[3] := 0;
  util1_15('@@@@HIKM');
  util1_15('@@JLNU__');
  util1_15('@@TV____');
  util1_15('@HPQRSW_');
  util1_15('@ILXYZ__');
  util1_15('@QRU[___');
  util1_15('CFIOQ^__');
  util1_15('BDENTY__');
  util1_15('BGPXZ\]_');
  moveleft(work14.codes18, work14.buffer10.rows^[work14.words[7]], 54);
  work14.words[7] := work14.words[7] + 2;
  work14.work46.row := @work14.buffer10.rows^[work14.words[7]];
  work14.work46.row^.flag14 := -16;
  work14.work46.row^.bytes15.high := 1;
  work14.work46.row^.bytes15.low := 1;
  proc22_53(2048, 1, initwork.words[2] + work14.words[5], false)
end;
