#AutoIt3Wrapper_UseX64=y
#include <WindowsConstants.au3>
#include <GUIConstantsEx.au3>

; --- Main GUI Setup ---
$hMainGUI = GUICreate("Multi-WebView2 v1.3.0 Demo", 1000, 600, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPCHILDREN))
GUISetState(@SW_SHOW, $hMainGUI)

; --- Create Browser Instance 1 ---
; Prefix: Web1_ | Data Folder: \User_A
Global $aBrowser1 = _WebView2_Create($hMainGUI, "Web1_", @ScriptDir & "\User_A", 10, 10, 480, 500)
Global $oWeb1 = $aBrowser1[0]
Global $hCont1 = $aBrowser1[1]

; --- Create Browser Instance 2 ---
; Prefix: Web2_ | Data Folder: \User_B
Global $aBrowser2 = _WebView2_Create($hMainGUI, "Web2_", @ScriptDir & "\User_B", 510, 10, 480, 500)
Global $oWeb2 = $aBrowser2[0]
Global $hCont2 = $aBrowser2[1]

; --- Main Message Loop ---
While 1
	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE
			ExitLoop
	EndSwitch
WEnd

$oWeb1.Cleanup()
$oWeb2.Cleanup()

; ==============================================================================
; BROWSER 1 EVENTS
; ==============================================================================

; Manager Events (Status, Navigation, Errors)
Func Web1_OnMessageReceived($sMsg)
	ConsoleWrite("+> [Browser 1]: " & $sMsg & @CRLF)
	If $sMsg = "INIT_READY" Then
		$oWeb1.ExecuteScript('window.chrome.webview.postMessage(JSON.stringify({ "type": "COM_TEST", "status": "OK" }));')
		$oWeb1.NavigateToString(_GetDemoHTML("Browser 1 Content"))
	EndIf
EndFunc   ;==>Web1_OnMessageReceived

; JavaScript Bridge Events (Messages from JS to AutoIt)
Func Web1_Bridge_OnMessageReceived($sMsg)
	Local Static $iMsgCnt = -1
	ConsoleWrite(">> [JS 1]: " & $sMsg & @CRLF)

	If $sMsg = "CLOSE_APP" Then
		If MsgBox(36, "Confirm", "Close this Browser Instance?", 0, $hMainGUI) = 6 Then
			$oWeb1.Cleanup()
			GUIDelete($hCont1)
			ConsoleWrite("!> Browser 1 has been shut down." & @CRLF)
		EndIf
	Else
		$iMsgCnt += 1
		UpdateWebUI($oWeb1, "mainTitle", "Counter: " & $iMsgCnt)
		UpdateWebUI($oWeb1, "statusMsg", "Last Message: " & $sMsg)
	EndIf
EndFunc   ;==>Web1_Bridge_OnMessageReceived

; ==============================================================================
; BROWSER 2 EVENTS
; ==============================================================================

; Manager Events
Func Web2_OnMessageReceived($sMsg)
	ConsoleWrite("+> [Browser 2]: " & $sMsg & @CRLF)
	If $sMsg = "INIT_READY" Then
		$oWeb2.ExecuteScript('window.chrome.webview.postMessage(JSON.stringify({ "type": "COM_TEST", "status": "OK" }));')
		$oWeb2.NavigateToString(_GetDemoHTML("Browser 2 Content"))
	EndIf
EndFunc   ;==>Web2_OnMessageReceived

; JavaScript Bridge Events
Func Web2_Bridge_OnMessageReceived($sMsg)
	Local Static $iMsgCnt = -1
	ConsoleWrite(">> [JS 2]: " & $sMsg & @CRLF)

	If $sMsg = "CLOSE_APP" Then
		If MsgBox(36, "Confirm", "Close this Browser Instance?", 0, $hMainGUI) = 6 Then
			$oWeb2.Cleanup()
			GUIDelete($hCont2)
			ConsoleWrite("!> Browser 2 has been shut down." & @CRLF)
		EndIf
	Else
		$iMsgCnt += 1
		UpdateWebUI($oWeb2, "mainTitle", "Counter: " & $iMsgCnt)
		UpdateWebUI($oWeb2, "statusMsg", "Last Message: " & $sMsg)
	EndIf
EndFunc   ;==>Web2_Bridge_OnMessageReceived

; ==============================================================================
; UI HELPERS
; ==============================================================================

Func UpdateWebUI(ByRef $oManager, $sElementId, $sNewText)
	; Escape characters for JS safety
	Local $sClean = StringReplace($sNewText, "\", "\\")
	$sClean = StringReplace($sClean, "'", "\'")

	Local $sJS = "document.getElementById('" & $sElementId & "').innerText = '" & $sClean & "';"
	If IsObj($oManager) Then $oManager.ExecuteScript($sJS)
EndFunc   ;==>UpdateWebUI

Func _GetDemoHTML($sTitle)
	Return '<html><title>Simple GUI</title><head><style>' & _
			'body { font-family: "Segoe UI", sans-serif; background: #1a1a1a; color: white; padding: 20px; text-align: center; }' & _
			'.card { background: #2d2d2d; padding: 20px; border-radius: 12px; border: 1px solid #444; box-shadow: 0 4px 8px rgba(0,0,0,0.5); }' & _
			'button { padding: 10px 20px; cursor: pointer; background: #0078d4; color: white; border: none; border-radius: 5px; margin: 10px 5px; }' & _
			'button:hover { background: #005a9e; }' & _
			'h1 { color: #60cdff; }' & _
			'</style></head><body>' & _
			'<div class="card">' & _
			'  <h1>' & $sTitle & '</h1>' & _
			'  <h2 id="mainTitle">Waiting...</h2>' & _
			'  <p id="statusMsg">Ready for communication.</p>' & _
			'  <button onclick="window.chrome.webview.postMessage(''PING'')">Send Ping</button>' & _
			'  <button onclick="window.chrome.webview.postMessage(''CLOSE_APP'')">Exit</button>' & _
			'</div></body></html>'
EndFunc   ;==>_GetDemoHTML

; ==============================================================================
; UDF: _WebView2_Create
; ==============================================================================
Func _WebView2_Create($hParent, $sPrefix, $sProfilePath, $iX, $iY, $iW, $iH)
	Local $aResult[3]

	; 1. Create a child GUI as a container for the WebView
	Local $hContainer = GUICreate("", $iW, $iH, $iX, $iY, $WS_CHILD, -1, $hParent)
	GUISetState(@SW_SHOW, $hContainer)
	$aResult[1] = $hContainer

	; 2. Instantiate and Initialize the .NET Manager
	Local $oManager = ObjCreate("NetWebView2.Manager")
	If Not IsObj($oManager) Then Return SetError(1, 0, 0)

	; Link Manager Events (Prefix + OnMessageReceived)
	ObjEvent($oManager, $sPrefix, "IWebViewEvents")
	$oManager.Initialize($hContainer, $sProfilePath, 0, 0, $iW, $iH)
	$aResult[0] = $oManager

	; 3. Link the JavaScript Bridge (Prefix + Bridge_OnMessageReceived)
	Local $oBridge = $oManager.GetBridge()
	ObjEvent($oBridge, $sPrefix & "Bridge_", "IBridgeEvents")
	$aResult[2] = $oBridge

	Return $aResult
EndFunc   ;==>_WebView2_Create
