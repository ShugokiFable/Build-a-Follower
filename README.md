# Build a Follower

**Create-your-own companions** for Skyrim SE/AE — stamp RaceMenu presets onto permanent template actors, manage them from an MCM, save/load with JContainers.

Standalone rework of **Lazy Followers by LazyGirl** (modification permission with credit — https://www.nexusmods.com/skyrimspecialedition/mods/43312). Does **not** require LazyFollowers.esp and ships no unedited Lazy Followers files.

---

## Requirements (hard)

| Mod | Why |
|---|---|
| **SKSE64** (matching your runtime) | Foundation |
| **SkyUI** | MCM |
| **RaceMenu** (AE) | CharGen preset APIs |
| **JContainers SE** | Save/load config + NPC JSON |
| **PapyrusUtil SE/AE** | File lists / existence checks |

**Recommended:** powerofthree's Papyrus Extender (auto-scan playable races), Race Compatibility SKSE (custom races), Nether's Follower Framework (multi-follower management).

**Mu Dynamic NormalMap:** supported automatically as of 2.4.2. Build a Follower marks its own template actors and ships a Mu condition that disables Mu only for those followers. This prevents Mu's real-time normal pass from overwriting RaceMenu skin/normal overrides after Apply; Mu stays active for the player and every other NPC.

**Do not** install alongside LazyFollowers.esp or StampFollowers.esp — same role. Not save-compatible with either (new plugin + scripts); use a save that never had them, or clean-save first.

---

## Install (FOMOD)

Pick **one** template pool:

| Option | Slots |
|---|---|
| **Standard** (default) | 80 female + 80 male |
| **Female Only** | 160 female |
| **Male Only** | 160 male |

Load order: after RaceMenu, JContainers, PapyrusUtil. New game or existing save is fine.

---

## How to use (best quality — no blue face)

1. Wear the follower's face on **your** character in RaceMenu (sliders, tattoos, skin tone).
2. Open **MCM → Build a Follower** → click **Save my face for followers** and type a name.
   - This calls RaceMenu `SaveExternalCharacter` and writes the **jslot + head mesh + face tint** to the folders NPCs actually use (`Textures/CharGen/Exported` + `Meshes/CharGen/Exported`).
   - RaceMenu's sculpt **F5 export alone is not enough** for NPC tint — that is the blue/purple head bug.
3. **Pick a slot** in the NPCs dropdown. Tip: put your crosshair on any NPC before opening the MCM — their race/voice get harvested and a free slot of the same sex is pre-selected.
4. Choose that **Preset**, matching **Race**, **Voice**, name it.
5. Click **Apply settings**, then **Summon NPC**.
6. Talk to them and recruit (vanilla "Follow me" / NFF).

**Quick / tintless path:** applying a plain RaceMenu preset without an exported face tint still works — face **morphs** stamp, but head/body keep the template skin tone (matched, no blue face). For exact skin/tattoos, use **Save my face for followers**.

**Dark or grey face?** Select the NPC → **Fix dark/grey face**. Rebuilds head 3D. A full Apply already does this automatically.

Gear: **CopyKit**. Stats/Spells/Combat pages tune the rest. Save finished NPCs on **SaveLoad**.

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| **Blue / purple head** (missing tint texture) | Use **Save my face for followers** while wearing the face, then Apply that export. Plain Presets-tab saves often have no `Textures/CharGen/Exported/<name>.dds` — RaceMenu then pins a missing tint on every head regen. |
| Head OK but **skin tone / neck doesn't match body** | Export via **Save my face for followers**, match **Race**, re-Apply. If it matches for a split second and then changes back, update to 2.4.2: that is Mu Dynamic NormalMap overwriting the finished RaceMenu state. Restart Skyrim after installing, then use **Fix dark/grey face** once. |
| Dark / grey face | **Fix dark/grey face** button, or re-Apply while summoned. |
| Presets missing from the list | Fixed in 2.4.3 — both `CharGen/Exported` and `CharGen/Presets` are now always listed. |
| **Custom race missing from the Races list** | Improved in 2.4.4 — races from **Character Overhaul the Rework (CotR)** and **UBE** are now added automatically by exact record, with or without po3. For other race mods, po3 Papyrus Extender auto-scans (update po3 if the list stays empty). Otherwise play as that race, or look at an NPC of that race, then reopen the MCM — every race ever detected is remembered in `SKSE\Plugins\BuildAFollower\BuildAFollowerRaces.json` across saves and characters. |
| Follower unequips gifted gear on cell change / after dismiss | Fixed in 2.4.3 — the pipeline no longer re-sets race on every load, and gear is restored around any race change. |
| Hair color reverts after **Fix dark/grey face** | Fixed in 2.4.3 — morphs/hair are re-stamped after the rebuild. |
| Reset/Dismiss stranded the player | Fixed in 2.4.0 — Reset only moves the **NPC**. **Teleport to NPC** is blocked while they are in the storage cell (use **Summon** instead). |
| Preset applied but NPC looks default | Wrong slot selected in the NPC dropdown. |
| CombatStyle row says "SkyTactics (see Debug)" | SkyTactics installed — BAF leaves styles alone. |
| HeadNif won't toggle | Needs a head from **Save my face for followers** (`Meshes/CharGen/Exported`). Legacy F5 files under `SKSE/Plugins/CharGen` are flagged in the hover text. |
| Neck seam / floating head | **Race must match the preset.** Prefer HeadNif off unless you exported a matching head. |
| No presets in list | Export `.jslot` to `SKSE\Plugins\CharGen\Exported` (or `Presets`); PapyrusUtil must work. |
| Custom race dialogue broken | Race Compatibility SKSE + race patch. |
| All slots full | **Reset/Dismiss** parks the NPC (not you). Save JSON first if you want them back. |

Shouts stay **disabled** (vanilla engine save-corruption risk — same warning as the original mod).

---

## Changelog

### 2.4.4 — voice reverting to Nord, CotR/UBE races, and rebuildable scripts

- **Fixed: a follower's voice reverting to Nord.** Applying a preset re-set the
  actor's race, and that rebuild silently discarded the voice that had just been
  applied — which is why swapping the voice in the MCM and swapping it back
  "fixed" it. The voice is now re-applied after the race pass, and a missing
  voice can no longer fall back to the Nord default.
- **Added: automatic race detection for CotR and UBE.** Their playable races are
  now registered directly, so they appear in the **Races** list without needing
  po3 Papyrus Extender and without having to look at an NPC of that race first.
  **Completely optional** — both are soft dependencies. If you don't have them
  installed, nothing changes and nothing is added to your game.
- **Removed: the abandoned "Follower Goes on a Trip" hook.** With FGT not
  installed the "Followers Travel" button threw a script error, and its presence
  made the mod impossible to rebuild at all. Followers you aren't actively using
  are handled by the normal follower system / Nether's Follower Framework.

### 2.4.3 — preset visibility, custom races, hair color, and gear-unequip fixes
- **Fixed: custom races were only detected while you were playing one.** Detection had three weak points, all fixed: (1) the po3 Papyrus Extender scan could silently fail (outdated po3, or a stuck update flag from a crash) with no hint to the user; (2) detected races were never written anywhere, so nothing carried across new games or characters; (3) guidance was unclear. Now: the update flag can no longer jam shut, an empty po3 scan logs a clear recovery message, and **every detected race is remembered in `SKSE\Plugins\BuildAFollower\BuildAFollowerRaces.json`** — once a race is seen (po3 scan, playing it, or looking at an NPC of that race before opening the MCM), it stays in the Races dropdown on every save and every character.
- **Fixed: presets in `CharGen/Presets` were hidden whenever `CharGen/Exported` held any .jslot.** The MCM listed only one folder — a single stray export (even a leftover test file) made every preset in `Presets` invisible ("my presets cannot be found by the mod"). Both folders are now merged in the Preset dropdown, each entry keeping its correct load path; on a name clash the Exported copy wins.
- **Fixed: followers unequipped gifted armor/weapons on cell change and after dismiss/summon.** The appearance pipeline re-asserted the NPC's race on *every* load, and `SetRace` makes the engine re-evaluate equipment. Race is now only (re)set when it actually changed or on a manual Apply/Fix, and worn gear is snapshotted and restored around it.
- **Fixed: hair color and face morphs reverted to template defaults after Fix dark/grey face** (hair "turning blonde") for presets without an exported tint. The one-shot morph apply now re-stamps after the head rebuild and on cell loads — still without the Skin bit, so the blue-face guard is unchanged.
- Fixed: the "no exported face tint" note now checks the folder the preset actually lives in, and counts a full head export as having a tint.
- Everything from 2.4.2 is kept, including the Mu Dynamic NormalMap compatibility.

### 2.4.2 — Mu Dynamic NormalMap compatibility
- **Fixed the one-frame head/body match that immediately reverted** when Mu Dynamic NormalMap was installed. That visual blink is the giveaway: RaceMenu finishes correctly, then Mu's real-time normal-map pass runs afterward and replaces the follower's skin/normal state.
- Added a plugin-owned marker keyword to all 160 template NPC bases in every FOMOD ESP variant.
- Added `SKSE\Plugins\MuDynamicNormalMap\BuildAFollower.ini` at maximum condition priority. It disables Mu only for Build a Follower actors, leaving Mu enabled for the player and all other NPCs.
- No new DLL, script dependency, or manual patch is required. Fully exit Skyrim after updating so Mu reloads its condition files, then re-Apply or use **Fix dark/grey face** once on an existing follower.
- Updated FOMOD metadata and project link.

### 2.4.1 — critical crash fix
- **Fixed a hard crash on Apply** (`skee64.dll` → `std::runtime_error: "LargestInt out of UInt range"`). 2.4.0 copied a picked preset from `CharGen/Presets` into `CharGen/Exported` by round-tripping it through JContainers. JContainers stores integers as **signed** 32-bit, so RaceMenu's unsigned `tintInfo` colors (any with a high alpha byte) were rewritten **negative** — and RaceMenu's own JSON parser crashes reading a negative value as unsigned. The mod no longer rewrites `.jslot` files at all; it reads the preset in place, exactly like the original.
- If you used 2.4.0: delete any `Data\SKSE\Plugins\CharGen\Exported\*.jslot` files dated the day you ran 2.4.0 (they're corrupt copies — your originals are safe in `CharGen\Presets\`).
- Everything else from 2.4.0 is kept (all of it is crash-safe): the tint-aware apply, "Save my face for followers", dark-face rebuild, Reset/Teleport safety.

### 2.4.0
- **Blue face / skin-tone mismatch fixed (root cause).** RaceMenu `LoadCharacterEx` pins the head tint to `Textures/CharGen/Exported/<name>.dds`. Missing file → blue/purple head (or Face Discoloration Fix repaint that no longer matches body). Pipeline is now tint-aware; tintless presets apply morphs without skin override and clear the broken mapping.
- **New: "Save my face for followers"** — MCM export via `CharGen.SaveExternalCharacter` (verified in `skee64.dll`) so jslot + mesh + tint land where the NPC loader needs them.
- **Reset/Dismiss never moves the player** — only parks the NPC. **Teleport to NPC** blocked while parked in storage (the strand-in-temp-cell bug).
- Full Apply still does a 3D rebuild so dark/grey face stays fixed when tint is present.
- HEDR record count aligned to CK convention for ship-gate.

### 2.3.0
- **Dark / grey face bug fixed properly.** The apply pipeline now rebuilds the head 3D after stamping, so the face tint re-bakes against the applied preset. This is the same result the external "Face Discoloration Fix" gives, done in-mod. Root cause: a live CharGen apply leaves the head tint baked from the *old* face until the 3D is rebuilt.
- **New MCM button: "Fix dark/grey face"** — one click re-bakes a selected NPC's head, for followers made on an older version or restored from a save. Replaces needing an external dark-face spell.
- **Gender-split FOMOD restored.** Install-time choice of **80F+80M / 160 female-only / 160 male-only**. Female-only and male-only pools have zero opposite-sex slots, so you can't land on a male template when you wanted a female one (and vice versa).
- Kept the 2.2.x neck-seam pipeline (body→head→skin reblend + weight refresh); the tint rebuild runs on top of it.
- All three ESPs re-verified: HEDR 1.71, formVersion 44 on every record, 160 formlist entries all pointing at placed references (no dead slots), 4-byte SEQ.

### 1.2 — Build a Follower
- Rebranded: plugin `BuildAFollower.esp`, scripts `BAF_*`, JSON under `SKSE\Plugins\BuildAFollower\`
- **Fixed: slots 81–160 were dead** — the NPC formlist pointed at base actor records instead of placed references, so only the first 80 slots ever worked
- **Fixed: blue face / preset not applying when "Apply settings" was clicked before summoning** — the apply is now deferred until the NPC's 3D is loaded and runs automatically on summon (with a popup telling you so)
- **Fixed: malformed SEQ file** — the MCM quest now reliably starts on new games
- Fixed: MCM main page could fail to draw when an NPC's combat style wasn't in the pool (negative array index)
- Fixed: combat-style row labels SkyTactics clearly; all 20 styles have role names (not Style #5)
- Fixed: HeadNif is a real clickable toggle when a matching `.nif` exists
- Fixed: a menu-open handler bug that made unrelated dropdowns show the combat-style list
- Fixed: combat-style names pad correctly when loading a config saved with a smaller pool
- FOMOD installer with three template pools: 80F+80M / 160F / 160M

### 1.1 — Stamp Followers
- Fixed wrong save-slot restoration, reload dismissals, cross-sex template fallback, voice-list mismatch, Presets folder path bug

### 1.0 — Stamp Followers
- Initial rework of Lazy Followers: 160 slots, 20 combat styles, HEDR 1.71/formver 44, holding-cell architecture kept

---

## Credits

- **LazyGirl** — Lazy Followers (https://www.nexusmods.com/skyrimspecialedition/mods/43312): original design, template-pool approach, MCM feature set, save layout. Reworked and redistributed under the mod's open modification permission, with credit. Not for paid platforms.
- SkyUI team (MCM), Expired6978/RaceMenu contributors (CharGen), JContainers, PapyrusUtil, powerofthree — required/optional frameworks (install their mods; nothing of theirs is shipped here).
