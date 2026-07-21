Scriptname BAF_ActorScript extends Actor  

ObjectReference Property BAF_CellMarker Auto

GlobalVariable Property BAF_RMDelay Auto
GlobalVariable Property BAF_RMFullMode Auto
GlobalVariable Property BAF_RMLiteMode Auto
GlobalVariable Property BAF_TraceMode Auto
BAF_MCMScript Property mainHook Auto

String myPresetName
String myDefaultName
ActorBase myActorBase
VoiceType myDefaultVoiceType
VoiceType myPresetVoiceType
String myPreset
String myHeadMesh
Race myDefaultRace
Race myPresetRace
CombatStyle myCombatStyle
ColorForm rmHairColor
int myHairColor

Class myClass
int myVersion

Form[] mySpells
Form[] myShouts

; Set when a preset was applied while this actor's 3D was not loaded.
; The full CharGen apply is deferred to the next OnLoad (summon).
bool pendingFullApply

; True only while commitFaceTint is cycling the 3D, so the reload's own OnLoad
; does not recurse back into another apply/reload.
bool reloadingFace

; True when the applied preset has no exported face tint mask on disk. The
; preset is stamped once (morphs persist on the ActorBase) and the RaceMenu
; mapping is cleared so head regens never install the broken tint texture
; (the blue-face bug). See skee64 PresetInterface::ApplyMappedPreset.
bool myTintlessMode

Event OnInit()
	setMyDefaults()
	self.Disable()
	RegisterForModEvent("BuildAFollowerUpdate", "OnBuildAFollowerUpdate")
	RegisterForModEvent("BuildAFollowerOnloadUpdate", "OnBuildAFollowerOnloadUpdate")
endEvent

Event OnLoad()
	updateMyVersion()
	if reloadingFace
		; commitFaceTint is mid-reload and will re-stamp the preset itself.
		; Skip so we never run two CharGen applies on the same actor at once.
		return
	endIf
	if(pendingFullApply)
		pendingFullApply = false
		updateMyData(true)
	else
		updateMyData()
	endIf
endEvent

Event OnBuildAFollowerUpdate()
	dout("Recieved MCM update event")
	updateMyData(true)
endEvent

Event OnBuildAFollowerOnloadUpdate()
	dout("Recieved Onload update event")
	updateMyData(false)
endEvent

;If anything is clearing the name there's a good chance
;it starts a package. By hooking into the event for it we
;can attempt to immedietly restore it
Event OnPackageStart(Package akNewPackage)
	setMyPresetName(myPresetname)
endEvent

function registerForEvents()
	RegisterForModEvent("BuildAFollowerUpdate", "OnBuildAFollowerUpdate")
	RegisterForModEvent("BuildAFollowerOnloadUpdate", "OnBuildAFollowerOnloadUpdate")
endFunction

function setMyDefaults()
	; RaceMenu hair color form — try common plugin names
	rmHairColor = Game.GetFormFromFile(0x801, "RaceMenu.esp") as ColorForm
	if !rmHairColor
		rmHairColor = Game.GetFormFromFile(0x801, "RaceMenuPlugin.esp") as ColorForm
	endIf
	myActorBase = self.GetActorBase()
	myDefaultName = self.GetDisplayName()
	myPresetName = myDefaultName
	myDefaultVoiceType = self.GetVoiceType()
	myPresetVoiceType = myDefaultVoiceType
	myDefaultRace = self.GetRace()
	myPresetRace = myDefaultRace
	myCombatStyle = myActorBase.GetCombatStyle()
	myClass = myActorBase.GetClass()
	myPreset = ""
	myHeadMesh = ""
	mySpells = new Form[1]
	mySpells[0] = none
	myShouts = new Form[1]
	myShouts[0] = none
	checkRelationship()
endFunction

function resetMyData()
	myPresetName = myDefaultName
	myPresetVoiceType = myDefaultVoiceType
	myPresetRace = myDefaultRace
	myPreset = ""
	myHeadMesh = ""
	pendingFullApply = false
	myTintlessMode = false
	clearMySpells()
	CharGen.ClearPreset(self.GetActorBase())
