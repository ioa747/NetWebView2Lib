#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Run_AU3Check=Y
#AutoIt3Wrapper_AU3Check_Stop_OnWarning=y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7

; 003-Multi-Basic.au3

#include <WindowsConstants.au3>
#include <GUIConstantsEx.au3>
#include "..\NetWebView2Lib.au3"

_Main()

Func _Main()
	; --- Main GUI Setup ---
	Local $hMainGUI = GUICreate("Multi-WebView2 v2.0.0 Standard", 1000, 600, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPCHILDREN))
	GUISetState(@SW_SHOW, $hMainGUI)

	ConsoleWrite("! --- BROWSER 1 ---" & @CRLF)
	Local $oWeb_1, $oBridge_1, $h_WebWindow_1, $sEventPrfix_1 = "__UserEventHandler_Web1_", $sProfile_1 = @TempDir & "\User_A", $s_AddBrowserArgs_1 = ""
	_NetWebView2_BrowserSetupWrapper($hMainGUI, $oWeb_1, $sEventPrfix_1, $sProfile_1, $oBridge_1, $h_WebWindow_1, 10, 10, 480, 500, $s_AddBrowserArgs_1)
	ConsoleWrite("! $h_WebWindow_1 = " & $h_WebWindow_1 & @CRLF)
	ConsoleWrite("! BrowserWindowHandle = " & $oWeb_1.BrowserWindowHandle & @CRLF)
	_NetWebView2_NavigateToString($oWeb_1, _GetDemoHTML("Browser 1 Content"))

	ConsoleWrite("! --- BROWSER 2 ---" & @CRLF)
	Local $oWeb_2, $oBridge_2, $h_WebWindow_2, $sEventPrfix_2 = "__UserEventHandler_Web2_", $sProfile_2 = @TempDir & "\User_B", $s_AddBrowserArgs_2 = ""
	_NetWebView2_BrowserSetupWrapper($hMainGUI, $oWeb_2, $sEventPrfix_2, $sProfile_2, $oBridge_2, $h_WebWindow_2, 510, 10, 480, 500, $s_AddBrowserArgs_2)
	ConsoleWrite("! $h_WebWindow_2 = " & $h_WebWindow_2 & @CRLF)
	ConsoleWrite("! BrowserWindowHandle = " & $oWeb_2.BrowserWindowHandle & @CRLF)
	_NetWebView2_NavigateToString($oWeb_2, _GetDemoHTML("Browser 2 Content"))

	; --- Main Loop ---
	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				ExitLoop
		EndSwitch
	WEnd

	; CleanUp
	_NetWebView2_CleanUp($oWeb_1, $oBridge_1)
;~ 	_NetWebView2_CleanUp($oWeb_2, $oBridge_2)
EndFunc   ;==>_Main

; ==============================================================================
; UPDATED HELPERS
; ==============================================================================

Func _UpdateWebUI($oManager, $sElementId, $sNewText)
	If Not IsObj($oManager) Then Return
	Local $sJS = StringFormat("document.getElementById('%s').innerText = '%s';", $sElementId, $sNewText)
	_NetWebView2_ExecuteScript($oManager, $sJS, $NETWEBVIEW2_EXECUTEJS_MODE0_FIREANDFORGET)
EndFunc   ;==>_UpdateWebUI

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

#Region ; USER DEFINED EVENTS HANDLER FUNCTION
; BROWSER 1 - Manager Events
Func __UserEventHandler_Web1__Manager__OnMessageReceived($oWebView, $hWindow, $sMsg)
	#forceref $hWindow
	ConsoleWrite(">> [Browser 1]: " & (StringLen($sMsg) > 150 ? StringLeft($sMsg, 150) & "..." : $sMsg) & @CRLF)
	If $sMsg = "INIT_READY" Then
		_NetWebView2_ExecuteScript($oWebView, 'window.chrome.webview.postMessage(JSON.stringify({ "type": "COM_TEST", "status": "OK" }));', $NETWEBVIEW2_EXECUTEJS_MODE0_FIREANDFORGET)
	EndIf
EndFunc   ;==>__UserEventHandler_Web1__Manager__OnMessageReceived

; BROWSER 1 - JavaScript Bridge Events
Func __UserEventHandler_Web1__Bridge__OnMessageReceived($oWebView, $hWindow, $sMsg)
	Local Static $iMsgCnt = -1
	ConsoleWrite(">> [JS 1]: " & (StringLen($sMsg) > 150 ? StringLeft($sMsg, 150) & "..." : $sMsg) & @CRLF)

	If $sMsg = "CLOSE_APP" Then
		If MsgBox(36, "Confirm", "Close this Browser Instance?", 0, $hWindow) = 6 Then
			$oWebView.Cleanup()
			GUIDelete($hWindow)
			ConsoleWrite("!> Browser 1 has been shut down." & @CRLF)
		EndIf
	Else
		$iMsgCnt += 1
		_UpdateWebUI($oWebView, "mainTitle", "Counter: " & $iMsgCnt)
		_UpdateWebUI($oWebView, "statusMsg", "Last Message: " & $sMsg)
		If $sMsg = "PING" Then
			GUISetState(@SW_HIDE, $hWindow)
			Sleep(200)
			GUISetState(@SW_SHOW, $hWindow)
		EndIf
	EndIf
EndFunc   ;==>__UserEventHandler_Web1__Bridge__OnMessageReceived

; BROWSER 2 - Manager Events
Func __UserEventHandler_Web2__Manager__OnMessageReceived($oWebView, $hWindow, $sMsg)
	#forceref $hWindow
	ConsoleWrite(">> [Browser 2]: " & (StringLen($sMsg) > 150 ? StringLeft($sMsg, 150) & "..." : $sMsg) & @CRLF)
	If $sMsg = "INIT_READY" Then
		_NetWebView2_ExecuteScript($oWebView, 'window.chrome.webview.postMessage(JSON.stringify({ "type": "COM_TEST", "status": "OK" }));', $NETWEBVIEW2_EXECUTEJS_MODE0_FIREANDFORGET)
	EndIf
EndFunc   ;==>__UserEventHandler_Web2__Manager__OnMessageReceived

; BROWSER 2 - JavaScript Bridge Events
Func __UserEventHandler_Web2__Bridge__OnMessageReceived($oWebView, $hWindow, $sMsg)
	Local Static $iMsgCnt = -1
	ConsoleWrite(">> [JS 2]: " & (StringLen($sMsg) > 150 ? StringLeft($sMsg, 150) & "..." : $sMsg) & @CRLF)

	If $sMsg = "CLOSE_APP" Then
		If MsgBox(36, "Confirm", "Close this Browser Instance?", 0, $hWindow) = 6 Then
			$oWebView.Cleanup()
			GUIDelete($hWindow)
			ConsoleWrite("!> Browser 2 has been shut down." & @CRLF)
		EndIf
	Else
		$iMsgCnt += 1
		_UpdateWebUI($oWebView, "mainTitle", "Counter: " & $iMsgCnt)
		_UpdateWebUI($oWebView, "statusMsg", "Last Message: " & $sMsg)
		If $sMsg = "PING" Then
			GUISetState(@SW_HIDE, $hWindow)
			Sleep(200)
			GUISetState(@SW_SHOW, $hWindow)
		EndIf
	EndIf
EndFunc   ;==>__UserEventHandler_Web2__Bridge__OnMessageReceived
#EndRegion ; USER DEFINED EVENTS HANDLER FUNCTION
