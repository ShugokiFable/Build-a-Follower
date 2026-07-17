Scriptname BAF_ConfigManager extends Quest  

BAF_MCMScript Property mcmHook Auto
String configFile
String npcFile
int config
int npcData


Event OnInit()
	configFile = "Data/SKSE/Plugins/BuildAFollower/BuildAFollowerConfig.json"
	npcFile = "Data/SKSE/Plugins/BuildAFollower/BuildAFollowerNPC.json"
endEvent

bool function configFileExists()
	Return MiscUtil.FileExists(configFile)
endFunction

bool function npcFileExists()	
	Return MiscUtil.FileExists(npcFile)
endFunction

function saveConfig()
	configFile = "Data/SKSE/Plugins/BuildAFollower/BuildAFollowerConfig.json"
	config = JMap.object()
	saveFemaleVoiceTypes()
	saveFemaleVoiceTypeNames()
	saveMaleVoiceTypes()
	saveMaleVoiceTypeNames()
	saveRaces()
	saveRaceNames()
	saveCombatStylesData()
	saveCombatStyleNames()
	JValue.writeToFile(config, configFile)
endFunction

function loadConfig()
	configFile = "Data/SKSE/Plugins/BuildAFollower/BuildAFollowerConfig.json"
	config = JValue.readFromFile(configFile)
	loadFemaleVoiceTypes()
	loadFemaleVoiceTypeNames()
	loadMaleVoiceTypes()
	loadMaleVoiceTypeNames()
	loadRaces()
	loadRaceNames()
	loadCombatStylesData()
	loadCombatStyleNames()
endFunction

function saveNpcs()
	;saveNPCData()
	saveNPCDataMultiFile()
endFunction

function loadNPCs()
	loadNPCData()
endFunction

function writeFormListToDisk(Formlist inList, String keyName)
	int indexer = inList.GetSize()
	int n = 0
	while(indexer > 0)
		indexer -= 1
		JValue.solveFormSetter(config, keyName + n, inList.GetAt(indexer) as Form, createMissingKeys = true)
		n += 1
	endWhile
endFunction

function writeStringListToDisk(String[] inList, String keyName)
	int indexer = inList.Length
	int n = 0
	while(indexer > 0)
		indexer -= 1
		JValue.solveStrSetter(config, keyName + n, (inList[indexer] as String), createMissingKeys = true)
		n += 1
	endWhile
endFunction

function writeFloatListToDisk(Float[] inList, String keyName)
	int indexer = inList.Length
	int n = 0
	while(indexer > 0)
		indexer -= 1
		JValue.solveFltSetter(config, keyName + n, (inList[indexer] as float), createMissingKeys = true)
		n += 1
	endWhile
endFunction

Form[] function readFormListFromDisk(String keyName)
	int formIndex = 0

	Form[] formArr = Utility.CreateFormArray(1, none)

	while(JValue.hasPath(config, keyName + formIndex))
		formArr[formIndex] = JValue.solveForm(config, keyName + formIndex) as Form
		formArr = Utility.ResizeFormArray(formArr, formArr.Length + 1, none)
		formIndex += 1
	endWhile

	formArr = Utility.ResizeFormArray(formArr, formArr.Length - 1) ;Drop the last none entry
	formArr = flipFormArray(formArr)

	return formArr
endFunction

String[] function readStringListFromDisk(String keyName)
	int strIndex = 0

	String[] stringArr = Utility.CreateStringArray(1, none)

	while(JValue.hasPath(config, keyName +  strIndex))
		stringArr[strIndex] = JValue.solveStr(config, keyName + strIndex) as String
		stringArr = Utility.ResizeStringArray(stringArr, stringArr.Length + 1, none)
		strIndex += 1
	endWhile

	stringArr = Utility.ResizeStringArray(stringArr, stringArr.Length - 1) ;Drop the last none entry
	stringArr = flipStringArray(stringArr)

	return stringArr
endFunction

