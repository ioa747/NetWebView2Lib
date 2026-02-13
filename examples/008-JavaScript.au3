#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Run_AU3Check=Y
#AutoIt3Wrapper_AU3Check_Stop_OnWarning=y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7

; 008-JavaScript.au3

#include "..\NetWebView2Lib.au3"

Global $oWebV2M, $oBridge

_Example_Console_Redirect()

Func _Example_Console_Redirect()
	Local $hGUI = GUICreate("Console Redirect Test", 400, 300)

	; 1. Initialize WebView2
	; Initialize WebView2 Manager and register events
	Local $oWebV2M = _NetWebView2_CreateManager("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0", "", "--disable-gpu, --mute-audio")
	If @error Then Return SetError(@error, @extended, $oWebV2M)

	; initialize browser - put it on the GUI
	Local $sProfileDirectory = @ScriptDir & "\NetWebView2Lib-UserDataFolder"
	_NetWebView2_Initialize($oWebV2M, $hGUI, $sProfileDirectory, 0, 0, 0, 0, True, True, 1.2, "0x2B2B2B", True)
	GUISetState(@SW_SHOW)

	; create JavaScript Bridge object
	Local $oJSBridge = _NetWebView2_GetBridge($oWebV2M, "__UserEventHandler_Bridge__")
	If @error Then Return SetError(@error, @extended, $oJSBridge)

	; navigate to the page
	_NetWebView2_Navigate($oWebV2M, "about:blank")

	; 6. TEST: Execute a console.log
	; Note: We don't use ExecuteScriptWithResult here because
	; the data will come back through the Bridge Event!
	_NetWebView2_ExecuteScript($oWebV2M, "console.log('Hello from JavaScript to AutoIt Console!');")
	_NetWebView2_ExecuteScript($oWebV2M, "console.error('This is a test error message');")

	; --- Main Loop ---
	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				ExitLoop
		EndSwitch
	WEnd

	_NetWebView2_CleanUp($oWebV2M, $oJSBridge)
EndFunc   ;==>_Example_Console_Redirect

; This function handles the incoming messages from the JS Bridge
Func __UserEventHandler_Bridge__OnMessageReceived($oWebV2M, $hGUI, $sMsg)
	#forceref $oWebV2M, $hGUI
	; Check if it's a JSON message from our Bridge
	If StringLeft($sMsg, 1) = "{" Then
		; For simplicity in this example, we just print the raw message
		; In a real app, you would parse the JSON to get .message and .level
		ConsoleWrite(">> JavaScript BRIDGE: MESSAGE: " & $sMsg & @CRLF)
	EndIf
EndFunc   ;==>__UserEventHandler_Bridge__OnMessageReceived

