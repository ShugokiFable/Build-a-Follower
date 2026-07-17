#!/usr/bin/env python3
"""
Build a Follower - derive a single-sex ESP variant from the mixed 80F/80M ESP.

Drops every NPC_ of the unwanted sex, its placed ACHR, and its BAF_NPCs LNAM,
then keeps the remaining 80 of the wanted sex plus clones them x2 -> 160.
Everything else (combat styles, formlists, quest, cell) is left byte-identical
to the source so nothing else diverges from Grok's verified default ESP.

Usage: make_variant.py <female|male> <src_esp> <out_esp>
"""
from __future__ import annotations
import struct, sys, zlib
from pathlib import Path

MASTER_INDEX = 5
PLUGIN_BYTE = MASTER_INDEX << 24


def parse_subs(rec):
    out, sp = [], 0
    while sp + 6 <= len(rec):
        sig = rec[sp:sp + 4]
        sz = struct.unpack_from("<H", rec, sp + 4)[0]
        if sp + 6 + sz > len(rec):
            break
        out.append((sig, rec[sp + 6:sp + 6 + sz]))
        sp += 6 + sz
    return out


def build_subs(subs):
    return b"".join(s + struct.pack("<H", len(b)) + b for s, b in subs)


def get_edid(subs):
    for s, b in subs:
        if s == b"EDID":
            return b.split(b"\x00")[0].decode("utf-8", "replace")
    return None


def set_edid(subs, edid):
    body = edid.encode("utf-8") + b"\x00"
    return [(s, body if s == b"EDID" else b) for s, b in subs]


def set_full(subs, name):
    body = name.encode("utf-8") + b"\x00"
    return [(s, body if s == b"FULL" else b) for s, b in subs]


def decomp(rec, flags):
    if flags & 0x40000:
        try:
            return zlib.decompress(rec[4:])
        except Exception:
            return rec
    return rec


class Rec:
    def __init__(s, typ, flags, fid, rev, extra, data):
        s.typ, s.flags, s.fid, s.rev, s.extra, s.data = typ, flags, fid, rev, extra, data


class Grup:
    def __init__(s, label, gtype, stamp, unk, kids):
        s.label, s.gtype, s.stamp, s.unk, s.children = label, gtype, stamp, unk, kids


def parse_contents(data, start, end):
    items, pos = [], start
    while pos + 24 <= end:
        typ = data[pos:pos + 4]
        if typ == b"GRUP":
            gsz = struct.unpack_from("<I", data, pos + 4)[0]
            items.append(Grup(data[pos + 8:pos + 12],
                              struct.unpack_from("<I", data, pos + 12)[0],
                              struct.unpack_from("<I", data, pos + 16)[0],
                              struct.unpack_from("<I", data, pos + 20)[0],
                              parse_contents(data, pos + 24, pos + gsz)))
            pos += gsz
        else:
            dsz = struct.unpack_from("<I", data, pos + 4)[0]
            flags = struct.unpack_from("<I", data, pos + 8)[0]
            fid = struct.unpack_from("<I", data, pos + 12)[0]
            rev = struct.unpack_from("<I", data, pos + 16)[0]
            extra = data[pos + 22:pos + 24]
            payload = decomp(data[pos + 24:pos + 24 + dsz], flags)
            items.append(Rec(typ, flags & ~0x40000, fid, rev, extra, bytearray(payload)))
            pos += 24 + dsz
    return items


def walk(nodes):
    for n in nodes:
        if isinstance(n, Rec):
            yield n
        elif isinstance(n, Grup):
            yield from walk(n.children)


def serialize_rec(r):
    payload = bytes(r.data)
    return (r.typ + struct.pack("<I", len(payload)) + struct.pack("<I", r.flags)
            + struct.pack("<I", r.fid) + struct.pack("<I", r.rev)
            + struct.pack("<H", 44) + r.extra + payload)


def serialize_nodes(nodes):
    out = b""
    for n in nodes:
        if isinstance(n, Rec):
            out += serialize_rec(n)
        else:
            inner = serialize_nodes(n.children)
            out += (b"GRUP" + struct.pack("<I", 24 + len(inner)) + n.label
                    + struct.pack("<I", n.gtype) + struct.pack("<I", n.stamp)
                    + struct.pack("<I", n.unk) + inner)
    return out


def flst_lnams(subs):
    return [struct.unpack("<I", b[:4])[0] for s, b in subs if s == b"LNAM" and len(b) >= 4]


def set_flst_lnams(subs, fids):
    head = [(s, b) for s, b in subs if s != b"LNAM"]
    return head + [(b"LNAM", struct.pack("<I", f)) for f in fids]


def achr_base(rec):
    for s, b in parse_subs(bytes(rec.data)):
        if s == b"NAME" and len(b) >= 4:
            return struct.unpack("<I", b[:4])[0]
    return 0


