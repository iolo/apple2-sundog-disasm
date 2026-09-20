#!/usr/bin/env python3
"""Prepare custom dialogue script source and separately extracted message data."""
import argparse
import json
import subprocess

from dialogue_dictionary_asset import text_fields, text_bytes
from dialogue_script import analyze_bank, macro_source
from disk_layout import ROOT, block_bytes, logical_sector_offset, sha


def prepare():
    source_dir,asset_dir = ROOT/'src/dialogue',ROOT/'assets/dialogue-messages'
    audit_path = ROOT/'docs/reference/dialogue-scripts.json'
    if source_dir.exists() or asset_dir.exists() or audit_path.exists():
        raise ValueError('Dialogue outputs already exist')
    evidence = 'docs/dialogue-scripts.md'
    if not (ROOT/evidence).is_file():
        raise ValueError('Missing dialogue script evidence')
    manifest = json.loads((ROOT/'reconstruction/manifest.json').read_text())
    disk = next(d for d in manifest['disks'] if d['id']=='disk2')
    image = (ROOT/'build/disks'/disk['filename']).read_bytes()
    if sha(image)!=disk['sha256']:
        raise ValueError('Rebuild baseline before preparation')
    source_bytes,asset_bytes = bytearray(),bytearray()
    source_maps,asset_maps,audits,fields = [],[],[],[]
    lines = ['; Evidence: docs/dialogue-scripts.md', '.include "encoding.inc"',
             '.segment "DIALOGUE"']

    def append(bank,block,start,end,data,mappings):
        base = len(data)
        cursor = start
        while cursor<end:
            offset = logical_sector_offset(block*2+cursor//256)+cursor%256
            size = min(end-cursor,256-cursor%256)
            owners = [r for r in disk['regions'] if r['offset']<=offset and offset+size<=r['offset']+r['size']]
            if len(owners)!=1 or manifest['components'][owners[0]['input']]['kind']!='temporary-unresolved':
                raise ValueError(f'Dialogue range overlaps reconstructed bytes: {block}:{cursor}')
            mappings.append(dict(disk='disk2',offset=offset,size=size,input_offset=base+cursor-start))
            cursor += size
        data.extend(bank[start:end])

    for block in range(90,103):
        bank = block_bytes(image,block,block+1)
        audit = analyze_bank(bank)
        audit.update(block=block,bank_sha256=sha(bank))
        audits.append(audit)
        lines += ['',f'; Disk 2 block {block}; offsets below are bank-relative.']
        for record in audit['records']:
            lines.append(f'b{block}_offset_{record["start"]:03x} = ${record["start"]:02X}')
        for text in audit['text_records']:
            lines.append(f'b{block}_text_{text["offset"]:03x} = ${text["offset"]:03X}')
        # Byte zero in the twelve supplemented banks was adopted as dictionary
        # metadata in 07p. Its dual role as entry zero is retained in the audit.
        first = 1 if bank[0]==18 else 0
        lines += [f'; Entry table bytes {first}–15; zero means no stored entry.']
        for index in range(first,16):
            target = bank[index]
            value = f'b{block}_offset_{target:03x}' if target else '0'
            lines.append(f'    d_entry {value} ; slot {index}')
        append(bank,block,first,16,source_bytes,source_maps)
        for record in audit['records']:
            lines += ['',f'b{block}_record_{record["start"]:03x}:']
            context = None
            for item in record['units']:
                op,args = item['operation'],item['operands']
                if op.startswith('text_'):context='text'
                elif op.startswith('state_'):context='state'
                rendered = [f'${n:02X}' for n in args]
                if op=='say' or (context=='text' and op in ('value','test','default')):
                    rendered[0] = f'b{block}_text_{args[0]*2:03x}/2'
                lines.append('    d_'+op+(' '+', '.join(rendered) if args else '')+f' ; +${item["offset"]:03X}')
            lines.append(f'; End +${record["end"]:03X}'+(' (EXIT from interpreter procedure)' if record['early_exit'] else ''))
            append(bank,block,record['start'],record['end'],source_bytes,source_maps)
        for text in audit['text_records']:
            start,length = text['offset'],text['length']
            raw = bank[start+1:start+1+length]
            field = dict(block=block,bank_offset=start,input_offset=len(asset_bytes),
                         length=length,alignment_bytes=text['alignment_bytes'],**text_fields(raw))
            if text_bytes(field)!=raw:
                raise ValueError('Dialogue message text does not round trip')
            fields.append(field)
            append(bank,block,start,text['end'],asset_bytes,asset_maps)
    config = (f'MEMORY {{ IMAGE: start = $0000, size = {len(source_bytes)}, file = %O; }}\n'
              'SEGMENTS { DIALOGUE: load = IMAGE, type = ro; }\n')
    scratch = ROOT/'build/dialogue-preparation'
    scratch.mkdir(parents=True,exist_ok=True)
    source = '\n'.join(lines)+'\n'
    (scratch/'scripts.s').write_text(source)
    (scratch/'encoding.inc').write_text(macro_source())
    (scratch/'scripts.cfg').write_text(config)
    subprocess.run(['ca65','-I',str(scratch),str(scratch/'scripts.s'),'-o',str(scratch/'scripts.o')],check=True)
    subprocess.run(['ld65','-C',str(scratch/'scripts.cfg'),str(scratch/'scripts.o'),'-o',str(scratch/'scripts.bin')],check=True)
    if (scratch/'scripts.bin').read_bytes()!=source_bytes:
        raise ValueError('Dialogue source assembly differs')
    summary = dict(classification_evidence=evidence,banks=audits,
                   script_record_count=sum(len(a['records']) for a in audits),
                   script_bytes=sum(r['end']-r['start'] for a in audits for r in a['records']),
                   entry_table_bytes=196,source_bytes=len(source_bytes),source_sha256=sha(source_bytes),
                   message_count=len(fields),message_bytes=len(asset_bytes),message_sha256=sha(asset_bytes),
                   excluded='Unvisited bank gaps/tails and any unreferenced messages remain unresolved')
    source_recipe = dict(name='dialogue_scripts',source='src/dialogue/scripts.s',
                         config='src/dialogue/scripts.cfg',mappings=source_maps)
    asset_recipe = dict(name='dialogue_messages',data='assets/dialogue-messages/messages.bin',
                        format='Counted word-aligned dialogue text with dictionary/glyph substitution tokens',
                        classification=evidence,mappings=asset_maps)
    source_dir.mkdir(parents=True)
    asset_dir.mkdir(parents=True)
    for filename,value in [('scripts.s',source),('scripts.cfg',config),('encoding.inc',macro_source())]:
        (source_dir/filename).write_text(value)
    (asset_dir/'messages.bin').write_bytes(asset_bytes)
    for path,value in [(source_dir/'scripts.adopt.json',source_recipe),(asset_dir/'adopt.json',asset_recipe),
                       (asset_dir/'fields.json',fields),(asset_dir/'manifest.json',
                        {k:v for k,v in summary.items() if k!='banks'}),(audit_path,summary)]:
        path.write_text(json.dumps(value,indent=2)+'\n')
    print(json.dumps({k:v for k,v in summary.items() if k not in ('banks','excluded','classification_evidence')}))


def verify():
    folder = ROOT/'assets/dialogue-messages'
    data = (folder/'messages.bin').read_bytes()
    fields = json.loads((folder/'fields.json').read_text())
    manifest = json.loads((folder/'manifest.json').read_text())
    packed = bytearray()
    for record in fields:
        raw = text_bytes(record)
        if record['input_offset']!=len(packed) or len(raw)!=record['length']:
            raise ValueError('Message extent differs')
        packed.append(len(raw))
        packed.extend(raw)
        alignment = (len(raw)+1)&1
        if alignment!=record['alignment_bytes']:
            raise ValueError('Message alignment differs')
        packed.extend(bytes(alignment))
    if packed!=data or sha(data)!=manifest['message_sha256'] or len(data)!=manifest['message_bytes']:
        raise ValueError('Message encoding differs')
    audit = json.loads((ROOT/'docs/reference/dialogue-scripts.json').read_text())
    image = (ROOT/'build/disks/sundog-disk2-util.dsk').read_bytes()
    reconstruction = json.loads((ROOT/'reconstruction/manifest.json').read_text())
    disk = next(d for d in reconstruction['disks'] if d['id']=='disk2')
    if sha(image)!=disk['sha256']:
        raise ValueError('Rebuild baseline before checking script audit')
    for recorded in audit['banks']:
        block = recorded['block']
        bank = block_bytes(image,block,block+1)
        actual = analyze_bank(bank)
        actual.update(block=block,bank_sha256=sha(bank))
        if actual!=recorded:
            raise ValueError('Script decoder differs from recorded bank audit')
    if (ROOT/'src/dialogue/encoding.inc').read_text()!=macro_source():
        raise ValueError('Committed script macros differ from reviewed encoding')
    print(f'Verified {len(fields)} dialogue messages and {len(data)} bytes')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--verify',action='store_true')
    args = parser.parse_args()
    verify() if args.verify else prepare()
