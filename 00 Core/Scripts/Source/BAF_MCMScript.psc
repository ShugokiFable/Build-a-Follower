Scriptname BAF_MCMScript extends SKI_ConfigBase  

Formlist Property BAF_NPCs Auto
Formlist Property BAF_CombatStyles Auto
Formlist Property BAF_FemaleVoices Auto
Formlist Property BAF_MaleVoices Auto
Formlist Property BAF_Races Auto
Formlist Property BAF_Spells Auto
Formlist Property BAF_Shouts Auto
Formlist Property BAF_Classes Auto

GlobalVariable Property BAF_RMDelay Auto
GlobalVariable Property BAF_RMFullMode Auto
GlobalVariable Property BAF_RMLiteMode Auto
GlobalVariable Property BAF_SandboxEnable Auto
GlobalVariable Property BAF_TraceMode Auto
Bool Property BAF_CombatStyleEnabled Auto
Bool Property BAF_ClassEnabled Auto

String[] Property FVoicesList Auto
String[] Property MVoicesList Auto
String[] Property RacesList Auto
String[] Property skillNames Auto
String[] Property classesNames Auto
String[] Property NPCList Auto
String[] Property PresetList Auto
String[] Property NPCpresetList Auto
String[] property combatStyleNames Auto

float[] property  combatStyle1Data Auto
float[] property  combatStyle2Data Auto
float[] property  combatStyle3Data Auto
float[] property  combatStyle4Data Auto
float[] property  combatStyle5Data Auto
float[] property  combatStyle6Data Auto
float[] property  combatStyle7Data Auto
float[] property  combatStyle8Data Auto
float[] property  combatStyle9Data Auto
float[] property  combatStyle10Data Auto

BAF_ConfigManager Property cfgMan Auto

Faction Property BAF_Faction Auto
Actor Property PlayerRef Auto

Actor tarActor
BAF_ActorScript actorScript
CombatStyle tarStyle

;Main
int eventHandle
bool msgBool
bool femVoice
bool hasHeadMesh
bool headMeshAvailable
bool legacyHeadExport
bool headMeshUse
bool headMeshStateInit
String headMeshPresetKey
bool NPCPresetsFound
bool noMatchingSexSlot
bool csDisabledBySkyTactics
bool skyTacticsInstalled
String newPreset
String newName
String headMeshPath
String presetFolder
String[] presetFolderList
bool suppressRaceAutosave

int guiNPCList
int guiFVoicesList
int guiMVoicesList
int guiRacesList
int guiSummonToggle
int guiTeleportToggle
int guiFixFace
int guiSaveMyFace
int guiResetToggle
int guiNPCName
int guiPresetsList
int guiNPCPresetList
int guiPresetHeadMesh
int guiApplySettings
int guiGlobalApply
int guiNPCCombatStyle
int guiCopyKit
int guiCopyKitAutoEquip
int guiSummonAll
int guiCSDisabledText
int guiClassDisabledText

;Save/Load
int guiSaveConfig
bool savingConfigToDisk
int guiLoadConfig
bool loadingConfigFromDisk

int guiSaveNPCs
int guiSaveSingleNPCs
bool savingNPCsToDisk
int guiLoadNPCs
bool loadingNPCsFromDisk

;Copy Kit
bool copyKitActive
bool copyKitAutoEquip = false

;Stats
int guiWeaponSpeedMulti
int guiBowSpeedMulti
int guiAttackDamageMult
int guiSpeedMulti
int guiDamageResist
int guiMagicResist
int guiHealth
int guiMagicka
int guiStamina
int guiHealRate
int guiMagickaRate
int guiStaminaRate

;Skills
int guiSkillsList
int guiSkillsInput

;CombatStyle
int guiCombatStyle
int guiCombatStyleName

bool combatStyleSaveChanges

;Classes
int guiNPCClass
int guiClassesNames


;CombatStyle - General tab options
int guiCsOffensive
int guiCsDefensive
int guiCsGroupOffensive
int guiCsAvoidThreatChance
int guiCsMelee
int guiCsRanged
int guiCsMagic
int guiCsShout
int guiCsStaff
int guiCsUnarmed

;CombatStyle - Melee tab
int guiMeleeAttackStaggered
int guiMeleePowerAttackStaggered
int guiMeleePowerAttackBlocking
int guiMeleeBash
int guiMeleeBashRecoiled
int guiMeleeBashAttack
int guiMeleeBashPowerAttack
int guiMeleeSpecialAttack
int guiAllowDualWielding

;CombatStyle - Ranged tab
int guiCloseRangeDuelingCircle
int guiCloseRangeDuelingFallback
int guiCloseRangeFlankingFlankDistance
int guiCloseRangeFlankingStalkTime

;CombatStyle - LongRange tab
int guiLongRangeStrafeMult

;Spells
int guiSpellList
int guiNPCSpellListNames
String[] guiSpellListNames

;Shouts
int guiShoutList
int guiNPCShoutListNames
String[] guiShoutListNames

;Debug

int guiDebugRMDelay
int guiDebugRMFullMode
int guiDebugRMLiteMode
int guiDebugTraceMode
String[] guiDebugTraceModes
int guiDebugSandboxEnable
int guiDebugCSEnable
int guiDebugClassEnable
int guiDebugPO3Spells

;Indexers
int Nindex
int Fvindex
int Mvindex
int CSindex
int Rindex
int Prindex
int NPrindex
int FAPIndex
int SKindex
int ClassIndex

; Legacy "Follower Goes on a Trip" integration was REMOVED in 2.4.4.
; FGT is abandoned; when it isn't installed travelHook stayed None and the
; "Followers Travel" button threw a Papyrus error on every use. It also made the
; whole mod impossible to recompile (FGTDialogueQuest has no available source),
; which blocked every future script fix. Followers you aren't using are managed
; through the vanilla follower system / Nether's Follower Framework instead.
Faction Property CurrentFollowerFaction Auto

;PO3Extender
bool po3ExtenderInstalled

int version = 1
bool updaterIsRunning = false

int function GetVersion()
	return version ; Initial
endFunction

Event OnConfigRegister()
	parent.OnConfigInit()
	RegisterForModEvent("BuildAFollowerOnloadUpdate", "OnBuildAFollowerOnloadUpdate")
	updater()
	initVars()
endEvent

Event OnBuildAFollowerOnloadUpdate()
	setCSValues()
	RegisterForModEvent("BuildAFollowerOnloadUpdate", "OnBuildAFollowerOnloadUpdate")
endEvent

Event OnConfigOpen()
	getCustomRace(playerRef)
	getNPCTarget()
endEvent

Event OnConfigClose()
	if(combatStyleSaveChanges)
		combatStyleSaveChanges = false
		initCSValues()
	endIf
endEvent

event OnPageReset(string page)
	if(page == " Main")		
		drawMainMenu()
	elseIf(page == " Stats")
		drawStatsMenu()
	elseIf(page == " Spells")
		drawSpellsMenu()
	elseIf(page == " Shouts")
		drawShoutsMenu()
	elseIf(page ==" Combat")
		drawCombatMenu()
	elseIf(page ==" Debug")
		drawDebugMenu()
	elseIf(page ==" SaveLoad")
		drawSaveLoadMenu()
	endIf
endEvent

function sendGlobalUpdateRequest()
	eventHandle = ModEvent.Create("BuildAFollowerUpdate")
	ModEvent.Send(eventHandle)
endFunction

function updater()
	; updaterIsRunning used to gate this whole function, but it persists in the
	; save — a crash mid-run left it TRUE and permanently disabled race/mod
	; detection for that save (one of the ways "custom races never show up"
	; happens). Re-entry is harmless (every add dedupes), so only the one-time
	; migrations stay gated, on version.
	if(version == 1)
		dout("Updating from 1 -> 2")
		guiDebugTraceModes = new String[3]
		guiDebugTraceModes[0] = "Console"
		guiDebugTraceModes[1] = "Papyrus log"
		guiDebugTraceModes[2] = "Disable"
		BAF_TraceMode.SetValueInt(0)
		version = 2
	endIf
	getInstalledMods()
	loadCustomRaces()
endFunction

function initVars()
	initSpellLists()
	initShoutLists()
	initCSList()
	initCSValues()
endFunction

function initSpellLists()
	guiSpellListNames = Utility.CreateStringArray(BAF_Spells.GetSize())

	int sIndexer = guiSpellListNames.Length

	while(sIndexer > 0)
		sIndexer -= 1
		Spell toAdd = BAF_Spells.GetAt(sIndexer) as Spell
		guiSpellListNames[sIndexer] = toAdd.GetName() + getSpellEquipSlot(toAdd)	
	endWhile
endFunction

String function getSpellEquipSlot(Spell inSpell)
	String result

	if(inSpell.GetEquipType() == Game.GetForm(0x00013F44))
		result= "(-)"
	elseIf(inSpell.GetEquipType() == Game.GetForm(0x00013F42))
		result= "(R)"
	elseIf(inSpell.GetEquipType() == Game.GetForm(0x00013F43))
		result= "(L)"
	endIf
	return result
endFunction

function initShoutLists()
	guiShoutListNames = Utility.CreateStringArray(BAF_Shouts.GetSize())

	int sIndexer = guiShoutListNames.Length

	while(sIndexer > 0)
		sIndexer -= 1
		guiShoutListNames[sIndexer] = BAF_Shouts.GetAt(sIndexer).GetName()		
	endWhile
endFunction

function initNPCList()
	NPCList = Utility.CreateStringArray(BAF_NPCs.GetSize())

	int indexer = NPCList.Length

	while(indexer > 0)
		indexer -= 1
		NPCList[indexer] = (BAF_NPCs.GetAt(indexer) as BAF_ActorScript).getmyPresetName()
	endWhile
endFunction

function initCSList()
	; Full descriptive names for every slot (not just 0-3).
	; Saved JSON custom names still win via loadCombatStyleNames after this.
	int n = BAF_CombatStyles.GetSize()
	combatStyleNames = Utility.CreateStringArray(n)

	int i = 0
	while i < n
		combatStyleNames[i] = defaultCombatStyleName(i)
		; If still generic, label from live CSTY mults
		if StringUtil.Find(combatStyleNames[i], "Style ") == 0 || combatStyleNames[i] == ""
			CombatStyle cs = BAF_CombatStyles.GetAt(i) as CombatStyle
			if cs
				combatStyleNames[i] = autoNameFromCombatStyle(cs, i)
			else
				combatStyleNames[i] = "Empty slot " + (i + 1)
			endIf
		endIf
		i += 1
	endWhile
	dout("Combat style names set for " + n + " slots")
endFunction

String function defaultCombatStyleName(int index)
	; Hand-authored defaults for the built-in pool (20 styles)
	if index == 0
		return "1H Spellsword"
	elseIf index == 1
		return "Magic Archer"
	elseIf index == 2
		return "1H Tank / Shield"
	elseIf index == 3
		return "Pure Caster"
	elseIf index == 4
		return "Dual-Wield Skirmisher"
	elseIf index == 5
		return "2H Berserker"
	elseIf index == 6
		return "Archer / Bow"
	elseIf index == 7
		return "Battlemage"
	elseIf index == 8
		return "Shield Wall"
	elseIf index == 9
		return "Assassin / Flanker"
	elseIf index == 10
		return "Staff Mage"
	elseIf index == 11
		return "Sniper / Long Range"
	elseIf index == 12
		return "Aggressive Melee"
	elseIf index == 13
		return "Defensive Melee"
	elseIf index == 14
		return "Melee-Magic Hybrid"
	elseIf index == 15
		return "Ranged Support"
	elseIf index == 16
		return "Unarmed / Brawler"
	elseIf index == 17
		return "Shout-Heavy"
	elseIf index == 18
		return "Balanced Fighter"
	elseIf index == 19
		return "Custom / Flex Slot"
	endIf
	return "Style " + (index + 1)
