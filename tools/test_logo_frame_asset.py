import unittest

from logo_frame_asset import unpack_frames, pack_frames


class LogoFrameTests(unittest.TestCase):
    def test_stride_and_full_byte_preservation(self):
        raw = bytearray(6144)
        raw[0:4] = bytes([1,2,128,255])
        raw[95] = 42
        raw[128] = 73
        raw[1024] = 91
        rows = unpack_frames(raw)
        self.assertEqual(rows[0][0],[1,2,128,255])
        self.assertEqual(rows[0][23][3],42)
        self.assertEqual(rows[1][0][0],73)
        self.assertEqual(rows[8][0][0],91)
        self.assertEqual(pack_frames(rows),raw)

    def test_nonzero_padding_is_not_silently_dropped(self):
        for offset in (96,127,6143):
            raw = bytearray(6144)
            raw[offset] = 1
            with self.assertRaises(ValueError):
                unpack_frames(raw)

    def test_invalid_extent_and_row_shape(self):
        with self.assertRaises(ValueError):
            unpack_frames(bytes(6143))
        rows = unpack_frames(bytes(6144))
        rows[0].pop()
        with self.assertRaises(ValueError):
            pack_frames(rows)


if __name__ == '__main__':
    unittest.main()
