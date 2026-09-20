#!/usr/bin/env python3
"""Classify the retained native footer, linker records and file-version word."""
from disk_layout import sha
from native_relocations import native_relocations
from pascal_inventory import procedure_dictionary

EVIDENCE = 'docs/native-high-metadata.md'


def audit_metadata(high, initializer, io_bank, primitives, shared):
    if (len(high),len(initializer),len(io_bank),len(primitives),len(shared)) != (2160,1280,4096,4325,4523):
        raise ValueError('Native component extents differ')
    # Bank 2 and common memory form the original contiguous D000-F79F
    # native container. The primitive component also owns E000-E0E4.
    container = io_bank+primitives[4096:]+shared+initializer+high[:16]
    if len(container) != 0x27a0:
        raise ValueError('Native container extent differs')
    dictionary = procedure_dictionary(container,1)
    if not dictionary['valid'] or dictionary['procedure_count'] != 1:
        raise ValueError('Expected one native procedure in retained container')
    proc = dictionary['procedures'][0]
    if (proc['representation'] != 'native-6502' or proc['entry_offset'] != 0
            or proc['attribute_offset'] != 0x279a or proc['lexical_level'] != 0):
        raise ValueError('Native entry or attributes differ')
    relocations = native_relocations(container,proc)
    if relocations['tables_start'] != 0x2790 or any(g['count'] for g in relocations['groups']):
        raise ValueError('Native footer relocation counts differ')
    if initializer[0x30f:0x311] != bytes.fromhex('a0 03') or high[16:112] != initializer[0x310:0x370]:
        raise ValueError('Retained LDY operand/instruction copy differs')
    expected = [(b'THISISIT',11,[1,0,0],'SEPPROC'),
                (b'THISISIT',6,[1,0,0],'GLOBDEF'),
                (b'        ',0,[0,0,0],'EOFMARK')]
    records = []
    for index,(name,kind,fields,kind_name) in enumerate(expected):
        offset = 0x70+index*16
        raw = high[offset:offset+16]
        values = [int.from_bytes(raw[p:p+2],'little') for p in range(8,16,2)]
        if raw[:8] != name or values != [kind,*fields]:
            raise ValueError('Retained linker record differs from reviewed fields')
        records.append(dict(address=0xf800+index*16,size=16,name=name.decode('ascii'),
                            kind=kind_name,type_word=kind,fields=fields))
    if any(high[0xa0:0x270]):
        raise ValueError('Nonzero remainder in linker-information block')
    version = int.from_bytes(high[0x866:0x868],'little')
    if version != 3:
        raise ValueError('Stored SYSTEM.APPLE version word differs')
    return dict(classification_evidence=EVIDENCE,
        native_container=dict(start_address=0xd000,end_address_exclusive=0xf7a0,
            sha256=sha(container),procedure=proc,relocations=relocations),
        instruction_fragment=dict(address=0xf7a0,size=1,classification='code',
            assembly='LDY #$03 immediate operand; opcode is outside this retained copy',
            original_instruction_address=0xf59f,copied_instruction_address=0x6b0f,
            original_instruction_hex='a003'),
        linker_records=records,linker_block_zero_storage=dict(address=0xf830,size=464),
        file_version=dict(address=0xfff6,size=2,value=version,
            meaning='Stored SYSTEM.APPLE version word; no release-name mapping asserted'),
        unresolved_preservation_ranges=[])
