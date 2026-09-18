"""Check bank-scattered adoption without corrupting existing reconstruction."""
import copy
import unittest

from adopt_component import replacement_plan
from build_disks import compose_image
from disk_layout import sha


class AdoptionTests(unittest.TestCase):
    def setUp(self):
        self.image = b"ABCDEFGH"
        self.manifest = {"components": {"raw": {"kind": "temporary-unresolved", "path": "raw.bin"}},
                         "disks": [{"id": "disk1", "size": 8, "sha256": sha(self.image),
                                    "regions": [{"offset": 0, "size": 8, "input": "raw", "input_offset": 0}]}]}
        self.recipe = {"name": "code", "source": "src/code.s", "config": "src/code.cfg", "mappings": [
            {"disk": "disk1", "offset": 5, "size": 1, "input_offset": 0},
            {"disk": "disk1", "offset": 2, "size": 1, "input_offset": 1}]}

    def test_scattered_banks_preserve_full_image_and_original_metadata(self):
        before = copy.deepcopy(self.manifest)
        result, files = replacement_plan(self.manifest, {"disk1": self.image}, self.recipe, b"FC")
        self.assertEqual(self.manifest, before)
        self.assertEqual(files["raw.bin"], b"ABDEGH")
        self.assertEqual(compose_image(result["disks"][0], {"code": b"FC", "raw": files["raw.bin"]}), self.image)

    def test_wrong_source_or_stale_baseline_cannot_be_adopted(self):
        for image, source in [(self.image, b"FX"), (b"ABCDEFGX", b"FC"), (self.image, b"FCZ")]:
            with self.subTest(image=image, source=source), self.assertRaises(ValueError):
                replacement_plan(self.manifest, {"disk1": image}, self.recipe, source)

    def test_overlaps_bounds_and_previously_reconstructed_regions(self):
        for key, value in [("offset", -1), ("offset", 8), ("input_offset", -1), ("input_offset", 2), ("size", 0)]:
            bad = copy.deepcopy(self.recipe)
            bad["mappings"][0][key] = value
            with self.subTest(key=key, value=value), self.assertRaises(ValueError):
                replacement_plan(self.manifest, {"disk1": self.image}, bad, b"FC")
        duplicate = copy.deepcopy(self.recipe)
        duplicate["mappings"].append(duplicate["mappings"][0].copy())
        with self.assertRaises(ValueError):
            replacement_plan(self.manifest, {"disk1": self.image}, duplicate, b"FC")
        reconstructed = copy.deepcopy(self.manifest)
        reconstructed["components"]["raw"]["kind"] = "ca65-source"
        with self.assertRaises(ValueError):
            replacement_plan(reconstructed, {"disk1": self.image}, self.recipe, b"FC")


if __name__ == "__main__":
    unittest.main()
