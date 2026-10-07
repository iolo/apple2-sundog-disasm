-- Prepared source input probe. Load after tactical_reference.lua in an owned,
-- paused Game12 gun-loop debugger context. This explicitly edits target/charge
-- RAM; native buttons and axes are then read by unmodified original routines.
local m=manager.machine
local s=m.devices[':maincpu'].spaces.program
local json=require('json')
function a2.tacticalInputSetup(path)
  assert(m.paused and m.debugger.execution_state=='stop')
  local before=a2.tacticalSourceContext();local g=before.source.globalsBase
  for n,value in pairs({[205]=512,[206]=512,[207]=0,[208]=0,[209]=0,
    [215]=40,[216]=200,[217]=20,[226]=100,[354]=0}) do
    a2.write(g+2*n,{value&255,(value>>8)&255})
  end
  local result={scope='declared centered contact/charge fixture',before=before,
    after=a2.tacticalSourceContext(),state=a2.encounterCapture()}
  local f=assert(io.open(path,'w'));f:write(json.stringify(result));f:close()
  return {path=path,words=result.state.words}
end
function a2.tacticalInputAxes(x,y,primary,secondary)
  assert(m.paused or m.debugger.execution_state=='stop')
  assert(math.type(x)=='integer' and x>=0 and x<=255)
  assert(math.type(y)=='integer' and y>=0 and y<=255)
  assert(type(primary)=='boolean' and type(secondary)=='boolean')
  local p=m.ioport.ports
  p[':gameio:joy:joystick_1_x'].fields['P1 Joystick X']:set_value(x)
  p[':gameio:joy:joystick_1_y'].fields['P1 Joystick Y']:set_value(y)
  local b=p[':gameio:joy:joystick_buttons'].fields
  b['P1 Button 1']:set_value(primary and 1 or 0)
  b['P1 Button 2']:set_value(secondary and 1 or 0)
  return {x=x,y=y,primary=primary,secondary=secondary}
end
function a2.tacticalStoppedSave(path,offset)
  assert(m.debugger.execution_state=='stop','not a debugger stop')
  local c=a2.tacticalSourceContext()
  assert(c.source.vm.ip-c.segmentBase==offset,'unexpected source dispatch')
  emu.pause()
  return a2.tacticalSourceSave(path)
end
function a2.tacticalCommSetup(path)
  assert(m.paused and m.debugger.execution_state=='stop')
  local before=a2.tacticalSourceContext();local source=before.source
  assert(source.vm.ip-before.segmentBase==0x1388,'use the Game12 main-loop stop')
  local frame=source.frames[1]
  assert(frame.localBytes==94 and frame.locals['4']==0 and frame.locals['29']==0)
  -- Local44 is angle, local45 radius. Values deliberately cross byte bounds.
  a2.write(frame.address+10+2*44,{255,255})
  a2.write(frame.address+10+2*45,{9,3})
  local result={scope='declared signed reticle fixture',before=before,
    after=a2.tacticalSourceContext(),reticle={angle=-1,radius=777}}
  local f=assert(io.open(path,'w'));f:write(json.stringify(result));f:close()
  return {path=path,reticle=result.reticle}
end
return true
