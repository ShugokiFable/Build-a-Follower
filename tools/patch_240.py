#!/usr/bin/env python3
"""
Build a Follower 2.4.0 - source-verified blue-face fix (skee64 PapyrusCharGen.cpp):
LoadCharacterEx pins head texture slot 6 to Textures/CharGen/Exported/<name>.dds on
every head regen. Missing DDS (preset saved in CharGen/Presets, or no tint export)
= permanent blue face. Fix = tint-aware apply + SaveExternalCharacter workflow.
Every patch asserts exactly one occurrence.
"""
from pathlib import Path
import sys

ROOT = Path(r"Z:\Backup\!Skyrim AE\z4GrokWork\Build a Follower\Build a Follower 2.4.0\00 Core\Scripts\Source")
failed = []

def patch(text, old, new, label):
    n = text.count(old)
    if n != 1:
        failed.append(f"{label}: {n} occurrences")
        return text
    return text.replace(old, new)

# ================= BAF_ActorScript =================
a = (ROOT / "BAF_ActorScript.psc").read_text(encoding="utf-8")

a = patch(a,
    "; True only while commitFaceTint is cycling the 3D, so the reload's own OnLoad\n"
    "; does not recurse back into another apply/reload.\n"
    "bool reloadingFace",
    "; True only while commitFaceTint is cycling the 3D, so the reload's own OnLoad\n"
    "; does not recurse back into another apply/reload.\n"
    "bool reloadingFace\n"
    "\n"
    "; True when the applied preset has no exported face tint mask on disk. The\n"
    "; preset is stamped once (morphs persist on the ActorBase) and the RaceMenu\n"
    "; mapping is cleared so head regens never install the broken tint texture\n"
    "; (the blue-face bug). See skee64 PresetInterface::ApplyMappedPreset.\n"
    "bool myTintlessMode",
    "A1 myTintlessMode decl")

a = patch(a,
    "\t\tif(fullRefresh)\n"
    "\t\t\trefreshAppearance(true)\n"
    "\t\telse\n"
    "\t\t\trefreshAppearance()\n"
    "\t\tendIf",
    "\t\tif(fullRefresh)\n"
    "\t\t\trefreshAppearance(true)\n"
    "\t\telseIf(myTintlessMode)\n"
    "\t\t\t; Tintless one-shot preset: morphs already live on the ActorBase and\n"
    "\t\t\t; re-running CharGen would re-map a broken tint (blue face). Skip.\n"
    "\t\t\tdout(\"Tintless preset - skipping lite reapply\")\n"
    "\t\telse\n"
    "\t\t\trefreshAppearance()\n"
    "\t\tendIf",
    "A2 tintless lite skip")

a = patch(a,
    "\tapplyPresetPipeline(fullRefresh)\n"
    "\n"
    "\t; Dark / grey face fix. A live CharGen apply keeps the head tint baked from\n"
    "\t; the OLD face until the 3D is rebuilt — the classic dark-face bug testers hit.\n"
    "\t; On a full (user) apply, cycle the 3D and re-stamp so the tint bakes fresh.\n"
    "\t; Guarded so the reload's own OnLoad cannot recurse back into here.\n"
    "\tif fullRefresh && !reloadingFace\n"
    "\t\tcommitFaceTint()\n"
    "\tendIf",
    "\tapplyPresetPipeline(fullRefresh)\n"
    "\n"
    "\t; Tintless presets: the apply above stamped the morphs, but the head regen\n"
    "\t; it triggered still rendered RaceMenu's missing-tint texture (blue face).\n"
    "\t; One clean 3D reload — with the mapping already cleared — purges it.\n"
    "\t; Guarded so the reload's own OnLoad cannot recurse back into here.\n"
    "\tif myTintlessMode && !reloadingFace\n"
    "\t\tcommitFaceTint()\n"
    "\tendIf",
    "A5 reload only for tintless")

