#WIP - this Example is imported from 1.5.0 UDF - and is in "WORK IN PROGRESS" state
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Run_AU3Check=Y
#AutoIt3Wrapper_AU3Check_Stop_OnWarning=y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7

; 018-BasicFramesDemo.au3

#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include "..\NetWebView2Lib.au3"

Main()

Func Main()
	ConsoleWrite("! MicrosoftEdgeWebview2 : version check: " & _NetWebView2_IsAlreadyInstalled() & ' ERR=' & @error & ' EXT=' & @extended & @CRLF)

	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc)
	#forceref $oMyError

	; Create the UI
	Local $iHeight = 800
	Local $hGUI = GUICreate("WebView2 .NET Manager - Community Demo", 1100, $iHeight)
	GUICtrlSetFont(-1, 9, 400, 0, "Segoe UI")

	WinMove($hGUI, '', Default, Default, 800, 440)
	GUISetState(@SW_SHOW, $hGUI)

	; Initialize WebView2 Manager and register events
	Local $oWebV2M = _NetWebView2_CreateManager("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0", _
			"MyHook_", "--disable-gpu, --mute-audio")
	If @error Then Return SetError(@error, @extended, $oWebV2M)

	; Initialize JavaScript Bridge
	Local $oJSBridge = _NetWebView2_GetBridge($oWebV2M, "_BridgeMyEventsHandler_")
	If @error Then Return SetError(@error, @extended, $oWebV2M)

	Local $sProfileDirectory = @ScriptDir & "\NetWebView2Lib-UserDataFolder"
	_NetWebView2_Initialize($oWebV2M, $hGUI, $sProfileDirectory, 0, 0, 0, 0, True, True, 1.2, "0x2B2B2B", False)
	If @error Then Return SetError(@error, @extended, $oWebV2M)

	__Example_Log(@ScriptLineNumber, "After: _NetWebView2_Initialize()" & @CRLF)

	; navigate to HTML string - full fill the object with your own offline content - without downloading any content
	ConsoleWrite(@CRLF)

	__Example_Log(@ScriptLineNumber, "Before: _NetWebView2_NavigateToString()")
	GUISetState(@SW_SHOW, $hGUI)
	WinMove($hGUI, '', Default, Default, 1100, 800)

	#COMMENT This example is based on ==> ;	https://github.com/Danp2/au3WebDriver/blob/1834e95206bd4a6ef6952c47a1f1192042f98c0b/wd_demo.au3#L588-L732
	#Region - Testing how to manage frames

	_NetWebView2_Navigate($oWebV2M, 'https://www.w3schools.com/tags/tryit.asp?filename=tryhtml_iframe', $NETWEBVIEW2_MESSAGE__TITLE_CHANGED, "", 5000)
	MsgBox($MB_TOPMOST, "TEST #" & @ScriptLineNumber, 1)
