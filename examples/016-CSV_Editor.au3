#WIP - this Example is imported from 1.5.0 UDF - and is in "WORK IN PROGRESS" state

#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Run_AU3Check=Y
#AutoIt3Wrapper_AU3Check_Stop_OnWarning=y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7
#Au3Stripper_Ignore_Funcs=__NetWebView2_WebEvents_*,__NetWebView2_JSEvents_*

; CSV_editor.au3

#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <Array.au3>

; Register exit function to ensure clean WebView2 shutdown
OnAutoItExitRegister("_ExitApp")

; Global objects
Global $oWeb, $oJS
Global $oMyError = ObjEvent("AutoIt.Error", _ErrFunc) ; COM Error Handler
Global $g_DebugInfo = True
Global $sProfileDirectory = @ScriptDir & "\UserDataFolder"
Global $hGUI

_Example()

Func _Example()
	; Create GUI with resizing support
	$hGUI = GUICreate("WebView2AutoIt CSV_editor", 1500, 650, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPCHILDREN))
	GUISetBkColor(0x2B2B2B, $hGUI)

	; GUI Controls for CSV interaction
	Local $idSaveFile = GUICtrlCreateLabel("Save CSV", 100, 10, 90, 30)
	GUICtrlSetFont(-1, 12, Default, $GUI_FONTUNDER, "Segoe UI")
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetColor(-1, 0x4CFF00) ; Chartreuse

	Local $idLoadFile = GUICtrlCreateLabel("Load CSV", 280, 10, 90, 30)
	GUICtrlSetFont(-1, 12, Default, $GUI_FONTUNDER, "Segoe UI")
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetColor(-1, 0x00CCFF) ; Light Blue

	; Initialize WebView2 Manager and register events
	$oWeb = ObjCreate("NetWebView2.Manager")
	ObjEvent($oWeb, "WebEvents_", "IWebViewEvents")

	; Important: Pass $hGUI in parentheses to maintain Pointer type for COM
	$oWeb.Initialize(($hGUI), $sProfileDirectory, 0, 50, 1500, 600)

	; Initialize JavaScript Bridge
	$oJS = $oWeb.GetBridge()
	ObjEvent($oJS, "JavaScript_", "IBridgeEvents")

	; Wait for WebView2 to be ready
	Do
		Sleep(50)
	Until $oWeb.IsReady

	; WebView2 Configuration
	$oWeb.SetAutoResize(True) ; Using SetAutoResize(True) to skip WM_SIZE
	$oWeb.BackColor = "0x2B2B2B"
	$oWeb.AreDevToolsEnabled = True ; Allow F12
	$oWeb.ZoomFactor = 1.2

	; Initial CSV display
	_Web_CSVViewer($oWeb) ; 🏆 https://stackblitz.com/edit/web-platform-3kkvy2?file=index.html

	GUISetState(@SW_SHOW)

	; Main Application Loop
	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				Exit

			Case $idSaveFile
				$oWeb.ExecuteScript("sendDataToAutoIt();")

			Case $idLoadFile
				Local $sFilePath = FileOpenDialog("Select CSV File", @ScriptDir, "CSV Files (*.csv;*.txt)", 1)
				If Not @error Then
					Local $sFileData = FileRead($sFilePath)
					If $sFileData <> "" Then
						_Web_CSVViewer($oWeb, $sFileData) ; Re-render CSV with new data
						__DW("+ Loaded CSV from: " & $sFilePath)
					EndIf
				EndIf

		EndSwitch
	WEnd
EndFunc   ;==>_Example

#Region ; === EVENT HANDLERS ===

; Handles native WebView2 events
Func WebEvents_OnMessageReceived($sMsg)
	__DW("+++ [WebEvents]: " & (StringLen($sMsg) > 150 ? StringLeft($sMsg, 150) & "..." : $sMsg) & @CRLF, 0)
	Local $iSplitPos = StringInStr($sMsg, "|")
	Local $sCommand = $iSplitPos ? StringStripWS(StringLeft($sMsg, $iSplitPos - 1), 3) : $sMsg
	Local $sData = $iSplitPos ? StringTrimLeft($sMsg, $iSplitPos) : ""
	Local $aParts

	Switch $sCommand
		Case "INIT_READY"
			$oWeb.ExecuteScript('window.chrome.webview.postMessage(JSON.stringify({ "type": "COM_TEST", "status": "OK" }));')

		Case "WINDOW_RESIZED"
			$aParts = StringSplit($sData, "|")
			If $aParts[0] >= 2 Then
				Local $iW = Int($aParts[1]), $iH = Int($aParts[2])
				; Filter minor resize glitches
				If $iW > 50 And $iH > 50 Then __DW("WINDOW_RESIZED : " & $iW & "x" & $iH & @CRLF)
			EndIf
	EndSwitch
