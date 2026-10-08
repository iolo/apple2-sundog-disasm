-- Declared original Nav/Warp context on an owned IIe and disposable media.
-- IP/local re-entry and source status-window geometry are explicit fixtures.
-- Healthy and fatal continuations execute original code; no code patch.
local m=manager.machine;local s=m.devices[':maincpu'].spaces.program;local j=require('json')
 function a2.warpExit(path)
 assert(m.paused and m.debugger.execution_state=='stop')
 local c=a2.tacticalSourceContext();assert(c.source.vm.ip-c.segmentBase==0x1388)
 local frame=c.source.frames[1];assert(frame.localBytes==94)
 local before={context=c,state=a2.encounterCapture()}
 a2.write(frame.address+10+2*12,{1,0})
 a2.write(0x58,{(c.segmentBase+0x14cc)&255,(c.segmentBase+0x14cc)>>8})
 local f=assert(io.open(path,'w'));f:write(j.stringify({scope='declared Game12 exit flag/original exit-test re-entry',before=before,after=a2.tacticalSourceContext()}));f:close()
 return {path=path}
 end
 function a2.warpNav(path)
 assert(m.paused and m.debugger.execution_state=='stop')
 local c=a2.groundSourceContext();local base=c.vm.segment-0x27e4
 assert(c.vm.ip-base==0x269d and c.frames[1].localBytes==16)
 local before={context=c,state=a2.encounterCapture()}
 a2.write(0x58,{(base+0x2683)&255,(base+0x2683)>>8})
 local f=assert(io.open(path,'w'));f:write(j.stringify({scope='declared original Nav case call in existing Game13 main activation',before=before,after=a2.groundSourceContext()}));f:close()
 return {path=path}
 end
 function a2.warpChoice(path)
 assert(m.paused and m.debugger.execution_state=='stop')
 local c=a2.groundSourceContext();local base=c.vm.segment-0x27e4
 assert(c.vm.ip-base==0x2368)
 local before={context=c,state=a2.encounterCapture()};local frame=c.frames[1]
 a2.write(c.globalsBase+2*307,{13,0,4,0,9,1,245,0}) -- Library22 proc18 result for original Game15 $009D–$00A9 rectangle245,265,4,13
 a2.write(frame.address+10+2*8,{7,0});a2.write(frame.address+10+2*6,{1,0});a2.write(frame.address+10+2*7,{0,0})
 for n,v in pairs({[221]=11,[222]=10,[223]=10}) do a2.write(c.globalsBase+2*n,{v&255,v>>8}) end
 local flag=c.globalsBase+164;a2.write(flag,{s:read_u8(flag)|1})
 local target=a2.read(c.globalsBase+144,12).bytes;target[3]=(target[3]&240)|11
 a2.write(frame.address+10+2*9,target)
 a2.write(0x58,{(base+0x2415)&255,(base+0x2415)>>8})
 local f=assert(io.open(path,'w'));f:write(j.stringify({scope='declared Warp command7, charged target11, existing-location record with system11 and source Game15 status-window geometry; original action call2415',before=before,after=a2.groundSourceContext()}));f:close()
 return {path=path,locals=c.frames[1].locals}
 end

function a2.warpDefeatHealthy(path)
 assert(m.paused and m.debugger.execution_state=='stop')
 local before=a2.encounterCapture();local g=before.globalsBase
 a2.write(g+372,{100})
 local f=assert(io.open(path,'w'));f:write(j.stringify({scope='healthy hull100 control for the same pending-shot and original Nav/Warp path',before=before,after=a2.encounterCapture()}));f:close()
 return {path=path}
end
function a2.warpDefeatSave(path,segment,offset)
 a2.recoverySourceSave(path,segment,offset)
 local g=a2.encounterCapture().globalsBase
 local f=assert(io.open(path..'.json','r'));local value=j.parse(f:read('*a'));f:close()
 value.currentLocation=a2.read(g+144,12).bytes
 value.selectedLocation=a2.read(g+72,12).bytes
 value.statusRectangle307=a2.read(g+614,8).bytes
 value.opcodeVector=a2.read(0xd020,16).bytes
 f=assert(io.open(path..'.json','w'));f:write(j.stringify(value));f:close()
 return {path=path,segment=segment,offset=offset}
end