endFunction

String function autoNameFromCombatStyle(CombatStyle cs, int index)
	float melee = cs.GetMeleeMult()
	float ranged = cs.GetRangedMult()
	float magic = cs.GetMagicMult()
	float defn = cs.GetDefensiveMult()
	float off = cs.GetOffensiveMult()
	float unarmed = cs.GetUnarmedMult()
	float fShout = cs.GetShoutMult()
	float staff = cs.GetStaffMult()

	String role = "Fighter"
	if magic >= melee && magic >= ranged && magic >= unarmed
		if staff >= magic * 0.8
			role = "Staff Mage"
		else
			role = "Caster"
		endIf
	elseIf ranged >= melee && ranged >= magic
		role = "Archer"
	elseIf unarmed >= melee && unarmed >= ranged && unarmed >= magic
		role = "Brawler"
	elseIf melee >= ranged && melee >= magic
		if defn >= 0.7 && defn >= off
			role = "Tank"
		elseIf off >= 0.85
			role = "Berserker"
		else
			role = "Melee"
		endIf
	endIf

	if fShout >= 1.5 && fShout >= melee && fShout >= magic
		role = "Shout user"
	endIf

	; Slot number keeps the list unique when several share a role
	return role + " (" + (index + 1) + ")"
endFunction

function initCSValues()
	; Cache first 10 styles into legacy arrays (MCM combat editor uses these)
	; Styles 11+ still exist on the FormList and can be assigned to NPCs; edit via slot 1-10 or JSON save
	int n = BAF_CombatStyles.GetSize()
	if n > 0
		combatStyle1Data = getCombatStyleData(BAF_CombatStyles.GetAt(0) as CombatStyle)
	endIf
	if n > 1
		combatStyle2Data = getCombatStyleData(BAF_CombatStyles.GetAt(1) as CombatStyle)
	endIf
	if n > 2
		combatStyle3Data = getCombatStyleData(BAF_CombatStyles.GetAt(2) as CombatStyle)
	endIf
	if n > 3
		combatStyle4Data = getCombatStyleData(BAF_CombatStyles.GetAt(3) as CombatStyle)
	endIf
	if n > 4
		combatStyle5Data = getCombatStyleData(BAF_CombatStyles.GetAt(4) as CombatStyle)
	endIf
	if n > 5
		combatStyle6Data = getCombatStyleData(BAF_CombatStyles.GetAt(5) as CombatStyle)
	endIf
	if n > 6
		combatStyle7Data = getCombatStyleData(BAF_CombatStyles.GetAt(6) as CombatStyle)
	endIf
	if n > 7
		combatStyle8Data = getCombatStyleData(BAF_CombatStyles.GetAt(7) as CombatStyle)
	endIf
	if n > 8
		combatStyle9Data = getCombatStyleData(BAF_CombatStyles.GetAt(8) as CombatStyle)
	endIf
	if n > 9
		combatStyle10Data = getCombatStyleData(BAF_CombatStyles.GetAt(9) as CombatStyle)
	endIf
	dout("Init CombatStyle data (" + n + " styles in pool)")
endFunction

function setCSValues()
	int n = BAF_CombatStyles.GetSize()
	if n > 0
		setMyCombatStyleData(BAF_CombatStyles.GetAt(0) as CombatStyle, combatStyle1Data)
	endIf
	if n > 1
		setMyCombatStyleData(BAF_CombatStyles.GetAt(1) as CombatStyle, combatStyle2Data)
	endIf
	if n > 2
		setMyCombatStyleData(BAF_CombatStyles.GetAt(2) as CombatStyle, combatStyle3Data)
	endIf
	if n > 3
		setMyCombatStyleData(BAF_CombatStyles.GetAt(3) as CombatStyle, combatStyle4Data)
	endIf
	if n > 4
		setMyCombatStyleData(BAF_CombatStyles.GetAt(4) as CombatStyle, combatStyle5Data)
	endIf
	if n > 5
		setMyCombatStyleData(BAF_CombatStyles.GetAt(5) as CombatStyle, combatStyle6Data)
	endIf
	if n > 6
		setMyCombatStyleData(BAF_CombatStyles.GetAt(6) as CombatStyle, combatStyle7Data)
	endIf
	if n > 7
		setMyCombatStyleData(BAF_CombatStyles.GetAt(7) as CombatStyle, combatStyle8Data)
	endIf
	if n > 8
		setMyCombatStyleData(BAF_CombatStyles.GetAt(8) as CombatStyle, combatStyle9Data)
	endIf
	if n > 9
		setMyCombatStyleData(BAF_CombatStyles.GetAt(9) as CombatStyle, combatStyle10Data)
	endIf
	dout("Save CombatStyle data")
endFunction

function getNPCTarget()
	tarActor = none
	noMatchingSexSlot = false

	if(Game.GetCurrentCrosshairRef() as Actor)
		Actor curTar = Game.GetCurrentCrosshairRef() as Actor
		if(curTar.IsInFaction(BAF_Faction))
			dout("Found Build a Follower NPC under crosshair")
			tarActor = curTar
		else
			; Looking at a world NPC — harvest race/voice, then pick free slot
			getCustomRace(curTar)
			getCustomVoiceParser(curTar)
			tarActor = findBestSlot(curTar.GetActorBase().GetSex())
			if tarActor == none
				; Keep the MCM usable, but never let the next Apply silently use
				; an opposite-sex template when no matching slot is free.
				noMatchingSexSlot = true
			endIf
		endIf
	endIf

	if(tarActor == none) ; crosshair empty / VR
		tarActor = findBestSlot(-1)
	endIf

	if tarActor == none
		tarActor = BAF_NPCs.GetAt(0) as Actor
	endIf
	
	actorScript = tarActor as BAF_ActorScript
	getNPCIndex()
	femVoice = tarActor.GetActorBase().GetSex()
	newName = actorScript.getMyPresetName()
endFunction

; With a requested sex, return only an empty template of that sex. Falling
; back to the other sex is unsafe for RaceMenu heads, bodies, and voices.
Actor function findBestSlot(int preferredSex)
	Actor firstEmpty = none
	int n = BAF_NPCs.GetSize()
	int i = 0
	while i < n
		Actor a = BAF_NPCs.GetAt(i) as Actor
		BAF_ActorScript scr = a as BAF_ActorScript
		if scr && scr.getMyPreset() == ""
			if firstEmpty == none
				firstEmpty = a
			endIf
			if preferredSex < 0 || a.GetActorBase().GetSex() == preferredSex
				dout("Free slot: " + a.GetDisplayName() + " (" + i + "/" + n + ")")
				return a
			endIf
		endIf
		i += 1
	endWhile
	if firstEmpty && preferredSex < 0
		dout("Free slot: using first empty")
		return firstEmpty
	endIf
	if preferredSex >= 0
		dout("No free template with matching sex — dismiss a matching follower first")
	else
		dout("All " + n + " slots in use — dismiss one to free a template")
	endIf
	return none
endFunction

function getNPCTargetData()
	SetMenuOptionValue(guiNPCList, NPCList[Nindex])
	SetMenuOptionValue(guiNPCCombatStyle, combatStyleNames[getCSIndex()])
	SetMenuOptionValue(guiNPCClass, classesNames[getClassIndex()])
	newName = actorScript.getMyPresetName()
	SetInputOptionValue(guiNPCName, newName)
	SetMenuOptionValue(guiFVoicesList, FVoicesList[getFVoiceIndex()])
	SetMenuOptionValue(guiMVoicesList, MVoicesList[getMVoiceIndex()])
	SetMenuOptionValue(guiRacesList,RacesList[getRaceIndex()])
	SetMenuOptionValue(guiPresetsList,PresetList[getPresetIndex()])
	SetMenuOptionValue(guiNPCPresetList,NPCPresetList[getNPCPresetIndex()])
	SetMenuOptionValue(guiRacesList,RacesList[getRaceIndex()])
	SetToggleOptionValue(guiPresetHeadMesh, getHasHeadMesh())
endFunction


function getNPCTargetStatsData()
	SetInputOptionValue(guiWeaponSpeedMulti, tarActor.GetAV("WeaponSpeedMult") as String)
	SetInputOptionValue(guiBowSpeedMulti, tarActor.GetAV("BowSpeedBonus") as String)
	SetSliderOptionValue(guiAttackDamageMult, tarActor.GetAV("AttackDamageMult"), "{2}")
	SetInputOptionValue(guiSpeedMulti, tarActor.GetAV("SpeedMult") as String)
	SetInputOptionValue(guiDamageResist, tarActor.GetAV("DamageResist") as String)
	SetInputOptionValue(guiMagicResist, tarActor.GetAV("MagicResist") as String)
	SetInputOptionValue(guiHealth, tarActor.GetAV("Health") as String)
	SetInputOptionValue(guiStamina, tarActor.GetAV("Stamina") as String)
	SetInputOptionValue(guiMagicka, tarActor.GetAV("Magicka") as String)
	SetInputOptionValue(guiHealRate, tarActor.GetAV("HealRate") as String)
	SetInputOptionValue(guiStaminaRate, tarActor.GetAV("StaminaRate") as String)
	SetInputOptionValue(guiMagickaRate, tarActor.GetAV("MagickaRate") as String)
	SetSliderOptionValue(guiSkillsInput, tarActor.GetAV(skillNames[SKindex]))
endFunction

float[] function getCombatStyleData(CombatStyle inStyle)
	float[] csValues = new float[24]

	csValues[0] = inStyle.GetOffensiveMult()
	csValues[1] = inStyle.GetDefensiveMult()
	csValues[2] = inStyle.GetGroupOffensiveMult()
	csValues[3] = inStyle.GetAvoidThreatChance()
	csValues[4] = inStyle.GetMeleeMult()
	csValues[5] = inStyle.GetRangedMult()
	csValues[6] = inStyle.GetMagicMult()
	csValues[7] = inStyle.GetShoutMult()
	csValues[8] = inStyle.GetStaffMult()
	csValues[9] = inStyle.GetUnarmedMult()

	csValues[10] = inStyle.GetCloseRangeDuelingCircleMult()
	csValues[11] = inStyle.GetCloseRangeDuelingFallbackMult()
	csValues[12] = inStyle.GetCloseRangeFlankingFlankDistance()
	csValues[13] = inStyle.GetCloseRangeFlankingStalkTime()
	csValues[14] = inStyle.GetLongRangeStrafeMult()

	csValues[15] = inStyle.getMeleeAttackStaggeredMult()
	csValues[16] = inStyle.getMeleePowerAttackStaggeredMult()
	csValues[17] = inStyle.GetMeleePowerAttackBlockingMult()
	csValues[18] = inStyle.GetMeleeBashMult()
	csValues[19] = inStyle.GetMeleeBashRecoiledMult()
	csValues[20] = inStyle.GetMeleeBashAttackMult()
	csValues[21] = inStyle.GetMeleeBashPowerAttackMult()
	csValues[22] = inStyle.GetMeleeSpecialAttackMult()

	csValues[23] = inStyle.GetAllowDualWielding() as float

	return csValues
endFunction

