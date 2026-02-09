#AutoIt3Wrapper_UseX64=y
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>

#include "..\NetWebView2Lib.au3"

; 006-DownloadDemo.au3

Global $_sURLDownload_InProgress = ''
_Example()

Func _Example()
	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc)
	#forceref $oMyError

	#Region ; GUI CREATION

	; Create the GUI
	Local $hGUI = GUICreate("WebView2 .NET Manager - [ Press ESC to cancel the download ]", 1000, 800)

	; Initialize WebView2 Manager and register events
	Local $oWebV2M = _NetWebView2_CreateManager("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0", "__UserEventHandler__", "--mute-audio")
	If @error Then Return SetError(@error, @extended, $oWebV2M)

	; create JavaScript Bridge object
	Local $oJSBridge = _NetWebView2_GetBridge($oWebV2M, "")
	If @error Then Return SetError(@error, @extended, $oWebV2M)

	; initialize browser - put it on the GUI
	Local $sProfileDirectory = @ScriptDir & "\NetWebView2Lib-UserDataFolder"
	_NetWebView2_Initialize($oWebV2M, $hGUI, $sProfileDirectory, 0, 0, 0, 0, True, True, True, 1.2, "0x2B2B2B")

	; show the GUI after browser was fully initialized
	GUISetState(@SW_SHOW)

	#EndRegion ; GUI CREATION

	; Silent Download Setting
	$oWebV2M.IsDownloadUIEnabled = False
	; Set default Download Path
	DirCreate(@ScriptDir & "\Downloads_Test")
	$oWebV2M.SetDownloadPath(@ScriptDir & "\Downloads_Test")

	; navigate to the page
;~ 	_NetWebView2_Navigate($oWebV2M, "https://www.libreoffice.org/download/download-libreoffice", $NETWEBVIEW2_MESSAGE__TITLE_CHANGED)

	_NetWebView2_Navigate($oWebV2M, "https://www.libreoffice.org/donate/dl/win-x86_64/25.8.4/en-US/LibreOffice_25.8.4_Win_x86-64.msi", $NETWEBVIEW2_MESSAGE__NAV_STARTING)

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

Func __UserEventHandler__OnDownloadStateChanged($oWebV2M, $hGUI, $sState, $sURL, $iTotal_Bytes, $iReceived_Bytes)
	#forceref $oWebV2M

	$hGUI = HWnd("0x" & Hex($hGUI, 16))
	Local $iPercent = 0
	If $iTotal_Bytes > 0 Then $iPercent = Round(($iReceived_Bytes / $iTotal_Bytes), 5) * 100

	; Convert to MB for easy-to-read log
	Local $iReceived_MegaBytes = Round($iReceived_Bytes / 1024 / 1024)
	Local $iTotal_MegaBytes = Round($iTotal_Bytes / 1024 / 1024)

	Local Const $s_Message = " " & $iPercent & "% (" & $iReceived_MegaBytes & " / " & $iTotal_MegaBytes & " Mega Bytes)"

	Local Static $bProgres_State = 0

	Switch $sState
		Case "InProgress"
			If $bProgres_State = 0 Then
				ProgressOn("Dowload in progress", StringRegExpReplace($sURL, '(.+/)(.+)', '$2'), $s_Message, -1, -1, BitOR($DLG_NOTONTOP, $DLG_MOVEABLE))
			EndIf
			$_sURLDownload_InProgress = $sURL
			ProgressSet(Round($iPercent), $s_Message)
			$bProgres_State = 1
		Case "Interrupted"
			ProgressSet(100, "Done", "Interrupted")
			Sleep(3000)
			ProgressOff()
			$bProgres_State = 0
			$_sURLDownload_InProgress = ''
		Case "Completed"
			ProgressSet(100, "Done", "Completed")
			Sleep(3000)
			ProgressOff()
			$bProgres_State = 0
			$_sURLDownload_InProgress = ''
	EndSwitch
EndFunc   ;==>__UserEventHandler__OnDownloadStateChanged

Func __UserEventHandler__OnAcceleratorKeyPressed($oWebV2M, $hGUI, $oArgs)
	$hGUI = HWnd("0x" & Hex($hGUI, 16))
	Local Const $sArgsList = '[Handled=' & $oArgs.Handled & '; KeyEventKind=' & $oArgs.KeyEventKind & '; KeyEventLParam=' & $oArgs.KeyEventLParam & '; VirtualKey=' & $oArgs.VirtualKey & ']'
	Local Const $s_Prefix = "[USER:EVENT: OnAcceleratorKeyPressed]: GUI:" & $hGUI & " ARGS: " & ((IsObj($oArgs)) ? ($sArgsList) : ('ERRROR'))

;~ 	https://learn.microsoft.com/en-us/dotnet/api/microsoft.web.webview2.core.corewebview2acceleratorkeypressedeventargs?view=webview2-dotnet-1.0.705.50
	ConsoleWrite($oArgs.Handled & @CRLF) ; Indicates whether the AcceleratorKeyPressed event is handled by host.
	ConsoleWrite($oArgs.KeyEventKind & @CRLF) ; Gets the key event kind that caused the event to run
	ConsoleWrite($oArgs.KeyEventLParam & @CRLF) ; Gets the LPARAM value that accompanied the window message.
;~ 	ConsoleWrite('>> PhysicalKeyStatus=' & $oArgs.PhysicalKeyStatus & @CRLF) ; Gets a CoreWebView2PhysicalKeyStatus representing the information passed in the LPARAM of the window message. ==> ; https://learn.microsoft.com/en-us/dotnet/api/microsoft.web.webview2.core.corewebview2physicalkeystatus?view=webview2-dotnet-1.0.705.50
	ConsoleWrite($oArgs.VirtualKey & @CRLF) ; Gets the Win32 virtual key code of the key that was pressed or released.

	If $oArgs.VirtualKey = 27 Then ; ESC 27 1b 033 Escape, next character is not echoed ; https://www.autoitscript.com/autoit3/docs/appendix/ascii.htm
		$oWebV2M.CancelDownloads($_sURLDownload_InProgress)
	EndIf

	__NetWebView2_Log(@ScriptLineNumber, (StringLen($s_Prefix) > 150 ? StringLeft($s_Prefix, 150) & "..." : $s_Prefix), 1)
EndFunc   ;==>__UserEventHandler__OnAcceleratorKeyPressed
