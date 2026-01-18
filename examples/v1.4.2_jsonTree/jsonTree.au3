;~ #AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Run_AU3Check=Y
#AutoIt3Wrapper_AU3Check_Stop_OnWarning=y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7
#Au3Stripper_Ignore_Funcs=__NetWebView2_WebEvents_*,__NetWebView2_JSEvents_*


; Html_Gui.au3
#include <Array.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include "..\..\NetWebView2Lib.au3"

_Example()

#Region ; UDF TESTING EXAMPLE
Func _Example()
	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc)
	#forceref $oMyError
	; Create GUI with resizing support
	Local $hGUI = GUICreate("WebView2AutoIt JSON Viewer", 500, 650, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPCHILDREN))
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
	Local $oWebV2M = _NetWebView2_CreateManager()
	$_g_oWeb = $oWebV2M
	If @error Then Return SetError(@error, @extended, $oWebV2M)

	ObjEvent($oWebV2M, "__NetWebView2_WebEvents_", "IWebViewEvents")

	; Important: Pass $hGUI in parentheses to maintain Pointer type for COM
	Local $sProfileDirectory = @TempDir & "\NetWebView2Lib-UserDataFolder"
	$oWebV2M.Initialize($hGUI, $sProfileDirectory, 0, 50, 500, 600)

	; Initialize JavaScript Bridge
	Local $oJS = $oWebV2M.GetBridge()
	ObjEvent($oJS, "__NetWebView2_JSEvents_", "IBridgeEvents")

	; Wait for WebView2 to be ready
	Do
		Sleep(50)
	Until $oWebV2M.IsReady

	; WebView2 Configuration
	$oWebV2M.SetAutoResize(True) ; Using SetAutoResize(True) to skip WM_SIZE
	$oWebV2M.BackColor = "0x2B2B2B"
	$oWebV2M.AreDevToolsEnabled = True ; Allow F12
	$oWebV2M.ZoomFactor = 1.2

	; Initial JSON display
	Local $sMyJson = '{"Game": "Witcher 3", "ID": 1, "Meta": {"Developer": "CD Projekt", "Year": 2015 }, "Tags": ["RPG", "Open World"]}'

	_Web_jsonTree($oWebV2M, $sMyJson) ; 🏆 https://github.com/summerstyle/jsonTreeViewer

	GUISetState(@SW_SHOW)

	Local $sLastSearch = ""

	; Main Application Loop
	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				Exit

			Case $idExpand
				; Call JavaScript expand method on the global tree object
				$oWebV2M.ExecuteScript("if(window.tree) window.tree.expand();")

			Case $idCollapse
				; Call JavaScript collapse method
				$oWebV2M.ExecuteScript("if(window.tree) window.tree.collapse();")

			Case $idFind
				Local $sInput = InputBox("JSON Search", "Enter key or value:", $sLastSearch, "", 200, 130, Default, Default, Default, $hGUI)
				If Not @error And StringLen(StringStripWS($sInput, 3)) > 0 Then
					$sLastSearch = StringStripWS($sInput, 3)
					_Web_jsonTreeFind($oWebV2M, $sLastSearch, False) ; New search
				EndIf

			Case $idLoadFile
				Local $sFilePath = FileOpenDialog("Select JSON File", @ScriptDir, "JSON Files (*.json;*.txt)", 1)
				If Not @error Then
					Local $sFileData = FileRead($sFilePath)
					If $sFileData <> "" Then
						_Web_jsonTree($oWebV2M, $sFileData) ; Re-render tree with new data
						__NetWebView2_Log(@ScriptLineNumber, "+ Loaded JSON from: " & $sFilePath)
					EndIf
				EndIf

		EndSwitch
	WEnd

	If IsObj($oWebV2M) Then $oWebV2M.Cleanup()
	$oWebV2M = 0
	$oJS = 0
	_NetWebView2_ShutDown()

EndFunc   ;==>Main

#Region ; === UTILS ===

; #FUNCTION# ====================================================================================================================
; Name...........: _Web_jsonTree
; Description....: Renders JSON data using the jsonTree library by summerstyle.
; Author.........: summerstyle (https://github.com/summerstyle/jsonTreeViewer)
; Integration....: Adapted for AutoIt WebView2
; ===============================================================================================================================
Func _Web_jsonTree(ByRef $oWebV2M, $sJson)
	; 1. Prepare JSON (Minify to prevent script errors from line breaks)
	Local $oJSON = _NetJson_CreateParser($sJson)
;~ 	_NetWebView2_ObjName_FlagsValue($oJSON)
	$sJson = $oJSON.GetMinifiedJson()

	; 2. Load local library files
	Local $sJsLib = FileRead(@ScriptDir & ".\JS_Lib\jsonTree.js")
	Local $sCssLib = FileRead(@ScriptDir & ".\JS_Lib\jsonTreeDark.css")

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
	$oWebV2M.NavigateToString($sHTML)
	__NetWebView2_Log(@ScriptLineNumber, "+ JSON Tree Rendered & Listeners Active")
EndFunc   ;==>_Web_jsonTree

; #FUNCTION# ====================================================================================================================
; Name...........: _Web_jsonTreeFind
; Description....: Searches for a string in labels and values and highlights matching nodes.
; Parameters.....: $sSearch - The string to find
; ===============================================================================================================================
Func _Web_jsonTreeFind(ByRef $oWebV2M, $sSearch, $bNext = False)
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
	$oWebV2M.ExecuteScript($sJS)
EndFunc   ;==>_Web_jsonTreeFind
#EndRegion ; === UTILS ===
#EndRegion ; UDF TESTING EXAMPLE