endFunction

; Parks THIS NPC in the storage cell. Never moves the player.
function dismissMe()
	resetMyData()
	CharGen.ClearPreset(myActorBase)
	; Only the follower goes to BAF_CellMarker. Teleport-to-NPC is blocked
	; while parked so the player cannot strand themselves in storage.
	self.MoveTo(BAF_CellMarker)
	self.Disable()
endFunction

function summonMe(ObjectReference inObj)
	if(self.IsDisabled())
		self.Enable()
	endIf
	self.MoveTo(inObj)
	; Failsafe: OnLoad normally handles a deferred preset. If the actor was
	; already loaded (no OnLoad fires), apply the pending preset here.
	Utility.Wait(1.0)
	if(pendingFullApply && self.Is3DLoaded() && !self.IsDisabled())
		pendingFullApply = false
		updateMyData(true)
	endIf
endFunction

function updateMyData(bool fullRefresh = false)
	if(myPreset != "" && !self.IsDisabled())
		Utility.Wait(BAF_RMDelay.GetValueInt())
		checkmyPresetName()
		checkMyVoice()
		checkRelationship()
		; When mainHook missing (early load), skip style/class until resolved
		if mainHook
			if(mainHook.BAF_CombatStyleEnabled)
				myActorBase.SetCombatStyle(myCombatStyle)
			endIf
			if(mainHook.BAF_ClassEnabled)
				myActorBase.SetClass(myClass)
			endIf
		endIf

		if(fullRefresh)
			refreshAppearance(true)
		elseIf(myTintlessMode)
			; Tintless preset: re-stamp morphs/hair WITHOUT the Skin bit; the
			; pipeline clears the RaceMenu mapping again right after. Hair color
			; and head morphs are transient reference overrides that revert on
			; every 3D reload — skipping this left followers with the template
			; hair color after cell changes. No Skin bit is ever applied, so the
			; blue-face guard (no tint gets pinned) still holds.
			refreshAppearance()
		else
			refreshAppearance()
		endIf
	endIf
endFunction

function updateMyVersion()
	if(myVersion < 2)
		myVersion = 2
		if !mainHook
			mainHook = (Game.GetFormFromFile(0x14f63, "BuildAFollower.esp") as Quest) as BAF_MCMScript
		endIf
	endIf
endFunction

function checkmyPresetName()
	self.SetDisplayName(myPresetName)
	myActorBase.SetName(myPresetName)
endFunction

; Re-asserts this follower's voice on its own ActorBase.
; Guarded: SetVoiceType(None) makes the engine fall back to the template's race
; default (the templates are Nord), which is one of the ways the voice
; "randomly" reverted to Nord after a load.
function checkMyVoice()
	if myPresetVoiceType
		myActorBase.SetVoiceType(myPresetVoiceType)
	endIf
endFunction

function refreshAppearance(bool fullRefresh = false)
	if myPreset == ""
		return
	endIf

	if(self.IsDisabled() || !self.Is3DLoaded())
		; RaceMenu CharGen on an unloaded actor half-applies (grey/blue face,
		; wrong head). Defer the full apply until the NPC is summoned.
		pendingFullApply = true
		dout("Preset apply deferred until summon (3D not loaded)")
		return
	endIf

	applyPresetPipeline(fullRefresh)

	; Full (user) apply: rebuild 3D so face tint commits cleanly.
	; - Tint on disk: Disable/Enable then re-stamp (classic dark-face fix).
	; - Tintless: reload only (mapping already cleared) so the broken tint
	;   texture is not left on the head after the first stamp.
	; Guarded so the reload's own OnLoad cannot recurse back into here.
	if fullRefresh && !reloadingFace
		commitFaceTint()
	endIf
endFunction

