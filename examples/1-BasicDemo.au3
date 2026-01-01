#AutoIt3Wrapper_UseX64=y
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>

; ==============================================================================
; WebView2 Multi-Channel Presentation Script
; ==============================================================================

; Register the exit function
OnAutoItExitRegister("_CleanExit")

; Global objects
Global $oManager, $oBridge
Global $oEvtManager, $oEvtBridge

; COM Error Handler
Global $oMyError = ObjEvent("AutoIt.Error", "_ErrFunc")

; GUI & Controls
Global $hGUI, $idLabelStatus

Main()

Func Main()
	; 1. Create the UI
	$hGUI = GUICreate("WebView2 .NET Manager - Community Demo", 900, 650)
	$idLabelStatus = GUICtrlCreateLabel("Status: Initializing Engine...", 10, 620, 880, 20)
	GUICtrlSetFont(-1, 9, 400, 0, "Segoe UI")
	GUISetState(@SW_SHOW)

	; 2. Instantiate the .NET Manager
	$oManager = ObjCreate("NetWebView2.Manager")
	If Not IsObj($oManager) Then
		MsgBox(16, "Error", "Could not create WebView2 Manager. Please register the DLL.")
		Exit
	EndIf

	; 3. Setup Events (Crucial: Define interfaces explicitly)
	; Channel 1: Manager Events (INIT_READY, NAV_COMPLETED, etc.)
	$oEvtManager = ObjEvent($oManager, "WebView_", "IWebViewEvents")

	; Channel 2: JavaScript Bridge (Messages from JS to AutoIt)
	$oBridge = $oManager.GetBridge()
	$oEvtBridge = ObjEvent($oBridge, "Bridge_", "IBridgeEvents")

	; 4. Initialize the Browser
	; We pass an empty string for the URL to prevent "ConnectionAborted"
	; and wait for our INIT_READY signal.
	$oManager.Initialize(($hGUI), "", 10, 10, 880, 600)

	; Main Loop
	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				ExitLoop
		EndSwitch
	WEnd

	GUIDelete($hGUI)
EndFunc   ;==>Main

Func _CleanExit()
	; Check if the object exists before calling methods to avoid COM errors during crash
	If IsObj($oManager) Then
		$oManager.Cleanup()
	EndIf

	; Release the event sinks
	$oManager = 0
	$oBridge = 0
	$oEvtManager = 0
	$oEvtBridge = 0
	$oMyError = 0

	ConsoleWrite(">>> Application exited cleanly." & @CRLF)
EndFunc   ;==>_CleanExit

