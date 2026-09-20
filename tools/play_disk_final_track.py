#!/usr/bin/env python3
"""Audit sector-image fill against a separately preserved non-sector track."""
import argparse
import json
from pathlib import Path
import subprocess
import tempfile

from disk_layout import ROOT, DOS_TO_PHYSICAL, BLOCK_ORDER, block_bytes, sha
from pascal_inventory import parse_header, procedure_dictionary

EVIDENCE = ROOT / 'src/data/evidence/play_disk_final_track.json'


def reference_track(evidence):
    ref = evidence['nibble_reference']
    if (ref['track_number'], ref['track_size'], ref['fill']) != (34, 6656, 255):
        raise ValueError('Unexpected raw-track geometry')
    track = bytearray([255] * 6656)
    seen = set()
    for item in ref['nonfill_bytes']:
        offset, value = item['offset'], item['value']
        if offset in seen or not 0 <= offset < 6656 or not 0 <= value < 255:
            raise ValueError('Invalid sparse track record')
        seen.add(offset)
        track[offset] = value
    if sha(track) != ref['track_sha256']:
        raise ValueError('Raw-track reference differs')
    circular = track + track[:2]
    if any(bytes.fromhex(marker) in circular for marker in ('d5aa96', 'd5aaad')):
        raise ValueError('Reference has a standard sector marker')
    return bytes(track)


def classify(image, evidence):
    if len(image) != 143360:
        raise ValueError('Expected the complete 35-track sector image')
    track = reference_track(evidence)
    entries = [e for e in parse_header(block_bytes(image, 140, 141))
               if e['relative_block'] and e['length']]
    ends = [140 + e['relative_block'] + (e['length'] + 511) // 512 for e in entries]
    last = [e for e in entries if e['segment_number'] == 21]
    if (max(ends) != 272 or len(last) != 1
            or (last[0]['relative_block'], last[0]['length']) != (116, 8132)):
        raise ValueError('Final declared segment boundary differs')
    allocation = block_bytes(image, 256, 272)
    if sha(allocation) != evidence['final_segment']['allocation_sha256']:
        raise ValueError('Independently matched neighboring tracks differ')
    procedures = procedure_dictionary(allocation[:8132], 21)
    if procedures['procedure_count'] != 41 or not procedures['valid']:
        raise ValueError('Final segment dictionary differs')
    tail = image[139264:]
    if any(tail) or sha(tail) != evidence['sha256']:
        raise ValueError('Final sector-image track is not the reviewed zero fill')
    return dict(classification='data',kind=evidence['kind'],offset=139264,size=4096,
                sha256=sha(tail),preceding_segment=21,preceding_procedures=41,
                raw_reference_track_sha256=sha(track),standard_sector_markers=0)


def verify_external(image, evidence, nibble, clean):
    ref = evidence['nibble_reference']
    raw = nibble.read_bytes()
    if len(raw) != ref['size'] or sha(raw) != ref['sha256']:
        raise ValueError('External nibble image differs')
    if raw[-6656:] != reference_track(evidence):
        raise ValueError('External final-track excerpt differs')
    decoded = subprocess.run(['a2kit','get','-t','sec','-f','0..34,0,0..16',
                              '-d',str(nibble)],check=True,capture_output=True).stdout
    if len(decoded) != 34*4096 or sha(decoded) != ref['readable_tracks_physical_sector_order_sha256']:
        raise ValueError('Decoded historical sectors differ')
    matches, different, tracks, blocks = 0, 0, set(), {}
    for track in range(34):
        for sector in range(16):
            start = track*4096+sector*256
            target = track*4096+DOS_TO_PHYSICAL.index(sector)*256
            count = sum(a != b for a,b in zip(decoded[start:start+256],image[target:target+256]))
            matches += count == 0
            different += count
            if count:
                tracks.add(track)
                block = (track*16+BLOCK_ORDER.index(DOS_TO_PHYSICAL.index(sector)))//2
                blocks[str(block)] = blocks.get(str(block),0)+count
    if (matches,different,sorted(tracks)) != (532,378,[6]):
        raise ValueError('Historical-to-current sector correspondence differs')
    if blocks != ref['different_bytes_by_logical_block']:
        raise ValueError('Historical working-state difference locations changed')
    failure = subprocess.run(['a2kit','get','-t','sec','-f','34,0,0','-d',str(nibble)],capture_output=True)
    if failure.returncode == 0 or failure.stdout or b'SectorNotFound' not in failure.stderr:
        raise ValueError('Expected the observed missing standard sector')
    if clean:
        other = clean.read_bytes()
        if sha(other) != evidence['clean_dsk_reference']['sha256'] or len(other) != len(image):
            raise ValueError('Clean-crack reference differs')
        if other[32*4096:] != image[32*4096:]:
            raise ValueError('Independent sector-image ending differs')
    return dict(matching_sectors=matches,different_bytes=different,different_tracks=sorted(tracks),
                different_bytes_by_logical_block=blocks,
                final_standard_sector_read='SectorNotFound',clean_reference_checked=bool(clean))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--external-nib',type=Path)
    parser.add_argument('--external-clean',type=Path)
    parser.add_argument('--output',type=Path)
    args = parser.parse_args()
    if args.external_clean and not args.external_nib:
        parser.error('--external-clean requires --external-nib')
    evidence = json.loads(EVIDENCE.read_text())
    image = (ROOT/'build/disks/sundog-disk2-util.dsk').read_bytes()
    report = classify(image,evidence)
    if args.external_nib:
        report['external_verification'] = verify_external(image,evidence,args.external_nib,args.external_clean)
    with tempfile.TemporaryDirectory(prefix='sundog-final-track-') as directory:
        obj, binary = Path(directory)/'fill.o',Path(directory)/'fill.bin'
        subprocess.run(['ca65',str(ROOT/'src/data/play_disk_final_track.s'),'-o',str(obj)],check=True)
        subprocess.run(['ld65','-C',str(ROOT/'src/data/play_disk_final_track.cfg'),str(obj),'-o',str(binary)],check=True)
        if binary.read_bytes() != image[139264:]:
            raise ValueError('Freshly assembled container fill differs')
    report['fresh_assembly_verified'] = True
    formatted = json.dumps(report,indent=2)+'\n'
    if args.output:
        args.output.write_text(formatted)
    print(formatted,end='')


if __name__ == '__main__':
    main()
