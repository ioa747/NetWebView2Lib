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
#include <Array.au3>
#include <String.au3>

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
	Local $sScriptId = _NetWebView2_AddInitializationScript($oWeb, @ScriptDir & "\JS_Lib\NetWebView2Lib_pdfjs_Tools.js")
	ConsoleWrite("$sScriptId=" & $sScriptId & @CRLF)

	; navigate to the page
	Local $sFileName = "invoice-plugin-sample.pdf"
	Local $sRegExp_Title = "(?i) - " & $sFileName

	__SetupStaticPDF($oWeb, @ScriptDir & "\" & $sFileName, $sRegExp_Title, True, False, True)

	#Region ; now we can call the script directly from the JavaScript library "NetWebView2Lib_pdfjs_Tools.js" - some pdfjs magic stuff ;)
	Local $s_JavaScript_snipp = ''
	Local $s_PDF_TEXT = ''

	$s_JavaScript_snipp = "PDF_ExtractToJSON();"
	_NetWebView2_ExecuteScript($oWeb, $s_JavaScript_snipp, $NETWEBVIEW2_EXECUTEJS_MODE2_RESULT)

	; Get JSON data
	$s_PDF_TEXT = Get_Data_Sync("", "PDF_DATA_PACKAGE")

	If $s_PDF_TEXT <> "" Then ; === JSON REPORT ===
		Local $oJson = _NetJson_CreateParser($s_PDF_TEXT)
		If @error Then Return ConsoleWrite("!> Error: Failed to create NetJson object." & @CRLF)

		ConsoleWrite(@CRLF & "==================== PDF REPORT ====================" & @CRLF)

		; METADATA SECTION
		Local $sTitle = $oJson.GetTokenValue("metadata.Title")
		Local $sAuthor = $oJson.GetTokenValue("metadata.Author")
		ConsoleWrite(StringFormat("+ Title:  %s\n+ Author: %s\n", $sTitle, $sAuthor))
		ConsoleWrite("+ Format: " & $oJson.GetTokenValue("metadata.PDFFormatVersion") & @CRLF)

		; PAGES SECTION
;~ 		Local $iActualPages = $oJson.GetArrayLength("pages")
		Local $iPages = Number($oJson.GetTokenValue("pagesCount"))
		ConsoleWrite("----------------------------------------------------" & @CRLF)
		ConsoleWrite("- Total Pages Detected: " & $iPages & @CRLF)

		For $i = 0 To $iPages - 1 ; Get and Clean Page Text
			Local $sRawPageText = $oJson.GetTokenValue("pages[" & $i & "].text")
			Local $sCleanText = StringReplace($sRawPageText, Chr(160), " ") ; Normalize spaces
			ConsoleWrite(StringFormat(">>> Page [%d] Content:\n%s\n", $i + 1, $sCleanText))
			ConsoleWrite("----------------------------------------------------" & @CRLF)
		Next

		; DATA GRID SECTION
		Local $sTable = $oJson.FlattenToTable("↲", @CRLF)
		Local $aFinalGrid = _ArrayFromString($sTable, "↲", @CRLF, True)

		If Not @error Then
			ConsoleWrite("+ Data Grid: Success. Displaying UI Table..." & @CRLF)
			_ArrayDisplay($aFinalGrid, "v1.4.1 Final Table View")
		Else
			ConsoleWrite("!> Error: FlattenToTable failed to generate array." & @CRLF)
		EndIf

		ConsoleWrite("====================================================" & @CRLF & @CRLF)
	Else
		ConsoleWrite("!> Error: No PDF data received within timeout." & @CRLF)
	EndIf

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
		Local $oJson = _NetJson_CreateParser($sMsg)
		If @error Then Return ConsoleWrite("!> Error: Failed to create NetJson object." & @CRLF)

		Local $sJobType = $oJson.GetTokenValue("type")

		Switch $sJobType
			Case "COM_TEST"
				ConsoleWrite("- COM_TEST Confirmed: " & $oJson.GetTokenValue("status") & @CRLF)

			Case "PDF_DATA_PACKAGE"
				Get_Data_Sync($sMsg, "PDF_DATA_PACKAGE")
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

Func Get_Data_Sync($sData = "", $sJobType = "DEFAULT", $iTimeout = 5000)
	; We use a Map to hold many different types of data at the same time.
	Local Static $mDataMap[]

	; If we send data (from the Event Handler)
	If $sData <> "" Then
		$mDataMap[$sJobType] = $sData
		Return True
	EndIf

	; If we request data (from the main Script)
	Local $iStart = TimerInit()
	While Not MapExists($mDataMap, $sJobType)
		If TimerDiff($iStart) > $iTimeout Then Return SetError(1, 0, "")
		Sleep(10)
	WEnd

	Local $sResult = $mDataMap[$sJobType]
	MapRemove($mDataMap, $sJobType) ; Cleaning for next time
	Return $sResult
EndFunc   ;==>Get_Data_Sync

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
	Local $sViewerPath = StringReplace(@ScriptDir & "\JS_Lib\pdfjs\web\viewer.html", "\", "/")
	Local $sPDF_URL = "file:///" & StringReplace($s_PDF_Path, "\", "/")
	Local $sFinalURL = "file:///" & $sViewerPath & "?file=" & $oWeb.EncodeURI($sPDF_URL)
	ConsoleWrite("Correct URL: " & $sFinalURL & @CRLF)

	_NetWebView2_Navigate($oWeb, $sFinalURL, $NETWEBVIEW2_MESSAGE__TITLE_CHANGED, $sExpectedTitle, 5000)
	ConsoleWrite("! we're done with navigation, but check how many more messages there are below. SLN=" & @ScriptLineNumber & @CRLF)
	MsgBox($MB_TOPMOST, "TEST #" & @ScriptLineNumber, 'Wait for all messages to full loading PDF by pdf.js')
	; mLipok #TODO this should be fixed by better LoadWait, I mean adding a check if the desired title appears

	; $oWeb.IsZoomControlEnabled = False ; <--- It doesn't work in PDF.
	$oWeb.DisableBrowserFeatures()
	$oWeb.LockWebView()
EndFunc   ;==>__SetupStaticPDF