; The RaceMenu stamping pipeline (no 3D reload). Split out so commitFaceTint can
; re-run it on freshly loaded 3D without re-triggering another reload.
; RaceMenu neck seams on NPCs usually mean: wrong race, external head without a
; full body/skin base, or skin applied before the body morphs settled.
; Pipeline: SetRace → body+skin base → optional external head → skin/body reblend.
function applyPresetPipeline(bool fullRefresh = false)
	if myPresetRace
		Race currentRace = self.GetRace()
		bool raceDiffers = currentRace != myPresetRace
		; Only SetRace when the race actually changed, or on a user-initiated full
		; apply where head parts must rebind (neck-seam fix). SetRace rebuilds the
		; actor and makes the engine re-evaluate equipment — running it on every
		; cell load was unequipping gifted armor/weapons (the unequip-on-cell-change
		; / unequip-after-dismiss bug). Gear is snapshotted and restored around it.
		if raceDiffers || fullRefresh
			Form[] wornGear = getMyGear()
			dout("Setting race " + myPresetRace.GetName())
			self.SetRace(myPresetRace)
			if raceDiffers
				Utility.Wait(0.35)
			else
				Utility.Wait(0.1)
			endIf
			restoreGear(wornGear)
			; SetRace rebuilds the actor from its base, which also re-derives the
			; voice type from the (Nord) template — the "voice keeps reverting to
			; Nord" bug. updateMyData() applies the voice BEFORE this point, so it
			; is discarded here and must be re-asserted after the rebuild. This is
			; exactly what the manual MCM workaround (swap voice, then revert) was
			; doing by hand. Same reason gear is snapshotted/restored above.
			checkMyVoice()
		endIf
	endIf

	; Only auto-pick a head .nif if MCM left one set empty (user turned HeadNif off → myHeadMesh "")
	; Do not auto-enable external heads; wrong-race .nif is a common seam source.

	int fullMode = 15
	int liteMode = 5
	if BAF_RMFullMode
		fullMode = BAF_RMFullMode.GetValueInt()
	endIf
	if BAF_RMLiteMode
		liteMode = BAF_RMLiteMode.GetValueInt()
	endIf

	; Ensure Skin bit (8) is present on full apply — mode without skin is a top seam cause
	int applyMode = fullMode
	if fullRefresh
		applyMode = ensureSkinBodyFlags(fullMode)
	else
		applyMode = ensureSkinBodyFlags(liteMode)
	endIf

	; --- Read the preset IN PLACE (never rewrite a .jslot) ---
	; CRITICAL: do NOT round-trip a .jslot through JContainers. JContainers stores
	; ints as signed int32, so RaceMenu's UInt tintInfo colors (alpha 0xFF..) get
	; written back negative; RaceMenu's JSON parser then throws
	; "LargestInt out of UInt range" and hard-crashes on the next apply.
	; myPreset already carries its own ../Exported/ or ../Presets/ prefix, so we
	; hand it straight to CharGen and RaceMenu reads its own untouched file.
	String baseName = presetBaseName(myPreset)
	String presetDir = "Exported"
	if StringUtil.Find(myPreset, "Presets") > -1
		presetDir = "Presets"
	endIf

	; RaceMenu resolves the head tint to Textures/CharGen/<same folder>/<name>.dds.
	bool hasTintMask = MiscUtil.FileExists("Data/Textures/CharGen/" + presetDir + "/" + baseName + ".dds")
	; A full head export (from "Save my face for followers") lives only in Exported.
	bool hasExternalHead = MiscUtil.FileExists("Data/Meshes/CharGen/Exported/" + baseName + ".nif") && MiscUtil.FileExists("Data/Textures/CharGen/Exported/" + baseName + ".dds") && MiscUtil.FileExists("Data/SKSE/Plugins/CharGen/Exported/" + baseName + ".jslot")
	myTintlessMode = !hasTintMask && !hasExternalHead

	if hasExternalHead
		; Baked head export exists: copy head nif + tint into this template's
		; FaceGen and refresh the live tint. Engine-native path, best quality.
		dout("Applying external character (baked FaceGen) - " + baseName)
		CharGen.LoadExternalCharacterEx(self, myPresetRace, baseName, applyMode)
		Utility.Wait(0.15)
		CharGen.LoadCharacterEx(self, myPresetRace, myPreset, 8)  ; SkinOverrides
		Utility.Wait(0.05)
		CharGen.LoadCharacterEx(self, myPresetRace, myPreset, 2)  ; BodyMorphs
	elseIf hasTintMask
		; jslot + its exported tint mask both present: standard full apply is safe
		dout("Applying preset mode=" + applyMode + " - " + baseName)
		CharGen.LoadCharacterEx(self, myPresetRace, myPreset, applyMode)
		Utility.Wait(0.15)
		CharGen.LoadCharacterEx(self, myPresetRace, myPreset, 2)  ; overlay/body pass
	else
		; No exported tint mask -> applying SkinOverrides would pin the head to a
		; missing tint texture (grey/blue mismatch). Apply face morphs WITHOUT skin
		; so head and body both keep the template tone (they match), then clear the
		; RaceMenu mapping so head regens do not re-install a missing tint.
		int safeMode = Math.LogicalAnd(applyMode, 7) ; drop SkinOverrides(8)
		dout("Tintless preset - one-shot apply mode=" + safeMode + " - " + baseName)
		CharGen.LoadCharacterEx(self, myPresetRace, myPreset, safeMode)
		Utility.Wait(0.15)
		CharGen.ClearPreset(myActorBase)
	endIf

	; 4) Weight / skeleton refresh (SKEE) — soft fail if NiOverride missing
	fixNeckSeamPostProcess()

	Utility.Wait(0.05)
	self.QueueNiNodeUpdate()
