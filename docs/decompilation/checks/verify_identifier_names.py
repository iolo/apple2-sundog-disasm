#!/usr/bin/env python3
"""Check identifier-only Pascal changes and cataloged p-code bindings.

Uses the pinned repository revision as the source baseline. Disk byte equality
and compiler-output comparisons are separate checks recorded in the receipt.
"""
from pathlib import Path
import hashlib
import json
import re
import subprocess

ROOT = Path(__file__).resolve().parents[3]
CATALOG = ROOT / 'docs/decompilation/identifier-names.json'
RECEIPT = ROOT / 'docs/decompilation/checks/identifier_names_receipt.json'
TOKEN = re.compile(
    r"'(?:[^']|'')*'|\{[^}]*\}|\(\*[\s\S]*?\*\)|"
    r'[A-Za-z_][A-Za-z_0-9]*|[^\s]', re.S)


def git(*args):
    return subprocess.check_output(['git', *args], cwd=ROOT, text=True)


def tokens(source, global_map=None, local_map=None):
    global_map = global_map or {}
    local_map = local_map or {}
    result = []
    previous = None
    for match in TOKEN.finditer(source):
        value = match[0]
        if value.startswith(('{', '(*')):
            continue
        replacement = global_map.get(value, value)
        if previous != '.':
            replacement = local_map.get(value, replacement)
        result.append(replacement)
        previous = value
    return result


