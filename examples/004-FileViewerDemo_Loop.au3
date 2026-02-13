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
	; Create the UI
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
	_NetWebView2_Initialize($oWebV2M, $hMainGUIWindow, $sProfileDirectory, 0, 0, 0, $iHeight - 20, True, True, True, 1.2, "0x2B2B2B")
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
			_NetWebView2_NavigateToPDF($oWebV2M, $s_PDF_FileFullPath, '#view=FitH', 1000, True)
			GUICtrlSetData($idLabelStatus, $sProgress & ' - Navigation completed: ' & $s_PDF_FileFullPath)
			ConsoleWrite("! === @SLN=" & @ScriptLineNumber & ' ' & $s_PDF_FileFullPath & @CRLF)
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

Func __NetWebView2_freezer($oWebV2M, ByRef $idPic)
	Local $hWebView2_Window = WinGetHandle($oWebV2M.BrowserWindowHandle)
	#Region ; if $idPic is given then it means you already have it and want to delete it - unfreeze - show WebView2 content
	If $idPic Then
		_SendMessage($hWebView2_Window, $WM_SETREDRAW, True, 0) ; Enables
		_WinAPI_RedrawWindow($hWebView2_Window, 0, 0, BitOR($RDW_FRAME, $RDW_INVALIDATE, $RDW_ALLCHILDREN))  ; Repaints
		GUICtrlDelete($idPic)
		$idPic = 0
		Return
	EndIf
	#EndRegion ; if $idPic is given then it means you already have it and want to delete it - unfreeze - show WebView2 content

	#Region ; freeze $hWebView2_Window

	#Region ; add PIC to parent window
	Local $hMainGUI_Window = _WinAPI_GetWindow($hWebView2_Window, $GW_HWNDPREV)
	Local $aPos = WinGetPos($hWebView2_Window)
;~ 	_ArrayDisplay($aPos, '$aPos ' & @ScriptLineNumber)
	Local $hPrev = GUISwitch($hMainGUI_Window)
	$idPic = GUICtrlCreatePic('', 0, 0, $aPos[2], $aPos[3])
	Local $hPic = GUICtrlGetHandle($idPic)
	GUISwitch($hPrev)
	#EndRegion ; add PIC to parent window

	; Create bitmap
	Local $hDC = _WinAPI_GetDC($hPic)
	Local $hDestDC = _WinAPI_CreateCompatibleDC($hDC)
	Local $hBitmap = _WinAPI_CreateCompatibleBitmap($hDC, $aPos[2], $aPos[3])
	Local $hDestSv = _WinAPI_SelectObject($hDestDC, $hBitmap)
	Local $hSrcDC = _WinAPI_CreateCompatibleDC($hDC)
	Local $hBmp = _WinAPI_CreateCompatibleBitmap($hDC, $aPos[2], $aPos[3])
	Local $hSrcSv = _WinAPI_SelectObject($hSrcDC, $hBmp)
	_WinAPI_PrintWindow($hWebView2_Window, $hSrcDC, 2)
	_WinAPI_BitBlt($hDestDC, 0, 0, $aPos[2], $aPos[3], $hSrcDC, 0, 0, $MERGECOPY)

	_WinAPI_ReleaseDC($hPic, $hDC)
	_WinAPI_SelectObject($hDestDC, $hDestSv)
	_WinAPI_SelectObject($hSrcDC, $hSrcSv)
	_WinAPI_DeleteDC($hDestDC)
	_WinAPI_DeleteDC($hSrcDC)
	_WinAPI_DeleteObject($hBmp)

	; Set bitmap to control
	_SendMessage($hPic, $STM_SETIMAGE, 0, $hBitmap)
	Local $hObj = _SendMessage($hPic, $STM_GETIMAGE)
	If $hObj <> $hBitmap Then
		_WinAPI_DeleteObject($hBitmap)
	EndIf

	_SendMessage($hWebView2_Window, $WM_SETREDRAW, False, 0) ; Disables ; https://www.autoitscript.com/forum/topic/199172-disable-gui-updating-repainting/
	Return $idPic
	#EndRegion ; freeze $hWebView2_Window
EndFunc   ;==>__NetWebView2_freezer

Func _NetWebView2_NavigateToPDF($oWebV2M, $s_URL_or_FileFullPath, Const $s_Parameters = '', Const $iSleep_ms = 1000, Const $bFreeze = True)
	If FileExists($s_URL_or_FileFullPath) Then
		$s_URL_or_FileFullPath = StringReplace($s_URL_or_FileFullPath, '\', '/')
		$s_URL_or_FileFullPath = StringReplace($s_URL_or_FileFullPath, ' ', '%20')
		$s_URL_or_FileFullPath = "file:///" & $s_URL_or_FileFullPath
	EndIf

	If $s_Parameters Then
		$s_URL_or_FileFullPath &= $s_Parameters
		#TIP: FitToPage: https://stackoverflow.com/questions/78820187/how-to-change-webview2-fit-to-page-button-on-pdf-toolbar-default-to-fit-to-width#comment138971950_78821231
		#TIP: Open desired PAGE: https://stackoverflow.com/questions/68500164/cycle-pdf-pages-in-wpf-webview2#comment135402565_68566860
	EndIf

	Local $idPic = 0
	If $bFreeze Then __NetWebView2_freezer($oWebV2M, $idPic)
	_NetWebView2_Navigate($oWebV2M, $s_URL_or_FileFullPath)
	Sleep($iSleep_ms)
	If $bFreeze And $idPic Then __NetWebView2_freezer($oWebV2M, $idPic)

EndFunc   ;==>_NetWebView2_NavigateToPDF
