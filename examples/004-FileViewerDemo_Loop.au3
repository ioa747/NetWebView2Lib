#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Run_AU3Check=Y
#AutoIt3Wrapper_AU3Check_Stop_OnWarning=y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7

; 004-FileViewerDemo_Loop.au3

#include <File.au3>
#include <GUIConstantsEx.au3>
#include <SendMessage.au3>
#include <StaticConstants.au3>
#include <WinAPIGdi.au3>
#include <WinAPIGdiDC.au3>
#include <WinAPIHObj.au3>
#include <WinAPISysWin.au3>
#include <WindowsConstants.au3>

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

#TODO MainGui CloseButton support ==> ;

_Example()

Func _Example()
	ConsoleWrite("! MicrosoftEdgeWebview2 : version check: " & _NetWebView2_IsAlreadyInstalled() & ' ERR=' & @error & ' EXT=' & @extended & @CRLF)

	; Create the GUI
	Local $iHeight = 800
	Local $hMainGUIWindow = GUICreate("WebView2 .NET Manager - Demo: " & @ScriptName, 1100, $iHeight, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPCHILDREN))
	Local $idLabelStatus = GUICtrlCreateLabel("Status: Initializing Engine...", 10, $iHeight - 20, 1080, 20)
	GUICtrlSetFont(-1, 9, 400, 0, "Segoe UI")

	; Initialize WebView2 Manager and register events
	Local $oWebV2M = _NetWebView2_CreateManager("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0", "", "--mute-audio")
	If @error Then Return SetError(@error, @extended, $oWebV2M)

	ConsoleWrite("! " & _NetWebView2_GetVersion($oWebV2M) & @CRLF)

;~ 	; Initialize JavaScript Bridge
;~ 	Local $oJSBridge = _NetWebView2_GetBridge($oWebV2M, "_BridgeMyEventsHandler_")
;~ 	If @error Then Return SetError(@error, @extended, $oWebV2M)

	Local $sProfileDirectory = @ScriptDir & "\NetWebView2Lib-UserDataFolder"
	_NetWebView2_Initialize($oWebV2M, $hMainGUIWindow, $sProfileDirectory, 0, 0, 0, $iHeight - 20, True, True, 1.2, "0x2B2B2B")
	Local $i_ProcessID = @extended
	#forceref $i_ProcessID

	GUISetState(@SW_SHOW, $hMainGUIWindow)
	ConsoleWrite("! ===" & @ScriptLineNumber & @CRLF)
;~ 	MsgBox($MB_TOPMOST, "TEST #" & @ScriptLineNumber, 0)
	Local $s_PDF_FileFullPath

	Local $s_PDF_Directory = FileSelectFolder('Choose folder with PDF', @ScriptDir)

	WinSetOnTop($hMainGUIWindow, "", $WINDOWS_ONTOP)

	Local $bSleep_UserReaction = ($IDYES = MsgBox($MB_YESNO + $MB_TOPMOST + $MB_ICONQUESTION + $MB_DEFBUTTON1, "Question", "Simulates user reaction on PDF (2 sec sleep) ?"))

	Local $a_Files = _FileListToArrayRec($s_PDF_Directory, '*.pdf', $FLTAR_FILES, $FLTAR_RECUR, $FLTAR_NOSORT, $FLTAR_FULLPATH)
	If Not @error Then
		Local $sProgress = ''
		For $IDX_File = 1 To $a_Files[0]
			$sProgress = '[ ' & $IDX_File & '/' & $a_Files[0] & ' - ' & Round($IDX_File / $a_Files[0], 5) * 100 & ' % ]'

			$s_PDF_FileFullPath = $a_Files[$IDX_File]
			GUICtrlSetData($idLabelStatus, $sProgress & ' - Navigation started: ' & $s_PDF_FileFullPath)
			_NetWebView2_NavigateToPDF($oWebV2M, $s_PDF_FileFullPath, '#view=FitH', $NETWEBVIEW2_MESSAGE__TITLE_CHANGED, Default, 5000, 1000, True)
			GUICtrlSetData($idLabelStatus, $sProgress & ' - Navigation completed: ' & $s_PDF_FileFullPath)
			ConsoleWrite("! =Example= @SLN=" & @ScriptLineNumber & ' NAVIGATION COMPLETED FOR: ' & $s_PDF_FileFullPath & @CRLF)
			If $bSleep_UserReaction Then Sleep(2000) ; simulates user reaction on PDF
		Next
	EndIf

	; Main Loop
	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				ExitLoop
		EndSwitch
	WEnd

	Local $oJSBridge
	_NetWebView2_CleanUp($oWebV2M, $oJSBridge)
	GUIDelete($hMainGUIWindow)
EndFunc   ;==>_Example

