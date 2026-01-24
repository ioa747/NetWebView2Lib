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
	Local $iHeight = 800
	$hGUI = GUICreate("WebView2 .NET Manager - Community Demo", 1100, $iHeight)
	$idLabelStatus = GUICtrlCreateLabel("Status: Initializing Engine...", 10, $iHeight - 20, 880, 20)
	GUICtrlSetFont(-1, 9, 400, 0, "Segoe UI")

	WinMove($hGUI, '', Default, Default, 800, 440)
	GUISetState(@SW_SHOW, $hGUI)

	; Initialize WebView2 Manager and register events
	Local $oWebV2M = _NetWebView2_CreateManager("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0", "", "--disable-gpu, --mute-audio")
	$_g_oWeb = $oWebV2M
	If @error Then Return SetError(@error, @extended, $oWebV2M)

	; Initialize JavaScript Bridge
	Local $oJSBridge = _NetWebView2_GetBridge($oWebV2M, "_BridgeMyEventsHandler_")
	If @error Then Return SetError(@error, @extended, $oWebV2M)

	Local $sProfileDirectory = @TempDir & "\NetWebView2Lib-UserDataFolder"
	_NetWebView2_Initialize($oWebV2M, $hGUI, $sProfileDirectory, 0, 0, 0, 0, True, True, True, 1.2, "0x2B2B2B")
	__NetWebView2_Log(@ScriptLineNumber, "After: _NetWebView2_Initialize()", 1)

	; navigate to HTML string - full fill the object with your own offline content - without downloading content
	_NetWebView2_NavigateToString($_g_oWeb, __GetDemoHTML())

	MsgBox($MB_TOPMOST, "TEST #" & @ScriptLineNumber, 'Watch Point')

	WinMove($hGUI, '', Default, Default, 1100, 800)
	GUISetState(@SW_HIDE, $hGUI)

	; navigate to a given URL - downloading online content
	_NetWebView2_Navigate($_g_oWeb, 'https://www.microsoft.com', $NETWEBVIEW2_MESSAGE__TITLE_CHANGED, 5*1000)
	GUISetState(@SW_SHOW, $hGUI)

	MsgBox($MB_TOPMOST, "TEST #" & @ScriptLineNumber, 'Watch Point')
	; navigate to fake/broken url
;~ 	_NetWebView2_Navigate($oWebV2M, 'htpppps://www.microsoft.com', $NETWEBVIEW2_MESSAGE__COMPLETED)

	MsgBox($MB_TOPMOST, "TEST #" & @ScriptLineNumber, 'Watch Point')
	; navigate to fake/broken url
;~ 	_NetWebView2_Navigate($oWebV2M, 'https://w2ww.microsoft.com', $NETWEBVIEW2_MESSAGE__COMPLETED, 100)
;~ 	__NetWebView2_Log(@ScriptLineNumber, "After: https://w2ww.microsoft.com", 1)

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
