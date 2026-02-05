#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Run_AU3Check=Y
#AutoIt3Wrapper_AU3Check_Stop_OnWarning=y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7
#Au3Stripper_Ignore_Funcs=__NetWebView2_WebEvents_*,__NetWebView2_JSEvents_*

; DownloadDemo.au3

#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include "..\..\NetWebView2Lib.au3"

; Global objects
Global $hGUI

_Example()

Func _Example()
	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc)
	#forceref $oMyError

	#Region ; GUI CREATION

	HotKeySet("{ESC}", _DownloadCancel)

	; Create the GUI
	$hGUI = GUICreate("WebView2 .NET Manager - [ Press ESC to cancell the download ]", 1000, 800)

	; Initialize WebView2 Manager and register events
	Local $oWebV2M = _NetWebView2_CreateManager("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0", "", "--mute-audio")
	$_g_oWeb = $oWebV2M
	If @error Then Return SetError(@error, @extended, $oWebV2M)

	; create JavaScript Bridge object
	Local $oJSBridge = _NetWebView2_GetBridge($oWebV2M, "")
	If @error Then Return SetError(@error, @extended, $oWebV2M)

	; initialize browser - put it on the GUI
	Local $sProfileDirectory = @TempDir & "\..\NetWebView2Lib-UserDataFolder"
	_NetWebView2_Initialize($oWebV2M, $hGUI, $sProfileDirectory, 0, 0, 0, 0, True, True, True, 1.2, "0x2B2B2B")

	; show the GUI after browser was fully initialized
	GUISetState(@SW_SHOW)

	#EndRegion ; GUI CREATION

	; Silent Download Setting
	$oWebV2M.IsDownloadUIEnabled = False
	; Set default Download Path
	$oWebV2M.SetDownloadPath(@ScriptDir & "\Downloads_Test")

	; navigate to the page
	_NetWebView2_Navigate($oWebV2M, "https://www.libreoffice.org/download/download-libreoffice/", $NETWEBVIEW2_MESSAGE__TITLE_CHANGED) ; 4 = NAV_COMPLETED 👈

	_NetWebView2_Navigate($oWebV2M, "https://www.libreoffice.org/donate/dl/win-x86_64/25.8.4/en-US/LibreOffice_25.8.4_Win_x86-64.msi")

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
EndFunc   ;==>_Example

; =======================================================================================
; EVENT HANDLERS (CALLBACKS)
; =======================================================================================

Func _DownloadCancel()
	ConsoleWrite("HotKeyPress: _DownloadCancel" & @CRLF)
	$_g_oWeb.CancelDownloads("https://fosszone.csd.auth.gr/tdf/libreoffice/stable/25.8.4/win/x86_64/LibreOffice_25.8.4_Win_x86-64.msi")
EndFunc   ;==>_DownloadCancel
