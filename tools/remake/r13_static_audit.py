#!/usr/bin/env python3
"""Check every shipped module/resource edge and named runtime content reference."""
from html.parser import HTMLParser
import json
from pathlib import Path
import re

from r12_static_audit import font_codepoints

ROOT = Path(__file__).resolve().parents[2] / 'remake'


class Links(HTMLParser):
    def __init__(self):
        super().__init__()
        self.paths = []

    def handle_starttag(self, _tag, attrs):
        self.paths.extend(value for key, value in attrs if key in ('src', 'href'))


def local_path(source, reference):
    assert not re.match(r'(?:https?:)?//', reference), f'External runtime URL: {reference}'
    target = ((ROOT if reference.startswith('/') else source.parent) / reference.lstrip('/')).resolve()
    assert target.is_relative_to(ROOT.resolve()) and target.is_file(), f'Missing/escaped resource: {source}: {reference}'
    return target


def main():
    js = list((ROOT / 'js').rglob('*.js'))
    imports = 0
    for source in js:
        code = source.read_text()
        assert not re.search(r'https?://', code), f'External URL in {source}'
        for reference in re.findall(r"(?m)^\s*import\s+(?:[^\n;]*?\s+from\s+)?['\"]([^'\"]+)['\"]", code):
            local_path(source, reference)
            imports += 1
    assert imports > 100, 'Module graph unexpectedly small'
    links = Links()
    html = ROOT / 'index.html'
    links.feed(html.read_text())
    for reference in links.paths:
        local_path(html, reference)
    css_urls = 0
    for css in (ROOT / 'styles').glob('*.css'):
        for reference in re.findall(r"url\(\s*['\"]?([^)'\"]+)", css.read_text()):
            local_path(css, reference)
            css_urls += 1
    catalog = json.loads((ROOT / 'data/catalog.json').read_text())
    paths = list(catalog['images'].values()) + list(catalog['itemImages'].values())
    paths += [path for bank in catalog['tileBanks'].values() for path in bank]
    paths += [catalog[key] for key in ('maps', 'items', 'shipWalk', 'shipInventory')]
    paths += [f'data/{name}.json' for name in ('initial-navigation', 'initial-economy', 'initial-location',
      'city-walk', 'room-walk', 'dialogue', 'dialogue-text', 'dialogue-systems', 'exchange-defaults',
      'surface-walk', 'flight-defaults', 'ground-chase', 'ground-combat')]
    paths += ['locales/en.json', 'locales/ko.json', 'assets/fonts/Mulmaru.woff2']
    assert len(paths) == len(set(paths)), 'Duplicate runtime resource path'
    for reference in paths:
        local_path(ROOT / 'index.html', reference)
    navigation = json.loads((ROOT / 'data/initial-navigation.json').read_text())
    economy = json.loads((ROOT / 'data/initial-economy.json').read_text())
    exchange = json.loads((ROOT / 'data/exchange-defaults.json').read_text())
    maps = json.loads((ROOT / 'data/maps.json').read_text())
    surface = json.loads((ROOT / 'data/surface-walk.json').read_text())
    systems = navigation['systems']
    worlds = {world['id'] for world in navigation['worlds']}
    assert len(systems) == 12 and len(worlds) == 18
    memberships = [world for system in systems for world in system['worldIds']]
    assert len(memberships) == len(worlds) and set(memberships) == worlds
    assert {world['id'] for world in exchange['worlds']} == worlds
    assert {world['id'] for world in maps['worlds']} == worlds
    cities = {city['id'] for city in economy['cities']}
    assert len(cities) == 57 and all(city['worldId'] in worlds for city in economy['cities'])
    assert {city['id'] for city in maps['cities']} == cities | {'city-58', 'city-59', 'city-60'}
    assert {marker['cityId'] for marker in surface['cities']} == cities
    assert all(set(world['cityIds']) == {city['id'] for city in economy['cities'] if city['worldId'] == world['id']}
               for world in exchange['worlds'])
    text = json.loads((ROOT / 'data/dialogue-text.json').read_text())['messages']
    dialogue = json.loads((ROOT / 'data/dialogue.json').read_text())
    message_refs = redirect_refs = 0
    for bank in dialogue['banks']:
        available = text[str(bank['block'])]
        for record in bank['records']:
            selection = record['selection']
            if selection['kind'] == 'conditional':
                values = [choice['value'] for choice in selection['choices']]
                if selection.get('fallback') is not None:
                    values.append(selection['fallback'])
            elif selection['kind'] == 'literal':
                values = [selection['value']]
            else:
                values = selection['values'] + ([selection['fallback']] if selection.get('fallback') is not None else [])
            for value in values:
                if record['redirect']:
                    assert 16 <= value <= 223, f'Invalid dialogue redirect: {value}'
                    target_bank = dialogue['banks'][value // 16 - 1]
                    assert target_bank['entries'][value % 16], f'Missing dialogue redirect: {value}'
                    redirect_refs += 1
                else:
                    assert str(value) in available, f'Missing dialogue message {bank["block"]}/{value}'
                    message_refs += 1
    coverage = font_codepoints()
    names = [record['name'] for record in navigation['systems'] + navigation['worlds'] + economy['cities']]
    names.append(economy['colonyCity']['name'])
    assert all(ord(character) in coverage for name in names for character in name), 'Missing content-name font glyph'
    print(json.dumps({'modules': len(js), 'imports': imports, 'htmlResources': len(links.paths),
      'cssResources': css_urls, 'runtimeResources': len(paths), 'worlds': len(worlds), 'ordinaryCities': len(cities),
      'dialogueMessageReferences': message_refs, 'dialogueRedirectReferences': redirect_refs, 'status': 'pass'}))


if __name__ == '__main__':
    main()
