#!/usr/bin/env python3
"""Project reviewed component classifications onto every mapped disk byte.

This ledger integrates existing audits; it does not infer data from assembler
directives, filenames, or a successful build. Unsupported audit families remain
explicitly pending, separately from the temporary unidentified disk regions.
"""
import argparse
from collections import Counter
import json
import re

from build_disks import build, compose_image, contained_file, validate_data_assumptions
from disk_layout import ROOT, sha, block_bytes
from native_pascal_source import mixed_decoder, instruction
from native_raw_source import analyze as analyze_raw
from pascal_inventory import procedure_dictionary
from pcode_source import analyze, analyze_fragment, verify_interpreter
from storage_encoding import transform
from system_core_source import analyze_system, CORE_SIZE

MANIFEST = ROOT/'reconstruction/manifest.json'
REPORT = ROOT/'docs/reference/classification-ledger.json'
CODE, DATA, TEMPORARY, PENDING, ASSUMED = range(1, 6)
LABELS = {CODE:'code', DATA:'data', TEMPORARY:'temporary-unresolved',
          PENDING:'audit-not-integrated', ASSUMED:'user-assumed-data'}
DATA_KINDS = set('''alignment attributes case-pointer dictionary-pointer
entry-pointer exit-pointer jump-pointer local-size parameter-size segment-trailer
string-data packed-array-data relocation-count relocation-pointer
native-address-high-table native-address-low-table native-alignment
native-attributes native-code-pointer native-division-table native-entry-pointer
native-lookup-table native-mask-table native-pixel-index-table
native-pixel-pattern-table native-state-array native-state-byte native-state-word
native-table-continuation'''.split())
RAW_NAMES = ('raw_screen_init', 'raw_buffer_transform', 'certificate_reveal',
             'warp_animation', 'viewscreen_transition', 'viewscreen_io',
             'disk_checksum', 'play_boot', 'encoded_disk_reader')
# Individually reviewed data-only sources. Directory placement or .byte/.res
# syntax is never used to infer membership in this registry.
DATA_SOURCES = {
    'pascal_header_tables':'pascal-header-tables',
    'pascal_directories':'pascal-directories',
    'pascal_header_extensions':'pascal-header-extensions',
    'asset_block_storage':'asset-block-storage',
    'retained_pascal_metadata':'retained-pascal-metadata',
    'retained_pascal_stack':'retained-pascal-stack',
    'retained_command_stack':'retained-command-stack',
    'retained_compiler_heap':'retained-compiler-heap',
    'disk_control':'disk-control',
    'play_disk_final_track':'play-disk-final-track',
    'viewscreen_output_storage':'native-output-storage',
    'bootstrap_output_storage':'native-output-storage',
    'window_allocation_tail':'window-allocation-tail',
    'dialogue_workspace':'dialogue-workspace',
    'packed_image_storage':'packed-image-storage',
    'library_text_tail':'library-text-tail',
    'saved_map_cache':'saved-map-cache',
    'encoded_reader_alignment':'encoded-disk-reader',
}


def from_items(size, items):
    """Require positive, disjoint, complete and explicitly classified extents."""
    owners = bytearray(size)
    for item in items:
        offset, length, label = item['offset'], item['size'], item['classification']
        if (type(offset) is not int or type(length) is not int
                or not 0 <= offset < offset+length <= size or label not in ('code','data')):
            raise ValueError('Invalid classification interval')
        if any(owners[offset:offset+length]):
            raise ValueError('Classification intervals overlap')
        owners[offset:offset+length] = bytes([CODE if label == 'code' else DATA])*length
    if not size or not all(owners):
        raise ValueError('Classification intervals have gaps')
    return bytes(owners)


def pcode_classes(report):
    items = []
    for item in report['items']:
        if item['kind'] in ('instruction','native-instruction'):
            label = 'code'
        elif item['kind'] in DATA_KINDS:
            label = 'data'
        else:
            raise ValueError(f"Unreviewed p-code classification kind: {item['kind']}")
        items.append(dict(offset=item['offset'],size=item['size'],classification=label))
    return from_items(report['size'],items)