; ==============================================================================
; ; Function to update a text element inside the WebView UI
; ==============================================================================
Func UpdateWebUI($sElementId, $sNewText)
	; Escape backslashes, single quotes and handle new lines for JavaScript safety
	Local $sCleanText = StringReplace($sNewText, "\", "\\")
	$sCleanText = StringReplace($sCleanText, "'", "\'")
	$sCleanText = StringReplace($sCleanText, @CRLF, "\n")
	$sCleanText = StringReplace($sCleanText, @LF, "\n")

	Local $sJS = "document.getElementById('" & $sElementId & "').innerText = '" & $sCleanText & "';"

	If IsObj($oManager) Then
		$oManager.ExecuteScript($sJS)
	EndIf
EndFunc   ;==>UpdateWebUI

; ==============================================================================
; EVENT HANDLER: WebView Manager (C# Internal Events)
; ==============================================================================
Func WebView_OnMessageReceived($sMessage)
	ConsoleWrite(">>> [CORE EVENT]: " & $sMessage & @CRLF)

	; Separating messages that have parameters (e.g. TITLE_CHANGED|...)
	Local $aParts = StringSplit($sMessage, "|")
	Local $sCommand = StringStripWS($aParts[1], 3)

	Switch $sCommand
		Case "INIT_READY"
			GUICtrlSetData($idLabelStatus, "Status: Engine Ready. Loading HTML UI...")
			$oManager.NavigateToString(_GetDemoHTML())

		Case "NAV_STARTING"
			GUICtrlSetData($idLabelStatus, "Status: Navigation started...")

		Case "NAV_COMPLETED"
			GUICtrlSetData($idLabelStatus, "Status: Application Ready.")

		Case "TITLE_CHANGED"
			; If you want to change the title of your GUI based on the page
			If $aParts[0] > 1 Then WinSetTitle($hGUI, "", "WebView2 - " & $aParts[2])

		Case "ERROR", "NAV_ERROR"
			Local $sErr = ($aParts[0] > 1) ? $aParts[2] : "Unknown"
			GUICtrlSetData($idLabelStatus, "Status: Error " & $sErr)
			MsgBox(16, "WebView2 Error", $sMessage)
	EndSwitch
EndFunc   ;==>WebView_OnMessageReceived

; ==============================================================================
; EVENT HANDLER: Bridge (JavaScript Messages)
; ==============================================================================
Func Bridge_OnMessageReceived($sMessage)
	Local Static $iMsgCnt = 0
	ConsoleWrite(">>> [JS MESSAGE]: " & $sMessage & @CRLF)

	If $sMessage = "CLOSE_APP" Then
		If MsgBox(36, "Confirm", "Exit Application?", 0, $hGUI) = 6 Then Exit
	Else
		MsgBox(64, "JS Notification", "Message from Browser: " & $sMessage)
		$iMsgCnt += 1
		UpdateWebUI("mainTitle", $iMsgCnt & " Hallo from AutoIt!")
	EndIf
EndFunc   ;==>Bridge_OnMessageReceived

; ==============================================================================
; HELPER: Demo HTML Content
; ==============================================================================
Func _GetDemoHTML()
	Local $sH = '<html><head><style>' & _
			'body { font-family: "Segoe UI", sans-serif; background: #202020; color: white; padding: 40px; text-align: center; }' & _
			'.card { background: #2d2d2d; padding: 20px; border-radius: 8px; border: 1px solid #444; }' & _
			'button { padding: 12px 24px; cursor: pointer; background: #0078d4; color: white; border: none; border-radius: 4px; font-size: 16px; margin: 5px; }' & _
			'button:hover { background: #005a9e; }' & _
			'</style></head><body>' & _
			'<div class="card">' & _
			'  <h1 id="mainTitle">WebView2 + AutoIt .NET Manager</h1>' & _     ; Fixed ID attribute
			'  <p id="statusMsg">The communication is now 100% Event-Driven (No Sleep needed).</p>' & _
			'  <button onclick="window.chrome.webview.postMessage(''Hello from JavaScript!'')">Send Ping</button>' & _
			'  <button onclick="window.chrome.webview.postMessage(''CLOSE_APP'')">Exit App</button>' & _
			'</div>' & _
			'</body></html>'
	Return $sH
EndFunc   ;==>_GetDemoHTML

; ==============================================================================
; COM ERROR HANDLER
; ==============================================================================
Func _ErrFunc($oError)
	; Do anything here.
	ConsoleWrite(@ScriptName & " (" & $oError.scriptline & ") : ==> COM Error intercepted !" & @CRLF & _
			@TAB & "err.number is: " & @TAB & @TAB & "0x" & Hex($oError.number) & @CRLF & _
			@TAB & "err.windescription:" & @TAB & $oError.windescription & @CRLF & _
			@TAB & "err.description is: " & @TAB & $oError.description & @CRLF & _
			@TAB & "err.source is: " & @TAB & @TAB & $oError.source & @CRLF & _
			@TAB & "err.helpfile is: " & @TAB & $oError.helpfile & @CRLF & _
			@TAB & "err.helpcontext is: " & @TAB & $oError.helpcontext & @CRLF & _
			@TAB & "err.lastdllerror is: " & @TAB & $oError.lastdllerror & @CRLF & _
			@TAB & "err.scriptline is: " & @TAB & $oError.scriptline & @CRLF & _
			@TAB & "err.retcode is: " & @TAB & "0x" & Hex($oError.retcode) & @CRLF & @CRLF)
EndFunc   ;==>_ErrFunc