a = patch(a,
    "\t; 1) Always stamp body + skin + morphs from the jslot first (shared base)\n"
    "\tdout(\"Applying preset body/skin base mode=\" + applyMode + \" - \" + myPreset)\n"
    "\tCharGen.LoadCharacterEx(self, myPresetRace, myPreset, applyMode)\n"
    "\tUtility.Wait(0.15)\n"
    "\n"
    "\t; 2) External head on top (only when user/MCM set a path)\n"
    "\tif myHeadMesh != \"\"\n"
    "\t\tif fullRefresh\n"
    "\t\t\tdout(\"Applying external head (full) - \" + myPreset)\n"
    "\t\t\tif rmHairColor\n"
    "\t\t\t\tCharGen.LoadCharacterPresetEx(self, myPreset, rmHairColor, applyMode)\n"
    "\t\t\telse\n"
    "\t\t\t\tCharGen.LoadExternalCharacterEx(self, myPresetRace, myPreset, applyMode)\n"
    "\t\t\tendIf\n"
    "\t\telse\n"
    "\t\t\tdout(\"Applying external head (lite) - \" + myPreset)\n"
    "\t\t\tCharGen.LoadExternalCharacterEx(self, myPresetRace, myPreset, applyMode)\n"
    "\t\tendIf\n"
    "\t\tUtility.Wait(0.1)\n"
    "\t\t; 3) Re-blend neck: skin then body morphs after head swap\n"
    "\t\tdout(\"Neck-seam safeguard: re-apply Skin + Body after external head\")\n"
    "\t\tCharGen.LoadCharacterEx(self, myPresetRace, myPreset, 8)  ; Skin\n"
    "\t\tUtility.Wait(0.05)\n"
    "\t\tCharGen.LoadCharacterEx(self, myPresetRace, myPreset, 2)  ; Body\n"
    "\telse\n"
    "\t\t; Overlay / tattoo pass without re-doing full stack\n"
    "\t\tCharGen.LoadCharacterEx(self, myPresetRace, myPreset, 2)\n"
    "\tendIf",
    "\t; --- Tint-aware apply (verified against skee64 PapyrusCharGen.cpp) ---\n"
    "\t; LoadCharacterEx resolves the head tint to Textures/CharGen/Exported/<name>.dds\n"
    "\t; and RaceMenu re-installs that texture on EVERY head regen. If the file is\n"
    "\t; missing the head renders with a broken texture = the blue-face bug.\n"
    "\tString baseName = presetBaseName(myPreset)\n"
    "\tensureExportedJslot(baseName)\n"
    "\n"
    "\tbool hasTintMask = MiscUtil.FileExists(\"Data/Textures/CharGen/Exported/\" + baseName + \".dds\")\n"
    "\tbool hasExternalTrio = hasTintMask && MiscUtil.FileExists(\"Data/Meshes/CharGen/Exported/\" + baseName + \".nif\") && MiscUtil.FileExists(\"Data/SKSE/Plugins/CharGen/Exported/\" + baseName + \".jslot\")\n"
    "\tmyTintlessMode = !hasTintMask\n"
    "\n"
    "\tif hasExternalTrio && myHeadMesh != \"\"\n"
    "\t\t; Full export trio (from \"Save my face for followers\"): copies the head\n"
    "\t\t; nif + tint into FaceGenData for THIS template and refreshes the live\n"
    "\t\t; tint mask - the engine-native baked path. Best quality, no blue face.\n"
    "\t\tdout(\"Applying external character (baked FaceGen) - \" + baseName)\n"
    "\t\tCharGen.LoadExternalCharacterEx(self, myPresetRace, baseName, applyMode)\n"
    "\t\tUtility.Wait(0.15)\n"
    "\t\t; Re-blend neck: skin then body morphs after the head swap\n"
    "\t\tCharGen.LoadCharacterEx(self, myPresetRace, \"../Exported/\" + baseName, 8)  ; SkinOverrides\n"
    "\t\tUtility.Wait(0.05)\n"
    "\t\tCharGen.LoadCharacterEx(self, myPresetRace, \"../Exported/\" + baseName, 2)  ; BodyMorphs\n"
    "\telseIf hasTintMask\n"
    "\t\t; jslot + exported tint mask both on disk: the standard apply is safe\n"
    "\t\tdout(\"Applying preset mode=\" + applyMode + \" - \" + baseName)\n"
    "\t\tCharGen.LoadCharacterEx(self, myPresetRace, \"../Exported/\" + baseName, applyMode)\n"
    "\t\tUtility.Wait(0.15)\n"
    "\t\t; Overlay / body pass\n"
    "\t\tCharGen.LoadCharacterEx(self, myPresetRace, \"../Exported/\" + baseName, 2)\n"
    "\telse\n"
    "\t\t; No exported tint mask anywhere -> RaceMenu would pin the head to a\n"
    "\t\t; missing texture forever. Apply face morphs WITHOUT SkinOverrides so\n"
    "\t\t; head and body both keep the template tone (they match), then clear\n"
    "\t\t; the mapping so regens never install the broken tint.\n"
    "\t\tint safeMode = Math.LogicalAnd(applyMode, 7) ; drop SkinOverrides(8)\n"
    "\t\tdout(\"Tintless preset - one-shot apply mode=\" + safeMode + \" - \" + baseName)\n"
    "\t\tCharGen.LoadCharacterEx(self, myPresetRace, \"../Exported/\" + baseName, safeMode)\n"
    "\t\tUtility.Wait(0.15)\n"
    "\t\tCharGen.ClearPreset(myActorBase)\n"
    "\tendIf",
    "A3 tint-aware apply strategy")

