"""Validate the interpreter relocation base and its four address-vector fields."""
import json
import struct

from disk_layout import ROOT, sha

EVIDENCE = ROOT/'src/native/evidence/interpreter_linkage.json'
VALUES = (0xd1af, 0xd1fb, 0xff00, 0xbdde, 0x007e)


def audit_linkage(primitives, shared, high):
    if (len(primitives),len(shared),len(high)) != (4325,4523,2160):
        raise ValueError('Native component bounds differ')
    evidence = json.loads(EVIDENCE.read_text())
    raw = primitives[0x1ad:0x1b7]
    if struct.unpack('<5H',raw) != VALUES or raw.hex() != evidence['hex']:
        raise ValueError('Interpreter linkage pointer/vector fields differ')
    fields = evidence['fields']
    if [(f['offset'],f['size'],f['value']) for f in fields] != [(i*2,2,v) for i,v in enumerate(VALUES)]:
        raise ValueError('Linkage field boundaries differ')
    images = dict(pcode_primitives=(0xd000,primitives),native_shared=(0xe0e5,shared),
                  native_high=(0xf790,high))
    for window in evidence['windows']:
        base,binary = images[window['component']]
        offset = window['address']-base
        expected = bytes.fromhex(window['hex'])
        if (window['base'] != base or len(expected) != window['size']
                or offset < 0 or binary[offset:offset+window['size']] != expected):
            raise ValueError('Reviewed linkage consumer/target window differs')
    # Independently pin the pointer load and final relocation call, rather than
    # relying only on a copied evidence window.
    consumer = shared[0xe626-0xe0e5:0xe633-0xe0e5]
    if consumer != bytes.fromhex('adadd18592adaed1859320fde3'):
        raise ValueError('Interpreter relocation base setup differs')
    historical = bytes.fromhex(evidence['historical']['descriptor_hex'])
    if historical[:8] != raw[:8] or historical[8:] != b'\x74\0':
        raise ValueError('Historical vector layout correspondence differs')
    return dict(classification='data',classification_evidence='docs/interpreter-linkage.md',
                address=0xd1ad,size=10,sha256=sha(raw),
                fields=[dict(f,address=0xd1ad+f['offset']) for f in fields],
                relocation_base=VALUES[0],relocation_call=0xe630,relocation_routine=0xe3fd,
                checked_windows=len(evidence['windows']),
                live_use_of_every_vector_claimed=False,unresolved_descriptor_bytes=0)
