-- Controlled fatal-hit probe on disposable media. Load the encounter and
-- ground reference helpers first. RAM edits are declared; original damage,
-- dispatcher, death dialog and saved-point reload routines remain unmodified.
local m=manager.machine
local s=m.devices[':maincpu'].spaces.program
local json=require('json')
local segments={ [7]={size=0x074a,procedures=8}, [24]={size=0x10d0,procedures=17} }
local function source(segment,offset)
  assert(m.paused or m.debugger.execution_state=='stop')
  local spec=assert(segments[segment])
  local slot=0xbdb6+2*(segment-12)
  local trailer=s:read_u16(slot)
  assert(trailer>=spec.size+0x800 and trailer+1<0xc000)
  assert(s:read_u8(trailer)==segment and s:read_u8(trailer+1)==spec.procedures)
  local base=trailer-spec.size
  if offset then assert(s:read_u16(0x58)==base+offset,'unexpected source dispatch') end
  return base
end
function a2.recoverySourceBreakpoint(segment,offset)
  assert(m.paused or m.debugger.execution_state=='stop')
  local spec=assert(segments[segment])
  assert(math.type(offset)=='integer' and offset>=0 and offset<spec.size)
  local slot=0xbdb6+2*(segment-12)
  local exp=string.format('w@0x58==(w@0x%x-0x%x+0x%x)',slot,spec.size,offset)
  return {id=m.devices[':maincpu'].debug:bpset(0xd293,exp,''),segment=segment,offset=offset}
end
function a2.recoverySourceSave(path,segment,offset)
  source(segment,offset);emu.pause()
  a2.groundSourceSave(path)
  return {path=path,segment=segment,offset=offset}
end
function a2.recoveryFatalSetup(path)
  assert(m.paused and m.debugger.execution_state=='stop')
  source(24,0x084c)
  local before={state=a2.encounterCapture(),source=a2.groundSourceContext()}
  local g=before.source.globalsBase
  local edits={ [207]=0,[214]=1,[215]=40,[217]=5,[225]=0 }
  for n,v in pairs(edits) do a2.write(g+2*n,{v&255,(v>>8)&255}) end
  a2.write(g+372,{1})
  a2.write(g+42,{28,0,0,0}) -- Draws3584/3591/3719/3975/28295: hit, hull, fatal.
  local flagAddress=g+164+5
  local flags=s:read_u8(flagAddress)
  a2.write(flagAddress,{flags|(1<<5)}) -- Pending fire45; contact40 retained.
  local result={scope='declared fatal-hit fixture at Library24 proc13 $084c',
    before=before,after={state=a2.encounterCapture(),source=a2.groundSourceContext()},
    wordEdits=edits,hull=1,randomState=28,pendingFire=true}
  local f=assert(io.open(path,'w'));f:write(json.stringify(result));f:close()
  return {path=path,wordEdits=edits,hull=1,randomState=28}
end
return true
