#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Run_AU3Check=Y
#AutoIt3Wrapper_AU3Check_Stop_OnWarning=y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7

; 025_Example_XlsxViewer.au3

#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <FileConstants.au3>

#include "..\NetWebView2Lib.au3"

; 🏆 https://cdn.sheetjs.com/xlsx-latest/package/dist/xlsx.full.min.js

$_g_bNetWebView2_DebugInfo = False

_Example_XlsxViewer()

Func _Example_XlsxViewer()
	ConsoleWrite("! MicrosoftEdgeWebview2 : version check: " & _NetWebView2_IsAlreadyInstalled() & ' ERR=' & @error & ' EXT=' & @extended & @CRLF)

	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc)
	#forceref $oMyError

	#Region ; GUI CREATION
	Local $hGUI = GUICreate("WebView2 - Dynamic Excel Viewer", 900, 750, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPCHILDREN))
	GUISetBkColor(0x2B2B2B, $hGUI)

	; Label to open File Dialog
	Local $idLoadFile = GUICtrlCreateLabel("Load Excel Document", 20, 10, 180, 30)
	GUICtrlSetFont(-1, 12, Default, $GUI_FONTUNDER, "Segoe UI")
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetColor(-1, 0x00CCFF) ; Light Blue

	; Initialize Manager with Chromium flag for local file access
	Local $oWebV2M = _NetWebView2_CreateManager("", "", "--allow-file-access-from-files")
	If @error Then Return SetError(@error, @extended, $oWebV2M)

	Local $sProfileDirectory = @ScriptDir & "\NetWebView2Lib-UserDataFolder"
	; Reserve 40px top offset for control panel
	_NetWebView2_Initialize($oWebV2M, $hGUI, $sProfileDirectory, 0, 40, 0, 0, True, True, 1.2, "0x2B2B2B")

	; Set Virtual Mapping
	Local $sMappedFolder = @ScriptDir & "\JS_Lib\excelviewer"
	_NetWebView2_SetVirtualHostNameToFolderMapping($oWebV2M, "excelviewer.local", $sMappedFolder, 0)

	; Navigate to the HTML viewer page
	_NetWebView2_Navigate($oWebV2M, "https://excelviewer.local/index.html")

	GUISetState(@SW_SHOW)
	#EndRegion ; GUI CREATION

	#Region ; GUI Loop
	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				ExitLoop

			Case $idLoadFile
				Local $sFilePath = FileOpenDialog("Select Excel Document", @ScriptDir, "Excel Files (*.xlsx;*.xls)", 1)
				If Not @error Then
					; Copy selected file to MappedFolder as active_file.xlsx
					Local $sTargetFile = $sMappedFolder & "\active_file.xlsx"
					FileCopy($sFilePath, $sTargetFile, $FC_OVERWRITE)

					; Call JS function using _NetWebView2_ExecuteScript (Mode 0: Fire-and-Forget)
					_NetWebView2_ExecuteScript($oWebV2M, "renderLocalXlsx('active_file.xlsx');")
				EndIf

		EndSwitch
	WEnd

	Local $oJSBridge
	_NetWebView2_CleanUp($oWebV2M, $oJSBridge)
	GUIDelete($hGUI)
	#EndRegion ; GUI Loop

EndFunc   ;==>_Example_XlsxViewer