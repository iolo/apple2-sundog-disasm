-- Declared rare-branch fixture and read-only original Game16 observations.
local m=manager.machine;local s=m.devices[':maincpu'].spaces.program;local j=require('json')
 local function source(offset)
  local trailer=s:read_u16(0xbdbe);assert(s:read_u16(0x56)==trailer)
  assert(s:read_u8(trailer)==16 and s:read_u8(trailer+1)==48)
  assert(s:read_u16(0x58)==trailer-0x1d14+offset);return trailer-0x1d14
 end
 local function context()
  local src=a2.groundSourceContext();local base=src.vm.segment-0x1d14;local main
  for _,f in ipairs(src.frames)do if f.procedureAddress==base+0x1cb2 then main=f;break end end
  assert(main,'Game16 main frame not found')
  local locals={};for _,n in ipairs({1,2,3,8,9,19,20,21,22,26,30,33,38,39,40,41,43,44,100,101,102,103,104,105,106,107,140,141})do locals[tostring(n)]=s:read_u16(main.address+10+2*n)end
  local ptr=locals['140'];local dict=locals['141'];local sp=a2.registers().SP+1
  return {state=a2.encounterCapture(),source=src,segmentBase=base,mainFrame=main.address,mainLocals=locals,
   flag125=(s:read_u8(src.globalsBase+179)&32)~=0,colonyProgress=s:read_u8(src.globalsBase+543),
   evaluationStack={pointer=sp,bytes=a2.read(sp,16).bytes},entryPrefix=(ptr>=0x800 and ptr<0xbf80)and a2.read(ptr,128).bytes or {},
   dictionaryPrefix=(dict>=0x800 and dict<0xbf80)and a2.read(dict,128).bytes or {}}
 end
 function a2.rewardBreakpoint(offset)
  local exp=string.format('w@0x56==w@0xbdbe && b@(w@0xbdbe)==0x10 && b@(w@0xbdbe+1)==0x30 && w@0x58==(w@0xbdbe-0x1d14+0x%x)',offset)
  return {id=m.devices[':maincpu'].debug:bpset(0xd293,exp,''),segment=16,offset=offset}
 end
 function a2.rewardSave(path,offset)
  source(offset);emu.pause();local data=context();local f=assert(io.open(path..'.json','w'));f:write(j.stringify(data));f:close();assert(not m.screens[':screen']:snapshot(path..'.png'));return {path=path,offset=offset}
 end
 function a2.rewardSetup(path)
  source(0x1252);assert(m.paused);local before=context();local g=before.source.globalsBase
  a2.write(before.mainFrame+12,{18,0});a2.write(g+543,{2});a2.write(g+179,{s:read_u8(g+179)&223});a2.write(g+42,{23,0,0,0})
  local f=assert(io.open(path,'w'));f:write(j.stringify({scope='declared type18, colony progress2, flag125false and RNG23 at actual Game16 proc39 entry in existing Comm activation; no instruction/frame edits',before=before,after=context()}));f:close();return {path=path}
 end
 return true
