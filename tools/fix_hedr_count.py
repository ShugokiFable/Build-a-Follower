#!/usr/bin/env python3
"""Set HEDR numRecords = records + GRUPs (CK convention used by ship-gate)."""
import struct
import sys
from pathlib import Path


def count_records_and_grups(data: bytes):
    dsize = struct.unpack_from("<I", data, 4)[0]
    pos = 24 + dsize
    records = 0
    grups = 0

    def walk(start, end):
        nonlocal records, grups
        p = start
        while p + 24 <= end:
            sig = data[p : p + 4]
            if sig == b"GRUP":
                gs = struct.unpack_from("<I", data, p + 4)[0]
                if gs < 24 or p + gs > end:
                    break
                grups += 1
                walk(p + 24, p + gs)
                p += gs
            else:
                ds = struct.unpack_from("<I", data, p + 4)[0]
                if p + 24 + ds > end:
                    break
                records += 1
                p += 24 + ds

    walk(pos, len(data))
    return records, grups


def fix_hedr(path: Path) -> None:
    data = bytearray(path.read_bytes())
    pos = 24
    end = 24 + struct.unpack_from("<I", data, 4)[0]
    while pos + 6 <= end:
        st = data[pos : pos + 4]
        ss = struct.unpack_from("<H", data, pos + 4)[0]
        if st == b"HEDR" and ss == 12:
            ver, nrec, nextid = struct.unpack_from("<fII", data, pos + 6)
            recs, grups = count_records_and_grups(data)
            want = recs + grups
            print(f"{path}: was nrec={nrec} records={recs} grups={grups} -> {want}")
            struct.pack_into("<I", data, pos + 10, want)
            path.write_bytes(data)
            return
        pos += 6 + ss
    raise SystemExit(f"HEDR not found in {path}")


def main():
    base = Path(__file__).resolve().parents[1]
    esps = sorted(base.rglob("BuildAFollower.esp"))
    if not esps:
        raise SystemExit("no ESPs")
    for e in esps:
        fix_hedr(e)


if __name__ == "__main__":
    main()
