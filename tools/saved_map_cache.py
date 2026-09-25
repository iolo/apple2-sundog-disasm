#!/usr/bin/env python3
"""Reproduce the Blackblade save tail from the shipped world-map cache writer."""
import argparse
import json
import subprocess

from disk_layout import ROOT, block_bytes, logical_sector_offset, sha
from pcode_copies import verify_ownership
from save_state_asset import PAYLOAD_SIZE, checksum
from world_map_asset import STATE_TABLE, decode_tiles, unpack_symbols

EVIDENCE = 'docs/saved-map-cache.md'
PROOF = ROOT/'src/data/evidence/saved_map_cache.json'


def modeled_tail(payload, packed_maps):
    if len(payload) != PAYLOAD_SIZE or len(packed_maps) != 18*240:
        raise ValueError('Saved payload or world-map extent differs')
    word = lambda offset: int.from_bytes(payload[offset:offset+2],'little')
    world = (word((37-36)*2)>>4)&31
    if not 1 <= world <= 18:
        raise ValueError('World identifier exceeds packed map bank')
    raw = packed_maps[(world-1)*240:world*240]
    tiles = bytes(tile for row in decode_tiles(unpack_symbols(raw)) for tile in row)
    # Game 21 replaces tile 13 by randomized variants before restoring city
    # cells. No generator result is needed for the reviewed tail, which is 12.
    if 13 in tiles[928:960]:
        raise ValueError('Selected tail requires unmodeled random terrain variants')
    world_record = 3824+(world-1)*16
    control = word(world_record+14)
    first,count = (control>>9)&63,control&7
    cities = list(range(first,first+count))
    if world == 1:
        relocate_special = word((82-36)*2+(112//16)*2)&1
        if relocate_special:
            raise ValueError('Special city relocation requires unmodeled random placement')
        cities.append(60)
    # CSP 10 clears 2,048 bytes at $5000. Decode writes the first 960, then
    # procedure 28 writes city markers and the cached world ID at offset 1000.
    cache = bytearray(2048)
    cache[:960] = tiles
    overlays = []
    for city in cities:
        if not 1 <= city <= 76:
            raise ValueError('City record exceeds saved world table')
        value = word(4112+(city-1)*12+10)
        x,y = value&63,(value>>6)&31
        if x>=40 or y>=24:
            raise ValueError('City location exceeds map buffer')
        offset = y*40+x
        cache[offset] = 13
        overlays.append(dict(city=city,x=x,y=y,cache_offset=offset,
                             affects_saved_tail=928<=offset<960))
    cache[1000] = world
    # The final explicit save copy ends at $4E00+1440 = $53A0. The ten-block
    # save extends through $53FF, retaining cache offsets 928..1023.
    report = dict(world_identifier=world,map_source_index=world-1,
                  map_payload_sha256=sha(raw),cache_base=0x5000,cleared_bytes=2048,
                  decoded_map_bytes=960,cache_identifier_offset=1000,
                  save_base=0x4000,save_bytes=5120,world_copy_destination=0x4E00,
                  world_copy_bytes=1440,retained_memory_range=[0x53A0,0x5400],
                  retained_cache_range=[928,1024],retained_save_range=[5024,5120],
                  retained_map_row=23,retained_map_columns=[8,40],city_overlays=overlays,
                  random_generator_replayed=False,full_runtime_map_reconstructed=False)
    return bytes(cache[928:1024]),report


def classify(bank, payload, maps):
    if len(bank) != 5120 or bank[:PAYLOAD_SIZE] != payload:
        raise ValueError('Save bank or classified payload differs')
    expected,report = modeled_tail(payload,maps)
    if bank[PAYLOAD_SIZE:] != expected:
        raise ValueError('Saved tail differs from map-cache producers')
    report.update(classification='data',classified_bytes=96,
                  tile_bytes=32,cache_identifier_bytes=1,cleared_storage_bytes=63,
                  tail_sha256=sha(expected),live_historical_save_trace=False)
    return report


def check_proof(proof, components, manifest):
    for component in proof['components']:
        name = component['name']
        data = components[name]
        if (sha(data) != component['sha256']
                or manifest['components'][name]['sha256'] != component['sha256']):
            raise ValueError('Reviewed map-cache producer component differs')
        for window in component['windows']:
            raw = data[window['offset']:window['offset']+window['size']]
            if raw.hex() != window['hex'] or sha(raw) != window['sha256']:
                raise ValueError('Reviewed map-cache producer window differs')
    if components['library_23'][0x6F:0xA7] != STATE_TABLE:
        raise ValueError('Native world-map transition table differs')


def run(prepare=False):
    manifest = json.loads((ROOT/'reconstruction/manifest.json').read_text())
    proof = json.loads(PROOF.read_text())
    components = {p['name']:(ROOT/'build/disks/components'/f"{p['name']}.bin").read_bytes()
                  for p in proof['components']}
    check_proof(proof,components,manifest)
    assets = {}
    for name in ('save_state_payloads','save_slot_records','world_maps'):
        spec = manifest['components'][name]
        data = (ROOT/spec['path']).read_bytes()
        if spec['kind'] != 'identified-data' or sha(data) != spec['sha256'] or len(data) != spec['size']:
            raise ValueError('Independently classified saved-state/map asset differs')
        assets[name] = data
    disk = next(d for d in manifest['disks'] if d['id']=='disk1')
    image = (ROOT/'build/disks'/disk['filename']).read_bytes()
    if sha(image) != disk['sha256']:
        raise ValueError('Rebuild exact baseline before saved-cache audit')
    bank = block_bytes(image,57,67)
    payload = assets['save_state_payloads'][3*PAYLOAD_SIZE:4*PAYLOAD_SIZE]
    result = classify(bank,payload,assets['world_maps'])
    stored_checksum = int.from_bytes(assets['save_slot_records'][3*64+30:3*64+32],'little')
    if checksum(bank) != stored_checksum:
        raise ValueError('Blackblade bank checksum differs')
    for position in range(0,PAYLOAD_SIZE,256):
        verify_ownership(manifest,[dict(disk='disk1',offset=logical_sector_offset(114+position//256),
            size=min(256,PAYLOAD_SIZE-position),input='save_state_payloads',
            input_offset=3*PAYLOAD_SIZE+position)])
    stem = ROOT/'src/data/saved_map_cache'
    output = ROOT/'build/saved-map-cache'
    output.mkdir(parents=True,exist_ok=True)
    subprocess.run(['ca65',str(stem.with_suffix('.s')),'-o',str(output/'cache.o')],check=True)
    subprocess.run(['ld65','-C',str(stem.with_suffix('.cfg')),str(output/'cache.o'),
                    '-o',str(output/'cache.bin')],check=True)
    if (output/'cache.bin').read_bytes() != bank[PAYLOAD_SIZE:]:
        raise ValueError('Named saved-cache source differs')
    recipe = dict(name='saved_map_cache',source=str(stem.with_suffix('.s').relative_to(ROOT)),
                  config=str(stem.with_suffix('.cfg').relative_to(ROOT)),
                  mappings=[dict(disk='disk1',offset=logical_sector_offset(133)+160,
                                 size=96,input_offset=0)])
    result.update(classification_evidence=EVIDENCE,disk='disk1',block=66,block_offset=416,
                  save_slot=3,save_name='Blackblade',bank_sha256=sha(bank),
                  payload_sha256=sha(payload),stored_checksum=stored_checksum,
                  producer_evidence=str(PROOF.relative_to(ROOT)))
    artifacts = {stem.with_suffix('.adopt.json'):json.dumps(recipe,indent=2)+'\n',
                 ROOT/'docs/reference/saved-map-cache.json':json.dumps(result,indent=2)+'\n'}
    for path,text in artifacts.items():
        if prepare:
            path.write_text(text)
        elif path.read_text() != text:
            raise ValueError(f'Saved-cache artifact differs: {path}')
    if not prepare:
        verify_ownership(manifest,[dict(m,input=recipe['name']) for m in recipe['mappings']])
    print(json.dumps(dict(classified_data_bytes=96,world_identifier=result['world_identifier'],
                         tile_bytes=32,cleared_bytes=63,verified=not prepare)))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--prepare',action='store_true')
    run(parser.parse_args().prepare)
