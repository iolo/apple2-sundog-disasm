{ library_24 procedure8, $014C..$0261, attributes $0272.
  Raw 28-byte records at DATASEG29 word90; source meanings are unresolved. }
procedure recompute_component_group(base: integer);
var
  expected: integer;    { 2 }
  group: integer;       { 3 }
  actual: integer;      { 4 }
  column: integer;      { 5 }
  remaining: integer;   { 6 }
  row: integer;         { 7 }
  total: integer;       { 8 }
  special: integer;     { 9 }
  matchcode: integer;   { 10 }
  matched: boolean;     { 11 }
begin
  group := base;
  base := 28 * base;
  matchcode := data29.bytes[178 + (base + 26)];
  if matchcode = 0 then matchcode := -1;
  special := data29.bytes[178 + (base + 27)] + base;
  total := 0;
  row := 0;
  data29.flags82[group + 16] := false;
  while row < 20 do
  begin
    remaining := 4;
    column := base;
    matched := false;
    while (column < base + 4) and (remaining > 0) do
    begin
      actual := data29.bytes[178 + (column + row)];
      expected := data29.bytes[178 + (column + 20)];
      if (actual = 23) and (column > base) then remaining := remaining - 1
      else if column = special then
      begin
        if actual = matchcode then matched := true
        else if actual <> expected then remaining := 0
      end
      else if (actual < 23) or (actual <> expected) then remaining := 0;
      column := column + 1
    end;
    data29.bytes[178 + ((base + 4) + row)] := remaining;
    total := total + remaining;
    if matched and (remaining > 0) then data29.flags82[group + 16] := true;
    row := row + 5
  end;
  data29.bytes[178 + (base + 24)] := total;
  if total = 0 then
  begin
    data29.flags82[group] := false;
    if group = 0 then data29.warp_setting := 0
    else if group = 2 then data29.weapon_charge := 0
    else if group = 4 then data29.shield_setting := 0
  end;
  if not data29.flags82[group + 16] then data29.flags82[group + 8] := false
end;
