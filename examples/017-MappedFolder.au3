#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Run_AU3Check=Y
#AutoIt3Wrapper_AU3Check_Stop_OnWarning=y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7

; 017-MappedFolder.au3

#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>

#include "..\NetWebView2Lib.au3"

_Example()

Func _Example()
	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc)
	#forceref $oMyError

	#Region ; GUI CREATION

	; Create the GUI
	Local $hGUI = GUICreate("WebView2 .NET Manager - MappedFolder Demo", 1000, 800, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPCHILDREN))
	GUISetBkColor(0x1A1A1A, $hGUI)

	; Initialize WebView2 Manager and register events
	Local $oWebV2M = _NetWebView2_CreateManager()
	If @error Then Return SetError(@error, @extended, $oWebV2M)

	; initialize browser - put it on the GUI
	Local $sProfileDirectory = @ScriptDir & "\NetWebView2Lib-UserDataFolder"
	_NetWebView2_Initialize($oWebV2M, $hGUI, $sProfileDirectory, 0, 0, 0, 0, True, True, 1.2, "0x2B2B2B")

	; Now that it is Ready, we define Mapping & Scripts
    Local $sLocalFolder = @ScriptDir & "\MappedFolder"
	_NetWebView2_SetVirtualHostNameToFolderMapping($oWebV2M, "myapp.local", $sLocalFolder, 0)

    ; Finish Navigate
	_NetWebView2_Navigate($oWebV2M, "https://myapp.local/index.html")

	; show the GUI after browser was fully initialized
	GUISetState(@SW_SHOW)

	#EndRegion ; GUI CREATION


	#Region ; GUI Loop
	; Main Loop
	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				ExitLoop
		EndSwitch
	WEnd

	Local $oJSBridge
	_NetWebView2_CleanUp($oWebV2M, $oJSBridge)
	GUIDelete($hGUI)
	#EndRegion ; GUI Loop

EndFunc   ;==>_Example

