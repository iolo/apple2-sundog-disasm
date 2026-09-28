-- Load the a2-mame control.lua helper as global a2 before this file.
-- Owned paused Apple IIe play session; see docs/remake/survival.md.
local m=manager.machine
local s=m.devices[':maincpu'].spaces.program
local pending,frames=nil,0
local function capture()
 local g=s:read_u16(0xbd9e+58)
 return {condition=a2.read(g+120,4).bytes,clock=a2.read(g+84,4).bytes,mode=a2.read(g+90,2).bytes}
end
function a2.hourProbe(name,values,sleep)
 assert(m.paused)
 local g=s:read_u16(0xbd9e+58)
 a2.write(g+120,values);a2.write(g+84,{59,0,0,0})
 -- Flags bit59 is byte7 bit3 of the set at word82. This controlled probe
 -- tests suppression of rest drain, not the game8 sleep-loop restoration.
 local flag=s:read_u8(g+171)
 a2.write(g+171,{sleep and (flag | 8) or (flag & 247)})
 pending={name=name,started=frames,stabilize=nil}
 emu.unpause()
 return {written=values,sleeping=sleep,clock={59,0,0,0}}
end
emu.register_frame_done(function()
 frames=frames+1
 if not pending then return end
 local g=s:read_u16(0xbd9e+58)
 if s:read_u8(g+85)==1 and not pending.stabilize then pending.stabilize=frames+15 end
 if (pending.stabilize and frames>=pending.stabilize) or frames-pending.started>2000 then
   emu.pause()
   local result=capture();result.name=pending.name
   result.timeout=not pending.stabilize
   local path='/tmp/r05d-'..pending.name..'.json'
   local f=assert(io.open(path,'w'));f:write(require('json').stringify(result));f:close()
   print('PROBE '..require('json').stringify(result));pending=nil
 end
end)
return true