EndFunc   ;==>WebEvents_OnMessageReceived

; Handles custom messages from JavaScript (window.chrome.webview.postMessage)
Func JavaScript_OnMessageReceived($sMsg)
	__DW(">>> [JavaScript]: " & (StringLen($sMsg) > 150 ? StringLeft($sMsg, 150) & "..." : $sMsg) & @CRLF, 0)
	Local $sFirstChar = StringLeft($sMsg, 1)

	; 1. JSON Messaging
	If $sFirstChar = "{" Or $sFirstChar = "[" Then
		__DW("+> : Processing JSON Messaging..." & @CRLF)
		Local $oJson = ObjCreate("NetJson.Parser")
		If Not IsObj($oJson) Then Return ConsoleWrite("!> Error: Failed to create NetJson object." & @CRLF)

		$oJson.Parse($sMsg)
		Local $sJobType = $oJson.GetTokenValue("type")

		Switch $sJobType
			Case "COM_TEST"
				__DW("- COM_TEST Confirmed: " & $oJson.GetTokenValue("status") & @CRLF)
		EndSwitch

	Else
		; 2. Legacy / Native Pipe-Delimited Messaging
		__DW("+> : Legacy / Native Pipe-Delimited Messaging..." & @CRLF, 0)
		Local $sCommand, $sData, $iSplitPos
		$iSplitPos = StringInStr($sMsg, "|") - 1

		If $iSplitPos < 0 Then
			$sCommand = StringStripWS($sMsg, 3)
			$sData = ""
		Else
			$sCommand = StringStripWS(StringLeft($sMsg, $iSplitPos), 3)
			$sData = StringTrimLeft($sMsg, $iSplitPos + 1)
		EndIf

		Switch $sCommand
			Case "JSON_CLICKED"
				Local $aClickData = StringSplit($sData, "=", 2) ; Split "Key = Value"
				If UBound($aClickData) >= 2 Then
					Local $sKey = StringStripWS($aClickData[0], 3)
					Local $sVal = StringStripWS($aClickData[1], 3)
					__DW("+++ Property: " & $sKey & " | Value: " & $sVal & @CRLF)
				EndIf

			Case "COM_TEST"
				__DW("- Status: Legacy COM_TEST: " & $sData & @CRLF)

			Case "CSV_UPDATED"
				; Clean up literal \n sent by JS to real @CRLF for AutoIt
				Local $sCleanData = StringReplace($sData, "\n", @CRLF)

				; Here you define what you want to do with the data
				; E.g. Save to a file so that changes are not lost
				Local $hFile = FileOpen(@ScriptDir & "\updated_data.csv", 2) ; 2 = Overwrite
				If $hFile <> -1 Then
					FileWrite($hFile, $sCleanData)
					FileClose($hFile)
					__DW("- CSV saved to file successfully!")
				EndIf

			Case "ERROR"
				__DW("! Status: " & $sData & @CRLF)
		EndSwitch
	EndIf
EndFunc   ;==>JavaScript_OnMessageReceived

Func WebEvents_OnContextMenuRequested($sLink, $iX, $iY, $sSelection)
	#forceref $sLink, $iX, $iY, $sSelection
EndFunc   ;==>WebEvents_OnContextMenuRequested

#EndRegion ; === EVENT HANDLERS ===

#Region ; === UTILS ===