Float[] function readFloatListFromDisk(String keyName)
	int flIndex = 0

	Float[] floatArr = Utility.CreateFloatArray(1, 0.0)

	while(JValue.hasPath(config, keyName + flIndex))
		floatArr[flIndex] = JValue.solveflt(config, keyName + flIndex)
		floatArr = Utility.ResizeFloatArray(floatArr, floatArr.Length + 1, 0.0)
		flIndex += 1
	endWhile
	floatArr = Utility.ResizeFloatArray(floatArr, floatArr.Length - 1) ;Drop the last none entry
	floatArr = flipFloatArray(floatArr)

	return floatArr
endFunction

;Voices
function saveFemaleVoiceTypes()
	writeFormListToDisk(mcmHook.BAF_FemaleVoices, ".FemaleVoice.")
endFunction

function saveFemaleVoiceTypeNames()
	writeStringListToDisk(mcmHook.FVoicesList, ".FemaleVoiceNames.")
endFunction

function saveMaleVoiceTypes()
	writeFormListToDisk(mcmHook.BAF_MaleVoices, ".MaleVoice.")
endFunction

function saveMaleVoiceTypeNames()
	writeStringListToDisk(mcmHook.MVoicesList, ".MaleVoiceNames.")
endFunction

function loadFemaleVoiceTypes()
	mcmHook.BAF_FemaleVoices.Revert()
	mcmHook.BAF_FemaleVoices.AddForms(readFormListFromDisk(".FemaleVoice."))
endFunction

function loadFemaleVoiceTypeNames()
	mcmHook.FVoicesList = readStringListFromDisk(".FemaleVoiceNames.")
endFunction

function loadMaleVoiceTypes()
	mcmHook.BAF_MaleVoices.Revert()
	mcmHook.BAF_MaleVoices.AddForms(readFormListFromDisk(".MaleVoice."))
endFunction

function loadMaleVoiceTypeNames()
	mcmHook.MVoicesList = readStringListFromDisk(".MaleVoiceNames.")
endFunction


;Races
function saveRaces()
	writeFormListToDisk(mcmHook.BAF_Races, ".Races.")
endFunction

function saveRaceNames()
	writeStringListToDisk(mcmHook.RacesList, ".RaceNames.")
endFunction

function loadRaces()
	mcmHook.BAF_Races.AddForms(readFormListFromDisk(".Races."))
endFunction

function loadRaceNames()
	mcmHook.RacesList = readStringListFromDisk(".RaceNames.")
endFunction

;CombaStyle
function saveCombatStyleNames()
	writeStringListToDisk(mcmHook.combatStyleNames, ".CombatStyleNames.")
endFunction

function saveCombatStylesData()
	int indexer = mcmHook.BAF_CombatStyles.GetSize()
	int n = 0
	while(indexer > 0)
		indexer -= 1
		writeFloatListToDisk(mcmHook.getCombatStyleData(mcmHook.BAF_CombatStyles.GetAt(indexer) as CombatStyle), ".CombatStyle." + n + "." )
		n += 1
	endWhile
endFunction

function loadCombatStyleNames()
	String[] loaded = readStringListFromDisk(".CombatStyleNames.")
	int need = mcmHook.BAF_CombatStyles.GetSize()
	if(loaded.Length < need)
		; Config written by an older/smaller pool - pad so styles keep a label
		int i = loaded.Length
		loaded = Utility.ResizeStringArray(loaded, need)
		while(i < need)
			loaded[i] = mcmHook.defaultCombatStyleName(i)
			i += 1
		endWhile
	endIf
	; Replace legacy placeholder labels so old JSON does not keep "Style #5"
	int j = 0
	while j < need
		String n = loaded[j]
		if n == "" || StringUtil.Find(n, "Style #") == 0 || StringUtil.Find(n, "CombatStyle #") == 0
			loaded[j] = mcmHook.defaultCombatStyleName(j)
		endIf
		j += 1
	endWhile
	mcmHook.combatStyleNames = loaded
endFunction

function loadCombatStylesData()
	int indexer = mcmHook.BAF_CombatStyles.GetSize()
	int n = 0
	while(indexer > 0)
		indexer -= 1
		mcmHook.setMyCombatStyleData(mcmHook.BAF_CombatStyles.GetAt(indexer) as CombatStyle, readFloatListFromDisk(".CombatStyle." + n + "."))
		n += 1
	endWhile
endFunction

