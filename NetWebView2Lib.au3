;~ #AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Run_AU3Check=Y
#AutoIt3Wrapper_AU3Check_Stop_OnWarning=y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7

#include <Array.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>


; Global objects
Global $_g_hNetWebView2Lib_DLL = ''
Global $_g_oWeb
Global $g_DebugInfo = True
_Example()

#Region ; NetWebView2Lib UDF
Func _NetWebView2_StartUp($sDLLFileFullPath)
	$_g_hNetWebView2Lib_DLL = DllOpen($sDLLFileFullPath)
	Return SetError(@error, @extended, $_g_hNetWebView2Lib_DLL)
EndFunc   ;==>_NetWebView2_StartUp

; #FUNCTION# ====================================================================================================================
; Name ..........: _NetWebView2_CreateManager
; Description ...:
; Syntax ........: _NetWebView2_CreateManager()
; Parameters ....: None
; Return values .: None
; Author ........: ioa747
; Modified ......: mLipok
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _NetWebView2_CreateManager()
	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc) ; Local COM Error Handler
	#forceref $oMyError
	Local $oWebV2M = ObjCreate("NetWebView2.Manager", "{CCB12345-6789-4ABC-DEF0-1234567890AB}", $_g_hNetWebView2Lib_DLL) ; NOT REGISTERED VERSION
;~ 	_NetWebView2_ObjName_FlagsValue($oWebV2M)
	Return SetError(@error, @extended, $oWebV2M)
EndFunc   ;==>_NetWebView2_CreateManager

; #FUNCTION# ====================================================================================================================
; Name ..........: _NetJson_CreateParser
; Description ...:
; Syntax ........: _NetJson_CreateParser([$sInitialJson = "{}"])
; Parameters ....: $sInitialJson        - [optional] a string value. Default is "{}".
; Return values .: None
; Author ........: ioa747
; Modified ......: mLipok
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _NetJson_CreateParser($sInitialJson = "{}")
	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc) ; Local COM Error Handler
	#forceref $oMyError
	If $sInitialJson = "" Or $sInitialJson = Default Then $sInitialJson = "{}"
	Local $oParser = ObjCreate("NetJson.Parser", "{D1E2F3A4-B5C6-4D7E-8F9A-0B1C2D3E4F5A}", $_g_hNetWebView2Lib_DLL) ; NOT REGISTERED VERSION
	If Not IsObj($oParser) Then Return SetError(1, 0, 0)
	$oParser.Parse($sInitialJson)
	Return $oParser
EndFunc   ;==>_NetJson_CreateParser

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __NetWebView2_Log
; Description ...: Debug Write utility
; Syntax ........: __NetWebView2_Log($s_ScriptLineNumber, $sString[, $iErrorNoLineNo = 1[, $iError = @error[, $iExtended = @extended]]])
; Parameters ....: $s_ScriptLineNumber  - a string value.
;                  $sString             - a string value.
;                  $iErrorNoLineNo      - [optional] an integer value. Default is 1.
;                  $iError              - [optional] an integer value. Default is @error.
;                  $iExtended           - [optional] an integer value. Default is @extended.
; Return values .: None
; Author ........: ioa747
; Modified ......: mLipok
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __NetWebView2_Log($s_ScriptLineNumber, $sString, $iErrorNoLineNo = 1, $iError = @error, $iExtended = @extended)
	If Not $g_DebugInfo Then Return SetError($iError, $iExtended, 0)
	If $iErrorNoLineNo = 1 Then
		If $iError Then
			$sString = "@@ ( NetWebView2Lib UDF Line: " & $s_ScriptLineNumber & " ) :: @error=" & $iError & ", @extended=" & $iExtended & " :: " & $sString
		Else
			$sString = "+> ( NetWebView2Lib UDF Line: " & $s_ScriptLineNumber & " ) :: " & $sString
		EndIf
	EndIf
	Local $iReturn = ConsoleWrite($sString & @CRLF)
	Return SetError($iError, $iExtended, $iReturn)
EndFunc   ;==>__NetWebView2_Log