Func _Web_CSVViewer(ByRef $oWeb, $sFileData = "")
	Local $sSafeData = StringReplace($sFileData, "\", "\\")
	$sSafeData = StringReplace($sSafeData, "'", "\'")
	$sSafeData = StringReplace($sSafeData, @CRLF, "\n")
	$sSafeData = StringReplace($sSafeData, @LF, "\n")

	Local $sCSS = "body { background-color: #2b2b2b; color: white; font-family: 'Segoe UI', sans-serif; margin: 0; padding: 0; }" & _
			".container { width: 100%; padding: 20px; box-sizing: border-box; }" & _
			"h1 { font-size: 1.5rem; margin-bottom: 20px; color: #00CCFF; text-align: center; }" & _
			"table { border-collapse: collapse; width: 100%; background: #333; box-shadow: 0 4px 8px rgba(0,0,0,0.5); }" & _
			"th, td { border: 1px solid #444; padding: 12px 8px; text-align: left; }" & _
			"th { background-color: #444; color: #00CCFF; position: sticky; top: 0; }" & _
			"tr:nth-child(even) { background-color: #383838; }" & _
			"tr:hover { background-color: #4a4a4a; }"

	Local $sJS = "const table = document.getElementById('table');" & @CRLF & _
			"function renderCSV(csvData) {" & @CRLF & _
			"    const rows = csvData.split(/\r?\n/);" & @CRLF & _
			"    let html = '';" & @CRLF & _
			"    rows.forEach((row, index) => {" & @CRLF & _
			"        if (row.trim() === '') return;" & @CRLF & _
			"        const cells = row.split(',');" & @CRLF & _
			"        html += '<tr>';" & @CRLF & _
			"        cells.forEach(cell => {" & @CRLF & _
			"            const tag = index === 0 ? 'th' : 'td';" & @CRLF & _
			"            const editable = index === 0 ? '' : 'contenteditable=""true""';" & @CRLF & _
			"            html += `<${tag} ${editable}>${cell.trim()}</${tag}>`;" & @CRLF & _
			"        });" & @CRLF & _
			"        html += '</tr>';" & @CRLF & _
			"    });" & @CRLF & _
			"    table.innerHTML = html;" & @CRLF & _
			"}" & @CRLF & _
			"function sendDataToAutoIt() {" & @CRLF & _
			"    let data = [];" & @CRLF & _
			"    Array.from(table.rows).forEach(row => {" & @CRLF & _
			"        let rowData = Array.from(row.cells).map(cell => cell.innerText.replace(/,/g, ''));" & @CRLF & _ ; Removing commas from text to avoid corrupting CSV
			"        data.push(rowData.join(','));" & @CRLF & _
			"    });" & @CRLF & _
			"    window.chrome.webview.postMessage('CSV_UPDATED|' + data.join('\\n'));" & @CRLF & _
			"}" & @CRLF & _
			"if ('" & $sSafeData & "' !== '') { renderCSV('" & $sSafeData & "'); }"

	Local $sHTML = "<html><head><meta charset='UTF-8'><style>" & $sCSS & "</style></head><body>" & _
			"<div class='container'><table id='table'></table></div>" & _
			"<script>" & $sJS & "</script></body></html>"

	$oWeb.NavigateToString($sHTML)
EndFunc   ;==>_Web_CSVViewer

Func _ErrFunc($oError) ; Global COM Error Handler
	ConsoleWrite('@@ Line(' & $oError.scriptline & ') : COM Error Number: (0x' & Hex($oError.number, 8) & ') ' & $oError.windescription & @CRLF)
EndFunc   ;==>_ErrFunc

; Debug Write utility
Func __DW($sString, $iErrorNoLineNo = 1, $iLine = @ScriptLineNumber, $iError = @error, $iExtended = @extended)
	If Not $g_DebugInfo Then Return SetError($iError, $iExtended, 0)
	Local $iReturn
	If $iErrorNoLineNo = 1 Then
		If $iError Then
			$iReturn = ConsoleWrite("@@(" & $iLine & ") :: @error:" & $iError & ", @extended:" & $iExtended & ", " & $sString)
		Else
			$iReturn = ConsoleWrite("+>(" & $iLine & ") :: " & $sString)
		EndIf
	Else
		$iReturn = ConsoleWrite($sString)
	EndIf
	Return SetError($iError, $iExtended, $iReturn)
EndFunc   ;==>__DW

Func _NetJson_New($sInitialJson = "{}")
	Local $oParser = ObjCreate("NetJson.Parser")
	If Not IsObj($oParser) Then Return SetError(1, 0, 0)
	If $sInitialJson <> "" Then $oParser.Parse($sInitialJson)
	Return $oParser
EndFunc   ;==>_NetJson_New

Func _ExitApp()
	If IsObj($oWeb) Then $oWeb.Cleanup()
	$oWeb = 0
	$oJS = 0
	Exit
EndFunc   ;==>_ExitApp

#EndRegion ; === UTILS ===
