#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Run_AU3Check=Y
#AutoIt3Wrapper_AU3Check_Stop_OnWarning=y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7

; 003-Multi-Basic.au3

#include <WindowsConstants.au3>
#include <GUIConstantsEx.au3>
#include "..\NetWebView2Lib.au3"

Main()

Func Main()
	; --- Main GUI Setup ---
	Local $hMainGUI = GUICreate("Multi-WebView2 v2.0.0 Standard", 1000, 600, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPCHILDREN))
	GUISetState(@SW_SHOW, $hMainGUI)

	; --- BROWSER 1 ---
	Local $oWeb1, $hCont1, $oBridge1
	_Browser_Setup($hMainGUI, "Web1_", @TempDir & "\User_A", 10, 10, 480, 500, $oWeb1, $hCont1, $oBridge1)

	; --- BROWSER 2 ---
	Local $oWeb2, $hCont2, $oBridge2
	_Browser_Setup($hMainGUI, "Web2_", @TempDir & "\User_B", 510, 10, 480, 500, $oWeb2, $hCont2, $oBridge2)

	; --- Main Loop ---
	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				ExitLoop
		EndSwitch
	WEnd

	; CleanUp
	_NetWebView2_CleanUp($oWeb1)
	_NetWebView2_CleanUp($oWeb2)
EndFunc   ;==>Main


; --- BROWSER 1 ---

; Manager Events
Func Web1_OnMessageReceived($oWebV2M, $hGUI, $sMsg)
	#forceref $hGUI
	ConsoleWrite("+> [Browser 1]: " & (StringLen($sMsg) > 150 ? StringLeft($sMsg, 150) & "..." : $sMsg) & @CRLF)
	If $sMsg = "INIT_READY" Then
		_NetWebView2_ExecuteScript($oWebV2M, 'window.chrome.webview.postMessage(JSON.stringify({ "type": "COM_TEST", "status": "OK" }));')
		_NetWebView2_NavigateToString($oWebV2M, _GetDemoHTML("Browser 1 Content"))
	EndIf
EndFunc   ;==>Web1_OnMessageReceived

; JavaScript Bridge Events
Func Web1_Bridge_OnMessageReceived($oWebV2M, $hGUI, $sMsg)
	Local Static $iMsgCnt = -1
	ConsoleWrite(">> [JS 1]: " & (StringLen($sMsg) > 150 ? StringLeft($sMsg, 150) & "..." : $sMsg) & @CRLF)

	If $sMsg = "CLOSE_APP" Then
		If MsgBox(36, "Confirm", "Close this Browser Instance?", 0, $hGUI) = 6 Then
			$oWebV2M.Cleanup()
			GUIDelete($hGUI)
			ConsoleWrite("!> Browser 1 has been shut down." & @CRLF)
		EndIf
	Else
		$iMsgCnt += 1
		UpdateWebUI($oWebV2M, "mainTitle", "Counter: " & $iMsgCnt)
		UpdateWebUI($oWebV2M, "statusMsg", "Last Message: " & $sMsg)
	EndIf
EndFunc   ;==>Web1_Bridge_OnMessageReceived


; --- BROWSER 2 ---

; Manager Events
Func Web2_OnMessageReceived($oWebV2M, $hGUI, $sMsg)
	#forceref $hGUI
	ConsoleWrite("+> [Browser 2]: " & (StringLen($sMsg) > 150 ? StringLeft($sMsg, 150) & "..." : $sMsg) & @CRLF)
	If $sMsg = "INIT_READY" Then
		_NetWebView2_ExecuteScript($oWebV2M, 'window.chrome.webview.postMessage(JSON.stringify({ "type": "COM_TEST", "status": "OK" }));')
		_NetWebView2_NavigateToString($oWebV2M, _GetDemoHTML("Browser 2 Content"))
	EndIf
EndFunc   ;==>Web2_OnMessageReceived

; JavaScript Bridge Events
Func Web2_Bridge_OnMessageReceived($oWebV2M, $hGUI, $sMsg)
	Local Static $iMsgCnt = -1
	ConsoleWrite(">> [JS 2]: " & (StringLen($sMsg) > 150 ? StringLeft($sMsg, 150) & "..." : $sMsg) & @CRLF)

	If $sMsg = "CLOSE_APP" Then
		If MsgBox(36, "Confirm", "Close this Browser Instance?", 0, $hGUI) = 6 Then
			$oWebV2M.Cleanup()
			GUIDelete($hGUI)
			ConsoleWrite("!> Browser 2 has been shut down." & @CRLF)
		EndIf
	Else
		$iMsgCnt += 1
		UpdateWebUI($oWebV2M, "mainTitle", "Counter: " & $iMsgCnt)
		UpdateWebUI($oWebV2M, "statusMsg", "Last Message: " & $sMsg)
	EndIf
EndFunc   ;==>Web2_Bridge_OnMessageReceived
; ==============================================================================
; UPDATED HELPERS
; ==============================================================================

Func UpdateWebUI($oManager, $sElementId, $sNewText)
	If Not IsObj($oManager) Then Return
	Local $sJS = StringFormat("document.getElementById('%s').innerText = '%s';", $sElementId, $sNewText)
	_NetWebView2_ExecuteScript($oManager, $sJS)
EndFunc   ;==>UpdateWebUI

Func _Browser_Setup($hParent, $sPrefix, $sProfile, $iX, $iY, $iW, $iH, ByRef $oOutWeb, ByRef $hOutCont, ByRef $oOutBridge)
	$hOutCont = GUICreate("", $iW, $iH, $iX, $iY, $WS_CHILD, -1, $hParent)
	GUISetState(@SW_SHOW, $hOutCont)

	$oOutWeb = _NetWebView2_CreateManager("", $sPrefix, "")
	_NetWebView2_Initialize($oOutWeb, $hOutCont, $sProfile, 0, 0, $iW, $iH)

	$oOutBridge = _NetWebView2_GetBridge($oOutWeb, $sPrefix & "Bridge_")
EndFunc   ;==>_Browser_Setup

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
