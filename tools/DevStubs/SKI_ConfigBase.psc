Scriptname SKI_ConfigBase extends SKI_QuestBase

; Dev stub for compilation only - real script ships with SkyUI. Do NOT package.
; Signatures match SkyUI 5.2 SE MCM API.

int Property TOP_TO_BOTTOM = 1 AutoReadOnly
int Property LEFT_TO_RIGHT = 2 AutoReadOnly

int Property OPTION_FLAG_NONE = 0x00 AutoReadOnly
int Property OPTION_FLAG_DISABLED = 0x01 AutoReadOnly
int Property OPTION_FLAG_HIDDEN = 0x02 AutoReadOnly
int Property OPTION_FLAG_WITH_UNMAP = 0x04 AutoReadOnly

string Property ModName auto
string[] Property Pages auto

event OnConfigInit()
endEvent

event OnConfigRegister()
endEvent

event OnConfigOpen()
endEvent

event OnConfigClose()
endEvent

event OnDefaultReset()
endEvent

event OnPageReset(string a_page)
endEvent

event OnOptionHighlight(int a_option)
endEvent

event OnOptionSelect(int a_option)
endEvent

event OnOptionDefault(int a_option)
endEvent

event OnOptionSliderOpen(int a_option)
endEvent

event OnOptionSliderAccept(int a_option, float a_value)
endEvent

event OnOptionMenuOpen(int a_option)
endEvent

event OnOptionMenuAccept(int a_option, int a_index)
endEvent

event OnOptionColorOpen(int a_option)
endEvent

event OnOptionColorAccept(int a_option, int a_color)
endEvent

event OnOptionKeyMapChange(int a_option, int a_keyCode, string a_conflictControl, string a_conflictName)
endEvent

event OnOptionInputOpen(int a_option)
endEvent

event OnOptionInputAccept(int a_option, string a_input)
endEvent

function ForcePageReset()
endFunction

function SetTitleText(string a_text)
endFunction

function SetInfoText(string a_text)
endFunction

function SetCursorPosition(int a_position)
endFunction

function SetCursorFillMode(int a_fillMode)
endFunction

int function AddHeaderOption(string a_text, int a_flags = 0)
	return 0
endFunction

int function AddEmptyOption()
	return 0
endFunction

int function AddTextOption(string a_text, string a_value, int a_flags = 0)
	return 0
endFunction

int function AddToggleOption(string a_text, bool a_checked, int a_flags = 0)
	return 0
endFunction

int function AddSliderOption(string a_text, float a_value, string a_formatString = "{0}", int a_flags = 0)
	return 0
endFunction

int function AddMenuOption(string a_text, string a_value, int a_flags = 0)
	return 0
endFunction

int function AddColorOption(string a_text, int a_color, int a_flags = 0)
	return 0
endFunction

int function AddKeyMapOption(string a_text, int a_keyCode, int a_flags = 0)
	return 0
endFunction

int function AddInputOption(string a_text, string a_value, int a_flags = 0)
	return 0
endFunction

function SetOptionFlags(int a_option, int a_flags, bool a_noUpdate = false)
endFunction

function SetTextOptionValue(int a_option, string a_value, bool a_noUpdate = false)
endFunction

function SetToggleOptionValue(int a_option, bool a_checked, bool a_noUpdate = false)
endFunction

function SetSliderOptionValue(int a_option, float a_value, string a_formatString = "{0}", bool a_noUpdate = false)
endFunction

function SetMenuOptionValue(int a_option, string a_value, bool a_noUpdate = false)
endFunction

function SetColorOptionValue(int a_option, int a_color, bool a_noUpdate = false)
endFunction

function SetKeyMapOptionValue(int a_option, int a_keyCode, bool a_noUpdate = false)
endFunction

function SetInputOptionValue(int a_option, string a_value, bool a_noUpdate = false)
endFunction

function SetSliderDialogStartValue(float a_value)
endFunction

function SetSliderDialogDefaultValue(float a_value)
endFunction

function SetSliderDialogRange(float a_minValue, float a_maxValue)
endFunction

function SetSliderDialogInterval(float a_value)
endFunction

function SetMenuDialogStartIndex(int a_value)
endFunction

function SetMenuDialogDefaultIndex(int a_value)
endFunction

function SetMenuDialogOptions(string[] a_options)
endFunction

function SetColorDialogStartColor(int a_color)
endFunction

function SetColorDialogDefaultColor(int a_color)
endFunction

function SetInputDialogStartText(string a_text)
endFunction

bool function ShowMessage(string a_message, bool a_withCancel = true, string a_acceptLabel = "$Accept", string a_cancelLabel = "$Cancel")
	return false
endFunction
