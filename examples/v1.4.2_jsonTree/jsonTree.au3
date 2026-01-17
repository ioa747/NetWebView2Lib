#AutoIt3Wrapper_UseX64=y
; Html_Gui.au3
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <Array.au3>

; Register exit function to ensure clean WebView2 shutdown
OnAutoItExitRegister("_ExitApp")

; Global objects
Global $oWeb, $oJS
Global $oMyError = ObjEvent("AutoIt.Error", "_ErrFunc") ; COM Error Handler
Global $g_DebugInfo = True
Global $g_sProfilePath = @ScriptDir & "\UserDataFolder"
Global $hGUI

Main()

Func Main()
	; Create GUI with resizing support
	$hGUI = GUICreate("WebView2AutoIt JSON Viewer", 500, 650, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPCHILDREN))
	GUISetBkColor(0x2B2B2B, $hGUI)

	; GUI Controls for JSON Tree interaction
	Local $idExpand = GUICtrlCreateLabel("Expand All", 10, 10, 90, 30)
	GUICtrlSetFont(-1, 12, Default, $GUI_FONTUNDER, "Segoe UI")
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetColor(-1, 0x00FF00) ; Green

	Local $idCollapse = GUICtrlCreateLabel("Collapse All", 110, 10, 90, 30)
	GUICtrlSetFont(-1, 12, Default, $GUI_FONTUNDER, "Segoe UI")
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetColor(-1, 0xFF4D4D) ; Red

	Local $idFind = GUICtrlCreateLabel("Search", 210, 10, 60, 30)
	GUICtrlSetFont(-1, 12, Default, $GUI_FONTUNDER, "Segoe UI")
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetColor(-1, 0xFFD700) ; Gold

	Local $idLoadFile = GUICtrlCreateLabel("Load JSON", 280, 10, 90, 30)
	GUICtrlSetFont(-1, 12, Default, $GUI_FONTUNDER, "Segoe UI")
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetColor(-1, 0x00CCFF) ; Light Blue

	; Initialize WebView2 Manager and register events
	$oWeb = ObjCreate("NetWebView2.Manager")
	ObjEvent($oWeb, "WebEvents_", "IWebViewEvents")

	; Important: Pass $hGUI in parentheses to maintain Pointer type for COM
	$oWeb.Initialize(($hGUI), $g_sProfilePath, 0, 50, 500, 600)

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

	; Initial JSON display
	Local $sMyJson = '{"Game": "Witcher 3", "ID": 1, "Meta": {"Developer": "CD Projekt", "Year": 2015 }, "Tags": ["RPG", "Open World"]}'

	_Web_jsonTree($oWeb, $sMyJson) ; 🏆 https://github.com/summerstyle/jsonTreeViewer

	GUISetState(@SW_SHOW)

	Local $sLastSearch = ""

	; Main Application Loop
	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				Exit

			Case $idExpand
				; Call JavaScript expand method on the global tree object
				$oWeb.ExecuteScript("if(window.tree) window.tree.expand();")

			Case $idCollapse
				; Call JavaScript collapse method
				$oWeb.ExecuteScript("if(window.tree) window.tree.collapse();")

			Case $idFind
				Local $sInput = InputBox("JSON Search", "Enter key or value:", $sLastSearch, "", 200, 130, Default, Default, Default, $hGUI)
				If Not @error And StringLen(StringStripWS($sInput, 3)) > 0 Then
					$sLastSearch = StringStripWS($sInput, 3)
					_Web_jsonTreeFind($sLastSearch, False) ; New search
				EndIf

			Case $idLoadFile
				Local $sFilePath = FileOpenDialog("Select JSON File", @ScriptDir, "JSON Files (*.json;*.txt)", 1)
				If Not @error Then
					Local $sFileData = FileRead($sFilePath)
					If $sFileData <> "" Then
						_Web_jsonTree($oWeb, $sFileData) ; Re-render tree with new data
						__DW("+ Loaded JSON from: " & $sFilePath & @CRLF)
					EndIf
				EndIf

		EndSwitch
	WEnd
EndFunc   ;==>Main

#Region ; === EVENT HANDLERS ===

