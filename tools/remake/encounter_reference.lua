-- Controlled original-game probes, loaded into an owned, paused MAME console.
-- Boot the existing game-play sequence on disposable copies first. This file
-- changes declared RAM fields; it does not claim natural encounter generation.
local m=manager.machine
local s=m.devices[':maincpu'].spaces.program
local json=require('json')
local pending,frames=nil,0
local function base() return s:read_u16(0xbdd8) end
local function capture()
  local g=base();local words,flags={},{}
  for _,n in ipairs({40,41,45,203,204,205,206,207,208,209,214,215,216,217,222,223,224,225,226,227,347,351,352,353,354}) do
    words[tostring(n)]=s:read_u16(g+2*n)
  end
  for _,n in ipairs({0,1,2,4,5,7,12,29,35,36,40,41,43,44,45,46,47,48,49,50,51}) do
    flags[tostring(n)]=(s:read_u8(g+164+math.floor(n/8))&(1<<(n%8)))~=0
  end
  local equipment={}
  for i=0,5 do
    local bytes={};for j=0,27 do bytes[#bytes+1]=s:read_u8(g+180+28*i+j) end
    equipment[#equipment+1]=bytes
  end
  return {globalsBase=g,words=words,flags=flags,equipment=equipment,hull=s:read_u8(g+372),
    condition=a2.read(g+120,4).bytes,attributes=a2.read(g+96,5).bytes,
    carried=a2.read(g+124,4).bytes,location=a2.read(g+72,12).bytes,
    clock=a2.read(g+84,4).bytes,workspace=a2.read(g+542,24).bytes,
    rangeMemory=s:read_u8(g+373),frames=frames,
    pc=m.devices[':maincpu'].state['PC'].value}
end
function a2.encounterCapture() assert(m.paused);return capture() end
function a2.encounterRun(name,path,wordEdits,flagEdits,duration)
  assert(m.paused and not pending)
  assert(type(name)=='string' and type(path)=='string' and duration>=1 and duration<=2400)
  local g=base();local before=capture()
  for n,value in pairs(wordEdits or {}) do a2.write(g+2*tonumber(n),{value&255,(value>>8)&255}) end
  for n,value in pairs(flagEdits or {}) do
    n=tonumber(n);local addr=g+164+math.floor(n/8);local mask=1<<(n%8);local byte=s:read_u8(addr)
    a2.write(addr,{value and (byte|mask) or (byte&(~mask))})
  end
  pending={name=name,path=path,before=before,setup=capture(),wordEdits=wordEdits,flagEdits=flagEdits,
    started=frames,duration=duration}
  emu.unpause()
  return {scheduled=true,name=name,duration=duration,setup=pending.setup}
end
function a2.spaceContact(path)
  local mode=(s:read_u16(base()+90)&0xf0ff)|0x0100
  return a2.encounterRun('space-contact',path,
    {[45]=mode,[203]=0,[205]=512,[206]=512,[207]=-1,[208]=0,[209]=0,
      [214]=1,[215]=40,[216]=200,[217]=127,[225]=100,[226]=100,[347]=0,[353]=16},
    {[0]=false,[1]=false,[2]=false,[4]=false,[5]=false,[12]=false,[29]=false,
      [35]=false,[36]=false,[40]=true,[41]=true,[43]=false,[44]=false,[45]=false},480)
end
function a2.encounterInput(name,path,xvalue,yvalue,button,duration)
  assert(m.paused and not pending)
  assert(type(name)=='string' and type(path)=='string' and duration>=1 and duration<=2400)
  assert(math.type(xvalue)=='integer' and xvalue>=0 and xvalue<=255)
  assert(math.type(yvalue)=='integer' and yvalue>=0 and yvalue<=255)
  assert(button==nil or button==0 or button==1)
  local ports=m.ioport.ports
  local x=ports[':gameio:joy:joystick_1_x'].fields['P1 Joystick X']
  local y=ports[':gameio:joy:joystick_1_y'].fields['P1 Joystick Y']
  local buttons=ports[':gameio:joy:joystick_buttons'].fields
  x:set_value(xvalue);y:set_value(yvalue)
  if button~=nil then buttons['P1 Button '..tostring(button+1)]:set_value(1) end
  local result=a2.encounterRun(name,path,{},{},duration)
  pending.input={x=xvalue,y=yvalue,button=button};pending.buttons=buttons
  return result
end
function a2.encounterRelease()
  local ports=m.ioport.ports
  ports[':gameio:joy:joystick_1_x'].fields['P1 Joystick X']:clear_value()
  ports[':gameio:joy:joystick_1_y'].fields['P1 Joystick Y']:clear_value()
  local buttons=ports[':gameio:joy:joystick_buttons'].fields
  buttons['P1 Button 1']:clear_value();buttons['P1 Button 2']:clear_value()
  return {released=true}
end
emu.register_frame_done(function()
  frames=frames+1
  if pending and frames-pending.started>=pending.duration then
    emu.pause()
    local result={name=pending.name,scope='controlled RAM fixture',before=pending.before,
      setup=pending.setup,after=capture(),wordEdits=pending.wordEdits,flagEdits=pending.flagEdits,
      elapsedFrames=frames-pending.started,input=pending.input}
    if pending.buttons then
      pending.buttons['P1 Button 1']:set_value(0);pending.buttons['P1 Button 2']:set_value(0)
    end
    assert(not m.screens[':screen']:snapshot(pending.path..'.png'))
    local f=assert(io.open(pending.path..'.json','w'));f:write(json.stringify(result));f:close()
    print('R10_PROBE '..json.stringify({name=pending.name,path=pending.path,elapsedFrames=result.elapsedFrames}))
    pending=nil
  end
end)
return true
