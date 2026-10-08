#!/usr/bin/env python3
"""Retain and verify the native fatal Comm-dispatch vector."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
from verify_startup_defeat_reference import REF, SIZES

PREFIX='remake-comm-defeat-'
CONTEXTS={'main':(12,0x1388),'comm-store':(12,0x1320),
          'dispatch':(13,0x2588),'fire-before':(24,0x084c),'fatal':(24,0x096a),
          'dispatch-after':(13,0x258b),'counter':(13,0x20e8),'death':(7,0x04b2)}
SIZES={**SIZES,13:0x27e4}


def check(read,operations,terminal):
    assert terminal['clean'] is True and terminal['exitCode']==0
    assert all(r['ok'] for r in operations)
    by_id={r['id']:r for r in operations};assert len(by_id)==len(operations)
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
    setup=read('comm-entry');assert setup['commandOffset']==0x1458
    assert values['comm-store']['state']['flags']['35'] is True
    dispatch=values['dispatch'];assert dispatch['state']['flags']['51'] is True
    assert dispatch['state']['words']['354']==0 and dispatch['state']['words']['352']==1
    prepared=read('fatal-setup')['after']
    assert prepared['source']['randomBytes']==[28,0,0,0]
    assert prepared['state']['hull']==1 and prepared['state']['flags']['45'] is True
    for name in ['fatal','dispatch-after','counter','death']:
        d=values[name];w=d['state']['words']
        assert tuple(w[k] for k in ['352','226','215','217','354','347'])==(2,68,40,5,0 if name in ['fatal','dispatch-after'] else 1,1)
        assert d['state']['hull']==(1 if name=='fatal' else 0)
        assert d['source']['randomBytes']==[220,15,135,195]
        assert d['state']['clock']==[18,21,0,0] and d['state']['condition']==[237,235,255,228]
        for key in ['equipment','attributes','carried','location']:
            assert d['state'][key]==values['fatal']['state'][key]
        assert d['state']['flags']['51']==(name in ['fatal','dispatch-after'])
        assert d['state']['flags']['35']==(name in ['fatal','dispatch-after'])
    assert values['death']['state']['flags']['41'] is True
    assert values['death']['state']['flags']['44'] is True
    return {'status':'pass','nativeContexts':len(values),'milestoneStatus':'in progress'}


def retain(directory):
    read=lambda n:json.loads((directory/(n+'.json')).read_text())
    operations,terminal=read('receipts'),read('terminal');check(read,operations,terminal)
    names=['comm-entry.json','fatal-setup.json']+[n+ext for n in CONTEXTS for ext in ['.json','.png']]
    for name in names:shutil.copyfile(directory/name,REF/(PREFIX+name))
    (REF/(PREFIX+'receipts.json')).write_text(json.dumps({'operations':operations,'terminal':terminal},indent=2)+'\n')
    names=[PREFIX+n for n in names]+[PREFIX+'receipts.json']
    meta={'date':'2026-10-08','checkpoint':'R10v','emulator':'MAME0.285 / unenhanced apple2e / owned Qt debugger',
          'scope':'Declared original Comm command entry, unattended Game16 timed return and prepared fatal dispatcher hit. No ordinary acceptance.',
          'runner':'tools/remake/capture_comm_defeat_reference.py','terminal':terminal,
          'contexts':[{'file':PREFIX+n+'.json','segment':seg,'offset':hex(offset)} for n,(seg,offset) in CONTEXTS.items()],
          'notProven':['Fatal warp pre-entry call','Ordinary encounter/equipment/negotiation/recovery acceptance'],
          'artifacts':[{'file':n,'sha256':hashlib.sha256((REF/n).read_bytes()).hexdigest()} for n in names]}
    (REF/(PREFIX+'reference.json')).write_text(json.dumps(meta,indent=2)+'\n')


def verify():
    meta=json.loads((REF/(PREFIX+'reference.json')).read_text())
    assert len(meta['artifacts'])==len({a['file'] for a in meta['artifacts']})==19
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