a = patch(a,
    "\treloadingFace = true\n"
    "\tdout(\"Committing face tint (3D reload) to clear dark-face\")\n"
    "\tself.Disable()\n"
    "\tUtility.Wait(0.3)\n"
    "\tself.Enable()\n"
    "\tUtility.Wait(0.4)          ; let the fresh 3D load before re-stamping\n"
    "\tapplyPresetPipeline(true)  ; re-stamp preset onto the fresh head; bakes tint\n"
    "\tself.QueueNiNodeUpdate()\n"
    "\treloadingFace = false",
    "\treloadingFace = true\n"
    "\tdout(\"Reloading 3D to rebuild the face\")\n"
    "\tself.Disable()\n"
    "\tUtility.Wait(0.3)\n"
    "\tself.Enable()\n"
    "\tUtility.Wait(0.4)          ; let the fresh 3D load\n"
    "\tif !myTintlessMode\n"
    "\t\tapplyPresetPipeline(true)  ; re-stamp onto the fresh head (tint on disk is valid)\n"
    "\tendIf\n"
    "\tself.QueueNiNodeUpdate()\n"
    "\treloadingFace = false",
    "A7 conditional re-stamp in commitFaceTint")

a = patch(a,
    "; Resolve external exported head .nif for a RaceMenu preset path like ../Exported/Name\n"
    "String function resolveHeadMeshPath(String presetPath)",
    "; Strip ../Exported/ or ../Presets/ style prefixes down to the bare file name.\n"
    "String function presetBaseName(String presetPath)\n"
    "\tString baseName = presetPath\n"
    "\tint slash = StringUtil.Find(baseName, \"/\")\n"
    "\twhile slash > -1\n"
    "\t\tbaseName = StringUtil.SubString(baseName, slash + 1)\n"
    "\t\tslash = StringUtil.Find(baseName, \"/\")\n"
    "\tendWhile\n"
    "\tslash = StringUtil.Find(baseName, \"\\\\\")\n"
    "\twhile slash > -1\n"
    "\t\tbaseName = StringUtil.SubString(baseName, slash + 1)\n"
    "\t\tslash = StringUtil.Find(baseName, \"\\\\\")\n"
    "\tendWhile\n"
    "\treturn baseName\n"
    "endFunction\n"
    "\n"
    "; RaceMenu's loaders and their tint path are rooted in CharGen/Exported. If the\n"
    "; picked .jslot only exists in CharGen/Presets (RaceMenu's own save folder),\n"
    "; copy the JSON over so the apply and its tint path resolve consistently.\n"
    "function ensureExportedJslot(String baseName)\n"
    "\tString dst = \"Data/SKSE/Plugins/CharGen/Exported/\" + baseName + \".jslot\"\n"
    "\tif MiscUtil.FileExists(dst)\n"
    "\t\treturn\n"
    "\tendIf\n"
    "\tString src = \"Data/SKSE/Plugins/CharGen/Presets/\" + baseName + \".jslot\"\n"
    "\tif MiscUtil.FileExists(src)\n"
    "\t\tint presetJson = JValue.readFromFile(src)\n"
    "\t\tif presetJson != 0\n"
    "\t\t\tJValue.writeToFile(presetJson, dst)\n"
    "\t\t\tpresetJson = JValue.release(presetJson)\n"
    "\t\t\tdout(\"Copied preset from Presets to Exported - \" + baseName)\n"
    "\t\tendIf\n"
    "\tendIf\n"
    "endFunction\n"
    "\n"
    "; True while this NPC is parked (disabled or physically in the storage cell).\n"
    "bool function isInStorage()\n"
    "\treturn self.IsDisabled() || self.GetParentCell() == BAF_CellMarker.GetParentCell()\n"
    "endFunction\n"
    "\n"
    "bool function isTintless()\n"
    "\treturn myTintlessMode\n"
    "endFunction\n"
    "\n"
    "; Whether the current preset has an exported face tint mask on disk.\n"
    "bool function presetHasTintMask()\n"
    "\tif myPreset == \"\"\n"
    "\t\treturn true\n"
    "\tendIf\n"
    "\treturn MiscUtil.FileExists(\"Data/Textures/CharGen/Exported/\" + presetBaseName(myPreset) + \".dds\")\n"
    "endFunction\n"
    "\n"
    "; Resolve external exported head .nif for a RaceMenu preset path like ../Exported/Name\n"
    "String function resolveHeadMeshPath(String presetPath)",
    "A6 helper functions")