; #FUNCTION# ====================================================================================================================
; Name ..........: _NetWebView2_ObjName_FlagsValue
; Description ...:
; Syntax ........: _NetWebView2_ObjName_FlagsValue(ByRef $oObj)
; Parameters ....: $oObj                - [in/out] an object.
; Return values .: None
; Author ........: AutoIt HelpFile ObjName Example 2
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _NetWebView2_ObjName_FlagsValue(ByRef $oObj)
	Local $sInfo = ''
	$sInfo &= '+>' & @TAB & 'ObjName($oObj,1) {The name of the Object} =' & @CRLF & @TAB & ObjName($oObj, $OBJ_NAME) & @CRLF

	; HELPFILE REMARKS: Not all Objects support flags 2 to 7. Always test for @error in these cases.
	$sInfo &= '+>' & @TAB & 'ObjName($oObj,2) {Description string of the Object} =' & @CRLF & @TAB & ObjName($oObj, $OBJ_STRING)
	If @error Then $sInfo &= '@error = ' & @error
	$sInfo &= @CRLF & @CRLF

	$sInfo &= '+>' & @TAB & 'ObjName($oObj,3) {The ProgID of the Object} =' & @CRLF & @TAB & ObjName($oObj, $OBJ_PROGID)
	If @error Then $sInfo &= '@error = ' & @error
	$sInfo &= @CRLF & @CRLF

	$sInfo &= '+>' & @TAB & 'ObjName($oObj,4) {The file that is associated with the object in the Registry} =' & @CRLF & @TAB & ObjName($oObj, $OBJ_FILE)
	If @error Then $sInfo &= '@error = ' & @error
	$sInfo &= @CRLF & @CRLF

	$sInfo &= '+>' & @TAB & 'ObjName($oObj,5) {Module name in which the object runs (WIN XP And above). Marshaller for non-inproc objects.} =' & @CRLF & @TAB & ObjName($oObj, $OBJ_MODULE)
	If @error Then $sInfo &= '@error = ' & @error
	$sInfo &= @CRLF & @CRLF

	$sInfo &= '+>' & @TAB & 'ObjName($oObj,6) {CLSID of the object''s coclass} =' & @CRLF & @TAB & ObjName($oObj, $OBJ_CLSID)
	If @error Then $sInfo &= '@error = ' & @error
	$sInfo &= @CRLF & @CRLF

	$sInfo &= '+>' & @TAB & 'ObjName($oObj,7) {IID of the object''s interface} =' & @CRLF & @TAB & ObjName($oObj, $OBJ_IID)
	If @error Then $sInfo &= '@error = ' & @error
	$sInfo &= @CRLF & @CRLF

	ConsoleWrite($sInfo & @CRLF)
EndFunc   ;==>_NetWebView2_ObjName_FlagsValue

#Region ; === EVENT HANDLERS ===
; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __NetWebView2_COMErrFunc
; Description ...:
; Syntax ........: __NetWebView2_COMErrFunc($oError)
; Parameters ....: $oError              - an object.
; Return values .: None
; Author ........: mLipok
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __NetWebView2_COMErrFunc($oError) ; COM Error Function used by COM Error Handler
	If @Compiled Then Return
	ConsoleWrite("NetWebView2Lib UDF (" & $oError.scriptline & ") : ==> COM Error intercepted !" & @CRLF & _
			@TAB & "err.number is: " & @TAB & @TAB & "0x" & Hex($oError.number) & @CRLF & _
			@TAB & "err.windescription:" & @TAB & $oError.windescription & @CRLF & _
			@TAB & "err.description is: " & @TAB & $oError.description & @CRLF & _
			@TAB & "err.source is: " & @TAB & @TAB & $oError.source & @CRLF & _
			@TAB & "err.helpfile is: " & @TAB & $oError.helpfile & @CRLF & _
			@TAB & "err.helpcontext is: " & @TAB & $oError.helpcontext & @CRLF & _
			@TAB & "err.lastdllerror is: " & @TAB & $oError.lastdllerror & @CRLF & _
			@TAB & "err.scriptline is: " & @TAB & $oError.scriptline & @CRLF & _
			@TAB & "err.retcode is: " & @TAB & "0x" & Hex($oError.retcode) & @CRLF & @CRLF)
EndFunc   ;==>__NetWebView2_COMErrFunc

