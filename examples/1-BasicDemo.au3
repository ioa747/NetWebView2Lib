#AutoIt3Wrapper_UseX64=y
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>

#include "..\NetWebView2Lib.au3"

; ==============================================================================
; WebView2 Multi-Channel Presentation Script
; ==============================================================================

; Global objects

; GUI & Controls
Global $hGUI, $idLabelStatus

Main()

Func Main()
	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc)
	#forceref $oMyError

	; Create the UI
	Local $iHeight = 400
	$hGUI = GUICreate("WebView2 .NET Manager - Community Demo", 800, $iHeight)
	$idLabelStatus = GUICtrlCreateLabel("Status: Initializing Engine...", 10, $iHeight -20 , 880, 20)
	GUICtrlSetFont(-1, 9, 400, 0, "Segoe UI")
	GUISetState(@SW_SHOW)

	; Initialize WebView2 Manager and register events
	Local $oWebV2M = _NetWebView2_CreateManager()
	$_g_oWeb = $oWebV2M
	If @error Then Return SetError(@error, @extended, $oWebV2M)

	; Initialize JavaScript Bridge
	Local $oJSBridge = _NetWebView2_GetBridge($oWebV2M, "_BridgeMyEventsHandler_")
	If @error Then Return SetError(@error, @extended, $oWebV2M)

	Local $sProfileDirectory = @TempDir & "\NetWebView2Lib-UserDataFolder"
	_NetWebView2_Initialize($oWebV2M, $hGUI, $sProfileDirectory, 0, 0, 0, 0, True, True, True, 1.2, "0x2B2B2B")

	_NetWebView2_NavigateToString($_g_oWeb, __GetDemoHTML())

	; Main Loop
	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				ExitLoop
		EndSwitch
	WEnd

	GUIDelete($hGUI)

	_NetWebView2_CleanUp($oWebV2M, $oJSBridge)
EndFunc   ;==>Main

; ==============================================================================
; ; Function to update a text element inside the WebView UI
; ==============================================================================
Func UpdateWebUI(ByRef $oWeb, $sElementId, $sNewText)
	If Not IsObj($oWeb) Then Return ''

	; Escape backslashes, single quotes and handle new lines for JavaScript safety
	Local $sCleanText = StringReplace($sNewText, "\", "\\")
	$sCleanText = StringReplace($sCleanText, "'", "\'")
	$sCleanText = StringReplace($sCleanText, @CRLF, "\n")
	$sCleanText = StringReplace($sCleanText, @LF, "\n")

	Local $sJavaScript = "document.getElementById('" & $sElementId & "').innerText = '" & $sCleanText & "';"
	_NetWebView2_ExecuteScript($oWeb, $sJavaScript)
EndFunc   ;==>UpdateWebUI

; ==============================================================================
; MY EVENT HANDLER: Bridge (JavaScript Messages)
; ==============================================================================
Func _BridgeMyEventsHandler_OnMessageReceived($sMessage)
	Local Static $iMsgCnt = 0
	ConsoleWrite(">>> [JS MESSAGE]: " & $sMessage & @CRLF)

	If $sMessage = "CLOSE_APP" Then
		If MsgBox(36, "Confirm", "Exit Application?", 0, $hGUI) = 6 Then Exit
	Else
		MsgBox(64, "JS Notification", "Message from Browser: " & $sMessage)
		$iMsgCnt += 1
		UpdateWebUI($_g_oWeb, "mainTitle", $iMsgCnt & " Hello from AutoIt!")
	EndIf
EndFunc   ;==>_BridgeMyEventsHandler_OnMessageReceived

; ==============================================================================
; HELPER: Demo HTML Content
; ==============================================================================
Func __GetDemoHTML()
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
EndFunc   ;==>__GetDemoHTML