function setMyCombatStyleData(CombatStyle inStyle, float[] inValues)
	inStyle.SetOffensiveMult(inValues[0])
	inStyle.SetDefensiveMult(inValues[1])
	inStyle.SetGroupOffensiveMult(inValues[2])
	inStyle.SetAvoidThreatChance(inValues[3])
	inStyle.SetMeleeMult(inValues[4])
	inStyle.SetRangedMult(inValues[5])
	inStyle.SetMagicMult(inValues[6])
	inStyle.SetShoutMult(inValues[7])
	inStyle.SetStaffMult(inValues[8])
	inStyle.SetUnarmedMult(inValues[9])

	inStyle.SetCloseRangeDuelingCircleMult(inValues[10])
	inStyle.SetCloseRangeDuelingFallbackMult(inValues[11])
	inStyle.SetCloseRangeFlankingFlankDistance(inValues[12])
	inStyle.SetCloseRangeFlankingStalkTime(inValues[13])
	inStyle.SetLongRangeStrafeMult(inValues[14])

	inStyle.SetMeleeAttackStaggeredMult(inValues[15])
	inStyle.SetMeleePowerAttackStaggeredMult(inValues[16])
	inStyle.SetMeleePowerAttackBlockingMult(inValues[17])
	inStyle.SetMeleeBashMult(inValues[18])
	inStyle.SetMeleeBashRecoiledMult(inValues[19])
	inStyle.SetMeleeBashAttackMult(inValues[20])
	inStyle.SetMeleeBashPowerAttackMult(inValues[21])
	inStyle.SetMeleeSpecialAttackMult(inValues[22])

	inStyle.SetAllowDualWielding(inValues[23] as bool)
endFunction



