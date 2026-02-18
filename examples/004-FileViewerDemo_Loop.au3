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
	Local $oWebV2M = _NetWebView2_CreateManager("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0", "", "--disable-gpu, --mute-audio")
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
		ConsoleWrite("! " & @ScriptLineNumber & " : GetFrameHtmlSource(" & $IDX_Frame & ") :" & @CRLF & $oWebV2M.GetFrameHtmlSource($IDX_Frame) & @CRLF)
	Next
	ConsoleWrite(@CRLF & "======================================================" & @CRLF)
	ConsoleWrite(@CRLF)
	ConsoleWrite(@CRLF)
	#EndRegion ; Example part 3 - testing NetWebView2Lib new methodes .GetFrameHtmlSource($IDX_Frame)


#cs NOT SUPPORTED YET
	Local $oFrame0 = $oWebV2M.GetFrame(0)
	Local $oFrame1 = $oWebV2M.GetFrame(1)
	Local $oFrame2 = $oWebV2M.GetFrame(2)
	Local $oFrame3 = $oWebV2M.GetFrame(3)
#CE NOT SUPPORTED YET


#CS
	; just after navigate current context should be on top level Window
	ConsoleWrite("wd_demo.au3: (" & @ScriptLineNumber & ") : TopWindow = " & $bIsWindowTop & @CRLF)

	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//iframe[@id='iframeResult']")
	; changing context to first frame
	_WD_FrameEnter($sSession, $sElement)
	If @error Then Return SetError(@error, @extended)

	$bIsWindowTop = _WD_IsWindowTop($sSession)
	; after changing context to first frame the current context is not on top level Window
	ConsoleWrite("wd_demo.au3: (" & @ScriptLineNumber & ") : TopWindow = " & $bIsWindowTop & @CRLF)

	; changing context to first sub frame using iframe element specified ByXPath
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//iframe")
	_WD_FrameEnter($sSession, $sElement)
	If @error Then Return SetError(@error, @extended)

	; Leaving sub frame
	_WD_FrameLeave($sSession)
	If @error Then Return SetError(@error, @extended)

	$bIsWindowTop = _WD_IsWindowTop($sSession)
	; after leaving sub frame, the current context is back to first frame but still is not on top level Window
	ConsoleWrite("wd_demo.au3: (" & @ScriptLineNumber & ") : TopWindow = " & $bIsWindowTop & @CRLF)

	; Leaving first frame
	_WD_FrameLeave($sSession)
	If @error Then Return SetError(@error, @extended)
#CE

	#EndRegion - Testing how to manage frames