def runs(owners):
    """Compact [offset, size, classification] rows, with end-exclusive extents."""
    result = []
    for offset, owner in enumerate(owners):
        label = LABELS[owner]
        if result and result[-1][2] == label:
            result[-1][1] += 1
        else:
            result.append([offset,1,label])
    return result


def counts(owners):
    histogram = Counter(owners)
    return {label:histogram[value] for value,label in LABELS.items()}


def project(disk, binaries, classifications):
    """Use the same strict byte composition as the build, including copies.

    A disk occurrence can clip a source instruction. Its surviving operand
    bytes still inherit code classification; never decode a slice in isolation.
    """
    image = compose_image(disk,binaries)
    if sha(image) != disk['sha256']:
        raise ValueError('Projected disk differs from manifest hash')
    owners = compose_image(disk,classifications)
    if any(value not in LABELS for value in owners):
        raise ValueError('Unknown projected classification')
    components, unfinished, assumed = {}, [], []
    for region in sorted(disk['regions'],key=lambda r:r['offset']):
        name, start, size = region['input'],region['input_offset'],region['size']
        selected = classifications[name][start:start+size]
        components.setdefault(name,Counter()).update(selected)
        for offset, length, label in runs(selected):
            if label not in ('code','data'):
                target = assumed if label == 'user-assumed-data' else unfinished
                target.append(dict(offset=region['offset']+offset,size=length,
                    component=name,input_offset=start+offset,classification=label))
    return dict(id=disk['id'],filename=disk['filename'],size=len(image),sha256=sha(image),
                coverage_bytes=counts(owners),
                component_coverage={n:{LABELS[k]:v for k,v in sorted(c.items())}
                                    for n,c in sorted(components.items())},
                unfinished_regions=unfinished, assumed_data_regions=assumed)


def complete(coverage):
    return coverage['temporary-unresolved'] == coverage['audit-not-integrated'] == 0


def early_native_classes(data, name):
    """Review the original two handwritten native components and their tables.

    Fixed code/data bounds come from bootstrap.md/title-draw.md and their
    reviewed source. Decode every code interval, including retained NOPs;
    complete native footers/storage are checked by the later dedicated audits.
    """
    from early_native_footers import classify
    classify(data,name)
    if name == 'bootstrap':
        base = 0x800
        code = [(1,0x9D),(0xB3,0xCF),(0xFD,0x13E),(0x14E,0x2C8)]
        data_ranges = [(0,1),(0x9D,0xB3),(0xCF,0xFD),(0x13E,0x14E),(0x2C8,0x300)]
        if (data[0] != 1 or data[0x9D:0xB3] != b'\0MUST BOOT FROM SLOT 6'
                or any(data[0xCF:0xFD]) or data[0xFD:0xFF] != b'\xea\xea'
                or data[0x13E:0x14E] != bytes(range(0,16,2))+bytes(range(1,16,2))
                or data[0x2C8:0x2E0] != bytes.fromhex(
                    '01 30 28 24 20 1e 1d 1c 1c 1c 1c 1c 70 2c 26 22 1f 1e 1d 1c 1c 1c 1c 1c')):
            raise ValueError('Bootstrap count, message, storage or disk tables differ')
        external = {0x4000,0xC65C,0xFBFD,0xFC24}
    elif name == 'title_draw':
        base = 0x4000
        code, data_ranges = [(0,0x210)],[(0x210,0x400)]
        addresses = [0x2000+(y&7)*0x400+((y>>3)&7)*0x80+(y>>6)*40 for y in range(192)]
        if data[0x210:0x390] != bytes(a&255 for a in addresses)+bytes(a>>8 for a in addresses):
            raise ValueError('Title scanline address tables differ')
        external = set()
    else:
        raise ValueError('Unreviewed early native component')
    decoded = {}
    for lo,hi in code:
        cursor = lo
        while cursor < hi:
            item = instruction(data,cursor)
            if item['mnemonic'] == 'brk' or cursor+item['size'] > hi:
                raise ValueError('Early native instruction crosses a data boundary')
            decoded[cursor] = item
            cursor += item['size']
    for offset,item in decoded.items():
        target = None
        if item['mode'] == 'Lb':
            target = base+offset+2+int.from_bytes(data[offset+1:offset+2],'little',signed=True)
        elif item['mnemonic'] in ('jsr','jmp'):
            if item['mode'] == 'In':
                if (name,offset,item['operand_value']) != ('bootstrap',0x9A,0xFFF8):
                    raise ValueError('Unexpected indirect early-native transfer')
            else:
                target = item['operand_value']
        if target is not None and target-base not in decoded and target not in external:
            raise ValueError('Early native transfer enters data or an unreviewed external target')
    return from_items(len(data),[dict(offset=lo,size=hi-lo,classification=label)
        for label,spans in [('code',code),('data',data_ranges)] for lo,hi in spans])