;npcData
function saveNPCData()
	int npcSlots = mcmHook.BAF_NPCs.GetSize()
	int indexer = 0
	int npcIndex = 0
	npcFile = "Data/SKSE/Plugins/BuildAFollower/BuildAFollowerNPC.json"
	npcData = JMap.object()	
	while(indexer < npcSlots)		
		BAF_ActorScript tarScript = (mcmHook.BAF_NPCs.GetAt(indexer) as Actor) as BAF_ActorScript

			if(tarScript.getMyPreset() != "")
				mcmHook.dout("Saving NPC - " + tarScript.getMyPresetName())
				; Persist the real template index, not the compacted save-entry index.
				; Mixing these moves a saved male follower into a female template after reload.
				saveNPCSlotID(".NPC" + npcIndex + ".slotId", indexer)
				saveNPCActorVars( tarScript, ".NPC" + npcIndex)
				saveNPCSpellVars( tarScript, ".NPC" + npcIndex + ".Spells")
				saveNPCSpellName( tarScript, ".NPC" + npcIndex + ".SpellNames")
				saveNPCGear( tarScript, ".NPC" + npcIndex + ".Equipment")

				;For whatever reason JContainers shits the bed halfway through without this save-reload nutslap
				JValue.writeToFile(npcData, npcFile)
				npcData = JValue.readFromFile(npcFile)
				npcIndex += 1
			endIf

		indexer += 1
	endWhile
	mcmHook.dOut("BuildAFollower: Saved " + npcIndex + " followers")
endFunction

function saveNPCDataMultiFile()
	;rewrite as single file - indexing order
	int indexer = mcmHook.BAF_NPCs.GetSize()
	int n = 0
	while(indexer > 0)
		indexer -= 1		
		
		BAF_ActorScript tarScript = (mcmHook.BAF_NPCs.GetAt(indexer) as Actor) as BAF_ActorScript

		if(tarScript.getMyPreset() != "")
			npcData = JMap.object()
			String npcName = tarScript.getMyPresetName()
			mcmHook.dout("Saving NPC - " + npcName)
			npcFile = "Data/SKSE/Plugins/BuildAFollower/BuildAFollowerNPCs/"  + npcName + ".json"
			saveNPCActorVars( tarScript, ".NPC")
			saveNPCSpellVars( tarScript, ".NPC.Spells")
			saveNPCGear( tarScript, ".NPC.Equipment")

			JValue.writeToFile(npcData, npcFile)
			n += 1
		endIf
	endWhile
	mcmHook.dOut("BuildAFollower: Saved " + n + " followers")
endFunction

function saveNPCSpellName(BAF_ActorScript inTarScript, String inKeyName)
	String[] tarSpellNames = inTarScript.getMySpellNames()
	int sNameCount = tarSpellNames.Length

	while(sNameCount > 0)
		sNameCount -= 1
		if(tarSpellNames[sNameCount] != "none")
			
			JValue.solveStrSetter(npcData, inKeyName + "." + sNameCount, tarSpellNames[sNameCount], createMissingKeys=True)
		endIf		
	endWhile
endFunction

function saveNPCGear(BAF_ActorScript inTarScript, String inKeyName)
	Form[] tarEquipment = inTarScript.getMyGear()
	int eqCount = tarEquipment.Length
	int n = 0
	while( eqCount > 0)
		eqCount -= 1
		if((tarEquipment[eqCount] as Form) != none)
			JValue.solveFormSetter(npcData, inKeyName + "." + n, tarEquipment[eqCount] as Form, createMissingKeys=True)
			n += 1
		endIf
	endWhile
endFunction

function saveNPCSlotID(String inKeyName, int inSlotId)
	JValue.solveIntSetter(npcData, inKeyName, inSlotId, createMissingKeys = true)
endFunction