def main():
    catalog = json.loads(CATALOG.read_text())
    receipt = json.loads(RECEIPT.read_text())
    assert hashlib.sha256(CATALOG.read_bytes()).hexdigest() == receipt['catalog_sha256']
    revision = receipt['baseline_source_revision']
    paths = [path for path in git(
        'ls-tree', '-r', '--name-only', revision, '--', 'src/pascal',
        'docs/decompilation/checks/game_18_compile.pas',
        'docs/decompilation/checks/game_21_compile.pas').splitlines()
        if path.endswith('.pas')]
    names = {old: new for group in catalog['procedures'].values()
             for old, new, _ in group.values()}
    names.update({old: entry[0]
                  for old, entry in catalog['native_call_shapes'].items()})
    fields = {old: new for section in ('record_fields', 'storage_symbols')
              for group in catalog[section].values()
              for old, new in group.items()}
    source_paths = catalog.get('source_paths', {}).get('files', {})
    assert len(source_paths.values()) == len(set(source_paths.values()))
    for old, current in source_paths.items():
        assert (ROOT / current).is_file(), current
        assert not (ROOT / old).exists(), ('stale original source path', old)
    assert len(source_paths) == receipt['source_path_renaming']['mapped_files']
    for path in (ROOT / 'src/pascal').rglob('*.pas'):
        for target in re.findall(r'\(\*\$include\s+([^\s*]+)\s*\*\)', path.read_text(), re.I):
            assert (ROOT / target).is_file(), (path, target)
    for name in paths:
        old = git('show', f'{revision}:{name}')
        current_name = source_paths.get(name, name)
        new = (ROOT / current_name).read_text()
        for scope, params in catalog.get('fixture_parameters', {}).get(name, {}).items():
            def signature(match):
                return re.sub(r'\b(?:' + '|'.join(params) + r')\b',
                              lambda token: params[token[0]], match[0])
            old = re.sub(r'procedure ' + scope + r'\([^;]+;', signature, old)
        shared = [catalog['shared_words'], *catalog['context_words'].values()]
        for group in shared:
            for slot, (field, _) in group.items():
                new = re.sub(r'\bdata29\.' + field + r'\b',
                             f'data29.words[{slot}]', new)
        for frame in catalog['frames'].values():
            view = frame['pascal_view']
            for slot, field in frame['words'].items():
                new = re.sub(r'\b' + view + r'\.' + field + r'\b',
                             f'{view}.words[{slot}]', new)
        if name == 'src/pascal/storage.pas':
            new = re.sub(r';\n    \{ Named aliases[\s\S]*?\nend;', '\nend;', new)
        if name == 'src/pascal/game_12/types.pas':
            new = re.sub(r'(hull37: bounds4\));[\s\S]*?\nend;', r'\1\nend;', new)
        if name.endswith('/types.pas'):
            new = re.sub(r';\n    \{ Semantic aliases[\s\S]*?\nend;', '\nend;', new)
        if name == 'src/pascal/utility_disk1/types.pas':
            new = new.replace(
                'utilinit = record\n  case integer of\n    0: (words: array[1..17] of integer)',
                'utilinit = record\n  words: array[1..17] of integer')
        local = catalog['locals'].get(current_name.removeprefix('src/pascal/'), {})
        assert tokens(old, names | fields, local) == tokens(new), name
        assert not (set(tokens(new)) & names.keys()), (name, 'stale symbol')

    modules = {m['component']: m for m in json.loads(
        (ROOT / 'docs/decompilation/inventory.json').read_text())['modules']}
    constants = (ROOT / 'src/pcode/identifier_names.inc').read_text()
    canonical = {}
    numbers = {}
    sources = {}
    counts = {}
    for component, group in catalog['procedures'].items():
        module = modules[component]
        records = {str(record['number']): record for record in module['procedures']}
        assert set(group) == set(records), component
        for number, (_, name, _) in group.items():
            key = name.replace('_', '').lower()[:8]
            assert canonical.setdefault(key, name) == name, (component, name)
            symbol = 'proc_' + name
            assert re.search(r'^' + symbol + r' = ' + number + r'$', constants, re.M), symbol
            numbers[symbol] = int(number)
            source = catalog.get('assembly_procedure_sources', {}).get(component, {}).get(
                number, catalog.get('assembly_sources', {}).get(component, module['source']))
            text = (ROOT / source).read_text()
            sources[source] = component
            anchor = catalog.get('assembly_entry_labels', {}).get(component, {}).get(
                number, f'L_{records[number]["entry_offset"]:04X}')
            assert re.search(r'^' + name + r':[^\n]*\n' + anchor + ':', text, re.M), (source, name)
            kind = records[number]['representation']
            counts[kind] = counts.get(kind, 0) + 1
    for component, module in modules.items():
        if module['scope'] == 'target':
            assert component in catalog['procedures'], component
    for component, group in catalog['branches'].items():
        text = (ROOT / modules[component]['source']).read_text()
        for offset, name in group.items():
            assert re.search(r'^' + name + r':[^\n]*\nL_' + offset + ':', text, re.M), name
    for key, frame in catalog['frames'].items():
        significant = {}
        for name in frame['words'].values():
            prefix = name.replace('_', '').lower()[:8]
            assert significant.setdefault(prefix, name) == name, (key, name)
    # CIP has one procedure-number operand in the shipped interpreter.
    # Static-link traversal comes from the callee's dictionary lexical level.
    for source, component in sources.items():
        for line in (ROOT / source).read_text().splitlines():
            match = re.match(r'\s*p_c(gp|lp|ip|bp)\s+(\w+)\s*(?:;|$)', line)
            if match:
                opcode, operand = match.groups()
                number = int(operand) if operand.isdecimal() else numbers[operand]
                target = 'system_core' if opcode == 'bp' else component
                record = catalog['procedures'].get(target, {}).get(str(number))
                if record:
                    assert operand == 'proc_' + record[1], (source, line)
            match = re.match(r'\s*p_cxp\s+(\d+),\s*(\w+)\s*(?:;|$)', line)
            if match:
                segment, operand = match.groups()
                number = int(operand) if operand.isdecimal() else numbers[operand]
                if int(segment) < 7:
                    target = 'system_core' if segment == '0' else 'system_' + segment
                    record = catalog['procedures'].get(target, {}).get(str(number))
                    if record:
                        assert operand == 'proc_' + record[1], (source, line)
    assert len(paths) == receipt['pascal_source_token_comparison']['files']
    assert counts['p-code'] == receipt['named_procedures']['p-code']
    assert counts['native-6502'] == receipt['named_procedures']['native-entry-or-contract']
    print(f'{len(paths)} Pascal/fixture files: only cataloged identifier and alias changes')
    print(f'{sum(counts.values())} procedure identities: entry aliases, constants and call ownership verified')
    print(f'{len(source_paths)} source paths: current files and Pascal includes verified')


if __name__ == '__main__':
    main()
