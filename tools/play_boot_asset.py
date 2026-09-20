#!/usr/bin/env python3
"""Extract and verify the play disk's four-plane compressed boot notice."""
import argparse
import json
from pathlib import Path

from disk_layout import ROOT, block_bytes, logical_sector_offset, sha
from hgr_asset import preview
from packed_hgr_asset import decode, encode


def extract(output):
    output = output.resolve()
    relative = output.relative_to(ROOT)
    if output.exists():
        raise ValueError('Boot notice output already exists')
    manifest = json.loads((ROOT/'reconstruction/manifest.json').read_text())
    disk = next(d for d in manifest['disks'] if d['id'] == 'disk2')
    image = (ROOT/'build/disks'/disk['filename']).read_bytes()
    if sha(image) != disk['sha256']:
        raise ValueError('Rebuild current baseline before extraction')
    loaded = block_bytes(image,0,3)[256:]
    page, packets, consumed = decode(loaded)
    raw = loaded[:consumed]
    if packets['stride'] != 4 or consumed != 576 or encode(packets) != raw:
        raise ValueError('Boot stream differs from reviewed native decoder extent')
    mappings = []
    for position in range(0,consumed,256):
        offset = logical_sector_offset(1+position//256)
        size = min(256,consumed-position)
        owners = [r for r in disk['regions'] if r['offset'] <= offset and offset+size <= r['offset']+r['size']]
        if len(owners) != 1 or manifest['components'][owners[0]['input']]['kind'] != 'temporary-unresolved':
            raise ValueError('Boot notice overlaps reconstructed bytes')
        mappings.append(dict(disk='disk2',offset=offset,size=size,input_offset=position))
    report = dict(classification='data',format='sundog-stride4-rle-hgr',
                  classification_evidence='docs/play-disk-boot.md',
                  disk='disk2',logical_byte_offset=256,size=consumed,sha256=sha(raw),
                  decoded_size=len(page),decoded_sha256=sha(page),
                  packet_count=len(packets['packets']),consumer='Native boot decoder $0812–$0896',
                  inverse='encode(packets.json) reproduces image.rle exactly',
                  preview_note='Monochrome HGR preview; raw stream retains all bits')
    recipe = dict(name='play_boot_notice',data=str(relative/'image.rle'),
                  format=report['format'],classification=report['classification_evidence'],mappings=mappings)
    output.mkdir(parents=True)
    (output/'image.rle').write_bytes(raw)
    (output/'decoded.hgr').write_bytes(page)
    for name,value in [('packets.json',packets),('manifest.json',report),('adopt.json',recipe)]:
        (output/name).write_text(json.dumps(value,indent=2)+'\n')
    preview(page,output/'monochrome.png')
    print(f'Extracted {consumed} compressed boot-notice bytes')


def verify(output):
    raw = (output/'image.rle').read_bytes()
    page, packets, consumed = decode(raw)
    report = json.loads((output/'manifest.json').read_text())
    if (consumed != len(raw) or len(raw) != report['size'] or sha(raw) != report['sha256']
            or sha(page) != report['decoded_sha256'] or page != (output/'decoded.hgr').read_bytes()
            or packets != json.loads((output/'packets.json').read_text()) or encode(packets) != raw):
        raise ValueError('Boot notice bytes/packets/decoded page differ')
    print('Verified 576 compressed bytes and 8,192 decoded HGR bytes')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--extract',type=Path)
    group.add_argument('--verify',type=Path)
    args = parser.parse_args()
    extract(args.extract) if args.extract else verify(args.verify)
