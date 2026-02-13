#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Run_AU3Check=Y
#AutoIt3Wrapper_AU3Check_Stop_OnWarning=y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7

; 010-NavigationBar.au3
;~ #AutoIt3Wrapper_Run_Debug_Mode=Y
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <Misc.au3>
#include <GuiMenu.au3>
#include <WinAPIMisc.au3>
#include "_WV2_ExtensionPicker.au3"
#include "..\NetWebView2Lib.au3"

; Check if the version supports Maps
If _VersionCompare(@AutoItVersion, "3.3.16.0") < 0 Then
	MsgBox($MB_ICONSTOP, "Compatibility Error", _
			"This version of the script uses Maps and requires AutoIt 3.3.16.0 or higher." & @CRLF & _
			"Your version: " & @AutoItVersion)
	Exit
EndIf


; Global objects
Global $_mBAR
Global $sProfileDirectory = @ScriptDir & "\NetWebView2Lib-UserDataFolder"

_Example()

Func _Example()
	Local $hDLL = DllOpen("user32.dll")
	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc)
	#forceref $oMyError

	; Create the GUI
	Local $hGUI = GUICreate("WebView2", 1000, 800, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPCHILDREN))
	GUISetBkColor(0x2B2B2B, $hGUI)

	; Initialize WebView2 Manager and register events
	Local $oWebV2M = _NetWebView2_CreateManager("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0", "Event_")
	If @error Then Return SetError(@error, @extended, $oWebV2M)

	; create JavaScript Bridge object
	Local $oJSBridge = _NetWebView2_GetBridge($oWebV2M, "")
	If @error Then Return SetError(@error, @extended, $oWebV2M)

	; initialize browser - put it on the GUI
	_NetWebView2_Initialize($oWebV2M, $hGUI, $sProfileDirectory, 0, 25, 1000, 800 - 25, True, True, True, 1.2, "0x2B2B2B")

	; Make a Basic ToolBar for Browsing navigation
	$_mBAR = _Web_MakeBar($hGUI, $oWebV2M, 1)

	; show the GUI after browser was fully initialized
	GUISetState(@SW_SHOW)


	; navigate to the page
	_NetWebView2_Navigate($oWebV2M, "https://en.wikipedia.org/wiki/List_of_countries_and_dependencies_by_population", $NETWEBVIEW2_MESSAGE__TITLE_CHANGED)
	ConsoleWrite("navigate to the page" & @CRLF)

	; Main Loop
	Local $iMsg
	While 1
		$iMsg = GUIGetMsg()
		Switch $iMsg
			Case $GUI_EVENT_CLOSE
				ExitLoop
			Case $_mBAR.Navigation
				_Web_NavButton()
			Case $_mBAR.Address
				If _IsPressed("0D", $hDLL) Then ; ENTER key
					_Web_NavButton("Navigate")
					_Web_NavButton()
				Else
					AdlibRegister(_Web_SetNavigateToReload, 700)
				EndIf

			Case $_mBAR.GoBack
				$oWebV2M.GoBack()
			Case $_mBAR.GoForward
				$oWebV2M.GoForward()
			Case $_mBAR.Application_Menu
				_ShowApplicationMenu($oWebV2M, $hGUI)
			Case $_mBAR.Features
;~ 				_ShowFeaturesMenu()
		EndSwitch

		; AddressBar FullSelection Management
		If $_mBAR.bURLFullSelected Then
			$_mBAR.bURLFullSelected = False
			GUICtrlSendMsg($_mBAR.Address, $EM_SETSEL, 0, -1)
		EndIf

	WEnd

	__NetWebView2_LastMessageReceived($oWebV2M, -1000)

	_NetWebView2_CleanUp($oWebV2M, $oJSBridge)
	GUIDelete($hGUI)
	DllClose($hDLL)
EndFunc   ;==>_Example

;---------------------------------------------------------------------------------------
Func _ShowApplicationMenu($oWebV2M, $hGUI)
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
			_Web_GoTo($oWebV2M, "https://www.google.com")
		Case 1002
			_Web_GoTo($oWebV2M, "https://www.autoitscript.com/forum")
		Case 1003
			_Web_GoTo($oWebV2M, "https://en.wikipedia.org/wiki/List_of_countries_and_dependencies_by_population")
		Case 1004
			_Web_GoTo($oWebV2M, "https://demoqa.com/text-box")
		Case 1005
			_Web_GoTo($oWebV2M, "https://learn.microsoft.com/en-us/dotnet/api/microsoft.web.webview2.core.corewebview2profile.addbrowserextensionasync?view=webview2-dotnet-1.0.3595.46")
		Case 1010
			_Web_GoTo($oWebV2M, "extension://mlomiejdfkolichcflejclcbmpeaniij/pages/panel/index.html")
		Case 1011
			_Web_GoTo($oWebV2M, "extension://eimadpbcbfnmbkopoojfekhnkhdbieeh/ui/popup/index.html")
		Case 1020
			_WV2_ShowExtensionPicker(500, 600, $hGUI, @ScriptDir & "\Extensions_Lib", $sProfileDirectory)
		Case 1021
			If MsgBox(36, "Confirm", "Clear all browser history/cookies?") = 6 Then $oWebV2M.ClearBrowserData()
	EndSwitch
	_GUICtrlMenu_DestroyMenu($hMenu)
	$oWebV2M.WebViewSetFocus() ; We give focus to the browser
EndFunc   ;==>_ShowApplicationMenu

