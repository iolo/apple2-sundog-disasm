"""Boundary checks for exact-byte preservation and disk mapping."""
import copy
from pathlib import Path
import tempfile
import unittest

from disk_layout import (ROOT, IMAGE_SIZE, block_bytes, directory,
                         logical_sector_offset, reconstruct, sha)


class DiskLayoutTests(unittest.TestCase):
    def test_sector_mapping_covers_each_byte_once(self):
        offsets = [logical_sector_offset(i) for i in range(560)]
        self.assertEqual(sorted(offsets), list(range(0, IMAGE_SIZE, 256)))
        self.assertEqual(offsets[:4], [0, 0xE00, 0xD00, 0xC00])
        self.assertEqual(offsets[158:164], [0x9100, 0x9F00, 0xA000, 0xAE00, 0xAD00, 0xAC00])
        with self.assertRaises(ValueError):
            logical_sector_offset(560)

    def test_directory_and_loader_anchors(self):
        image = (ROOT / "sundog-disk1-game.dsk").read_bytes()
        candidate = directory(image, 79)
        self.assertEqual(candidate["volume"], "SUNDOG")
        self.assertEqual(candidate["files"][-1]["name"], "SYSTEM.PASCAL")
        self.assertEqual(candidate["files"][-1]["end_block"], 280)
        self.assertEqual(block_bytes(image, 219, 220)[:8], bytes.fromhex("08 48 a5 ff 48 28 ea 78"))
        with self.assertRaises(ValueError):
            directory(image, 2)

    def test_track_integrity_and_complete_coverage(self):
        with tempfile.TemporaryDirectory() as temporary:
            folder = Path(temporary)
            image = bytes(i % 251 for i in range(IMAGE_SIZE))
            records = []
            for track in range(35):
                data = image[track * 4096:(track + 1) * 4096]
                name = f"{track}.bin"
                (folder / name).write_bytes(data)
                records.append(dict(offset=track * 4096, size=4096, path=name, sha256=sha(data)))
            disk = dict(tracks=records, size=IMAGE_SIZE, sha256=sha(image))
            self.assertEqual(reconstruct(folder, disk), image)
            disk["tracks"].reverse()
            self.assertEqual(reconstruct(folder, disk), image)
            duplicate = copy.deepcopy(disk)
            duplicate["tracks"][0] = duplicate["tracks"][1]
            with self.assertRaises(ValueError):
                reconstruct(folder, duplicate)
            bad = copy.deepcopy(disk)
            bad["tracks"][0]["path"] = "../escape.bin"
            with self.assertRaises(ValueError):
                reconstruct(folder, bad)
            (folder / "0.bin").write_bytes(bytes(4096))
            with self.assertRaises(ValueError):
                reconstruct(folder, disk)


if __name__ == "__main__":
    unittest.main()