function saveNPCActorVars(BAF_ActorScript inTarScript, String inKeyName)
	JValue.solveFormSetter(npcData, inKeyName + ".Actor", inTarScript.getMyActor(), createMissingKeys=True)
	JValue.solveStrSetter(npcData, inKeyName + ".PresetName", inTarScript.getMyPresetName(), createMissingKeys = true)
	JValue.solveStrSetter(npcData, inKeyName + ".Preset", inTarScript.getMyPreset(), createMissingKeys = true)
	JValue.solveIntSetter(npcData, inKeyName + ".IsFemale", inTarScript.GetMyActor().GetActorBase().GetSex(), createMissingKeys = true)
	JValue.solveFormSetter(npcData, inKeyName + ".CombatStyle", inTarScript.getMyCombatStyle(), createMissingKeys=True)
	JValue.solveFormSetter(npcData, inKeyName + ".VoiceType", inTarScript.getMyPresetVoiceType(), createMissingKeys=True)
	JValue.solveFormSetter(npcData, inKeyName + ".Race", inTarScript.getMyPresetRace(), createMissingKeys=True)
	JValue.solveFormSetter(npcData, inKeyName + ".Class", inTarScript.getMyClass(), createMissingKeys=True)
endFunction

function saveNPCSpellVars(BAF_ActorScript inTarScript, String inKeyName)
	Form[] tarSpells = inTarScript.getMySpells()
	int spellCount = tarSpells.Length

	while(spellCount > 0)
		spellCount -= 1
		if(tarSpells[spellCount] as Spell)
			
			JValue.solveFormSetter(npcData, inKeyName + "." + spellCount, tarSpells[spellCount], createMissingKeys=True)
		endIf		
	endWhile
endFunction

function loadNPCData()
	int npcSlots = mcmHook.BAF_NPCs.GetSize()
	int indexer = 0
	int numLoaded = 0
	npcFile = "Data/SKSE/Plugins/BuildAFollower/BuildAFollowerNPC.json"
	npcData = JValue.readFromFile(npcFile)

	; Clear every template before any restore. The old single-pass approach could
	; restore into a later slot and then dismiss that slot on a later iteration.
	while(indexer < npcSlots)
		BAF_ActorScript toClear = (mcmHook.BAF_NPCs.GetAt(indexer) as Actor) as BAF_ActorScript
		toClear.dismissMe()
		indexer += 1
	endWhile

	indexer = 0
	while(indexer < npcSlots)
		if(npcDataToLoad(".NPC" + indexer))
			int savedSex = loadNPCSex(".NPC" + indexer)
			Actor tarActor = resolveLoadSlot(loadNPCSlotID(".NPC" + indexer), savedSex)
			if tarActor
				BAF_ActorScript tarScript = tarActor as BAF_ActorScript
				tarActor.enable()
				loadNPCActorVars( tarScript, ".NPC" + indexer)
				loadNPCSpellVars( tarScript, ".NPC" + indexer + ".Spells")
				loadNPCGear( tarScript, ".NPC" + indexer + ".Equipment")
				tarScript.registerForEvents()
				numLoaded += 1
			else
				mcmHook.dOut("BuildAFollower: No compatible template for saved NPC " + indexer)
			endIf
		endIf
		indexer += 1
	endWhile
	mcmHook.dOut("BuildAFollower: Loaded " + numLoaded + " followers")
endFunction

bool function loadSingleNPCData(BAF_ActorScript inScript, String inPreset)
	Actor tarActor = inScript.getMyActor()

	npcFile = "Data/SKSE/Plugins/BuildAFollower/BuildAFollowerNPCs/" + inPreset
	npcData = JValue.readFromFile(npcFile)

	int savedSex = loadNPCSex(".NPC")
	if(savedSex > -1 && tarActor.GetActorBase().GetSex() == savedSex)
		tarActor.enable()
		loadNPCActorVars( inScript, ".NPC")
		loadNPCSpellVars( inScript, ".NPC.Spells")
		loadNPCGear( inScript, ".NPC.Equipment")
		inScript.registerForEvents()
		mcmHook.dOut("BuildAFollower: Loaded " + inPreset)
		return true
	endIf
		
	return false
endFunction

; New saves use IsFemale. Accept the old lowercase spelling only for backwards
; compatibility with pre-fix JSON files.
int function loadNPCSex(String inKeyName)
	if JValue.hasPath(npcData, inKeyName + ".IsFemale")
		return JValue.solveInt(npcData, inKeyName + ".IsFemale")
	elseIf JValue.hasPath(npcData, inKeyName + ".isFemale")
		return JValue.solveInt(npcData, inKeyName + ".isFemale")
	endIf
	return -1