;---------------------------------------------------------------------------------------
Func Event_OnNavigationCompleted($oWebV2M, $hGUI, $bSuccess, $iError) ; EVENT HANDLERS (CALLBACKS)
	#forceref $hGUI, $bSuccess, $iError
	ConsoleWrite(">>>$bSuccess=" & $bSuccess & @CRLF)
	$oWebV2M.ExecuteScript("finalizeProgress();")

	GUICtrlSetData($_mBAR.Address, $oWebV2M.GetSource())
	_Web_NavButton("Reload")

	; Using the new Getters for dynamic UI
	GUICtrlSetState($_mBAR.GoBack, ($oWebV2M.GetCanGoBack() ? $GUI_ENABLE : $GUI_DISABLE))
	GUICtrlSetState($_mBAR.GoForward, ($oWebV2M.GetCanGoForward() ? $GUI_ENABLE : $GUI_DISABLE))
	$oWebV2M.WebViewSetFocus() ; We give focus to the browser
EndFunc   ;==>Event_OnNavigationCompleted

;---------------------------------------------------------------------------------------
Func _Web_MakeBar($hGUI, $oWebV2M, $bAddress = 1) ; Make a Basic ToolBar for Browsing navigation
	; Defining the main buttons with the Fluent Icons
	Local $Btn[][] = _
			[ _
			[59136, "Application_Menu"], _
			[59308, "Features"], _
			[59179, "GoBack"], _
			[59178, "GoForward"], _
			[59180, "Navigation"] _
			]

	Local $iX = 0, $iY = 0, $iH = 25, $iW = 25, $iCnt = UBound($Btn)
	Local $mBAR[] ; Map object to return IDs

	; Creating the Buttons
	For $i = 0 To $iCnt - 1
		$mBAR[$Btn[$i][1]] = GUICtrlCreateButton(ChrW($Btn[$i][0]), $iX, $iY, $iW, $iH)
		GUICtrlSetFont(-1, 12, 400, 0, "Segoe Fluent Icons")
		GUICtrlSetTip(-1, StringReplace($Btn[$i][1], "_", " "))
		GUICtrlSetResizing(-1, $GUI_DOCKALL)
		$iX += $iW
	Next

	; Creating the Address Bar
	Local $aCsz = WinGetClientSize($hGUI)
	Local $iInputW = $aCsz[0] - $iX - 15
	$mBAR.Address = GUICtrlCreateInput("", $iX, $iY, $iInputW, $iH)
	GUICtrlSetFont(-1, 11, 400, 0, "Segoe UI")
	GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKMENUBAR)
	If Not $bAddress Then GUICtrlSetState(-1, $GUI_HIDE)

	$mBAR.bURLFullSelected = False

	$mBAR.WebV2M = $oWebV2M
	Return $mBAR
EndFunc   ;==>_Web_MakeBar

;---------------------------------------------------------------------------------------
Func _Web_NavButton($sSetState = Default) ; Set or executes the action of Navigation button (Reload/Stop/Navigate)
	Local Static $sState = "Reload"

	; 59180 = Reload ; 59153 = Cancel ; 59217 = ReturnKey
	Local $oWebV2M = $_mBAR.WebV2M
	If $sSetState <> Default Then
		Switch $sSetState
			Case "Reload"
				GUICtrlSetData($_mBAR.Navigation, ChrW(59180))
				GUICtrlSetTip($_mBAR.Navigation, "Reload")
			Case "Stop"
				GUICtrlSetData($_mBAR.Navigation, ChrW(59153))
				GUICtrlSetTip($_mBAR.Navigation, "Stop")
			Case "Navigate"
				If $sState = $sSetState Then Return
				AdlibUnRegister(_Web_SetNavigateToReload) ; UnRegister it (if exist)
				GUICtrlSetData($_mBAR.Navigation, ChrW(59217))
				GUICtrlSetTip($_mBAR.Navigation, "Navigate")
		EndSwitch
		$sState = $sSetState
		Return
	EndIf

	Switch $sState
		Case "Reload"
			$oWebV2M.Reload()
		Case "Stop"
			$oWebV2M.Stop()
		Case "Navigate"
			Sleep(100)
			_Web_GoTo($oWebV2M, GUICtrlRead($_mBAR.Address))
	EndSwitch
EndFunc   ;==>_Web_NavButton

;---------------------------------------------------------------------------------------
Func _Web_SetNavigateToReload() ; AdlibRegister("_Web_SetNavigateToReload", 700), and forget it
	_Web_NavButton("Reload")
	AdlibUnRegister(_Web_SetNavigateToReload) ; unregister itself.
EndFunc   ;==>_Web_SetNavigateToReload

;---------------------------------------------------------------------------------------
Func _Web_GoTo($oWebV2M, $sURL) ; Navigates to a URL or performs a Google search if the input is not a URL.
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
		$sFinalURL = "https://www.google.com/search?q=" & $oWebV2M.EncodeURI($sURL)
	EndIf

	; Execution
	ConsoleWrite("-> Web_GoTo: " & $sFinalURL & @CRLF)
	$oWebV2M.Navigate($sFinalURL)
	Return True
EndFunc   ;==>_Web_GoTo

;---------------------------------------------------------------------------------------
Func WM_COMMAND($hWnd, $iMsg, $wParam, $lParam) ; Register the WM_COMMAND (CALLBACKS) to handle AddressBar FullSelection
	#forceref $hWnd, $iMsg
	Local Static $hidURL = GUICtrlGetHandle($_mBAR.Address)
	Local $iCode = BitShift($wParam, 16)
	If $lParam = $hidURL Then
		Switch $iCode
			Case $EN_SETFOCUS
				$_mBAR.bURLFullSelected = True
			Case $EN_CHANGE
				_Web_NavButton("Navigate")
		EndSwitch
	EndIf
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_COMMAND
;---------------------------------------------------------------------------------------
