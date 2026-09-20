import unittest

from working_state_asset import decode, encode, LAYOUTS


class WorkingStateTests(unittest.TestCase):
    def test_template_boundary_and_selector_are_independent(self):
        raw = bytes(range(252))*2 + b'\x17'
        fields = decode(raw,'record_templates')
        self.assertEqual(len(fields['templates']),18)
        self.assertEqual(len(fields['templates'][0]),14)
        self.assertEqual(fields['selector'],23)
        fields['selector'] = 7
        self.assertEqual(encode(fields,'record_templates'),raw[:504]+b'\x07')

    def test_all_word_layouts_round_trip(self):
        for kind,layout in LAYOUTS.items():
            with self.subTest(kind=kind):
                raw = bytes((i*37+11)%256 for i in range(sum(size for _,size,_ in layout)))
                self.assertEqual(encode(decode(raw,kind),kind),raw)

    def test_unreviewed_tails_and_bad_field_shapes_are_rejected(self):
        with self.assertRaises(ValueError):
            decode(bytes(512),'record_templates')
        fields = decode(bytes(3072),'working_records')
        fields['records32'].pop()
        with self.assertRaises(ValueError):
            encode(fields,'working_records')
        fields = decode(bytes(505),'record_templates')
        fields['selector'] = 256
        with self.assertRaises(ValueError):
            encode(fields,'record_templates')


if __name__ == '__main__':
    unittest.main()
