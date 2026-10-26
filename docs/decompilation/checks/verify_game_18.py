#!/usr/bin/env python3
"""Check the reviewed recovery artifacts; does not translate or generate Pascal.

Run the documented compiler/assembler commands first. Checks provenance,
interfaces, exact bodies, and selected effect-ordering regressions. This is not
a general semantic-equivalence check and does not execute the recovered game.
"""
import hashlib
import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'tools'))
from pascal_inventory import procedure_attributes


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def compiled_procedures(raw):
    # The compile fixture's code segment occupies header slot 1.
    start = int.from_bytes(raw[4:6], 'little') * 512
    size = int.from_bytes(raw[6:8], 'little')
    segment = raw[start:start + size]
    assert len(segment) == size and segment[-2] == 1
    result = {}
    for number in range(1, segment[-1] + 1):
        pointer = len(segment) - 2 - 2 * number
        distance = int.from_bytes(segment[pointer:pointer + 2], 'little')
        if distance:  # External declarations have no body.
            result[number] = procedure_attributes(segment, pointer - distance, number)
    return segment, result


def main():
    receipt = json.loads((ROOT / 'docs/decompilation/checks/game_18_receipt.json').read_text())
    manifest = json.loads((ROOT / 'reconstruction/manifest.json').read_text())
    inventory = json.loads((ROOT / 'docs/decompilation/inventory.json').read_text())
    originals = {}
    for name, path in receipt['source_components'].items():
        originals[name] = (ROOT / path).read_bytes()
        assert digest(originals[name]) == manifest['components'][name]['sha256'], name
    for path, expected in receipt['source_sha256'].items():
        assert digest((ROOT / path).read_bytes()) == expected, ('stale source receipt', path)
    code = (ROOT / 'build/decompile/game_18/check.code').read_bytes()
    assert digest(code) == receipt['compiler_output_sha256'], 'compiler output differs'
    segment, frames = compiled_procedures(code)
    for number, expected in receipt['compiled_frames'].items():
        actual = frames[int(number)]
        assert all(actual[key] == value for key, value in expected.items()), number
    records = {f"{m['component']}:{p['number']}": p
               for m in inventory['modules'] for p in m['procedures']}
    source_frames = {}
    for number, identity in receipt['compiled_procedure_mapping'].items():
        name, source_number = identity.split(':')
        record = records[identity]
        source = procedure_attributes(originals[name], record['attribute_offset'], int(source_number))
        source_frames[identity] = source
        assert record['status'] == 'recovered', identity
        assert (ROOT / record['pascal']).is_file(), identity
        for key in ('parameter_bytes', 'lexical_level'):
            assert frames[int(number)][key] == source[key], (identity, key)
    for match in receipt['exact_body_matches']:
        source = source_frames[match['original']]
        name = match['original'].split(':')[0]
        before = originals[name][source['entry_offset']:source['exit_offset'] + 2]
        target = frames[match['compiled_procedure']]
        after = segment[target['entry_offset']:target['exit_offset'] + 2]
        assert before == after and len(after) == match['bytes']
        assert digest(after) == match['sha256']
    mapping = {identity: int(number)
               for number, identity in receipt['compiled_procedure_mapping'].items()}

    def body(identity):
        frame = frames[mapping[identity]]
        return segment[frame['entry_offset']:frame['exit_offset'] + 2]

    # Game 18:9: collision call; STL 8; argument construction; collision call.
    # There is no conditional branch between the two calls in this pinned window.
    collision = bytes([0xae, mapping['game_18:3']])
    assert collision + bytes.fromhex('cc08dedaf8dd82d9f8dc820000') + collision in body('game_18:9')
    # Game 18:13 saves the failed-placement predicate, then calls collision
    # unconditionally before testing either Boolean. This prevents short-circuiting.
    assert (bytes.fromhex('dc00c3cc0818b6017fb6017e05820000') + collision +
            bytes.fromhex('cc07')) in body('game_18:13')
    # Game 18:12 branches directly on the low bit of the saved random word.
    assert bytes.fromhex('0000cf04cc08dfa1') in body('game_18:12')
    # Game 18:14 clears all 180 bytes from parent local slot 5 using CSP 10.
    assert body('game_18:14').startswith(bytes.fromhex('b2010500c7b400009e0a'))
    # The setup helper copies two words before touching the destination.
    assert body('game_18:17').startswith(bytes.fromhex('c604daa802'))
    # Setup entries are 16 words; exactly five calls convert their bounds.
    assert bytes.fromhex('d8d9108fa401') in body('game_18:16')
    assert body('game_18:16').count(bytes([0xce, mapping['game_18:17']])) == 5
    # Word-address overlays yield loads of the pointers, not addresses of them.
    assert bytes.fromhex('a9817700a9817600c700089e02') in body('library_22:63')
    assert bytes.fromhex('a9817600a9817700c700089e02') in body('library_22:63')
    # Grid initialization fills six bytes, then rounds odd edges up by one.
    assert body('game_18:18').startswith(bytes.fromhex('b2015f0006a981279e0a'))
    assert bytes.fromhex('daa105da0182cc03') in body('game_18:18')
    # Four input calls remain in order even though each result is overwritten.
    assert body('game_18:21').startswith(b''.join(
        bytes([selector, 0, 0, 0xcf, 8, 0xcc, 2]) for selector in [4, 0, 5, 1]))
    # Address-return calls compute the parent span [slot 5, slot 151).
    assert bytes.fromhex('b20180970000cf09b201050000cf0995b8018099') in body('game_18:21')
    assert bytes.fromhex('db00b2010500b60180999e02') in body('game_18:21')
    assert bytes.fromhex('b2010500d900d89e02') in body('game_18:22')
    # Bounds are copied before the external stores; the nested VAR flag is read
    # after it is written. The native input destination is two adjacent words.
    assert body('library_22:42').startswith(bytes.fromhex('c605d8a804'))
    assert body('library_22:62').startswith(bytes.fromhex('d9dbdac59ad9f8'))
    assert body('library_22:61').startswith(bytes.fromhex('c603cf0a'))
    # Strings are copied before effects; formatter keeps its original 120-byte
    # frame and the run buffer at slot49 beside code59/done60/limit61.
    assert body('library_22:10').startswith(bytes.fromhex('c602d8aa50'))
    assert body('library_22:48').startswith(bytes.fromhex('c602d8aa50'))
    assert frames[mapping['library_22:48']]['local_bytes'] == 120
    assert bytes.fromhex('c631ca2b0195ca3bbf') in body('library_22:48')
    # Game 8:6 preserves aggregate-copy-before-caption-copy order even though
    # the compiler assigns different local offsets to the two copied values.
    assert body('game_8:6').startswith(bytes.fromhex('c603d9a804c607d8aa0f'))
    # Game 8:7 uses original six-character labels and restores four bounds words.
    assert b'Vigor Rest  HealthNoursh' in body('game_8:7')
    assert bytes.fromhex('a50dc601a80401b8010f') in body('game_8:7')
    # DATASEG31 follows DATASEG29 in this fixture: 760 + 152 bytes. Table
    # entries start at global399, span two words, and retain three packed writes
    # (code in word2 low byte, then first/second offsets in word1).
    assert frames[1]['local_bytes'] == 1254  # DATASEG29 +31 +30; existing bases unchanged
    assert bytes.fromhex('a5818fa9818e0195028fa401cc04') in body('library_27:5')
    assert bytes.fromhex('dba2010800dac700018ebbdb0808d9bbdb0800d8bb') in body('library_27:5')
    # Selection update rereads both VAR coordinates for drawing after stores;
    # its entry pointer stays captured even if the outputs alias shared storage.
    draw = bytes([0xcf, mapping['library_27:3']])
    assert bytes.fromhex('d9f8d8f8') + draw + bytes.fromhex('dfde') + draw in body('library_27:7')
    # Both distance functions execute before the Boolean branch in hit testing.
    distance = bytes([0xcf, mapping['library_22:35']])
    assert (distance + bytes.fromhex('0ac9cc07dadf0800ba950000') +
            distance + bytes.fromhex('08c9cc06')) in body('library_27:8')
    # Caption table is loaded through the address in DATASEG31 word1; the
    # index has an eight-word stride. Text is copied before drawing effects.
    assert (bytes.fromhex('a9817fd9088fa401') +
            bytes([0xcf, mapping['library_27:9']])) in body('library_27:10')
    assert body('library_27:9').startswith(bytes.fromhex('c602d8aa0f'))
    # The nested update loads the byte before the random call, then retains
    # subtraction of (3 + masked_random), followed by the byte store.
    assert bytes.fromhex('becc040000cf04cc03') in body('library_27:14')
    assert bytes.fromhex('db03da070000cf2d8295bf') in body('library_27:14')
    assert frames[mapping['library_27:11']]['local_bytes'] == 16
    # Odd(mode) emits a low-bit branch, not a nonzero comparison.
    assert body('library_27:13').startswith(bytes.fromhex('d8a10509cc08'))
    # Clock stores retain the original widths/offsets, including the spare
    # bits. Aggregate value parameters are copied before any global effects.
    assert bytes.fromhex('d90600da3c8ebb') in body('library_22:26')
    assert bytes.fromhex('d90808da188ebb') in body('library_22:26')
    assert bytes.fromhex('d9a2010e00d9a2010e00bada188682bb') in body('library_22:26')
    assert body('library_22:27').startswith(bytes.fromhex('c604daa80200cc01'))
    assert body('library_22:28').startswith(bytes.fromhex('c602d8a802'))
    assert body('library_22:60').startswith(bytes.fromhex('c603d8a802'))
    # All three fixed four-byte tables survive unchanged, and nested60 still
    # uses parent slots2/3/6 and current value in its own slot8.
    for rates in (b'4234', b'1000', b'1123'):
        assert b'\xd0\x04' + rates in body('library_22:29')
    assert frames[mapping['library_22:29']]['local_bytes'] == 16
    assert frames[mapping['library_22:60']]['local_bytes'] == 12
    assert bytes.fromhex('dfb60106048f82cc08') in body('library_22:60')
    assert bytes.fromhex('b60102df1086049582b80102') in body('library_22:60')
    assert bytes.fromhex('de0182188ecc07a557010c01bb') in body('library_22:29')
    # Save and restore the same four bounds words, plus parent slots21/20.
    assert body('game_8:8').startswith(bytes.fromhex('b2011ea50da804'))
    assert bytes.fromhex('b6010293a108b601020182b80102') in body('game_8:8')
    assert bytes.fromhex('a50db2011ea804b60115ab8161b60114ab8163') in body('game_8:18')
    # Library24 value copies precede effects, including its drawing mode gate.
    assert body('library_24:7').startswith(bytes.fromhex('c605dba804'))
    assert body('library_24:17').startswith(bytes.fromhex('c609dba804'))
    assert frames[mapping['library_24:15']]['local_bytes'] == 30
    # Three different global bounds must remain distinct despite the compiler's
    # eight-significant-character identifier limit: words319/315/311 ->321/317/313.
    update = bytes([0xce, mapping['library_24:17']])
    for prefix in ('a58141040604', 'a5813d040507', 'a5813908090b'):
        assert bytes.fromhex(prefix) + update in body('library_24:15')
    # Parent slot15 is saved before nested17 and reread afterward; nested16
    # can overwrite it. Its stock update uses a two-word stride and 5-bit store.
    resource_body = body('library_24:15')
    saved_at = resource_body.index(bytes.fromhex('a980e1cc0f'))
    update_at = resource_body.index(update, saved_at)
    assert resource_body.index(bytes.fromhex('e6a980e0c9'), update_at) > update_at
    assert bytes.fromhex('01b8010f') in body('library_24:16')
    assert bytes.fromhex('a580ecb6010f0195028fa401050000bb') in body('library_24:16')
    assert bytes.fromhex('a580f0b6010f0195088fa401a600aa0f03b8010f') in body('library_24:16')
    # Low-bit phase gate, and unconditional timestamp call after capturing flag25.
    assert body('library_24:15').startswith(bytes.fromhex('a98162a1'))
    assert (bytes.fromhex('a5550109bacc08a5500000') +
            bytes([0xcf, mapping['library_22:27']]) + bytes.fromhex('cc09')) in body('library_24:15')
    # VAR input is read before random3, and the limit helper retains both MPI.
    assert bytes.fromhex('d8f8cc030000cf04cc04') in body('library_24:11')
    assert body('library_24:14').startswith(bytes.fromhex('d8dbda828fd8d98fc5'))
    # Movement captures phase before random, even when the low-bit gate fails.
    movement = body('library_24:12')
    assert bytes.fromhex('a98162cc0b0000cf04cc0c') in movement
    # Six-word arrival copies: 66->72, then 66->36 while preserving word40 and
    # only the low byte of word41. Optional 66->228 uses the same six words.
    assert bytes.fromhex('a54aa544a806a92acc08a50350becc07a526a544a806dfab2aa50350debf') in movement
    assert bytes.fromhex('a580e6a544a806') in movement
    # Ten-word table row is captured in slot15; each high-nibble threshold is
    # loaded before random, and failure rereads/stores nibble7 through that row.
    assert bytes.fromhex('a919cc0ee5a54b0400ba01950a8fa401cc0f') in movement
    assert bytes.fromhex('e6a208040cbacc0d0000cf04cc0c') in movement
    assert bytes.fromhex('e6a208a201040cbacc0d0000cf04cc0c') in movement
    assert bytes.fromhex('e6a209040ce6a209040cba0195bb') in movement
    damage = body('library_24:13')
    # Flag12 is captured before an unconditional random call; both event tests
    # also execute random after the range function regardless of its result.
    assert bytes.fromhex('a554010cbacc0a0000cf04cc08') in damage
    assert damage.count(bytes.fromhex('de0f460000cf14c9cc090000cf04cc08')) == 2
    assert bytes.fromhex('a5815903cf12a5815903cf12') in damage
    # Empty group redirects to group6 without recomputing base in slot1.
    assert bytes.fromhex('00c3a10306cc03da06c3') in damage
    # Selected byte overwrites work(slot6), which is subsequently decremented
    # by512. The code23 scan always calls random after reading/comparing a byte.
    assert bytes.fromhex('a503c7b200d882d982becc06dd17c3') in damage
    assert bytes.fromhex('ddc7000295cc06dd00c8') in damage
    assert bytes.fromhex('a503c7b200db82be17c3cc090000cf04cc08') in damage
    assert damage.endswith(bytes.fromhex('dcab80daad00'))
    tick = body('library_24:9')
    assert tick.startswith(bytes.fromhex('a980e5cc01a98162048eab8162'))
    assert (bytes.fromhex('c601') + bytes([0xcf, mapping['library_24:12']]) +
            bytes.fromhex('c601') + bytes([0xcf, mapping['library_24:15']]) +
            bytes.fromhex('a5560108ba')) in tick
    assert bytes.fromhex('a58145a980e5080a') + bytes([0xcf, mapping['library_24:7']]) in tick
    # Game8:3 calls its nested redraw on both sides of the four-bar loop. The
    # helper accesses flags one lexical level up and coordinates two levels up.
    redraw = bytes([0xce, mapping['game_8:4']])
    refresh = body('game_8:3')
    assert refresh.count(redraw) == 2
    assert bytes.fromhex('b6010fa1') in refresh
    assert bytes.fromhex('da') + bytes([0xae, mapping['game_8:2']]) in refresh
    assert bytes.fromhex('b60207b60206') + bytes([0xcf, mapping['library_27:3']]) in body('game_8:4')
    assert bytes.fromhex('b6020db6020c') + bytes([0xcf, mapping['library_22:41']]) in body('game_8:4')
    # Original EXIT(8,1) targets the recovered enclosing game8 entry, fixture83,
    # rather than the current nested procedure. Both failure/save paths do so.
    assert frames[mapping['game_8:1']]['local_bytes'] == 118 and frames[mapping['game_8:1']]['parameter_bytes'] == 4
    assert bytes([0xcf, mapping['library_22:52'], 1, mapping['game_8:1'], 0x9e, 4]) in refresh
    assert bytes([0xcf, mapping['library_22:52'], 1, mapping['game_8:1'], 0x9e, 4]) in body('game_8:16')
    # Selection always polls selector1 before testing parent item/exit state.
    assert bytes.fromhex('010000cf08cc08dfa1') in body('game_8:10')
    # The VAR item aliases the value argument; keep stores/calls and reloads.
    assert (bytes.fromhex('b60103dbb20103b20107b20106') +
            bytes([0xcf, mapping['library_27:7']])) in body('game_8:10')
    assert bytes.fromhex('040000cf08cc02d9a1') in body('game_8:11')
    # Bounds are copied directly between DATASEG31/29 for the clock display.
    assert bytes.fromhex('a58149a58184a804') in body('game_8:12')
    attributes = body('game_8:14')
    assert b'STIQDXCHLK' in attributes and b'|Attributes\\' in attributes
    assert bytes.fromhex('c606c60f01dc028f8202cd0019c60f') in attributes
    # Name pointers are loaded from words25/24/23, then indexed with distinct
    # six/eight/ten-word strides and the corresponding packed location fields.
    location = body('game_8:15')
    for window in ('a91ba5270609ba0195068fa401',
                   'a91aa5270504ba0195088fa401',
                   'a919a5270400ba01950a8fa401'):
        assert bytes.fromhex(window) in location
    # The save hit test runs before enabled is examined, even when disabled.
    assert (bytes.fromhex('deddb201160000') + bytes([0xae, mapping['game_8:5']]) +
            bytes.fromhex('cc0bd8e2a1')) in body('game_8:16')
    rest = body('game_8:17')
    assert rest.startswith(bytes.fromhex('00cc0800cc09'))
    assert bytes.fromhex('c606a52ca802') in rest
    assert bytes.fromhex('010000cf08cc0ae1a1') in rest
    assert bytes.fromhex('a530c608a802') in rest  # clear both currency words
    assert bytes.fromhex('e2038ecc05dccc02') in rest  # random MOD3 start
    assert bytes.fromhex('dc0182030000cf2dcc05dcd9c3') in rest  # AND3 cycle
    # Full parent body now dispatches input and restores via18 on normal exit.
    entry = body('game_8:1')
    assert entry.startswith(bytes([0xce, mapping['game_8:8']]))
    assert entry.endswith(bytes([0xce, mapping['game_8:18'], 0xad, 0]))
    assert bytes.fromhex('010000cf0893a1') in entry
    choose = body('game_18:23')
    assert choose.startswith(bytes.fromhex('b60104cc07b60103cc08b60102cc09'))
    assert bytes.fromhex('ac01000900b912') in choose
    assert bytes.fromhex('ac08001000b912') in choose
    # Preserve bounds around the game8 call and pass dereferenced coordinates.
    assert (bytes.fromhex('c603a50da804def8dff8') +
            bytes([0xcf, mapping['game_8:1']])) in choose
    assert bytes.fromhex('a50dc603a804a52f0408ba0ac5b801808f') in choose
    events = body('game_18:26')
    assert events.startswith(bytes.fromhex('b2010fcc02'))
    assert events.count(bytes.fromhex('040000cf08')) == 2
    assert bytes.fromhex('b601808ad8b706') in events  # Boolean low-bit NEQ
    follower = body('game_18:27')
    assert bytes.fromhex('b6017d00c5cc030000cf04cc02') in follower
    # Selected low-byte destination is captured before random, not indexed again.
    assert bytes.fromhex('b20105dba20900be0a8f0982a401cc050000cf04cc02') in follower
    assert bytes.fromhex('dc080040d9c7c0008e82bb') in follower
    assert bytes.fromhex('0000cf04cc02d9b6017a8e00c3') in body('game_18:28')
    parent = body('game_18:1')
    assert frames[mapping['game_18:1']]['local_bytes'] == 298
    assert parent.startswith(bytes.fromhex('08cf651bcf65') +
                             bytes([0xce, mapping['game_18:21']]))
    assert b''.join(bytes([0xce, mapping[f'game_18:{n}']]) for n in (26, 27, 28)) in parent
    assert parent.endswith(bytes.fromhex('1bcf6608cf66ad00'))
    # Original parent exit metadata targets release27/release8 before RNP.
    # The fixture's EXTERNAL calls preserve source order but do not bind this
    # nonlocal-exit epilogue; assert the original requirement independently.
    original_parent = source_frames['game_18:1']
    at = original_parent['exit_offset']
    assert originals['game_18'][at:at + 6] == bytes.fromhex('1b9e16089e16')
    # Constants >=128 use LDCI, rather than the short constant opcode.
    def constant(value):
        return bytes([value]) if value < 128 else bytes([0xc7, value & 255, value >> 8])

    # These CSP EXIT operations target their own fixture procedure in segment 1.
    for identity, count in [('game_18:10', 1), ('game_18:13', 3), ('game_18:14', 1),
                            ('library_22:51', 1), ('library_22:52', 1),
                            ('library_22:27', 3), ('game_18:27', 1), ('game_18:28', 1),
                            ('game_17:14', 1), ('game_19:12', 2), ('game_19:18', 2),
                            ('game_20:4', 2), ('game_20:13', 1),
                            ('game_20:23', 1), ('game_20:24', 1), ('game_20:25', 1),
                            ('game_20:27', 1), ('game_20:28', 1),
                            ('game_21:7', 1), ('game_21:15', 2), ('game_21:18', 1)]:
        assert body(identity).count(bytes([1]) + constant(mapping[identity]) + bytes([0x9e, 4])) == count
    # Game17 now has its recovered parent. Save/restore depend on the physical
    # child-local addresses: preserve both frame sizes and the LLA operands.
    original17 = procedure_attributes(originals['game_17'], records['game_17:1']['attribute_offset'], 1)
    assert frames[mapping['game_17:1']]['local_bytes'] == original17['local_bytes'] == 196
    assert frames[mapping['game_17:1']]['parameter_bytes'] == original17['parameter_bytes'] == 6
    assert frames[mapping['game_17:11']]['local_bytes'] == 4
    assert frames[mapping['game_17:12']]['local_bytes'] == 2
    # native_shared E116/E197..E1CC allocates below parent mark-2, then reserves
    # local bytes and a12-byte mark. D315 addresses child mark+10+2*slot.
    for local_bytes, slot in ((4, 2), (2, 1)):
        child_slot = -2 - local_bytes - 12 + 10 + 2 * slot
        assert (10 + 2 * 99) - child_slot == 212
    restore17 = body('game_17:11')
    save17 = body('game_17:12')
    assert bytes.fromhex('b201630000cf09c6020000cf0995cc02') in restore17
    assert bytes.fromhex('b6016400b2010400d99e02a50db2012ba804') in restore17
    assert bytes.fromhex('040000cf08cc01050000cf08cc02') in restore17
    assert bytes.fromhex('b2012ba50da804b201630000cf09c6010000cf0995cc01') in save17
    assert bytes.fromhex('b2010400b6016400d89e02') in save17
    parent17 = body('game_17:1')
    assert parent17.startswith(bytes([0xce, mapping['game_17:11']]))
    assert bytes([0xce, mapping['game_17:16'], 0xce, mapping['game_17:17']]) in parent17
    assert parent17.endswith(bytes([0xce, mapping['game_17:12'], 0xad, 0]))
    # Packed entry: five-word stride, high byte at word2, bit8 at word4.
    assert body('game_17:3').startswith(bytes.fromhex('b20104d8058fa401cc02'))
    assert bytes.fromhex('d9a2020808bacf03') in body('game_17:3')
    assert bytes.fromhex('a805') in body('game_17:4')
    assert bytes.fromhex('b2010d010801bb') in body('game_17:7')
    # Equipment scan reads the byte and invokes AND before the index<4 guard.
    assert bytes.fromhex('a5037ab6014d82be1f0000cf2d0bcba111b6014d04c9') in body('game_17:6')
    setup17 = body('game_17:9')
    assert setup17.startswith(bytes.fromhex('b201040046009e0a'))  # exactly70 bytes
    assert bytes.fromhex('0000cf04cc03da058ecc030000cf04cc02') in setup17
    assert bytes.fromhex('dca2040800d8dca2030800ba95bb') in setup17  # read radius after random
    scan17 = body('game_17:13')
    assert bytes.fromhex('0000cf04cc0ce2e3c780008e82cc0bdbe2c9') in scan17
    assert bytes.fromhex('daf8b6015ec9') in scan17  # strict count bound, before increment
    # Both coordinate distance calls execute before the two saved tests combine.
    assert bytes.fromhex('e5f9dd950000cf15e4c9cc09e5f8dc950000cf15e4c9cc08') in scan17
    assert bytes.fromhex('e1a2030808bacc050000cf04cc04dc04db108e8f95cc06') in body('game_17:14')
    assert bytes.fromhex('ac01000900b912') in body('game_17:15')
    update17 = body('game_17:16')
    # Flag48 and mode78 are saved before both unconditional input0/input1 calls.
    assert bytes.fromhex('a5570100bacc0bb6014e01c3cc0a000000cf08cc09010000cf08cc08') in update17
    assert bytes.fromhex('050000cf08cc06050000cf08cc07') in update17
    assert update17.count(bytes.fromhex('cf06')) == 2  # two movement attempts
    followers17 = body('game_17:17')
    assert bytes.fromhex('0000cf04cc03da078ecc04b20162b20161cf24') in followers17
    assert bytes.fromhex('0000cf04cc03daa1') in followers17  # low-bit random branch
    assert followers17.count(bytes.fromhex('cf06')) == 3
    # Delay destination still uses captured entry after the hit/removal call.
    assert (bytes([0xae, mapping['game_17:14']]) +
            bytes.fromhex('dda20408000adda2030800ba95bb')) in followers17
    # Amounts retain value copies, signed16-bit operations, and both ordered
    # sign-normalization branches. No conversion to a host-wide integer.
    amount = body('library_28:2')
    assert amount.startswith(bytes.fromhex('c603d9a802d8f9db82cc05'))
    assert bytes.fromhex('d8a201dcc7e8038e9adc00c9') in amount
    assert bytes.fromhex('d8dcc7e80386da82d8f8829a') in amount
    assert bytes.fromhex('c603d9a802db91cc06da91cc05c605d8') in body('library_28:3')
    assert bytes.fromhex('d80000cf13d8c7e8038e8f9a') in body('library_28:4')
    assert body('library_28:6').startswith(bytes.fromhex('c607daa802c605dba802'))
    # DATASEG30 starts at global459: labels1..64, counts65/66, items67.
    addbutton = body('library_25:3')
    assert bytes.fromhex('a9820b08c9') in addbutton
    assert bytes.fromhex('a9820c15c9') in addbutton
    assert bytes.fromhex('e60800ddbbe6010801bbe60409a9820bbb') in addbutton
    # Nested9's parent offsets must remain6/7 (base) and8/9 (caption position).
    assert frames[mapping['library_25:6']]['local_bytes'] == 22
    assert bytes.fromhex('b80109') in body('library_25:9')
    assert bytes.fromhex('b80108') in body('library_25:9')
    assert bytes.fromhex('b60107b6010982b60106b6010882cf10') in body('library_25:9')
    # Code output precedes index output; both distance calls run before tests.
    hit = body('library_25:7')
    assert hit.startswith(bytes.fromhex('d8009ad9009a'))
    assert bytes.fromhex('dbdffb950000cf1508c9cc07dadffa950000cf1508c9cc06') in hit
    assert bytes.fromhex('d9df0800ba9ad8dc9a') in hit
    flash = body('library_25:8')
    assert flash.startswith(bytes.fromhex('c606daa804'))
    assert bytes.fromhex('d9019ad8009a') in flash  # alias-sensitive button output
    assert bytes.fromhex('c60600cf1201cf0d') in flash  # area copy, not item bounds
    assert bytes.fromhex('e246c8') in flash and bytes.fromhex('e2e282e295cc0a') in flash
    assert bytes.fromhex('d9000000cf089ad8010000cf089ad9f8') in flash
    assert bytes.fromhex('e3a10e') in flash  # low-bit parity test of flash count
    # Game19's recovered parent retains its frame and ordered segment lifecycle.
    assert mapping['game_19:1'] == 164
    original19 = procedure_attributes(originals['game_19'], records['game_19:1']['attribute_offset'], 1)
    assert frames[164]['local_bytes'] == original19['local_bytes'] == 56
    assert frames[164]['parameter_bytes'] == original19['parameter_bytes'] == 2
    assert (bytes.fromhex('01b2011aa50db2011db2011d') +
            bytes([0xcf, mapping['library_25:8']])) in body('game_19:2')
    # System row word6/7 transfers preserve destination-first MOV2 directions.
    assert bytes.fromhex('b2010ad9a206a802d9a206b20108a802') in body('game_19:5')
    assert bytes.fromhex('a530b2010aa802b2010ab20108a802d9a206b2010aa802') in body('game_19:6')
    assert bytes.fromhex('d9a208040cbab8010ed9a2090400bab8010dd9a2090404bab8010c') in body('game_19:26')
    parent19 = body('game_19:1')
    assert parent19.startswith(bytes([25, 0xcf, 101, 28, 0xcf, 101, 0xce, mapping['game_19:26']]))
    assert parent19.endswith(bytes([28, 0xcf, 102, 25, 0xcf, 102, 0xad, 0]))
    at = original19['exit_offset']
    assert originals['game_19'][at:at + 6] == bytes.fromhex('1c9e16199e16')
    # Location update first copies all six words, then preserves spare packed bits.
    location19 = body('game_19:10')
    assert location19.startswith(bytes.fromhex('d8a526a806'))
    assert bytes.fromhex('dea202060009bbdea203050006bb') in location19
    assert bytes.fromhex('dea20508001abb') in location19
    # Timeout predicate saved before both unconditional input selectors0/1.
    transport = body('game_19:12')
    assert bytes.fromhex('ca1800c3cc1d000000cf08cc1e010000cf08cc1f') in transport
    assert bytes.fromhex('b20102b2010aa802') in transport
    assert transport.endswith(bytes.fromhex('a526c610a806ad00'))
    assert bytes.fromhex('b6011705823c8fcc050000cf04cc04dcdb3c8e82') in body('game_19:14')
    # Bank writeback uses the entry-captured row, not a freshly selected row.
    bank = body('game_19:17')
    assert bytes.fromhex('e100be09c8a105c602e1aa0e') in bank
    assert bank.endswith(bytes.fromhex('e1a206b2010aa802ad00'))
    # Both purchase-loop polling sites execute unconditionally at their sites.
    purchase = body('game_19:18')
    assert purchase.count(bytes.fromhex('010000cf08cc3a')) == 2
    assert bytes.fromhex('cc39010000cf08cc3aca39') in purchase
    assert bytes.fromhex('d8d8f801829ac627b2010acf97') in purchase
    # Nested display captures no-units before comparing the two-word price.
    assert bytes.fromhex('b6012900c3cc02b20127b2020a0000cf9acc01') in body('game_19:19')
    assert bytes.fromhex('b2011fcf29') in body('game_19:19')  # remapped unit-name copy
    # Stock writes: category bits5..7, origin byte, kind bits0..4; word1 untouched.
    assert bytes.fromhex('dc030507bbdc0808a5270504babbdc050001bb') in body('game_19:24')
    # Game20's recovered parent retains its328-byte overlapping storage.
    assert mapping['game_20:1'] == 190
    original20 = procedure_attributes(originals['game_20'], records['game_20:1']['attribute_offset'], 1)
    assert frames[190]['local_bytes'] == original20['local_bytes'] == 328
    assert frames[190]['parameter_bytes'] == original20['parameter_bytes'] == 2
    assert bytes.fromhex('000000cf08cc02010000cf08cc01') in body('game_20:2')
    # Full14-byte SCAN and separate bonus162/cash164 addresses. The compiler
    # only distinguishes8 characters; names must not alias these amount fields.
    phase20 = body('game_20:4')
    assert phase20.startswith(bytes.fromhex('0e0100b2011600009e0b'))
    assert bytes.fromhex('b20180a2b20180a4cf96') in phase20
    assert body('game_20:32').startswith(bytes.fromhex('b20180a00000cf98'))
    disk20 = body('game_20:3')
    assert bytes.fromhex('b60115c72001b6011400369e02') in disk20
    assert bytes.fromhex('b60115dcb2011600da9e02') in disk20
    assert bytes.fromhex('b2011600b60115dcda9e02') in disk20
    setup20 = body('game_20:5')
    assert bytes.fromhex('c70014b20112cf2c') in setup20
    assert bytes.fromhex('c70058b20113cf2c') in setup20
    assert setup20.count(bytes.fromhex('b70c07')) == 2  # include padding
    assert bytes.fromhex('b20116000e009e0a') in setup20
    assert setup20.count(bytes.fromhex('0000cf04cc04')) == 2  # two random sites
    assert bytes.fromhex('b20180a4a530a802') in setup20
    assert bytes.fromhex('dda206b20180a0a802') in setup20
    assert body('game_20:6').startswith(bytes.fromhex('c603d9a807'))
    assert bytes.fromhex('b6010382cc0a') in body('game_20:6')
    # Timer increment/check precedes cursor update in the menu loop.
    assert bytes.fromhex('a981640182ab8164a981640ac4a102cf44c60dc60ccf24') in body('game_20:8')
    assert bytes.fromhex('01c60da50dc60ec60ecfa3') in body('game_20:10')
    assert frames[mapping['game_20:13']]['local_bytes'] == 22
    warehouse20 = body('game_20:13')
    assert bytes.fromhex('c60a0004009e0a') in warehouse20
    assert warehouse20.count(bytes.fromhex('a802')) == 5
    assert bytes.fromhex('b60106') in body('game_20:14')
    assert bytes.fromhex('b60107') in body('game_20:14')
    # Price scaling retains the equality threshold and both division orders.
    scale20 = body('game_20:18')
    assert scale20.startswith(bytes.fromhex('c7ff7fdc86dbc8'))
    assert bytes.fromhex('dcdbda868f') in scale20
    assert bytes.fromhex('dcdb8fda86') in scale20
    assert body('game_20:16').startswith(bytes.fromhex('c605dba802'))
    assert bytes.fromhex('b8010a') in body('game_20:19')
    assert bytes.fromhex('b80109') in body('game_20:19')
    # Offers retain seven-word copies including padding, and capture the
    # availability value before the unconditional random call on loop exit.
    offer20 = body('game_20:21')
    assert offer20.count(bytes.fromhex('a807')) == 2
    assert bytes.fromhex('c00503bacc1d0000cf04cc1b') in offer20
    assert bytes.fromhex('b2018090') in offer20
    assert bytes.fromhex('b2013c') in offer20
    # The caption's length is forced to14 using STB, after SAS15 and padding.
    assert bytes.fromhex('db000ebf') in body('game_20:23')
    assert bytes.fromhex('b20180a4da0000cf9a') in body('game_20:23')
    # Even the unused value amount is copied before procedure24's effects.
    assert body('game_20:24').startswith(bytes.fromhex('c605d9a802da009a'))
    # Failed capacity still polls input1. This path returns normally; only
    # cancelling the inner selection uses the explicit self EXIT above.
    assert body('game_20:27').startswith(bytes.fromhex('c6070000aed8cc14010000cf08cc15'))
    # Menu flash aliases both outputs, then polling snapshots selected first.
    assert bytes.fromhex('c609c603c603cfa3') in body('game_20:30')
    assert bytes.fromhex('dacc0d010000cf08cc0e') in body('game_20:30')
    # Heading uses a9-character gate and retains the callee's SAS15 check.
    assert bytes.fromhex('be09c8') in body('game_20:31')
    assert body('game_20:10').startswith(bytes.fromhex('c605dbaa0f'))
    parent20 = body('game_20:1')
    assert parent20.startswith(bytes([25, 0xcf, 101, 28, 0xcf, 101, 0xce, mapping['game_20:32']]))
    assert parent20.endswith(bytes([28, 0xcf, 102, 25, 0xcf, 102, 0xad, 0]))
    at = original20['exit_offset']
    assert originals['game_20'][at:at + 6] == bytes.fromhex('1c9e16199e16')
    # Game21's parent is still scaffolding, with eight VAR parameter words
    # and114 local bytes. It must not inflate recovered-body coverage.
    assert 'game_21:1' not in mapping
    original21 = procedure_attributes(originals['game_21'], records['game_21:1']['attribute_offset'], 1)
    assert frames[222]['local_bytes'] == original21['local_bytes'] == 114
    assert frames[222]['parameter_bytes'] == original21['parameter_bytes'] == 16
    # Parent26 controls glyph parity with a low-bit branch, not a nonzero test.
    assert bytes.fromhex('b6011aa107b6011fcf03') in body('game_21:5')
    # Six-word location copies precede any effects; whole-location transfers
    # preserve spare bits and have opposite directions for park and restore.
    assert body('game_21:7').startswith(bytes.fromhex('c604daa806'))
    assert body('game_21:13').startswith(bytes.fromhex('c604d8a806'))
    assert bytes.fromhex('a580e6a526a806') in body('game_21:6')
    assert bytes.fromhex('a526a580e6a806') in body('game_21:16')
    # Nested20 reads parent19 slots5/4 and executes both proximity calls
    # before testing its enabled argument. Parent19 keeps its28-byte locals.
    assert frames[mapping['game_21:19']]['local_bytes'] == 28
    assert body('game_21:20').startswith(bytes.fromhex(
        'b60105db040000aee9cc07b60104da040000aee9cc06dc'))
    # VAR output is copied through enclosing arg1 and then reread.
    assert bytes.fromhex('b60101d8f89ab60101f8') in body('game_21:16')
    # Map rows are20 words/40 bytes. Preceding flags are saved, and both
    # nearby-location calls run before their combined condition is tested.
    transitions21 = body('game_21:21')
    assert bytes.fromhex('b60102b60137d9148fa401dabe9a') in transitions21
    assert bytes.fromhex(
        'cc06daa580e80600ba010000aee9cc05d9a580e90500ba010000aee9cc04') in transitions21
    # Distinct16-byte glyph buffers at slots39/47, preserving first-eight
    # character identifier uniqueness and the literal character lookup tables.
    assert bytes.fromhex('b201270eaef1b2012f0faef1') in body('game_21:23')
    assert b'ABAA' in body('game_21:19') and b'OPOU' in body('game_21:19')
    # Preserve the surprising repeated parent15 source, and probe the search
    # candidate after counter/radius update with the original low-bit result.
    placement21 = body('game_21:25')
    assert bytes.fromhex('b6010fb8011ab6010fb80119') in placement21
    assert bytes.fromhex('b6011db6011ab601190000aee693a1') in placement21
    # Map selection keeps the native mask call per cell and row advance7.
    assert bytes.fromhex('b60137dd148fa401dcbe0f0000cf2d') in body('game_21:32')
    assert bytes.fromhex('da0782cc03') in body('game_21:32')
    # Nested34 retains parent bases5/4. Native5 fills adjacent local words;
    # both drawings precede ordered VAR stores, including when outputs alias.
    assert bytes.fromhex('b60105019506d98f82b6010407d88f82') in body('game_21:34')
    assert body('game_21:35').startswith(bytes.fromhex('c603cf0ada0786cc03db0886cc04'))
    assert bytes.fromhex('d9f8d8f8aef7dadbaef7d9da9ad8db9a') in body('game_21:35')
    # Capture the first polling result before the unconditional second call;
    # the original output is read again after the loop, not replaced by saved.
    select21 = body('game_21:33')
    assert bytes.fromhex('d8000000cf089ad8f8cc06010000cf08cc07') in select21
    assert bytes.fromhex('d8f8a11800ab2a') in select21
    # Expired timeout cannot suppress either input call on insufficient funds.
    funds21 = body('game_21:37')
    assert b'||Insufficient funds' in funds21
    assert bytes.fromhex('db00c3cc05000000cf08cc06010000cf08cc07') in funds21
    # Status update precedes cursor refresh, followed by a fresh mode read.
    assert body('game_21:41').startswith(bytes.fromhex(
        'b60113b60112cf16b60104f8b60103f8cf53b20113b20112a9812cb2013ecf21'))
    print(f"Verified source/output hashes, {len(mapping)} interfaces, "
          f"{len(receipt['exact_body_matches'])} exact bodies, call order, storage views, copies, fills, and EXIT targets.")


if __name__ == '__main__':
    main()
