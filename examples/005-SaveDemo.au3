#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Run_AU3Check=Y
#AutoIt3Wrapper_AU3Check_Stop_OnWarning=y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7

; 005-SaveDemo.au3

#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>

#include "..\NetWebView2Lib.au3"

_Example()

Func _Example()
	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc)
	#forceref $oMyError

	#Region ; GUI CREATION

	; Create the GUI
	Local $hGUI = GUICreate("WebView2 .NET Manager - Community Demo", 1000, 800)

	; Initialize WebView2 Manager and register events
	Local $oWebV2M = _NetWebView2_CreateManager()
	If @error Then Return SetError(@error, @extended, $oWebV2M)

	; initialize browser - put it on the GUI
	Local $sProfileDirectory = @ScriptDir & "\NetWebView2Lib-UserDataFolder"
	_NetWebView2_Initialize($oWebV2M, $hGUI, $sProfileDirectory, 0, 0, 0, 0, True, True, True, 1.2, "0x2B2B2B")

	; show the GUI after browser was fully initialized
	GUISetState(@SW_SHOW)

	#EndRegion ; GUI CREATION

	; navigate to the page
	_NetWebView2_Navigate($oWebV2M, "https://www.microsoft.com/")
	_NetWebView2_WaitForReadyState($oWebV2M)

	#Region ; PDF
	; get Browser content as PDF Base64 encoded binary data
	Local $s_PDF_FileFullPath = @ScriptDir & '\5-SaveDemo_result.pdf'
	Local $dBinaryDataToWrite = _NetWebView2_PrintToPdfStream($oWebV2M, True)

	; finally save PDF to FILE
	Local $hFile = FileOpen($s_PDF_FileFullPath, $FO_OVERWRITE + $FO_BINARY)
	FileWrite($hFile, $dBinaryDataToWrite)
	FileClose($hFile)

	; open PDF file in viewer (viewer which is set as default in Windows)
	ShellExecute($s_PDF_FileFullPath)
	#EndRegion ; PDF

	#Region ; HTML
	Local $s_HTML_content = _NetWebView2_ExportPageData($oWebV2M, 0, "")
	Local $s_HTML_FileFullPath = @ScriptDir & '\5-SaveDemo_result.html'
	If FileExists($s_HTML_FileFullPath) Then FileDelete($s_HTML_FileFullPath)
	FileWrite($s_HTML_FileFullPath, $s_HTML_content)
	ShellExecute($s_HTML_FileFullPath)
	#EndRegion ; HTML

	#Region ; MHTML
	; This trick is because Responsive Design (CSS) stored inside MHTML, and loading="lazy"
	$oWebV2M.ZoomFactor = 0.5
	Sleep(500)
	Local $s_MHTML_content = _NetWebView2_ExportPageData($oWebV2M, 1, "")
	$oWebV2M.ZoomFactor = 1

	Local $s_MHTML_FileFullPath = @ScriptDir & '\5-SaveDemo_result.mhtml'
	If FileExists($s_MHTML_FileFullPath) Then FileDelete($s_MHTML_FileFullPath)
	FileWrite($s_MHTML_FileFullPath, $s_MHTML_content)
	ShellExecute($s_MHTML_FileFullPath)
	#EndRegion ; MHTML

	#Region ; GUI Loop
	; Main Loop
	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				ExitLoop
		EndSwitch
	WEnd

	Local $oJSBridge
	_NetWebView2_CleanUp($oWebV2M, $oJSBridge)
	GUIDelete($hGUI)
	#EndRegion ; GUI Loop

EndFunc   ;==>_Example

; #FUNCTION# ====================================================================================================================
; Name...........: _NetWebView2_WaitForReadyState
; Description ...: Polls the browser until the document.readyState reaches 'complete'.
; Syntax.........: _NetWebView2_WaitForReadyState($oWebV2M, $iTimeout_ms = 5000)
; Parameters ....: $oWebV2M       - The WebView2 Manager object.
;                  $iTimeout_ms   - Maximum time to wait in milliseconds. 0 for infinite.
; Return values .: Success: True
;                  Failure: False, sets @error:
;                      1 - Timeout reached before document was complete.
;                      2 - WebView2 object is not valid or ready.
; Author ........: ioa747
; Modified.......:
; Remarks .......: This function uses JavaScript execution to check the internal state of the page.
;                  Useful for tasks like PDF printing where 'complete' state is mandatory.
; ===============================================================================================================================
Func _NetWebView2_WaitForReadyState($oWebV2M, $iTimeout_ms = 5000)
    Local Const $s_Prefix = ">>>[_NetWebView2_WaitForReadyState]:"

    If Not IsObj($oWebV2M) Then Return SetError(2, 0, False)
    Local $hTimer = TimerInit()
    Local $sReadyState = ""

    While 1
        ; Execute JS via the Bridge (Mode 2)
        $sReadyState = _NetWebView2_ExecuteScript($oWebV2M, "document.readyState", $NETWEBVIEW2_EXECUTEJS_MODE2_RESULT)

        ; Check for the 'complete' state
        If $sReadyState == "complete" Then
            __NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " SUCCESS: Document is ready. Timeout_ms: " & Round(TimerDiff($hTimer), 0), 0)
            Return True
        EndIf

        ; Check for C# Bridge internal errors (Timeout/Init)
        If StringLeft($sReadyState, 6) == "ERROR:" Then
            __NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " BRIDGE " & $sReadyState & " Timeout_ms: " & Round(TimerDiff($hTimer), 0), 1)
            Return SetError(3, 0, False)
        EndIf

        ; Check for AutoIt-side Timeout
        If $iTimeout_ms > 0 And TimerDiff($hTimer) > $iTimeout_ms Then
            __NetWebView2_Log(@ScriptLineNumber, $s_Prefix & " TIMEOUT: Document state is " & $sReadyState & " Timeout_ms: " & Round(TimerDiff($hTimer), 0), 1)
            Return SetError(1, 0, False)
        EndIf
        Sleep(100)
    WEnd
EndFunc   ;==>_NetWebView2_WaitForReadyState