def main():
    keep_sex = sys.argv[1]
    src = Path(sys.argv[2])
    outp = Path(sys.argv[3])
    assert keep_sex in ("female", "male")
    keep_word = "Female" if keep_sex == "female" else "Male"
    drop_word = "Male" if keep_sex == "female" else "Female"

    data = src.read_bytes()
    tes4_sz = struct.unpack_from("<I", data, 4)[0]
    tes4 = {
        "flags": struct.unpack_from("<I", data, 8)[0],
        "fid": struct.unpack_from("<I", data, 12)[0],
        "rev": struct.unpack_from("<I", data, 16)[0],
        "extra": data[22:24],
        "data": bytearray(data[24:24 + tes4_sz]),
    }
    grups = parse_contents(data, 24 + tes4_sz, len(data))

    npc_grup = next(g for g in grups if isinstance(g, Grup) and g.label == b"NPC_")

    cell_children = None

    def find_cell(nodes):
        nonlocal cell_children
        for n in nodes:
            if isinstance(n, Grup):
                if any(isinstance(c, Rec) and c.typ == b"ACHR" for c in n.children):
                    cell_children = n
                find_cell(n.children)

    for g in grups:
        if isinstance(g, Grup) and g.label == b"CELL":
            find_cell(g.children)

    keep_npcs, drop_fids = [], set()
    for r in walk(grups):
        if r.typ == b"NPC_":
            ed = get_edid(parse_subs(bytes(r.data))) or ""
            if drop_word in ed:
                drop_fids.add(r.fid)
            elif keep_word in ed:
                keep_npcs.append(r)

    achrs = [c for c in cell_children.children if isinstance(c, Rec) and c.typ == b"ACHR"]
    achr_by_base = {achr_base(a): a.fid for a in achrs}
    achr_template = achrs[0]
    dropped_refs = {achr_by_base[f] for f in drop_fids if f in achr_by_base}

    max_fid = max(r.fid for r in walk(grups))
    next_id = (max_fid & 0xFFFFFF) + 1

    def alloc():
        nonlocal next_id
        fid = PLUGIN_BYTE | next_id
        next_id += 1
        return fid

    # Drop other-sex NPC_ + ACHR
    npc_grup.children = [c for c in npc_grup.children
                         if not (isinstance(c, Rec) and c.typ == b"NPC_" and c.fid in drop_fids)]
    cell_children.children = [c for c in cell_children.children
                              if not (isinstance(c, Rec) and c.typ == b"ACHR" and c.fid in dropped_refs)]

    # Clone the kept sex 80 -> 160 (indices 81..160), preserving ZNAM/appearance
    template = sorted(keep_npcs, key=lambda r: r.fid)[0]

    def clone_npc(idx):
        subs = parse_subs(bytes(template.data))
        subs = set_edid(subs, f"BAF_Nord{keep_word}{idx:02d}")
        subs = set_full(subs, f"{keep_word}{idx:02d}")
        return Rec(b"NPC_", 0, alloc(), template.rev, template.extra, bytearray(build_subs(subs)))

    def clone_achr(npc_fid, slot):
        subs = parse_subs(bytes(achr_template.data))
        out = []
        for s, b in subs:
            if s == b"NAME":
                out.append((s, struct.pack("<I", npc_fid)))
            elif s == b"DATA" and len(b) >= 12:
                x, y, z = struct.unpack_from("<fff", b, 0)
                nb = bytearray(b)
                struct.pack_into("<fff", nb, 0, x + (slot % 10) * 64.0, y + (slot // 10) * 64.0, z)
                out.append((s, bytes(nb)))
            else:
                out.append((s, b))
        return Rec(b"ACHR", 0x400, alloc(), achr_template.rev, achr_template.extra,
                   bytearray(build_subs(out)))

    new_ref_fids = []
    slot = 0
    for idx in range(81, 161):
        nr = clone_npc(idx)
        npc_grup.children.append(nr)
        ar = clone_achr(nr.fid, slot)
        cell_children.children.append(ar)
        new_ref_fids.append(ar.fid)
        slot += 1

    # Rebuild BAF_NPCs formlist = kept placed refs + new placed refs
    npc_fl = next(r for r in walk(grups)
                  if r.typ == b"FLST" and (get_edid(parse_subs(bytes(r.data))) or "") == "BAF_NPCs")
    subs = parse_subs(bytes(npc_fl.data))
    kept = [f for f in flst_lnams(subs) if f not in dropped_refs]
    ids = kept + new_ref_fids
    npc_fl.data = bytearray(build_subs(set_flst_lnams(subs, ids)))
    assert len(ids) == 160, f"formlist {len(ids)} != 160"

    # HEDR: record count + next id + description
    nrec = sum(1 for _ in walk(grups))
    t_subs = parse_subs(bytes(tes4["data"]))
    fixed = []
    for s, b in t_subs:
        if s == b"HEDR":
            fixed.append((s, struct.pack("<fII", 1.71, nrec, next_id)))
        elif s == b"SNAM":
            desc = (f"Build a Follower - 160 {keep_sex} permanent template slots in a private "
                    "holding cell. Based on Lazy Followers by LazyGirl (modification permission "
                    "with credit).\x00")
            fixed.append((s, desc.encode("utf-8")))
        else:
            fixed.append((s, b))
    tes4["data"] = bytearray(build_subs(fixed))

    tes4_payload = bytes(tes4["data"])
    tes4_rec = (b"TES4" + struct.pack("<I", len(tes4_payload)) + struct.pack("<I", tes4["flags"] & ~0x200)
                + struct.pack("<I", tes4["fid"]) + struct.pack("<I", tes4["rev"])
                + struct.pack("<H", 44) + tes4["extra"] + tes4_payload)
    outp.parent.mkdir(parents=True, exist_ok=True)
    outp.write_bytes(tes4_rec + serialize_nodes(grups))
    print(f"[{keep_sex}] wrote {outp.name}: kept {len(keep_npcs)} + cloned 80 = 160 {keep_word}, "
          f"dropped {len(drop_fids)} {drop_word}, formlist={len(ids)}, records={nrec}")


if __name__ == "__main__":
    main()
