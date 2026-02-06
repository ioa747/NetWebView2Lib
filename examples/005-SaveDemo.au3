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
	Local $sProfileDirectory = @TempDir & "\NetWebView2Lib-UserDataFolder"
	_NetWebView2_Initialize($oWebV2M, $hGUI, $sProfileDirectory, 0, 0, 0, 0, True, True, True, 1.2, "0x2B2B2B")

	; show the GUI after browser was fully initialized
	GUISetState(@SW_SHOW)

	#EndRegion ; GUI CREATION

	; navigate to the page
	_NetWebView2_Navigate($oWebV2M, "https://www.microsoft.com/", $NETWEBVIEW2_MESSAGE__NAVIGATION_COMPLETED)

	#Region ; PDF
	; get Browser content as PDF Base64 encoded binary data
	Local $s_PDF_FileFullPath = @ScriptDir & '\5-SaveDemo_result.pdf'
	Local $dPDF_asBase64 = _NetWebView2_PrintToPdfStream($oWebV2M)

	; decode Base64 encoded data do Binary
	Local $dBinaryDataToWrite = _NetWebView2_DecodeB64ToBinary($oWebV2M, $dPDF_asBase64)

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
	; This trick is because Responsive Design (CSS) stored inside MHTML, and loading="lazy" ; 👈
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

	_NetWebView2_CleanUp($oWebV2M)
	GUIDelete($hGUI)
	#EndRegion ; GUI Loop


EndFunc   ;==>_Example