endFunction

; Forces the engine to rebuild this actor's head 3D so the face tint re-bakes
; against the applied preset — the reliable in-mod fix for the dark / grey face
; bug, no external "face discoloration" mod required. Reproduces the known-good
; "summon first, then apply" ordering deterministically.
function commitFaceTint()
	if myPreset == "" || self.IsDisabled() || !self.Is3DLoaded()
		return
	endIf
	reloadingFace = true
	dout("Reloading 3D to rebuild the face")
	self.Disable()
	Utility.Wait(0.3)
	self.Enable()
	Utility.Wait(0.4)          ; let the fresh 3D load
	; Re-stamp onto the fresh head. Tinted presets get the full apply (their tint
	; is on disk and valid). Tintless presets get their morph-only one-shot again
	; (no Skin bit, mapping cleared after) — without it, hair color and head
	; morphs stay reverted to the template default after the rebuild (the
	; "hair turned blonde after Fix dark/grey face" bug).
	applyPresetPipeline(true)
	self.QueueNiNodeUpdate()
	reloadingFace = false
endFunction

; Public entry for the MCM "Fix dark/grey face" button. Summons the template if
; needed, then re-bakes the face. Safe on an already-recruited follower.
function forceFaceRefresh()
	if myPreset == ""
		return
	endIf
	if self.IsDisabled()
		self.Enable()
	endIf
	if !self.Is3DLoaded()
		self.MoveTo(Game.GetPlayer())
		Utility.Wait(0.5)
	endIf
	commitFaceTint()
endFunction

; RaceMenu flag bits: 1=Overrides 2=Body 4=Transforms 8=Skin (15=ALL).
; If the user dialed Debug modes that drop Skin/Body, force them back for seam safety.
int function ensureSkinBodyFlags(int mode)
	int m = mode
	if m < 0
		m = 0
	endIf
	if m > 15
		m = 15
	endIf
	; Always include Body (2) and Skin (8) for NPC preset stamping
	m = Math.LogicalOr(m, 2)
	m = Math.LogicalOr(m, 8)
	return m
endFunction

function fixNeckSeamPostProcess()
	; Re-assert weight so body/head scale match, then SKEE weight update
	if myActorBase
		float w = myActorBase.GetWeight()
		myActorBase.SetWeight(w)
	endIf
	; NiOverride ships with RaceMenu (SKEE). Soft: only call if DLL present.
	if MiscUtil.FileExists("data/SKSE/Plugins/skee64.dll")
		NiOverride.UpdateModelWeight(self)
	endIf
endFunction