; Handles native WebView2 events
#TODO => Func __NetWebView2_WebEvents_OnMessageReceived(ByRef $oWebV2M, $sMsg)
Func __NetWebView2_WebEvents_OnMessageReceived($sMsg)
	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc) ; Local COM Error Handler
	#forceref $oMyError
	__NetWebView2_Log(@ScriptLineNumber, "+++ [WebEvents]: " & (StringLen($sMsg) > 150 ? StringLeft($sMsg, 150) & "..." : $sMsg), 0)
	Local $iSplitPos = StringInStr($sMsg, "|")
	Local $sCommand = $iSplitPos ? StringStripWS(StringLeft($sMsg, $iSplitPos - 1), 3) : $sMsg
	Local $sData = $iSplitPos ? StringTrimLeft($sMsg, $iSplitPos) : ""
	Local $aParts

	Switch $sCommand
		Case "INIT_READY"
			$_g_oWeb.ExecuteScript('window.chrome.webview.postMessage(JSON.stringify({ "type": "COM_TEST", "status": "OK" }));')

		Case "WINDOW_RESIZED"
			$aParts = StringSplit($sData, "|")
			If $aParts[0] >= 2 Then
				Local $iW = Int($aParts[1]), $iH = Int($aParts[2])
				; Filter minor resize glitches
				If $iW > 50 And $iH > 50 Then __NetWebView2_Log(@ScriptLineNumber, "+++ [WebEvents]: WINDOW_RESIZED : " & $iW & "x" & $iH)
			EndIf
	EndSwitch
EndFunc   ;==>__NetWebView2_WebEvents_OnMessageReceived

; Handles custom messages from JavaScript (window.chrome.webview.postMessage)
#TODO => Func __NetWebView2_JSEvents_OnMessageReceived(ByRef $oWebV2M, $sMsg)
Func __NetWebView2_JSEvents_OnMessageReceived($sMsg)
	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc) ; Local COM Error Handler
	#forceref $oMyError
	__NetWebView2_Log(@ScriptLineNumber, ">>> [JavaScriptEvents]: " & (StringLen($sMsg) > 150 ? StringLeft($sMsg, 150) & "..." : $sMsg), 0)
	Local $sFirstChar = StringLeft($sMsg, 1)

	; 1. Modern JSON Messaging
	If $sFirstChar = "{" Or $sFirstChar = "[" Then
		__NetWebView2_Log(@ScriptLineNumber, "+> : Processing JSON message..." & @CRLF)
		Local $oJSON = _NetJson_CreateParser()
		If Not IsObj($oJSON) Then Return ConsoleWrite("!> Error: Failed to create NetJson object." & @CRLF)

		$oJSON.Parse($sMsg)
		Local $sJobType = $oJSON.GetTokenValue("type")

		Switch $sJobType
			Case "COM_TEST"
				__NetWebView2_Log(@ScriptLineNumber, "- COM_TEST Confirmed: " & $oJSON.GetTokenValue("status") & @CRLF)
		EndSwitch

	Else
		; 2. Legacy / Native Pipe-Delimited Messaging
		__NetWebView2_Log(@ScriptLineNumber, "+> [JavaScriptEvents]: Processing Delimited message...", 0)
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
					__NetWebView2_Log(@ScriptLineNumber, "+++ [JavaScriptEvents]: Property: " & $sKey & " | Value: " & $sVal & @CRLF)
				EndIf

			Case "COM_TEST"
				__NetWebView2_Log(@ScriptLineNumber, "- [JavaScriptEvents]: Status: Legacy COM_TEST: " & $sData & @CRLF)

			Case "ERROR"
				__NetWebView2_Log(@ScriptLineNumber, "! [JavaScriptEvents]: Status: " & $sData & @CRLF)
		EndSwitch
	EndIf
EndFunc   ;==>__NetWebView2_JSEvents_OnMessageReceived

#TODO => Func __NetWebView2_WebEvents_OnContextMenuRequested(ByRef $oWebV2M, $sLink, $iX, $iY, $sSelection)
Func __NetWebView2_WebEvents_OnContextMenuRequested($sLink, $iX, $iY, $sSelection)
	#forceref $sLink, $iX, $iY, $sSelection
	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc) ; Local COM Error Handler
	#forceref $oMyError
EndFunc   ;==>__NetWebView2_WebEvents_OnContextMenuRequested
#EndRegion ; === EVENT HANDLERS ===

#EndRegion ; NetWebView2Lib UDF

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

	_NetWebView2_StartUp(@ScriptDir & '\bin\NetWebView2Lib.dll')

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
	Local $sJsLib = FileRead(@ScriptDir & "\examples\v1.4.2_jsonTree\JS_Lib\jsonTree.js")
	Local $sCssLib = FileRead(@ScriptDir & "\examples\v1.4.2_jsonTree\JS_Lib\jsonTreeDark.css")

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