(ROOT / "BAF_ActorScript.psc").write_text(a, encoding="utf-8", newline="\n")

# ================= BAF_MCMScript =================
m = (ROOT / "BAF_MCMScript.psc").read_text(encoding="utf-8")

m = patch(m,
    "int guiFixFace\n",
    "int guiFixFace\nint guiSaveMyFace\n",
    "M2a save-face gui id")

m = patch(m,
    "bool headMeshAvailable\n",
    "bool headMeshAvailable\nbool legacyHeadExport\n",
    "M1a legacyHeadExport decl")

m = patch(m,
    "\tString p1 = \"data/SKSE/Plugins/CharGen/Exported/\" + headMeshFileName + \".nif\"\n"
    "\tString p2 = \"data/SKSE/Plugins/CharGen/\" + headMeshFileName + \".nif\"\n"
    "\tString p3 = \"data/SKSE/Plugins/CharGen/Presets/\" + headMeshFileName + \".nif\"\n"
    "\n"
    "\tif MiscUtil.FileExists(p1)\n"
    "\t\theadMeshPath = p1\n"
    "\t\theadMeshAvailable = true\n"
    "\telseIf MiscUtil.FileExists(p2)\n"
    "\t\theadMeshPath = p2\n"
    "\t\theadMeshAvailable = true\n"
    "\telseIf MiscUtil.FileExists(p3)\n"
    "\t\theadMeshPath = p3\n"
    "\t\theadMeshAvailable = true\n"
    "\tendIf",
    "\t; The NPC loader (LoadExternalCharacterEx) reads Meshes/CharGen/Exported +\n"
    "\t; Textures/CharGen/Exported. \"Save my face for followers\" writes there.\n"
    "\t; RaceMenu's sculpt-tab F5 export goes to SKSE/Plugins/CharGen - the WRONG\n"
    "\t; place for NPC use; flag it so the hover text can explain.\n"
    "\tString p1 = \"Data/Meshes/CharGen/Exported/\" + headMeshFileName + \".nif\"\n"
    "\n"
    "\tlegacyHeadExport = false\n"
    "\tif MiscUtil.FileExists(p1) && MiscUtil.FileExists(\"Data/Textures/CharGen/Exported/\" + headMeshFileName + \".dds\")\n"
    "\t\theadMeshPath = p1\n"
    "\t\theadMeshAvailable = true\n"
    "\telseIf MiscUtil.FileExists(\"data/SKSE/Plugins/CharGen/\" + headMeshFileName + \".nif\") || MiscUtil.FileExists(\"data/SKSE/Plugins/CharGen/Exported/\" + headMeshFileName + \".nif\")\n"
    "\t\tlegacyHeadExport = true\n"
    "\tendIf",
    "M1b scanHeadMeshFile real paths")

m = patch(m,
    "\t\telse\n"
    "\t\t\tSetInfoText(\"No matching .nif. Export head same name as .jslot under CharGen/Exported. Race must match the preset or you get neck seams / dark face.\")",
    "\t\telseIf legacyHeadExport\n"
    "\t\t\tSetInfoText(\"Head export found in RaceMenu's old F5 location (SKSE/Plugins/CharGen) which the NPC loader cannot read. Wear the face, then click 'Save my face for followers' to export it to the right place.\")\n"
    "\t\telse\n"
    "\t\t\tSetInfoText(\"No exported head for this preset. Wear the face in RaceMenu, then click 'Save my face for followers' (best quality, prevents the blue face).\")",
    "M1c headnif hover text")

m = patch(m,
    "\tAddEmptyOption()\n"
    "\tguiFGTEnable = AddToggleOption(\"Followers Travel\", false)\n"
    "endFunction",
    "\tguiSaveMyFace = AddInputOption(\"Save my face for followers\", \"click me\")\n"
    "\tAddEmptyOption()\n"
    "\tguiFGTEnable = AddToggleOption(\"Followers Travel\", false)\n"
    "endFunction",
    "M2b draw save-face")

m = patch(m,
    "event OnOptionInputOpen(int a_option)\n"
    "\tif(a_option == guiNPCName)",
    "event OnOptionInputOpen(int a_option)\n"
    "\tif(a_option == guiSaveMyFace)\n"
    "\t\tSetInputDialogStartText(\"MyFollowerFace\")\n"
    "\telseIf(a_option == guiNPCName)",
    "M2c input open")

