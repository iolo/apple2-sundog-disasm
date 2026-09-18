"""Reject misleading bytecode boundaries and verify the traced split procedure."""
import struct
import unittest

from disk_layout import ROOT, INPUTS, block_bytes
from pascal_inventory import inventory, parse_header, procedure_dictionary


class PascalInventoryTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.images = {disk: (ROOT / name).read_bytes() for disk, name in INPUTS.items()}
        cls.result = inventory(cls.images)

    def segment(self, disk, block, slot):
        header = next(h for h in self.result["headers"] if (h["disk"], h["block"]) == (disk, block))
        return next(e for e in header["entries"] if e["slot"] == slot)

    def test_header_scan_preserves_candidates_and_non_disk_data(self):
        self.assertEqual([(h["disk"], h["block"]) for h in self.result["headers"]],
                         [("disk1", b) for b in (84, 85, 103, 140, 157, 251)]
                         + [("disk2", b) for b in (103, 140)])
        self.assertEqual(self.segment("disk1", 84, 0)["status"], "unresolved")
        self.assertEqual(self.segment("disk1", 85, 0)["procedure_count"], 50)
        self.assertEqual(self.segment("disk1", 85, 1)["status"], "unused-header-slot-with-metadata")
        data = self.segment("disk1", 103, 8)
        self.assertEqual((data["segment_number"], data["length"]), (29, 760))
        self.assertEqual(data["status"], "data-segment-allocation")
        self.assertNotIn("start_block", data)

    def test_cross_disk_extent_and_native_procedures(self):
        wrong_side = self.segment("disk1", 140, 15)
        right_side = self.segment("disk2", 140, 15)
        self.assertEqual(wrong_side["status"], "unresolved")
        self.assertEqual(wrong_side["other_disk_matches"][0]["sha256"], right_side["sha256"])
        self.assertEqual((right_side["start_block"], right_side["end_block"]), (256, 272))
        self.assertEqual(right_side["procedure_count"], 41)
        for disk in self.images:
            native = [p for p in self.segment(disk, 103, 1)["procedures"]
                      if p["representation"] == "native-6502"]
            self.assertEqual(len(native), 18)

    def test_split_system_reference_uses_captured_memory_mapping(self):
        core = block_bytes(self.images["disk1"], 252, 259)[:3124]
        without_mapping = procedure_dictionary(core, 0)
        self.assertFalse(without_mapping["valid"])
        self.assertEqual([p["number"] for p in without_mapping["procedures"]
                          if p["status"] == "unresolved"], [38])
        resolved = self.segment("disk1", 251, 0)["procedures"][37]
        self.assertEqual(resolved["attribute_address"], 0xBD1A)
        self.assertEqual(resolved["storage"], "header-slot-15")
        self.assertEqual(resolved["entry_offset"], 0)
        self.assertEqual(resolved["attribute_offset"], 168)

    def test_reject_corrupt_counts_pointers_and_metadata(self):
        good = block_bytes(self.images["disk2"], 141, 143)[:576]
        self.assertTrue(procedure_dictionary(good, 1)["valid"])
        with self.assertRaises(ValueError):
            procedure_dictionary(good, 2)
        # A count cannot manufacture an out-of-buffer table.
        with self.assertRaises(ValueError):
            procedure_dictionary(bytes([0, 0, 1, 255]), 1)
        for backwards in (0, 65535, 1):
            corrupt = bytearray(good)
            struct.pack_into("<H", corrupt, len(corrupt) - 4, backwards)
            result = procedure_dictionary(corrupt, 1)
            self.assertFalse(result["valid"])
            self.assertEqual(result["procedures"][0]["status"], "unresolved")
        header = bytearray(block_bytes(self.images["disk1"], 140, 141))
        struct.pack_into("<H", header, 2, 575)
        with self.assertRaises(ValueError):
            parse_header(header)
        with self.assertRaises(ValueError):
            parse_header(header[:511])


if __name__ == "__main__":
    unittest.main()
