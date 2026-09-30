"""Normalize the audited Game16 records into browser dialogue data.

This consumes classified source operations, not opaque disk/code bytes. Execution
of predicates, rendering and transaction actions belongs to later runtime work.
"""


def dialogue_records(audit):
    def normalize(record):
        units = iter(record['units'])

        def take(expected=None):
            unit = next(units)
            op, args = unit['operation'], unit['operands']
            if expected is not None and op != expected:
                raise ValueError(f'Expected {expected}, found {op}')
            return op, args

        _, (mode, replies, delay, controls) = take('begin')
        redirect = bool(mode & 2 and replies == 0)
        prefix = 'state_' if redirect else 'text_'
        op, args = take()
        if op == 'say' and not redirect:
            selection = dict(kind='literal', value=args[0])
        elif op == prefix + 'random':
            selection = dict(kind='random', values=[take('value')[1][0] for _ in range(args[0])])
        elif op == prefix + 'conditional':
            choices = []
            for _ in range(args[0] - 1):
                _, (value, predicate) = take('test')
                choices.append(dict(value=value, predicate=predicate))
            selection = dict(kind='conditional', choices=choices, fallback=take('default')[1][0])
        elif op in [prefix + f'mood{i}' for i in (20, 21, 22, 23)]:
            code = int(op[-2:])
            # Proc24 $09D4 reads this into the RESULT, never into predicate8.
            # If outer local20 is false it survives as the selected value.
            fallback = take('condition')[1][0] if code == 21 else None
            selection = dict(kind='mood', code=code, fallback=fallback,
                             values=[take('value')[1][0] for _ in range(4 if code == 23 else 3)])
        else:
            raise ValueError(f'Unsupported dialogue selector: {op}')

        def transition(state, conditional):
            unless = None
            if conditional:
                op, args = take()
                if op == 'override':
                    unless = dict(predicate=args[0], state=args[1])
                elif op != 'no_override':
                    raise ValueError('Invalid transition override')
            return dict(state=state, unless=unless)

        transitions, options = [], []
        if not redirect:
            for _ in range(2):
                transitions.append(transition(take('next')[1][0], bool(mode & 1)))
            for _ in range(replies):
                _, (caption, state) = take('reply')
                options.append(dict(caption=caption, transition=transition(state, bool(mode & 2))))
        action = None
        if mode >= 8:
            op, args = take()
            if op not in [f'action{i}' for i in range(8)]:
                raise ValueError('Invalid dialogue action')
            action = dict(opcode=int(op[-1]), operands=args)
        if next(units, None) is not None or redirect != record['early_exit']:
            raise ValueError('Unconsumed or inconsistent dialogue record')
        return dict(offset=record['start'], end=record['end'], mode=mode,
                    delayUnits=delay * 2, controls=controls, redirect=redirect,
                    selection=selection, transitions=transitions, replies=options, action=action)

    banks = [dict(block=b['block'], entries=b['entries'],
                  records=[normalize(r) for r in b['records']]) for b in audit['banks']]
    if [b['block'] for b in banks] != list(range(90, 103)):
        raise ValueError('Expected the thirteen classified dialogue banks')
    return dict(version=1, source='game_16 procedures23–29/34; docs/reference/dialogue-scripts.json', banks=banks)


def dialogue_text(dictionary, messages, storage):
    def field(value):
        return dict(text=value['stored_characters'], spaces=value['high_bit_positions'])
    base = next(d for d in dictionary if d['kind'] == 'base')['fields']['entries']
    supplements = {str(d['block']): [field(e) for e in d['fields']['entries']]
                   for d in dictionary if d['kind'] == 'supplement'}
    records = messages + [f for f in storage if f['kind'] == 'message']
    banks = {str(block): {} for block in range(90, 103)}
    for record in records:
        bank, word = str(record['block']), str(record['bank_offset'] // 2)
        if record['bank_offset'] % 2 or word in banks[bank]:
            raise ValueError('Duplicate or unaligned dialogue message')
        banks[bank][word] = field(record)
    if len(base) != 64 or any(e['stored_characters'] for e in base[52:]):
        raise ValueError('Unexpected supplemental dictionary boundary')
    return dict(version=1, source='game_16 procedures13–22/32; classified dialogue text assets',
                base=[field(e) for e in base], supplementStart=52, supplements=supplements, messages=banks)


def dialogue_systems(defaults):
    if len(defaults) != 1440:
        raise ValueError('Expected shipped world defaults')
    # Utility12 clears system word5 bit7 and word9 high nibble. Never export
    # the saved working values of those mutable fields as new-game defaults.
    systems = []
    for i in range(12):
        record = defaults[i * 20:(i + 1) * 20]
        systems.append(dict(id=f'system-{i+1:02}', local16=False, local29=0,
                            local30=record[18] & 15, local31=record[18] >> 4,
                            local32=record[17] >> 4))
    return dict(version=1, source='utility_disk1 procedure12; game_16 procedure37', systems=systems)
