#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7
#include <WindowsConstants.au3>
#include <GUIConstants.au3>
#include <GuiMenu.au3>
#include <Misc.au3>
#include "_WV2_ExtensionPicker.au3"

; Web_Demo_v1.4.2_MASTER.au3
; The Ultimate Comprehensive Demo

OnAutoItExitRegister("_ExitApp")

; Global objects for COM
Global $oWeb, $oJS
Global $oMyError = ObjEvent("AutoIt.Error", "_ErrFunc") ; COM Error Handler
Global $hGUI, $Bar
Global $g_sProfilePath = @ScriptDir & "\UserDataFolder"
Global $hDLL = DllOpen("user32.dll")
Global $g_bURLFullSelected

_MainGUI()

#Region ; === MainGUI ===
;---------------------------------------------------------------------------------------
Func _MainGUI()
	$hGUI = GUICreate("WebView2 v1.4.2 - MASTER DEMO", 1300, 900, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPCHILDREN))
	GUISetBkColor(0x1E1E1E, $hGUI)

	; 1. Initialize Objects
	$oWeb = ObjCreate("NetWebView2.Manager")
	If Not IsObj($oWeb) Then Return MsgBox(16, "Error", "WebView2 Library not registered!")

	; 2. Register Events (Direct Methods in v1.4.2)
	; ⚠️ IMPORTANT: Explicit 3rd parameter is required for reliable .NET binding in AutoIt
	ObjEvent($oWeb, "Web_", "IWebViewEvents")

	; 3. Setup Bridge
	$oJS = $oWeb.GetBridge()
	ObjEvent($oJS, "JS_", "IBridgeEvents")

	; 4. Make a Basic ToolBar for Browsing navigation
	$Bar = _Web_MakeBar($hGUI, 1)

	; 5. Initialize Browser
	; ⚠️ IMPORTANT: Enclose ($hGUI) in parentheses to force "Pass-by-Value" (COM requirement).
	$oWeb.Initialize(($hGUI), $g_sProfilePath, 0, 25, 1300, 900 - 25)

	Do
		Sleep(50)
	Until $oWeb.IsReady

	; Standard Config
	$oWeb.SetAutoResize(True) ; Using SetAutoResize(True) to skip WM_SIZE
	$oWeb.BackColor = "#1E1E1E"
	$oWeb.AreDefaultContextMenusEnabled = False ; Custom menu handling

	; Inject Master Bridge
	$oWeb.AddInitializationScript(FileRead(@ScriptDir & "\_Bridge.js"))

	; Navigate to a good demo page
	$oWeb.Navigate("https://en.wikipedia.org/wiki/List_of_countries_and_dependencies_by_population")

	GUIRegisterMsg($WM_COMMAND, "WM_COMMAND") ; ; Register the WM_COMMAND message to handle URL FullSelection

	GUISetState(@SW_SHOW, $hGUI)

	Local $iMsg

	While 1
		$iMsg = GUIGetMsg()
		Switch $iMsg
			Case $GUI_EVENT_CLOSE
				Exit
			Case $Bar.Navigation
				_NavButton()
			Case $Bar.Address
				If _IsPressed("0D", $hDLL) Then ; ENTER key
					_NavButton("Navigate")
					_NavButton()
				Else
					AdlibRegister("_SetNavigateToReload", 700)
				EndIf

			Case $Bar.GoBack
				$oWeb.GoBack()
			Case $Bar.GoForward
				$oWeb.GoForward()
			Case $Bar.Application_Menu
				_ShowApplicationMenu()
			Case $Bar.Features
				_ShowFeaturesMenu()
		EndSwitch

		; 1. Διαχείριση Full Selection (Focus)
		If $g_bURLFullSelected Then
			$g_bURLFullSelected = False
			GUICtrlSendMsg($Bar.Address, $EM_SETSEL, 0, -1)
		EndIf
	WEnd
