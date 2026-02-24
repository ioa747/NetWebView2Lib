;----------------------------------------------------------------------------------------
; USAGE INSTRUCTIONS:
; 1. In the Right Browser (Web2) Use your mouse to select (highlight) any text or keyword on the Right Browser.
; 2. A floating button "🔍 Search Google" will appear near your selection.
; 3. Click the button to automatically perform a Google Search on the Left Browser (Web1).
; 4. The search is automatically restricted to the current domain (site:domain.com).
;----------------------------------------------------------------------------------------
#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7
#AutoIt3Wrapper_UseX64=y
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <StaticConstants.au3>
#include <EditConstants.au3>
#include "..\NetWebView2Lib.au3"
#include "_WV2_ExtensionPicker.au3"

; 011-TwinWebView.au3

OnAutoItExitRegister(_ExitApp)

; Global Objects & Handles
Global $oWeb1, $oWeb2
Global $oBridge1, $oBridge2
Global $Bar1, $Bar2
Global $hID1, $hID2
Global $hMainGUI, $hSplitter, $hSplitterHandle
Global $g_iSplitRatio = 0.5 ; Initial 50/50 split
Global $bIsDragging = False
Global $sProfileDirectory = @ScriptDir & "\NetWebView2Lib-UserDataFolder"

_MainGUI()

;--------------------------------------------------------------------------------------------------------------------------------
Func _MainGUI() ; Creates the primary application window and starts the message loop
	ConsoleWrite("! MicrosoftEdgeWebview2 : version check: " & _NetWebView2_IsAlreadyInstalled() & ' ERR=' & @error & ' EXT=' & @extended & @CRLF)

	; Use $WS_CLIPCHILDREN to prevent flickering when resizing child windows
	$hMainGUI = GUICreate("Multi-WebView2 v1.4.0", 1000, 600, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPCHILDREN))

	; Create a Splitter bar between $hID1 and $hID2
	$hSplitter = GUICtrlCreateLabel("▒", 495, 35, 10, 555, BitOR($SS_CENTER, $SS_CENTERIMAGE))
	GUICtrlSetFont(-1, 24)
	GUICtrlSetColor(-1, 0x999999) ; Dark color for visibility
	GUICtrlSetCursor(-1, 13)      ; SizeWE cursor
	GUICtrlSetResizing(-1, $GUI_DOCKALL)

	; Register the WM_SIZE message to handle window resizing dynamically
	GUIRegisterMsg($WM_SIZE, WM_SIZE)

	; Initialize Browsers and their child window containers
	_InitBrowsers()

	; Show the main window
	GUISetState(@SW_SHOW, $hMainGUI)

	Local $nMsg
	; Main Message Loop
	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE
				Exit

			; ~~~ Web1 Controls ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			Case $Bar1.ClearBrowserData
				If MsgBox(36, "Confirm", "Do you want to clear your browsing data for Web1?") = 6 Then
					If IsObj($oWeb1) Then $oWeb1.ClearBrowserData()
				EndIf

			Case $Bar1.Address
				_Web_GoTo($oWeb1, GUICtrlRead($Bar1.Address))
			Case $Bar1.GoBack
				If IsObj($oWeb1) Then $oWeb1.GoBack()
			Case $Bar1.Reload
				If IsObj($oWeb1) Then $oWeb1.Reload()
			Case $Bar1.GoForward
				If IsObj($oWeb1) Then $oWeb1.GoForward()
			Case $Bar1.Stop
				If IsObj($oWeb1) Then $oWeb1.Stop()

			; ~~~ $Bar1.ctx_ : ContexMenu ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			Case $Bar1.GlobalNavButton
				MouseClick("right")
			Case $Bar1.ctx_Google
				If IsObj($oWeb1) Then _NetWebView2_Navigate($oWeb1, "https://www.google.com")
			Case $Bar1.ctx_AutoIt
				If IsObj($oWeb1) Then _NetWebView2_Navigate($oWeb1, "https://www.autoitscript.com/forum")
			Case $Bar1.ctx_Ghostery
				If IsObj($oWeb1) Then _NetWebView2_Navigate($oWeb1, "extension://mlomiejdfkolichcflejclcbmpeaniij/pages/panel/index.html")
			Case $Bar1.ctx_DarkReader
				If IsObj($oWeb1) Then _NetWebView2_Navigate($oWeb1, "extension://eimadpbcbfnmbkopoojfekhnkhdbieeh/ui/popup/index.html")
			Case $Bar1.ctx_Extensions_Manager
				_WV2_ShowExtensionPicker(500, 600, $hMainGUI, @ScriptDir & "\Extensions_Lib", $Bar1.Web_ProfilePath)
			Case $Bar1.ctx_EnableCustomMenu
				ConsoleWrite("> Switching to Custom Menu (AutoIt Mode)" & @CRLF)
				$oWeb1.SetContextMenuEnabled(False)
			Case $Bar1.ctx_EnableNativeMenu
				ConsoleWrite("> Switching to Native Menu (Edge Mode)" & @CRLF)
				$oWeb1.SetContextMenuEnabled(True)

			Case $Bar1.ctx_About
				_Web_Status($oWeb1)

			; ~~~ Web2 Controls ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			Case $Bar2.ClearBrowserData
				If MsgBox(36, "Confirm", "Do you want to clear your browsing data for Web2?") = 6 Then
					If IsObj($oWeb2) Then $oWeb2.ClearBrowserData()
				EndIf

			Case $Bar2.Address
				_Web_GoTo($oWeb2, GUICtrlRead($Bar2.Address))
			Case $Bar2.GoBack
				If IsObj($oWeb2) Then $oWeb2.GoBack()
			Case $Bar2.Reload
				If IsObj($oWeb2) Then $oWeb2.Reload()
			Case $Bar2.GoForward
				If IsObj($oWeb2) Then $oWeb2.GoForward()
			Case $Bar2.Stop
				If IsObj($oWeb2) Then $oWeb2.Stop()

			; ~~~ $Bar2.ctx_ : ContexMenu ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			Case $Bar2.GlobalNavButton
				MouseClick("right")
			Case $Bar2.ctx_Google
				If IsObj($oWeb2) Then $oWeb2.Navigate("https://www.google.com")
			Case $Bar2.ctx_AutoIt
				If IsObj($oWeb2) Then $oWeb2.Navigate("https://www.autoitscript.com/forum")
			Case $Bar2.ctx_Ghostery
				If IsObj($oWeb2) Then $oWeb2.Navigate("extension://mlomiejdfkolichcflejclcbmpeaniij/pages/panel/index.html")
			Case $Bar2.ctx_DarkReader
				If IsObj($oWeb2) Then $oWeb2.Navigate("extension://eimadpbcbfnmbkopoojfekhnkhdbieeh/ui/popup/index.html")
			Case $Bar2.ctx_Extensions_Manager
				_WV2_ShowExtensionPicker(500, 600, $hMainGUI, @ScriptDir & "\Extensions_Lib", $Bar2.Web_ProfilePath)
			Case $Bar2.ctx_EnableCustomMenu
				ConsoleWrite("> Switching to Custom Menu (AutoIt Mode)" & @CRLF)
				$oWeb2.SetContextMenuEnabled(False)
			Case $Bar2.ctx_EnableNativeMenu
				ConsoleWrite("> Switching to Native Menu (Edge Mode)" & @CRLF)
				$oWeb2.SetContextMenuEnabled(True)

			Case $Bar2.ctx_About
				_Web_Status($oWeb2)

			; ~~~ Dragging Handler ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			Case $GUI_EVENT_PRIMARYDOWN
				_DragAdjust()

		EndSwitch
	WEnd
