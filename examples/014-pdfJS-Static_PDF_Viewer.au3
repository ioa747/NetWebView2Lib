#WIP - this Example is imported from 1.5.0 UDF - and is in "WORK IN PROGRESS" state

#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Run_AU3Check=Y
#AutoIt3Wrapper_AU3Check_Stop_OnWarning=y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7
#Au3Stripper_Ignore_Funcs=__NetWebView2_WebEvents_*,__NetWebView2_JSEvents_*

#Tidy_Parameters=/tcb=-1

; 014-pdfJS-Static_PDF_Viewer.au3
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; ⚠️ to make this work, download pdfJS library from https://mozilla.github.io/pdf.js/
; for example:
; https://github.com/mozilla/pdf.js/releases/download/v5.4.624/pdfjs-5.4.624-dist.zip
; and unzip to:   @ScriptDir & "\JS_Lib\pdfjs\"
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include "..\NetWebView2Lib.au3"

; Global objects

_Example()

Func _Example()
	ConsoleWrite("! MicrosoftEdgeWebview2 : version check: " & _NetWebView2_IsAlreadyInstalled() & ' ERR=' & @error & ' EXT=' & @extended & @CRLF)

	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc)
	#forceref $oMyError

	#Region ; GUI CREATION

	; Create the GUI
	Local $hGUI = GUICreate("WebView2 .NET Manager", 800, 1000)

	; Get the WebView2 Manager object and register events
	Local $oWeb = _NetWebView2_CreateManager("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0", _
			"", "--allow-file-access-from-files") ; 👈

	; initialize browser - put it on the GUI
	Local $sProfileDirectory = @ScriptDir & "\NetWebView2Lib-UserDataFolder"
	_NetWebView2_Initialize($oWeb, $hGUI, $sProfileDirectory, 0, 0, 0, 0, True, False, False, 0.7)

	; Get the bridge object and register events
	Local $oBridge = _NetWebView2_GetBridge($oWeb, "__UserEventHandler__Bridge_")

	; show the GUI after browser was fully initialized
	GUISetState(@SW_SHOW)

	#EndRegion ; GUI CREATION

	; Adds a JavaScript library to be executed before any other script when a new page is loaded.
	Local $sScriptId = New_NetWebView2_AddInitializationScript($oWeb, @ScriptDir & "\JS_Lib\NetWebView2Lib_pdfjs_Tools.js")
	ConsoleWrite("$sScriptId=" & $sScriptId & @CRLF)

	; navigate to the page
	Local $sFileName = "invoice-plugin-sample.pdf"
	Local $sRegExp_Title = "(?i) - " & $sFileName

	__SetupStaticPDF($oWeb, @ScriptDir & "\" & $sFileName, $sRegExp_Title, True, False, True)

	#Region ; now we can call the script directly from the JavaScript library "NetWebView2Lib_pdfjs_Tools.js" - some pdfjs magic stuff ;)
	Local $s_JavaScript_snipp = ''
	Local $s_PDF_TEXT = ''

	$s_JavaScript_snipp = "PDF_ExtractToJSON();"
	$s_PDF_TEXT = _NetWebView2_ExecuteScript($oWeb, $s_JavaScript_snipp, $NETWEBVIEW2_EXECUTEJS_MODE2_RESULT)
	MsgBox($MB_TOPMOST, "TEST #" & @ScriptLineNumber, "After:" & @CRLF & $s_JavaScript_snipp & @CRLF & $s_PDF_TEXT)

	$s_JavaScript_snipp = "PDF_HighlightSpansContainingText('2016', 'blue', 'pink');"
	_NetWebView2_ExecuteScript($oWeb, $s_JavaScript_snipp, $NETWEBVIEW2_EXECUTEJS_MODE0_FIREANDFORGET)
	MsgBox($MB_TOPMOST, "TEST #" & @ScriptLineNumber, "After:" & @CRLF & $s_JavaScript_snipp)

	$s_JavaScript_snipp = "PDF_HighlightSpansContainingText('January 31, 2016', 'red', 'yellow');"
	_NetWebView2_ExecuteScript($oWeb, $s_JavaScript_snipp, $NETWEBVIEW2_EXECUTEJS_MODE0_FIREANDFORGET)
	MsgBox($MB_TOPMOST, "TEST #" & @ScriptLineNumber, "After:" & @CRLF & $s_JavaScript_snipp)

	$s_JavaScript_snipp = "PDF_HighlightSpansContainingText('Total Due', 'white', 'red');"
	_NetWebView2_ExecuteScript($oWeb, $s_JavaScript_snipp, $NETWEBVIEW2_EXECUTEJS_MODE0_FIREANDFORGET)
	MsgBox($MB_TOPMOST, "TEST #" & @ScriptLineNumber, "After:" & @CRLF & $s_JavaScript_snipp)

	$s_JavaScript_snipp = "PDF_RemoveHighlights('January 31, 2016');"
	_NetWebView2_ExecuteScript($oWeb, $s_JavaScript_snipp, $NETWEBVIEW2_EXECUTEJS_MODE0_FIREANDFORGET)
	MsgBox($MB_TOPMOST, "TEST #" & @ScriptLineNumber, "After:" & @CRLF & $s_JavaScript_snipp)

	#EndRegion ; now we can call the script directly from the JavaScript library "NetWebView2Lib_pdfjs_Tools.js" - some pdfjs magic stuff ;)

	; Main Loop
	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				ExitLoop
		EndSwitch
	WEnd

	GUIDelete($hGUI)
	_NetWebView2_CleanUp($oWeb, $oBridge)
EndFunc   ;==>_Example

; Handles custom messages from JavaScript (window.chrome.webview.postMessage)
Func __UserEventHandler__Bridge_OnMessageReceived($oWebV2M, $hGUI, $sMsg)
	#forceref $oWebV2M, $hGUI
	ConsoleWrite("$sMsg=" & $sMsg & @CRLF)
	ConsoleWrite(">>> [__EVENTS_Bridge]: " & (StringLen($sMsg) > 150 ? StringLeft($sMsg, 150) & "..." : $sMsg) & @CRLF)
	Local $sFirstChar = StringLeft($sMsg, 1)

	If $sFirstChar = "{" Or $sFirstChar = "[" Then ; 1. JSON Messaging
		ConsoleWrite("+> : Processing JSON Messaging..." & @CRLF)
		Local $oJson = ObjCreate("NetJson.Parser")
		If ObjName($oJson, $OBJ_PROGID) <> 'NetWebView2.Manager' Then Return ConsoleWrite("!> Error: Failed to create NetJson object." & @CRLF)

		$oJson.Parse($sMsg)
		Local $sJobType = $oJson.GetTokenValue("type")

		Switch $sJobType
			Case "COM_TEST"
				ConsoleWrite("- COM_TEST Confirmed: " & $oJson.GetTokenValue("status") & @CRLF)

			Case "PDF_DATA_PACKAGE"
				ConsoleWrite("> PDF Metadata: " & $oJson.GetTokenValue("metadata.title") & " by " & $oJson.GetTokenValue("metadata.author") & @CRLF)

				; Loop through pages (if your parser supports it)
				Local $iPages = $oJson.GetTokenValue("metadata.pagesCount")
				For $i = 0 To $iPages - 1
					ConsoleWrite("- Page " & ($i + 1) & " content: " & StringLeft($oJson.GetTokenValue("pages[" & $i & "].text"), 150) & "..." & @CRLF)
				Next
		EndSwitch

	Else ; 2. Legacy / Native Pipe-Delimited Messaging
		ConsoleWrite("+> : Legacy / Native Pipe-Delimited Messaging..." & @CRLF)
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
			Case "COM_TEST"
				ConsoleWrite("- Status: Legacy COM_TEST: " & $sData & @CRLF)

			Case "PDF_TEXT_RESULT"
				ConsoleWrite("- PDF_TEXT_RESULT: " & @CRLF & $sData & @CRLF)

			Case "ERROR"
				ConsoleWrite("! Status: " & $sData & @CRLF)
		EndSwitch
	EndIf
EndFunc   ;==>__UserEventHandler__Bridge_OnMessageReceived

Func __SetupStaticPDF(ByRef $oWeb, $s_PDF_Path, $sExpectedTitle, $bBlockLinks = False, $bBlockSelection = False, $bShowToolbar = False)
	; 🏆 https://mozilla.github.io/pdf.js/

	Local $sBlockLinksJS = ""
	Local $sBlockLinksCSS = ""
	Local $sSelectionCSS = ""

	; 1. Configuration for BlockLinks
	If $bBlockLinks Then
		$sBlockLinksJS = _
				"window.addEventListener('click', function(e) {" & _
				"    if (e.target.tagName === 'A' || e.target.closest('a')) {" & _
				"        e.stopImmediatePropagation();" & _
				"        e.preventDefault();" & _
				"    }" & _
				"}, { capture: true });"
		$sBlockLinksCSS = " .annotationLayer { pointer-events: none !important; } "
	EndIf

	; 2. Configuration for Text Selection
	If $bBlockSelection Then
		$sSelectionCSS = " .textLayer, body { -webkit-user-select: none !important; user-select: none !important; cursor: default !important; } "
	EndIf

	; 3. Final Script Construction
	Local $sCleanupJS = _
			"/* 1. Block Zoom (Wheel & Keys) */ " & _
			"window.addEventListener('wheel', function(e) {" & _
			"    if (e.ctrlKey) {" & _
			"        e.stopImmediatePropagation();" & _
			"        e.preventDefault();" & _
			"    }" & _
			"}, { passive: false, capture: true });" & _
			"window.addEventListener('keydown', function(e) {" & _
			"    if (e.ctrlKey && ['+', '-', '=', '0'].includes(e.key)) {" & _
			"        e.stopImmediatePropagation();" & _
			"        e.preventDefault();" & _
			"    }" & _
			"}, { capture: true });" & _
			$sBlockLinksJS & _
			"/* 2. PDF Text Extraction Function with Auto-Wait */ " & _
			"window.extractPDFText = async function() {" & _
			"    const runExtraction = async () => {" & _
			"        try {" & _
			"            if (typeof PDFViewerApplication !== 'undefined' && PDFViewerApplication.pdfDocument) {" & _
			"                const pdf = PDFViewerApplication.pdfDocument;" & _
			"                let text = '';" & _
			"                for (let i = 1; i <= pdf.numPages; i++) {" & _
			"                    const page = await pdf.getPage(i);" & _
			"                    const content = await page.getTextContent();" & _
			"                    text += content.items.map(item => item.str).join(' ') + '\n';" & _
			"                }" & _
			"                window.chrome.webview.postMessage('PDF_TEXT|' + text);" & _
			"            } else {" & _
			"                setTimeout(runExtraction, 500);" & _
			"            }" & _
			"        } catch (e) {" & _
			"            window.chrome.webview.postMessage('JS_ERROR|extractPDFText() SLN=" & @ScriptLineNumber & "' + e.message);" & _
			"        }" & _
			"    };" & _
			"    runExtraction();" & _
			"};" & _
			"/* 3. Style Injection */ " & _
			"window.addEventListener('DOMContentLoaded', () => {" & _
			"   const style = document.createElement('style');" & _
			"   style.innerHTML = " & (($bShowToolbar) ? ("") : ("'#toolbarContainer, #sidebarContainer { display: none !important; } ' + ")) & _
			"                     '#viewerContainer { top: 0 !important; bottom: 0 !important; overflow: hidden !important; } ' + " & _
			"                     '" & $sBlockLinksCSS & "' + " & _
			"                     '" & $sSelectionCSS & "' + " & _
			"                     ' ::-webkit-scrollbar { display: none !important; }';" & _
			"   document.head.appendChild(style);" & _
			"});" & _
			""

	$oWeb.AddInitializationScript($sCleanupJS)

	; Fix slashes in Path for URL
	Local $s_PDF_URL = StringReplace($s_PDF_Path, "\", "/")
	$s_PDF_URL = $oWeb.EncodeURI($s_PDF_URL)
	Local $s_PDF_JS_URL = StringReplace(@ScriptDir & "\JS_Lib\pdfjs\web\viewer.html" & "?file=", "\", "/")
	Local $s_Viewer_URL = "file:///" & $s_PDF_JS_URL & $s_PDF_URL
	ConsoleWrite("- $s_Viewer_URL= " & $s_Viewer_URL & @CRLF)

	_NetWebView2_Navigate($oWeb, $s_Viewer_URL, $NETWEBVIEW2_MESSAGE__TITLE_CHANGED, $sExpectedTitle, 5000)
	ConsoleWrite("! we're done with navigation, but check how many more messages there are below. SLN=" & @ScriptLineNumber & @CRLF)
	MsgBox($MB_TOPMOST, "TEST #" & @ScriptLineNumber, 'Wait for all messages to full loading PDF by pdf.js')
	#EndRegion ; mLipok #TODO this should be fixed by better LoadWait, I mean adding a check if the desired title appears

	; $oWeb.IsZoomControlEnabled = False ; <--- It doesn't work in PDF.
	$oWeb.DisableBrowserFeatures()
	$oWeb.LockWebView()
EndFunc   ;==>__SetupStaticPDF

; New to replace _NetWebView2_AddInitializationScript in UDF
Func New_NetWebView2_AddInitializationScript($oWebV2M, $vScript)
	If (Not IsObj($oWebV2M)) Or ObjName($oWebV2M, $OBJ_PROGID) <> 'NetWebView2.Manager' Then Return SetError(1, 0, "ERROR: Invalid Object")

	; Smart Detection
	If FileExists($vScript) Then $vScript = FileRead($vScript)

	Local $sScriptId = $oWebV2M.AddInitializationScript($vScript)
	If StringInStr($sScriptId, "ERROR:") Then Return SetError(2, 0, $sScriptId)
	Return SetError(0, 0, $sScriptId)
EndFunc   ;==>New_NetWebView2_AddInitializationScript
