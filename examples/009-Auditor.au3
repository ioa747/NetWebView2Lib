#WIP - this Example is imported from 1.5.0 UDF - and is in "WORK IN PROGRESS" state

#AutoIt3Wrapper_UseX64=y
#include <GUIConstantsEx.au3>
#include <EditConstants.au3>
#include <WindowsStylesConstants.au3>
#include <WindowsNotifsConstants.au3>
#include <File.au3>
#include <StaticConstants.au3>
#include "..\NetWebView2Lib.au3"

; Global objects
Global $oMyError = ObjEvent("AutoIt.Error", __ErrFunc) ; COM Error Handler
Global $g_bHighlight = 0
Global $g_b_HideAllPopups = 0
Global $g_bAdBlock = 0
Global $g_bDarkMode = 0
Global $idStatusLabel, $idAuditBtn, $idURL, $idReportEdit

_Example()
Exit

Func _Example()
	ConsoleWrite("! MicrosoftEdgeWebview2 : version check: " & _NetWebView2_IsAlreadyInstalled() & ' ERR=' & @error & ' EXT=' & @extended & @CRLF)

	#Region ; === GUI ===
	Local $hGUI = GUICreate("AutoIt Auditor", 1100, 850, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPCHILDREN))
	GUISetBkColor(0x1E1E1E, $hGUI)

	; URL ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~ Local $sURL = "https://learn.microsoft.com/en-us/windows/win32/api/uiautomationclient/"
	Local $sURL = "https://learn.microsoft.com/en-us/dotnet/api/microsoft.web.webview2.core.corewebview2?view=webview2-dotnet-1.0.3595.46"
	$idURL = GUICtrlCreateInput($sURL, 420, 10, 670, 25)
	GUICtrlSetFont(-1, 10)
	GUICtrlSetColor(-1, 0xFFFFFF) ; White
	GUICtrlSetBkColor(-1, 0x000000) ; Black background
	GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKMENUBAR)

	; Button ClearBrowserData
	Local $idBtnClearBrowserData = GUICtrlCreateButton(ChrW(59608), 150, 10, 20, 25)
	GUICtrlSetFont(-1, 10, 400, 0, "Segoe Fluent Icons")
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetTip(-1, "ClearBrowserData")

	; Button ResetZoom
	Local $idBtnResetZoom = GUICtrlCreateButton(ChrW(59623), 170, 10, 20, 25)
	GUICtrlSetFont(-1, 10, 400, 0, "Segoe Fluent Icons")
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetTip(-1, "ResetZoom")

	; Button SetZoom
	Local $idBtnSetZoom = GUICtrlCreateButton(ChrW(59624), 190, 10, 20, 25)
	GUICtrlSetFont(-1, 10, 400, 0, "Segoe Fluent Icons")
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetTip(-1, "SetZoom")

	; Button _HideAllPopups
	Local $idBtn_HideAllPopups = GUICtrlCreateButton(ChrW(59212), 210, 10, 20, 25)
	GUICtrlSetFont(-1, 10, 400, 0, "Segoe Fluent Icons")
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetTip(-1, "_HideAllPopups")

	; Button AdBlock
	Local $idBtnAdBlock = GUICtrlCreateButton(ChrW(59184), 230, 10, 20, 25)
	GUICtrlSetFont(-1, 10, 400, 0, "Segoe Fluent Icons")
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetTip(-1, "AdBlock")

	; Button DarkMode
	Local $idBtnDarkMode = GUICtrlCreateButton(ChrW(59297), 270, 10, 20, 25)
	GUICtrlSetFont(-1, 10, 400, 0, "Segoe Fluent Icons")
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetTip(-1, "DarkMode")

	; Button Highlight
	Local $idBtnHighlight = GUICtrlCreateButton(ChrW(59366), 290, 10, 20, 25)
	GUICtrlSetFont(-1, 10, 400, 0, "Segoe Fluent Icons")
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetTip(-1, "Highlight")

	; Button GoBack
	Local $idBtnGoBack = GUICtrlCreateButton(ChrW(59179), 320, 10, 20, 25)
	GUICtrlSetFont(-1, 10, 400, 0, "Segoe Fluent Icons")
	GUICtrlSetResizing(-1, $GUI_DOCKALL)

	; Button Stop
	Local $idBtnStop = GUICtrlCreateButton(ChrW(59153), 340, 10, 20, 25)
	GUICtrlSetFont(-1, 10, 400, 0, "Segoe Fluent Icons")
	GUICtrlSetResizing(-1, $GUI_DOCKALL)

	; Button GoForward
	Local $idBtnGoForward = GUICtrlCreateButton(ChrW(59178), 360, 10, 20, 25)
	GUICtrlSetFont(-1, 10, 400, 0, "Segoe Fluent Icons")
	GUICtrlSetResizing(-1, $GUI_DOCKALL)

	; Button Reload
	Local $idReload = GUICtrlCreateButton(ChrW(59180), 380, 10, 30, 25)
	GUICtrlSetFont(-1, 10, 400, 0, "Segoe Fluent Icons")
	GUICtrlSetResizing(-1, $GUI_DOCKALL)

	; Report Consolas ~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$idReportEdit = GUICtrlCreateEdit("", 10, 45, 400, 300, $ES_READONLY + $WS_VSCROLL)
	#forceref $idReportEdit
	GUICtrlSetFont(-1, 10, 400, 0, "Consolas")
	GUICtrlSetBkColor(-1, 0x121212)
	GUICtrlSetColor(-1, 0x00FF00)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)

	; Button SAVE AS PDF
	Local $idBtnPdf = GUICtrlCreateButton("SAVE AS PDF", 200, 350, 80, 25)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)

	; Button RUN SITE HEALTH CHECK
	$idAuditBtn = GUICtrlCreateButton("CHECK SITE HEALTH", 10, 350, 190, 25)
	GUICtrlSetFont(-1, 10, 800)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)

	; Separator Label
	GUICtrlCreateLabel("", 10, 385, 400, 3, $SS_GRAYFRAME)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)

	; JS Consolas ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Local $idJSEdit = GUICtrlCreateEdit(__JS_Example(), 10, 400, 400, 370)
	GUICtrlSetFont(-1, 10, 400, 0, "Consolas")
	GUICtrlSetBkColor(-1, 0x121212)
	GUICtrlSetColor(-1, 0x00FF00)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)

	; Button Execute JS
	Local $idBtnExecJS = GUICtrlCreateButton("Execute JS", 10, 780, 80, 25)
	GUICtrlSetResizing(-1, $GUI_DOCKALL)

	; Status Label ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$idStatusLabel = GUICtrlCreateLabel("", 10, 820, 400, 20)
	GUICtrlSetFont(-1, 10, 800)
