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
	MsgBox($MB_TOPMOST, "TEST #" & @ScriptLineNumber, 'Wait till all frames are loaded')
;~ 	_Demo_NavigateCheckBanner($sSession, "https://www.w3schools.com/tags/tryit.asp?filename=tryhtml_iframe", '//*[@id="snigel-cmp-framework" and @class="snigel-cmp-framework"]')
	If @error Then Return SetError(@error, @extended)

	#Region ; Example part 1 - testing NetWebView2Lib methodes: .GetFrameCount() .GetFrameUrl($IDX_Frame) .GetFrameName($IDX_Frame)
	ConsoleWrite("+ Example part 1 - testing NetWebView2Lib methodes: .GetFrameCount() .GetFrameUrl($IDX_Frame) .GetFrameName($IDX_Frame)" & @CRLF)

	Local $iFrameCount = $oWebV2M.GetFrameCount()
	ConsoleWrite(@CRLF)
	ConsoleWrite("! " & @ScriptLineNumber & " : Frames=" & $iFrameCount & @CRLF)
	For $IDX_Frame = 0 To $iFrameCount - 1
		ConsoleWrite("- IDX=" & $IDX_Frame & @CRLF)
		ConsoleWrite("- URL=" & $oWebV2M.GetFrameUrl($IDX_Frame) & @CRLF)
		ConsoleWrite("- NAME=" & $oWebV2M.GetFrameName($IDX_Frame) & @CRLF)
		ConsoleWrite(@CRLF)
	Next
	MsgBox($MB_TOPMOST, "TEST #" & @ScriptLineNumber, 'Example part 1 - testing NetWebView2Lib methodes: ' & @CRLF & '.GetFrameCount() .GetFrameUrl($IDX_Frame) .GetFrameName($IDX_Frame)' & @CRLF & 'End')
	#EndRegion ; Example part 1 - testing NetWebView2Lib methodes: .GetFrameCount() .GetFrameUrl($IDX_Frame) .GetFrameName($IDX_Frame)

	#Region ; Example part 2 - testing NetWebView2Lib methodes: .GetFrameCount() .GetFrameUrl($IDX_Frame) .GetFrameName($IDX_Frame)
	ConsoleWrite("+ Example part 2 - testing NetWebView2Lib methodes: .GetFrameCount() .GetFrameUrl($IDX_Frame) .GetFrameName($IDX_Frame)" & @CRLF)

	ConsoleWrite("! " & @ScriptLineNumber & " : GetFrameUrls() :" & @CRLF & $oWebV2M.GetFrameUrls() & @CRLF)
	ConsoleWrite("! " & @ScriptLineNumber & " : GetFrameNames() :" & @CRLF & $oWebV2M.GetFrameNames() & @CRLF)
	MsgBox($MB_TOPMOST, "TEST #" & @ScriptLineNumber, 'Example part 2 - testing NetWebView2Lib methodes:' & @CRLF & '.GetFrameCount() .GetFrameUrl($IDX_Frame) .GetFrameName($IDX_Frame)' & @CRLF & 'End')
	#EndRegion ; Example part 2 - testing NetWebView2Lib methodes: .GetFrameCount() .GetFrameUrl($IDX_Frame) .GetFrameName($IDX_Frame)

	#Region ; Example part 3 - testing NetWebView2Lib methodes .GetFrameHtmlSource($IDX_Frame)
	ConsoleWrite("+ Example part 3 - testing NetWebView2Lib methodes .GetFrameHtmlSource($IDX_Frame)" & @CRLF)
	For $IDX_Frame = 0 To $iFrameCount - 1
		ConsoleWrite(@CRLF & "======================================================" & @CRLF)
		Local $sHtmlSource = Fire_And_Wait($oWebV2M.GetFrameHtmlSource($IDX_Frame), 5000) ; pair with "FRAME_HTML_SOURCE"
		ConsoleWrite("! " & @ScriptLineNumber & " : GetFrameHtmlSource(" & $IDX_Frame & ") :" & @CRLF & $sHtmlSource & @CRLF)
	Next
	ConsoleWrite(@CRLF & "======================================================" & @CRLF)
	ConsoleWrite(@CRLF)
	ConsoleWrite(@CRLF)
	MsgBox($MB_TOPMOST, "TEST #" & @ScriptLineNumber, 'Example part 3 - testing NetWebView2Lib methodes : ' & @CRLF & '.GetFrameHtmlSource($IDX_Frame)' & @CRLF & 'End')
	#EndRegion ; Example part 3 - testing NetWebView2Lib methodes .GetFrameHtmlSource($IDX_Frame)

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
		ConsoleWrite("$oFrame0.FrameId=" & $oFrame0.FrameId & @CRLF & @CRLF)
		ConsoleWrite("$oFrame0.IsDestroyed()=" & $oFrame0.IsDestroyed() & @CRLF & @CRLF)

		; Direct script execution in the iframe without involving the central Manager
		$oFrame0.ExecuteScript("document.body.style.backgroundColor = 'red';")
		ConsoleWrite("> Executed background color change on Frame(0)" & @CRLF)

		; Try getting the URL via JS
		Local $sUrl = $oFrame0.ExecuteScriptWithResult("window.location.href")
		ConsoleWrite("> Frame(0) URL via JS: " & $sUrl & @CRLF)

	Else
		ConsoleWrite("! Error: $oFrame0 is not a valid COM Object" & @CRLF)
	EndIf
	MsgBox($MB_TOPMOST, "TEST #" & @ScriptLineNumber, 'Example part 4 - Direct Frame Interaction: ' & @CRLF & '' & @CRLF & 'End')
	#EndRegion ; Example part 4 - Direct Frame Interaction

	#Region ; Example part 5 - Get all Frames as array
	Local $aFrames
	Do
		$aFrames = _NetWebView2_GetAllFrames_AsArray($oWebV2M)
		_ArrayDisplay($aFrames, @ScriptLineNumber & ' $aFrames : Example part 5 - Get all Frames as array')
	Until ($IDNO = MsgBox($MB_YESNO + $MB_TOPMOST + $MB_ICONQUESTION + $MB_DEFBUTTON2, "Question", "Check again all frames ?"))

	#EndRegion ; Example part 5 - Get all Frames as array

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