#CS

	#Region - Testing _WD_FrameList() usage

	#Region - Example 1 ; from 'https://www.w3schools.com' get frame list as string
	$bIsWindowTop = _WD_IsWindowTop($sSession)
	; after leaving first frame, the current context should back on top level Window
	ConsoleWrite("wd_demo.au3: (" & @ScriptLineNumber & ") : TopWindow = " & $bIsWindowTop & @CRLF)

	; now lets try to check frame list and using locations as path 'null/0'
	; firstly go to website
	_WD_Navigate($sSession, 'https://www.w3schools.com/tags/tryit.asp?filename=tryhtml_iframe')
	_WD_LoadWait($sSession)

	Local $sResult = _WD_FrameList($sSession, False)
	ConsoleWrite("! ---> @error=" & @error & "  @extended=" & @extended & " : Example 1" & @CRLF)
	ConsoleWrite($sResult & @CRLF)
	#EndRegion - Example 1 ; from 'https://www.w3schools.com' get frame list as string

	#Region - Example 2 ; from 'https://www.w3schools.com' get frame list as array
	Local $aFrameList = _WD_FrameList($sSession, True)
	ConsoleWrite("! ---> @error=" & @error & "  @extended=" & @extended & " : Example 2" & @CRLF)
	_ArrayDisplay($aFrameList, 'Example 2 - w3schools.com - get frame list as array', 0, 0, Default, $sArrayHeader)

	#EndRegion - Example 2 ; from 'https://www.w3schools.com' get frame list as array

	#Region - Example 3 ; from 'https://www.w3schools.com' get frame list as array, while current location is "null/0"
	; check if document context location is Top Window - should be as we are after navigation
	ConsoleWrite("> " & @ScriptLineNumber & " IsWindowTop = " & _WD_IsWindowTop($sSession) & @CRLF)

	; change document context location by path 'null/0'
	_WD_FrameEnter($sSession, 'null/0')

	; check if document context location is Top Window - should not be as we enter to frame 'null/0'
	ConsoleWrite("> " & @ScriptLineNumber & " IsWindowTop = " & _WD_IsWindowTop($sSession) & @CRLF)

	$aFrameList = _WD_FrameList($sSession, True)
	ConsoleWrite("! ---> @error=" & @error & "  @extended=" & @extended & " : Example 3" & @CRLF)
	_ArrayDisplay($aFrameList, 'Example 3 - w3schools.com - relative to "null/0"', 0, 0, Default, $sArrayHeader)
	#EndRegion - Example 3 ; from 'https://www.w3schools.com' get frame list as array, while current location is "null/0"

	#Region - Example 4 ; from 'https://stackoverflow.com' get frame list as string
	; go to another website
	_WD_Navigate($sSession, 'https://stackoverflow.com/questions/19669786/check-if-element-is-visible-in-dom')
	_WD_LoadWait($sSession)

	$sResult = _WD_FrameList($sSession, False)
	ConsoleWrite("! ---> @error=" & @error & "  @extended=" & @extended & " : Example 4" & @CRLF)
	ConsoleWrite($sResult & @CRLF)
	#EndRegion - Example 4 ; from 'https://stackoverflow.com' get frame list as string

	#Region - Example 5 ; from 'https://stackoverflow.com' get frame list as array
	$aFrameList = _WD_FrameList($sSession, True)
	ConsoleWrite("! ---> @error=" & @error & "  @extended=" & @extended & " : Example 5" & @CRLF)
	_ArrayDisplay($aFrameList, 'Example 5 - stackoverflow.com - get frame list as array', 0, 0, Default, $sArrayHeader)
	#EndRegion - Example 5 ; from 'https://stackoverflow.com' get frame list as array

	#Region - Example 6v1 ; from 'https://stackoverflow.com' get frame list as array, while is current location is "null/2"
	; check if document context location is Top Window - should be as we are after navigation
	ConsoleWrite("> " & @ScriptLineNumber & " IsWindowTop = " & _WD_IsWindowTop($sSession) & @CRLF)

	; change document context location by path 'null/2'
	_WD_FrameEnter($sSession, 'null/2')

	; check if document context location is Top Window - should not be as we enter to frame 'null/2'
	ConsoleWrite("> " & @ScriptLineNumber & " IsWindowTop = " & _WD_IsWindowTop($sSession) & @CRLF)

	$aFrameList = _WD_FrameList($sSession, True)
	ConsoleWrite("! ---> @error=" & @error & "  @extended=" & @extended & " : Example 6v1" & @CRLF)
	_ArrayDisplay($aFrameList, 'Example 6v1 - stackoverflow.com - relative to "null/2"', 0, 0, Default, $sArrayHeader)
	#EndRegion - Example 6v1 ; from 'https://stackoverflow.com' get frame list as array, while is current location is "null/2"

	#Region - Example 6v2 ; from 'https://stackoverflow.com' get frame list as array, check if it is still relative to the same location as it was before recent _WD_FrameList() was used - still should be "null/2"
	; check if document context location is Top Window
	ConsoleWrite("> " & @ScriptLineNumber & " IsWindowTop = " & _WD_IsWindowTop($sSession) & @CRLF)

	$aFrameList = _WD_FrameList($sSession, True)
	ConsoleWrite("! ---> @error=" & @error & "  @extended=" & @extended & " : Example 6v2" & @CRLF)
	_ArrayDisplay($aFrameList, 'Example 6v2 - stackoverflow.com - check if it is still relative to "null/2"', 0, 0, Default, $sArrayHeader)
	#EndRegion - Example 6v2 ; from 'https://stackoverflow.com' get frame list as array, check if it is still relative to the same location as it was before recent _WD_FrameList() was used - still should be "null/2"

	#EndRegion - Testing _WD_FrameList() usage

	#Region - Testing element location in frame set and iframe collecion
	; go to website
	_WD_Navigate($sSession, 'https://www.tutorialspoint.com/html/html_frames.htm#')
	_WD_LoadWait($sSession)

	; check if document context location is Top Window
	ConsoleWrite("> " & @ScriptLineNumber & " IsWindowTop = " & _WD_IsWindowTop($sSession) & @CRLF)

	MsgBox($MB_TOPMOST, "", 'Before checking location of multiple elements on multiple frames' & @CRLF & 'Try the same example with and without waiting about 30 seconds in order to see that many frames should be fully loaded, and to check the differences')

	$aFrameList = _WD_FrameList($sSession, True, 5000, Default)
	ConsoleWrite("! ---> @error=" & @error & "  @extended=" & @extended & " : Example : Testing element location in frame set - after pre-checking list of frames" & @CRLF)
	_ArrayDisplay($aFrameList, @ScriptLineNumber & ' Before _WD_FrameListFindElement - www.tutorialspoint.com - get frame list as array', 0, 0, Default, $sArrayHeader)

	Local $aLocationOfElement = _WD_FrameListFindElement($sSession, $_WD_LOCATOR_ByCSSSelector, "li.nav-item[data-bs-original-title='Home Page'] a.nav-link[href='https://www.tutorialspoint.com/index.htm']")
	ConsoleWrite("wd_demo.au3: (" & @ScriptLineNumber & ") : $aLocationOfElement (" & UBound($aLocationOfElement) & ")=" & @CRLF & _ArrayToString($aLocationOfElement) & @CRLF)
	_ArrayDisplay($aLocationOfElement, @ScriptLineNumber & ' $aLocationOfElement', 0, 0, Default, $sArrayHeader)

	#EndRegion - Testing element location in frame set and iframe collecion

#CE

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
