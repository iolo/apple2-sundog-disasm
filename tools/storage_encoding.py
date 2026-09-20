"""Reversible on-disk encoding for reconstructed native source components."""


def validate_encoding(spec):
    if (not isinstance(spec,dict) or set(spec)!={'kind','seed','step','offset','evidence'}
            or spec['kind']!='additive-byte-sequence' or not isinstance(spec['evidence'],str)
            or not spec['evidence']):
        raise ValueError('Unsupported or undocumented storage encoding')
    for field in ('seed','step'):
        if type(spec[field]) is not int or not 0<=spec[field]<=255:
            raise ValueError('Encoding seed/step must be bytes')
    if type(spec['offset']) is not int or spec['offset']<0:
        raise ValueError('Encoding offset must be nonnegative')


def transform(data,spec,*,decode=False):
    validate_encoding(spec)
    sign = 1 if decode else -1
    return bytes((byte+sign*(spec['seed']+(spec['offset']+i)*spec['step']))&255
                 for i,byte in enumerate(data))
