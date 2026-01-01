#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7
#include <WindowsConstants.au3>
#include <GUIConstants.au3>
#include <GuiMenu.au3>
#include <SQLite.au3>
#include "_WV2_ExtensionPicker.au3"

; VERSION: 1.4.0

OnAutoItExitRegister("_ExitApp")

; Global objects for COM
Global $oWeb, $oJS
Global $oMyError = ObjEvent("AutoIt.Error", "_ErrFunc") ; Will be called if COM error occurs
Global $hGUI, $Bar
Global $g_sProfilePath = @ScriptDir & "\UserDataFolder"
Global $g_bURLFullSelected = 0
Global $g_bHighlight = 0
Global $g_iScreenshotStep = 0 ; 0=Idle, 1=Waiting Metrics, 2=Waiting SetMetrics, 3=Waiting Capture
Global $g_sSavePath = ""

_MainGUI()

;---------------------------------------------------------------------------------------
Func _MainGUI() ; Create the Main GUI

	; 1. Create the Main GUI
	$hGUI = GUICreate("WebView2 v1.4.0 - Starter Template", 1000, 800, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPCHILDREN))
	ConsoleWrite("$hGUI=" & $hGUI & @CRLF)
	GUISetBkColor(0x1E1E1E, $hGUI)

	GUIRegisterMsg($WM_SIZE, "WM_SIZE")       ; Register the WM_SIZE message to handle window resizing
	GUIRegisterMsg($WM_COMMAND, "WM_COMMAND") ; Register the WM_COMMAND message to handle URL FullSelection

	; 2. Initialize the COM Objects
	_Web_ObjectsInit($g_sProfilePath)

	SetupWebView2Features($oWeb)

	; Set the starting URL
	Local $sURL = "https://www.google.com" ; "http://localhost"

	GUICtrlSetData($Bar.Address, $sURL)

	; 3. Navigate to the starting URL
	$oWeb.Navigate($sURL)


	; 4. Main Application Loop
	GUISetState(@SW_SHOW, $hGUI)

	Local $iMsg

	While 1
		$iMsg = GUIGetMsg()
		Switch $iMsg
			Case $GUI_EVENT_CLOSE
				Exit
			Case $Bar.Address
				_Web_GoTo(GUICtrlRead($Bar.Address))

			Case $Bar.ClearBrowserData
				If MsgBox(36, "Confirm", "Do you want to clear your browsing data?") = 6 Then
					If IsObj($oWeb) Then $oWeb.ClearBrowserData()
				EndIf
			Case $Bar.GoBack
				If IsObj($oWeb) Then $oWeb.GoBack()
			Case $Bar.Reload
				If IsObj($oWeb) Then $oWeb.Reload()
			Case $Bar.GoForward
				If IsObj($oWeb) Then $oWeb.GoForward()
			Case $Bar.Stop
				If IsObj($oWeb) Then $oWeb.Stop()
			Case $Bar.GlobalNavButton
				MouseClick("right")
				; === $Bar.ctx_ : ContexMenu ===
			Case $Bar.ctx_Google
				If IsObj($oWeb) Then $oWeb.Navigate("https://www.google.com")
			Case $Bar.ctx_AutoIt
				If IsObj($oWeb) Then $oWeb.Navigate("https://www.autoitscript.com/forum")
			Case $Bar.ctx_wikipedia
				If IsObj($oWeb) Then $oWeb.Navigate("https://en.wikipedia.org/wiki/List_of_countries_and_dependencies_by_population")
			Case $Bar.ctx_demoqa
				If IsObj($oWeb) Then $oWeb.Navigate("https://demoqa.com/text-box")
			Case $Bar.ctx_microsoft
				If IsObj($oWeb) Then $oWeb.Navigate("https://learn.microsoft.com/en-us/dotnet/api/microsoft.web.webview2.core.corewebview2profile.addbrowserextensionasync?view=webview2-dotnet-1.0.3595.46	")

			Case $Bar.ctx_Show_All_Tables
				If IsObj($oWeb) Then $oWeb.ExecuteScript("scanTables();")

			Case $Bar.ctx_EnableCustomMenu
				ConsoleWrite("> Switching to Custom Menu (AutoIt Mode)" & @CRLF)
				$oWeb.SetContextMenuEnabled(False)
			Case $Bar.ctx_EnableNativeMenu
				ConsoleWrite("> Switching to Native Menu (Edge Mode)" & @CRLF)
				$oWeb.SetContextMenuEnabled(True)

			Case $Bar.ctx_Ghostery
				If IsObj($oWeb) Then $oWeb.Navigate("extension://mlomiejdfkolichcflejclcbmpeaniij/pages/panel/index.html")
			Case $Bar.ctx_DarkReader
				If IsObj($oWeb) Then $oWeb.Navigate("extension://eimadpbcbfnmbkopoojfekhnkhdbieeh/ui/popup/index.html")
			Case $Bar.ctx_Extensions_Manager
				_WV2_ShowExtensionPicker(500, 600, $hGUI, @ScriptDir & "\Extensions_Lib", $g_sProfilePath)

			Case $Bar.ctx_Highlights
				$g_bHighlight = Not $g_bHighlight ; Status reversal (True/False)
				$oWeb.ToggleAuditHighlights($g_bHighlight)
				; GUICtrlSetFont($Bar.ctx_Highlights, 10, ($g_bHighlight ? 700 : 400), 0, "Segoe Fluent Icons")
				_Web_Notify("Highlights " & $g_bHighlight, ($g_bHighlight ? "#FF6A00" : "#2196F3"))

			Case $Bar.Download_All