; Strip ../Exported/ or ../Presets/ style prefixes down to the bare file name.
String function presetBaseName(String presetPath)
	String baseName = presetPath
	int slash = StringUtil.Find(baseName, "/")
	while slash > -1
		baseName = StringUtil.SubString(baseName, slash + 1)
		slash = StringUtil.Find(baseName, "/")
	endWhile
	slash = StringUtil.Find(baseName, "\\")
	while slash > -1
		baseName = StringUtil.SubString(baseName, slash + 1)
		slash = StringUtil.Find(baseName, "\\")
	endWhile
	return baseName
endFunction

; True while this NPC is parked (disabled or physically in the storage cell).
; Used by MCM to block "Teleport to NPC" so the player is never stranded there.
bool function isInStorage()
	if self.IsDisabled()
		return true
	endIf
	if BAF_CellMarker && self.GetParentCell() == BAF_CellMarker.GetParentCell()
		return true
	endIf
	return false
endFunction

bool function isTintless()
	return myTintlessMode
endFunction

; Whether the current preset has an exported face tint mask on disk.
bool function presetHasTintMask()
	if myPreset == ""
		return true
	endIf
	String baseName = presetBaseName(myPreset)
	String presetDir = "Exported"
	if StringUtil.Find(myPreset, "Presets") > -1
		presetDir = "Presets"
	endIf
	if MiscUtil.FileExists("Data/Textures/CharGen/" + presetDir + "/" + baseName + ".dds")
		return true
	endIf
	; A full external head export always carries its own tint next to the mesh
	if MiscUtil.FileExists("Data/Textures/CharGen/Exported/" + baseName + ".dds") && MiscUtil.FileExists("Data/Meshes/CharGen/Exported/" + baseName + ".nif")
		return true
	endIf
	return false
endFunction

; Resolve external exported head .nif for a RaceMenu preset path like ../Exported/Name
String function resolveHeadMeshPath(String presetPath)
	if presetPath == ""
		return ""
	endIf
	String baseName = presetPath
	; strip ../Exported/ or similar prefixes
	int slash = StringUtil.Find(baseName, "/")
	while slash > -1
		baseName = StringUtil.SubString(baseName, slash + 1)
		slash = StringUtil.Find(baseName, "/")
	endWhile
	slash = StringUtil.Find(baseName, "\\")
	while slash > -1
		baseName = StringUtil.SubString(baseName, slash + 1)
		slash = StringUtil.Find(baseName, "\\")
	endWhile

	String p1 = "data/SKSE/Plugins/CharGen/Exported/" + baseName + ".nif"
	String p2 = "data/SKSE/Plugins/CharGen/" + baseName + ".nif"
	String p3 = "data/SKSE/Plugins/CharGen/Presets/" + baseName + ".nif"
	if MiscUtil.FileExists(p1)
		return p1
	elseIf MiscUtil.FileExists(p2)
		return p2
	elseIf MiscUtil.FileExists(p3)
		return p3
	endIf
	return ""
endFunction

function clearMySpells()
	int sIndexer = mySpells.Length

	while(sIndexer > 0)
		sIndexer -= 1
		if(mySpells[sIndexer] as Spell != none && self.HasSpell(mySpells[sIndexer]as Spell))
			self.RemoveSpell(mySpells[sIndexer] as Spell)
		endIf
	endWhile

	mySpells = new Form[1]
endFunction

function clearMyShouts()
	int sIndexer = myShouts.Length

	while(sIndexer > 0)
		sIndexer -= 1
		if(myShouts[sIndexer] as Shout != none && self.HasSpell(myShouts[sIndexer]as Shout))
			self.RemoveShout(myShouts[sIndexer] as Shout)
		endIf
	endWhile

	myShouts = new Form[1]
endFunction

function checkMySpells()
	int sIndexer = mySpells.Length

	while(sIndexer > 0)
		sIndexer -= 1
		if(mySpells[sIndexer] as Spell != none && !self.HasSpell(mySpells[sIndexer] as Spell))
			self.AddSpell(mySpells[sIndexer] as Spell)
		endIf
	endWhile
endFunction

function checkMyShouts()
	int sIndexer = myShouts.Length

	while(sIndexer > 0)
		sIndexer -= 1
		if(myShouts[sIndexer] as Shout != none && !self.HasSpell(myShouts[sIndexer] as Shout))
			self.AddShout(myShouts[sIndexer] as Shout)
		endIf
	endWhile
