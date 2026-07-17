Scriptname CharGen Hidden

; Dev stub for compilation only - real script ships with RaceMenu (SKEE64). Do NOT package.

Function SaveCharacter(Actor saveActor, String fileName) global native
; Writes jslot + head nif + face tint under CharGen/Exported + Textures/CharGen/Exported
; (verified string in skee64.dll). Preferred export for NPC followers.
Function SaveExternalCharacter(String fileName) global native
Function LoadCharacter(Actor loadedActor, Race defaultRace, String fileName) global native
Function LoadCharacterEx(Actor loadedActor, Race defaultRace, String fileName, int presetFlags = 3) global native
Function LoadExternalCharacter(Actor loadedActor, Race defaultRace, String fileName) global native
Function LoadExternalCharacterEx(Actor loadedActor, Race defaultRace, String fileName, int presetFlags = 3) global native
Function LoadCharacterPreset(Actor loadedActor, String fileName, ColorForm hairColorForm) global native
Function LoadCharacterPresetEx(Actor loadedActor, String fileName, ColorForm hairColorForm, int presetFlags = 3) global native
Function ClearPreset(ActorBase character) global native
Function ClearPresets() global native