function getPresetList()
	; Merge BOTH preset folders. Previously Exported won outright and Presets was
	; only listed when Exported was completely empty — so a single stray .jslot in
	; Exported hid every preset in CharGen/Presets ("my presets cannot be found by
	; the mod"). presetFolderList keeps the correct RaceMenu load path per entry.
	; On a name clash the Exported copy wins (it usually has the head/tint export
	; next to it). Paths are never rewritten — presets are read in place.
	String[] exported = MiscUtil.FilesInFolder("data/SKSE/Plugins/CharGen/Exported", ".jslot")
	String[] presets = MiscUtil.FilesInFolder("data/SKSE/Plugins/CharGen/Presets", ".jslot")

	int total = 0
	if exported
		total += exported.Length
	endIf
	if presets
		total += presets.Length
	endIf

	presetFolder = ""
	if total == 0
		PresetList = new String[1]
		PresetList[0] = "(no presets found)"
		presetFolderList = new String[1]
		presetFolderList[0] = ""
		dout("MiscUtil found no .jslot under CharGen/Exported or CharGen/Presets — check PapyrusUtil + RaceMenu paths")
		return
	endIf

	PresetList = Utility.CreateStringArray(total)
	presetFolderList = Utility.CreateStringArray(total)
	int w = 0
	int i = 0
	if exported
		while i < exported.Length
			PresetList[w] = exported[i]
			presetFolderList[w] = "../Exported/"
			w += 1
			i += 1
		endWhile
	endIf
	if presets
		i = 0
		while i < presets.Length
			bool clash = false
			if exported
				clash = exported.Find(presets[i]) > -1
			endIf
			if !clash
				PresetList[w] = presets[i]
				presetFolderList[w] = "../Presets/"
				w += 1
			endIf
			i += 1
		endWhile
	endIf
	if w < total
		PresetList = Utility.ResizeStringArray(PresetList, w)
		presetFolderList = Utility.ResizeStringArray(presetFolderList, w)
	endIf
	dout("Preset list: " + w + " .jslot merged from CharGen/Exported + CharGen/Presets")
endFunction

function getNPCPResetList()
	NPCpresetList = MiscUtil.FilesInFolder("data/SKSE/Plugins/BuildAFollower/BuildAFollowerNPCs", ".json")

	if(NPCpresetList.Length == 0)
		NPCPresetsFound = false
	elseIf(NPCpresetList.Length > 0)
		NPCPresetsFound = true
	else
		NPCPresetsFound = false ;failsafe
		dout("MiscUtil failed reading BuildAFollowerNPCs.json, verify PapyrusUtil is installed, activated and have none of its files overwritten")
	endIf
endFunction

function drawSpellsMenu()
	SetTitleText("Spells - " + actorScript.getMyPresetName())
	SetCursorFillMode(TOP_TO_BOTTOM)
	guiNPCSpellListNames = AddMenuOption("Added spells:", actorScript.getMySpellNames()[0])
	SetCursorPosition(1)
	guiSpellList = AddMenuOption("Spells", guiSpellListNames[0])
endFunction

function drawShoutsMenu()
	msgBool = ShowMessage("Adding shouts to NPCs will corrupt your savegame - DO NOT USE THIS UNLESS THIS GAME BUG IS FIXED",  true)

		if(msgBool)
			SetCursorFillMode(TOP_TO_BOTTOM)
			guiNPCShoutListNames = AddMenuOption("Added Shouts:", actorScript.getMyShoutNames()[0])
			SetCursorPosition(1)
			guiShoutList = AddMenuOption("Shouts", guiShoutListNames[0])
		else
			AddHeaderOption("Disabled")
		endIf
	
endFunction

function drawMainMenu()
	initNPCList()
	getPresetList()
	getNPCPresetList()
	SetCursorFillMode(TOP_TO_BOTTOM)
	guiNPCList = AddMenuOption("NPCs", NPCList[Nindex])
	guiNPCName = AddInputOption("NPC name",  getNPCName())
	if(BAF_CombatStyleEnabled)
		guiNPCCombatStyle = AddMenuOption("CombatStyle", combatStyleNames[getCSIndex()])
	else
		if skyTacticsInstalled || csDisabledBySkyTactics
			guiCSDisabledText = AddTextOption("CombatStyle", "SkyTactics (see Debug)")
		else
			guiCSDisabledText = AddTextOption("CombatStyle", "Off — enable in Debug")
		endIf
	endIf
	if(BAF_ClassEnabled)
		guiNPCClass = AddMenuOption("Class", classesNames[getClassIndex()])
	else
		guiClassDisabledText = AddTextOption("Class", "Off — enable in Debug")
	endIf
	guiPresetsList = AddMenuOption("Preset", PresetList[getPresetIndex()])
	if(NPCPresetsFound)
		guiNPCPresetList = AddMenuOption("NPC Preset", NPCpresetList[getNPCPresetIndex()])
	endIf
	; HeadNif: user-toggleable when a matching .nif exists next to the preset
	refreshHeadMeshState()
	guiPresetHeadMesh = AddToggleOption("HeadNif", hasHeadMesh)
	guiFVoicesList = AddMenuOption("Female Voices", FVoicesList[getFVoiceIndex()])
	guiMVoicesList = AddMenuOption("Male Voices", MVoicesList[getMVoiceIndex()])
	guiRacesList = AddMenuOption("Races", RacesList[getRaceIndex()])
	if(tarActor.Is3DLoaded())
		guiCopyKit = AddToggleOption("CopyKit", copyKitActive)
	endIf
	guiCopyKitAutoEquip = AddToggleOption("AutoEquip", copyKitAutoEquip)


	SetCursorPosition(1)	
	guiApplySettings = AddToggleOption("Apply settings", false)
	guiSummonToggle = AddToggleOption("Summon NPC", false)
	if(actorScript.getMyPreset() != "")
		guiTeleportToggle = AddToggleOption("Teleport to NPC", false)
		guiFixFace = AddToggleOption("Fix dark/grey face", false)
	endIf
	guiResetToggle = AddToggleOption("Reset/Dismiss",false)
	guiGlobalApply = AddToggleOption("Apply to all", false)
	guiSummonAll = AddToggleOption("Summon all", false)
	guiSaveMyFace = AddInputOption("Save my face for followers", "click me")
endFunction

function drawStatsMenu()
	SetTitleText("Stats - " + actorScript.getMyPresetName())
	SetCursorFillMode(TOP_TO_BOTTOM)	
	guiWeaponSpeedMulti = AddInputOption("WeaponSpeed", tarActor.GetAV("WeaponSpeedMult") as String)
	guiBowSpeedMulti = AddInputOption("BowSpeed", tarActor.GetAV("BowSpeedBonus") as String)
	guiAttackDamageMult = AddSliderOption("AttackDamageMult", tarActor.GetAV("AttackDamageMult"),"{2}")
	guiSpeedMulti = AddInputOption("MovementSpeed", tarActor.GetAV("SpeedMult") as String)
	guiDamageResist = AddInputOption("DamageResist", tarActor.GetAV("DamageResist") as String)
	guiMagicResist = AddInputOption("MagicResist", tarActor.GetAV("MagicResist") as String)
	guiHealth = AddInputOption("Health", tarActor.GetAV("Health") as String)
	guiStamina = AddInputOption("Stamina", tarActor.GetAV("Stamina") as String)
	guiMagicka = AddInputOption("Magicka", tarActor.GetAV("Magicka") as String)
	guiHealRate = AddInputOption("HealRate", tarActor.GetAV("HealRate") as String)
	guiStaminaRate = AddInputOption("StaminaRate", tarActor.GetAV("StaminaRate") as String)
	guiMagickaRate = AddInputOption("MagickaRate", tarActor.GetAV("MagickaRate") as String)
	SetCursorPosition(1)
	SKindex = 0
	guiSkillsList = AddMenuOption("Skills", skillNames[SKindex])
	guiSkillsInput = AddSliderOption("Value", tarActor.GetAv(skillNames[SKindex]))
endFunction

function drawCombatMenu()
	combatStyleSaveChanges = true
	SetCursorFillMode(TOP_TO_BOTTOM)
	tarStyle = BAF_CombatStyles.GetAt(CSindex)as CombatStyle

	guiCombatStyle = AddMenuOption("CombatStyle", combatStyleNames[CSIndex])
	guiCombatStyleName = AddInputOption("StyleName", combatStyleNames[CSIndex])
	AddEmptyOption()
	guiCsOffensive = AddSliderOption("OffensiveMult", tarStyle.GetOffensiveMult(),"{2}")
	guiCsDefensive = AddSliderOption("DefensiveMult", tarStyle.GetDefensiveMult(),"{2}")
	guiCsGroupOffensive = AddSliderOption("GroupOffensiveMult", tarStyle.GetGroupOffensiveMult(),"{2}")
	guiCsAvoidThreatChance = AddSliderOption("AvoidThreatChanceMult", tarStyle.GetAvoidThreatChance(),"{2}")
	guiCsMelee = AddSliderOption("MeleeMult", tarStyle.GetMeleeMult(),"{2}")
	guiCsRanged = AddSliderOption("RangedMult", tarStyle.GetRangedMult(),"{2}")
	guiCsMagic = AddSliderOption("MagicMult", tarStyle.GetMagicMult(),"{2}")
	guiCsShout = AddSliderOption("ShoutMult", tarStyle.GetShoutMult(),"{2}")
	guiCsStaff = AddSliderOption("StaffMult", tarStyle.GetStaffMult(),"{2}")
	guiCsUnarmed = AddSliderOption("UnarmedMult", tarStyle.GetUnarmedMult(),"{2}")

	SetCursorPosition(1)
	AddHeaderOption("Ranged")
	guiCloseRangeDuelingCircle = AddSliderOption("CloseRangeDuelingCircle", tarStyle.GetCloseRangeDuelingCircleMult(),"{2}")
	guiCloseRangeDuelingFallback = AddSliderOption("CloseRangeDuelingFallback", tarStyle.GetCloseRangeDuelingFallbackMult(),"{2}")
	guiCloseRangeFlankingFlankDistance = AddSliderOption("CloseRangeFlankingFlankDistance", tarStyle.GetCloseRangeFlankingFlankDistance(),"{2}")
	guiCloseRangeFlankingStalkTime = AddSliderOption("CloseRangeFlankingStalkTime", tarStyle.GetCloseRangeFlankingStalkTime(),"{2}")
	guiLongRangeStrafeMult = AddSliderOption("LongRangeStrafeMult", tarStyle.GetLongRangeStrafeMult(),"{2}")
	
	AddHeaderOption("Melee")
	guiMeleeAttackStaggered = AddSliderOption("MeleeAttackStaggered", tarStyle.getMeleeAttackStaggeredMult(),"{2}")
	guiMeleePowerAttackStaggered = AddSliderOption("MeleePowerAttackStaggered", tarStyle.getMeleePowerAttackStaggeredMult(),"{2}")
	guiMeleePowerAttackBlocking = AddSliderOption("MeleePowerAttackBlocking", tarStyle.GetMeleePowerAttackBlockingMult(),"{2}")
	guiMeleeBash = AddSliderOption("MeleeBash", tarStyle.GetMeleeBashMult(),"{2}")
	guiMeleeBashRecoiled = AddSliderOption("MeleeBashRecoiled", tarStyle.GetMeleeBashRecoiledMult(),"{2}")
	guiMeleeBashAttack = AddSliderOption("MeleeBashAttack", tarStyle.GetMeleeBashAttackMult(),"{2}")
	guiMeleeBashPowerAttack = AddSliderOption("MeleeBashPowerAttack", tarStyle.GetMeleeBashPowerAttackMult(),"{2}")
	guiMeleeSpecialAttack = AddSliderOption("MeleeSpecialAttack", tarStyle.GetMeleeSpecialAttackMult(),"{2}")
	guiAllowDualWielding = AddToggleOption("AllowDualWielding", tarStyle.GetAllowDualWielding())
endFunction

function drawSaveLoadMenu()
	SetCursorFillMode(TOP_TO_BOTTOM)
	AddHeaderOption("Config Data")
	if(cfgMan.configFileExists())
		guiLoadConfig = AddToggleOption("Load from file", loadingConfigFromDisk)
	endIf
	guiSaveConfig = AddToggleOption("Save to file", savingConfigToDisk)
	SetCursorPosition(1)
	AddHeaderOption("NPC Data")
	if(cfgMan.npcFileExists())
		guiLoadNPCs = AddToggleOption("Load from file", loadingNPCsFromDisk)
	endIf
	guiSaveNPCs = AddToggleOption("Save all NPCs to one file", savingNpcsToDisk)
	guiSaveSingleNPCs = AddToggleOption("Save each NPC separately", savingNpcsToDisk)
endFunction

function drawDebugMenu()
	SetCursorFillMode(TOP_TO_BOTTOM)
	AddHeaderOption("Debug settings")
	guiDebugRMDelay = AddSliderOption("Apply delay", BAF_RMDelay.GetValue(), "{0}")
	guiDebugRMFullMode = AddSliderOption("RM Full Mode", BAF_RMFullMode.GetValue(), "{0}")
	guiDebugRMLiteMode = AddSliderOption("RM Lite Mode", BAF_RMLiteMode.GetValue(), "{0}")
	guiDebugTraceMode = AddMenuOption("Logging Mode", guiDebugTraceModes[BAF_TraceMode.GetValueInt()])
	guiDebugSandboxEnable = AddToggleOption("Sandboxing", BAF_SandboxEnable.GetValueInt() as bool)
	guiDebugCSEnable = AddToggleOption("Custom combatstyles", BAF_CombatStyleEnabled)
	guiDebugClassEnable = AddToggleOption("Custom classes", BAF_ClassEnabled)
	if(po3ExtenderInstalled)
		guiDebugPO3Spells = AddToggleOption("Load spells", false)
	endIf
	SetCursorPosition(1)
	AddHeaderOption("RM Modes")
	AddTextOption("0", "Default(F)")
	AddTextOption("1", "Overrides")
	AddTextOption("2", "Body")
	AddTextOption("3", "Overrides + Body")
	AddTextOption("4", "Transforms")
	AddTextOption("5", "Overrides + Transforms")
	AddTextOption("6", "Body + Transforms")
	AddTextOption("7", "Overrides + Body + Transforms")
	AddTextOption("8", "Skin")
	AddTextOption("11", "Skin + Body + Overrides(L)")
	AddTextOption("13", "Overrides + Transforms + Skin")
	AddTextOption("15", "ALL")
	AddTextOption("F = Full default", "L = Lite default")
endFunction

; Scan disk for a matching external head .nif; updates headMeshAvailable / headMeshPath.
; Does NOT force the toggle on/off every redraw — user choice is headMeshUse.
function scanHeadMeshFile()
	headMeshAvailable = false
	headMeshPath = ""

	if Prindex < 0
		return
	endIf
	if !PresetList || Prindex >= PresetList.Length
		return
	endIf

	String presetFileName = PresetList[Prindex]
	if StringUtil.Find(presetFileName, ".jslot") < 0
		return
	endIf
	String headMeshFileName = StringUtil.SubString(presetFileName, 0, StringUtil.GetLength(presetFileName) - 6)

	; The NPC loader (LoadExternalCharacterEx) reads Meshes/CharGen/Exported +
	; Textures/CharGen/Exported. "Save my face for followers" writes there.
	; RaceMenu's sculpt-tab F5 export goes to SKSE/Plugins/CharGen - the WRONG
	; place for NPC use; flag it so the hover text can explain.
	String p1 = "Data/Meshes/CharGen/Exported/" + headMeshFileName + ".nif"

	legacyHeadExport = false
	if MiscUtil.FileExists(p1) && MiscUtil.FileExists("Data/Textures/CharGen/Exported/" + headMeshFileName + ".dds")
		headMeshPath = p1
		headMeshAvailable = true
	elseIf MiscUtil.FileExists("data/SKSE/Plugins/CharGen/" + headMeshFileName + ".nif") || MiscUtil.FileExists("data/SKSE/Plugins/CharGen/Exported/" + headMeshFileName + ".nif")
		legacyHeadExport = true
	endIf
endFunction

function refreshHeadMeshState()
	scanHeadMeshFile()

	String presetKey = ""
	if Prindex >= 0 && PresetList && Prindex < PresetList.Length
		presetKey = PresetList[Prindex]
	endIf

	; New preset selection → default ON if .nif exists, else OFF
	if presetKey != headMeshPresetKey
		headMeshPresetKey = presetKey
		headMeshUse = headMeshAvailable
		headMeshStateInit = true
		if headMeshAvailable
			dout("HeadNif available (default ON): " + headMeshPath)
		else
			dout("HeadNif not found for preset (toggle stays OFF until a matching .nif exists)")
		endIf
	elseIf !headMeshAvailable
		; File gone — force off
		headMeshUse = false
	endIf

	hasHeadMesh = headMeshUse && headMeshAvailable
endFunction

bool function getHasHeadMesh()
	refreshHeadMeshState()
	return hasHeadMesh
endFunction

int function getPresetIndex()
	Prindex = -1

	; Stored presets can originate from either ../Exported/ or ../Presets/.
	; Compare only the filename rather than assuming the Exported prefix length.
	String presetStr = actorScript.getMyPreset()
	int slash = StringUtil.Find(presetStr, "/")
	while slash > -1
		presetStr = StringUtil.SubString(presetStr, slash + 1)
		slash = StringUtil.Find(presetStr, "/")
	endWhile
	presetStr = presetStr + ".jslot"

	Prindex = PresetList.Find(presetStr)


	if(Prindex == -1)
		newPreset = presetFolderList[0] + PresetList[0]
		return 0
	endIf

	newPreset = presetFolderList[Prindex] + PresetList[Prindex]
	return Prindex
endFunction

int function getNPCPresetIndex()
	NPrindex = NPCPresetList.Find(actorScript.getMyPresetName() + ".json")


	if(NPrindex == -1)
		return 0
	endIf

	return NPrindex
endFunction

int function getNPCIndex()
	if(tarActor)
		Nindex = BAF_NPCs.Find(tarActor)
		CSindex = getCSIndex()
		return Nindex
	endIf

	CSIndex = 0
	return 0
endFunction

String function getNPCName()
	return actorScript.getmyPresetName()
endFunction

int function getFVoiceIndex()
	Fvindex =  BAF_FemaleVoices.Find(actorScript.getmyPresetVoiceType())

	if(Fvindex == -1)
		return 0
	endIf

	femVoice = true
	return Fvindex
endFunction

int function getMVoiceIndex()
	Mvindex =  BAF_MaleVoices.Find(actorScript.getmyPresetVoiceType())


	if(Mvindex == -1)
		return 0
	endIf

	femVoice = false
	return Mvindex
endFunction

int function getRaceIndex()
	Rindex =  BAF_Races.Find(actorScript.getMyPresetRace())

	if(Rindex == -1)
		return 0
	endIf

	return Rindex
endFunction

int function getCSIndex()
	int found = BAF_CombatStyles.Find(actorScript.getMyCombatStyle())
	if(found == -1)
		; Style not in our pool (another mod changed it). Never return -1;
		; a negative array index aborts the whole MCM page draw.
		return 0
	endIf
	return found
endFunction

int function getClassIndex()
	classIndex = BAF_Classes.Find(actorScript.getMyClass())

	if(classIndex == -1)
		return 0
	endIf

	return classIndex
endFunction

function dout(String inText)
	String outputText = "BuildAFollower: MCM "  + inText
	If(BAF_TraceMode.GetValueInt() == 0)
		MiscUtil.PrintConsole(outputText)
	elseif(BAF_TraceMode.GetValueInt() == 1)
		Debug.Trace(outputText)
	endIf
endFunction

function applySettings()
	if noMatchingSexSlot
		ShowMessage("No free template of the required sex. Dismiss a matching follower, or manually select a matching template before applying.", false, "OK")
		return
	endIf

	; RaceMenu slots keep their base actor sex. Applying a detectable male preset
	; to a female slot (or vice versa) causes the head/body mismatch this mod must avoid.
	int presetSex = getPresetSex(newPreset)
	if presetSex > -1 && tarActor.GetActorBase().GetSex() != presetSex
		ShowMessage("Preset gender does not match the selected template. Select a matching Male/Female template before applying.", false, "OK")
		return
	endIf

	actorScript.setMyPresetName(newName)
	; Do not trust the last voice menu clicked: its list can be opposite to the
	; selected template. Use the template's actual sex as the authoritative choice.
	if(tarActor.GetActorBase().GetSex() == 1)
		actorScript.SetMyPresetVoice(BAF_FemaleVoices.GetAt(Fvindex) as VoiceType)
	else
		actorScript.SetMyPresetVoice(BAF_MaleVoices.GetAt(Mvindex) as VoiceType)
	endIf

	actorScript.setMyPresetRace(BAF_Races.GetAt(Rindex) as Race)
	actorScript.setMyPreset(parsePreset(newPreset))

	; Respect HeadNif toggle: only pass path when user left it ON and file exists
	scanHeadMeshFile()
	hasHeadMesh = headMeshUse && headMeshAvailable
	if(hasHeadMesh)
		actorScript.setMyHeadMesh(headMeshPath)
	else
		actorScript.setMyHeadMesh("")
	endIf

	actorScript.refreshAppearance(true)

	if(!actorScript.presetHasTintMask())
		ShowMessage("Note: this preset has no exported face tint, so skin color stays at the template default (that is what prevents the blue face). For exact colors: wear the face in RaceMenu, then click 'Save my face for followers'.", false, "OK")
	endIf

	if(!tarActor.Is3DLoaded() || tarActor.IsDisabled())
		ShowMessage("Settings saved. The preset will be applied automatically when this NPC is summoned.", false, "OK")
	endIf

	initNPCList()

endFunction

; Returns 1 for a detectable female preset, 0 for a detectable male preset, or
; -1 when the JSON uses custom paths that cannot safely be classified.
int function getPresetSex(String presetPath)
	if presetPath == ""
		return -1
	endIf

	String relativePath = presetPath
	if StringUtil.Find(relativePath, "../") == 0
		relativePath = StringUtil.SubString(relativePath, 3)
	endIf
	if StringUtil.Find(relativePath, ".jslot") == -1
		relativePath = relativePath + ".jslot"
	endIf

	String presetFile = "data/SKSE/Plugins/CharGen/" + relativePath
	if !MiscUtil.FileExists(presetFile)
		dout("Preset sex check unavailable: " + presetFile)
		return -1
	endIf

	int presetData = JValue.readFromFile(presetFile)
	if presetData == 0
		dout("Preset sex check could not parse: " + presetFile)
		return -1
	endIf

	String headTexture = JValue.solveStr(presetData, ".faceTextures.0.texture")
	presetData = JValue.release(presetData)
	if StringUtil.Find(headTexture, "Female") > -1
		return 1
	elseIf StringUtil.Find(headTexture, "Male") > -1
		return 0
	endIf

	return -1
endFunction

String function parsePreset(String inString)
	String pruned

	int indexer = StringUtil.Find(inString, ".jslot", 0)
	if(indexer > -1)
		pruned = StringUtil.SubString(inString, 0, indexer)
	endIf

	return pruned
endFunction

function getInstalledMods()
	if(MiscUtil.FileExists("data/SKSE/plugins/po3_PapyrusExtender.dll"))
		po3ExtenderInstalled = true
		getCustomRacesPO3()
		dout("po3_PapyrusExtender detected — scanning playable races")
	else
		po3ExtenderInstalled = false
		dout("po3_PapyrusExtender NOT detected — custom races are only added when you play as one or look at an NPC of that race (then remembered via BuildAFollowerRaces.json)")
	endIf

	; Known race packs are seeded by exact FormID and do not depend on po3.
	seedKnownCustomRaces()

	skyTacticsInstalled = Game.IsPluginInstalled("SkyTactics.esp") || MiscUtil.FileExists("data/SKSE/Plugins/SkyTactics.dll")

	; SkyTactics owns dynamic combat styles — do not fight it every load.
	; Only auto-disable once (version migrate); user may re-enable in Debug.
	if version < 3
		if skyTacticsInstalled
			BAF_CombatStyleEnabled = false
			csDisabledBySkyTactics = true
			dout("SkyTactics detected — Build a Follower combat-style override OFF (Debug can re-enable)")
		endIf
		version = 3
	elseIf skyTacticsInstalled && !BAF_CombatStyleEnabled
		; Keep flag for clearer MCM labels without re-stomping user re-enable
		csDisabledBySkyTactics = true
	endIf
endFunction

function saveMyFace(String inName)
	if(inName == "" || inName == "click me")
		return
	endIf
	msgBool = ShowMessage("Export YOUR current face as '" + inName + "'? It saves the preset, head mesh and face tint together (no blue face, best quality).", true)
	if(msgBool)
		CharGen.SaveExternalCharacter(inName)
		Utility.Wait(2.0) ; head + tint export runs as a background task
		getPresetList()
		ShowMessage("Saved. Pick '" + inName + ".jslot' in the Preset list, set the matching Race, then Apply.", false, "OK")
		ForcePageReset()
	endIf
endFunction

function copyKit()
	Actor inSource = PlayerRef
	Actor inTarget = tarActor
	 
	int n = 0x01
	int n2 = 0

	tarActor.UnequipAll()

	while (n < 0x80000000)
		if (Math.LogicalAnd(n2, n) != n) ;only check slots we haven't found anything equipped on already
			Armor thisForm = inSource.GetWornForm(n) as Armor
				if thisForm != none && validItem(thisForm, inTarget)
					transferItem(thisForm, inTarget)
				endif
		else ;no armor was found on this slot
			n2 += n
		endif

		n *= 2 ;double the number to move on to the next slot
	endWhile
	
	if(inSource.GetEquippedWeapon(true) as Weapon) ;Left Weapon
		Weapon lWeapon = inSource.GetEquippedWeapon(true)
		if(validItem(lWeapon, inTarget))
			transferItem(lWeapon, inTarget, true)
		endIf
	endIf
	
	if(inSource.GetEquippedWeapon() as Weapon) ;Right Weapon
		Weapon rWeapon = inSource.GetEquippedWeapon()
		if(validItem(rWeapon, inTarget))
			transferItem(rWeapon, inTarget)
		endIf
	endIf
	
	if(inSource.GetEquippedShield() as Armor) ;Shield
		Armor shield = inSource.GetEquippedShield() as Armor
		if(validItem(shield, inTarget))
			transferItem(shield, inTarget, true)
		endIf
	endIf

endFunction

function transferItem(Form inform, Actor inTarget, bool leftHand = false)
	inTarget.AddItem(inForm, 1, true)
	if(copyKitAutoEquip)
		if(leftHand == true)			
			inTarget.EquipItemEx(inform, 2, false, true)
		else
			inTarget.EquipItem(inform)
		endIf
	endIf	
endFunction

bool function validItem(Form inForm, Actor inTarget)
	If(!inForm.IsPlayable())
		dOut("CopyKit: Item flagged as non playable" + inForm + ", skipped")
		return false
	elseIf(inTarget.GetItemCount(inForm) > 0)
		dOut("CopyKit: Item  " + inForm.GetName() + " already found in target inventory item, skipped")
		return false
	elseIf(inForm.GetName()	== "")
		dOut("CopyKit: Item  " + inForm + " is missing a name, skipped")
		return false
	endIf
	
	return true
endFunction

function getCustomRace(Actor inActor)
	Race actRace = inActor.GetRace()
	addCustomRace(actRace)
endFunction

function addCustomRace(Race inRace)
	if(BAF_Races.Find(inRace) == -1)
		BAF_Races.AddForm(inRace)
		RacesList = Utility.ResizeStringArray(RacesList, RacesList.Length + 1, inRace.GetName())

		dOut("Added custom race " + RacesList[RacesList.Length - 1])
		if !suppressRaceAutosave
			saveCustomRaces()
		endIf
	endIf
endFunction

; Persists the full race list (vanilla pool + every detected custom race) to a
; small JSON, so custom races survive new games, character swaps and po3-less
; installs. Loaded on every game load from updater(); entries dedupe through
; addCustomRace, and races from uninstalled mods are skipped on load.
function saveCustomRaces()
	int jr = JArray.object()
	int n = BAF_Races.GetSize()
	int i = 0
	while i < n
		JArray.addForm(jr, BAF_Races.GetAt(i))
		i += 1
	endWhile
	JValue.writeToFile(jr, "Data/SKSE/Plugins/BuildAFollower/BuildAFollowerRaces.json")
	JValue.release(jr)
endFunction

function loadCustomRaces()
	String path = "Data/SKSE/Plugins/BuildAFollower/BuildAFollowerRaces.json"
	if !MiscUtil.FileExists(path)
		return
	endIf
	int jr = JValue.readFromFile(path)
	if jr == 0
		return
	endIf
	suppressRaceAutosave = true
	int n = JArray.count(jr)
	int i = 0
	while i < n
		Race r = JArray.getForm(jr, i) as Race
		if r
			addCustomRace(r)
		endIf
		i += 1
	endWhile
	suppressRaceAutosave = false
	JValue.release(jr)
endFunction

; --- Known custom-race packs (CotR / UBE) ------------------------------------
; Both ship their playable races as RaceCompatibility-derived RACE records and
; register them at runtime through their own Papyrus race controllers
; (DZ_*RaceController / UBE_*RaceController + RegisterCustomRaceScript).
; po3's GetAllRaces has proven unreliable on some builds, which is why these
; races never showed up in the MCM and users had to crosshair an NPC of that
; race first. Seeding them here by exact FormID + plugin makes them appear with
; or without po3, on any save, with no NPC required.
;
; FormIDs were verified by parsing the shipped plugins directly.
; Vampire variants are deliberately excluded: their records are flagged
; non-playable and the game's vampirism system assigns them, not the user.
; NOTE: CotR and UBE reuse the SAME RaceCompatibility FormIDs for the same
; vanilla-race slot, so every lookup must be scoped to its own plugin.
function seedKnownCustomRaces()
	seedRacePack("COR_AllRace.esp")
	seedRacePack("UBE_AllRace.esp")
endFunction

function seedRacePack(String pluginName)
	if !Game.IsPluginInstalled(pluginName)
		return
	endIf

	int[] ids = new int[10]
	ids[0] = 0x005734   ; Breton
	ids[1] = 0x05A179   ; Imperial
	ids[2] = 0x05A184   ; Nord
	ids[3] = 0x05A18E   ; Redguard
	ids[4] = 0x05A198   ; Dark Elf
	ids[5] = 0x05A1A2   ; High Elf
	ids[6] = 0x05A1AC   ; Wood Elf
	ids[7] = 0x05A1B0   ; Orc
	ids[8] = 0x07A4D5   ; UBE CustomRace01 (not present in CotR -> skipped)
	ids[9] = 0x07A4D6   ; UBE CustomRace02 (not present in CotR -> skipped)

	int before = BAF_Races.GetSize()
	suppressRaceAutosave = true
	int i = 0
	while i < ids.Length
		Race r = Game.GetFormFromFile(ids[i], pluginName) as Race
		if r
			addCustomRace(r)
		endIf
		i += 1
	endWhile
	suppressRaceAutosave = false

	int added = BAF_Races.GetSize() - before
	if added > 0
		saveCustomRaces()
	endIf
	dout("Race pack " + pluginName + " detected - added " + added + " new races")
endFunction

function getCustomRacesPO3()
	Race[] foundRaces = PO3_SKSEFunctions.GetAllRaces()
	if !foundRaces || foundRaces.Length == 0
		; Old/incompatible po3 build: GetAllRaces fails silently from the user's
		; view and customs never appear. Say how to recover.
		dout("po3 GetAllRaces returned nothing — update po3 Papyrus Extender. Without it, open the MCM while playing (or looking at an NPC of) the custom race to add it manually; it is remembered afterwards.")
		return
	endIf
	int rIndexer = foundRaces.Length

	while(rIndexer > 0)
		rIndexer -= 1
		if((foundRaces[rIndexer] as Race).IsPlayable())
			addCustomRace(foundRaces[rIndexer])
		endIf
	endWhile
endFunction

function getCustomSpellsPO3()
	Spell[] foundSpells = PO3_SKSEFunctions.GetAllSpells(abIsPlayable = true)
	int sIndexer = foundSpells.Length

	while(sIndexer > 0)
		sIndexer -= 1
		Spell toAdd = foundSpells[sIndexer]
		if(BAF_Spells.Find(toAdd) == -1)		
			dOut("Added spell " + toAdd.GetName())
			BAF_Spells.AddForm(toAdd)
		endIf
	endWhile

	initSpellLists()
endFunction

function getCustomVoiceParser(Actor inActor)
	if(inActor.GetActorBase().GetSex() == 0)
		getCustomVoiceMale(inActor)
	else
		getCustomVoiceFemale(inActor)
	endIf
endFunction

function getCustomVoiceFemale(Actor inActor)
	VoiceType actVoice = inActor.GetVoiceType()
	if(BAF_FemaleVoices.Find(actVoice) == -1)
		BAF_FemaleVoices.AddForm(actVoice)
		FVoicesList = Utility.ResizeStringArray(FVoicesList, FVoicesList.Length + 1, actVoice)

		dOut("Added custom voice " + FVoicesList[FVoicesList.Length - 1] + " from " + inActor.GetDisplayName())
	endIf
endFunction

function getCustomVoiceMale(Actor inActor)
	VoiceType actVoice = inActor.GetVoiceType()
	if(BAF_MaleVoices.Find(actVoice) == -1)
		BAF_MaleVoices.AddForm(actVoice)
		MVoicesList = Utility.ResizeStringArray(MVoicesList, MVoicesList.Length + 1, actVoice)

		dOut("Added custom voice " + MVoicesList[MVoicesList.Length - 1] + " from " + inActor.GetDisplayName())
	endIf
endFunction

function summonAll()
	int ndx = BAF_NPCs.GetSize()

	while(ndx > 0)
		ndx -= 1
		tarActor = BAF_NPCs.GetAt(ndx) as Actor
		actorScript = tarActor as BAF_ActorScript

		if(actorScript.getMyPreset() != "" && tarActor.GetFactionRank(CurrentFollowerFaction) < 1)
			actorScript.checkmyPresetName()
			dout("Summoning " + actorScript.getMyPresetName())
			actorScript.summonMe(playerRef)		
		endIf
	endWhile
endFunction

function loadSingleNPC(BAF_ActorScript inScript, String inPreset)
	msgBool = ShowMessage("Apply preset " + Inpreset + " to currently selected NPC?", true)

		if(msgBool)
			if(cfgMan.loadSingleNPCData(inScript, inPreset))
				inScript.summonMe(playerRef)
				ForcePageReset()
			else
				ShowMessage("Error - Template/Preset gender mismatch?", false, "OK")
			endIf
		endIf

		
endFunction

event OnOptionHighlight(int a_option)
	if (a_option == guiFVoicesList || a_option == guiMVoicesList)
		SetInfoText("The selected template's sex determines which voice list is applied. Starred are vanilla followerfriendly")
	elseIf(a_option == guiRacesList)
		SetInfoText("This follower's race. Custom races: po3 Papyrus Extender auto-scans them, or open the MCM while playing as / looking at an NPC of that race. Every detected race is remembered in BuildAFollowerRaces.json from then on.")
	elseIf(a_option == guiSummonToggle)
		SetInfoText("Teleports selected NPC to your location")
	elseIf(a_option == guiTeleportToggle)
		SetInfoText("Teleports player to NPC location")
	elseIf(a_option == guiFixFace)
		SetInfoText("Dark or grey face? Rebuilds this NPC's head so the tint re-bakes. No external Dark Face Fix mod needed. NPC briefly blinks out and back.")
	elseIf(a_option == guiSaveMyFace)
		SetInfoText("Wear the follower's face on YOUR character (RaceMenu), then use this. Exports preset + head mesh + face tint together to the folders the NPC loader needs - the no-blue-face way.")
	elseIf(a_option == guiResetToggle)
		SetInfoText("Resets this NPC and parks THEM in the storage cell (not you). Use Summon to bring them back. Teleport-to-NPC is blocked while parked.")
	elseIf(a_option == guiApplySettings)
		SetInfoText("Applies changes to NPC as displayed")
	elseIf(a_option == guiGlobalApply)
		SetInfoText("Does a *FULL* preset reload on ALL npcs")
	elseIf(a_option == guiCopyKit)
		SetInfoText("Copies player equipment to target NPC.")
	elseIf(a_option == guiCopyKitAutoEquip)
		SetInfoText("Automatically equips copied items. WARNING - CAN CRASH THE GAME.")
	elseIf(a_option == guiSpellList)
		SetInfoText("Dropdown list of spells. (L) and (R) denotes assigned hand. (-) is either")
	elseIf(a_option == guiDebugRMDelay)
		SetInfoText("Seconds to wait after NPC loading before applying appearance")
	elseIf(a_option == guiDebugRMFullMode)
		SetInfoText("Mode to apply the FULL RaceMenu Preset with. Default 15. Only done by MCM menu")
	elseIf(a_option == guiDebugRMLiteMode)
		SetInfoText("Mode to apply the LITE RaceMenu Preset with. Default 5. Used whenever the NPC is loaded")
	elseIf(a_option == guiDebugTraceMode)
		SetInfoText("Log to console, papyrus log (if enabled in Skyrim INI-file) or silent(nowhere)")
	elseIf(a_option == guiDebugSandboxEnable)
		SetInfoText("Can disable if you have other mods handling behaviour for NPCs not currently following the player")
	elseIf(a_option == guiDebugPO3Spells)
		SetInfoText("Loads all spells from load order. WARNING - Can result in a long list to scroll and not all spells are guaranteed to work on NPCs")
	elseIf(a_option == guiSummonAll)
		SetInfoText("Summon all NPCs not currently following you")
	elseIf(a_option == guiPresetHeadMesh)
		if headMeshAvailable
			if hasHeadMesh
				SetInfoText("ON — external head: " + headMeshPath + ". Neck seam? Try OFF (jslot-only), or match Race to the preset race. Click to turn OFF.")
			else
				SetInfoText("OFF — .nif found but unused: " + headMeshPath + "  (click ON). Wrong-race head nifs often cause neck seams.")
			endIf
		elseIf legacyHeadExport
			SetInfoText("Head export found in RaceMenu's old F5 location (SKSE/Plugins/CharGen) which the NPC loader cannot read. Wear the face, then click 'Save my face for followers' to export it to the right place.")
		else
			SetInfoText("No exported head for this preset. Wear the face in RaceMenu, then click 'Save my face for followers' (best quality, prevents the blue face).")
		endIf
	elseIf(a_option == guiNPCCombatStyle)
		SetInfoText("Assign a BAF combat style to this NPC. Names describe intended role. Edit mults on the Combat page; rename there via StyleName. SkyTactics users: leave Custom combatstyles OFF in Debug unless you want BAF to override.")
	elseIf(a_option == guiNPCPresetList)
		SetInfoText("Saved NPC files from -> data/SKSE/Plugins/BuildAFollower/BuildAFollowerNPCs/")
	elseIf(a_option == guiCSDisabledText)
		if(skyTacticsInstalled || csDisabledBySkyTactics)
			SetInfoText("Combat styles are OFF so SkyTactics can drive AI dynamically. This is intentional. To force Build a Follower styles instead: Debug -> Custom combatstyles ON. You cannot pick SkyTactics styles from this list — those are runtime/dynamic.")
		else
			SetInfoText("Custom combat styles are turned off. Enable under Debug -> Custom combatstyles.")
		endIf
	elseIf(a_option == guiClassDisabledText)
		SetInfoText("Custom classes are turned off. Enable under Debug -> Custom classes.")
	elseIf(a_option == guiSaveConfig)
		SetInfoText("File -> data/SKSE/Plugins/BuildAFollower/BuildAFollowerConfig.json")
	elseIf(a_option == guiSaveNPCs)
		SetInfoText("File -> data/SKSE/Plugins/BuildAFollower/BuildAFollowerNPC.json")
	elseIf(a_option == guiSaveSingleNPCs)
		SetInfoText("Stored in -> data/SKSE/Plugins/BuildAFollower/BuildAFollowerNPCs/")
	endIf
endEvent


event OnOptionSelect(int a_option)
	if(a_option == guiPresetHeadMesh)
		scanHeadMeshFile()
		if !headMeshAvailable
			ShowMessage("No external head .nif for this preset.\n\nExport a head with the same name as the .jslot into:\nSKSE/Plugins/CharGen/Exported/\n(or CharGen/ or Presets/)", false, "OK")
			hasHeadMesh = false
			headMeshUse = false
			SetToggleOptionValue(guiPresetHeadMesh, false)
		else
			headMeshUse = !headMeshUse
			hasHeadMesh = headMeshUse
			SetToggleOptionValue(guiPresetHeadMesh, hasHeadMesh)
			if hasHeadMesh
				dout("HeadNif ON: " + headMeshPath)
			else
				dout("HeadNif OFF (jslot-only)")
			endIf
		endIf

	elseIf(a_option == guiSummonToggle)
		msgBool = ShowMessage("Summon " + actorScript.getMyPresetName() + "?",  true)

		if(msgBool)
			actorScript.summonMe(PlayerRef)
		endIf

	elseIf(a_option == guiTeleportToggle)
		if(actorScript.isInStorage())
			ShowMessage("This NPC is parked in the storage cell. Use Summon NPC instead - teleporting there would strand you.", false, "OK")
		else
			msgBool = ShowMessage("Teleport to " + actorScript.getMyPresetName() + "?",  true)

			if(msgBool)
				playerRef.MoveTo(tarActor)
			endIf
		endIf

	elseIf(a_option == guiFixFace)
		msgBool = ShowMessage("Fix dark/grey face on " + actorScript.getMyPresetName() + "? They will briefly blink out and back while the head is rebuilt.",  true)

		if(msgBool)
			actorScript.forceFaceRefresh()
			ShowMessage("Face rebuilt. If it is still dark, re-check the Race matches the preset, then try again.", false, "OK")
		endIf

	elseIf(a_option == guiResetToggle)
		msgBool = ShowMessage("Reset + dismiss " + actorScript.getMyPresetName() + "?",  true)

		if(msgBool)
			actorScript.dismissMe()
			ForcePageReset()
		endIf
	
	elseIf(a_option == guiApplySettings)
		msgBool = ShowMessage("Apply settings to " + actorScript.getMyPresetName() + "?",  true)

		if(msgBool)
			applySettings()
		endIf

	elseIf(a_option == guiGlobalApply)
		msgBool = ShowMessage("Force full update of all NPCs? Warning - will reapply/override all tints, overlays etc from preset",  true)

		if(msgBool)
			sendGlobalUpdateRequest()
		endIf
	elseIf(a_option == guiAllowDualWielding)
		tarStyle.SetAllowDualWielding(!tarStyle.GetAllowDualWielding())
		SetToggleOptionValue(guiAllowDualWielding, tarStyle.GetAllowDualWielding())

	elseIf(a_option == guiCopyKit && !copyKitActive)
		copyKitActive = true
		copyKit()
		ShowMessage("Equipment copied to " + actorScript.getMyPresetName())
		copyKitActive = false

	elseIf(a_option == guiCopyKitAutoEquip)
		copyKitAutoEquip = !copyKitAutoEquip
		SetToggleOptionValue(guiCopyKitAutoEquip, copyKitAutoEquip)

	elseIf(a_option == guiSaveConfig && !savingConfigToDisk)

		msgBool = ShowMessage("SAVE config to file? Existing config data will be OVERWRITTEN",  true)

		if(msgBool)
			savingConfigToDisk = true
			ShowMessage("Please wait for confirmation popup")
			cfgMan.saveConfig()
			ShowMessage("Config saved")
			savingConfigToDisk = false
		endIf
		
	elseIf(a_option == guiLoadConfig && !loadingConfigFromDisk)

		msgBool = ShowMessage("LOAD config to file? Existing savegame config data will be OVERWRITTEN",  true)

		if(msgBool)
			loadingConfigFromDisk = true
			ShowMessage("Please wait for confirmation popup")
			cfgMan.loadConfig()
			ShowMessage("Config loaded")
			loadingConfigFromDisk = false
		endIf

	elseIf(a_option == guiSaveNPCs && !savingNPCsToDisk)

		msgBool = ShowMessage("SAVE NPCs to file? ALL existing NPC data will be OVERWRITTEN",  true)

		if(msgBool)
			savingNPCsToDisk = true
			ShowMessage("Please wait for confirmation popup")
			cfgMan.saveNPCs()
			ShowMessage("NPCs saved")
			savingNPCsToDisk = false
		endIf

	elseIf(a_option == guiSaveSingleNPCs && !savingNPCsToDisk)

		msgBool = ShowMessage("Save each follower to their own file? Naming convention - followerName.json",  true)

		if(msgBool)
			savingNPCsToDisk = true
			ShowMessage("Please wait for confirmation popup")
			cfgMan.saveNPCDataMultiFile()
			ShowMessage("NPCs saved")
			savingNPCsToDisk = false
		endIf

	elseIf(a_option == guiLoadNPCs && !loadingNPCsFromDisk)
		msgBool = ShowMessage("LOAD NPCs from file? All current NPCs will be reset and sent back to storage first.",  true)

		if(msgBool)
			loadingNPCsFromDisk = true
			ShowMessage("Please wait for confirmation popup")
			cfgMan.loadNPCs()
			ShowMessage("NPCs loaded")
			loadingNPCsFromDisk = false
		endIf

	elseIf(a_option == guiDebugSandboxEnable)
		if(BAF_SandboxEnable.GetValueInt() == 0)
			BAF_SandboxEnable.SetValueInt(1)
			dout("NPC will use default sandbox package when idle")
		else
			BAF_SandboxEnable.SetValueInt(0)
			dout("NPC will NOT use default sandbox package when idle")
		endIf

		SetToggleOptionValue(guiDebugSandboxEnable, BAF_SandboxEnable.GetValueInt() as bool)

	elseIf(a_option == guiDebugCSEnable)
		if(BAF_CombatStyleEnabled)
			BAF_CombatStyleEnabled = false
			dout("Custom combat styles DISABLED")
			if skyTacticsInstalled
				csDisabledBySkyTactics = true
			endIf
		else
			BAF_CombatStyleEnabled = true
			csDisabledBySkyTactics = false
			dout("Custom combat styles ENABLED (overrides SkyTactics for BAF NPCs if both run)")
		endIf

		SetToggleOptionValue(guiDebugCSEnable, BAF_CombatStyleEnabled)

	elseIf(a_option == guiDebugClassEnable)
		if(BAF_ClassEnabled)
			BAF_ClassEnabled = false
			dout("Custom classes DISABLED")
		else
			BAF_ClassEnabled = true
			dout("Custom classes ENABLED")
		endIf

		SetToggleOptionValue(guiDebugClassEnable, BAF_ClassEnabled)
	elseIf(a_option == guiDebugPO3Spells)
		msgBool = ShowMessage("Scan load order and add all playable spells?",  true, "Yes", "No")

		int numSpells = BAF_Spells.GetSize()
		if(msgBool)
			getCustomSpellsPO3()
		endIf

		ShowMessage("Added " + (BAF_Spells.GetSize() - numspells) + " spells", false, "OK")
	elseIf(a_option == guiSummonAll)
		msgBool = ShowMessage("Summon all unassigned followers?",  true, "Yes", "No")

		if(msgBool)
			ShowMessage("Exit menu to start process")
			summonAll()
		endIf

	endIf

endEvent

; @implements SKI_ConfigBase
event OnOptionDefault(int a_option)
	{Called when resetting an option to its default value}

	; ...
endEvent

Event OnOptionSliderOpen(int a_option)
	if(a_option == guiCsOffensive)
		setSliderOpenSmall(tarStyle.GetOffensiveMult())
	elseIf(a_option == guiCsDefensive)
		setSliderOpenSmall(tarStyle.GetDefensiveMult())
	elseIf(a_option == guiCsGroupOffensive)
		setSliderOpenSmall(tarStyle.GetGroupOffensiveMult())
	elseIf(a_option == guiCsAvoidThreatChance)
		setSliderOpenSmall(tarStyle.GetAvoidThreatChance())
	elseIf(a_option == guiCsMelee)
		setSliderOpenLarge(tarStyle.GetMeleeMult())		
	elseIf(a_option == guiCsRanged)
		setSliderOpenLarge(tarStyle.GetRangedMult())		
	elseIf(a_option == guiCsMagic)
		setSliderOpenLarge(tarStyle.GetMagicMult())		
	elseIf(a_option == guiCsShout)
		setSliderOpenLarge(tarStyle.GetShoutMult())		
	elseIf(a_option == guiCsStaff)
		setSliderOpenLarge(tarStyle.GetStaffMult())		
	elseIf(a_option == guiCsUnarmed)
		setSliderOpenLarge(tarStyle.GetUnarmedMult())		

	elseIf(a_option == guiCloseRangeDuelingCircle)
		setSliderOpenSmall(tarStyle.GetCloseRangeDuelingCircleMult())		
	elseIf(a_option == guiCloseRangeDuelingFallback)
		setSliderOpenSmall(tarStyle.GetCloseRangeDuelingFallbackMult())		
	elseIf(a_option == guiCloseRangeFlankingFlankDistance)
		setSliderOpenSmall(tarStyle.GetCloseRangeFlankingFlankDistance())		
	elseIf(a_option == guiCloseRangeFlankingStalkTime)
		setSliderOpenSmall(tarStyle.GetCloseRangeFlankingStalkTime())		
	elseIf(a_option == guiLongRangeStrafeMult)
		setSliderOpenSmall(tarStyle.GetLongRangeStrafeMult())		

	elseIf(a_option == guiMeleeAttackStaggered)
		setSliderOpenLarge(tarStyle.getMeleeAttackStaggeredMult())
	elseIf(a_option == guiMeleePowerAttackStaggered)
		setSliderOpenLarge(tarStyle.getMeleePowerAttackStaggeredMult())
	elseIf(a_option == guiMeleePowerAttackBlocking)
		setSliderOpenLarge(tarStyle.GetMeleePowerAttackBlockingMult())
	elseIf(a_option == guiMeleeBash)
		setSliderOpenLarge(tarStyle.GetMeleeBashMult())
	elseIf(a_option == guiMeleeBashRecoiled)
		setSliderOpenLarge(tarStyle.GetMeleeBashRecoiledMult())
	elseIf(a_option == guiMeleeBashAttack)
		setSliderOpenLarge(tarStyle.GetMeleeBashAttackMult())
	elseIf(a_option == guiMeleeBashPowerAttack)
		setSliderOpenLarge(tarStyle.GetMeleeBashPowerAttackMult())
	elseIf(a_option == guiMeleeSpecialAttack)
		setSliderOpenSmall(tarStyle.GetMeleeSpecialAttackMult())

	elseIf(a_option == guiAttackDamageMult)
		SetSliderDialogStartValue(tarActor.GetAv("AttackDamageMult") as float)
		SetSliderDialogDefaultValue(tarActor.GetAv("AttackDamageMult") as float)
		SetSliderDialogRange(0, 2)
		SetSliderDialogInterVal(0.05)

	elseIf(a_option == guiSkillsInput)
		setSliderOpenXLarge(tarActor.GetAV(skillNames[SKindex]))

	elseIf(a_option == guiDebugRMDelay)
		SetSliderDialogStartValue(BAF_RMDelay.GetValue())
		SetSliderDialogDefaultValue(1)
		SetSliderDialogRange(0, 10)
		SetSliderDialogInterVal(1)
	elseIf(a_option == guiDebugRMFullMode)
		setSlideRaceMenuFlag(BAF_RMFullMode.GetValueInt(), 15)
	elseIf(a_option == guiDebugRMLiteMode)
		setSlideRaceMenuFlag(BAF_RMLiteMode.GetValueInt(), 4)
	endIf
endEvent

function setSliderOpenSmall(float inValue)
	SetSliderDialogStartValue(inValue)
	SetSliderDialogDefaultValue(inValue)
	SetSliderDialogRange(0, 1)
	SetSliderDialogInterVal(0.05)
endFunction

function setSliderOpenLarge(float inValue)
	SetSliderDialogStartValue(inValue)
	SetSliderDialogDefaultValue(inValue)
	SetSliderDialogRange(0, 10)
	SetSliderDialogInterVal(0.5)
endFunction

function setSliderOpenXLarge(float inValue)
	SetSliderDialogStartValue(inValue)
	SetSliderDialogDefaultValue(inValue)
	SetSliderDialogRange(0, 100)
	SetSliderDialogInterVal(5)
endFunction

function setSlideRaceMenuFlag(int inValue, int defaultValue)
	SetSliderDialogStartValue(inValue)
	SetSliderDialogDefaultValue(defaultValue)
	SetSliderDialogRange(0, 15)
	SetSliderDialogInterVal(1)
EndFunction


; @implements SKI_ConfigBase
event OnOptionMenuOpen(int a_option)
	{Called when the user selects a menu option}
	If(a_option == guiNPCList)
		SetMenuDialogOptions(NPCList)
		SetMenuDialogStartIndex(Nindex)
		SetMenuDialogDefaultIndex(0)
	elseIf(a_option == guiFVoicesList)
		SetMenuDialogOptions(FVoicesList)
		SetMenuDialogStartIndex(FVindex)
		SetMenuDialogDefaultIndex(0)
	elseIf(a_option == guiMVoicesList)
		SetMenuDialogOptions(MVoicesList)
		SetMenuDialogStartIndex(MVIndex)
		SetMenuDialogDefaultIndex(0)
	elseIf(a_option == guiRacesList)
		SetMenuDialogOptions(RacesList)
		SetMenuDialogStartIndex(Rindex)
		SetMenuDialogDefaultIndex(0)
	elseIf(a_option == guiPresetsList)
		SetMenuDialogOptions(PresetList)
		SetMenuDialogStartIndex(Prindex)
		SetMenuDialogDefaultIndex(0)
	elseIf(a_option == guiNPCPresetList)
		SetMenuDialogOptions(NPCpresetList)
		SetMenuDialogStartIndex(NPrindex)
		SetMenuDialogDefaultIndex(0)
	elseIf(a_option == guiSkillsList)
		SetMenuDialogOptions(skillNames)
		SetMenuDialogStartIndex(SKindex)
		SetMenuDialogDefaultIndex(SKindex)
	elseIf(a_option == guiSpellList)
		SetMenuDialogOptions(guiSpellListNames)
		SetMenuDialogStartIndex(0)
		SetMenuDialogDefaultIndex(0)

	elseIf(a_option == guiShoutList)
		SetMenuDialogOptions(guiShoutListNames)
		SetMenuDialogStartIndex(0)
		SetMenuDialogDefaultIndex(0)

	elseIf(a_option == guiNPCSpellListNames)
		SetMenuDialogOptions(actorScript.getMySpellNames())
		SetMenuDialogStartIndex(0)
		SetMenuDialogDefaultIndex(0)

	elseIf(a_option == guiNPCShoutListNames)
		SetMenuDialogOptions(actorScript.getMyShoutNames())
		SetMenuDialogStartIndex(0)
		SetMenuDialogDefaultIndex(0)

	elseIf(a_option == guiNPCClass)
		SetMenuDialogOptions(classesNames)
		SetMenuDialogStartIndex(0)
		SetMenuDialogDefaultIndex(0)

	elseIf(a_option == guiDebugTraceMode)
		SetMenuDialogOptions(guiDebugTraceModes)
		SetMenuDialogStartIndex(BAF_TraceMode.GetValueInt())
		SetMenuDialogDefaultIndex(BAF_TraceMode.GetValueInt())	

	elseIf(a_option == guiCombatStyle || a_option == guiNPCCombatStyle)
		SetMenuDialogOptions(combatStyleNames)
		SetMenuDialogStartIndex(CSindex)
		SetMenuDialogDefaultIndex(CSindex)
	endIf
endEvent

event OnOptionInputOpen(int a_option)
	if(a_option == guiSaveMyFace)
		SetInputDialogStartText("MyFollowerFace")
	elseIf(a_option == guiNPCName)
		SetInputDialogStartText(NPCList[Nindex])
	elseIf(a_option == guiWeaponSpeedMulti)	
		SetInputDialogStartText(tarActor.GetAV("WeaponSpeedMult") as String)
	elseIf(a_option == guiBowSpeedMulti)
		SetInputDialogStartText(tarActor.GetAV("BowSpeedBonus") as String)
	elseIf(a_option == guiSpeedMulti)
		SetInputDialogStartText(tarActor.GetAV("SpeedMult") as String)
	elseIf(a_option == guiDamageResist)
		SetInputDialogStartText(tarActor.GetAV("DamageResist") as String)
	elseIf(a_option == guiMagicResist)
		SetInputDialogStartText(tarActor.GetAV("MagicResist") as String)
	elseIf(a_option == guiHealth)
		SetInputDialogStartText(tarActor.GetAV("Health") as String)
	elseIf(a_option == guiStamina)
		SetInputDialogStartText(tarActor.GetAV("Stamina") as String)
	elseIf(a_option == guiMagicka)
		SetInputDialogStartText(tarActor.GetAV("Magicka") as String)
	elseIf(a_option == guiHealRate)
		SetInputDialogStartText(tarActor.GetAV("HealRate") as String)
	elseIf(a_option == guiStaminaRate)
		SetInputDialogStartText(tarActor.GetAV("StaminaRate") as String)
	elseIf(a_option == guiMagickaRate)
		SetInputDialogStartText(tarActor.GetAV("MagickaRate") as String)
	elseIf(a_option == guiCombatStyleName)
		SetInputDialogStartText(combatStyleNames[CSindex])
	endIf
endEvent

Event OnOptionSliderAccept(int a_option, float a_value)
	if(a_option == guiCsOffensive)
		SetSliderOptionValue(a_option, a_value, "{2}")
		tarStyle.SetOffensiveMult(a_value)
	elseIf(a_option == guiCsDefensive)
		SetSliderOptionValue(a_option, a_value, "{2}")
		tarStyle.SetDefensiveMult(a_value)
	elseIf(a_option == guiCsGroupOffensive)
		SetSliderOptionValue(a_option, a_value, "{2}")
		tarStyle.SetGroupOffensiveMult(a_value)
	elseIf(a_option == guiCsAvoidThreatChance)
		SetSliderOptionValue(a_option, a_value, "{2}")
		tarStyle.SetAvoidThreatChance(a_value)
	elseIf(a_option == guiCsMelee)
		SetSliderOptionValue(a_option, a_value, "{2}")
		tarStyle.SetMeleeMult(a_value)		
	elseIf(a_option == guiCsRanged)
		SetSliderOptionValue(a_option, a_value, "{2}")
		tarStyle.SetRangedMult(a_value)		
	elseIf(a_option == guiCsMagic)
		SetSliderOptionValue(a_option, a_value, "{2}")
		tarStyle.SetMagicMult(a_value)		
	elseIf(a_option == guiCsShout)
		SetSliderOptionValue(a_option, a_value, "{2}")
		tarStyle.SetShoutMult(a_value)		
	elseIf(a_option == guiCsStaff)
		SetSliderOptionValue(a_option, a_value, "{2}")
		tarStyle.SetStaffMult(a_value)		
	elseIf(a_option == guiCsUnarmed)
		SetSliderOptionValue(a_option, a_value, "{2}")
		tarStyle.SetUnarmedMult(a_value)		

	elseIf(a_option == guiCloseRangeDuelingCircle)
		SetSliderOptionValue(a_option, a_value, "{2}")
		tarStyle.SetCloseRangeDuelingCircleMult(a_value)		
	elseIf(a_option == guiCloseRangeDuelingFallback)
		SetSliderOptionValue(a_option, a_value, "{2}")
		tarStyle.SetCloseRangeDuelingFallbackMult(a_value)		
	elseIf(a_option == guiCloseRangeFlankingFlankDistance)
		SetSliderOptionValue(a_option, a_value, "{2}")
		tarStyle.SetCloseRangeFlankingFlankDistance(a_value)		
	elseIf(a_option == guiCloseRangeFlankingStalkTime)
		SetSliderOptionValue(a_option, a_value, "{2}")
		tarStyle.SetCloseRangeFlankingStalkTime(a_value)		
	elseIf(a_option == guiLongRangeStrafeMult)
		SetSliderOptionValue(a_option, a_value, "{2}")
		tarStyle.SetLongRangeStrafeMult(a_value)		

	elseIf(a_option == guiMeleeAttackStaggered)
		SetSliderOptionValue(a_option, a_value, "{2}")
		tarStyle.SetMeleeAttackStaggeredMult(a_value)
	elseIf(a_option == guiMeleePowerAttackStaggered)
		SetSliderOptionValue(a_option, a_value, "{2}")
		tarStyle.SetMeleePowerAttackStaggeredMult(a_value)
	elseIf(a_option == guiMeleePowerAttackBlocking)
		SetSliderOptionValue(a_option, a_value, "{2}")
		tarStyle.SetMeleePowerAttackBlockingMult(a_value)
	elseIf(a_option == guiMeleeBash)
		SetSliderOptionValue(a_option, a_value, "{2}")
		tarStyle.SetMeleeBashMult(a_value)
	elseIf(a_option == guiMeleeBashRecoiled)
		SetSliderOptionValue(a_option, a_value, "{2}")
		tarStyle.SetMeleeBashRecoiledMult(a_value)
	elseIf(a_option == guiMeleeBashAttack)
		SetSliderOptionValue(a_option, a_value, "{2}")
		tarStyle.SetMeleeBashAttackMult(a_value)
	elseIf(a_option == guiMeleeBashPowerAttack)
		SetSliderOptionValue(a_option, a_value, "{2}")
		tarStyle.SetMeleeBashPowerAttackMult(a_value)
	elseIf(a_option == guiMeleeSpecialAttack)
		SetSliderOptionValue(a_option, a_value, "{2}")
		tarStyle.SetMeleeSpecialAttackMult(a_value)

	elseIf(a_option == guiAttackDamageMult)
		SetSliderOptionValue(a_option, a_value, "{2}")
		tarActor.ForceAV("AttackDamageMult", a_value)

	elseIf(a_option == guiSkillsInput)
		tarActor.ForceAv(skillNames[SKindex], a_value)
		SetSliderOptionValue(guiSkillsInput, tarActor.GetAV(skillNames[SKindex]))

	elseIf(a_option == guiDebugRMDelay)
		BAF_RMDelay.SetValueInt(a_value as int)
		SetSliderOptionValue(guiDebugRMDelay, BAF_RMDelay.GetValueInt())
	elseIf(a_option == guiDebugRMFullMode)
		BAF_RMFullMode.SetValueInt(a_value as int)
		SetSliderOptionValue(guiDebugRMFullMode, BAF_RMFullMode.GetValueInt())
	elseIf(a_option == guiDebugRMLiteMode)
		BAF_RMLiteMode.SetValueInt(a_value as int)
		SetSliderOptionValue(guiDebugRMLiteMode, BAF_RMLiteMode.GetValueInt())
	endIf

endEvent

event OnOptionInputAccept(int a_option, string a_input)
	if(a_option == guiSaveMyFace)
		saveMyFace(a_input)
	elseIf(a_option == guiNPCName)
		newName = a_input
		SetInputOptionValue(guiNPCName, newName)
	elseIf(a_option == guiWeaponSpeedMulti)
		tarActor.ForceAV("WeaponSpeedMult", a_input as float)
		SetInputOptionValue(guiWeaponSpeedMulti, tarActor.GetAV("WeaponSpeedMult") as String)
	elseIf(a_option == guiBowSpeedMulti)
		tarActor.ForceAV("BowSpeedBonus", a_input as float)
		SetInputOptionValue(guiBowSpeedMulti, tarActor.GetAV("BowSpeedBonus") as String)
	elseIf(a_option == guiSpeedMulti)
		tarActor.ForceAV("SpeedMult", a_input as float)
		SetInputOptionValue(guiSpeedMulti, tarActor.GetAV("SpeedMult") as String)
	elseIf(a_option == guiDamageResist)
		tarActor.ForceAV("DamageResist", a_input as int)
		SetInputOptionValue(guiDamageResist, tarActor.GetAV("DamageResist") as String)
	elseIf(a_option == guiMagicResist)
		tarActor.ForceAV("MagicResist", a_input as int)
		SetInputOptionValue(guiMagicResist, tarActor.GetAV("MagicResist") as String)
	elseIf(a_option == guiHealth)
		tarActor.ForceAV("Health", a_input as float)
		SetInputOptionValue(guiHealth, tarActor.GetAV("Health") as String)
	elseIf(a_option == guiStamina)
		tarActor.ForceAV("Stamina", a_input as float)
		SetInputOptionValue(guiStamina, tarActor.GetAV("Stamina") as String)
	elseIf(a_option == guiMagicka)
		tarActor.ForceAV("Magicka", a_input as float)
		SetInputOptionValue(guiMagicka, tarActor.GetAV("Magicka") as String)
	elseIf(a_option == guiHealRate)
		tarActor.ForceAV("HealRate", a_input as float)
		SetInputOptionValue(guiHealRate, tarActor.GetAV("HealRate") as String)
	elseIf(a_option == guiStaminaRate)
		tarActor.ForceAV("StaminaRate", a_input as float)
		SetInputOptionValue(guiStaminaRate, tarActor.GetAV("StaminaRate") as String)
	elseIf(a_option == guiMagickaRate)
		tarActor.ForceAV("MagickaRate", a_input as float)
		SetInputOptionValue(guiMagickaRate, tarActor.GetAV("MagickaRate") as String)
	
	elseIf(a_option == guiCombatStyleName)
		combatStyleNames[CSindex] = a_input
		SetInputOptionValue(guiCombatStyleName, combatStyleNames[CSindex])
		SetMenuOptionValue(guiCombatStyle, combatStyleNames[CSindex])
	endIf
endEvent

; @implements SKI_ConfigBase
event OnOptionMenuAccept(int a_option, int a_index)
	{Called when a menu entry has been accepted}

	; ...
	if(a_index != -1) ;User cancel, do nothing. NOTHING
		if (a_option == guiNPCList)
			tarActor = BAF_NPCs.GetAt(a_index) as Actor
			actorScript = tarActor as BAF_ActorScript
			noMatchingSexSlot = false
			Nindex = a_index
			CSindex = getCSIndex()
			getNPCTargetData()
			ForcePageReset()
		elseIf(a_option == guiFVoicesList)
			femVoice = true
			Fvindex = a_index
			SetMenuOptionValue(guiFVoicesList, FVoicesList[Fvindex])
		elseIf(a_option == guiMVoicesList)
			femVoice = false
			Mvindex = a_index
			SetMenuOptionValue(guiMVoicesList, MVoicesList[Mvindex])
		elseIf(a_option == guiRacesList)
			Rindex = a_index
			SetMenuOptionValue(guiRacesList,RacesList[Rindex])
	elseIf(a_option == guiPresetsList)
		Prindex = a_index
		newPreset = presetFolderList[Prindex] + PresetList[Prindex]
		SetMenuOptionValue(guiPresetsList,PresetList[Prindex])
			SetToggleOptionValue(guiPresetHeadMesh, getHasHeadMesh())
		elseIf(a_option == guiNPCPresetList)
			NPrindex = a_index
			SetMenuOptionValue(guiNPCPresetList,NPCPresetList[NPrindex])
			loadSingleNPC(actorScript, NPCPresetList[NPrindex])
			getNPCTargetData()
		elseIf(a_option == guiSkillsList)
			SKindex = a_index
			SetMenuOptionValue(guiSkillsList,skillNames[SKindex])
			SetSliderOptionValue(guiSkillsInput, tarActor.GetAv(skillNames[SKindex]))

		elseIf(a_option == guiNPCSpellListNames)
			actorScript.toggleSpellByIndex(a_index)
			SetMenuOptionValue(guiNPCSpellListNames, actorScript.getMySpellNames()[0])
		elseIf(a_option == guiSpellList)
			actorScript.toggleSpell(BAF_Spells.GetAt(a_index) as Spell)
			SetMenuOptionValue(guiNPCSpellListNames, actorScript.getMySpellNames()[0])
		elseIf(a_option == guiShoutList)
			actorScript.toggleShout(BAF_Shouts.GetAt(a_index) as Shout)
			SetMenuOptionValue(guiNPCShoutListNames, actorScript.getMyShoutNames()[0])

		elseIf(a_option == guiCombatStyle)
			CSindex = a_index
			ForcePageReset()

		elseIf(a_option == guiNPCCombatStyle)
			CSindex = a_index
			actorScript.setMyCombatStyleData(BAF_CombatStyles.GetAt(a_index) as CombatStyle)
			SetMenuOptionValue(guiNPCCombatStyle, combatStyleNames[a_index])

		elseIf(a_option == guiNPCClass)
			ClassIndex = a_index
			actorScript.setMyClass(BAF_Classes.GetAt(a_index) as Class)
			SetMenuOptionValue(guiNPCClass, classesNames[a_index])

		elseIf(a_option == guiDebugTraceMode)
			BAF_TraceMode.SetValueInt(a_index)
			SetMenuOptionValue(guiDebugTraceMode, guiDebugTraceModes[a_index])
		endIf
	endIf
endEvent
