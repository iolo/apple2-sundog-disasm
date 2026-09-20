#!/usr/bin/env python3
"""Classify native footers inside existing bootstrap/title source components."""
import argparse
import json
import subprocess

from disk_layout import ROOT, sha
from native_relocations import native_relocations
from pascal_inventory import procedure_dictionary
from native_output_storage import classify_tail, check_proof, PROOF

AUDIT = ROOT/'docs/reference/early-native-footers.json'
EVIDENCE = 'docs/early-native-footers.md'
LAYOUTS = {
    'bootstrap': dict(size=768, segment_end=752, footer_start=736),
    'title_draw': dict(size=1024, segment_end=928, footer_start=912),
}


def classify(raw, name):
    layout = LAYOUTS[name]
    if len(raw) != layout['size']:
        raise ValueError('Early native component extent differs')
    end, start = layout['segment_end'], layout['footer_start']
    dictionary = procedure_dictionary(raw[:end], 1)
    if not dictionary['valid'] or dictionary['procedure_count'] != 1:
        raise ValueError('Expected one valid native procedure')
    proc = dictionary['procedures'][0]
    if (proc['representation'] != 'native-6502' or proc['entry_offset'] != 0
            or proc['lexical_level'] != 0 or proc['attribute_offset'] != start+10
            or proc['dictionary_offset'] != start+12):
        raise ValueError('Native entry/attribute/dictionary relationship differs')
    relocations = native_relocations(raw[:end], proc)
    if relocations['tables_start'] != start or any(g['count'] for g in relocations['groups']):
        raise ValueError('Native relocation fields differ')
    items = [dict(offset=g['count_offset'], size=2, classification='data',
                  kind='native-relocation-count-'+g['kind'], value=0)
             for g in reversed(relocations['groups'])]
    items += [dict(offset=start+8, size=2, classification='data', kind='native-entry-displacement', value=start+8),
              dict(offset=start+10, size=2, classification='data', kind='native-attributes'),
              dict(offset=start+12, size=2, classification='data', kind='procedure-dictionary-pointer', value=2),
              dict(offset=start+14, size=2, classification='data', kind='segment-trailer')]
    unresolved = []
    if name == 'bootstrap':
        if any(raw[end:]):
            raise ValueError('Nonzero bootstrap allocation storage needs independent review')
        items.append(dict(offset=end, size=len(raw)-end, classification='data',
                          kind='zero-storage-to-three-page-loader-boundary'))
    else:
        check_proof(json.loads(PROOF.read_text()))
        classify_tail(raw, name)
        items += [dict(offset=end, size=1023-end, classification='data',
                       kind='cleared-native-output-buffer-storage'),
                  dict(offset=1023, size=1, classification='data',
                       kind='retained-uncleared-output-buffer-byte', value=4)]
    return dict(name=name, **layout, dictionary=dictionary, relocations=relocations,
                items=items, newly_classified_data_bytes=sum(i['size'] for i in items),
                remaining_provisional_ranges=unresolved)


def run(verify=False):
    manifest = json.loads((ROOT/'reconstruction/manifest.json').read_text())
    output = ROOT/'build/early-native-footers'
    output.mkdir(parents=True, exist_ok=True)
    records = []
    for name in LAYOUTS:
        spec = manifest['components'][name]
        if spec['kind'] != 'ca65-source':
            raise ValueError('Expected existing native source component')
        obj, binary = output/(name+'.o'), output/(name+'.bin')
        subprocess.run(['ca65', str(ROOT/spec['source']), '-o', str(obj)], check=True)
        subprocess.run(['ld65', '-C', str(ROOT/spec['config']), str(obj), '-o', str(binary)], check=True)
        raw = binary.read_bytes()
        if len(raw) != spec['size'] or sha(raw) != spec['sha256']:
            raise ValueError('Early source component changed its exact bytes')
        records.append(dict(classify(raw, name), source=spec['source'], sha256=sha(raw)))
    report = dict(classification_evidence=EVIDENCE, records=records,
                  newly_classified_data_bytes=sum(r['newly_classified_data_bytes'] for r in records),
                  source_ownership_bytes_changed=0)
    text = json.dumps(report, indent=2)+'\n'
    if verify:
        if AUDIT.read_text() != text:
            raise ValueError('Early footer audit differs')
    else:
        AUDIT.write_text(text)
    print(json.dumps(dict(data_bytes=report['newly_classified_data_bytes'], verified=verify)))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--verify', action='store_true')
    run(parser.parse_args().verify)
