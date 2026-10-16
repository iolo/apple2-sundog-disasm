#!/usr/bin/env python3
"""Audit browser artwork and built-in text used by the R12 presentation pass."""
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2] / 'remake'


def font_codepoints():
    raw = subprocess.check_output(
        ['fc-query', '--format', '%{charset}', str(ROOT / 'assets/fonts/Mulmaru.woff2')],
        text=True,
    )
    points = set()
    for part in raw.split():
        first, *last = part.split('-')
        points.update(range(int(first, 16), int(last[0], 16) + 1 if last else int(first, 16) + 1))
    return points


def main():
    catalog = json.loads((ROOT / 'data/catalog.json').read_text())
    images = list(catalog['images'].values()) + list(catalog['itemImages'].values())
    images += [path for bank in catalog['tileBanks'].values() for path in bank]
    assert len(images) == len(set(images)), 'Duplicate catalog paths'
    for path in images:
        image = ROOT / path
        assert image.is_file(), f'Missing SVG: {path}'
        source = image.read_text()
        assert re.search(r'<svg\b', source), f'Invalid SVG: {path}'
        assert not re.search(r'<image\b|data:image|<foreignObject\b', source, re.I), f'Embedded raster: {path}'
    names = catalog['images']
    for key in ['ship', 'ship-section', 'title', 'player', 'city-player',
                'landed-ship', 'landed-ship-detached', 'room-player', 'room-npc']:
        assert key in names, f'Missing reachable scene art: {key}'
    for number in range(1, 16):
        assert f'room-01-doors-{number}' in names, f'Missing bedroom state {number}'
    for number in range(4, 16):
        assert f'room-{number:02}' in names, f'Missing room {number}'
    for heading in (14, 16, 18, 20, 26, 29):
        assert f'pod-{heading}' in names, f'Missing pod heading {heading}'
    for glyph in (22, 23, 24, 25):
        assert f'encounter-glyph-{glyph}' in names, f'Missing encounter glyph {glyph}'
    assert all(len(bank) == 16 for key, bank in catalog['tileBanks'].items() if key.startswith('city-'))
    assert len(catalog['tileBanks']['world']) >= 21
    maps = json.loads((ROOT / 'data/maps.json').read_text())
    assert len(maps['cities']) == 60 and len(maps['worlds']) == 18
    for record in maps['cities']:
        assert all(0 <= tile < 16 for row in record['tiles'] for tile in row), record['id']
    for record in maps['worlds']:
        assert all(0 <= tile < len(catalog['tileBanks']['world']) for row in record['tiles'] for tile in row), record['id']
    catalogs = {lang: json.loads((ROOT / f'locales/{lang}.json').read_text()) for lang in ('en', 'ko')}
    assert catalogs['en'].keys() == catalogs['ko'].keys(), 'Translation keys differ'
    coverage = font_codepoints()
    for lang, strings in catalogs.items():
        for key, value in strings.items():
            assert isinstance(value, str), f'{lang}/{key} is not text'
            missing = sorted({character for character in value if not character.isspace() and ord(character) not in coverage})
            assert not missing, f'{lang}/{key} lacks Mulmaru glyphs: {missing}'
            assert re.findall(r'\{\w+\}', value) == re.findall(r'\{\w+\}', catalogs['en'][key]), f'{lang}/{key} interpolation differs'
    ui_sources = [ROOT / 'js/main.js', *(ROOT / 'js/ui').glob('*.js')]
    static_keys = set()
    for source in ui_sources:
        for line in source.read_text().splitlines():
            if line.lstrip().startswith('//'):
                continue
            assert not {char for char in line if ord(char) > 127 and ord(char) not in coverage}, f'Uncovered UI glyph in {source.name}'
            static_keys.update(match[2] for match in re.finditer(r"\bt\((['\"])([A-Za-z][A-Za-z0-9]*)\1(?!\s*\+)", line))
    assert static_keys <= catalogs['en'].keys(), f'Untranslated static UI keys: {sorted(static_keys-catalogs["en"].keys())}'
    messages = json.loads((ROOT / 'data/dialogue-text.json').read_text())['messages']
    message_keys = {f'dialogueMessage{bank}_{index}' for bank, records in messages.items() for index in records}
    assert message_keys <= catalogs['en'].keys() and len(message_keys) == 165, 'Dialogue messages lack translations'
    for number in range(1, 32):
        assert f'cargo{number:02}' in catalogs['en'], f'Missing cargo label {number}'
    for number in (7, *range(8, 14), *range(15, 32)):
        assert f'item{number}' in catalogs['en'], f'Missing item label {number}'
    print(json.dumps({'svgAssets': len(images), 'cityMaps': len(maps['cities']),
                      'worldMaps': len(maps['worlds']), 'localeKeys': len(catalogs['en']),
                      'uiStaticKeys': len(static_keys), 'dialogueMessages': len(message_keys),
                      'fontCodepoints': len(coverage), 'status': 'pass'}))


if __name__ == '__main__':
    main()
