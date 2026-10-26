{ system_core0:13 $0394..$042F, attributes$043C. File pointer3, value2,
  width1; locals4 position,5 place,6 character,7 leading,8..13 string,
  14 zero lower bound (replaced by constant0). The ancestor powers20 table
  supplies divisors; do not replace it with a host number formatter.
  -32768 uses the literal before ABS. $03BD is the reviewed unreachable join
  after that transfer; it contributes no executed effect. Width is raised
  to the resulting length before passing the borrowed string to core19. }
procedure rt_write_integer(var f: integer; value, width: integer);
label 900;
var position, place, code: integer;
    leading: boolean;
    temp: s0str10;
begin
  position := 1;
  temp.bytes[0] := 10;
  leading := true;
  if value < 0 then
  begin
    if value = -32767 - 1 then
    begin
      temp.text := '-32768';
      goto 900
    end;
    value := abs(value);
    temp.bytes[1] := 45;
    position := 2
  end;
  place := 4;
  while place >= 0 do
  begin
    code := value div sy0e.powers20[place] + 48;
    if not odd(ord(code = 48) and ord(place > 0) and ord(leading)) then
    begin
      leading := false;
      temp.bytes[position] := code;
      position := position + 1;
      if code <> 48 then value := value mod sy0e.powers20[place]
    end;
    place := place - 1
  end;
  temp.bytes[0] := position - 1;
900:
  if width < temp.bytes[0] then width := temp.bytes[0];
  rt_write_string(f, temp.text, width)
end;
