#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Run_AU3Check=Y
#AutoIt3Wrapper_AU3Check_Stop_OnWarning=y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7
#Au3Stripper_Ignore_Funcs=__NetWebView2_WebEvents_*,__NetWebView2_JSEvents_*

; 015-CSV_Viewer.au3

#include <Array.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include "..\NetWebView2Lib.au3"

_Example()

Func _Example()
	ConsoleWrite("! MicrosoftEdgeWebview2 : version check: " & _NetWebView2_IsAlreadyInstalled() & ' ERR=' & @error & ' EXT=' & @extended & @CRLF)

	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc)
	#forceref $oMyError

	; Create GUI with resizing support
	Local $hGUI = GUICreate("WebView2AutoIt CSV Viewer", 500, 650, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPCHILDREN))
	GUISetBkColor(0x2B2B2B, $hGUI)

	; GUI Controls for CSV interaction
	Local $idLoadFile = GUICtrlCreateLabel("Load CSV", 280, 10, 90, 30)
	GUICtrlSetFont(-1, 12, Default, $GUI_FONTUNDER, "Segoe UI")
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetColor(-1, 0x00CCFF) ; Light Blue

	; Initialize WebView2 Manager and register events
	Local $oWebV2M = _NetWebView2_CreateManager()
	If @error Then Return SetError(@error, @extended, $oWebV2M)

	; Initialize JavaScript Bridge
	Local $oJSBridge = _NetWebView2_GetBridge($oWebV2M)
	If @error Then Return SetError(@error, @extended, $oWebV2M)

	Local $sProfileDirectory = @ScriptDir & "\NetWebView2Lib-UserDataFolder"
	_NetWebView2_Initialize($oWebV2M, $hGUI, $sProfileDirectory, 0, 50, 0, 0, True, True, 1.2, "0x2B2B2B")

	; Initial CSV display
	_Web_CSVViewer($oWebV2M) ; 🏆 https://stackblitz.com/edit/web-platform-3kkvy2?file=index.html

	GUISetState(@SW_SHOW)

	; Main Application Loop
	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				Exit

			Case $idLoadFile
				Local $sFilePath = FileOpenDialog("Select CSV File", @ScriptDir, "CSV Files (*.csv;*.txt)", 1)
				If Not @error Then
					Local $sFileData = FileRead($sFilePath)
					If $sFileData <> "" Then
						_Web_CSVViewer($oWebV2M, $sFileData) ; Re-render CSV with new data
						__NetWebView2_Log(@ScriptLineNumber, "+ Loaded CSV from: " & $sFilePath)
					EndIf
				EndIf

		EndSwitch
	WEnd

	_NetWebView2_CleanUp($oWebV2M, $oJSBridge)
EndFunc   ;==>_Example

#Region ; === UTILS ===
Func _Web_CSVViewer(ByRef $oWeb, $sFileData = "")
	; 1. CSS - Dark Theme
	Local $sCSS = "body { background-color: #2b2b2b; color: white; font-family: 'Segoe UI', sans-serif; margin: 0; padding: 0; }" & _
			".container { width: 100%; padding: 20px; box-sizing: border-box; }" & _
			"h1 { font-size: 1.5rem; margin-bottom: 20px; color: #00CCFF; text-align: center; }" & _
			"table { border-collapse: collapse; width: 100%; background: #333; box-shadow: 0 4px 8px rgba(0,0,0,0.5); }" & _
			"th, td { border: 1px solid #444; padding: 12px 8px; text-align: left; }" & _
			"th { background-color: #444; color: #00CCFF; position: sticky; top: 0; }" & _
			"tr:nth-child(even) { background-color: #383838; }" & _
			"tr:hover { background-color: #4a4a4a; }"

	; 2. JavaScript - Preparing data for safe insertion into JS
	Local $sSafeData = StringReplace($sFileData, "\", "\\")
	$sSafeData = StringReplace($sSafeData, "'", "\'")
	$sSafeData = StringReplace($sSafeData, @CRLF, "\n")
	$sSafeData = StringReplace($sSafeData, @LF, "\n")

	Local $sJS = "const table = document.getElementById('table');" & @CRLF & _
			"function renderCSV(csvData) {" & @CRLF & _
			"    if (!csvData) return;" & @CRLF & _
			"    const rows = csvData.split(/\n/);" & @CRLF & _
			"    let html = '';" & @CRLF & _
			"    rows.forEach((row, index) => {" & @CRLF & _
			"        if (row.trim() === '') return;" & @CRLF & _
			"        const cells = row.split(',');" & @CRLF & _
			"        html += '<tr>';" & @CRLF & _
			"        cells.forEach(cell => {" & @CRLF & _
			"            const tag = index === 0 ? 'th' : 'td';" & @CRLF & _
			"            html += `<${tag}>${cell.trim()}</${tag}>`;" & @CRLF & _
			"        });" & @CRLF & _
			"        html += '</tr>';" & @CRLF & _
			"    });" & @CRLF & _
			"    table.innerHTML = html;" & @CRLF & _
			"}" & @CRLF & _
			"if ('" & $sSafeData & "' !== '') { renderCSV('" & $sSafeData & "'); }"

	; 3. HTML Structure
	Local $sHTML = "<html><head><meta charset='UTF-8'><style>" & $sCSS & "</style></head><body>" & _
			"<div class='container'>" & _
			"  <table id='table'></table>" & _
			"</div>" & _
			"<script>" & $sJS & "</script>" & _
			"</body></html>"

	; 4. Loading - using NavigateToString to refresh all the content
	_NetWebView2_NavigateToString($oWeb, $sHTML)

EndFunc   ;==>_Web_CSVViewer
#EndRegion ; === UTILS ===