; Handles native WebView2 events
Func WebEvents_OnMessageReceived($sMsg)
	__DW("+++ [WebEvents]: " & (StringLen($sMsg) > 150 ? StringLeft($sMsg, 150) & "..." : $sMsg) & @CRLF, 0)
	Local $iSplitPos = StringInStr($sMsg, "|")
	Local $sCommand = $iSplitPos ? StringStripWS(StringLeft($sMsg, $iSplitPos - 1), 3) : $sMsg
	Local $sData = $iSplitPos ? StringTrimLeft($sMsg, $iSplitPos) : ""
	Local $aParts

	Switch $sCommand
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

	; 1. Modern JSON Messaging
	If $sFirstChar = "{" Or $sFirstChar = "[" Then
		__DW("+> : Processing JSON message..." & @CRLF)
		Local $oJson = ObjCreate("NetJson.Parser")
		If Not IsObj($oJson) Then Return ConsoleWrite("!> Error: Failed to create NetJson object." & @CRLF)

		$oJson.Parse($sMsg)
		Local $sJobType = $oJson.GetTokenValue("type")

		Switch $sJobType
			Case "CONSOLE_LOG"
				If Not _Web_DebugJStoConsole($oWeb) Then Return
				Local $sLvl = $oJson.GetTokenValue("level")
				Local $sTxt = $oJson.GetTokenValue("message")
				__DW(StringFormat("[JS-%s] %s", $sLvl, $sTxt) & @CRLF, 0)

			Case "COM_TEST"
				__DW("- COM_TEST Confirmed: " & $oJson.GetTokenValue("status") & @CRLF)
		EndSwitch

	Else
		; 2. Legacy / Native Pipe-Delimited Messaging
		__DW("+> : Processing Delimited message..." & @CRLF, 0)
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

