#!/usr/bin/env python3
"""Check the supplied originals against the committed baseline."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def main():
    failures = []
    manifest = json.loads((ROOT / "inputs.json").read_text())
    for entry in manifest["inputs"]:
        path = ROOT / entry["path"]
        if not path.is_file():
            failures.append(f"{entry['path']}: missing")
            continue
        data = path.read_bytes()
        digest = hashlib.sha256(data).hexdigest()
        if len(data) != entry["size"] or digest != entry["sha256"]:
            failures.append(f"{entry['path']}: baseline mismatch ({len(data)} bytes, {digest})")
        else:
            print(f"OK {entry['path']} ({len(data)} bytes, {digest})")
    if failures:
        raise SystemExit("\n".join(failures))


if __name__ == "__main__":
    main()