EndFunc   ;==>_MainGUI

Func _ExitApp() ; OnAutoItExitRegister
	; Proper cleanup of COM objects before exit
	If IsObj($oWeb1) Then $oWeb1.Cleanup()
	If IsObj($oWeb2) Then $oWeb2.Cleanup()
	Exit
EndFunc   ;==>_ExitApp

Func _InitBrowsers() ; Creates child window containers and initializes WebView2 instances
	Local $sExtras = "Google, AutoIt, -, AdBlock, Highlight, ClearBrowserData, -, EnableCustomMenu, EnableNativeMenu, -, DarkReader"
	; Create Child Windows as containers for the WebViews

	; Instance 1 - "Profile_1" folder
	$hID1 = GUICreate("", 485, 580, 10, 10, BitOR($WS_CHILD, $WS_CLIPCHILDREN), -1, $hMainGUI)
	$Bar1 = _Web_MakeBar($hID1, $sExtras)
	$oWeb1 = _NetWebView2_CreateManager("", "Web1_")
	$oBridge1 = _NetWebView2_GetBridge($oWeb1, "Bridge1_")
	$Bar1.Web_ProfilePath = $sProfileDirectory
	_NetWebView2_Initialize($oWeb1, $hID1, $sProfileDirectory, 0, 25, 485, 555, True, True, 1.2, "0x2B2B2B", False)
	_NetWebView2_Navigate($oWeb1, "https://www.google.com/search?q=web1")

	; Instance 2 - "Profile_2" folder
	$hID2 = GUICreate("", 485, 580, 505, 10, BitOR($WS_CHILD, $WS_CLIPCHILDREN), -1, $hMainGUI)
	$Bar2 = _Web_MakeBar($hID2, $sExtras)
	$oWeb2 = _NetWebView2_CreateManager("", "Web2_")
	$oBridge2 = _NetWebView2_GetBridge($oWeb2, "Bridge2_")
	$Bar2.Web_ProfilePath = @ScriptDir & "\Profile_2"
	_NetWebView2_Initialize($oWeb2, $hID2, $sProfileDirectory, 0, 25, 485, 555, True, True, 1.2, "0x2B2B2B", False)
	_NetWebView2_Navigate($oWeb2, "https://www.google.com/search?q=web2")

	GUISetState(@SW_SHOWNOACTIVATE, $hID1)
	GUISetState(@SW_SHOWNOACTIVATE, $hID2)

