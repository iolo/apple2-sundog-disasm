-- Read-only source context and owned debugger breakpoints for ground evidence.
-- Load after the a2-mame control helper and encounter_reference.lua.
local m=manager.machine
local s=m.devices[':maincpu'].spaces.program
local json=require('json')
local function stopped()
  assert(m.paused or (m.debugger and m.debugger.execution_state=='stop'))
end
local function word(addr)
  assert(addr>=0x800 and addr+1<0xc000)
  return s:read_u16(addr)
end
local function segment21()
  local trailer=word(0xbdc8)
  assert(trailer>=8130+0x800 and trailer+1<0xc000)
  assert(s:read_u8(trailer)==21 and s:read_u8(trailer+1)==41,'Game21 is not loaded')
  local base=trailer-8130
  assert(s:read_u8(base+0x1f0e)==0xcd and s:read_u8(base+0x1f0f)==22
    and s:read_u8(base+0x1f10)==3,'Game21 RNG call does not match source')
  return base
end
function a2.groundSourceContext()
  stopped()
  local g=word(0xbdd8)
  local words,flags={},{}
  for _,n in ipairs({1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,21,22,
    23,36,37,38,39,40,41,45,64,65,73,74,75,76,77,217,292,347,351,352,353,354,
    357,358,359,360,361,362,363,364,365,366,367,370,371}) do
    words[tostring(n)]=word(g+2*n)
  end
  for _,n in ipairs({7,12,28,40,41,44,48,49,50,114,116,117}) do
    flags[tostring(n)]=(s:read_u8(g+164+math.floor(n/8))&(1<<(n%8)))~=0
  end
  local frames,ptr={},s:read_u16(0x52)
  local procedure=s:read_u16(0x54)
  for i=1,12 do
    if ptr<0x800 or ptr+12>=0xc000 then break end
    local locals,count,localBytes,parameterBytes={},0,nil,nil
    if procedure>=0x808 and procedure+1<0xc000 then
      localBytes=word(procedure-8);parameterBytes=word(procedure-6)
      if localBytes%2==0 and parameterBytes%2==0 and localBytes<=512 and parameterBytes<=64 then
        count=math.min(128,(localBytes+parameterBytes)//2)
      end
    end
    for n=1,count do
      if ptr+11+2*n>=0xc000 then break end
      locals[tostring(n)]=word(ptr+10+2*n)
    end
    frames[#frames+1]={address=ptr,header=a2.read(ptr,12).bytes,locals=locals,
      procedureAddress=procedure,localBytes=localBytes,parameterBytes=parameterBytes}
    procedure=word(ptr+4)
    local parent=word(ptr+2);if parent==ptr then break end;ptr=parent
  end
  return {globalsBase=g,words=words,flags=flags,frames=frames,
    vm={mp=s:read_u16(0x52),procedure=s:read_u16(0x54),segment=s:read_u16(0x56),ip=s:read_u16(0x58)},
    randomBytes=a2.read(g+42,4).bytes,cpu=a2.registers(),status=a2.status()}
end
function a2.groundSourceSave(path)
  assert(m.paused,'pause before a complete capture')
  local result={state=a2.encounterCapture(),source=a2.groundSourceContext()}
  local f=assert(io.open(path..'.json','w'));f:write(json.stringify(result));f:close()
  assert(not m.screens[':screen']:snapshot(path..'.png'))
  return {path=path}
end
function a2.groundOpcodeBreakpoint(offset)
  stopped();assert(m.debugger,'launch with --debug')
  assert(math.type(offset)=='integer' and offset>=0 and offset<8130)
  local ip=segment21()+offset
  return {id=m.devices[':maincpu'].debug:bpset(0xd293,string.format('w@0x58==0x%x',ip),''),ip=ip}
end
function a2.groundGateBreakpoint()
  stopped();assert(m.debugger,'launch with --debug')
  local g=word(0xbdd8)
  local matches={}
  for addr=0x800,0xbff0 do
    if s:read_u8(addr)==0xa0 and s:read_u8(addr+1)==7 and s:read_u8(addr+2)==0x0e
      and s:read_u16(addr+3)==g+42 and s:read_u8(addr+5)==8
      and s:read_u8(addr+6)==0x2e and s:read_u16(addr+7)==g+43
      and s:read_u8(addr+9)==0x2e and s:read_u16(addr+10)==g+44 then
      matches[#matches+1]=addr
    end
  end
  assert(#matches==1,'native RNG entry is not unique')
  local ip=segment21()+0x1f11
  return {id=m.devices[':maincpu'].debug:bpset(matches[1],string.format('w@0x58==0x%x',ip),''),
    pc=matches[1],ip=ip,randomAddress=g+42}
end
function a2.groundCombatBreakpoint(offset)
  stopped();assert(m.debugger,'launch with --debug')
  assert(math.type(offset)=='integer' and offset>=0 and offset<3530)
  -- The segment may still be unloaded. Resolve its trailer on each dispatch.
  local expression=string.format('w@0x58==(w@0xbdc0-0xdca+0x%x)',offset)
  return {id=m.devices[':maincpu'].debug:bpset(0xd293,expression,'')}
end
return true
