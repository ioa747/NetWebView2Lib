#AutoIt3Wrapper_UseX64=y
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <Misc.au3>
#include "..\NetWebView2Lib.au3"

#Tidy_Parameters=/tcb=-1

; 006-DownloadDemo.au3

Global $_sURLDownload_InProgress = ''
_Example()

Func _Example()
	ConsoleWrite("! MicrosoftEdgeWebview2 : version check: " & _NetWebView2_IsAlreadyInstalled() & ' ERR=' & @error & ' EXT=' & @extended & @CRLF)

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
	_NetWebView2_Initialize($oWebV2M, $hGUI, $sProfileDirectory, 0, 0, 0, 0, True, True, 1.2, "0x2B2B2B")

	; show the GUI after browser was fully initialized
	GUISetState(@SW_SHOW)

	#EndRegion ; GUI CREATION

	; BlockedVirtualKeys
	;	A comma-separated list of Virtual Key codes to be blocked synchronously (e.g., "116,123").
	;	`object.BlockedVirtualKeys = "116,123"`

	; Block F5 (116) and F12 (123) AcceleratorKey!
	$oWebV2M.BlockedVirtualKeys = "116,123"

	; Silent Download Setting
	$oWebV2M.IsDownloadUIEnabled = False

	; Set default Download Path (Create the folder if it doesn't exist)
	$oWebV2M.SetDownloadPath(@ScriptDir & "\Downloads_Test")

	; navigate to the page
	_NetWebView2_Navigate($oWebV2M, "https://downloadarchive.documentfoundation.org/libreoffice/old/26.2.3.1/win/x86_64/LibreOffice_26.2.3.1_Win_x86-64.msi", $NETWEBVIEW2_MESSAGE__NAV_STARTING)
	#TODO AutoDetermine MSI file location

	__Example_Log(@ScriptLineNumber, "END - close window to exit" & @CRLF)
	#Region ; GUI Loop
	; Main Loop
	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				ConsoleWrite('$GUI_EVENT_CLOSE fired' & @CRLF)
				ExitLoop
		EndSwitch
	WEnd

	_NetWebView2_CleanUp($oWebV2M, $oJSBridge)
	GUIDelete($hGUI)
	#EndRegion ; GUI Loop

EndFunc   ;==>_Example

#Region ; === EVENT HANDLERS ===
; Advise using 'Volatile' for Event Handlers to ensure the WebView2 COM thread can interrupt the main script safely.
Volatile Func __UserEventHandler__OnDownloadStateChanged($oWebV2M, $hGUI, $oArgs)
	#forceref $oWebV2M

	$hGUI = HWnd("0x" & Hex($hGUI, 16))
	Local $iPercent = $oArgs.PercentComplete
	If $iPercent < 0 Then $iPercent = 0

	; Convert to MB for easy-to-read log
	Local $iReceived_MegaBytes = Round($oArgs.BytesReceived / 1048576, 2) ; 1024*1024
	Local $iTotal_MegaBytes = Round($oArgs.TotalBytesToReceive / 1048576, 2)

	Local Const $s_Message = " " & $iPercent & "% (" & $iReceived_MegaBytes & " / " & $iTotal_MegaBytes & " MB)"

	Local Static $bProgres_State = 0

	Switch $oArgs.State
		Case "InProgress"
			If $bProgres_State = 0 Then
				ProgressOn("Dowload in progress", StringRegExpReplace($oArgs.Uri, '(.+/)(.+)', '$2'), $s_Message, -1, -1, BitOR($DLG_NOTONTOP, $DLG_MOVEABLE))
			EndIf
			$_sURLDownload_InProgress = $oArgs.Uri
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

; Advise using 'Volatile' for Event Handlers to ensure the WebView2 COM thread can interrupt the main script safely.
Volatile Func __UserEventHandler__OnAcceleratorKeyPressed($oWebV2M, $hGUI, $oArgs)
	Local Const $sArgsList = '[VirtualKey=' & $oArgs.VirtualKey & _ ; The VK code of the key.
			'; KeyEventKind=' & $oArgs.KeyEventKind & _             ; Type of key event (Down, Up, etc.).
			'; Handled=' & $oArgs.Handled & _                       ; Set to `True` to stop the browser from processing the key.
			'; RepeatCount=' & $oArgs.RepeatCount & _               ; The number of times the key has repeated.
			'; ScanCode=' & $oArgs.ScanCode & _                     ; Hardware scan code.
			'; IsExtendedKey=' & $oArgs.IsExtendedKey & _           ; True if it's an extended key (e.g., right Alt).
			'; IsMenuKeyDown=' & $oArgs.IsMenuKeyDown & _           ; True if Alt is pressed.
			'; WasKeyDown=' & $oArgs.WasKeyDown & _                 ; True if the key was already down.
			'; IsKeyReleased=' & $oArgs.IsKeyReleased & _           ; True if the event is a key up.
			'; KeyEventLParam=' & $oArgs.KeyEventLParam & ']'       ; Gets the LPARAM value that accompanied the window message.

	Local Const $s_Prefix = "[USER:EVENT: OnAcceleratorKeyPressed]:: GUI:" & $hGUI & " ARGS: " & ((IsObj($oArgs)) ? ($sArgsList) : ('ERROR'))

	; Example of checking specific keys
	Switch $oArgs.VirtualKey
		Case Int($VK_F7)
			ConsoleWrite("! Blocked: F7 caret browsing." & @CRLF)
			$oArgs.Handled = True

		Case Int($VK_N)
			; Check if Ctrl is pressed (using _IsPressed for Ctrl as IsMenuKeyDown specifically targets Alt)
			; Use this to block shortcuts like Ctrl+N (New Window)
			If _IsPressed("11") Then
				ConsoleWrite("! Blocked: Ctrl+N shortcut." & @CRLF)
				$oArgs.Handled = True
			EndIf

		Case Int($VK_ESCAPE) ; ESC 27 1b 033 Escape
			; Cancels active downloads. If `uri` is empty or omitted, cancels all active downloads.
			$oWebV2M.CancelDownloads()

	EndSwitch

	__NetWebView2_Log(@ScriptLineNumber, $s_Prefix, 0)

EndFunc   ;==>__UserEventHandler__OnAcceleratorKeyPressed
#EndRegion ; === EVENT HANDLERS ===

Func __Example_Log($s_ScriptLineNumber, $sString, $iError = @error, $iExtended = @extended)
	ConsoleWrite(@ScriptName & ' SLN=' & $s_ScriptLineNumber & ' [' & $iError & '/' & $iExtended & '] ::: ' & $sString & @CRLF)
	Return SetError($iError, $iExtended, '')
EndFunc   ;==>__Example_Log