;~ 				$oWeb.ExecuteScript("scanForFiles('.zip');")
				$oWeb.ExecuteScript("scanForFiles('.jpg');")

		EndSwitch

		If $g_bURLFullSelected Then
			$g_bURLFullSelected = False
			GUICtrlSendMsg($Bar.Address, $EM_SETSEL, 0, -1)
		EndIf

	WEnd
EndFunc   ;==>_MainGUI
;---------------------------------------------------------------------------------------
Func _ExitApp() ; OnAutoItExitRegister
	; ⚠️ IMPORTANT: Cleanup must be called to release file locks on the Profile Folder
	; and to terminate msedgewebview2.exe processes.
	If IsObj($oWeb) Then $oWeb.Cleanup()

	$oWeb = 0
	$oJS = 0
	Exit
EndFunc   ;==>_ExitApp
;---------------------------------------------------------------------------------------
Func _Web_GoTo($sURL) ; Navigates to a URL or performs a Google search if the input is not a URL.
	$sURL = StringStripWS($sURL, 3)
	If $sURL = "" Then Return False

	; 1. Check if it already has a protocol (http://, https://, file://, etc.)
	Local $bHasProtocol = StringRegExp($sURL, '(?i)^[a-z]+://', 0)

	; 2. Check if it looks like a domain (e.g., test.com, autoitscript.com)
	Local $bIsURL = StringRegExp($sURL, '(?i)^([a-z0-9\-]+\.)+[a-z]{2,}', 0)

	Local $sFinalURL = ""

	If $bHasProtocol Then
		$sFinalURL = $sURL
	ElseIf $bIsURL Then
		; Prepend https for domains without protocol
		$sFinalURL = "https://" & $sURL
	Else
		; It's a search query. Use the new EncodeURI for perfect character handling
		Local $sEncodedQuery = $sURL
		If IsObj($oWeb) Then
			$sEncodedQuery = $oWeb.EncodeURI($sURL)
		Else
			; Fallback if object is not ready (basic replace)
			$sEncodedQuery = StringReplace($sURL, " ", "+")
		EndIf
		$sFinalURL = "https://www.google.com/search?q=" & $sEncodedQuery
	EndIf

	; --- Execution ---
	ConsoleWrite("-> Web_GoTo: " & $sFinalURL & @CRLF)

	If IsObj($oWeb) Then
		$oWeb.Navigate($sFinalURL)
		Return True
	EndIf

	Return False
EndFunc   ;==>_Web_GoTo
;---------------------------------------------------------------------------------------
Func _Web_ObjectsInit($sProfilePath = @ScriptDir & "\UserDataFolder") ; Create the Manager Instance
	; A. Create the Manager Instance
	$oWeb = ObjCreate("NetWebView2.Manager")
	If Not IsObj($oWeb) Then Return MsgBox(16, "Error", "WebView2 DLL not registered!")

	; B. Register Manager Events (Navigation, Status, Core Messages)
	ObjEvent($oWeb, "WebEvents_", "IWebViewEvents")

	; C. Setup the JavaScript Bridge (Communication from JS to AutoIt)
	$oJS = $oWeb.GetBridge()
	ObjEvent($oJS, "JavaScript_", "IBridgeEvents")

	; D. Initialize the browser engine

	; Browser Data Directory (Cache, Cookies, Session).
	; Ensures that settings and logins persist after closing the application.
	; - If left blank "", the folder will be automatically created next to the executable.
	; - ⚠️ WARNING: If you are running the script from Scite (C:\Program Files (x86)\AutoIt3),
	; make sure you have write permissions to the folder, otherwise set a path
	; to another location (e.g. @AppDataDir & "\MyApp").
	; Local $sProfilePath = @ScriptDir & "\UserDataFolder"

	; ⚠️ IMPORTANT: Enclose ($hGUI) in parentheses to force "Pass-by-Value" (COM requirement).
	; Parameters: (hWnd, profilePath, x, y, width, height)
	; $oWeb.Initialize(($hGUI), $sProfilePath, 0, 0, 1000, 800)
	$oWeb.Initialize(($hGUI), $sProfilePath, 0, 25, 1000, 775)


	; Make a Basic ToolBar for Browsing navigation
	Local $sExtra = "Google, AutoIt, wikipedia, demoqa, microsoft, -,Show_All_Tables, Download_All, -, " & _
			"Highlights, EnableCustomMenu, EnableNativeMenu, ClearBrowserData, -, Ghostery, DarkReader"
	$Bar = _Web_MakeBar($hGUI, $sExtra, 1)


	If Not FileExists($sProfilePath & "\EBWebView\initialized") Then
		; E. show Welcome page Wait for the engine to be ready before navigating
		Local $sWelcomeHTML = _
				'<html><title>Welcome</title><head><style>' & _
				'body { background-color: #1E1E1E; color: white; font-family: "Segoe UI", sans-serif; display: flex; flex-direction: column; justify-content: center; align-items: center; height: 100vh; margin: 0; }' & _
				'.loader { border: 4px solid #333; border-top: 4px solid #2196F3; border-radius: 50%; width: 40px; height: 40px; animation: spin 1s linear infinite; margin-bottom: 20px; }' & _
				'@keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }' & _
				'h2 { font-weight: 300; letter-spacing: 1px; }' & _
				'</style></head><body>' & _
				'<div class="loader"></div>' & _
				'<h2>Initializing WebView2 Engine</h2>' & _
				'<p style="color: #888;">Setting up your profile folder...</p>' & _
				'</body></html>'

		$oWeb.NavigateToString($sWelcomeHTML)
		FileWrite($sProfilePath & "\EBWebView\initialized", "NetWebView2.Manager initialized")
	EndIf

	; E. Wait for the engine to be ready before navigating
	Do
		Sleep(50)
	Until $oWeb.IsReady

	ConsoleWrite("WebView2 is Ready for Navigating..." & @CRLF)
EndFunc   ;==>_Web_ObjectsInit
;---------------------------------------------------------------------------------------
Func _Web_MakeBar($hGUI, $ctx_list = "", $bAddress = 1) ; Make a Basic ToolBar for Browsing navigation
	; Defining the main buttons with the Fluent Icons
	Local $Btn[][] = [[59136, "GlobalNavButton"] _
			, [59213, "ClearBrowserData"] _
			, [59179, "GoBack"] _
			, [59153, "Stop"] _
			, [59178, "GoForward"] _
			, [59180, "Reload"]]

	Local $iX = 0, $iY = 0, $iH = 25, $iW = 25, $iCnt = UBound($Btn)
	Local $m[] ; Map object to return IDs

	; Creating the Buttons
	For $i = 0 To $iCnt - 1
		$m[$Btn[$i][1]] = GUICtrlCreateButton(ChrW($Btn[$i][0]), $iX, $iY, $iW, $iH)
		GUICtrlSetFont(-1, 12, 400, 0, "Segoe Fluent Icons")
		GUICtrlSetTip(-1, $Btn[$i][1])
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

	; Creating the Context Menu (adding to GlobalNavButton)
	$m.ctx = GUICtrlCreateContextMenu($m.GlobalNavButton)

	; List combination: Extra items + Separator + Basic items
	Local $sFinalList = $ctx_list
	If $sFinalList <> "" Then $sFinalList &= ",-,"
	$sFinalList &= "Extensions Manager, About"

	Local $aItems = StringSplit($sFinalList, ",")
	Local $sName
	For $i = 1 To $aItems[0]
		$sName = StringReplace(StringStripWS($aItems[$i], 3), " ", "_")
		If $sName = "-" Then
			GUICtrlCreateMenuItem("", $m.ctx)  ; Create a separator line
		Else
			$m["ctx_" & $sName] = GUICtrlCreateMenuItem($sName, $m.ctx)
		EndIf
	Next

	Return $m
EndFunc   ;==>_Web_MakeBar
;---------------------------------------------------------------------------------------
Func WM_SIZE($hWnd, $iMsg, $wParam, $lParam) ; Synchronizes WebView size with the GUI window
	#forceref $hWnd, $iMsg, $wParam
	If $hWnd <> $hGUI Then Return $GUI_RUNDEFMSG ; critical, to respond only to the $hGUI
	If $wParam = 1 Then Return $GUI_RUNDEFMSG
	Local $iW = BitAND($lParam, 0xFFFF), $iH = BitShift($lParam, 16) - 25 ; 25 = ToolBar
	If IsObj($oWeb) Then $oWeb.Resize(($iW < 10 ? 10 : $iW), ($iH < 10 ? 10 : $iH))
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_SIZE
;---------------------------------------------------------------------------------------
Func WM_COMMAND($hWnd, $iMsg, $wParam, $lParam) ; Register the WM_COMMAND message to handle URL FullSelection
	#forceref $hWnd, $iMsg
	Local Static $hidURL = GUICtrlGetHandle($Bar.Address)
	Local $iCode = BitShift($wParam, 16)
	Switch $lParam
		Case $hidURL
			Switch $iCode
				Case $EN_SETFOCUS
					$g_bURLFullSelected = True
					;Case $EN_CHANGE
			EndSwitch
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_COMMAND
;---------------------------------------------------------------------------------------
Func SetupWebView2Features(ByRef $oWebView)
	; 1. Appearance Setting
	$oWebView.BackColor = "0x2B2B2B" ; Dark Background (Dark Mode)
	$oWebView.BorderStyle = 1 ; FixedSingle frame

	; 2. Permissions & Security Control
	$oWebView.AreDevToolsEnabled = True ; Enable F12 for debugging
	$oWebView.AreDefaultContextMenusEnabled = False ; Disable Edge's right-click
	$oWebView.AreBrowserAcceleratorKeysEnabled = False ; Disable Ctrl+P, F5 etc.

	; 3. Zoom Setting
	$oWebView.ZoomFactor = 1.25 ; Set the zoom to 125%

	; 4. Focus
	$oWebView.WebViewSetFocus() ; Automatically focus the browser
EndFunc   ;==>SetupWebView2Features
;---------------------------------------------------------------------------------------
Func SetBridgeTheme($bEnabled = True, $iColor = 0xFFD800, $iSize = 4, $nOpacity = 0.7, $iDuration = 1200)
	Local $iR = BitAND(BitShift($iColor, 16), 0xFF)
	Local $iG = BitAND(BitShift($iColor, 8), 0xFF)
	Local $iB = BitAND($iColor, 0xFF)

	; Format: rgba(R, G, B, A) ; We use %f for Opacity (float)
	Local $sJson = StringFormat('{"enabled": %s, "color": "rgba(%i, %i, %i, %.2f)", "thickness": "%ipx", "duration": %i}', _
			StringLower($bEnabled), $iR, $iG, $iB, $nOpacity, $iSize, $iDuration)

	ConsoleWrite("-> [Bridge Config]: " & $sJson & @CRLF)
	$oWeb.ExecuteScript("setBridgeConfig('" & $sJson & "');")
EndFunc   ;==>SetBridgeTheme
;---------------------------------------------------------------------------------------
Func _Web_Notify($sMessage, $sType = "success", $iDuration = 3000) ; notification toast in the browser
	Local $sCleanMsg = StringReplace($sMessage, "'", "\'") ; We clean the message from single quotes and line breaks
	$sCleanMsg = StringRegExpReplace($sCleanMsg, "[\r\n]+", " ") ; [\r\n]+ matches all line break combinations (CR, LF, CRLF)
	Local $sCall = StringFormat("showNotification('%s', '%s', %i);", $sCleanMsg, $sType, $iDuration)
	$oWeb.ExecuteScript($sCall)
EndFunc   ;==>_Web_Notify
;---------------------------------------------------------------------------------------

; --- EVENT HANDLERS  ---

;---------------------------------------------------------------------------------------
Func JavaScript_OnMessageReceived($sMessage) ; Listen for Events (JavaScript Bridge)
	ConsoleWrite("+> [JavaScript]: " & $sMessage & @CRLF)

	; Check if the message is a JSON object or array
	Local $sFirstChar = StringLeft($sMessage, 1)

	If $sFirstChar = "{" Or $sFirstChar = "[" Then
		ConsoleWrite("+> : Processing JSON message..." & @CRLF)

		; 1. Initialize JSON Parser
		Local $oJson = ObjCreate("NetJson.Parser")
		If Not IsObj($oJson) Then Return ConsoleWrite("!> Error: Failed to create NetJson object." & @CRLF)

		$oJson.Parse($sMessage)

		; 2. Identify the Job Type
		Local $sJobType = $oJson.GetTokenValue("type")
		Local $sResult, $iCount, $sExt, $sURL, $sFileName

		Switch $sJobType
			Case "COM_TEST"
				$sResult = $oJson.GetTokenValue("status")
				ConsoleWrite("-  COM_TEST Confirmed status: " & $sResult & @CRLF)

			Case "TABLE_LIST2"
				ConsoleWrite("-  Table list received (v2): " & $sMessage & @CRLF)
				$sResult = $oJson.GetTokenValue("data")
				ConsoleWrite("-  Data: " & $sResult & @CRLF)

			Case "TABLE_DATA"
				; Extract rows from the main JSON message
				Local $sRowsJson = $oJson.GetTokenValue("rows")
				Local $oRows = ObjCreate("NetJson.Parser")
				$oRows.Parse($sRowsJson)

				; Determine array dimensions
				Local $iTotalRows = $oRows.GetArrayLength("")
				Local $iTotalCols = $oRows.GetArrayLength("[0]")

				; Initialize AutoIt 2D Array
				Local $aTableData[$iTotalRows][$iTotalCols]
				ConsoleWrite("-  Transferring to AutoIt Array: " & $iTotalRows & "x" & $iTotalCols & @CRLF)

				; Populate array from JSON data
				For $r = 0 To $iTotalRows - 1
					For $c = 0 To $iTotalCols - 1
						$aTableData[$r][$c] = $oRows.GetTokenValue("[" & $r & "][" & $c & "]")
					Next
				Next

				; Trigger CSV Export
				_TableExportAsCSV($aTableData)

			Case "TABLE_LIST"
				$iCount = $oJson.GetArrayLength("data")
				If $iCount = 0 Then
					_Web_Notify("No tables found on this page.", "info")
					Return
				EndIf

				Local $sDisplayList = "Detected " & $iCount & " tables. Select Index:" & @CRLF & @CRLF
				For $i = 0 To $iCount - 1
					Local $sID = $oJson.GetTokenValue("data[" & $i & "].id")
					Local $iRows = $oJson.GetTokenValue("data[" & $i & "].rowCount")
					Local $iCols = $oJson.GetTokenValue("data[" & $i & "].colCount")
					If $sID = "" Or $sID = "no-id" Then $sID = "(No ID)"

					$sDisplayList &= StringFormat("[%d] Rows: %d, Cols: %d | ID: %s\n", $i, $iRows, $iCols, $sID)
				Next

				Local $iSelection = InputBox("Table Selector", $sDisplayList, "0", "", 450, 400, Default, Default, 0, $hGUI)
				If Not @error Then
					; Highlight table before export for confirmation
					$oWeb.ExecuteScript("highlightElement(document.querySelectorAll('table')[" & $iSelection & "]);")
					$oWeb.ExecuteScript("getTableDataByIndex(" & $iSelection & ");")
				EndIf

			Case "FORM_MAP"
				; Handle the mapped form data
				Local $sFormData = $oJson.GetTokenValue("data")
				ConsoleWrite("-  Form Mapping Received: " & $sFormData & @CRLF)

				; Sanitize document title for filename compatibility
				Local $sTitle = "Untitled_Page"
				If IsObj($oWeb) Then $sTitle = $oWeb.GetDocumentTitle()
				$sTitle = StringRegExpReplace($sTitle, '[\\/:*?"<>|]', "_")

				; Save JSON mapping to file (UTF-8 with BOM)
				Local $sFilePath = @ScriptDir & "\" & $sTitle & "_form_mapping.json"
				Local $hFile = FileOpen($sFilePath, 128 + 2)

				If $hFile <> -1 Then
					FileWrite($hFile, $sFormData)
					FileClose($hFile)
					MsgBox(64, "Success", "Form structure saved to: " & @CRLF & $sFilePath)
				Else
					ConsoleWrite("!   Error: Could not save form mapping file." & @CRLF)
				EndIf

			Case "FILE_LIST"
				$iCount = $oJson.GetArrayLength("links")
				$sExt = $oJson.GetTokenValue("extension")

				If $iCount = 0 Then
					_Web_Notify("No " & $sExt & " files found.", "warning")
					Return
				EndIf

				If MsgBox(36, "Bulk Download", "Found " & $iCount & " files (" & $sExt & "). Download them all?") = 6 Then
					Local $sDestDir = FileSelectFolder("Select Download Folder", @ScriptDir)
					If @error Then Return

					For $i = 0 To $iCount - 1
						$sURL = $oJson.GetTokenValue("links[" & $i & "]")

						; Δημιουργία ονόματος αρχείου από το URL
						Local $aName = StringSplit($sURL, "/")
						$sFileName = $aName[$aName[0]]

						_Web_Notify("Downloading: " & $sFileName, "info", 1000)

						; Κατέβασμα αρχείου (Background mode)
						InetGet($sURL, $sDestDir & "\" & $sFileName, 1, 1)
					Next

					MsgBox(64, "Done", "Bulk download started in background!")
				EndIf


			Case "BULK_DOWNLOAD"
				Local $oParser = ObjCreate("NetJson.Parser")
				$oParser.Parse($sMessage)

				$iCount = $oParser.GetArrayLength("links")
				$sExt = $oParser.GetTokenValue("extension")

				If $iCount = 0 Then
					_Web_Notify("No " & $sExt & " files found!", "info")
					Return
				EndIf

				Local $sFolder = FileSelectFolder("Select storage folder", "")
				If @error Then Return

				For $i = 0 To $iCount - 1
					$sURL = $oParser.GetTokenValue("links[" & $i & "]")

					; Use EncodeB64/DecodeB64 if URL has strange characters
					$sFileName = "??" ; _ExtractFileName($sURL)

					_Web_Notify("Downloading " & ($i + 1) & "/" & $iCount, "info")

					; InetGet(URL, Path, 1 [Background], 1 [Force Reload])
					InetGet($sURL, $sFolder & "\" & $sFileName, 1, 1)
				Next
				_Web_Notify("Download started!", "success")

		EndSwitch

	Else ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		; 3. Handle Legacy Pipe-Delimited Messaging
		ConsoleWrite("+> : Processing Legacy message..." & @CRLF)

		Local $aParts = StringSplit($sMessage, "|")
		If $aParts[0] > 0 Then
			Local $sCommand = StringStripWS($aParts[1], 3)
			Switch $sCommand
				Case "COM_TEST"
					If $aParts[0] > 1 Then ConsoleWrite("-  Status: Legacy COM_TEST: " & $aParts[2] & @CRLF)
				Case "ERROR"
					ConsoleWrite("! Status: " & $sMessage & @CRLF)
			EndSwitch
		EndIf
	EndIf
EndFunc   ;==>JavaScript_OnMessageReceived
;---------------------------------------------------------------------------------------
Func WebEvents_OnMessageReceived($sMessage) ; Listen for Events (WebView2 Manager)
	ConsoleWrite("+> [WEBEVENTS]: " & $sMessage & @CRLF)

	; Separating messages that have parameters (e.g. TITLE_CHANGED|...)
	Local $aParts = StringSplit($sMessage, "|")
	Local $sCommand = StringStripWS($aParts[1], 3)

	Switch $sCommand
		Case "INIT_READY"
			; COM_TEST
			; $oWeb.ExecuteScript('window.chrome.webview.postMessage(JSON.stringify({ "type": "COM_TEST", "status": "OK" }));')
			$oWeb.ExecuteScript('window.chrome.webview.postMessage("COM_TEST|hello world from JavaScript");') ; LEGACY PROCESSING
			ConsoleWrite("-  Switching to Custom Menu (AutoIt Mode)" & @CRLF)
			$oWeb.SetContextMenuEnabled(False)

			; Inject external JavaScript Lib file to the memory
			Local $sBridge = FileRead(@ScriptDir & "\_Bridge.js")
			$oWeb.AddInitializationScript($sBridge)
			ConsoleWrite("-  _Bridge.js script registered." & @CRLF)

		Case "NAV_STARTING"
			$oWeb.ExecuteScript("startProgress(20);") ; Page Progress indicator

		Case "NAV_COMPLETED"
			; also available as WebEvents_OnNavigationCompleted()
			$oWeb.ExecuteScript("finalizeProgress();")

		Case "URL_CHANGED"
			If $aParts[0] > 1 Then
				GUICtrlSetData($Bar.Address, $aParts[2])
				GUICtrlSendMsg($Bar.Address, $EM_SETSEL, 0, 0)
				$oWeb.WebViewSetFocus() ; We give focus to the browser
			EndIf

		Case "TITLE_CHANGED"
			If $aParts[0] > 1 Then
				WinSetTitle($hGUI, "", "WebView2 v1.4.0 - " & $aParts[2])
				ConsoleWrite(">> " & $aParts[2] & @CRLF)
			EndIf

		Case "CDP_RESULT"
;~ 			Local $sMethod = $aParts[2]
			Local $sData = $aParts[3]
			Local $oParser = ObjCreate("NetJson.Parser")

			; If the result contains an error field (common in CDP when something fails)
			If StringInStr($sData, '"error":') Then
				_Web_Notify("CDP Error detected. Resetting state.", "error")
				$g_iScreenshotStep = 0
				Return
			EndIf

			Switch $g_iScreenshotStep
				Case 1 ; Received Metrics, now set Device Override
					$oParser.Parse($sData)
					Local $iW = $oParser.GetTokenValue("contentSize.width")
					Local $iH = $oParser.GetTokenValue("contentSize.height")

					$g_iScreenshotStep = 2 ; Next state
					Local $sParams = StringFormat('{"width":%d, "height":%d, "deviceScaleFactor":1, "mobile":false}', $iW, $iH)
					$oWeb.CallDevToolsProtocolMethod("Emulation.setDeviceMetricsOverride", $sParams)

				Case 2 ; Metrics applied, now take the actual Screenshot
					$g_iScreenshotStep = 3 ; Next state
					Sleep(500) ; Give the browser half a second to render the full height
					Local $sCapParams = '{"format": "png", "fromSurface": true}'
					$oWeb.CallDevToolsProtocolMethod("Page.captureScreenshot", $sCapParams)

				Case 3 ; Received Screenshot Data
					; 1. WARNING: $sData contains {"data":"iVBOR..."}.
					; We need to get ONLY what is between "data":" and "
					Local $aMatch = StringRegExp($sData, '"data":"([^"]+)"', 1)

					If Not @error Then
						Local $sCleanBase64 = $aMatch[0]
						_WinAPI_Base64Decode($sCleanBase64, $g_sSavePath)
						Local $iSize = FileGetSize($g_sSavePath)
						ConsoleWrite("-  Final Screenshot File Size: " & $iSize & " bytes" & @CRLF)

						If $iSize > 1000 Then
							_Web_Notify("Full Page Captured!", "success")
							ShellExecute($g_sSavePath) ; Optional: open the photo immediately
						Else
							_Web_Notify("File is too small. Check Layout Metrics.", "error")
						EndIf
					Else
						ConsoleWrite("!  Error: Could not find 'data' property in JSON." & @CRLF)
					EndIf

					; 3. Cleanup
					$oWeb.CallDevToolsProtocolMethod("Emulation.clearDeviceMetricsOverride", "{}")
					$g_iScreenshotStep = 0
			EndSwitch

		Case "ERROR", "NAV_ERROR"
			ConsoleWrite("!   Status: Error " & ($aParts[0] > 1) ? $aParts[2] : "Unknown" & @CRLF)

	EndSwitch

EndFunc   ;==>WebEvents_OnMessageReceived
;---------------------------------------------------------------------------------------
Func WebEvents_OnContextMenu($sJsonData) ; Listen for Events of the context menu
	ConsoleWrite("+> [OnContextMenu]: " & $sJsonData & @CRLF)
	; 1. Validation
	If $sJsonData = "" Then Return False

	; Clean the JSON prefix safely
	Local $sCleanJson = StringReplace($sJsonData, "JSON:", "", 1)

	; 2. Parsing
	Local $oJson = ObjCreate("NetJson.Parser")
	If Not IsObj($oJson) Then Return SetError(1, 0, False)

	$oJson.Parse($sCleanJson)
	; e.g. JSON:{"x":493,"y":478,"kind":"SelectedText","tagName":"DIV","src":"","link":"","selection":"Google "}
	Local $iX_JS = $oJson.GetTokenValue("x")
	Local $iY_JS = $oJson.GetTokenValue("y")
	Local $sKind = $oJson.GetTokenValue("kind")
	Local $sTagName = $oJson.GetTokenValue("tagName")
	Local $sImgUrl = $oJson.GetTokenValue("src")
	Local $sSelection = $oJson.GetTokenValue("selection")

	; 3. Menu Creation (Lightweight)
	Local $hMenu = _GUICtrlMenu_CreatePopup()

	; We only add what is necessary for the current context
	Switch $sKind
		Case "SelectedText"
			_GUICtrlMenu_AddMenuItem($hMenu, "Copy Selection", 1001)
			_GUICtrlMenu_AddMenuItem($hMenu, "🔍 Search Google for: '" & StringLeft($sSelection, 15) & "...'", 1002)
		Case "Image"
			_GUICtrlMenu_AddMenuItem($hMenu, "💾 Save Image As...", 1003)
			_GUICtrlMenu_AddMenuItem($hMenu, "Copy Image URL", 1005)
		Case Else
			; _GUICtrlMenu_AddMenuItem($hMenu, "Reload Page", 1004)
	EndSwitch

	; Dynamic menu example
	Switch $sTagName
		Case "TABLE"
			_GUICtrlMenu_AddMenuItem($hMenu, "") ; separator
			_GUICtrlMenu_AddMenuItem($hMenu, "📥 Table Export", 1006)
		Case "INPUT", "FORM", "TEXTAREA"
			_GUICtrlMenu_AddMenuItem($hMenu, "") ; separator
			_GUICtrlMenu_AddMenuItem($hMenu, "📋 Map Form to JSON", 1007)
			_GUICtrlMenu_AddMenuItem($hMenu, "📥 Fill Form from JSON", 1008)
	EndSwitch

	_GUICtrlMenu_AddMenuItem($hMenu, "") ; separator
	_GUICtrlMenu_AddMenuItem($hMenu, "Reload Page", 1004)
	_GUICtrlMenu_AddMenuItem($hMenu, "Full Page Screenshot", 1009)

	; 4. Execution
	Local $tPoint = _WinAPI_GetMousePos()
	; Note: Using $hGUI as the parent for the menu to ensure it blocks appropriately
	Local $iCmd = _GUICtrlMenu_TrackPopupMenu($hMenu, $hGUI, DllStructGetData($tPoint, "X"), DllStructGetData($tPoint, "Y"), 1, 1, 2)
	Local $sSavePath
	Switch $iCmd
		Case 1001 ; Copy
			ClipPut($sSelection)

		Case 1002 ; Google Search
			; Using new built-in .EncodeURI method!
			_Web_GoTo("https://www.google.com/search?q=" & $oWeb.EncodeURI($sSelection))

		Case 1003 ; Save Image
			$sSavePath = FileSaveDialog("Save Image", @DesktopDir, "Images (*.jpg;*.png;*.gif;*.webp)", 18)
			If Not @error Then InetGet($sImgUrl, $sSavePath)

		Case 1004 ; Reload
			$oWeb.Reload()

		Case 1005 ; Copy URL
			ClipPut($sImgUrl)

		Case 1006 ; Table Export
			; Now you just call the function that already exists in bridge.js
			$oWeb.ExecuteScript("extractTableFromPoint(" & $iX_JS & ", " & $iY_JS & ");")

		Case 1007 ; Map Form
			; Just call the function name. No more building large strings in AutoIt!
			$oWeb.ExecuteScript("mapForm();")

		Case 1008 ; Fill Form from JSON
			SetBridgeTheme(True, 0xFFD800, 3, 0.7, 2000)
			$sSavePath = FileOpenDialog("Select Mapping File", @ScriptDir, "JSON Files (*.json)")
			If Not @error Then
				Local $sJsonFromFile = FileRead($sSavePath)

				; Now we just call the function that already exists in bridge.js
				; We pass the JSON as a string, only doing StringReplace for safety
				Local $sCall = "fillForm('" & StringReplace($sJsonFromFile, "'", "\'") & "');"
				$oWeb.ExecuteScript($sCall)
			EndIf

		Case 1009 ; Full Page Screenshot
			Local $sTitle = "Untitled_Page"
			If IsObj($oWeb) Then $sTitle = $oWeb.GetDocumentTitle()
			$sTitle = StringRegExpReplace($sTitle, '[\\/:*?"<>|]', "_")
			$sSavePath = @ScriptDir & "\" & $sTitle & "_Screenshot.png"
			_StartCaptureProcess($sSavePath)

	EndSwitch

	; 5. Cleanup (Crucial for memory)
	_GUICtrlMenu_DestroyMenu($hMenu)
	Return True
EndFunc   ;==>WebEvents_OnContextMenu

; --- EXTRA TOOLS  ---

Func _WinAPI_Base64Decode($sB64String, $FilePath = -1)
	Local $aCrypt = DllCall("Crypt32.dll", "bool", "CryptStringToBinaryA", "str", $sB64String, "dword", 0, "dword", 1, "ptr", 0, "dword*", 0, "ptr", 0, "ptr", 0)
	If @error Or Not $aCrypt[0] Then Return SetError(1, 0, "")
	Local $bBuffer = DllStructCreate("byte[" & $aCrypt[5] & "]")
	$aCrypt = DllCall("Crypt32.dll", "bool", "CryptStringToBinaryA", "str", $sB64String, "dword", 0, "dword", 1, "struct*", $bBuffer, "dword*", $aCrypt[5], "ptr", 0, "ptr", 0)
	If @error Or Not $aCrypt[0] Then Return SetError(2, 0, "")
	Local $bString = Binary(DllStructGetData($bBuffer, 1))
	If $FilePath <> -1 Then
		Local Const $hFile = FileOpen($FilePath, 18)
		If @error Then Return SetError(2, 0, $bString)
		FileWrite($hFile, $bString)
		FileClose($hFile)
	EndIf
	Return $bString
EndFunc   ;==>_WinAPI_Base64Decode

Func _StartCaptureProcess($sFilePath)
	$g_sSavePath = $sFilePath
	$g_iScreenshotStep = 1 ; Set state: Waiting for Metrics
	$oWeb.CallDevToolsProtocolMethod("Page.getLayoutMetrics", "{}")
EndFunc   ;==>_StartCaptureProcess

; ===============================================================================================================================
; Function Name:    _TableExportAsCSV
; Description:      Converts a 2D array to a CSV file and opens it.
;                   Handles strange characters using UTF-8 with BOM and sanitizes data for Excel compatibility.
; Parameters:       $aArray     - The 2D array containing the table data
;                   $sDelim_Col - The column delimiter (default is ";" which is standard for Excel settings)
; ===============================================================================================================================
Func _TableExportAsCSV(ByRef $aArray, $sDelim_Col = ";")
	; 1. Validation: Check if the input is a valid 2D array
	If Not IsArray($aArray) Or UBound($aArray, 0) <> 2 Then
		Return MsgBox(48, "Error", "The provided data is not a valid 2D array.", 3)
	EndIf

	Local $iRows = UBound($aArray, 1)
	Local $iCols = UBound($aArray, 2)
	Local $sCSVContent = ""

	; 2. Build the CSV string manually for better control
	For $i = 0 To $iRows - 1
		Local $sRowString = ""
		For $j = 0 To $iCols - 1
			Local $sCellData = $aArray[$i][$j]

			; Clean up: Remove line breaks inside cells to keep the CSV structure intact
			$sCellData = StringRegExpReplace($sCellData, '\R', ' ')

			; Wrap data in double quotes to handle cases where the cell contains the delimiter itself
			; We also escape existing double quotes by doubling them (Standard CSV rule)
			$sCellData = StringReplace($sCellData, '"', '""')
			$sRowString &= '"' & $sCellData & '"'

			; Add delimiter if it's not the last column
			If $j < $iCols - 1 Then $sRowString &= $sDelim_Col
		Next
		; Add a newline at the end of each row
		$sCSVContent &= $sRowString & @CRLF
	Next

	; 3. Prepare the Filename
	; Get document title and remove illegal filename characters like \ / : * ? " < > |
	Local $sTitle = "Export"
	If IsObj($oWeb) Then $sTitle = $oWeb.GetDocumentTitle()
	$sTitle = StringRegExpReplace($sTitle, '[\\/:*?"<>|]', "_")

	Local $sFileName = $sTitle & "_" & @HOUR & @MIN & @SEC & ".csv"
	Local $sFullCSVPath = @ScriptDir & "\" & $sFileName

	; 4. Write to File with UTF-8 BOM (Flag 128)
	; Flag 128 = UTF8 with BOM (Crucial for Excel to recognize Greek characters immediately)
	; Flag 2   = Overwrite mode
	Local $hFile = FileOpen($sFullCSVPath, 128 + 2)

	If $hFile = -1 Then
		ConsoleWrite("!> Error: Could not open file for writing: " & $sFullCSVPath & @CRLF)
		Return False
	EndIf

	FileWrite($hFile, $sCSVContent)
	FileClose($hFile)

	; 5. Finalize
	ConsoleWrite("+> Table successfully exported to: " & $sFullCSVPath & @CRLF)

	; Open the generated file with the default CSV viewer (usually Excel)
	ShellExecute($sFullCSVPath)

	Return True
EndFunc   ;==>_TableExportAsCSV
;---------------------------------------------------------------------------------------