endFunction

function checkRelationship()
	if(GetRelationshipRank(Game.GetPlayer()) < 3)
		SetRelationshipRank(Game.GetPlayer(), 3)
		dout("Fixed relationship")
	endIf
endFunction

function dout(String inText)
	String outputText = "BuildAFollower: " + myPresetName + "- ("  + self + ") - " + inText
	if(BAF_TraceMode.GetValueInt() == 0)
		Debug.Trace(outputText)
	else
		MiscUtil.PrintConsole(outputText)
	endIf
endFunction

function toggleSpell(Spell inSpell)
	int sIndexer
	if(mySpells.Find(inSpell) > -1)
		sIndexer = mySpells.Find(inSpell)
		self.RemoveSpell(inSpell)
		mySpells[sIndexer] = none

		mySpells = compressSpellArray(mySpells)
		dout("Removed spell " + inSpell.GetName())
	else
		sindexer = mySpells.Find(none)

		if(sIndexer == -1)
			mySpells = Utility.ResizeFormArray(mySpells, mySpells.Length + 1, none)
		endIf

		sIndexer = mySpells.Find(none)
		mySpells[sIndexer] = inSpell
		self.AddSpell(inSpell)

		dout("Added spell " + inSpell.GetName())
	endIf
endFunction

function toggleSpellByIndex(int spellindex)
	toggleSpell(mySpells[spellindex] as Spell)
endFunction

function toggleShout(Shout inShout)
	int sIndexer
	if(myShouts.Find(inShout) > -1)
		sIndexer = myShouts.Find(inShout)
		self.RemoveShout(inShout)
		myShouts[sIndexer] = none

		myShouts = compressSpellArray(myShouts)
		dout("Removed shout " + inShout.GetName())
	else
		sindexer = myShouts.Find(none)

		if(sIndexer == -1)
			myShouts = Utility.ResizeFormArray(myShouts, myShouts.Length + 1, none)
		endIf

		sIndexer = myShouts.Find(none)
		myShouts[sIndexer] = inShout
		self.AddShout(inShout)

		dout("Added shout " + inShout.GetName())
	endIf
endFunction



;Setters
function setMyPresetName(String inName)
	if(inName != "")
		dout("Updating Preset Name - " + inName)
		myPresetName = inName
		self.SetDisplayName(myPresetName)
		myActorBase.SetName(myPresetName)
	else
		dout("Updating Preset Name Failed - " + inName)
	endIf
endFunction

function setMyPresetVoice(VoiceType inVoice)
	if(inVoice as VoiceType)
		dout("Updating Preset VoiceType - " + inVoice)
		myPresetVoiceType = inVoice
		myActorBase.SetVoiceType(myPresetVoiceType)
	else
		dout("Updating Preset VoiceType Failed - " + inVoice)
	endIf
endFunction

function setMyPresetRace(Race inRace)
	if(inRace as Race)
		dout("Updating Preset Race - " + inRace )
		myPresetRace = inRace
		if(self.Is3DLoaded() && !self.IsDisabled())
			self.SetRace(inRace)
		endIf
	else
		dout("Updating Preset Race Failed - " + inRace )
	endIf
endFunction

function setMyPreset(String inPreset)
	if(inPreset != "")
		dout("Updating Full Preset - " + inPreset )
		myPreset = inPreset
	else
		dout("Updating Full Preset Failed - " + inPreset )
	endIf
endFunction

function setMyHeadMesh(String inHeadMesh)
	myHeadMesh = inHeadMesh
endFunction

function setMyCombatStyleData(CombatStyle inStyle)
	myCombatStyle = inStyle
	myActorBase.SetCombatStyle(myCombatStyle)
	dout("Changed combatstyle for " + myPresetName)
endFunction

function setMyClass(class InClass)	
	myClass = inClass
	myActorBase.SetClass(myClass)
	dout("Changed class for " + myPresetName)
endFunction

;Getters
String function getMyPresetName()
	return myPresetName
