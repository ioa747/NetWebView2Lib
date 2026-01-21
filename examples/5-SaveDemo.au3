#AutoIt3Wrapper_UseX64=y
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>

#include "..\NetWebView2Lib.au3"

; Global objects
Global $hGUI, $idLabelStatus

Main()

Func Main()
	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc)
	#forceref $oMyError

	#Region ; GUI CREATION

	; Create the GUI
	$hGUI = GUICreate("WebView2 .NET Manager - Community Demo", 1000, 800)

	; Initialize WebView2 Manager and register events
	Local $oWebV2M = _NetWebView2_CreateManager("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0", "", "--disable-gpu, --mute-audio")
	$_g_oWeb = $oWebV2M
	If @error Then Return SetError(@error, @extended, $oWebV2M)

	; create JavaScript Bridge object
	Local $oJSBridge = _NetWebView2_GetBridge($oWebV2M, "")
	If @error Then Return SetError(@error, @extended, $oWebV2M)

	; initialize browser - put it on the GUI
	Local $sProfileDirectory = @TempDir & "\NetWebView2Lib-UserDataFolder"
	_NetWebView2_Initialize($oWebV2M, $hGUI, $sProfileDirectory, 0, 0, 0, 0, True, True, True, 1.2, "0x2B2B2B")

	; show the GUI after browser was fully initialized
	GUISetState(@SW_SHOW)

	#EndRegion ; GUI CREATION

	; navigate to the page
	_NetWebView2_Navigate($_g_oWeb, "https://www.microsoft.com/")

	#Region ; PDF
	; get Browser content as PDF Base64 encoded binary data
	Local $s_PDF_FileFullPath = @ScriptDir & '\5-SaveDemo_result.pdf'
	Local $dPDF_asBase64 = _NetWebView2_PrintToPdfStream($_g_oWeb)

	; decode Base64 encoded data do Binary
	Local $dBinaryDataToWrite = _Base64Decode($dPDF_asBase64)

	; finally save PDF to FILE
	Local $hFile = FileOpen($s_PDF_FileFullPath, $FO_OVERWRITE + $FO_UTF8_NOBOM + $FO_BINARY)
	FileWrite($hFile, $dBinaryDataToWrite)
	FileClose($hFile)

	; open PDF file in viewer (viewer which is set as default in Windows)
	ShellExecute($s_PDF_FileFullPath)
	#EndRegion ; PDF

	#Region ; HTML
	Local $s_HTML_content = _NetWebView2_ExportPageData($_g_oWeb, 0, "")
	Local $s_HTML_FileFullPath = @ScriptDir & '\5-SaveDemo_result.html'
	FileWrite($s_HTML_FileFullPath, $s_HTML_content)
	ShellExecute($s_HTML_FileFullPath)
	#EndRegion ; HTML

	#Region ; MHTML
	Local $s_MHTML_content = _NetWebView2_ExportPageData($_g_oWeb, 1, "")
	Local $s_MHTML_FileFullPath = @ScriptDir & '\5-SaveDemo_result.mhtml'
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

	GUIDelete($hGUI)
	#EndRegion ; GUI Loop

	_NetWebView2_CleanUp($oWebV2M, $oJSBridge)
EndFunc   ;==>Main

; #FUNCTION# ====================================================================================================================
; Name ..........: _Base64Decode
; Description ...:
; Syntax ........: _Base64Decode($input_string)
; Parameters ....: $input_string        - An integer value.
; Return values .: None
; Author ........: trancexx
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: http://www.autoitscript.com/forum/topic/81332-base64encode-base64decode
; Example .......: yes
; ===============================================================================================================================
Func _Base64Decode($input_string)

	Local $struct = DllStructCreate("int")

	Local $a_Call = DllCall("Crypt32.dll", "int", "CryptStringToBinary", _
			"str", $input_string, _
			"int", 0, _
			"int", 1, _
			"ptr", 0, _
			"ptr", DllStructGetPtr($struct, 1), _
			"ptr", 0, _
			"ptr", 0)

	If @error Or Not $a_Call[0] Then
		Return SetError(1, 0, "") ; error calculating the length of the buffer needed
	EndIf

	Local $a = DllStructCreate("byte[" & DllStructGetData($struct, 1) & "]")

	$a_Call = DllCall("Crypt32.dll", "int", "CryptStringToBinary", _
			"str", $input_string, _
			"int", 0, _
			"int", 1, _
			"ptr", DllStructGetPtr($a), _
			"ptr", DllStructGetPtr($struct, 1), _
			"ptr", 0, _
			"ptr", 0)

	If @error Or Not $a_Call[0] Then
		Return SetError(2, 0, "") ; error decoding
	EndIf

	Return DllStructGetData($a, 1)

EndFunc   ;==>_Base64Decode
