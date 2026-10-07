-- Read-only tactical context and owned source breakpoints. Load after the
-- a2-mame helper, encounter_reference.lua and ground_reference.lua.
local m=manager.machine
local s=m.devices[':maincpu'].spaces.program
local function stopped()
  assert(m.paused or (m.debugger and m.debugger.execution_state=='stop'))
end
local function segment12()
  local trailer=s:read_u16(0xbdb6)
  assert(trailer>=0x800+0x15a8 and trailer+1<0xc000,'Game12 is not loaded')
  assert(s:read_u8(trailer)==12 and s:read_u8(trailer+1)==23,'Game12 trailer mismatch')
  local base=trailer-0x15a8
  assert(s:read_u8(base+0x0b87)==0xcd and s:read_u8(base+0x0b88)==24
    and s:read_u8(base+0x0b89)==9,'Game12 machinery call mismatch')
  return base
end
function a2.tacticalOpcodeBreakpoint(offset)
  stopped();assert(m.debugger,'launch with --debug')
  assert(math.type(offset)=='integer' and offset>=0 and offset<0x15a8)
  -- Resolve the trailer at dispatch, including before Game12 is loaded.
  -- Validate the trailer/call bytes with tacticalSourceContext at the stop.
  -- MAME debugger literals default to hexadecimal, unlike Lua numbers.
  local expression=string.format('w@0x58==(w@0xbdb6-0x15a8+0x%x)',offset)
  return {id=m.devices[':maincpu'].debug:bpset(0xd293,expression,''),offset=offset}
end
function a2.tacticalSourceContext()
  stopped()
  return {segmentBase=segment12(),source=a2.groundSourceContext()}
end
function a2.tacticalSourceSave(path)
  assert(m.paused,'pause before a complete capture')
  local g=s:read_u16(0xbdd8)
  local result={state=a2.encounterCapture(),source=a2.groundSourceContext(),segmentBase=segment12(),
    podRecords=a2.read(g+468,8).bytes,podLabels=a2.read(g+476,32).bytes}
  local f=assert(io.open(path..'.json','w'));f:write(require('json').stringify(result));f:close()
  assert(not m.screens[':screen']:snapshot(path..'.png'))
  return {path=path,ip=result.source.vm.ip,segmentBase=result.segmentBase}
end
return true