def report():
    manifest = json.loads(MANIFEST.read_text())
    assumptions = validate_data_assumptions(manifest)
    specs = manifest['components']
    binaries, classification, evidence = {}, {}, {}
    proof_files = set()

    def proof(path):
        file = contained_file(ROOT,path)
        proof_files.add(path)
        return file

    def read_json(path):
        return json.loads(proof(path).read_text())

    proof('tools/classification_ledger.py')
    proof('src/pcode/encoding.inc')

    def register(name, owners, paths, method):
        if name in classification:
            raise ValueError(f'Duplicate component classification: {name}')
        if len(owners) != specs[name]['size']:
            raise ValueError(f'Classification size differs: {name}')
        for path in paths:
            proof(path)
        classification[name] = owners
        evidence[name] = dict(method=method,files=paths)

    for name,spec in specs.items():
        if spec['kind'] == 'ca65-source':
            data = (ROOT/'build/disks/components'/f'{name}.bin').read_bytes()
            proof(spec['source'])
            proof(spec['config'])
        elif spec['kind'] == 'identified-data':
            data = contained_file(ROOT,spec['path']).read_bytes()
            if not spec.get('format'):
                raise ValueError('Data component lacks an identified format')
            register(name,bytes([DATA])*len(data),[spec['classification_evidence']],
                     'Existing identified-data classification; exact asset hash checked')
        elif spec['kind'] == 'temporary-unresolved':
            data = contained_file(MANIFEST.parent,spec['path']).read_bytes()
            register(name,bytes([TEMPORARY])*len(data),[], 'Unidentified temporary input')
        elif spec['kind'] == 'user-assumed-data':
            data = contained_file(ROOT,spec['path']).read_bytes()
            register(name,bytes([ASSUMED])*len(data),
                     [spec['acceptance_record'],spec['assumption_document']],
                     'Explicit user data assumption; exact accepted scope checked; no code/data proof claimed')
        else:
            raise ValueError(f'Unknown component kind: {name}')
        if len(data) != spec['size'] or sha(data) != spec['sha256']:
            raise ValueError(f'Component differs from reviewed bytes: {name}')
        binaries[name] = data

    verify_interpreter(binaries['pcode_primitives'])
    pcode = {p.stem:str(p.relative_to(ROOT))
             for p in (ROOT/'docs/reference/pcode-modules').glob('*.json')
             if p.stem not in ('system_core','library_23')}
    pcode.update(startup_disk1='docs/reference/step06g-pcode-audit.json',
                 startup_disk2='docs/reference/step06g-pcode-audit.json',
                 utility_disk1='docs/reference/step06h-pcode-audit.json')
    for name,path in sorted(pcode.items()):
        summary = read_json(path)
        data = binaries[name]
        if summary['sha256'] != sha(data) or summary['size'] != len(data):
            raise ValueError(f'P-code audit differs: {name}')
        decoder, paths = None, [path]
        if summary.get('native_evidence'):
            native_path = summary['native_evidence']
            native = read_json(native_path)
            paths.append(native_path)
            if native.get('documentation'):
                paths.append(native['documentation'])
            decoder = mixed_decoder(data,procedure_dictionary(data,summary['segment']),
                                    native['procedures'])
        for field in ('root_evidence','classification_evidence'):
            if summary.get(field):
                paths.append(summary[field])
        result = analyze(data,summary['segment'],native_decoder=decoder,
                         extra_code_roots=summary.get('extra_code_roots',[]))
        if result['coverage_bytes'] != summary['coverage_bytes']:
            raise ValueError(f'P-code audit coverage differs: {name}')
        register(name,pcode_classes(result),paths,'Replayed complete procedure-aware decoder')

    path = 'docs/reference/pcode-modules/system_core.json'
    summary = read_json(path)
    joined = binaries['system_entry']+binaries['system_core']
    result = analyze_system(joined[:CORE_SIZE],joined[CORE_SIZE:],
                            extra_code_roots=summary['extra_code_roots'])
    if sha(joined) != summary['sha256'] or result['coverage_bytes'] != summary['coverage_bytes']:
        raise ValueError('Split-system audit differs')
    owners = pcode_classes(result)
    register('system_entry',owners[:36],[path],'Replayed split-system procedure decoder')
    register('system_core',owners[36:],[path],'Replayed split-system procedure decoder')

    from check_library23 import audit as audit_library23
    path = 'docs/reference/pcode-modules/library_23.json'
    summary = read_json(path)
    result = audit_library23(binaries['library_23'])
    if result['coverage_bytes'] != summary['coverage_bytes'] or result['sha256'] != summary['sha256']:
        raise ValueError('Library-23 audit differs')
    items = [dict(offset=r['offset'],size=r['size'],classification=
             'code' if r['kind'] in ('p-code-instruction','native-instructions') else 'data')
             for r in result['code_data_regions']]
    register('library_23',from_items(606,items),[path], 'Replayed mixed library-23 audit')

    for name in RAW_NAMES:
        path = f'src/native/evidence/{name}.json'
        recipe = read_json(path)
        data = binaries[name]
        if recipe['sha256'] != sha(data):
            raise ValueError(f'Raw-native recipe differs: {name}')
        if recipe.get('storage_encoding') != specs[name].get('storage_encoding'):
            raise ValueError('Raw-native storage encoding differs')
        if recipe.get('storage_encoding'):
            data = transform(data,recipe['storage_encoding'],decode=True)
        result = analyze_raw(data,recipe['base'],recipe)
        audit_path = f'docs/reference/raw-modules/{name}.json'
        summary = read_json(audit_path)
        if result['sha256'] != summary['sha256'] or result['items'] != summary['items']:
            raise ValueError(f'Raw-native audit differs: {name}')
        register(name,from_items(len(data),result['items']),
                 [path,audit_path,recipe['classification_evidence']],
                 'Replayed native control-flow/data decoder')

    # These special bytes are instruction fragments/overlap prefixes already
    # resolved by the runtime audits. Complete code spans alone omit them.
    import runtime_classification
    from check_native_io import OVERLAPS
    runtime = json.loads(json.dumps(runtime_classification.report()))
    runtime_path = 'docs/reference/runtime-classification.json'
    if runtime != read_json(runtime_path):
        raise ValueError('Resident-runtime audit differs')
    bases = dict(pcode_primitives=0xD000,native_io=0xD000,native_shared=0xE0E5,
                 native_init=0x6800,native_high=0xF790)
    extras = dict(native_io=[a-0xD000 for a in OVERLAPS],native_init=[0x195],native_high=[0x10])
    for row in runtime['components']:
        name = row['component']
        owners = bytearray([DATA])*row['size']
        for lo,hi in row['code_spans_end_exclusive']:
            start,end = lo-bases[name],hi-bases[name]
            if not 0 <= start < end <= len(owners):
                raise ValueError('Runtime code span outside component')
            owners[start:end] = bytes([CODE])*(end-start)
        for offset in extras.get(name,[]):
            if owners[offset] != DATA:
                raise ValueError('Special runtime code byte already counted')
            owners[offset] = CODE
        if owners.count(CODE) != row['code_bytes'] or owners.count(DATA) != row['data_bytes']:
            raise ValueError('Runtime span/fragment totals differ')
        register(name,bytes(owners),[runtime_path]+row['classification_documents'],
                 'Replayed complete resident-runtime audits, including fragments and overlaps')

    for name,document in DATA_SOURCES.items():
        register(name,bytes([DATA])*specs[name]['size'],[f'docs/{document}.md'],
                 'Explicitly reviewed data-only source; exact assembly and evidence hashes checked')

    from encoded_bank_completion import prepare as verify_encoded_banks
    verify_encoded_banks(verify=True)
    path = 'docs/reference/encoded-bank-completion.json'
    bank_report = read_json(path)
    banks = {r['variant']:from_items(2048,r['byte_classification_runs'])
             for r in bank_report['records']}
    for name,spec in specs.items():
        match = re.fullmatch(r'encoded_(?:loader|body|tail|retained|symbols)_(play|alternate)(?:_[0-9a-f]{4})?',name)
        if not match:
            continue
        variant = match[1]
        encoding = spec['storage_encoding']
        start, end = encoding['offset'],encoding['offset']+spec['size']
        if not 0 <= start < end <= 2048:
            raise ValueError('Encoded component exceeds classified bank')
        register(name,banks[variant][start:end],[path,bank_report['classification_evidence'],
                 encoding['evidence']], 'Replayed complete encoded-bank audit; projected phased source slice')

    for name in ('bootstrap','title_draw'):
        register(name,early_native_classes(binaries[name],name),
                 ['docs/bootstrap.md' if name == 'bootstrap' else 'docs/title-draw.md',
                  'docs/early-native-footers.md','docs/native-output-storage.md',
                  'docs/reference/assembler-buffer-evidence.json'],
                 'Reviewed native intervals, decoded branches, consumed tables and replayed footer audit')

    from utility_variant_source import prepare as verify_variant
    from utility_variant_edges import prepare as verify_edges
    verify_variant(verify=True)
    verify_edges(verify=True)
    path = 'docs/reference/utility-variant-procedures.json'
    summary = read_json(path)
    result = analyze_fragment(binaries['utility_variant_procedures'],1,
                             [p['attribute_offset'] for p in summary['procedures']])
    if result['sha256'] != summary['sha256'] or result['coverage_bytes'] != summary['coverage_bytes']:
        raise ValueError('Utility variant audit differs')
    register('utility_variant_procedures',pcode_classes(result),
             [path,'docs/utility-variant-procedures.md'], 'Replayed retained complete procedures and context audit')
    path = 'docs/reference/utility-variant-edges.json'
    summary = read_json(path)
    register('utility_variant_edges',from_items(16,[
        dict(offset=r['input_offset'],size=r['size'],classification=r['classification'])
        for r in summary['records']]),[path,summary['classification_evidence']],
        'Replayed changed instruction/footer contexts; disk mappings select only changed bytes')

    from retained_linker import review
    path = 'src/pcode/evidence/retained_linker.json'
    raw, decoded, _, _ = review(read_json(path))
    owners = pcode_classes(decoded)
    for name,lo,hi in [('retained_linker',454,756),('retained_linker_prompt',46,60)]:
        if binaries[name] != raw[lo:hi]:
            raise ValueError('Retained linker slice differs from complete donor context')
        register(name,owners[lo:hi],[path,'docs/retained-linker-code.md'],
                 'Replayed historical complete procedures; clipped operands retain code classification')

    from native_block_tail import prepare as verify_native_tails
    verify_native_tails(verify=True)
    path = 'docs/reference/raw-modules/native_block_tails.json'
    summary = read_json(path)
    items, cursor = [], 0
    for record in summary['records']:
        items.extend(dict(offset=cursor+i['offset']-record['prefix_size'],size=i['size'],
                          classification=i['classification']) for i in record['items'])
        cursor += 512-record['prefix_size']
    register('native_block_tails',from_items(cursor,items),[path,summary['classification_evidence']],
             'Replayed native footer/storage audit and retained indirect transfer')

    from prepare_dialogue_scripts import verify as verify_dialogue
    verify_dialogue()
    path = 'docs/reference/dialogue-scripts.json'
    summary = read_json(path)
    play_disk = next(d for d in manifest['disks'] if d['id'] == 'disk2')
    image = (ROOT/'build/disks'/play_disk['filename']).read_bytes()
    packed, owners = bytearray(), bytearray()
    for record in summary['banks']:
        bank = block_bytes(image,record['block'],record['block']+1)
        first = 1 if bank[0] == 18 else 0
        packed.extend(bank[first:16])
        owners.extend(bytes([DATA])*(16-first))
        for script in record['records']:
            lo,hi = script['start'],script['end']
            packed.extend(bank[lo:hi])
            owners.extend(bytes([CODE])*(hi-lo))
    if packed != binaries['dialogue_scripts']:
        raise ValueError('Replayed dialogue source ordering differs')
    register('dialogue_scripts',bytes(owners),[path,summary['classification_evidence'],
             'src/dialogue/encoding.inc'], 'Replayed custom-script decoder; entry-pointer bytes are data')

    for name,spec in specs.items():
        if name not in classification:
            register(name,bytes([PENDING])*spec['size'],[],
                     'Existing audit requires a separate ledger adapter; no classification inferred')

    disks = [project(disk,binaries,classification) for disk in manifest['disks']]
    total = {label:sum(d['coverage_bytes'][label] for d in disks) for label in LABELS.values()}
    component_total = {label:sum(counts(c)[label] for c in classification.values())
                       for label in LABELS.values()}
    rows = []
    for name in sorted(specs):
        spec = specs[name]
        rows.append(dict(component=name,kind=spec['kind'],size=spec['size'],sha256=spec['sha256'],
                         source=spec.get('source',spec.get('path')),
                         storage_encoding=spec.get('storage_encoding'),
                         evidence=evidence[name],coverage_bytes=counts(classification[name]),
                         classification_runs=runs(classification[name])))
    return dict(schema_version=1,manifest_sha256=sha(MANIFEST.read_bytes()),
                scope='Reviewed classification plus separately counted explicit user data assumptions',
                complete=complete(total) and complete(component_total),coverage_bytes=total,
                assumed_data_inputs=assumptions,
                declared_component_coverage_bytes=component_total,components=rows,disks=disks,
                proof_files={p:sha(contained_file(ROOT,p).read_bytes()) for p in sorted(proof_files)},
                limitations=['Asset and registered data-source classifications are inherited from '
                             'their reviewed evidence; this ledger does not rerun every data consumer audit.',
                             'User-assumed data has no established code/data role; its acceptance is '
                             'an explicit user exception, not new classification evidence.',
                             'Classification coverage does not prove every routine executes or '
                             'replace the final PRD completion and behavior audit.'])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--write',action='store_true',help='Regenerate the reviewed ledger')
    parser.add_argument('--require-complete',action='store_true',
                        help='Fail if temporary bytes or unintegrated audits remain')
    args = parser.parse_args()
    # A fresh build binds the classification to current delivered source,
    # including the stored encoding of native components.
    build(MANIFEST,ROOT/'build/disks')
    result = report()
    content = json.dumps(result,indent=2)+'\n'
    if args.write:
        REPORT.write_text(content)
    elif REPORT.read_text() != content:
        raise ValueError('Classification ledger differs; review the changed evidence')
    print(json.dumps(dict(complete=result['complete'],coverage_bytes=result['coverage_bytes'])))
    if args.require_complete and not result['complete']:
        parser.exit(1,'Classification ledger incomplete: temporary bytes or unintegrated audits remain\n')


if __name__ == '__main__':
    main()
