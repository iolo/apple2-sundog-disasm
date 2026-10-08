#!/usr/bin/env python3
"""Retain and verify native fatal second/third startup-call continuations."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
from verify_startup_defeat_reference import ROOT, REF, SIZES

CALLS={2:('second',0x06c4),3:('third',0x074f)}
RETURNS=[('startup-first-after',0x0658),('startup-second-after',0x06c7),('startup-third-after',0x0752)]


def contexts(call):
    label,offset=CALLS[call]
    return {'main':(12,0x1388),'startup-'+label:(12,offset),
            'fire-before':(24,0x084c),'fatal':(24,0x096a),
            **{n:(12,o) for n,o in RETURNS[call-1:]},
            'menu-before':(12,0x0f19),'menu-after':(12,0x0f2b),
            'first-main':(12,0x1388),'main-exit-check':(12,0x14cc),'death':(7,0x04b2)}


def check(call,read,operations,terminal):
    assert terminal['clean'] is True and terminal['exitCode']==0
    assert all(r['ok'] for r in operations)
    by_id={r['id']:r for r in operations}
    assert len(by_id)==len(operations)
    assert by_id['release']['result']['released'] is True
    assert by_id['exit']['result']['scheduled']=='exit'
    owned={r['result']['id'] for r in operations if r['id'].endswith('-bp')}
    cleared={by_id[r['id'].removesuffix('-clear')+'-bp']['result']['id']
             for r in operations if r['id'].endswith('-clear') and r['result']['cleared'] is True}
    cleared.update(int(r['id'].removeprefix('clear-')) for r in operations
                   if r['id'].startswith('clear-') and r['result']['cleared'] is True)
    assert owned==cleared
    values={n:read(n) for n in contexts(call)}
    for name,(segment,offset) in contexts(call).items():
        src=values[name]['source']
        assert src['vm']['ip']-src['vm']['segment']+SIZES[segment]==offset,name
        assert src['status']['driver']=='apple2e' and src['status']['version']=='0.285'
        assert src['status']['debugger']=='stop' and src['status']['paused'] is True
        assert src['cpu']['PC']==0xd293
    setup=read('startup-setup')
    assert setup['wordEdits']=={'354':0} and setup['commandOffset']==0x1381
    prepared=read('fatal-setup')['after']
    assert prepared['source']['randomBytes']==[28,0,0,0]
    assert prepared['state']['hull']==1 and prepared['state']['flags']['45']
    phase=call+1
    assert values['fire-before']['state']['words']['352']==phase
    vectors={'fatal':(phase,60,40,0)}
    for i,(name,_) in enumerate(RETURNS[call-1:]):vectors[name]=(phase+i,60,40-4*i,0)
    cooldown=40-4*(3-call)
    vectors.update({'menu-before':(4,60,cooldown,0),'menu-after':(4,60,cooldown-1,0),
                    'first-main':(4,60,cooldown-1,0),'main-exit-check':(4,60,cooldown-2,1),
                    'death':(1,52,cooldown-6,0)})
    fatal=values['fatal']
    for name,vector in vectors.items():
        d=values[name];w=d['state']['words']
        assert tuple(w[k] for k in ['352','226','215','354'])==vector,name
        assert w['347']==1 and w['217']==5
        assert d['source']['randomBytes']==[220,15,135,195]
        assert d['state']['clock']==([19,21,0,0] if name=='death' else [18,21,0,0])
        assert d['state']['condition']==[237,235,255,228]
        for key in ['equipment','attributes','carried','location']:
            assert d['state'][key]==fatal['state'][key]
        assert d['state']['hull']==(1 if name=='fatal' else 0)
    return len(values)


def retain(call,directory):
    read=lambda n:json.loads((directory/(n+'.json')).read_text())
    operations,terminal=read('receipts'),read('terminal')
    check(call,read,operations,terminal)
    prefix='remake-startup-'+CALLS[call][0]+'-defeat-'
    names=['startup-setup.json','fatal-setup.json']+[n+ext for n in contexts(call) for ext in ['.json','.png']]
    for name in names:shutil.copyfile(directory/name,REF/(prefix+name))
    (REF/(prefix+'receipts.json')).write_text(json.dumps({'operations':operations,'terminal':terminal},indent=2)+'\n')
    names=[prefix+n for n in names]+[prefix+'receipts.json']
    meta={'date':'2026-10-08','checkpoint':'R10u','fatalCall':call,
          'emulator':'MAME0.285 / unenhanced apple2e / owned Qt debugger',
          'scope':'Declared counter0/source startup re-entry; fatal fixture in selected actual call. No ordinary acceptance.',
          'runner':f'tools/remake/capture_startup_defeat_reference.py --fatal-call {call}',
          'terminal':terminal,
          'contexts':[{'file':prefix+n+'.json','segment':seg,'offset':hex(offset)} for n,(seg,offset) in contexts(call).items()],
          'notProven':['Fatal warp pre-entry call','Fatal Comm dispatcher','Ordinary encounter/recovery acceptance'],
          'artifacts':[{'file':n,'sha256':hashlib.sha256((REF/n).read_bytes()).hexdigest()} for n in names]}
    (REF/(prefix+'reference.json')).write_text(json.dumps(meta,indent=2)+'\n')


def verify():
    result={'status':'pass','nativeContexts':0,'artifacts':0,'milestoneStatus':'in progress','fatalCalls':[2,3]}
    for call in CALLS:
        prefix='remake-startup-'+CALLS[call][0]+'-defeat-'
        meta=json.loads((REF/(prefix+'reference.json')).read_text())
        assert meta['fatalCall']==call
        expected=2*len(contexts(call))+3
        assert len(meta['artifacts'])==len({a['file'] for a in meta['artifacts']})==expected
        for a in meta['artifacts']:
            p=REF/a['file'];assert p.parent==REF
            assert hashlib.sha256(p.read_bytes()).hexdigest()==a['sha256']
        receipts=json.loads((REF/(prefix+'receipts.json')).read_text())
        assert receipts['terminal']==meta['terminal']
        result['nativeContexts']+=check(call,lambda n:json.loads((REF/(prefix+n+'.json')).read_text()),receipts['operations'],receipts['terminal'])
        result['artifacts']+=expected
    return result


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--retain-second',type=Path);parser.add_argument('--retain-third',type=Path)
    args=parser.parse_args()
    if args.retain_second:retain(2,args.retain_second.resolve())
    if args.retain_third:retain(3,args.retain_third.resolve())
    print(json.dumps(verify(),indent=2))
