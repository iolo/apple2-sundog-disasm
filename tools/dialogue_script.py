"""Decode dialogue records using game 16 procedures 15, 23–29.

This is the game's custom script format, not UCSD p-code or 6502 code.
The parser never assigns unvisited bank bytes a classification.
"""
import re

# Macro argument counts and emitted bytes. Expressions use ca65 syntax.
ENCODINGS = {
    'begin': (4, '((a << 4) | (b << 2) | c), d'),
    'entry': (1, 'a'), 'say': (1, 'a'), 'value': (1, 'a'),
    'condition': (1, 'a'), 'test': (2, 'a, b'), 'default': (1, 'a'),
    'next': (1, 'a'), 'reply': (2, 'a, b'),
    'no_override': (0, '0'), 'override': (2, 'a, b'),
}
for context in ('text','state'):
    ENCODINGS[context+'_random'] = (1,'a')
    ENCODINGS[context+'_conditional'] = (1,'10+a')
    for value in (20,21,22,23):
        ENCODINGS[context+'_mood'+str(value)] = (0,str(value))
ACTION_ARGS = {0:0,1:1,2:2,3:4,4:0,5:1,6:1,7:1}
for action,count in ACTION_ARGS.items():
    ENCODINGS['action'+str(action)] = (count,', '.join([str(action)]+list('abcd'[:count])))


def parse_record(bank, start):
    if len(bank)!=512 or type(start) is not int or not 16 <= start < 256:
        raise ValueError('Expected a block and an entry in its first 256 bytes')
    cursor, units, text_refs, state_refs = start, [], set(), set()

    def read(count):
        nonlocal cursor
        if cursor+count>512:
            raise ValueError('Script operand exceeds bank')
        values = list(bank[cursor:cursor+count])
        cursor += count
        return values

    def unit(name,args,offset,size):
        if name not in ENCODINGS or len(args)!=ENCODINGS[name][0]:
            raise ValueError('Unsupported script operation')
        units.append(dict(offset=offset,size=size,operation=name,operands=args))

    def field(name,count):
        offset = cursor
        values = read(count)
        unit(name,values,offset,count)
        return values

    def selector(context):
        offset = cursor
        lead = read(1)[0]
        refs = text_refs if context=='text' else state_refs
        if context=='text' and lead>=30:
            unit('say',[lead],offset,1)
            refs.add(lead)
        elif 1<=lead<=10:
            unit(context+'_random',[lead],offset,1)
            for _ in range(lead):
                refs.add(field('value',1)[0])
        elif lead in (20,21,22,23):
            unit(context+'_mood'+str(lead),[],offset,1)
            if lead==21:
                field('condition',1)
            for _ in range(4 if lead==23 else 3):
                refs.add(field('value',1)[0])
        elif 11<=lead<=29:
            count = lead-10
            unit(context+'_conditional',[count],offset,1)
            for _ in range(count-1):
                value,_ = field('test',2)
                refs.add(value)
            refs.add(field('default',1)[0])
        else:
            raise ValueError(f'Unsupported/invalid {context} selector {lead} at {offset}')

    def override():
        offset = cursor
        condition = read(1)[0]
        if condition:
            value = read(1)[0]
            state_refs.add(value)
            unit('override',[condition,value],offset,2)
        else:
            unit('no_override',[],offset,1)

    def action():
        offset = cursor
        kind = read(1)[0]
        if kind not in ACTION_ARGS:
            raise ValueError('Unreviewed action selector')
        args = read(ACTION_ARGS[kind])
        unit('action'+str(kind),args,offset,1+len(args))
        if kind in (1,2,3):
            state_refs.update(args[:1 if kind==1 else 2])

    header,controls = read(2)
    mode,options,delay = header>>4,(header>>2)&3,header&3
    unit('begin',[mode,options,delay,controls],start,2)
    early_exit = bool(mode&2 and options==0)
    if early_exit:
        selector('state')
        if mode>=8:
            action()
        # Game 16 $0DAC–$0DAE invokes CSP 4 EXIT(16,23), so no text follows.
    else:
        selector('text')
        for _ in range(2):
            state_refs.add(field('next',1)[0])
            if mode&1:
                override()
        for _ in range(options):
            _,target = field('reply',2)
            state_refs.add(target)
            if mode&2:
                override()
        if mode>=8:
            action()
    return dict(start=start,end=cursor,early_exit=early_exit,units=units,
                text_words=sorted(text_refs),state_values=sorted(state_refs))


def analyze_bank(bank):
    if len(bank)!=512 or bank[0] not in (16,18):
        raise ValueError('Unsupported dialogue bank layout')
    roots = sorted(set(bank[:16])-{0})
    lower = bank[0]
    upper = bank[17]*2 if lower==18 else 512
    records, occupied = [], set(range(lower))
    for root in roots:
        record = parse_record(bank,root)
        selected = set(range(root,record['end']))
        if root<lower or record['end']>upper or selected & occupied:
            raise ValueError('Script overlaps metadata, another entry, or supplemental text')
        if records and records[-1]['end']!=root:
            raise ValueError('Unreviewed gap between script entry boundaries')
        occupied.update(selected)
        records.append(record)
    text_records = []
    refs = sorted({word for record in records for word in record['text_words']})
    for word in refs:
        offset = word*2
        if offset>=512:
            raise ValueError('Text address exceeds bank')
        end = offset+1+bank[offset]
        aligned_end = end+(end&1)
        selected = set(range(offset,aligned_end))
        if aligned_end>512 or selected & occupied:
            raise ValueError('Referenced text overlaps code/metadata/text or exceeds bank')
        if aligned_end>end and bank[end]!=0:
            raise ValueError('Nonzero unreviewed text-record alignment')
        occupied.update(selected)
        text_records.append(dict(offset=offset,end=aligned_end,length=bank[offset],
                                 alignment_bytes=aligned_end-end))
    return dict(entries=list(bank[:16]),records=records,text_records=text_records)


def macro_source():
    lines = ['; Custom dialogue script encoding; see docs/dialogue-scripts.md.']
    for name,(count,expression) in ENCODINGS.items():
        expression = re.sub(r'\b([abcd])\b',lambda m:'arg'+str('abcd'.index(m[1])),expression)
        lines += ['.macro d_'+name+(' '+', '.join('arg'+str(i) for i in range(count)) if count else ''),
                  '    .byte '+expression,'.endmacro','']
    return '\n'.join(lines)
