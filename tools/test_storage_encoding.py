import unittest

from storage_encoding import transform
from adopt_component import replacement_plan
from disk_layout import sha


def encoding(seed=189,step=243,offset=0):
    return dict(kind='additive-byte-sequence',seed=seed,step=step,offset=offset,
                evidence='docs/encoded-native-overlay.md')


class StorageEncodingTests(unittest.TestCase):
    def test_known_loader_bytes_and_complete_byte_domain(self):
        stored = bytes.fromhex('ec506513d70991beab')
        plain = bytes.fromhex('a90008a96085002000')
        self.assertEqual(transform(stored,encoding(),decode=True),plain)
        self.assertEqual(transform(plain,encoding()),stored)
        for spec in (encoding(),encoding(251,185),encoding(255,0),encoding(0,255)):
            data = bytes(range(256))*8
            self.assertEqual(transform(transform(data,spec),spec,decode=True),data)

    def test_split_encoding_keeps_stream_phase(self):
        data = bytes(range(256))*8
        whole = transform(data,encoding())
        self.assertEqual(transform(data[:317],encoding())+
                         transform(data[317:],encoding(offset=317)),whole)

    def test_adoption_preserves_encoding_and_rejects_wrong_plaintext(self):
        plain = bytes.fromhex('a9000860')
        stored = transform(plain,encoding())
        manifest = dict(components={'raw':dict(kind='temporary-unresolved',path='raw.bin')},
                        disks=[dict(id='disk2',size=4,sha256=sha(stored),
                                    regions=[dict(offset=0,size=4,input='raw',input_offset=0)])])
        recipe = dict(name='encrypted',source='code.s',config='code.cfg',storage_encoding=encoding(),
                      mappings=[dict(disk='disk2',offset=0,size=4,input_offset=0)])
        planned,_ = replacement_plan(manifest,{'disk2':stored},recipe,stored)
        self.assertEqual(planned['components']['encrypted']['storage_encoding'],encoding())
        with self.assertRaises(ValueError):
            replacement_plan(manifest,{'disk2':stored},recipe,plain)

    def test_invalid_encoding_is_rejected(self):
        for key,value in [('seed',256),('step',True),('offset',-1),('kind','guess'),('evidence','')]:
            spec = encoding()
            spec[key] = value
            with self.assertRaises(ValueError):
                transform(b'\x00',spec)


if __name__=='__main__':
    unittest.main()
