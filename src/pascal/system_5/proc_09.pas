{ system5:9 $0338..$03B0, attributes$03BA. Result1,caption pointer3;
  value copy4..11, sector12..267,file268..557,allowed558,unused state559.
  File-open/read failures retain false. The mask-builder result is discarded;
  registration and true follow regardless. All local paths close at$03A9.
  The runtime exit pointer is$03B0 (RNP1), after that close: a nonlocal exit
  to this procedure does not repeat it. }
(*$I-*)
function sys5_9(caption: text15): boolean;
label 999;
var
  header: s5header;
  f: sysfile;
  allowed: s5mask16;
  state: s5state;
begin
  sys6_2(f.words[0], nil, -1);
  sys5_9 := false;
  sys6_4(f.words[0], caption, 1, nil);
  if ioresult = 0 then
  begin
    state.base := sy5e.common.state;
    unitread(f.words[7], header, 512, f.words[16], 0);
    if ioresult <> 0 then goto 999;
    fillchar(allowed, 2, 0);
    allowed[6] := true;
    allowed[7] := true;
    if sys5_8(header, sy5e.mask533, allowed) then begin end;
    sys5_7(header, f);
    sys5_9 := true
  end;
999:
  sys6_5(f.words[0], 0)
end;
(*$I+*)