;~ GUICtrlSetBkColor(-1, 0x808080)
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetResizing(-1, $GUI_DOCKSIZE + $GUI_DOCKBOTTOM)

	; WebView2 Setup ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	; Initialize WebView2 Manager and register events
	Local $oWebV2M = _NetWebView2_CreateManager("", "WebView_", "")
	If @error Then Exit ConsoleWrite("@@(" & @ScriptLineNumber & ") :: @error:" & @error & ", @extended:" & @extended & @CRLF)

	; create JavaScript Bridge object
	Local $oJSBridge = _NetWebView2_GetBridge($oWebV2M, "Bridge_")
	If @error Then Exit ConsoleWrite("@@(" & @ScriptLineNumber & ") :: @error:" & @error & ", @extended:" & @extended & @CRLF)

	; initialize browser - put it on the GUI
	Local $sProfileDirectory = @ScriptDir & "\NetWebView2Lib-UserDataFolder"
	_NetWebView2_Initialize($oWebV2M, $hGUI, $sProfileDirectory, 420, 45, 670, 795, True, True, 1.2, "0x1E1E1E")

	_NetWebView2_Navigate($oWebV2M, $sURL)
	WinSetState($hGUI, "", @SW_MAXIMIZE)
	GUISetState(@SW_SHOW)

	#EndRegion ; === GUI ===

	Local $idMsg = 0
	While 1
		$idMsg = GUIGetMsg()
		Switch $idMsg
			Case $GUI_EVENT_CLOSE
				ExitLoop

			Case $idBtnDarkMode
				$g_bDarkMode = Not $g_bDarkMode ; Status reversal (True/False)
				_ShowWebNotification($oWebV2M, "DarkMode " & $g_bDarkMode, ($g_bDarkMode ? "#FF6A00" : "#2196F3"))
				GUICtrlSetFont($idBtnDarkMode, 10, ($g_bDarkMode ? 700 : 400), 0, "Segoe Fluent Icons")
				Local $choose = $g_bDarkMode ? _ActivateDarkMode($oWebV2M) : $oWebV2M.ClearInjectedCss()
				#forceref $choose


			Case $idBtnAdBlock
				$g_bAdBlock = Not $g_bAdBlock ; Status reversal (True/False)
				_ShowWebNotification($oWebV2M, "AdBlock " & $g_bAdBlock, ($g_bAdBlock ? "#FF6A00" : "#2196F3"))
				GUICtrlSetFont($idBtnAdBlock, 10, ($g_bAdBlock ? 700 : 400), 0, "Segoe Fluent Icons")
				_SetAdBlock($oWebV2M, $g_bAdBlock)
				$oWebV2M.Reload()

			Case $idBtn_HideAllPopups
				$g_b_HideAllPopups = Not $g_b_HideAllPopups ; Status reversal (True/False)
				_ShowWebNotification($oWebV2M, "_HideAllPopups " & $g_b_HideAllPopups, ($g_b_HideAllPopups ? "#FF6A00" : "#2196F3"))
				GUICtrlSetFont($idBtn_HideAllPopups, 10, ($g_b_HideAllPopups ? 700 : 400), 0, "Segoe Fluent Icons")

			Case $idBtnHighlight
				$g_bHighlight = Not $g_bHighlight ; Status reversal (True/False)
				$oWebV2M.ToggleAuditHighlights($g_bHighlight)
				_ShowWebNotification($oWebV2M, "Highlights " & $g_bHighlight, ($g_bHighlight ? "#FF6A00" : "#2196F3"))
				GUICtrlSetFont($idBtnHighlight, 10, ($g_bHighlight ? 700 : 400), 0, "Segoe Fluent Icons")

			Case $idBtnSetZoom
				$oWebV2M.SetZoom(1.5) ; Zoom to 150%
				_ShowWebNotification($oWebV2M, "Zoom: 150%", "#2196F3")

			Case $idBtnResetZoom
				$oWebV2M.ResetZoom() ; Reset to 100%
				_ShowWebNotification($oWebV2M, "Zoom: 100%", "#4CAF50")

			Case $idBtnGoBack
				$oWebV2M.GoBack()

			Case $idBtnGoForward
				$oWebV2M.GoForward()

			Case $idBtnStop
				$oWebV2M.Stop()

			Case $idBtnClearBrowserData
				If MsgBox(36, "Confirm", "Do you want to clear your browsing data?") = 6 Then
					$oWebV2M.ClearBrowserData()
					_ShowWebNotification($oWebV2M, "Browser history & cookies cleared!", "#f44336")
				EndIf

			Case $idAuditBtn
				_RunHealthCheck($oWebV2M)

			Case $idReload
				$oWebV2M.Reload()

			Case $idURL
				$oWebV2M.Navigate(GUICtrlRead($idURL))
				ConsoleWrite("GUICtrlRead($idURL)=" & GUICtrlRead($idURL) & @CRLF)

			Case $idBtnPdf
				_CreateAndSavePDF($oWebV2M)

			Case $idBtnExecJS
				_NetWebView2_ExecuteScript($oWebV2M, GUICtrlRead($idJSEdit), $NETWEBVIEW2_EXECUTEJS_MODE0_FIREANDFORGET)

			Case Else
				If $idMsg > 0 Then ConsoleWrite("> Else Msg=" & $idMsg & @CRLF)

		EndSwitch
	WEnd

	_NetWebView2_CleanUp($oWebV2M, $oJSBridge)

