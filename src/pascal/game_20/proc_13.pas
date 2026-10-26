{ game_20 procedure13, $08CC..$0A60, attributes $0A6E.
  Parent row/column slots6/7 feed nested14/15. All item moves copy two words;
  the pod caption is refreshed whenever podidx>0, including failed stores. }
procedure proc20_13;
var
  selected: integer;
  found: integer;
  choice: integer;
  unused: array[4..5] of integer;
  row: integer;
  column: integer;
  wareidx: integer;
  podidx: integer;
  saved: stock4;
(*$include src/pascal/game_20/proc_14.pas*)
(*$include src/pascal/game_20/proc_15.pas*)
begin
  proc22_44;
  proc20_10('WAREHOUSE', g20.words[14], g20.words[13], g20.words[12] - 85);
  proc22_45;
  proc22_45;
  proc22_45;
  proc22_45;
  column := data29.words[19];
  row := data29.words[18];
  repeat
    proc20_15(column, row);
    proc25_2;
    proc20_9(g20.words[12] - 70, 1, 3, 'Store', 'Fetch', 'Swap');
    proc20_8(choice, found, data29.words[297], data29.bounds11, selected);
    if not odd(selected) then exit(proc20_13);
    selected := ord(choice = 3);
    fillchar(saved, 4, 0);
    podidx := 0;
    case choice of
      1, 3:
        begin
          proc20_12(podidx, true, column, row);
          if podidx > 0 then
          begin
            if odd(selected) then proc20_12(wareidx, false, column, row)
            else proc20_11(wareidx, false);
            if wareidx > 0 then
            begin
              if odd(selected) then saved := g20.ware52[wareidx];
              g20.ware52[wareidx] := data29.stock234[podidx];
              data29.stock234[podidx] := saved
            end
            else if not odd(selected) then
            begin
              proc20_14;
              proc22_48('No room to store in warehouse.');
              proc20_2
            end
          end
        end;
      2:
        begin
          proc20_12(wareidx, false, column, row);
          if wareidx > 0 then
          begin
            proc20_11(podidx, true);
            if podidx > 0 then
            begin
              data29.stock234[podidx] := g20.ware52[wareidx];
              g20.ware52[wareidx] := saved
            end
            else
            begin
              proc20_14;
              proc22_48('No room to fetch to pod.');
              proc20_2
            end
          end
        end
    end;
    if podidx > 0 then
      data29.labels238[podidx] := g20.names19.names^[data29.stock234[podidx].kind]
  until odd(data29.words[347])
end;
