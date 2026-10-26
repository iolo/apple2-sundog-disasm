{ game_16 procedure33, $0F7C..$1108, attributes $1118.
  Preserve VAR rereads and the flag index captured before random. The amount
  adjustment retains its decimal step loop and original comparison direction. }
procedure proc16_33(var action: integer);
var
  xpos: integer;
  step: integer;
  amount: wordpair;
begin
  case action of
    0, 4: begin
            data29.flags82[49] := true;
            g16.words[24] := 1;
            if action = 4 then
            begin
              if not odd(g16.words[18]) and (g16.words[41] < 23) and (arg1 = 17) then
              begin
                xpos := 80 + g16.words[41];
                step := proc22_3;
                data29.flags82[xpos] := odd(step)
              end;
              data29.bytes[552] := 0;
              data29.flags82[65] := false;
              data29.flags82[66] := false;
              data29.bytes[548] := 0
            end
          end;
    1, 2: begin
            g16.words[43] := g16.words[43] + 1;
            step := 10000;
            xpos := g16.words[13] + 9;
            while (step > 0) and (xpos > g16.words[71] + 38) do
            begin
              step := step div 10;
              xpos := xpos - 12
            end;
            proc28_4(amount, 0, step);
            if action = 1 then
            begin
              proc28_2(amount, g16.fund100);
              if proc28_6(g16.fund100, g16.cash104) then proc28_3(amount, g16.fund100)
            end
            else if proc28_6(amount, g16.fund100) then g16.fund100 := g16.fund102
            else proc28_3(amount, g16.fund100);
            proc22_19(g16.panel68, 0);
            proc22_12(g16.words[71] + 20, g16.words[69] + 16);
            proc16_4(g16.fund100);
            proc22_19(data29.bounds11, 0)
          end;
    3: begin
         g16.words[24] := 1;
         data29.flags82[65] := true;
         data29.flags82[66] := odd(g16.words[18]);
         data29.bytes[548] := g16.words[41]
       end;
    5, 6: begin
            g16.words[24] := 1;
            data29.flags82[51] := action = 5
          end;
    7: begin
         data29.flags82[50] := false;
         data29.flags82[48] := false;
         data29.flags82[49] := false;
         g16.words[24] := 1
       end;
    8: begin
         g16.words[24] := 1;
         data29.flags82[48] := true
       end;
    9, 10, 11: begin
                 g16.words[21] := 1;
                 action := g16.words[53 + (action - 9)]
               end
  end
end;