; #FUNCTION# ====================================================================================================================
; Name ..........: _NetWebView2_GetAllFrames_AsArray
; Description ...: Get all Frames as array
; Syntax ........: _NetWebView2_GetAllFrames_AsArray($oWebV2M)
; Parameters ....: $oWebV2M             - an object.
; Return values .: None
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _NetWebView2_GetAllFrames_AsArray($oWebV2M)
	Local Const $s_Prefix = "[_NetWebView2_GetAllFrames_AsArray]:"
	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc) ; Local COM Error Handler
	#forceref $oMyError, $s_Prefix

	Local Enum _
			$FRAME_IDX, _
			$FRAME_OBJECT, _
			$FRAME_ID, _
			$FRAME_NAME, _
			$FRAME_URL, _
			$FRAME_DESTROYED, _
			$FRAME_HTML, _
			$FRAME__COUNTER

	Local $iFrameCount = $oWebV2M.GetFrameCount()
	Local $aFrames[$iFrameCount][$FRAME__COUNTER]
	Local $oFrame
	For $IDX_Frame = 0 To $iFrameCount - 1
		$oFrame = $oWebV2M.GetFrame($IDX_Frame)
		$aFrames[$IDX_Frame][$FRAME_IDX] = $IDX_Frame
		$aFrames[$IDX_Frame][$FRAME_OBJECT] = $oFrame
		$aFrames[$IDX_Frame][$FRAME_ID] = $oFrame.FrameId
		$aFrames[$IDX_Frame][$FRAME_NAME] = $oWebV2M.Name
		$aFrames[$IDX_Frame][$FRAME_URL] = $oWebV2M.GetFrameUrl($IDX_Frame)
		$aFrames[$IDX_Frame][$FRAME_DESTROYED] = $oFrame.IsDestroyed()
;~ 		$aFrames[$IDX_Frame][$FRAME_HTML] = $oWebV2M.GetFrameHtmlSource($IDX_Frame)
	Next
	Return $aFrames
EndFunc   ;==>_NetWebView2_GetAllFrames_AsArray

; ==============================================================================
; MyHook_ Events
; ==============================================================================
Func MyHook_OnMessageReceived($oWebV2M, $hGUI, $sMsg)
	#forceref $oWebV2M, $hGUI
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
