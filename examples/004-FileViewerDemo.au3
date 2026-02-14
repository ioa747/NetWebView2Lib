#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Run_AU3Check=Y
#AutoIt3Wrapper_AU3Check_Stop_OnWarning=y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7

; 004-FileViewerDemo.au3

#include <GUIConstantsEx.au3>
#include <SendMessage.au3>
#include <StaticConstants.au3>
#include <WinAPIGdi.au3>
#include <WinAPISysWin.au3>
#include <WindowsConstants.au3>
#include <WinAPIGdi.au3>
#include <WinAPIGdiDC.au3>
#include <WinAPIHObj.au3>

#SciTE4AutoIt3_Dynamic_Include_Path=;..\NetWebView2Lib.au3
#SciTE4AutoIt3_Dynamic_Include=y                               ;dynamic.include=y/n
#SciTE4AutoIt3_Dynamic_Include_whiletyping=y                   ;dynamic.include.whiletyping=y/n
#SciTE4AutoIt3_Dynamic_Include_recursive_check=y               ;dynamic.include.recursive.check=n/y
#SciTE4AutoIt3_Dynamic_Include_use_local_cache=y               ;dynamic.include.use.local.cache=n/y
#SciTE4AutoIt3_Dynamic_Include_version=prod                    ;dynamic.include.version=prod/beta
#SciTE4AutoIt3_Dynamic_Include_verboselevel=0                  ;dynamic.include.verbose.level=0/1/2 ;  0=disabled; 1=Timing per Function; 2=1+Total timing
#SciTE4AutoIt3_Dynamic_Include_Always_Update_Local_File=n      ;dynamic.include.always.update.local.file=n/y
#SciTE4AutoIt3_AutoItTools_debug=n                             ;debug.autoIttools=n/y
#SciTE4AutoIt3_AutoItDynamicIncludes_debug=n                   ;debug.AutoItDynamicIncludes=n/y
#SciTE4AutoIt3_AutoItAutocomplete_debug=n                      ;debug.autoitautocomplet=n/y
#SciTE4AutoIt3_AutoItGotoDefinition_debug=n                    ;debug.autoitgotodefinition=n/y
#SciTE4AutoIt3_AutoItIndentFix_debug=n                         ;debug.autoitindentfix=n/y

#include "..\NetWebView2Lib.au3"

Global $idLabelStatus

_Example()

Func _Example()
	ConsoleWrite("! MicrosoftEdgeWebview2 : version check: " & _NetWebView2_IsAlreadyInstalled() & ' ERR=' & @error & ' EXT=' & @extended & @CRLF)

	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc)
	#forceref $oMyError

	; Create the UI
	Local $iHeight = 800
	Local $hGUI = GUICreate("WebView2 .NET Manager - Demo: " & @ScriptName, 1100, $iHeight, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPCHILDREN))
	$idLabelStatus = GUICtrlCreateLabel("Status: Initializing Engine...", 10, $iHeight - 20, 880, 20)
	GUICtrlSetFont(-1, 9, 400, 0, "Segoe UI")

	; Initialize WebView2 Manager and register events
	Local $oWebV2M = _NetWebView2_CreateManager("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0", "", "--mute-audio")
	If @error Then Return SetError(@error, @extended, $oWebV2M)

;~ 	; Initialize JavaScript Bridge ; not needed in this example
;~ 	Local $oJSBridge = _NetWebView2_GetBridge($oWebV2M)
;~ 	If @error Then Return SetError(@error, @extended, $oWebV2M)

	Local $sProfileDirectory = @ScriptDir & "\NetWebView2Lib-UserDataFolder"
	_NetWebView2_Initialize($oWebV2M, $hGUI, $sProfileDirectory, 0, 0, 0, $iHeight - 20, True, True, 1.2, "0x2B2B2B")

	GUISetState(@SW_SHOW, $hGUI)
	WinSetOnTop($hGUI, '', $WINDOWS_ONTOP)

	Local $s_PDF_FileFullPath

	#TIP: FitToPage: https://stackoverflow.com/questions/78820187/how-to-change-webview2-fit-to-page-button-on-pdf-toolbar-default-to-fit-to-width#comment138971950_78821231
	_NetWebView2_NavigateToPDF($oWebV2M, "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf", '#view=FitH', $NETWEBVIEW2_MESSAGE__TITLE_CHANGED, "", 5000, 1000, True)
	MsgBox($MB_TOPMOST, " _NetWebView2_NavigateToPDF() TEST #" & @ScriptLineNumber, $s_PDF_FileFullPath, 0, $hGUI)

	#TIP: Open desired PAGE: https://stackoverflow.com/questions/68500164/cycle-pdf-pages-in-wpf-webview2#comment135402565_68566860
	$s_PDF_FileFullPath = "file:///" & @ScriptDir & '/FileViewerDemo_1.pdf'
	_NetWebView2_NavigateToPDF($oWebV2M, $s_PDF_FileFullPath, '#page=1', $NETWEBVIEW2_MESSAGE__TITLE_CHANGED, "", 5000, 1000, True)
	MsgBox($MB_TOPMOST, " _NetWebView2_NavigateToPDF() TEST #" & @ScriptLineNumber, $s_PDF_FileFullPath, 0, $hGUI)

	$s_PDF_FileFullPath = "file:///" & @ScriptDir & '/FileViewerDemo_2.pdf'
	_NetWebView2_NavigateToPDF($oWebV2M, $s_PDF_FileFullPath, '#view=FitH', $NETWEBVIEW2_MESSAGE__TITLE_CHANGED, "", 5000, 1000, True)
	MsgBox($MB_TOPMOST, " _NetWebView2_NavigateToPDF() TEST #" & @ScriptLineNumber, $s_PDF_FileFullPath, 0, $hGUI)

	$s_PDF_FileFullPath = "file:///" & @ScriptDir & '/FileViewerDemo_3.pdf'
	_NetWebView2_NavigateToPDF($oWebV2M, $s_PDF_FileFullPath, '#view=FitH', $NETWEBVIEW2_MESSAGE__TITLE_CHANGED, "", 5000, 1000, True)
	MsgBox($MB_TOPMOST, " _NetWebView2_NavigateToPDF() TEST #" & @ScriptLineNumber, $s_PDF_FileFullPath, 0, $hGUI)

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
EndFunc   ;==>_Example
