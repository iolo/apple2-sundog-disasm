-- Declared native Tractor-entry probe. Load after the encounter, ground and
-- tactical helpers in an owned, paused Game12 main-loop debugger stop.
-- This does not establish ordinary menu reachability or a naturally won kill.
local m=manager.machine
local s=m.devices[':maincpu'].spaces.program
local json=require('json')
function a2.salvageCollectionSetup(path)
  assert(m.paused and m.debugger.execution_state=='stop')
  local before={state=a2.encounterCapture(),context=a2.tacticalSourceContext()}
  local c=before.context;local frame=c.source.frames[1];local g=c.source.globalsBase
  assert(c.source.vm.ip-c.segmentBase==0x1388,'use the Game12 main-loop stop')
  assert(frame.localBytes==94 and frame.parameterBytes==0)
  local locals={ [4]=3,[14]=0,[27]=1,[28]=0,[29]=0,[31]=0,[32]=0,[33]=0,[34]=217,[35]=0 }
  local words={ [207]=1,[208]=0,[209]=0,[216]=0,[217]=21,[354]=0 }
  for n,v in pairs(locals) do a2.write(frame.address+10+2*n,{v&255,(v>>8)&255}) end
  for n,v in pairs(words) do a2.write(g+2*n,{v&255,(v>>8)&255}) end
  local flags={ [35]=false,[36]=true,[40]=false,[41]=false,[45]=false }
  for n,v in pairs(flags) do
    local addr=g+164+n//8;local mask=1<<(n%8);local byte=s:read_u8(addr)
    a2.write(addr,{v and (byte|mask) or (byte&(~mask))})
  end
  -- Leave slot1's actual cargo intact; clear only slot2 for the source scan.
  local oldSlot2=a2.read(g+472,4).bytes
  a2.write(g+472,{0,0,0,0})
  -- The native main-loop case for Tractor calls proc18 at $148E. Dispatch
  -- that original instruction with the existing main activation/frame.
  a2.write(0x58,{(c.segmentBase+0x148e)&255,(c.segmentBase+0x148e)>>8})
  local result={scope='declared wreck/empty-slot/source-command-entry fixture',
    before=before,after={state=a2.encounterCapture(),context=a2.tacticalSourceContext()},
    localEdits=locals,wordEdits=words,flagEdits=flags,oldSlot2=oldSlot2,
    slot2={0,0,0,0},commandOffset=0x148e,wreck={packed=217,paidPrice=0}}
  local f=assert(io.open(path,'w'));f:write(json.stringify(result));f:close()
  return {path=path,commandOffset=0x148e,packedWreck=217,clearedSlot=2}
end
return true
