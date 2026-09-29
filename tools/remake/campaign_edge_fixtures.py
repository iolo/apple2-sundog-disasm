#!/usr/bin/env python3
"""Prepare valid depleted-condition imports after campaign_smoke.js exports a game."""
import json
from pathlib import Path

folder=Path(__file__).resolve().parents[2]/'output/playwright/remake'
raw=(folder/'campaign-export.json').read_text()
for name,condition in [
    ('exhaustion',dict(vigor=128,rest=1,health=180,nourishment=200)),
    ('death',dict(vigor=1,rest=1,health=1,nourishment=1)),
]:
    value=json.loads(raw)
    assert value['format']=='sundog-campaign' and value['scope']=='landed-rooms-1'
    value['state']['ship']['condition']=condition
    value['state']['ship']['minutes']=59
    (folder/f'campaign-{name}.json').write_text(json.dumps(value)+'\n')
print('2 campaign condition imports written; creation records unchanged')