EndFunc   ;==>_Example

Func _RunHealthCheck($oWebV2M)
	; Build the JS as a proper JSON object string
	Local $sJS = _
			"var audit = {" & _
			"    type: 'HEALTH_REPORT'," & _ ; Identify the message type
			"    h1Count: document.querySelectorAll('h1').length," & _
			"    missingAlt: document.querySelectorAll('img:not([alt]), img[alt=""""]').length," & _
			"    emptyLinks: document.querySelectorAll('a:not([href]), a[href=""""]').length," & _
			"    hasMetaDesc: document.querySelector('meta[name=""description""]') ? 'YES' : 'MISSING'," & _
			"    domSize: document.getElementsByTagName('*').length" & _
			"};" & _
			"window.chrome.webview.postMessage(JSON.stringify(audit));" ; Send as JSON string

	If IsObj($oWebV2M) Then _NetWebView2_ExecuteScript($oWebV2M, $sJS, $NETWEBVIEW2_EXECUTEJS_MODE0_FIREANDFORGET)
EndFunc   ;==>_RunHealthCheck

; ==============================================================================
; EVENT HANDLER: WebView Manager (Core System Events from C#)
; ==============================================================================
Func _WebView_OnMessageReceived($oWebV2M, $hGUI, $sMessage)
	; Uncomment for debugging core events
	ConsoleWrite("+> [SYSTEM]: " & $sMessage & @CRLF)

	Local Static $iAdCount = 0

	Local $aSplit = StringSplit($sMessage, "|")
	Local $sCommand = StringStripWS($aSplit[1], 3)

	Switch $sCommand
		Case "INIT_READY"
			GUICtrlSetData($idStatusLabel, "Engine Ready.")
			; Optional: Initial navigation if not set in Initialize
			; $oWebV2M.Navigate($sURL)

		Case "NAV_STARTING"
			GUICtrlSetState($idAuditBtn, $GUI_DISABLE)
			GUICtrlSetData($idStatusLabel, "Loading: " & GUICtrlRead($idURL))

		Case "NAV_COMPLETED"
			GUICtrlSetState($idAuditBtn, $GUI_ENABLE)
			GUICtrlSetData($idStatusLabel, "Ready" & ($g_bAdBlock ? " | 🛡️ Ads Blocked: " & $iAdCount : ""))

			; Auto-apply active features on new page load
			If $g_bDarkMode Then _ActivateDarkMode($oWebV2M)
			If $g_bHighlight Then $oWebV2M.ToggleAuditHighlights(True)
			If $g_b_HideAllPopups Then _HideAllPopups($oWebV2M)

		Case "TITLE_CHANGED"
			If $aSplit[0] > 1 Then
				WinSetTitle($hGUI, "", "AutoIt Auditor - " & $aSplit[2])
			EndIf

		Case "URL_CHANGED"
			If $aSplit[0] > 1 Then
				GUICtrlSetData($idURL, $aSplit[2])
				GUICtrlSendMsg($idURL, $EM_SETSEL, 0, 0)
				$oWebV2M.WebViewSetFocus() ; We give focus to the browser
				$iAdCount = 0 ; Reset ad counter for the new domain
			EndIf

		Case "BLOCKED_AD"
			$iAdCount += 1
			GUICtrlSetData($idStatusLabel, "Ready | 🛡️ Ads Blocked: " & $iAdCount)

		Case "DOWNLOAD_STARTING"
			; Format: DOWNLOAD_STARTING|FileName|Url
			If $aSplit[0] > 2 Then
				ConsoleWrite("!!! Download Started: " & $aSplit[2] & @CRLF)
				_FileWriteLog(@ScriptDir & "\audit_downloads.log", "Started: " & $aSplit[2] & " from " & $aSplit[3])
			EndIf

		Case "PDF_SUCCESS"
			MsgBox(64, "Success", "PDF Report saved successfully!")

		Case "PDF_ERROR"
			MsgBox(16, "Error", "PDF Export failed: " & $sMessage)

		Case "ERROR", "NAV_ERROR"
			Local $sErr = ($aSplit[0] > 1) ? $aSplit[2] : "Unknown Error"
			GUICtrlSetData($idStatusLabel, "Status: " & $sErr)
			ConsoleWrite("! System Error: " & $sMessage & @CRLF)

	EndSwitch
EndFunc   ;==>_WebView_OnMessageReceived

; ==============================================================================
; EVENT HANDLER: Bridge (JavaScript Messages via postMessage)
; ==============================================================================
Func _Bridge_OnMessageReceived($oWebV2M, $hGUI, $sMessage)
	#forceref $oWebV2M, $hGUI
	ConsoleWrite("+> [BRIDGE]: " & $sMessage & @CRLF)

	Local $sFirstChar = StringLeft($sMessage, 1)

	If $sFirstChar = "{" Or $sFirstChar = "[" Then

		ConsoleWrite("> JSON MESSAGE PROCESSING " & @CRLF)

		Local $oJson = _NetJson_CreateParser()
		If $oJson.Parse($sMessage) Then
			Local $sJobType = $oJson.GetTokenValue("type")

			Switch $sJobType
				Case "HEALTH_REPORT"
					_HandleHealthReportJSON($oJson)
					Return
				Case "SAVE_CSV"
					_HandleCSVExport($oJson.GetTokenValue("data"))
					Return
			EndSwitch
		EndIf
	Else

		ConsoleWrite("> LEGACY STRING PROCESSING (Pipe separated)" & @CRLF)

		Local $aParts = StringSplit($sMessage, "|")
		Local $sCommand = StringStripWS($aParts[1], 3)
		ConsoleWrite("$sCommand=" & $sCommand & @CRLF)

		Switch $sCommand
			Case "HEALTH_REPORT"
				; This handles the old format: HEALTH_REPORT|h1|alt|links|meta|dom
				_HandleHealthReportLegacy($sMessage)

			Case "SAVE_CSV"
				ConsoleWrite("SAVE_CSV**" & @CRLF)
				; This handles: SAVE_CSV:data...
				Local $sData = StringTrimLeft($sMessage, 9)
				_HandleCSVExport($sData)

			Case "CLOSE_APP"
				If MsgBox(36, "Confirm", "Exit Application?") = 6 Then Exit

			Case "ERROR"
				MsgBox(16, "JS Error", "Message: " & $sMessage)
		EndSwitch
	EndIf
EndFunc   ;==>_Bridge_OnMessageReceived

Func _HandleHealthReportJSON($oJson)
	Local $sReport = "=== SITE HEALTH REPORT (JSON) ===" & @CRLF & @CRLF
	$sReport &= "[1] H1 Tags: " & $oJson.GetTokenValue("h1Count") & @CRLF
	$sReport &= "[2] Missing Alts: " & $oJson.GetTokenValue("missingAlt") & @CRLF
	$sReport &= "[3] Broken Links: " & $oJson.GetTokenValue("emptyLinks") & @CRLF
	$sReport &= "[4] Meta Description: " & $oJson.GetTokenValue("hasMetaDesc") & @CRLF
	$sReport &= "[5] DOM Elements: " & $oJson.GetTokenValue("domSize") & _
			($oJson.GetTokenValue("domSize") > 1000 ? " (HEAVY PAGE)" : " (LIGHT PAGE)") & @CRLF
	$sReport &= "--------------------------" & @CRLF
	$sReport &= "Audit Completed at: " & @HOUR & ":" & @MIN
	GUICtrlSetData($idReportEdit, $sReport)
EndFunc   ;==>_HandleHealthReportJSON

Func _HandleHealthReportLegacy($sRaw)
	Local $aA = StringSplit($sRaw, "|")
	If $aA[0] < 6 Then Return

	Local $sReport = "=== SITE HEALTH REPORT (STRING) ===" & @CRLF & @CRLF
	$sReport &= "[1] H1 Tags: " & $aA[2] & @CRLF
	$sReport &= "[2] Images w/o Alt: " & $aA[3] & @CRLF
	$sReport &= "[3] Broken/Empty Links: " & $aA[4] & @CRLF
	$sReport &= "[4] Meta Description: " & $aA[5] & @CRLF
	$sReport &= "[5] Total DOM Elements: " & $aA[6] & @CRLF
	GUICtrlSetData($idReportEdit, $sReport)
EndFunc   ;==>_HandleHealthReportLegacy

Func _HandleCSVExport($sData)
	If $sData = "" Then Return MsgBox(48, "Warning", "No data to export.")
	Local $sCSVPath = @ScriptDir & "\Export_" & @HOUR & @MIN & @SEC & "_" & @MSEC & ".csv"
	Local $hFile = FileOpen($sCSVPath, 2)
	FileWrite($hFile, $sData)
	FileClose($hFile)
	ShellExecute($sCSVPath)
EndFunc   ;==>_HandleCSVExport

Func _CreateAndSavePDF($oWebV2M)
	Local $sAuditResults = GUICtrlRead($idReportEdit)

	If $sAuditResults = "" Then
		MsgBox(48, "Caution", "You must run the Health Check first!")
		Return
	EndIf

	Local $sHTML = "<html><head><style>" & _
			"body { font-family: 'Segoe UI', sans-serif; padding: 40px; line-height: 1.6; }" & _
			"h1 { color: #2c3e50; border-bottom: 2px solid #2c3e50; }" & _
			".report-box { background: #f9f9f9; border: 1px solid #ddd; padding: 20px; white-space: pre-wrap; }" & _
			"</style></head><body>" & _
			"<h1>Website Health Audit Report</h1>" & _
			"<p>Generated by AutoIt WebView2 Auditor</p>" & _
			"<div class='report-box'>" & $sAuditResults & "</div>" & _
			"</body></html>"

	; Show it in Browser
	_NetWebView2_NavigateToString($oWebV2M, $sHTML, $NETWEBVIEW2_MESSAGE__TITLE_CHANGED)

	; save to PDF
	Local $sFinalPDF = @ScriptDir & "\" & @HOUR & @MIN & @SEC & "_" & @MSEC & "_Health_Report.pdf"
	$oWebV2M.ExportToPdf($sFinalPDF)

EndFunc   ;==>_CreateAndSavePDF

; MessageTip
Func _ShowWebNotification($oWebV2M, $sMessage, $sBgColor = "#4CAF50", $iDuration = 3000)
	; We use a unique ID 'autoit-notification' to find and replace existing alerts
	Local $sJS = _
			"var oldDiv = document.getElementById('autoit-notification');" & _
			"if (oldDiv) { oldDiv.remove(); }" & _
			"var div = document.createElement('div');" & _
			"div.id = 'autoit-notification';" & _ ; Assign the ID
			"div.style = 'position:fixed; top:20px; left:50%; transform:translateX(-50%); padding:15px; background:" & $sBgColor & _
			"; color:white; border-radius:8px; z-index:9999; font-family:sans-serif; box-shadow: 0 4px 6px rgba(0,0,0,0.2); transition: opacity 0.5s;';" & _
			"div.innerText = '" & $sMessage & "';" & _
			"document.body.appendChild(div);" & _
			"setTimeout(() => {" & _
			"   var target = document.getElementById('autoit-notification');" & _
			"   if(target) { target.style.opacity = '0'; setTimeout(() => target.remove(), 500); }" & _
			"}, " & $iDuration & ");"

	$oWebV2M.ExecuteScript($sJS)
EndFunc   ;==>_ShowWebNotification

Func _ActivateSeoAudit($oWebV2M)
	Local $sCSS = "img:not([alt]) { border: 10px solid red !important; outline: 5px solid yellow !important; } " & _
			"a[href='#'] { background: #ffea00 !important; color: black !important; border: 2px dashed black !important; }"
	$oWebV2M.InjectCss($sCSS)
EndFunc   ;==>_ActivateSeoAudit

Func _ActivateDarkMode($oWebV2M)
	Local $sCSS = "html, body { background: #121212 !important; color: #e0e0e0 !important; } " & _
			"a { color: #bb86fc !important; }"
	$oWebV2M.InjectCss($sCSS)
EndFunc   ;==>_ActivateDarkMode

Func _HideAllPopups($oWebV2M)
	; A list of the most common selectors for cookie banners and popups
	Local $sSelectors = ".fc-consent-root, .cc-window, #onetrust-consent-sdk, .css-privacy-banner"

	; We send it through InjectCss
	$oWebV2M.InjectCss($sSelectors & " { display: none !important; visibility: hidden !important; pointer-events: none !important; }")
EndFunc   ;==>_HideAllPopups

Func _SetAdBlock($oWebV2M, $bEnable = True)
	If $bEnable Then
		; clean the old list so we don't have duplicates
		$oWebV2M.ClearBlockRules()

		; activate the switch
		$oWebV2M._SetAdBlock(True)

		; Add rules
		$oWebV2M.AddBlockRule("doubleclick.net")
		$oWebV2M.AddBlockRule("google-analytics.com")
		$oWebV2M.AddBlockRule("facebook.net")
		$oWebV2M.AddBlockRule("adservice.google.com")
		$oWebV2M.AddBlockRule("googletagmanager.com")

		ConsoleWrite("+> ️AdBlocker Enabled" & @CRLF)
	Else
		$oWebV2M._SetAdBlock(False)
		$oWebV2M.ClearBlockRules() ; Optional: clear memory when closing
		ConsoleWrite("+> ️AdBlocker Disabled." & @CRLF)
	EndIf
EndFunc   ;==>_SetAdBlock

Func __JS_Example()
	Return _
			"var results = [];" & @CRLF & _
			"var rows = document.querySelectorAll('table tr');" & @CRLF & _
			"rows.forEach(row => {" & @CRLF & _
			"    var cells = row.querySelectorAll('td');" & @CRLF & _
			"    if (cells.length >= 2) {" & @CRLF & _
			"        // innerText automatically cleans up <wbr> and <tb> tags" & @CRLF & _
			"        var name = cells[0].innerText.trim();" & @CRLF & _
			"        var desc = cells[1].innerText.trim();" & @CRLF & _
			"        " & @CRLF & _
			"        desc = desc.replace(/[\r\n]+/g, ' ');" & @CRLF & _
			"        " & @CRLF & _
			"        results.push(name + ' | ' + desc);" & @CRLF & _
			"    }" & @CRLF & _
			"});" & @CRLF & _
			"if (results.length > 0) {" & @CRLF & _
			"    window.chrome.webview.postMessage('SAVE_CSV|' + results.join('\n'));" & @CRLF & _
			"} else {" & @CRLF & _
			"    window.chrome.webview.postMessage('ERROR: No data found in table cells');" & @CRLF & _
			"}"
EndFunc   ;==>__JS_Example

Func __ErrFunc($oError) ; Global COM Error Handler
	ConsoleWrite('@@ Line(' & $oError.scriptline & ') : COM Error Number: (0x' & Hex($oError.number, 8) & ') ' & $oError.windescription & @CRLF)
EndFunc   ;==>__ErrFunc