EndFunc   ;==>_InitBrowsers

;--------------------------------------------------------------------------------------------------------------------------------
; BROWSER 1 EVENTS (Search Results Engine)
;--------------------------------------------------------------------------------------------------------------------------------
Func Web1_OnMessageReceived($oWebV2M, $hGUI, $sMsg)    ; [Web1]
	#forceref $oWebV2M, $hGUI
	ConsoleWrite("> [Web1]: " & $sMsg & @CRLF)
	Local $aParts = StringSplit($sMsg, "|")
	Local $sCommand = StringStripWS($aParts[1], 3)
	Switch $sCommand
		Case "INIT_READY"
			$oWebV2M.SetContextMenuEnabled(True)
			;COM_TEST
			$oWebV2M.ExecuteScript('window.chrome.webview.postMessage(JSON.stringify({ "type": "COM_TEST", "status": "OK" }));')

		Case "NAV_COMPLETED"
			; Responsive tweaks could be applied here if needed

		Case "URL_CHANGED"
			If $aParts[0] > 1 Then
				GUICtrlSetData($Bar1.Address, $aParts[2])
				GUICtrlSendMsg($Bar1.Address, $EM_SETSEL, 0, 0)
				$oWebV2M.WebViewSetFocus() ; We give focus to the browser
			EndIf

	EndSwitch
EndFunc   ;==>Web1_OnMessageReceived

Func Bridge1_OnMessageReceived($oWebV2M, $hGUI, $sMsg) ; [Bridge1 JS]
	#forceref $oWebV2M, $hGUI
	ConsoleWrite("> [Bridge1 JS]: " & $sMsg & @CRLF)
EndFunc   ;==>Bridge1_OnMessageReceived

;--------------------------------------------------------------------------------------------------------------------------------
; BROWSER 2 EVENTS (Main Navigation & Selection Source)
;--------------------------------------------------------------------------------------------------------------------------------
Func Web2_OnMessageReceived($oWebV2M, $hGUI, $sMsg)    ; [Web2]
	#forceref $oWebV2M, $hGUI
	ConsoleWrite("> [Web2]: " & $sMsg & @CRLF)
	Local $aParts = StringSplit($sMsg, "|")
	Local $sCommand = StringStripWS($aParts[1], 3)
	Switch $sCommand
		Case "INIT_READY"
			$oWeb2.SetContextMenuEnabled(True)
			;COM_TEST
			$oWeb2.ExecuteScript('window.chrome.webview.postMessage(JSON.stringify({ "type": "COM_TEST", "status": "OK" }));')

		Case "NAV_COMPLETED"
			; Re-inject the selection script every time a new page is loaded
			ConsoleWrite(">>> Web2 Navigation Completed. Injecting Selection Script..." & @CRLF)
			$oWeb2.ExecuteScript(JS_getSelection())

		Case "URL_CHANGED"
			If $aParts[0] > 1 Then
				GUICtrlSetData($Bar2.Address, $aParts[2])
				GUICtrlSendMsg($Bar2.Address, $EM_SETSEL, 0, 0)
				$oWeb2.WebViewSetFocus() ; We give focus to the browser
			EndIf
	EndSwitch
EndFunc   ;==>Web2_OnMessageReceived