;~ 	_Demo_NavigateCheckBanner($sSession, "https://www.w3schools.com/tags/tryit.asp?filename=tryhtml_iframe", '//*[@id="snigel-cmp-framework" and @class="snigel-cmp-framework"]')
	If @error Then Return SetError(@error, @extended)

	#Region ; Example part 1 - testing NetWebView2Lib new methodes: .GetFrameCount() .GetFrameUrl($IDX_Frame) .GetFrameName($IDX_Frame)
	ConsoleWrite("+ Example part 1 - testing NetWebView2Lib new methodes: .GetFrameCount() .GetFrameUrl($IDX_Frame) .GetFrameName($IDX_Frame)" & @CRLF)

	Local $iFrameCount = $oWebV2M.GetFrameCount()
	ConsoleWrite(@CRLF)
	ConsoleWrite("! " & @ScriptLineNumber & " : Frames=" & $iFrameCount & @CRLF)
	For $IDX_Frame = 0 To $iFrameCount - 1
		ConsoleWrite("- IDX=" & $IDX_Frame & @CRLF)
		ConsoleWrite("- URL=" & $oWebV2M.GetFrameUrl($IDX_Frame) & @CRLF)
		ConsoleWrite("- NAME=" & $oWebV2M.GetFrameName($IDX_Frame) & @CRLF)
		ConsoleWrite(@CRLF)
	Next
	#EndRegion ; Example part 1 - testing NetWebView2Lib new methodes: .GetFrameCount() .GetFrameUrl($IDX_Frame) .GetFrameName($IDX_Frame)

	#Region ; Example part 2 - testing NetWebView2Lib new methodes: .GetFrameCount() .GetFrameUrl($IDX_Frame) .GetFrameName($IDX_Frame)
	ConsoleWrite("+ Example part 2 - testing NetWebView2Lib new methodes: .GetFrameCount() .GetFrameUrl($IDX_Frame) .GetFrameName($IDX_Frame)" & @CRLF)

	ConsoleWrite("! " & @ScriptLineNumber & " : GetFrameUrls() :" & @CRLF & $oWebV2M.GetFrameUrls() & @CRLF)
	ConsoleWrite("! " & @ScriptLineNumber & " : GetFrameNames() :" & @CRLF & $oWebV2M.GetFrameNames() & @CRLF)
	#EndRegion ; Example part 2 - testing NetWebView2Lib new methodes: .GetFrameCount() .GetFrameUrl($IDX_Frame) .GetFrameName($IDX_Frame)

	#Region ; Example part 3 - testing NetWebView2Lib new methodes .GetFrameHtmlSource($IDX_Frame)
	ConsoleWrite("+ Example part 3 - testing NetWebView2Lib new methodes .GetFrameHtmlSource($IDX_Frame)" & @CRLF)
	For $IDX_Frame = 0 To $iFrameCount - 1
		ConsoleWrite(@CRLF & "======================================================" & @CRLF)
		Local $sHtmlSource = Fire_And_Wait($oWebV2M.GetFrameHtmlSource($IDX_Frame), 5000) ; pair with "FRAME_HTML_SOURCE"
		ConsoleWrite("! " & @ScriptLineNumber & " : GetFrameHtmlSource(" & $IDX_Frame & ") :" & @CRLF & $sHtmlSource & @CRLF)
	Next
	ConsoleWrite(@CRLF & "======================================================" & @CRLF)
	ConsoleWrite(@CRLF)
	ConsoleWrite(@CRLF)
	#EndRegion ; Example part 3 - testing NetWebView2Lib new methodes .GetFrameHtmlSource($IDX_Frame)


	#Region ; Example part 4 - Direct Frame Interaction

	#cs NOT SUPPORTED YET
		Local $oFrame0 = $oWebV2M.GetFrame(0)
		Local $oFrame1 = $oWebV2M.GetFrame(1)
		Local $oFrame2 = $oWebV2M.GetFrame(2)
		Local $oFrame3 = $oWebV2M.GetFrame(3)
	#CE NOT SUPPORTED YET

	Local $oFrame0 = $oWebV2M.GetFrame(0)

	ConsoleWrite("+ Example part 4 - Direct Frame Interaction via COM Object" & @CRLF)
	If IsObj($oFrame0) Then

		ConsoleWrite("VarGetType($oFrame0)=" & VarGetType($oFrame0) & @CRLF)
		ConsoleWrite("$oFrame0.Name=" & $oFrame0.Name & @CRLF & @CRLF)

		; Direct script execution in the iframe without involving the central Manager
		$oFrame0.ExecuteScript("document.body.style.backgroundColor = 'red';")
		ConsoleWrite("> Executed background color change on Frame(0)" & @CRLF)

		; Try getting the URL via JS
		Local $sUrl = $oFrame0.ExecuteScriptWithResult("window.location.href")
		ConsoleWrite("> Frame(0) URL via JS: " & $sUrl & @CRLF)

	Else
		ConsoleWrite("! Error: $oFrame0 is not a valid COM Object" & @CRLF)
	EndIf

	#EndRegion ; Example part 4 - Direct Frame Interaction


	#EndRegion - Testing how to manage frames


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
Func UpdateWebUI($oWebV2M, $sElementId, $sNewText)
	If Not IsObj($oWebV2M) Then Return ''

	; Escape backslashes, single quotes and handle new lines for JavaScript safety
	Local $sCleanText = StringReplace($sNewText, "\", "\\")
	$sCleanText = StringReplace($sCleanText, "'", "\'")
	$sCleanText = StringReplace($sCleanText, @CRLF, "\n")
	$sCleanText = StringReplace($sCleanText, @LF, "\n")

	Local $sJavaScript = "document.getElementById('" & $sElementId & "').innerText = '" & $sCleanText & "';"
	_NetWebView2_ExecuteScript($oWebV2M, $sJavaScript)
EndFunc   ;==>UpdateWebUI

; ==============================================================================
; MY EVENT HANDLER: Bridge (JavaScript Messages)
; ==============================================================================
Func _BridgeMyEventsHandler_OnMessageReceived($oWebV2M, $hGUI, $sMessage)
	Local Static $iMsgCnt = 0

	If $sMessage = "CLOSE_APP" Then
		If MsgBox(36, "Confirm", "Exit Application?", 0, $hGUI) = 6 Then Exit
	Else
		MsgBox(64, "JS Notification", "Message from Browser: " & $sMessage)
		$iMsgCnt += 1
		UpdateWebUI($oWebV2M, "mainTitle", $iMsgCnt & " Hello from AutoIt!")
	EndIf
EndFunc   ;==>_BridgeMyEventsHandler_OnMessageReceived

; ==============================================================================
; MyHook_ Events
; ==============================================================================
Func MyHook_OnMessageReceived($oWebV2M, $hGUI, $sMsg)
	#forceref $oWebV2M, $hGUI, $sMsg
	ConsoleWrite("> [MyHook] OnMessageReceived: GUI:" & $hGUI & " Msg: " & (StringLen($sMsg) > 30 ? StringLeft($sMsg, 30) & "..." : $sMsg) & @CRLF)
	Local $iSplitPos = StringInStr($sMsg, "|")
	Local $sCommand = $iSplitPos ? StringStripWS(StringLeft($sMsg, $iSplitPos - 1), 3) : $sMsg
	Local $sData = $iSplitPos ? StringTrimLeft($sMsg, $iSplitPos) : ""
;~ 	Local $aParts

	Switch $sCommand
		Case "INIT_READY"

		Case "FRAME_HTML_SOURCE"
			$iSplitPos = StringInStr($sData, "|")
			Local $sIDX = StringLeft($sData, $iSplitPos - 1)
			ConsoleWrite(" >> $sIDX=" & $sIDX & @CRLF)
			Local $sHtmlSource = StringTrimLeft($sData, $iSplitPos)
			If $sHtmlSource = "null" Then $sHtmlSource = "!! <Inaccessible>"
			Fire_And_Wait($sHtmlSource)
	EndSwitch
EndFunc   ;==>MyHook_OnMessageReceived

; ==============================================================================
; HELPER: Demo HTML Content
; ==============================================================================
Func __GetDemoHTML()
	Local $sH = _
			'<html><head><style>' & _
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

Func __Example_Log($s_ScriptLineNumber, $sString, $iError = @error, $iExtended = @extended)
	ConsoleWrite(@ScriptName & ' SLN=' & $s_ScriptLineNumber & ' [' & $iError & '/' & $iExtended & '] ::: ' & $sString & @CRLF)
	Return SetError($iError, $iExtended, '')
EndFunc   ;==>__Example_Log

; #FUNCTION# ====================================================================================================================
; Name...........: Fire_And_Wait
; Description....: Synchronizes asynchronous events by waiting for a response or a timeout.
; Syntax.........: Fire_And_Wait([$sData = "" [, $iTimeout = 5000]])
; Parameters.....: $sData     - [Optional] Data string.
;                               If provided: Acts as a "Signal" (setter) from the Event Handler.
;                               If empty: Acts as a "Listener" (getter) from the Main Script.
;                  $iTimeout  - [Optional] Maximum wait time in milliseconds (Default is 5000ms).
; Return values..: Success    - Returns the stored data string.
;                               Sets @extended to the duration of the wait in ms.
;                  Failure    - Returns an empty string and sets @error:
;                               |1 - Timeout reached.
; Author.........: YourName
; Modified.......: 2026-02-23
; Remarks........: This function uses static variables to bridge the gap between async COM events and sync script execution.
;                  It effectively pauses the script execution until the WebView2 event fires back with data.
; ===============================================================================================================================
Func Fire_And_Wait($sData = "", $iTimeout = 5000)
	Local Static $vStoredData = ""
	Local Static $hJobTimer = 0

	; === Part A: Response (From Event Handler) ===
	If $sData <> "" Then
		$vStoredData = $sData
		Return True
	EndIf

	; === Part B: Fire and Wait (From Main Script) ===
	$vStoredData = ""
	$hJobTimer = TimerInit()

	While $vStoredData = ""
		If TimerDiff($hJobTimer) > $iTimeout Then
			ConsoleWrite("! Fire_And_Wait | TIMEOUT after " & Round(TimerDiff($hJobTimer), 2) & " ms" & @CRLF)
			Return SetError(1, 0, "")
		EndIf
		Sleep(10)
	WEnd

	Local $fDuration = TimerDiff($hJobTimer)
	Local $vResult = $vStoredData
	$vStoredData = "" ; Reset for next use

	ConsoleWrite("> Fire_And_Wait | Duration: " & Round($fDuration, 0) & " ms | Status: SUCCESS" & @CRLF)

	Return SetError(0, Int($fDuration), $vResult)
EndFunc   ;==>Fire_And_Wait
