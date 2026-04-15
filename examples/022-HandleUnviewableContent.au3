#include "..\NetWebView2Lib.au3"
#include <MsgBoxConstants.au3>

; 022-HandleUnviewableContent.au3
; Description: Demonstrates how to use the refactored OnDownloadStarting event to identify content types (MimeType)
;              and take action (Cancel or Redirect) before the download starts.

$hGUI = GUICreate("NetWebView2 - Handle Unviewable Content (MIME)", 1000, 700)
GUISetState(@SW_SHOW)

; 1. Create and Initialize the Manager with the special 'DownloadTest_' event prefix
$oWebV2M = _NetWebView2_CreateManager("", "DownloadTest_")
_NetWebView2_Initialize($oWebV2M, $hGUI, @ScriptDir & "\Profile_DownloadTest", 0, 0, 1000, 700)

; 2. Navigate to a site known for downloads (e.g., a PDF direct link)
ConsoleWrite("! Navigating to a PDF file to test MIME detection..." & @CRLF)
_NetWebView2_Navigate($oWebV2M, "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf")

__Example_Log(@ScriptLineNumber, "END - close window to exit" & @CRLF)

Do
	$iMsg = GUIGetMsg()
Until $iMsg = $GUI_EVENT_CLOSE

_NetWebView2_CleanUp($oWebV2M, $hGUI)

#Region ; === EVENT HANDLERS ===
; NEW: OnDownloadStarting now receives an Args object instead of simple strings
; Advise using 'Volatile' for Event Handlers to ensure the WebView2 COM thread can interrupt the main script safely.
Volatile Func DownloadTest_OnDownloadStarting($oSender, $hGUI, $oArgs)
	Local $sURL = $oArgs.Uri
	Local $sMime = $oArgs.MimeType
	Local $sDefaultPath = $oArgs.ResultFilePath

	ConsoleWrite("+++ [EVENT] OnDownloadStarting fired!" & @CRLF)
	ConsoleWrite("    - URL: " & $sURL & @CRLF)
	ConsoleWrite("    - MIME: " & $sMime & @CRLF)
	ConsoleWrite("    - Suggested Path: " & $sDefaultPath & @CRLF)

	; 💡 Logic for Issue #123: Identify "Unviewable" content by MIME type
	If $sMime = "application/pdf" Then
		Local $iAnswer = MsgBox($MB_YESNO + $MB_ICONQUESTION, "Unviewable Content Detected", _
				"The browser detected a PDF file (MIME: " & $sMime & ")." & @CRLF & @CRLF & _
				"Do you want to CANCEL this download and show an alert instead?" & @CRLF & _
				"(Demonstrating the new Args control)")

		If $iAnswer = $IDYES Then
			$oArgs.Cancel = True ; 🛑 CANCEL THE DOWNLOAD
			ConsoleWrite("! Download Cancelled by User decision." & @CRLF)
			MsgBox($MB_ICONINFORMATION, "Action Taken", "The download was intercepted and cancelled.")
		Else
			$oArgs.Handled = True ; ✅ ALLOW DOWNLOAD (and tell C# we are done deciding)
			ConsoleWrite("! Download Allowed by User." & @CRLF)
		EndIf
	EndIf
EndFunc   ;==>DownloadTest_OnDownloadStarting

; Advise using 'Volatile' for Event Handlers to ensure the WebView2 COM thread can interrupt the main script safely.
Volatile Func DownloadTest_OnDownloadStateChanged($oWebV2M, $hGUI, $oArgs)
	ConsoleWrite(">>> [DOWNLOAD STATUS] State: " & $oArgs.State & " | PercentComplete:" & $oArgs.PercentComplete & "% " & $oArgs.BytesReceived & "/" & $oArgs.TotalBytesToReceive & " Bytes" & @CRLF)
EndFunc   ;==>DownloadTest_OnDownloadStateChanged
#EndRegion ; === EVENT HANDLERS ===

Func __Example_Log($s_ScriptLineNumber, $sString, $iError = @error, $iExtended = @extended)
	ConsoleWrite(@ScriptName & ' SLN=' & $s_ScriptLineNumber & ' [' & $iError & '/' & $iExtended & '] ::: ' & $sString & @CRLF)
	Return SetError($iError, $iExtended, '')
EndFunc   ;==>__Example_Log