Func Bridge2_OnMessageReceived($oWebV2M, $hGUI, $sMsg) ; [Bridge2 JS]
	#forceref $oWebV2M, $hGUI
	ConsoleWrite("> [Bridge2 JS]: " & $sMsg & @CRLF)

	Local $aParts = StringSplit($sMsg, "|")
	If $aParts[0] < 2 Then Return

	Local $sCommand = StringStripWS($aParts[1], 3)

	Switch $sCommand
		Case "SEARCH_GOOGLE"
			If IsObj($oWeb1) Then
				Local $sSearchText = StringReplace(StringStripWS($aParts[2], 3), " ", "+")
				Local $sDomain2 = StringStripWS($aParts[3], 3)
				ConsoleWrite(">>> Performing search on Web1: " & $sSearchText & " @ " & $sDomain2 & @CRLF)

				; Construct Google search URL with 'site:' operator
				Local $sURL = "https://www.google.com/search?q=" & $sSearchText & "+site:" & $sDomain2

				; Update Browser 1 with the results
				_NetWebView2_Navigate($oWeb1, $sURL)
			EndIf
	EndSwitch
EndFunc   ;==>Bridge2_OnMessageReceived

;--------------------------------------------------------------------------------------------------------------------------------
; Helper functions
;--------------------------------------------------------------------------------------------------------------------------------
Func _Web_MakeBar($hGUI, $ctx_list = "", $bAddress = 1) ; Make a Basic ToolBar for Browsing navigation
	; Defining the main buttons with the Fluent Icons
	Local $Btn[][] = [[59136, "GlobalNavButton"] _
			, [59213, "ClearBrowserData"] _
			, [59179, "GoBack"] _
			, [59153, "Cancel"] _
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
	Local $iInputW = $aCsz[0] - $iX

	$m.Address = GUICtrlCreateInput("", $iX, $iY, $iInputW, $iH)
	GUICtrlSetFont(-1, 10, 400, 0, "Segoe UI")
	GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKTOP)
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

Func _Web_GoTo(ByRef $oWebObject, $sURL) ; Navigates to a URL or performs a Google search if the input is not a URL.
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
        If IsObj($oWebObject) Then
            $sEncodedQuery = $oWebObject.EncodeURI($sURL)
        Else
            ; Fallback if object is not ready (basic replace)
            $sEncodedQuery = StringReplace($sURL, " ", "+")
        EndIf
        $sFinalURL = "https://www.google.com/search?q=" & $sEncodedQuery
    EndIf

    ; --- Execution ---
    ConsoleWrite("-> Web_GoTo: " & $sFinalURL & @CRLF)

    If IsObj($oWebObject) Then
        $oWebObject.Navigate($sFinalURL)
        Return True
    EndIf

    Return False
EndFunc   ;==>_Web_GoTo

Func _Web_Notify(ByRef $oObject, $sMessage, $sBgColor = "#4CAF50", $iDuration = 3000) ; notification toast in the browser
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

	$oObject.ExecuteScript($sJS)
EndFunc   ;==>_Web_Notify

Func _Web_Status(ByRef $oObject)
	Local $sMsg = "" & _
			"Current Source: " & $oObject.GetSource() & @CRLF & _
			"Document Title: " & $oObject.GetDocumentTitle() & @CRLF & _
			"Browser PID: " & $oObject.GetBrowserProcessId() & @CRLF & _
			"Can Go Back: " & ($oObject.GetCanGoBack() ? "Yes" : "No") & @CRLF & _
			"Can Go Forward: " & ($oObject.GetCanGoForward() ? "Yes" : "No") & @CRLF & _
			"Allow Popups: " & ($oObject.AreBrowserPopupsAllowed ? "Yes" : "No") & @CRLF & _
			"Are DevTools Enabled: " & ($oObject.AreDevToolsEnabled ? "Yes" : "No") & @CRLF & _
			"Are Default ContextMenus Enabled: " & ($oObject.AreDefaultContextMenusEnabled ? "Yes" : "No") & @CRLF

	MsgBox(0, "About v1.4.0 State", $sMsg)

EndFunc   ;==>_ShowHealthStatus

