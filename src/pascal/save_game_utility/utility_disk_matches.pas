{ utility_disk1:41 $1862..$1893, attributes$189E. Result slots1/2,
  Boolean argument3,256-byte local buffer at4. Unlike startup7:2, reads256
  bytes. Positive IORESULT self-exits with false; byte252 compares with0/9. }
(*$I-*)
function utility_disk_matches(utility: boolean): boolean;
var sector: packed array[0..255] of 0..255;
begin
  utility_disk_matches := false;
  unitread(4, sector, 256, 0, 0);
  if ioresult > 0 then exit(utility_disk_matches);
  if utility then utility_disk_matches := sector[252] = 0
  else utility_disk_matches := sector[252] = 9
end;
(*$I+*)