m = patch(m,
    "event OnOptionInputAccept(int a_option, string a_input)\n"
    "\tif(a_option == guiNPCName)",
    "event OnOptionInputAccept(int a_option, string a_input)\n"
    "\tif(a_option == guiSaveMyFace)\n"
    "\t\tsaveMyFace(a_input)\n"
    "\telseIf(a_option == guiNPCName)",
    "M2d input accept")

m = patch(m,
    "\telseIf(a_option == guiFixFace)\n"
    "\t\tSetInfoText(\"Dark or grey face? Rebuilds this NPC's head so the tint re-bakes. No external Dark Face Fix mod needed. NPC briefly blinks out and back.\")",
    "\telseIf(a_option == guiFixFace)\n"
    "\t\tSetInfoText(\"Dark or grey face? Rebuilds this NPC's head so the tint re-bakes. No external Dark Face Fix mod needed. NPC briefly blinks out and back.\")\n"
    "\telseIf(a_option == guiSaveMyFace)\n"
    "\t\tSetInfoText(\"Wear the follower's face on YOUR character (RaceMenu), then use this. Exports preset + head mesh + face tint together to the folders the NPC loader needs - the no-blue-face way.\")",
    "M2e save-face hover")

m = patch(m,
    "\telseIf(a_option == guiTeleportToggle)\n"
    "\t\tmsgBool = ShowMessage(\"Teleport to \" + actorScript.getMyPresetName() + \"?\",  true)\n"
    "\n"
    "\t\tif(msgBool)\n"
    "\t\t\tplayerRef.MoveTo(tarActor)\n"
    "\t\tendIf",
    "\telseIf(a_option == guiTeleportToggle)\n"
    "\t\tif(actorScript.isInStorage())\n"
    "\t\t\tShowMessage(\"This NPC is parked in the storage cell. Use Summon NPC instead - teleporting there would strand you.\", false, \"OK\")\n"
    "\t\telse\n"
    "\t\t\tmsgBool = ShowMessage(\"Teleport to \" + actorScript.getMyPresetName() + \"?\",  true)\n"
    "\n"
    "\t\t\tif(msgBool)\n"
    "\t\t\t\tplayerRef.MoveTo(tarActor)\n"
    "\t\t\tendIf\n"
    "\t\tendIf",
    "M3 teleport storage guard")

m = patch(m,
    "\t\tif(msgBool)\n"
    "\t\t\tactorScript.dismissMe()\n"
    "\t\tendIf",
    "\t\tif(msgBool)\n"
    "\t\t\tactorScript.dismissMe()\n"
    "\t\t\tForcePageReset()\n"
    "\t\tendIf",
    "M4 dismiss page reset")

m = patch(m,
    "\tactorScript.refreshAppearance(true)\n"
    "\n"
    "\tif(!tarActor.Is3DLoaded() || tarActor.IsDisabled())",
    "\tactorScript.refreshAppearance(true)\n"
    "\n"
    "\tif(!actorScript.presetHasTintMask())\n"
    "\t\tShowMessage(\"Note: this preset has no exported face tint, so skin color stays at the template default (that is what prevents the blue face). For exact colors: wear the face in RaceMenu, then click 'Save my face for followers'.\", false, \"OK\")\n"
    "\tendIf\n"
    "\n"
    "\tif(!tarActor.Is3DLoaded() || tarActor.IsDisabled())",
    "M5 tintless warning")

m = patch(m,
    "function copyKit()",
    "function saveMyFace(String inName)\n"
    "\tif(inName == \"\" || inName == \"click me\")\n"
    "\t\treturn\n"
    "\tendIf\n"
    "\tmsgBool = ShowMessage(\"Export YOUR current face as '\" + inName + \"'? It saves the preset, head mesh and face tint together (no blue face, best quality).\", true)\n"
    "\tif(msgBool)\n"
    "\t\tCharGen.SaveExternalCharacter(inName)\n"
    "\t\tUtility.Wait(2.0) ; head + tint export runs as a background task\n"
    "\t\tgetPresetList()\n"
    "\t\tShowMessage(\"Saved. Pick '\" + inName + \".jslot' in the Preset list, set the matching Race, then Apply.\", false, \"OK\")\n"
    "\t\tForcePageReset()\n"
    "\tendIf\n"
    "endFunction\n"
    "\n"
    "function copyKit()",
    "M2f saveMyFace function")

(ROOT / "BAF_MCMScript.psc").write_text(m, encoding="utf-8", newline="\n")

if failed:
    print("FAILED PATCHES:")
    for f in failed:
        print(" -", f)
    sys.exit(1)
print("All 2.4.0 patches applied cleanly.")
