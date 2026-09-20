#!/usr/bin/env python3
"""Re-run and combine the five resident native-runtime classification audits."""
import argparse
import json

from disk_layout import ROOT, sha
from check_pcode_native import audit as audit_primitives
from check_native_io import audit as audit_io
from check_native_shared import audit as audit_shared
from check_native_init import audit as audit_init
from check_native_high import audit as audit_high
from interpreter_linkage import audit_linkage

DOCUMENTS = {
    'pcode_primitives':['docs/pcode-native.md','docs/interpreter-linkage.md'],
    'native_io':['docs/native-io.md','docs/native-io-storage.md'],
    'native_shared':['docs/native-shared.md'],
    'native_init':['docs/native-init.md','docs/initializer-fortran-protection.md'],
    'native_high':['docs/native-high.md','docs/native-high-metadata.md'],
}


def report():
    manifest = json.loads((ROOT/'reconstruction/manifest.json').read_text())
    binary = {}
    for name in DOCUMENTS:
        spec = manifest['components'][name]
        data = (ROOT/'build/disks/components'/f'{name}.bin').read_bytes()
        if (spec['kind'] != 'ca65-source' or spec['size'] != len(data)
                or spec['sha256'] != sha(data) or 'storage_encoding' in spec):
            raise ValueError(f'Resident source component differs: {name}')
        for path in DOCUMENTS[name]:
            if not (ROOT/path).is_file():
                raise ValueError(f'Missing classification document: {path}')
        binary[name] = data
    p,io,s,i,h = (binary[n] for n in DOCUMENTS)
    audits = dict(pcode_primitives=audit_primitives(p),native_io=audit_io(io),
                  native_shared=audit_shared(s,p),native_init=audit_init(i,io),
                  native_high=audit_high(h,i,io,p,s))
    linkage = audit_linkage(p,s,h)
    if (audits['native_io']['unresolved_preservation_ranges']
            or audits['native_high']['unresolved_preservation_ranges']
            or audits['native_init']['unresolved_payload'] is not None):
        raise ValueError('A resident-runtime provisional classification remains open')
    # Existing checkers expose different conventions for overlapped/fragment
    # bytes. Normalize explicitly to unique source-byte ownership.
    code = {n:r['instruction_bytes'] for n,r in audits.items() if n!='native_io'}
    code['native_io'] = audits['native_io']['unique_instruction_bytes']
    code['native_init'] += audits['native_init']['instruction_fragment_bytes']
    rows = []
    for name,data in binary.items():
        audit = audits[name]
        if code[name]+audit['data_bytes'] != len(data):
            raise ValueError(f'Runtime code/data totals do not cover component: {name}')
        covered = bytearray(len(data))
        occurrences = []
        for disk in manifest['disks']:
            for region in disk['regions']:
                if region['input'] != name:
                    continue
                start,end = region['input_offset'],region['input_offset']+region['size']
                if not 0<=start<end<=len(data):
                    raise ValueError('Runtime source mapping exceeds component')
                covered[start:end] = bytes([1])*(end-start)
                occurrences.append(dict(disk=disk['id'],**region))
        if not all(covered):
            raise ValueError(f'Runtime source contains unmapped bytes: {name}')
        rows.append(dict(component=name,size=len(data),sha256=sha(data),
                         code_bytes=code[name],data_bytes=audit['data_bytes'],
                         source=manifest['components'][name]['source'],
                         classification_documents=DOCUMENTS[name],
                         instruction_fragment_bytes=audit.get('instruction_fragment_bytes',0),
                         extra_overlapping_opcode_bytes=3 if name=='native_io' else 0,
                         code_spans_end_exclusive=audit['code_spans_end_exclusive'],
                         mapping_count=len(occurrences),
                         disk_mapped_bytes=sum(m['size'] for m in occurrences)))
    return dict(scope='Five resident runtime source components; not all disk bytes or Pascal segments',
                unique_source_bytes=sum(r['size'] for r in rows),
                code_bytes=sum(r['code_bytes'] for r in rows),
                data_bytes=sum(r['data_bytes'] for r in rows),
                formerly_provisional_checks=['native I/O state/storage','initializer FORTRAN payload',
                                             'high-memory metadata','interpreter linkage descriptor'],
                unresolved_provisional_runtime_ranges=[],
                interpreter_linkage=linkage,components=rows,
                does_not_prove=['full-disk classification','execution of every routine',
                               'all peripheral behavior','historical data semantics'])


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--write',action='store_true')
    args = parser.parse_args()
    result = report()
    text = json.dumps(result,indent=2)+'\n'
    path = ROOT/'docs/reference/runtime-classification.json'
    if args.write:
        path.write_text(text)
    elif path.read_text() != text:
        raise ValueError('Combined runtime classification report differs')
    print(json.dumps({k:result[k] for k in ('unique_source_bytes','code_bytes','data_bytes',
                                          'unresolved_provisional_runtime_ranges')}))
