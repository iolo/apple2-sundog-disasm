{ game_12 procedure16, $0CB8..$0CD9, attributes $0CE4; nested in15.
  The value labeltext occupies slots3..10. Parent slots3/4/5 hold bounds. }
procedure proc12_16(itemcode: integer; labeltext: text15);
begin
  proc25_3(itemcode, labeltext, left, right, top, top + 10);
  top := top + 15
end;