endFunction

VoiceType function getMyPresetVoiceType()
	return myPresetVoiceType
endFunction

String function getMyPreset()
	return myPreset
endFunction

Race function getMyPresetRace()
	return myPresetRace
endFunction

CombatStyle function getMyCombatStyle()
	return myCombatStyle
endFunction

Class function getMyClass()
	return myClass
EndFunction

Form[] function getMySpells()
	return mySpells
endFunction


String[] function getMySpellNames()
	String[] spellNames = new String[1]
	spellNames[0] = "none"	
	int sIndexer = mySpells.Length
	int stringDexer = 0

	while(sIndexer > 0)
		sIndexer -= 1

		if(mySpells[sIndexer] != none)
			spellNames[stringDexer] = mySpells[sIndexer].GetName()
			spellNames = Utility.ResizeStringArray(spellNames, spellNames.Length + 1, none)
			stringDexer += 1
		endIf
	endWhile

	return spellNames
endFunction


String[] function getMyShoutNames()
	String[] shoutNames = new String[1]
	shoutNames[0] = "none"	
	int sIndexer = myShouts.Length
	int stringDexer = 0

	while(sIndexer > 0)
		sIndexer -= 1

		if(myShouts[sIndexer] != none)
			shoutNames[stringDexer] = myShouts[sIndexer].GetName()
			shoutNames = Utility.ResizeStringArray(shoutNames, shoutNames.Length + 1, none)
			stringDexer += 1
		endIf
	endWhile

	return shoutNames
endFunction

Actor function getMyActor()
	return self as Actor
endFunction

Form[] function getMyGear()
	Form[] gear = Utility.CreateFormArray(1, none)
	gear[0] = none

	int n = 0x01
	int n2 = 0


	while (n < 0x80000000)
		if (Math.LogicalAnd(n2, n) != n) ;only check slots we haven't found anything equipped on already
			Armor thisPiece = GetWornForm(n) as Armor
				if thisPiece != NONE
					gear =  addGearToArray(gear, thisPiece) 
				endif
		else ;no armor was found on this slot
			n2 += n
		endif

		n *= 2 ;double the number to move on to the next slot
	endWhile
	
	if(GetEquippedWeapon(true) as Weapon) ;Left Weapon
		gear =  addGearToArray(gear, GetEquippedWeapon(true))
	endIf
	
	if(GetEquippedWeapon() as Weapon) ;Right Weapon
		gear = addGearToArray(gear, GetEquippedWeapon())
	endIf
	
	if(GetEquippedShield() as Armor) ;Right Weapon
		gear = addGearToArray(gear, GetEquippedShield())
	endIf

	return gear
endFunction

Form[] function addGearToArray(Form[] inArray, Form inGear)
	if(inArray.Find(inGear) == -1) ;Do not add duplicates
		int emptySlot = inArray.Find(none)
		if(emptySlot == -1)
			inArray = Utility.ResizeFormArray(inArray, inArray.Length + 1, none)
		endIf
		emptySlot = inArray.Find(none)	
		inArray[emptySlot] = inGear
	endIf
	return inArray
endFunction

; Re-equips everything worn before a SetRace rebuild. Stripped items stay in
; the inventory, and EquipItem is a harmless no-op for anything still worn.
function restoreGear(Form[] wornGear)
	if !wornGear
		return
	endIf
	int gIndexer = wornGear.Length
	while gIndexer > 0
		gIndexer -= 1
		if wornGear[gIndexer]
			self.EquipItem(wornGear[gIndexer], false, true)
		endIf
	endWhile
endFunction

Form[] function compressSpellArray(Form[] inArray)
	Form[] newArray = Utility.CreateFormArray(1, none)
	int newIndexer = 0
	int inIndexer = inArray.Length

	while(inIndexer > 0)
		inIndexer -= 1
		if(inArray[inIndexer] != none)
			newArray[newIndexer] = inArray[inIndexer]
			newArray = Utility.ResizeFormArray(newArray, newArray.Length + 1, none)
			newIndexer += 1	
		endIf
	endWhile

	return newArray
endFunction