EndFunc   ;==>_MainGUI
;---------------------------------------------------------------------------------------
Func _Web_MakeBar($hGUI, $bAddress = 1) ; Make a Basic ToolBar for Browsing navigation
	; Defining the main buttons with the Fluent Icons
	Local $Btn[][] = [[59136, "Application_Menu"], [59308, "Features"] _
			, [59179, "GoBack"], [59178, "GoForward"], [59180, "Navigation"]]

	Local $iX = 0, $iY = 0, $iH = 25, $iW = 25, $iCnt = UBound($Btn)
	Local $m[] ; Map object to return IDs

	; Creating the Buttons
	For $i = 0 To $iCnt - 1
		$m[$Btn[$i][1]] = GUICtrlCreateButton(ChrW($Btn[$i][0]), $iX, $iY, $iW, $iH)
		GUICtrlSetFont(-1, 12, 400, 0, "Segoe Fluent Icons")
		GUICtrlSetTip(-1, StringReplace($Btn[$i][1], "_", " "))
		GUICtrlSetResizing(-1, $GUI_DOCKALL)
		$iX += $iW
	Next

	; Creating the Address Bar
	Local $aCsz = WinGetClientSize($hGUI)
	Local $iInputW = $aCsz[0] - $iX - 5
	$m.Address = GUICtrlCreateInput("", $iX, $iY, $iInputW, $iH)
	GUICtrlSetFont(-1, 11, 400, 0, "Segoe UI")
	GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKMENUBAR)
	If Not $bAddress Then GUICtrlSetState(-1, $GUI_HIDE)

	Return $m
EndFunc   ;==>_Web_MakeBar
;---------------------------------------------------------------------------------------
Func _NavButton($sSetState = Default) ; Set or executes the action of Navigation button (Reload/Stop/Navigate)
	Local Static $sState = "Reload"

	; 59180 = Reload ; 59153 = Cancel ; 59217 = ReturnKey

	If $sSetState <> Default Then
		Switch $sSetState
			Case "Reload"
				GUICtrlSetData($Bar.Navigation, ChrW(59180))
				GUICtrlSetTip($Bar.Navigation, "Reload")
			Case "Stop"
				GUICtrlSetData($Bar.Navigation, ChrW(59153))
				GUICtrlSetTip($Bar.Navigation, "Stop")
			Case "Navigate"
				If $sState = $sSetState Then Return
				AdlibUnRegister("_SetNavigateToReload") ; UnRegister it (if exist)
				GUICtrlSetData($Bar.Navigation, ChrW(59217))
				GUICtrlSetTip($Bar.Navigation, "Navigate")
		EndSwitch
		$sState = $sSetState
		Return
	EndIf

	Switch $sState
		Case "Reload"
			$oWeb.Reload()
		Case "Stop"
			$oWeb.Stop()
		Case "Navigate"
			Sleep(100)
			_Web_GoTo(GUICtrlRead($Bar.Address))
	EndSwitch
