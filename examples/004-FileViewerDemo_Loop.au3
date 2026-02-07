#AutoIt3Wrapper_UseX64=y
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

Main()

Func Main()
	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc)
	#forceref $oMyError

	; Create the UI
	Local $iHeight = 800
	Local $hGUI = GUICreate("WebView2 .NET Manager - Demo: " & @ScriptName, 1100, $iHeight, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPCHILDREN))
	Local $idLabelStatus = GUICtrlCreateLabel("Status: Initializing Engine...", 10, $iHeight - 20, 880, 20)
	#forceref $idLabelStatus
	GUICtrlSetFont(-1, 9, 400, 0, "Segoe UI")

	; Initialize WebView2 Manager and register events
	Local $oWebV2M = _NetWebView2_CreateManager("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0", "", "--mute-audio")
	If @error Then Return SetError(@error, @extended, $oWebV2M)

;~ 	; Initialize JavaScript Bridge
;~ 	Local $oJSBridge = _NetWebView2_GetBridge($oWebV2M, "_BridgeMyEventsHandler_")
;~ 	If @error Then Return SetError(@error, @extended, $oWebV2M)

	Local $sProfileDirectory = @TempDir & "\..\UserDataFolder"
	_NetWebView2_Initialize($oWebV2M, $hGUI, $sProfileDirectory, 0, 0, 0, $iHeight - 20, True, True, True, 1.2, "0x2B2B2B")
	Local $i_ProcessID = @extended
	#forceref $i_ProcessID

	GUISetState(@SW_SHOW, $hGUI)
	ConsoleWrite("! ===" & @ScriptLineNumber & @CRLF)
;~ 	MsgBox($MB_TOPMOST, "TEST #" & @ScriptLineNumber, 0)
	Local $s_PDF_FileFullPath

	Local $s_PDF_Directory = FileSelectFolder('Choose folder with PDF', '')

	Local $a_Files = _FileListToArrayRec($s_PDF_Directory, '*.pdf', $FLTAR_FILES, $FLTAR_RECUR, $FLTAR_NOSORT, $FLTAR_FULLPATH)
	Local Static $hWebView2_Window = _WinAPI_GetWindow($hGUI, $GW_CHILD)
	For $IDX_File = 1 To $a_Files[0]
		$s_PDF_FileFullPath = $a_Files[$IDX_File]
		_NetWebView2_NavigateToPDF($oWebV2M, $s_PDF_FileFullPath, $hWebView2_Window, '#view=FitH', 1000)
		ConsoleWrite("! === @SLN=" & @ScriptLineNumber & ' ' & $s_PDF_FileFullPath & @CRLF)
	Next

	; Main Loop
	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				ExitLoop
		EndSwitch
	WEnd

	_NetWebView2_CleanUp($oWebV2M)
	GUIDelete($hGUI)
EndFunc   ;==>Main

Func _EnumWindow($hWnd)
	Local $aData = _WinAPI_EnumChildWindows($hWnd)
	ConsoleWrite("! $aData[1][0] = " & $aData[1][0] & @CRLF)
;~ 	_ArrayDisplay($aData, '_WinAPI_EnumChildWindows')

	If Not @error And UBound($aData) Then Return $aData[1][0]

	Return SetError(1, @extended, False)
EndFunc   ;==>_EnumWindow

Func __NetWebView2_freezer($hWebView2_Window, $idPic = 0)
	#Region ; if $idPic is given then it means you already have it and want to delete it - unfreeze - show WebView2 content
	If $idPic Then
		_SendMessage($hWebView2_Window, $WM_SETREDRAW, True, 0) ; Enables
		_WinAPI_RedrawWindow($hWebView2_Window, 0, 0, BitOR($RDW_FRAME, $RDW_INVALIDATE, $RDW_ALLCHILDREN))  ; Repaints
		GUICtrlDelete($idPic)
		Return
	EndIf
	#EndRegion ; if $idPic is given then it means you already have it and want to delete it - unfreeze - show WebView2 content

	#Region ; freeze $hWebView2_Window

	#Region ; add PIC to parent window
	Local $hMainGUI_Window = _WinAPI_GetWindow($hWebView2_Window, $GW_HWNDPREV)
	Local $aPos = WinGetPos($hWebView2_Window)
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

Func _NetWebView2_NavigateToPDF($oWebV2M, $s_URL_or_FileFullPath, $hWebView2_Window = 0, $s_Parameters = '', $iSleep_ms = 1000)
	Local $idPic
	If FileExists($s_URL_or_FileFullPath) Then
		$s_URL_or_FileFullPath = StringReplace($s_URL_or_FileFullPath, ' ', '%20')
		$s_URL_or_FileFullPath = "file:///" & $s_URL_or_FileFullPath
		If $iSleep_ms Then
			$iSleep_ms -= 400
			If $iSleep_ms < 600 Then $iSleep_ms = 600
		EndIf
	EndIf

	If $s_Parameters Then
		$s_URL_or_FileFullPath &= $s_Parameters
		#TIP: FitToPage: https://stackoverflow.com/questions/78820187/how-to-change-webview2-fit-to-page-button-on-pdf-toolbar-default-to-fit-to-width#comment138971950_78821231
		#TIP: Open desired PAGE: https://stackoverflow.com/questions/68500164/cycle-pdf-pages-in-wpf-webview2#comment135402565_68566860
	EndIf

	If $hWebView2_Window Then $idPic = __NetWebView2_freezer($hWebView2_Window)

	_NetWebView2_Navigate($oWebV2M, $s_URL_or_FileFullPath)
	Sleep($iSleep_ms)
	If $hWebView2_Window Then
		__NetWebView2_freezer($hWebView2_Window, $idPic)
	EndIf
EndFunc   ;==>_NetWebView2_NavigateToPDF
