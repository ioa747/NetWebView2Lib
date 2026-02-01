#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Run_AU3Check=Y
#AutoIt3Wrapper_AU3Check_Stop_OnWarning=y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7
#Au3Stripper_Ignore_Funcs=__NetWebView2_WebEvents_*,__NetWebView2_JSEvents_*

; Static_PDF_Viewer.au3
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; ⚠️ to make this work, download
; https://github.com/mozilla/pdf.js/releases/download/v5.4.530/pdfjs-5.4.530-dist.zip
; and unzip to:   @ScriptDir & "/pdfjs/"
; from https://mozilla.github.io/pdf.js/
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include "..\..\NetWebView2Lib.au3"

; Global objects
Global $oBridge
Global $hGUI

_Example()

Func _Example()
	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc)
	#forceref $oMyError

	#Region ; GUI CREATION

	; Create the GUI
	$hGUI = GUICreate("WebView2 .NET Manager", 800, 1000)

	; Get the WebView2 Manager object and register events
	$_g_oWeb = _NetWebView2_CreateManager("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0", _
			"", "--allow-file-access-from-files") ; 👈

	; initialize browser - put it on the GUI
	Local $sProfileDirectory = @TempDir & "\NetWebView2Lib-UserDataFolder"
	_NetWebView2_Initialize($_g_oWeb, $hGUI, $sProfileDirectory, 0, 0, 0, 0, True, False, False, 0.7)

	; Get the bridge object and register events
	_NetWebView2_GetBridge($_g_oWeb, "__EVENTS_Bridge_")

	; show the GUI after browser was fully initialized
	GUISetState(@SW_SHOW)

	#EndRegion ; GUI CREATION

	; navigate to the page
	SetupStaticPDF($_g_oWeb, @ScriptDir & "\invoice-plugin-sample.pdf", True, True)

	Local $sResult = _NetWebView2_ExecuteScript($_g_oWeb, "extractPDFText();", 2)
	MsgBox($MB_TOPMOST, "$sResult", $sResult)

	; Main Loop
	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				ExitLoop
		EndSwitch
	WEnd

	GUIDelete($hGUI)

	_NetWebView2_CleanUp($_g_oWeb, $oBridge)
EndFunc   ;==>_Example


; Handles custom messages from JavaScript (window.chrome.webview.postMessage)
Func __EVENTS_Bridge_OnMessageReceived($sMsg)
	ConsoleWrite(">>> [__EVENTS_Bridge]: " & (StringLen($sMsg) > 150 ? StringLeft($sMsg, 150) & "..." : $sMsg) & @CRLF)
	Local $sFirstChar = StringLeft($sMsg, 1)

	If $sFirstChar = "{" Or $sFirstChar = "[" Then ; 1. JSON Messaging
		ConsoleWrite("+> : Processing JSON Messaging..." & @CRLF)
		Local $oJson = ObjCreate("NetJson.Parser")
		If Not IsObj($oJson) Then Return ConsoleWrite("!> Error: Failed to create NetJson object." & @CRLF)

		$oJson.Parse($sMsg)
		Local $sJobType = $oJson.GetTokenValue("type")

		Switch $sJobType
			Case "COM_TEST"
				ConsoleWrite("- COM_TEST Confirmed: " & $oJson.GetTokenValue("status") & @CRLF)
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

			Case "PDF_TEXT"
				ConsoleWrite("- PDF_TEXT: " & @CRLF & $sData & @CRLF)

			Case "ERROR"
				ConsoleWrite("! Status: " & $sData & @CRLF)
		EndSwitch
	EndIf
EndFunc   ;==>__EVENTS_Bridge_OnMessageReceived

Func SetupStaticPDF(ByRef $oWeb, $sPdfPath, $bBlockLinks = False, $bBlockSelection = False)
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
			"            window.chrome.webview.postMessage('ERROR|' + e.message);" & _
			"        }" & _
			"    };" & _
			"    runExtraction();" & _
			"};" & _
			"/* 3. Style Injection */ " & _
			"window.addEventListener('DOMContentLoaded', () => {" & _
			"   const style = document.createElement('style');" & _
			"   style.innerHTML = '#toolbarContainer, #sidebarContainer { display: none !important; } ' + " & _
			"                     '#viewerContainer { top: 0 !important; bottom: 0 !important; overflow: hidden !important; } ' + " & _
			"                     '" & $sBlockLinksCSS & "' + " & _
			"                     '" & $sSelectionCSS & "' + " & _
			"                     ' ::-webkit-scrollbar { display: none !important; }';" & _
			"   document.head.appendChild(style);" & _
			"});"

	$oWeb.AddInitializationScript($sCleanupJS)

	; Fix slashes in Path for URL
	Local $sPdfUrl = StringReplace($sPdfPath, "\", "/")
	$sPdfPath = StringReplace($sPdfPath, ' ', '%20')
	Local $sViewerUrl = "file:///" & StringReplace(@ScriptDir & "/pdfjs/web/viewer.html?file=" & $sPdfUrl, "\", "/")

	$oWeb.Navigate($sViewerUrl)

	; $oWeb.IsZoomControlEnabled = False ; <--- It doesn't work in PDF. 👈
	$oWeb.DisableBrowserFeatures()
	$oWeb.LockWebView()
EndFunc   ;==>SetupStaticPDF