; #FUNCTION# ====================================================================================================================
; Name...........: _Web_jsonTree
; Description....: Renders JSON data using the jsonTree library by summerstyle.
; Author.........: summerstyle (https://github.com/summerstyle/jsonTreeViewer)
; Integration....: Adapted for AutoIt WebView2
; ===============================================================================================================================
Func _Web_jsonTree(ByRef $oWeb, $sJson)
	; 1. Prepare JSON (Minify to prevent script errors from line breaks)
	Local $oJsonObj = _NetJson_New($sJson)
	$sJson = $oJsonObj.GetMinifiedJson()

	; 2. Load local library files
	Local $sJsLib = FileRead(@ScriptDir & "\.JS_Lib\jsonTree.js")
	Local $sCssLib = FileRead(@ScriptDir & "\.JS_Lib\jsonTreeDark.css")

	; 3. Build HTML with embedded Logic
	Local $sHTML = "<html><head><meta charset=""utf-8""><style>" & _
			$sCssLib & _
			"</style></head><body>" & _
			"<div id='tree-container' class='jsontree_tree'></div>" & _
			"    <div style='position:fixed; bottom:5px; right:10px; font-size:10px; color:#555; font-family:sans-serif;'>" & _
			"        Powered by <a href='https://github.com/summerstyle/jsonTreeViewer' style='color:#777; text-decoration:none;'>jsonTree</a>" & _
			"    </div>" & _
			"<script>" & @CRLF & _
			$sJsLib & @CRLF & _
			";" & @CRLF & _ ; Ensure library/code separation
			"try {" & @CRLF & _
			"    var data = " & $sJson & ";" & @CRLF & _
			"    var container = document.getElementById('tree-container');" & @CRLF & _
			"    if (typeof jsonTree !== 'undefined') {" & @CRLF & _
			"        window.tree = jsonTree.create(data, container);" & @CRLF & _ ; Assign to window for global access
			"        window.tree.expand(1);" & @CRLF & _
			"        container.addEventListener('click', function(e) {" & @CRLF & _
			"            var node = e.target.closest('.jsontree_node');" & @CRLF & _
			"            if (node) {" & @CRLF & _
			"                var labelEl = node.querySelector('.jsontree_label');" & @CRLF & _
			"                var valueEl = node.querySelector('.jsontree_value');" & @CRLF & _
			"                if (labelEl && valueEl) {" & @CRLF & _
			"                    var msg = 'JSON_CLICKED|' + labelEl.innerText + ' = ' + valueEl.innerText;" & @CRLF & _
			"                    window.chrome.webview.postMessage(msg);" & @CRLF & _
			"                }" & @CRLF & _
			"            }" & @CRLF & _
			"        });" & @CRLF & _
			"    } else {" & @CRLF & _
			"        throw new Error('jsonTree library not loaded');" & @CRLF & _
			"    }" & @CRLF & _
			"} catch(e) {" & @CRLF & _
			"    window.chrome.webview.postMessage('DEBUG:' + e.message);" & @CRLF & _
			"    document.body.innerHTML = '<b style=""color:red"">JS Error:</b> ' + e.message;" & @CRLF & _
			"}" & @CRLF & _
			"</script></body></html>"

	; 4. Navigate to the generated HTML
	$oWeb.NavigateToString($sHTML)
	__DW("+ JSON Tree Rendered & Listeners Active." & @CRLF)
EndFunc   ;==>_Web_jsonTree

; #FUNCTION# ====================================================================================================================
; Name...........: _Web_jsonTreeFind
; Description....: Searches for a string in labels and values and highlights matching nodes.
; Parameters.....: $sSearch - The string to find
; ===============================================================================================================================
Func _Web_jsonTreeFind($sSearch, $bNext = False)
	Local $sJS = _
			"var term = '" & $sSearch & "'.toLowerCase();" & _
			"if (!window.searchIndices || window.lastTerm !== term) {" & _
			"    window.searchIndices = [];" & _
			"    window.currentSearchIndex = -1;" & _
			"    window.lastTerm = term;" & _
			"}" & _
			"" & _
			"/* 1. If it's a new search, find all targets */" & _
			"if (!" & StringLower($bNext) & " || window.searchIndices.length === 0) {" & _
			"    document.querySelectorAll('.jsontree_node_marked').forEach(el => el.classList.remove('jsontree_node_marked', 'jsontree_node_active'));" & _
			"    var targets = document.querySelectorAll('.jsontree_label, .jsontree_value');" & _
			"    window.searchIndices = [];" & _
			"    targets.forEach(function(el) {" & _
			"        var text = el.innerText.toLowerCase();" & _
			"        var isBracket = (text === '{' || text === '}' || text === '[' || text === ']' || text === '{ }' || text === '[ ]');" & _
			"        if (!isBracket && (el.classList.contains('jsontree_label') || el.children.length === 0) && text.includes(term)) {" & _
			"            el.classList.add('jsontree_node_marked');" & _
			"            window.searchIndices.push(el);" & _
			"        }" & _
			"    });" & _
			"}" & _
			"" & _
			"/* 2. Move to next index */" & _
			"if (window.searchIndices.length > 0) {" & _
			"    /* Remove active class from previous */" & _
			"    if (window.currentSearchIndex >= 0) window.searchIndices[window.currentSearchIndex].classList.remove('jsontree_node_active');" & _
			"    " & _
			"    window.currentSearchIndex++;" & _
			"    if (window.currentSearchIndex >= window.searchIndices.length) window.currentSearchIndex = 0;" & _
			"    " & _
			"    var activeEl = window.searchIndices[window.currentSearchIndex];" & _
			"    activeEl.classList.add('jsontree_node_active');" & _
			"    " & _
			"    /* Expand parents of active element */" & _
			"    var p = activeEl.closest('.jsontree_node');" & _
			"    while (p && p.id !== 'tree-container') {" & _
			"        if (p.classList.contains('jsontree_node_complex')) p.classList.add('jsontree_node_expanded');" & _
			"        p = p.parentElement;" & _
			"    }" & _
			"    activeEl.scrollIntoView({behavior: 'smooth', block: 'center'});" & _
			"}"

	; Replace the AutoIt variable $bNext with JS boolean
;~     $sJS = StringReplace($sJS, "$bNext", ($bNext ? "true" : "false"))
	ConsoleWrite("$sJS=" & $sJS & @CRLF)
	$oWeb.ExecuteScript($sJS)
EndFunc   ;==>_Web_jsonTreeFind

Func _ExitApp()
	If IsObj($oWeb) Then $oWeb.Cleanup()
	$oWeb = 0
	$oJS = 0
	Exit
EndFunc   ;==>_ExitApp

#EndRegion ; === UTILS ===