endFunction

; Correct files retain their original slot. Broken older saves used a compacted
; entry index instead; recover them into a free template of the saved sex.
Actor function resolveLoadSlot(int savedSlot, int savedSex)
	int slotCount = mcmHook.BAF_NPCs.GetSize()
	if savedSlot >= 0 && savedSlot < slotCount
		Actor candidate = mcmHook.BAF_NPCs.GetAt(savedSlot) as Actor
		if savedSex < 0 || candidate.GetActorBase().GetSex() == savedSex
			return candidate
		endIf
	endIf

	if savedSex >= 0
		return mcmHook.findBestSlot(savedSex)
	endIf
	return none
endFunction

function loadNPCActorVars(BAF_ActorScript inTarScript, String inKeyName)
	inTarScript.setMyPresetName(JValue.solveStr(npcData, inKeyName + ".PresetName"))
	inTarScript.setMyPreset(JValue.solveStr(npcData, inKeyName + ".Preset"))
	inTarScript.setMyCombatStyleData(JValue.solveForm(npcData, inKeyName + ".CombatStyle") as CombatStyle)
	inTarScript.setMyPresetVoice(JValue.solveForm(npcData, inKeyName + ".VoiceType") as VoiceType)
	inTarScript.setMyPresetRace(JValue.solveForm(npcData, inKeyName + ".Race") as Race)
	inTarScript.setMyClass(JValue.solveForm(npcData, inKeyName + ".Class") as Class)
	inTarScript.refreshAppearance(true)
endFunction

function loadNPCSpellVars(BAF_ActorScript inTarScript, String inKeyName)
	int spellIndex = 0

	inTarScript.clearMySpells()

	while(JValue.hasPath(npcData, inKeyName + "." + spellIndex))
		inTarScript.toggleSpell(JValue.solveForm(npcData, inKeyName + "." + spellIndex) as Spell)
		spellIndex += 1
	endWhile

endFunction


function loadNPCGear(BAF_ActorScript inTarScript, String inKeyName)
	int gearIndex = 0
	Actor toOutfit = inTarScript.getMyActor()
	toOutfit.UnequipAll()

	while(JValue.hasPath(npcData, inKeyName + "." + gearIndex))
		Form toEquip = JValue.solveForm(npcData, inKeyName + "." + gearIndex) as Form
		
		if(toEquip != none)
			toOutfit.AddItem(toEquip)
			toOutfit.EquipItemEx(toEquip)
		else
			mcmHook.dout(inTarScript.getMyPresetName() + ":Failed to equip item #" + gearIndex + ". Item not found in current game")
		endIf
		gearIndex += 1
	endWhile

	toOutfit.QueueNiNodeUpdate()
endFunction

int function loadNPCSlotID(String inKeyName)
	int loadid = JValue.solveInt(npcData, inKeyName + ".slotId") as int
	return loadid
endFunction

bool function npcDataToLoad(String inKeyName)
	if(JValue.solveStr(npcData, inKeyName + ".Preset") == "")
		return false
	endIf

	return true
endFunction

Form[] function flipFormArray(Form[] inFormArray)
	; Reverse array order (load order was written descending)
	int n = inFormArray.Length
	Form[] newArray = Utility.CreateFormArray(n)
	int i = 0
	while i < n
		newArray[i] = inFormArray[n - 1 - i]
		i += 1
	endWhile
	return newArray
endFunction

String[] function flipStringArray(String[] inStringArray)
	int arrIndex = 0
	int inArrIndex = inStringArray.Length
	String[] newArray = Utility.CreateStringArray(inArrIndex)	

	while(inArrIndex > 0)
		inArrindex -= 1
		newArray[arrIndex] = inStringArray[inArrIndex]
		arrIndex += 1
	endWhile

	return newArray
endFunction

Float[] function flipFloatArray(Float[] inFloatArray)
	int arrIndex = 0
	int inArrIndex = inFloatArray.Length
	Float[] newArray = Utility.CreateFloatArray(inArrIndex)

	while(inArrIndex > 0)
		inArrindex -= 1
		newArray[arrIndex] = inFloatArray[inArrIndex]
		arrIndex += 1
	endWhile

	return newArray
endFunction
