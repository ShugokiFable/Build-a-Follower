Scriptname BAF_PlayerScript extends ReferenceAlias  

int eventHandle
BAF_MCMScript Property mainHook Auto

Event OnPlayerLoadGame()
	eventHandle = ModEvent.Create("BuildAFollowerOnloadUpdate")
	ModEvent.Send(eventHandle)
	mainHook.updater()
endEvent