Func JS_getSelection() ; A floating button "🔍 Search Google" will appear near your selection.
	Local $sJS = _
			"(function() {" & _
			"    document.onmouseup = function(e) {" & _
			"        var selection = window.getSelection();" & _
			"        var text = selection.toString().trim();" & _
			"        var old = document.getElementById('search-popup');" & _
			"        if (old) old.remove();" & _
			"        if (text.length > 0) {" & _
			"            var btn = document.createElement('div');" & _
			"            btn.id = 'search-popup';" & _
			"            btn.innerHTML = '🔍 Search Google';" & _
			"            btn.setAttribute('style', 'position:absolute; top:'+(e.pageY-45)+'px; left:'+e.pageX+'px; ' +" & _
			"                'z-index:2147483647; background:#4285f4; color:white; padding:8px 12px; ' +" & _
			"                'border-radius:5px; cursor:pointer; font-family:sans-serif; font-size:14px; ' +" & _
			"                'box-shadow:0 4px 10px rgba(0,0,0,0.4); user-select:none;');" & _
			"            " & _
			"            btn.addEventListener('mousedown', function(ev) {" & _
			"                ev.preventDefault();" & _
			"                ev.stopPropagation();" & _
			"                if (window.chrome && window.chrome.webview) {" & _
			"                    window.chrome.webview.postMessage('SEARCH_GOOGLE|' + text + '|' + window.location.hostname);" & _
			"                }" & _
			"                this.remove();" & _
			"            }, true);" & _
			"            document.body.appendChild(btn);" & _
			"        }" & _
			"    };" & _
			"})();"
	Return $sJS
EndFunc   ;==>JS_getSelection

Func WM_SIZE($hWnd, $iMsg, $wParam, $lParam)  ; Synchronizes WebView size with the GUI window
	#forceref $hWnd, $iMsg, $wParam, $lParam
	If $hWnd <> $hMainGUI Then Return $GUI_RUNDEFMSG ; critical, to respond only to the $hGUI
	If $wParam = 1 Then Return $GUI_RUNDEFMSG ; Skip if Minimized
	_DragAdjust(True) ; Re-adjust layout using the stored Ratio
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_SIZE

Func _DragAdjust($bResized = False)  ; Manages the interactive splitter dragging or proportional resizing
	Local Static $iOffset = 5 ; Half of the Gap (10/2)
	Local Static $iPrevMousePos = -1

	Local $aWin = WinGetClientSize($hMainGUI)
	Local $iGuiW = $aWin[0]
	Local $iGuiH = $aWin[1]
	Local $iTop = 10, $iMargin = 10, $iGap = 10
	Local $iH = $iGuiH - $iTop - 10
	Local $iW1

	If $bResized Then
		; Calculate W1 based on the existing SplitRatio during window resize
		Local $iTotalW = $iGuiW - ($iMargin * 2) - $iGap
		$iW1 = Int($iTotalW * $g_iSplitRatio)
		_UpdateLayout($iW1, $iGuiW, $iH)
		Return
	EndIf

	; --- Dragging Logic ---
	Local $aCursor = GUIGetCursorInfo($hMainGUI)
	If Not IsArray($aCursor) Or $aCursor[4] <> $hSplitter Then Return

	Opt("MouseCoordMode", 2) ; Client area coordinate mode
	While $aCursor[2] ; Loop while Primary Mouse Button is held
		$aCursor = GUIGetCursorInfo($hMainGUI)
		Local $iMousePos = $aCursor[0]

		; Boundaries to prevent panels from disappearing
		If $iMousePos < 100 Then $iMousePos = 100
		If $iMousePos > $iGuiW - 100 Then $iMousePos = $iGuiW - 100

		If $iMousePos <> $iPrevMousePos Then
			; Calculate new Split Ratio
			Local $iAvailableW = $iGuiW - ($iMargin * 2) - $iGap
			$g_iSplitRatio = ($iMousePos - $iMargin - $iOffset) / $iAvailableW

			; Execute Layout Update
			$iW1 = $iMousePos - $iMargin - $iOffset
			_UpdateLayout($iW1, $iGuiW, $iH)

			$iPrevMousePos = $iMousePos
		EndIf
		Sleep(10)
	WEnd
	Opt("MouseCoordMode", 1) ; Reset to Screen mode
EndFunc   ;==>_DragAdjust

Func _UpdateLayout($iW1, $iTotalW, $iH) ; Moves and resizes all GUI components based on the calculated widths
	Local $iMargin = 10, $iTop = 10, $iGap = 10
	Local $iW2 = $iTotalW - ($iMargin * 2) - $iGap - $iW1

	; Move Web1 Container and Resize WebView
	ControlMove($hMainGUI, "", $hID1, $iMargin, $iTop, $iW1, $iH)
	If IsObj($oWeb1) Then $oWeb1.Resize($iW1, $iH - 25)

	; Move Splitter Bar
	GUICtrlSetPos($hSplitter, $iMargin + $iW1, $iTop, $iGap, $iH)

	; Move Web2 Container and Resize WebView
	ControlMove($hMainGUI, "", $hID2, $iMargin + $iW1 + $iGap, $iTop, $iW2, $iH)
	If IsObj($oWeb2) Then $oWeb2.Resize($iW2, $iH - 25)
EndFunc   ;==>_UpdateLayout
