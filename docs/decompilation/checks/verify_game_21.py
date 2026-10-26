#!/usr/bin/env python3
"""Verify reviewed game/library groups; no translation or execution."""
import json
from pathlib import Path
from verify_game_18 import ROOT, compiled_procedures, digest, procedure_attributes


def main():
    receipt = json.loads((ROOT / 'docs/decompilation/checks/game_21_receipt.json').read_text())
    manifest = json.loads((ROOT / 'reconstruction/manifest.json').read_text())
    inventory = json.loads((ROOT / 'docs/decompilation/inventory.json').read_text())
    records = {f"{m['component']}:{p['number']}": p
               for m in inventory['modules'] for p in m['procedures']}
    originals = {}
    for name, path in receipt['source_components'].items():
        originals[name] = (ROOT / path).read_bytes()
        assert digest(originals[name]) == manifest['components'][name]['sha256'], name
    for path, expected in receipt['source_sha256'].items():
        assert digest((ROOT / path).read_bytes()) == expected, ('stale source receipt', path)
    code = (ROOT / receipt['compiler_output']).read_bytes()
    assert digest(code) == receipt['compiler_output_sha256']
    segment, frames = compiled_procedures(code)
    for number, expected in receipt['compiled_frames'].items():
        assert all(frames[int(number)][k] == v for k, v in expected.items()), number
    mapping = {identity: int(number) for number, identity in
               receipt['compiled_procedure_mapping'].items()}
    source_frames = {}
    for identity, number in mapping.items():
        component, n = identity.split(':')
        record = records[identity]
        assert record['status'] == 'recovered' and (ROOT / record['pascal']).is_file()
        source = procedure_attributes(originals[component], record['attribute_offset'], int(n))
        source_frames[identity] = source
        for key in ('parameter_bytes', 'lexical_level'):
            assert frames[number][key] == source[key], (identity, key)

    def body(identity):
        f = frames[mapping[identity]]
        return segment[f['entry_offset']:f['exit_offset'] + 2]

    for match in receipt['exact_body_matches']:
        f = source_frames[match['original']]
        raw = originals[match['original'].split(':')[0]]
        before = raw[f['entry_offset']:f['exit_offset'] + 2]
        after = body(match['original'])
        assert before == after and len(after) == match['bytes']
        assert digest(after) == match['sha256']
    assert {f'game_21:{n}' for n in range(1, 42)} <= mapping.keys()
    for n, size in [(1, 114), (12, 30), (30, 8), (40, 48)]:
        assert frames[mapping[f'game_21:{n}']]['local_bytes'] == size
    # Native arity is established by callers, while actual cleanup is checked
    # independently. Renderer3 really pops16 bytes despite five-word call sites.
    for n, count in [(2, 6), (3, 16), (4, 10)]:
        record = records[f'library_23:{n}']
        assert record['status'] == 'native interface reviewed'
        at = record['entry_offset']
        assert originals['library_23'][at:at + 6] == bytes([0xa2, 0, 0xa0, count, 0x68, 0x95])
    assert originals['library_23'][0x32:0x34] == bytes.fromhex('9104')  # source mutation
    draw = body('game_21:9')
    # Both renderer alternatives push exactly five words, with two VAR reads.
    for prefix in ('0620', '0818'):
        assert bytes.fromhex(prefix + 'b60106f8b60105f8b60137cf12') in draw
    # City: save/install/restore four seed bytes, clear960 map bytes, and call
    # random before the parent35 clipping test on every visited cell.
    city = body('game_21:26')
    assert city.count(bytes.fromhex('9e02')) == 3
    assert bytes.fromhex('b6013700c7c003009e0a') in city
    assert bytes.fromhex('0000cf04cc0be110e2028e8f82cc0ab6012393') in city
    assert bytes.fromhex('ca14a204e00a95038fa401df0695c00404ba') in city
    assert city.endswith(bytes([0xae, mapping['game_21:9'], 0xae, mapping['game_21:8'], 0xad, 0]))
    # Planet: capture the destination before random; restore seed before
    # stamping cities. Source selection retains256-byte halves plus16 bytes.
    planet = body('game_21:28')
    assert bytes.fromhex('e6c70001dd8f821082b60137cf11') in planet
    assert bytes.fromhex('b6013728db8f82dc82cc0a0000cf04cc09e1000ee0078e82bf') in planet
    assert planet.count(bytes.fromhex('9e02')) == 3
    restore = planet.index(bytes.fromhex('c60b00a51700049e02'))
    stamp = planet.index(bytes.fromhex('ca11a2050600ba0dbf'))
    assert restore < stamp
    # Native rectangle calls and signed sound arguments stay in loop order.
    flash = body('game_21:31')
    assert bytes.fromhex('dfdedddccf13') in flash
    assert bytes.fromhex('0408e095228f080891000100cf10') in flash
    assert bytes.fromhex('04e00182228f0808000100cf10') in flash
    # Probe tests bit0 and repeats after y decrement; polling4 is not removed
    # even though the next instruction overwrites parent38 with zero.
    move = body('game_21:36')
    assert bytes([0xae, mapping['game_21:10'], 0xa1]) in move
    assert move.endswith(bytes.fromhex('040000cf08b8012600b80126ad00'))
    assert move.count(bytes([0xae, mapping['game_21:31']])) == 4
    # Teleport preserves the nested bounds and initially unwritten flag slot.
    menu = body('game_21:38')
    assert frames[mapping['game_21:38']]['local_bytes'] == 22
    assert menu.count(bytes.fromhex('cc02')) == 1
    assert bytes.fromhex('c609a530a802') in menu and bytes.fromhex('a530c609a802') in menu
    for literal in (b'Public TelePort', b'|||||Cost:  ', b' Cr\\|\\',
                    b'|||Deposit money and\\||select destination.\\|\\', b'Deposit money'):
        assert bytes([0xa6, len(literal)]) + literal in menu
    assert bytes.fromhex('010000cf08cc01') in menu  # unconditional cancel poll
    assert body('game_21:39').startswith(bytes.fromhex('c603d9aa50'))
    assert frames[mapping['game_21:39']]['local_bytes'] == 84
    # Preserve the low-bit input comparison and RNG consumption on both
    # encounter-eligible and ineligible clock-update paths (reviewed branches).
    entry = body('game_21:1')
    assert bytes.fromhex('ca26ca24b706') in entry
    assert entry.count(bytes.fromhex('0000cf04cc18')) == 2
    assert entry.startswith(bytes.fromhex('08cf341bcf3417cf34'))
    assert entry.endswith(bytes.fromhex('17cf351bcf3508cf35ad00'))
    assert source_frames['game_21:1']['exit_offset'] == 0x1f45
    # Full step, x-only, y-only probes remain, and city leave exits the
    # movement procedure itself before any viewport update.
    movement = body('game_21:12')
    assert movement.count(bytes([0xae, mapping['game_21:10']])) == 3
    assert bytes([0xae, mapping['game_21:11'], 1, mapping['game_21:12'], 0x9e, 4]) in movement
    setup = body('game_21:30')
    assert bytes.fromhex('02cc02') in setup  # two read/check attempts
    assert bytes.fromhex('b20120b601094082cf33d90195cc02') in setup
    assert bytes.fromhex('d8f8b60120cb') in setup  # full-word checksum inequality
    assert bytes.fromhex('040000cf08b80126000000cf08b8012600b80126') in setup
    # The reviewed failure branch ends in UJP through a table entry pointing
    # back to that same UJP, preserving the original permanent failure loop.
    at = setup.index(bytes.fromhex('cf38b9')) + 2
    frame = frames[mapping['game_21:30']]
    jump = frame['entry_offset'] + at
    table = frame['attribute_offset'] + int.from_bytes(setup[at + 1:at + 2], 'little', signed=True)
    assert table - int.from_bytes(segment[table:table + 2], 'little') == jump
    assert records['library_22:25']['status'] == 'native interface reviewed'
    assert originals['library_22'][0xf44:0xf5b] == bytes.fromhex(
        '688500688501688d1500688d1600a50148a500484c0000')
    encounter = body('game_21:40')
    assert bytes([1, mapping['game_21:40'], 0x9e, 4]) in encounter
    assert bytes.fromhex('de0195cc07de93a104ca15a1') in encounter  # counter bit0
    assert encounter.count(bytes.fromhex('cf04cc05')) == 4  # two setup, two outcome sites
    assert encounter.count(bytes.fromhex('cf06')) == 3  # hero, foe, same-delta retry
    # Remaining shared libraries: select/store the buffer before disk I/O;
    # call the loaded initializer before clearing state and installing buffers.
    select = body('library_22:20')
    assert select.startswith(bytes.fromhex('d9a108d8a58165cf0d'))
    assert bytes.fromhex('d8a58166cf0d') in select
    assert select.endswith(bytes.fromhex('d802da028f01cf1cad00'))
    assert body('library_22:54') == bytes.fromhex(
        'cf69c7800e01d801cf1ca516c7400fcf6a00ab16c70018ab8177c70040ab8176ad00')
    circle = body('library_24:2')
    assert frames[mapping['library_24:2']]['local_bytes'] == 6
    assert circle.startswith(bytes.fromhex('00cc06dacc0503da010000cf0b95cc04'))
    assert circle.count(bytes([0xce, mapping['library_24:10']])) == 4
    assert bytes.fromhex('dbdddc95020000cf0b820a82cc04dc0195cc05') in circle
    plot = body('library_24:10')
    assert plot == bytes.fromhex(
        'b60102d982b60101d882cf68b60102d982b60101d895cf68'
        'b60102d995b60101d895cf68b60102d995b60101d882cf68ad00')
    distance = body('library_24:6')
    assert frames[mapping['library_24:6']]['local_bytes'] == 10  # two address views added
    assert distance.startswith(bytes.fromhex('00cc0600cc0502cc07'))
    assert bytes.fromhex('dddfa208dcc00404bae0a208dcc00404ba959882cc06') in distance
    assert distance.endswith(bytes.fromhex('dd0000cf6ecc01ad01'))
    for identity in ['library_22:8', 'library_22:55', 'library_24:3', 'library_24:5']:
        assert records[identity]['status'] == 'native interface reviewed'
    assert originals['library_22'][0x1030:0x1042] == bytes.fromhex(
        '68850668850768850c68850d68850a68850b')
    assert originals['library_22'][0x1045:0x104c] == bytes.fromhex('a50748a5064860')
    assert originals['library_22'][0x1600:0x1607] == bytes.fromhex('ad54c0ad50c060')
    assert originals['library_24'][0xe68:0xe73] == bytes.fromhex('a200a004689500e888d0f9')
    assert originals['library_24'][0xe9e:0xea5] == bytes.fromhex('a50148a5004860')
    assert originals['library_24'][0x1010:0x101b] == bytes.fromhex('688508688509ad00408504')
    assert originals['library_24'][0x106d:0x1074] == bytes.fromhex('a50948a5084860')
    # The complete game16 scope retains its original parent frame;
    # DATASEG31 follows the760-byte DATASEG29 stand-in view.
    assert {f'game_16:{n}' for n in range(1, 49)} <= mapping.keys()
    parent = frames[mapping['game_16:1']]
    assert parent['local_bytes'] == 278 and parent['parameter_bytes'] == 6
    assert frames[1]['local_bytes'] == 912
    price = body('game_16:3')
    # Distinct slot100/102 names must not collide under eight-character lookup.
    assert bytes.fromhex('b2016400dacf79') in price
    assert bytes.fromhex('b2016a00dacf79') in price
    assert bytes.fromhex('dab2016ccf31') in price  # formatter writes same108 prefix
    assert bytes.fromhex('b2017c') in price and price.count(bytes.fromhex('aa1f')) == 2
    assert bytes.fromhex('a60320437222cd0017c604aa1f') in price
    assert frames[mapping['game_16:3']]['local_bytes'] == 38
    assert body('game_16:4').startswith(bytes.fromhex('c602d8a80203cf15'))
    layout = body('game_16:6')
    assert frames[mapping['game_16:6']]['local_bytes'] == 10
    assert bytes.fromhex('dfa2010800dabbdf0808debbdf0800ddbb') in layout
    assert bytes.fromhex('dacf76f7de82f5dd82cf75') in layout  # mode before origins
    # Byte-reader15's complete20-byte body also matches the original exactly.
    scan = body('game_16:31')
    assert bytes.fromhex('d9b601808dd8bec8a114d841c9') in scan  # read before limit
    assert bytes.fromhex('b601808dd8becc02') in scan  # reread on inner-loop exit
    patch = body('game_16:32')
    assert bytes.fromhex('d8dc0182b601808dd9da9e02') in patch
    assert bytes.fromhex('b601808ddb0182d9da82c700018ebf') in patch
    assert bytes.fromhex('dca105dc0182cc05') in patch  # low-bit alignment
    assert bytes.fromhex('b601808ddb0182b601808ddbbebf') in patch  # forward fill
    hit = body('game_16:35')
    assert bytes([0xce, mapping['game_16:36'], 0xa1]) in hit
    assert bytes.fromhex('d8019a1e320a00000000cf10') in hit  # found before sound
    assert body('game_16:36').startswith(bytes.fromhex('b20248da048fa401cc06'))
    wait = body('game_16:44')
    assert wait.startswith(bytes.fromhex('0000cf04cc01'))
    assert bytes.fromhex('040000cf08a105a9815d') in wait  # poll before stop flag
    assert body('game_16:45').startswith(bytes.fromhex('a58149a58184a804'))
    for caption in (b' no money', b' Cr on hand'):
        assert bytes([0xa6, len(caption)]) + caption in body('game_16:46')
    cleanup = body('game_16:47')
    assert bytes.fromhex('b20166b201680000cf7a') in cleanup
    assert bytes.fromhex('b20168b20166a802') in cleanup
    assert bytes.fromhex('a530b20168a802') in cleanup
    assert bytes.fromhex('a58149b20138a804') in cleanup
    assert bytes.fromhex('a50db20140a804') in cleanup
    assert cleanup.endswith(bytes.fromhex('040000cf08cc02050000cf08cc02ad00'))
    # Conditions: negative input skips the result initialization and returns;
    # raw word cases4/6 and both random calls in case18 remain intact.
    condition = body('game_16:8')
    assert condition.startswith(bytes.fromhex('00cc0500cc06da00c3a10501cc01b9'))
    at = condition.index(bytes.fromhex('da00c5a1')) + 3
    frame = frames[mapping['game_16:8']]
    table = frame['attribute_offset'] + int.from_bytes(condition[at + 1:at + 2], 'little', signed=True)
    assert table - int.from_bytes(segment[table:table + 2], 'little') == frame['exit_offset']
    assert condition[at + 2:at + 5] == bytes.fromhex('00cc01')
    for slot in (20, 18):
        assert bytes([0xb6, 1, slot, 0xcc, 1]) in condition
    chance_call = bytes([0xce, mapping['game_16:9']])
    assert (bytes.fromhex('b6011d0a8f0000') + chance_call + bytes.fromhex('cc0cdd0000')
            + chance_call + bytes.fromhex('cc0de3a1')) in condition
    assert bytes.fromhex('b60105cc0ab60124cc0b0000cf04') in condition
    roll = body('game_16:9')
    assert roll == bytes.fromhex('0000cf04cc04db648eb80108b60108dac9cc01ad01')
    chance = body('game_16:10')
    assert bytes.fromhex('dcda820000') + bytes([0xae, mapping['game_16:9']]) + bytes.fromhex('cc01db04c3') in chance
    assert chance.endswith(bytes.fromhex('a5035edb82dc0286bfad01'))
    choose = body('game_16:11')
    condition_call = bytes([0xae, mapping['game_16:8']])
    assert (bytes.fromhex('b601290ec5cc071e0000') + condition_call
            + bytes.fromhex('cc08c7a6000000') + condition_call + bytes.fromhex('cc09dea1')) in choose
    assert frames[mapping['game_16:11']]['local_bytes'] == 24
    # Text writes retain the old length until the final store; low-byte96
    # rereads the preceding output byte. Nested14 writes the parent's glyph.
    text = body('game_16:13')
    assert frames[mapping['game_16:13']]['local_bytes'] == 12
    assert text.count(bytes.fromhex('aa1f')) == 1  # only the out-of-range empty result
    assert bytes.fromhex('d8dcbecc09dc0195cc0500cc07') in text
    assert bytes.fromhex('d8dce0bf20cc09') in text  # high-bit byte then space
    assert text.endswith(bytes.fromhex('d800dcbfad00'))
    variant = body('game_16:14')
    assert bytes.fromhex('b602808dd9beb80104') in variant
    assert variant.endswith(bytes.fromhex('0000cf04cc04dadbdaf88e9aad00'))
    names = body('game_16:16')
    assert names.startswith(bytes.fromhex('0000cf04a1'))  # bit0, not nonzero
    assert bytes.fromhex('d9a5270400bacba1') in names
    assert bytes.fromhex('daa5270504bacba1') in names
    assert names.count(bytes.fromhex('aa0f')) == 2
    # Dialogue and interaction retain every original frame size, including
    # the copied value string in21 and the compiler's captured bounds in27.
    for n in range(17, 30):
        identity = f'game_16:{n}'
        assert frames[mapping[identity]]['local_bytes'] == source_frames[identity]['local_bytes']
    dialogue = body('game_16:17')
    assert dialogue.startswith(bytes.fromhex('c606a50da804a50db2013ca804'))
    assert dialogue.count(bytes([0xce, mapping['game_16:18']])) == 2
    assert dialogue.endswith(bytes([0xce, mapping['game_16:19']]) + bytes.fromhex('a50dc606a804ad00'))
    flush = body('game_16:19')
    assert bytes.fromhex('b2010d00b601050195bfb2010dcf30') in flush
    literal = body('game_16:21')
    assert literal.startswith(bytes.fromhex('c603d9aa1fc60300becc14'))
    assert bytes.fromhex('c60301be') + bytes([0xae, mapping['game_16:20']]) in literal
    assert bytes.fromhex('c60302b2010db60105ca1401959e02') in literal
    assert bytes.fromhex('c603ca13be') + bytes([0xae, mapping['game_16:18']]) in literal
    assert body('game_16:22') == (bytes.fromhex('dad9b20103')
        + bytes([0xae, mapping['game_16:13']]) + bytes.fromhex('b20103d8')
        + bytes([0xae, mapping['game_16:21']]) + bytes.fromhex('ad00'))
    alternatives = body('game_16:24')
    assert bytes.fromhex('d9cc09dce0c8a1') in alternatives  # captured inclusive limit
    assert bytes.fromhex('0000cf04cc05dcd8f88ecc05') in alternatives  # divisor after random
    assert bytes.fromhex('df93a10dda0000') + bytes([0xae, mapping['game_16:8']]) in alternatives
    effects = body('game_16:26')
    assert bytes.fromhex('d80286a1') in effects  # quotient's bit0
    assert bytes.fromhex('b20264b20266a802') in effects  # fund102 -> fund100
    button = body('game_16:27')
    assert bytes.fromhex('b20248da048fa401cc16') in button
    assert bytes.fromhex('c60601be61c4a1') in button  # no length guard
    assert bytes.fromhex('dbca16f80295cf18c606cf2a01cf15') in button
    action = body('game_16:28')
    assert bytes.fromhex('b6021ecc040000cf04cc02') in action  # capture before random
    assert bytes.fromhex('b6010ab6010a01') + bytes([0xae, mapping['game_16:7']]) in action
    dispatch = body('game_16:23')
    assert bytes([1, 0xc7, mapping['game_16:23'], 0, 0x9e, 4]) in dispatch
    assert (bytes.fromhex('b60126cc0adb') + bytes([0xae, mapping['game_16:17']])
            + bytes.fromhex('e1b80126')) in dispatch
    assert bytes.fromhex('da0286a1') in dispatch  # flag bit1, not quotient nonzero
    for n in (33, 34, 37, 38, 41, 42, 43):
        identity = f'game_16:{n}'
        assert frames[mapping[identity]]['local_bytes'] == source_frames[identity]['local_bytes']
    assert frames[mapping['game_16:39']]['local_bytes'] == 6  # one extra saved result
    action = body('game_16:33')
    assert bytes.fromhex('50b6012982cc020000cf04cc03a554d9c01001dabb') in action
    assert bytes.fromhex('b20164b20166a802') in action
    redirect = body('game_16:34')
    assert bytes.fromhex('00ab816401b8011600b80115') in redirect
    assert (bytes.fromhex('dab80127c7004801b60109b601278201cf1c')
            + bytes([0xae, mapping['game_16:32']])) in redirect
    setup = body('game_16:37')
    assert setup.startswith(bytes.fromhex('b201350006009e0a'))  # six-byte clear
    assert bytes.fromhex('ca18a2050107bab80110') in setup  # system-row bit7
    for pattern in ('ca18a208040cbab80120', 'ca18a2090400bab8011e',
                    'ca18a2090404bab8011f', 'ca18a209040cbab8011d'):
        assert bytes.fromhex(pattern) in setup
    assert bytes.fromhex('b6010393a110b6010314b60103950000cf1d82b80103') in setup
    assert setup.count(bytes([0xce, mapping['game_16:38']])) == 4
    assert bytes.fromhex('deb601808ddd0195bec3a107dd0195cc06') in setup
    initial = body('game_16:39')
    assert bytes.fromhex('b6021ecc020000cf04cc03dac7ff0b0000cf0ecc03da0000cf6e') in initial
    assert (bytes.fromhex('a503c71d02be01c5cc02650000')
            + bytes([0xae, mapping['game_16:8']]) + bytes.fromhex('cc03d9a1')) in initial
    trade = body('game_16:41')
    # Capture target and mode before the unconditional amount comparison.
    assert bytes.fromhex('dfa9818cc3cc03e5cc04b2016ab201680000cf7acc01daa1') in trade
    # Both native masks run before either combined predicate is tested.
    assert bytes.fromhex('b60112cc03dc1f0000cf0ecc01b601291f0000cf0ecc04daa1') in trade
    assert bytes.fromhex('010000cf08cc01d8a1') in trade  # input1 even when held=0
    transfer = body('game_16:42')
    assert bytes.fromhex('b60107b80229b6025f00') + bytes([0xae, mapping['game_16:34']]) in transfer
    exchange = body('game_16:43')
    assert exchange.startswith(bytes.fromhex('b60105b80107b60108b80106'))
    assert bytes.fromhex('b60105b60108b20105b2010db2010c') + bytes([0xcf, mapping['library_27:7']]) in exchange
    entry16 = body('game_16:1')
    assert entry16.startswith(bytes.fromhex('1bcf341ccf34') + bytes([0xce, mapping['game_16:37']]))
    assert bytes.fromhex('000000cf08cc19010000cf08cc808eca1993a1') in entry16
    assert entry16.endswith(bytes([0xce, mapping['game_16:47']]) + bytes.fromhex('1ccf351bcf35ad00'))
    assert source_frames['game_16:1']['exit_offset'] == 0x1c8f  # original release epilogue
    assert {f'game_15:{n}' for n in range(1, 17)} <= mapping.keys()
    assert frames[mapping['game_15:1']]['local_bytes'] == 52
    for n in (1, 2, 3, 4, 5, 7, 9, 10, 12, 13, 14, 15):
        identity = f'game_15:{n}'
        assert frames[mapping[identity]]['local_bytes'] == source_frames[identity]['local_bytes']
    assert frames[mapping['game_15:6']]['local_bytes'] == 0  # four unused bytes omitted
    for n, size in ((8, 2), (11, 4), (16, 0)):
        assert frames[mapping[f'game_15:{n}']]['local_bytes'] == size  # unused locals omitted
    caption = body('game_15:3')
    # Both private value copies precede drawing: MOV4, then SAS80. Compiler
    # offsets differ from the original; no raw observer uses those private slots.
    assert caption.startswith(bytes.fromhex('c603d9a804c607d8aa50'))
    for n in range(1, 5):
        assert bytes.fromhex('c607') + bytes([n, 0xbe, 0xcf, 3]) in caption
    reset = body('game_15:7')
    assert bytes.fromhex('a503c7fb0110bfa503c7fa0111bf') in reset  # high byte then low
    assert bytes.fromhex('a526a580e6a806') in reset  # exactly six words228 ->36
    query = body('game_15:12')
    assert query.endswith(bytes.fromhex('cf03eacc01ad01'))  # native9, full word1 result
    movement = body('game_15:13')
    # Capture drawing codes before evaluating BOTH fallback step functions;
    # retain VAR coordinates6/5. Reviewed branches require both axes unchanged.
    assert bytes.fromhex('b60109b60108dd0000cf1ddc0000cf1db20106b20105cf06') in movement
    assert movement.count(bytes.fromhex('cf06')) == 2
    load15 = body('game_15:8')
    assert load15.startswith(bytes.fromhex('b6011aa60420202020aa0fc70040b8011a'))
    assert bytes.fromhex('a53cb60107cf6a') in load15  # unused VAR58, native entry7
    advance = body('game_15:9')
    assert bytes.fromhex('a91ad90195108f82cc08df0cbedf0bbeda8f82cc01') in advance
    assert bytes.fromhex('d8c7000182cc01') in advance  # signed +256 loop retained
    assert bytes.fromhex('df0cd8bf') in advance  # truncate into captured row byte12
    setup15 = body('game_15:11')
    assert bytes.fromhex('b6011ab20112b704b8010a') in setup15  # string comparison
    assert bytes.fromhex('a580e6a54aa806') in setup15  # six words72 ->228
    assert bytes.fromhex('b2010e') in setup15 and bytes.fromhex('b20112aa0f') in setup15
    leave15 = body('game_15:16')
    assert bytes([1, 0xc7, mapping['game_15:16'], 0, 0x9e, 4]) in leave15
    assert bytes.fromhex('b201010000cfc5a9815d93') in leave15  # VAR action then reread347
    entry15 = body('game_15:1')
    assert entry15.startswith(bytes.fromhex('08cf340ecf341bcf34'))
    assert entry15.count(bytes.fromhex('040000cf08')) == 4  # no input4 calls collapsed
    assert bytes.fromhex('010000cf08') in entry15  # input1 still called before mode test
    assert bytes.fromhex('040000cf08e3b706') in entry15  # low-bit transition comparison
    assert entry15.endswith(bytes.fromhex('a52f040402bb1bcf350ecf3508cf35ad00'))
    assert source_frames['game_15:1']['exit_offset'] == 0xa13
    assert {f'game_14:{n}' for n in range(1, 13)} <= mapping.keys()
    for n in range(1, 13):
        identity = f'game_14:{n}'
        assert frames[mapping[identity]]['local_bytes'] == source_frames[identity]['local_bytes']
    assert frames[mapping['game_14:1']]['local_bytes'] == 204
    assert frames[mapping['game_14:10']]['lexical_level'] == 3
    cargo = body('game_14:6')
    assert cargo.startswith(bytes.fromhex('c601a50da804a50db20152a804'))
    assert bytes.fromhex('cc09e00500ba') in cargo  # capture stock pointer in9 before calls
    assert bytes.fromhex('dee00500ba088fa401aa0f') in cargo  # caption index kind, no -1
    repair = body('game_14:10')
    assert bytes.fromhex('cc04db0808bab6010682cc02') in repair  # captured row4, saved parent6
    assert bytes.fromhex('cf10dba2010800bacf76') in repair  # code reread AFTER native sound
    assert bytes.fromhex('b60107b60204828207bf') in repair  # parent index and grandparent base
    transfer = body('game_14:12')
    # Capture eligibility, call11 regardless of it, THEN test both results.
    assert (bytes.fromhex('cc03dbde0000') + bytes([0xae, mapping['game_14:11']])
            + bytes.fromhex('cc01da')) in transfer
    assert bytes.fromhex('dbdec604c60cc60bcf82') in transfer  # value held before VAR held
    assert bytes.fromhex('010000cf08') in transfer  # unconditional input1 poll
    entry14 = body('game_14:1')
    assert entry14.startswith(bytes.fromhex('daf8') + bytes([0xce, mapping['game_14:3']]))
    assert bytes.fromhex('010000cf08cc66') in entry14
    assert entry14.endswith(bytes.fromhex('da08e0829aad00'))  # final VAR action write
    # Game13's systems-display parent is recovered; the enclosing entry is not.
    assert 'game_13:1' not in mapping
    for n in range(2, 12):
        identity = f'game_13:{n}'
        expected = 2 if n == 8 else source_frames[identity]['local_bytes']
        assert frames[mapping[identity]]['local_bytes'] == expected
    random13 = body('game_13:2')
    assert random13.startswith(bytes.fromhex('a51700a54200049e02'))
    assert bytes.fromhex('d8d90000cf04c7ff000000cf0ebf') in random13
    assert random13.endswith(bytes.fromhex('a54200a51700049e02ad00'))
    # Retain the selected name pointer across drawing, reread its length after.
    caption13 = body('game_13:8')
    assert bytes.fromhex('cc04dbcf30db00be0a82d9') in caption13
    display13 = body('game_13:9')
    assert bytes([0xa6, 10]) + b'WARP TO:  ' in display13
    assert bytes.fromhex('0a11a544') + bytes([0xae, mapping['game_13:8']]) in display13
    poll13 = body('game_13:10')
    assert poll13.count(bytes.fromhex('010000cf08')) == 2
    assert bytes([1, 0xc7, mapping['game_13:10'], 0, 0x9e, 4]) in poll13
    assert poll13.count(bytes.fromhex('b706')) == 2
    assert body('game_13:3') == b''.join(
        bytes([0xce, mapping[f'game_13:{n}']]) for n in (6, 9, 10, 11)) + bytes.fromhex('ad00')
    print(f"Verified {len(mapping)} interfaces ({len(receipt['newly_recovered'])} new bodies), "
          f"{len(receipt['native_interfaces'])} native contracts, "
          f"{len(receipt['exact_body_matches'])} exact bodies, source/output hashes, "
          "and scoped game21/shared-library/game16/game15/game14/game13 checks.")


if __name__ == '__main__':
    main()
