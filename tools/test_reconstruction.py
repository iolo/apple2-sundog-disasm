"""Ensure partial reconstruction cannot silently omit, overlap, or truncate bytes."""
import copy
from pathlib import Path
import tempfile
import unittest

from build_disks import compose_image, contained_file
from verify_disks import describe_offset, difference


class ReconstructionTests(unittest.TestCase):
    def setUp(self):
        self.components = {"code": bytes.fromhex("01 e0 60"), "remainder": b"abcde"}
        self.disk = {"size": 8, "regions": [
            {"offset": 0, "size": 3, "input": "code", "input_offset": 0},
            {"offset": 3, "size": 5, "input": "remainder", "input_offset": 0}]}

    def test_full_coverage_and_invalid_mapping(self):
        self.assertEqual(compose_image(self.disk, self.components), b"\x01\xe0\x60abcde")
        for field, value in [("offset", 2), ("offset", 4), ("size", 0), ("size", 6),
                             ("input_offset", -1), ("input_offset", 1)]:
            with self.subTest(field=field, value=value):
                bad = copy.deepcopy(self.disk)
                bad["regions"][1][field] = value
                with self.assertRaises(ValueError):
                    compose_image(bad, self.components)
        bad = copy.deepcopy(self.disk)
        bad["regions"].pop()
        with self.assertRaises(ValueError):
            compose_image(bad, self.components)

    def test_mismatch_including_truncation_and_sector_mapping(self):
        self.assertIsNone(difference(b"abc", b"abc"))
        self.assertEqual(difference(b"abc", b"adc"), 1)
        self.assertEqual(difference(b"abc", b"ab"), 2)
        self.assertEqual(difference(b"abc", b"abcd"), 3)
        disk = {"size": 143360, "regions": [
            {"offset": 0xE00, "size": 256, "input": "bootstrap"}]}
        detail = describe_offset(disk, 0xE07)
        self.assertIn("logical block 0, half 1, byte 7", detail)
        self.assertIn("component bootstrap", detail)
        self.assertEqual(describe_offset(disk, 143360), "past expected end of image")

    def test_missing_or_escaping_temporary_input(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            (root / "good.bin").write_bytes(b"ok")
            self.assertEqual(contained_file(root, "good.bin").read_bytes(), b"ok")
            for name in ("missing.bin", "../escape.bin"):
                with self.assertRaises(ValueError):
                    contained_file(root, name)


if __name__ == "__main__":
    unittest.main()