EndFunc   ;==>_NavButton
;---------------------------------------------------------------------------------------
Func _Web_GoTo($sURL) ; Navigates to a URL or performs a Google search if the input is not a URL.
	$sURL = StringStripWS($sURL, 3)
	If $sURL = "" Then Return False

	; Check if it already has a protocol (http://, https://, file://, etc.)
	Local $bHasProtocol = StringRegExp($sURL, '(?i)^[a-z]+://', 0)

	; Check if it looks like a domain (e.g., test.com, autoitscript.com)
	Local $bIsURL = StringRegExp($sURL, '(?i)^([a-z0-9\-]+\.)+[a-z]{2,}', 0)

	Local $sFinalURL = ""

	If $bHasProtocol Then
		$sFinalURL = $sURL
	ElseIf $bIsURL Then
		; Prepend https for domains without protocol
		$sFinalURL = "https://" & $sURL
	Else
		; It's a search query. Use the new EncodeURI for perfect character handling
		$sFinalURL = "https://www.google.com/search?q=" & $oWeb.EncodeURI($sURL)
	EndIf

	; Execution
	ConsoleWrite("-> Web_GoTo: " & $sFinalURL & @CRLF)
	$oWeb.Navigate($sFinalURL)
	Return True
EndFunc   ;==>_Web_GoTo
;---------------------------------------------------------------------------------------
Func _ExitApp() ; OnAutoItExitRegister
	DllClose($hDLL)
	If IsObj($oWeb) Then $oWeb.Cleanup()
EndFunc   ;==>_ExitApp
;---------------------------------------------------------------------------------------
Func _ErrFunc($oError) ; COM Error Handler
	ConsoleWrite('@@ Line(' & $oError.scriptline & ') : COM Error Number: (0x' & Hex($oError.number, 8) & ') ' & $oError.windescription & @CRLF)
EndFunc   ;==>_ErrFunc
;---------------------------------------------------------------------------------------
Func WM_COMMAND($hWnd, $iMsg, $wParam, $lParam) ; Register the WM_COMMAND message to handle URL FullSelection
	#forceref $hWnd, $iMsg
	Local Static $hidURL = GUICtrlGetHandle($Bar.Address)
	Local $iCode = BitShift($wParam, 16)
	If $lParam = $hidURL Then
		Switch $iCode
			Case $EN_SETFOCUS
				$g_bURLFullSelected = True
			Case $EN_CHANGE
				_NavButton("Navigate")
		EndSwitch
	EndIf
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_COMMAND
;---------------------------------------------------------------------------------------
Func _SetNavigateToReload()
	_NavButton("Reload")
	AdlibUnRegister("_SetNavigateToReload") ; unregister itself.
EndFunc   ;==>_SetNavigateToReload
#EndRegion ; === MainGUI ===

#Region ; === CONTEX MENUS ===
;---------------------------------------------------------------------------------------
Func _ShowApplicationMenu()
	Local $hMenu = _GUICtrlMenu_CreatePopup()
	_GUICtrlMenu_AddMenuItem($hMenu, "Google", 1001)
	_GUICtrlMenu_AddMenuItem($hMenu, "AutoIt", 1002)
	_GUICtrlMenu_AddMenuItem($hMenu, "wikipedia", 1003)
	_GUICtrlMenu_AddMenuItem($hMenu, "demoqa", 1004)
	_GUICtrlMenu_AddMenuItem($hMenu, "microsoft", 1005)
	_GUICtrlMenu_AddMenuItem($hMenu, "") ; separator

	_GUICtrlMenu_AddMenuItem($hMenu, "Extensions Manager", 1020)
	_GUICtrlMenu_AddMenuItem($hMenu, "Ghostery", 1010)
	_GUICtrlMenu_AddMenuItem($hMenu, "DarkReader", 1011)
	_GUICtrlMenu_AddMenuItem($hMenu, "") ; separator

	_GUICtrlMenu_AddMenuItem($hMenu, "Clear browser history", 1021)

	Local $tPos = _WinAPI_GetMousePos()
	Local $iCmd = _GUICtrlMenu_TrackPopupMenu($hMenu, $hGUI, DllStructGetData($tPos, "X"), DllStructGetData($tPos, "Y"), 1, 1, 2)

	Switch $iCmd
		Case 1001
			$oWeb.Navigate("https://www.google.com")
		Case 1002
			$oWeb.Navigate("https://www.autoitscript.com/forum")
		Case 1003
			$oWeb.Navigate("https://en.wikipedia.org/wiki/List_of_countries_and_dependencies_by_population")
		Case 1004
			$oWeb.Navigate("https://demoqa.com/text-box")
		Case 1005
			$oWeb.Navigate("https://learn.microsoft.com/en-us/dotnet/api/microsoft.web.webview2.core.corewebview2profile.addbrowserextensionasync?view=webview2-dotnet-1.0.3595.46	")
		Case 1010
			$oWeb.Navigate("extension://mlomiejdfkolichcflejclcbmpeaniij/pages/panel/index.html")
		Case 1011
			$oWeb.Navigate("extension://eimadpbcbfnmbkopoojfekhnkhdbieeh/ui/popup/index.html")
		Case 1020
			_WV2_ShowExtensionPicker(500, 600, $hGUI, @ScriptDir & "\..\Extensions_Lib", $g_sProfilePath)
		Case 1021
			If MsgBox(36, "Confirm", "Clear all browser history/cookies?") = 6 Then $oWeb.ClearBrowserData()
	EndSwitch
	_GUICtrlMenu_DestroyMenu($hMenu)
EndFunc   ;==>_ShowApplicationMenu
;---------------------------------------------------------------------------------------
Func _ShowFeaturesMenu()
	Local Static $bHighlight = 0
	Local $hMenu = _GUICtrlMenu_CreatePopup()

	_GUICtrlMenu_AddMenuItem($hMenu, "Scan for HTML Tables", 3000)
	_GUICtrlMenu_AddMenuItem($hMenu, "") ; separator

	_GUICtrlMenu_AddMenuItem($hMenu, "Save Form Map to JSON File", 3010)
	_GUICtrlMenu_AddMenuItem($hMenu, "Fill Form from JSON File", 3011)
	_GUICtrlMenu_AddMenuItem($hMenu, "") ; separator

	_GUICtrlMenu_AddMenuItem($hMenu, "Extract Page Summary", 2001)
	_GUICtrlMenu_AddMenuItem($hMenu, "Extract All Links", 2002)
	_GUICtrlMenu_AddMenuItem($hMenu, "Extract All Images", 2003)
	_GUICtrlMenu_AddMenuItem($hMenu, "") ; separator

	_GUICtrlMenu_AddMenuItem($hMenu, "Highlights", 3020)
	_GUICtrlMenu_AddMenuItem($hMenu, "Inject Custom CSS", 3022)
	_GUICtrlMenu_AddMenuItem($hMenu, "") ; separator
	_GUICtrlMenu_AddMenuItem($hMenu, "Full Page Screenshot", 3023)


	Local $tPos = _WinAPI_GetMousePos()
	Local $iCmd = _GUICtrlMenu_TrackPopupMenu($hMenu, $hGUI, DllStructGetData($tPos, "X"), DllStructGetData($tPos, "Y"), 1, 1, 2)

	Switch $iCmd
		Case 2001
			$oWeb.ExecuteScript("scrapeSummary();")
		Case 2002
			$oWeb.ExecuteScript("scrapeLinks();")
		Case 2003
			$oWeb.ExecuteScript("scrapeImages();")
		Case 3000
			$oWeb.ExecuteScript("scanTables();")
		Case 3010
			$oWeb.ExecuteScript("mapForm();")
		Case 3011
			_FillFormFromJSON()
		Case 3020
			$bHighlight = Not $bHighlight ; Status reversal (True/False)
			$oWeb.ToggleAuditHighlights($bHighlight)
		Case 3022
			Local $sCSS = "body { filter: sepia(0.5) !important; }"
			$oWeb.InjectCss($sCSS)
		Case 3023
			_StartScreenshotSequence()
	EndSwitch
	_GUICtrlMenu_DestroyMenu($hMenu)
EndFunc   ;==>_ShowFeaturesMenu
;---------------------------------------------------------------------------------------
#EndRegion ; === CONTEX MENUS ===

#Region ; === EVENTS (v1.4.2 Direct) ===
;---------------------------------------------------------------------------------------
Func Web_OnURLChanged($sURL)
	#forceref $sURL
;~ 	GUICtrlSetData($Bar.Address, $sURL)
EndFunc   ;==>Web_OnURLChanged
;---------------------------------------------------------------------------------------
Func Web_OnTitleChanged($sTitle)
	WinSetTitle($hGUI, "", "WebView2 v1.4.2 MASTER - " & $sTitle)
EndFunc   ;==>Web_OnTitleChanged
;---------------------------------------------------------------------------------------
Func Web_OnNavigationStarting($sURL)
	#forceref $sURL
	; Progress bar on top of page
	$oWeb.ExecuteScript("startProgress(30);")
	_NavButton("Stop")
EndFunc   ;==>Web_OnNavigationStarting
;---------------------------------------------------------------------------------------
Func Web_OnNavigationCompleted($bSuccess, $iError)
	#forceref $bSuccess, $iError
	$oWeb.ExecuteScript("finalizeProgress();")

	GUICtrlSetData($Bar.Address, $oWeb.GetSource())
	_NavButton("Reload")

	; Using the new Getters for dynamic UI
	GUICtrlSetState($Bar.GoBack, ($oWeb.GetCanGoBack() ? $GUI_ENABLE : $GUI_DISABLE))
	GUICtrlSetState($Bar.GoForward, ($oWeb.GetCanGoForward() ? $GUI_ENABLE : $GUI_DISABLE))
	$oWeb.WebViewSetFocus() ; We give focus to the browser
EndFunc   ;==>Web_OnNavigationCompleted
;---------------------------------------------------------------------------------------
Func Web_OnMessageReceived($sMessage)
	; ConsoleWrite("+> [Web Events]: " & (StringLen($sMessage) > 150 ? StringLeft($sMessage, 150) & "..." : $sMessage) & @CRLF)
	Local $iSplitPos = StringInStr($sMessage, "|")
	Local $sCommand = $iSplitPos ? StringStripWS(StringLeft($sMessage, $iSplitPos - 1), 3) : $sMessage
	Local $sData = $iSplitPos ? StringTrimLeft($sMessage, $iSplitPos) : ""
	Local $aParts
	Switch $sCommand
		Case "CDP_RESULT"
			$aParts = StringSplit($sData, "|")
			_HandleScreenshotSequence($aParts[1], $aParts[2])

		Case "debug"

	EndSwitch
EndFunc   ;==>Web_OnMessageReceived
;---------------------------------------------------------------------------------------
Func Web_OnContextMenuRequested($sLink, $iX, $iY, $sSelection)
	Local $hMenu = _GUICtrlMenu_CreatePopup()

	; Smart Menu: Check what's under the cursor via JS callback or coordinates
	; For better integration, we can ask JS what's there
	Local $sTag = $oWeb.ExecuteScriptWithResult("document.elementFromPoint(" & $iX & "," & $iY & ").closest('table') ? 'TABLE' : document.elementFromPoint(" & $iX & "," & $iY & ").tagName")

	If $sTag = "TABLE" Then
		_GUICtrlMenu_AddMenuItem($hMenu, "📥  Export this Table to CSV", 4001)
		_GUICtrlMenu_AddMenuItem($hMenu, "") ; separator
	Else
		_GUICtrlMenu_AddMenuItem($hMenu, "💾  Save Form Map to JSON File", 3010)
		_GUICtrlMenu_AddMenuItem($hMenu, "🗃️  Fill Form from JSON File", 3011)
		_GUICtrlMenu_AddMenuItem($hMenu, "") ; separator
	EndIf

	If $sSelection <> "" Then _GUICtrlMenu_AddMenuItem($hMenu, "📋  Copy Text Selection", 4010)
	If $sLink <> "" Then _GUICtrlMenu_AddMenuItem($hMenu, "Copy Link URL", 4011)
	If $sSelection <> "" Or $sLink <> "" Then _GUICtrlMenu_AddMenuItem($hMenu, "") ; separator

	_GUICtrlMenu_AddMenuItem($hMenu, "🔬  Inspect Element", 4020)

	Local $iCmd = _GUICtrlMenu_TrackPopupMenu($hMenu, $hGUI, -1, -1, 1, 1, 2)
	Switch $iCmd
		Case 3010
			$oWeb.ExecuteScript("mapForm();")
		Case 3011
			_FillFormFromJSON()
		Case 4001
			$oWeb.ExecuteScript("extractTableFromPoint(" & $iX & "," & $iY & ");")
		Case 4010
			ClipPut($sSelection)
		Case 4011
			ClipPut($sLink)
		Case 4020
			$oWeb.OpenDevToolsWindow()
	EndSwitch
	_GUICtrlMenu_DestroyMenu($hMenu)
EndFunc   ;==>Web_OnContextMenuRequested
;---------------------------------------------------------------------------------------
Func JS_OnMessageReceived($sMessage)
	Local $oJson = ObjCreate("NetJson.Parser")
	If Not $oJson.Parse($sMessage) Then Return

	Local $sType = $oJson.GetTokenValue("type")
	Switch $sType
		Case "TABLE_LIST"
			_ShowTableSelector($sMessage)
		Case "TABLE_DATA"
			_ProcessTableData($oJson.GetTokenValue("rows"))
		Case "FORM_MAP"
			_SaveFormToJSON($oJson.GetTokenValue("data"))
		Case "SCRAPE_RESULT"
			_SaveScrapeResult($oJson)
	EndSwitch
EndFunc   ;==>JS_OnMessageReceived
;---------------------------------------------------------------------------------------
#EndRegion ; === EVENTS (v1.4.2 Direct) ===

#Region ; === SCRAPING & TABLES & FORMS ===
;---------------------------------------------------------------------------------------
Func _ShowTableSelector($sJson)
	Local $oP = ObjCreate("NetJson.Parser")
	$oP.Parse($sJson)
	Local $iCnt = $oP.GetArrayLength("data")
	If $iCnt = 0 Then Return

	Local $sList = "Select Table for Export:" & @CRLF
	For $i = 0 To $iCnt - 1
		$sList &= StringFormat("[%d] Rows: %s, ID: %s\n", $i, $oP.GetTokenValue("data[" & $i & "].rowCount"), $oP.GetTokenValue("data[" & $i & "].id"))
	Next

	Local $iSel = InputBox("Table Selector", $sList, "0", "", 400, 300, Default, Default, 0, $hGUI)
	If Not @error Then $oWeb.ExecuteScript("getTableDataByIndex(" & $iSel & ");")
EndFunc   ;==>_ShowTableSelector
;---------------------------------------------------------------------------------------
Func _ProcessTableData($sRowsJson)
	Local $oRows = ObjCreate("NetJson.Parser")
	$oRows.Parse($sRowsJson)
	Local $iR = $oRows.GetArrayLength("")
	Local $iC = $oRows.GetArrayLength("[0]")
	Local $aArr[$iR][$iC]
	For $r = 0 To $iR - 1
		For $c = 0 To $iC - 1
			$aArr[$r][$c] = $oRows.GetTokenValue("[" & $r & "][" & $c & "]")
		Next
	Next
	_TableExportAsCSV($aArr)
EndFunc   ;==>_ProcessTableData
;---------------------------------------------------------------------------------------
Func _TableExportAsCSV(ByRef $aArray)
	Local $iRows = UBound($aArray, 1), $iCols = UBound($aArray, 2), $sCSV = ""
	For $i = 0 To $iRows - 1
		For $j = 0 To $iCols - 1
			Local $cell = StringReplace($aArray[$i][$j], '"', '""')
			$sCSV &= '"' & $cell & '"' & ($j < $iCols - 1 ? ";" : "")
		Next
		$sCSV &= @CRLF
	Next
	Local $sTitle = StringRegExpReplace($oWeb.GetDocumentTitle(), '[\\/:*?"<>|]', "_")
	Local $sFile = @ScriptDir & "\" & $sTitle & "_" & @HOUR & @MIN & ".csv"
	Local $hFile = FileOpen($sFile, 128 + 2) ; UTF-8 BOM
	FileWrite($hFile, $sCSV)
	FileClose($hFile)
	ShellExecute($sFile)
EndFunc   ;==>_TableExportAsCSV
;---------------------------------------------------------------------------------------
Func _FillFormFromJSON()
	Local $sFile = FileOpenDialog("Select Form Data", @ScriptDir & "\Forms_Data\", "JSON Files (*.json)")
	If @error Then Return
	Local $sJson = FileRead($sFile)
	ConsoleWrite("$sJson=" & $sJson & @CRLF)

	; Use Base64 encoding to pass JSON string safely to JavaScript (avoids issues with newlines and quotes)
	Local $sB64 = $oWeb.EncodeB64($sJson)
	$oWeb.ExecuteScript("fillForm(atob('" & $sB64 & "'));")
EndFunc   ;==>_FillFormFromJSON
;---------------------------------------------------------------------------------------
Func _SaveFormToJSON($sData)
	; Sanitize document title for filename compatibility
	Local $sTitle = "Untitled_Page"
	If IsObj($oWeb) Then $sTitle = $oWeb.GetDocumentTitle()
	$sTitle = StringRegExpReplace($sTitle, '[\\/:*?"<>|]', "_")
	Local $sDir = @ScriptDir & "\Forms_Data\"
	If Not FileExists(@ScriptDir & "\Forms_Data\") Then DirCreate(@ScriptDir & "\Forms_Data\")

	; Save JSON mapping to file (UTF-8 with BOM)
	Local $sFilePath = $sDir & $sTitle & "_form_" & @YEAR & @MON & @MDAY & "-" & @HOUR & @MIN & "-" & @SEC & @MSEC & ".json"
	Local $hFile = FileOpen($sFilePath, 128 + 2)
	If $hFile <> -1 Then
		FileWrite($hFile, $sData)
		FileClose($hFile)
		MsgBox(64, "Success", "Form structure saved to: " & @CRLF & $sFilePath)
	Else
		ConsoleWrite("!   Error: Could not save form mapping file." & @CRLF)
	EndIf
EndFunc   ;==>_SaveFormToJSON
;---------------------------------------------------------------------------------------
Func _SaveScrapeResult($oJson)
	Local $cat = $oJson.GetTokenValue("category")
	Local $sFilePath = @ScriptDir & "\scrape_" & $cat & "_" & @YEAR & @MON & @MDAY & "-" & @HOUR & @MIN & "-" & @SEC & @MSEC & ".json"
	Local $hFile = FileOpen($sFilePath, 128 + 2)
	If $hFile <> -1 Then
		FileWrite($hFile, $oJson.GetTokenValue("data"))
		FileClose($hFile)
		MsgBox(64, "Success", "Scrape Result [" & $cat & "] saved to: " & @CRLF & $sFilePath)
	Else
		ConsoleWrite("!   Error: Could not save Scrape Result to file." & @CRLF)
	EndIf
EndFunc   ;==>_SaveScrapeResult
;---------------------------------------------------------------------------------------
Func _StartScreenshotSequence()
	Local $sTitle = $oWeb.GetDocumentTitle()
	$sTitle = StringRegExpReplace($sTitle, '[\\/:*?"<>|]', "_")
	Local $sSavePath = @ScriptDir & "\" & $sTitle & "_FullCapture.png"
	_HandleScreenshotSequence("Screenshot", $sSavePath)
EndFunc   ;==>_StartScreenshotSequence
;---------------------------------------------------------------------------------------
Func _HandleScreenshotSequence($sMethod, $sData)
	Local Static $sSavePath = "", $bProcessing = False
	If $sMethod = "Screenshot" Then
		$bProcessing = True
		$sSavePath = $sData
		$oWeb.CallDevToolsProtocolMethod("Page.getLayoutMetrics", "{}")
		Return
	EndIf
	If Not $bProcessing Then Return

	Local $oParser = ObjCreate("NetJson.Parser")
	Switch $sMethod
		Case "Page.getLayoutMetrics"
			$oParser.Parse($sData)
			Local $iW = Int($oParser.GetTokenValue("contentSize.width"))
			Local $iH = Int($oParser.GetTokenValue("contentSize.height"))

			Local $iMaxGpuHeight = 16384 ; The usual limit of GPU textures
			Local $fScale = 1.0

			; If the height exceeds the limit, calculate the exact percentage of reduction
			If $iH > $iMaxGpuHeight Then
				$fScale = $iMaxGpuHeight / $iH
				; We set a floor at 0.25 to prevent the image from becoming too small
				If $fScale < 0.25 Then $fScale = 0.25
				$fScale = Round($fScale, 2)
				ConsoleWrite("!> Dynamic Scaling Active: Reducing scale to " & $fScale & " to fit GPU limits." & @CRLF)
			EndIf

			Local $sParams = StringFormat('{"width":%d, "height":%d, "deviceScaleFactor":%.2f, "mobile":false}', $iW, $iH, $fScale)
			$oWeb.CallDevToolsProtocolMethod("Emulation.setDeviceMetricsOverride", $sParams)

		Case "Emulation.setDeviceMetricsOverride"
			Sleep(100) ; Wait for render
			$oWeb.CallDevToolsProtocolMethod("Page.captureScreenshot", '{"format": "png", "fromSurface": true}')
		Case "Page.captureScreenshot"
			$oParser.Parse($sData)
			Local $sB64 = $oParser.GetTokenValue("data")
			If $sB64 <> "" Then
				; Using NetJson.Parser for Base64 To File
				$oParser.DecodeB64ToFile($sB64, $sSavePath)
				ConsoleWrite("> Full Page Captured: " & $sSavePath & @CRLF)
				ShellExecute($sSavePath)
			EndIf

			; Reset
			$oWeb.CallDevToolsProtocolMethod("Emulation.clearDeviceMetricsOverride", "{}")
			$oWeb.ExecuteScript("document.documentElement.style.height = ''; document.body.style.height = '';")
			$bProcessing = False
	EndSwitch
EndFunc   ;==>_HandleScreenshotSequence
;---------------------------------------------------------------------------------------
#EndRegion ; === SCRAPING & TABLES & FORMS ===
