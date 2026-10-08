#!/usr/bin/env python3
"""Retain and verify the declared fatal first-startup-call native vector."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil

ROOT=Path(__file__).resolve().parents[2]
REF=ROOT/'docs/reference'
PREFIX='remake-startup-defeat-'
CONTEXTS={'main':(12,0x1388),'startup-first':(12,0x0655),
          'fire-before':(24,0x084c),'fatal':(24,0x096a),
          'startup-first-after':(12,0x0658),'startup-second-after':(12,0x06c7),
          'startup-third-after':(12,0x0752),'menu-before':(12,0x0f19),
          'menu-after':(12,0x0f2b),'first-main':(12,0x1388),
          'main-exit-check':(12,0x14cc),'death':(7,0x04b2)}
SIZES={12:0x15a8,24:0x10d0,7:0x074a}


def check(read,operations,terminal):
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
    values={n:read(n) for n in CONTEXTS}
    for name,(segment,offset) in CONTEXTS.items():
        src=values[name]['source']
        assert src['vm']['ip']-src['vm']['segment']+SIZES[segment]==offset,name
        assert src['status']['driver']=='apple2e' and src['status']['version']=='0.285'
        assert src['status']['debugger']=='stop' and src['status']['paused'] is True
        assert src['cpu']['PC']==0xd293
    setup=read('startup-setup')
    assert setup['wordEdits']=={'354':0} and setup['commandOffset']==0x1381
    first=values['startup-first'];fatal=values['fatal'];death=values['death']
    assert first['state']['words']['354']==0 and first['state']['words']['352']==1
    assert read('fatal-setup')['after']['source']['randomBytes']==[28,0,0,0]
    vectors={'fatal':(2,68,40,0),'startup-first-after':(2,68,40,0),
             'startup-second-after':(3,60,36,0),'startup-third-after':(4,60,32,0),
             'menu-before':(4,60,32,0),'menu-after':(4,60,31,0),
             'first-main':(4,60,31,0),'main-exit-check':(4,60,30,1),'death':(1,52,26,0)}
    for name,vector in vectors.items():
        d=values[name];w=d['state']['words']
        assert tuple(w[k] for k in ['352','226','215','354'])==vector,name
        assert w['347']==1 and w['217']==5
        assert d['source']['randomBytes']==[220,15,135,195]
        assert d['state']['clock']==([19,21,0,0] if name=='death' else [18,21,0,0])
        assert d['state']['condition']==[237,235,255,228]
        for key in ['equipment','attributes','carried','location']:
            assert d['state'][key]==fatal['state'][key]
    assert fatal['state']['hull']==1 and death['state']['hull']==0
    return {'status':'pass','nativeContexts':len(values),
            'scope':'declared counter0 startup re-entry; fatal first call through death dispatch',
            'milestoneStatus':'in progress'}


def retain(directory):
    read=lambda n:json.loads((directory/(n+'.json')).read_text())
    operations,terminal=read('receipts'),read('terminal')
    check(read,operations,terminal)
    names=['startup-setup.json','fatal-setup.json']+[n+ext for n in CONTEXTS for ext in ['.json','.png']]
    for name in names:shutil.copyfile(directory/name,REF/(PREFIX+name))
    (REF/(PREFIX+'receipts.json')).write_text(json.dumps({'operations':operations,'terminal':terminal},indent=2)+'\n')
    names=[PREFIX+n for n in names]+[PREFIX+'receipts.json']
    metadata={'date':'2026-10-08','checkpoint':'R10t','emulator':'MAME0.285 / unenhanced apple2e / owned Qt debugger',
              'scope':'Declared existing-main startup re-entry, counter0 and fatal hit; no ordinary encounter or fresh-character acceptance.',
              'runner':'tools/remake/capture_startup_defeat_reference.py','terminal':terminal,
              'contexts':[{'file':PREFIX+n+'.json','segment':seg,'offset':hex(offset)} for n,(seg,offset) in CONTEXTS.items()],
              'notProven':['Fatal warp pre-entry call','Fatal second/third startup call by a native capture','Fatal Comm dispatcher','Ordinary encounter/recovery acceptance'],
              'artifacts':[{'file':n,'sha256':hashlib.sha256((REF/n).read_bytes()).hexdigest()} for n in names]}
    (REF/(PREFIX+'reference.json')).write_text(json.dumps(metadata,indent=2)+'\n')


def verify():
    meta=json.loads((REF/(PREFIX+'reference.json')).read_text())
    assert len(meta['artifacts'])==27 and len({a['file'] for a in meta['artifacts']})==27
    for a in meta['artifacts']:
        p=REF/a['file'];assert p.parent==REF
        assert hashlib.sha256(p.read_bytes()).hexdigest()==a['sha256']
    receipts=json.loads((REF/(PREFIX+'receipts.json')).read_text())
    assert receipts['terminal']==meta['terminal']
    result=check(lambda n:json.loads((REF/(PREFIX+n+'.json')).read_text()),receipts['operations'],receipts['terminal'])
    result['artifacts']=len(meta['artifacts']);return result


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--retain',type=Path)
    args=parser.parse_args()
    if args.retain:retain(args.retain.resolve())
    print(json.dumps(verify(),indent=2))
