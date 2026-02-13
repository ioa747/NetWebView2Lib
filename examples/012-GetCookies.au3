#WIP - this Example is imported from 1.5.0 UDF - and is in "WORK IN PROGRESS" state

#AutoIt3Wrapper_UseX64=y
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <Array.au3>
#include <GuiEdit.au3>
#include <Misc.au3>

_VersionChecker("1.2.0.0") ; DLL Version Check

; Register the exit function
OnAutoItExitRegister(_CleanExit)

; Global objects handler for COM objects
Global $oManager, $oBridge
Global $oMyError = ObjEvent("AutoIt.Error", "_ErrFunc")
Global $sProfileDirectory = @ScriptDir & "\NetWebView2Lib-UserDataFolder"

; Global variables for data management
Global $hGUI, $idURL, $idStatusLabel
Global $g_bURLFullSelected = False
Global $g_bAutoRestoreSession = False

Main()

Func Main()
	#Region ; === Gui AutoIt ===
	$hGUI = GUICreate("AutoIt", 1285, 850, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPCHILDREN))
	GUISetBkColor(0x1E1E1E, $hGUI)

	Local $sURL = "https://www.google.com"
	$idURL = GUICtrlCreateInput($sURL, 290, 10, 985, 25)
	GUICtrlSetFont(-1, 10)
	GUICtrlSetColor(-1, 0xFFFFFF) ; White
	GUICtrlSetBkColor(-1, 0x000000) ; Black background
	GUICtrlSetResizing(-1, $GUI_DOCKLEFT + $GUI_DOCKRIGHT + $GUI_DOCKMENUBAR)

	; Button ClearBrowserData
	Local $idBtnClearBrowserData = GUICtrlCreateButton(ChrW(59213), 10, 10, 25, 25)
	GUICtrlSetFont(-1, 10, 400, 0, "Segoe Fluent Icons")
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetTip(-1, "ClearBrowserData")

	; Button Save Session
	Local $idBtnSaveSession = GUICtrlCreateButton(ChrW(59276), 35, 10, 25, 25)
	GUICtrlSetFont(-1, 10, 400, 0, "Segoe Fluent Icons")
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetTip(-1, "Save Session")

	; Button Restore Session
	Local $idBtnRestoreSession = GUICtrlCreateButton(ChrW(59420), 60, 10, 25, 25)
	GUICtrlSetFont(-1, 10, 400, 0, "Segoe Fluent Icons")
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetTip(-1, "Restore Session")

	; Button ResetZoom
	Local $idBtnResetZoom = GUICtrlCreateButton(ChrW(59623), 135, 10, 25, 25)
	GUICtrlSetFont(-1, 10, 400, 0, "Segoe Fluent Icons")
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetTip(-1, "ResetZoom")

	; Button SetZoom
	Local $idBtnSetZoom = GUICtrlCreateButton(ChrW(59624), 160, 10, 25, 25)
	GUICtrlSetFont(-1, 10, 400, 0, "Segoe Fluent Icons")
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetTip(-1, "SetZoom")


	; Button GoBack
	Local $idBtnGoBack = GUICtrlCreateButton(ChrW(59179), 185, 10, 25, 25)
	GUICtrlSetFont(-1, 10, 400, 0, "Segoe Fluent Icons")
	GUICtrlSetResizing(-1, $GUI_DOCKALL)

	; Button Stop
	Local $idBtnStop = GUICtrlCreateButton(ChrW(59153), 210, 10, 25, 25)
	GUICtrlSetFont(-1, 10, 400, 0, "Segoe Fluent Icons")
	GUICtrlSetResizing(-1, $GUI_DOCKALL)

	; Button GoForward
	Local $idBtnGoForward = GUICtrlCreateButton(ChrW(59178), 235, 10, 25, 25)
	GUICtrlSetFont(-1, 10, 400, 0, "Segoe Fluent Icons")
	GUICtrlSetResizing(-1, $GUI_DOCKALL)

	; Button Reload
	Local $idReload = GUICtrlCreateButton(ChrW(59180), 260, 10, 25, 25)
	GUICtrlSetFont(-1, 10, 400, 0, "Segoe Fluent Icons")
	GUICtrlSetResizing(-1, $GUI_DOCKALL)

	; Status Label ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$idStatusLabel = GUICtrlCreateLabel("", 10, 830, 400, 20)
	GUICtrlSetFont(-1, 10, 800)
	GUICtrlSetColor(-1, 0xFFFFFF)
	GUICtrlSetResizing(-1, $GUI_DOCKSIZE + $GUI_DOCKBOTTOM)

	_WebView2(0, 45, 1285, 800) ; Get the WebView2 Manager object

	; Register the WM_SIZE message to handle window resizing
	GUIRegisterMsg($WM_SIZE, "WM_SIZE")

	; Register the WM_COMMAND message to handle ...
	GUIRegisterMsg($WM_COMMAND, "WM_COMMAND")

	;GUISetState(@SW_SHOW)
	#EndRegion ; === Gui AutoIt ===

	; Main Application Loop
	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				ExitLoop

			Case $idBtnClearBrowserData
				If MsgBox(36, "Confirm", "Do you want to clear your browsing data?") = 6 Then
					$oManager.ClearBrowserData()
					ShowWebNotification("Browser history & cookies cleared!", "#f44336")
				EndIf

			Case $idBtnSaveSession
				$oManager.GetCookies(GUICtrlRead($idURL))

			Case $idBtnRestoreSession
				Local $sURL = GUICtrlRead($idURL)
				Local $sDomainOnly = StringRegExpReplace($sURL, "https?://([^/]+).*", "$1")
				_RestoreSession($sDomainOnly)

			Case $idBtnSetZoom
				$oManager.SetZoom(1.5) ; Zoom to 150%
				ShowWebNotification("Zoom: 150%", "#2196F3")

			Case $idBtnResetZoom
				$oManager.ResetZoom() ; Reset to 100%
				ShowWebNotification("Zoom: 100%", "#4CAF50")

			Case $idBtnGoBack
				$oManager.GoBack()

			Case $idBtnGoForward
				$oManager.GoForward()

			Case $idBtnStop
				$oManager.Stop()
				GUICtrlSetData($idStatusLabel, "Stop")

			Case $idReload
				$oManager.Reload()
				GUICtrlSetData($idStatusLabel, "Reload")

			Case $idURL
				$oManager.Navigate(GUICtrlRead($idURL))
				GUICtrlSetData($idStatusLabel, "Navigate: " & GUICtrlRead($idURL))

		EndSwitch

		If $g_bURLFullSelected Then
			$g_bURLFullSelected = False
			GUICtrlSendMsg($idURL, $EM_SETSEL, 0, -1)
		EndIf

	WEnd

EndFunc   ;==>Main
;---------------------------------------------------------------------------------------
Func _CleanExit() ; CleanExit
	; Check if the object exists before calling methods to avoid COM errors during crash
	If IsObj($oManager) Then
		$oManager.Cleanup()
	EndIf

	; Release the event sinks
	$oManager = 0
	$oBridge = 0
	$oEvtManager = 0
	$oEvtBridge = 0
	$oMyError = 0

	ConsoleWrite("--> Application exited cleanly." & @CRLF)
EndFunc   ;==>_CleanExit
;---------------------------------------------------------------------------------------
Func _WebView2($iLeft = 0, $iTop = 0, $iWidth = 0, $iHeight = 0)

	; Get the WebView2 Manager object and register events
	$oManager = ObjCreate("NetWebView2.Manager")
	ObjEvent($oManager, "WebView_", "IWebViewEvents")

	; Get the bridge object and register events
	$oBridge = $oManager.GetBridge()
	ObjEvent($oBridge, "Bridge_", "IBridgeEvents")

	; ⚠️ Important: Enclose ($hGUI) in parentheses to force "Pass-by-Value".
	; This prevents the COM layer from changing the AutoIt variable type from Ptr to Int64.
	$oManager.Initialize(($hGUI), $sProfileDirectory, $iLeft, $iTop, $iWidth, $iHeight)
EndFunc   ;==>_WebView2
;---------------------------------------------------------------------------------------
Func Bridge_OnMessageReceived($sMessage)
	; Handles data received from the JavaScript 'postMessage'
	ConsoleWrite("+> [JS MESSAGE]: " & $sMessage & @CRLF)
EndFunc   ;==>Bridge_OnMessageReceived
;---------------------------------------------------------------------------------------
Func WebView_OnMessageReceived($sMessage)
	ConsoleWrite("+> [CORE EVENT]: " & $sMessage & @CRLF)
	Local Static $bIsInitialized, $sCurentURL = "", $sLastRestoredDomain = ""
	Local $sDomain

	; Separating messages that have parameters (e.g. TITLE_CHANGED|...)
	Local $aParts = StringSplit($sMessage, "|")
	Local $sCommand = StringStripWS($aParts[1], 3)

	Switch $sCommand
		Case "INIT_READY"
			$bIsInitialized = True ; We note that we are finished.
			$oManager.Navigate(GUICtrlRead($idURL))
			GUISetState(@SW_SHOW, $hGUI)

		Case "NAV_STARTING"
			$sCurentURL = GUICtrlRead($idURL)
			$sDomain = StringRegExpReplace($sCurentURL, "https?://([^/]+).*", "$1")

			If $g_bAutoRestoreSession And $sDomain <> $sLastRestoredDomain Then
				ConsoleWrite("> Auto-Restore: Initializing for " & $sDomain & @CRLF)
				_RestoreSession($sDomain)
				$sLastRestoredDomain = $sDomain ; Remember that we already restored this domain
			EndIf

		Case "NAV_COMPLETED"
			GUICtrlSetData($idStatusLabel, "Redy")

		Case "TITLE_CHANGED"
			If $aParts[0] > 1 Then
				WinSetTitle($hGUI, "", "AutoIt Auditor - " & $aParts[2])
			EndIf

		Case "URL_CHANGED"
			If $aParts[0] > 1 Then
				$sCurentURL = $aParts[2]
				GUICtrlSetData($idURL, $sCurentURL)
				GUICtrlSendMsg($idURL, $EM_SETSEL, 0, 0)
				$oManager.WebViewSetFocus() ; We give focus to the browser
			EndIf

		Case "COOKIES_B64"
			; Ensure we have enough parts (Command|URL|Data)
			If $aParts[0] > 2 Then
				_ProcessCookies($aParts[2], $aParts[3])
			EndIf

		Case "PDF_SUCCESS"
			MsgBox(64, "Success", "PDF Report saved successfully!")


		Case "ERROR", "NAV_ERROR"
			Local $sErr = ($aParts[0] > 1) ? $aParts[2] : "Unknown"
			GUICtrlSetData($idStatusLabel, "Status: Error " & $sErr)
			MsgBox(16, "WebView2 Error", $sMessage)
	EndSwitch

EndFunc   ;==>WebView_OnMessageReceived
;---------------------------------------------------------------------------------------
Func _ProcessCookies($sURL, $sBase64)
	Local $oJson = ObjCreate("NetJson.Parser")
	If Not IsObj($oJson) Then Return

	Local $sDomainOnly = StringRegExpReplace($sURL, "https?://([^/]+).*", "$1")
	Local $sDecodedJson = $oManager.DecodeB64($sBase64)  ; _Base64Decode($sBase64)
	$oJson.Parse($sDecodedJson)

	Local $iTotal = $oJson.GetArrayLength("")
	Local $sNewJson = "["
	Local $iFoundCount = 0

	For $i = 0 To $iTotal - 1
		Local $sDomain = $oJson.GetTokenValue("[" & $i & "].domain")
		Local $sName = $oJson.GetTokenValue("[" & $i & "].name")

		; Clean the domain for comparison (remove leading dot)
		Local $sCleanDom = $sDomain
		If StringLeft($sCleanDom, 1) = "." Then $sCleanDom = StringTrimLeft($sCleanDom, 1)

		; Filter: Check if cookie belongs to the current domain
		If Not StringInStr($sDomainOnly, $sCleanDom) Then
			ConsoleWrite($i & ") <-- Dropping: " & $sName & " (Domain: " & $sDomain & ")" & @CRLF)
			ContinueLoop
		EndIf

		ConsoleWrite($i & ") --> Adding: " & $sName & " (Domain: " & $sDomain & ")" & @CRLF)

		; Escape values to ensure valid JSON construction
		Local $sEscName = $oJson.EscapeString($sName)
		Local $sEscValue = $oJson.EscapeString($oJson.GetTokenValue("[" & $i & "].value"))
		Local $sEscDom = $oJson.EscapeString($sDomain)
		Local $sEscPath = $oJson.EscapeString($oJson.GetTokenValue("[" & $i & "].path"))

		; Build the JSON object for this cookie
		Local $sItem = '{"name":"' & $sEscName & '","value":"' & $sEscValue & '","domain":"' & $sEscDom & '","path":"' & $sEscPath & '"}'

		If $iFoundCount > 0 Then $sNewJson &= ","
		$sNewJson &= $sItem
		$iFoundCount += 1
	Next
	$sNewJson &= "]"

	; Save the filtered collection if not empty
	If $iFoundCount > 0 Then
		$oJson.Parse($sNewJson)
		If Not FileExists(@ScriptDir & "\Session") Then DirCreate(@ScriptDir & "\Session")
		Local $sLogFile = @ScriptDir & "\Session\cookies_" & $sDomainOnly & ".json"
		$oJson.SaveToFile($sLogFile)
		ConsoleWrite("> Clean session saved (" & $iFoundCount & " cookies) to: " & $sLogFile & @CRLF)
	EndIf
EndFunc   ;==>_ProcessCookies
;---------------------------------------------------------------------------------------
Func _RestoreSession($sDomain)
	Local $sLogFile = @ScriptDir & "\Session\cookies_" & $sDomain & ".json"

	Local $oJson = ObjCreate("NetJson.Parser")
	If Not $oJson.LoadFromFile($sLogFile) Then
		ShowWebNotification("! No session file found for: " & $sDomain, "#f44336")
		Return
	EndIf

	Local $iTotal = $oJson.GetArrayLength("")
	ConsoleWrite("> Restoring " & $iTotal & " cookies for " & $sDomain & "..." & @CRLF)

	Local $iInjected = 0

	For $i = 0 To $iTotal - 1
		; Retrieve escaped values and revert them back to raw format
		Local $sRawName = $oJson.UnescapeString($oJson.GetTokenValue("[" & $i & "].name"))
		Local $sRawValue = $oJson.UnescapeString($oJson.GetTokenValue("[" & $i & "].value"))
		Local $sRawDom = $oJson.UnescapeString($oJson.GetTokenValue("[" & $i & "].domain"))
		Local $sRawPath = $oJson.UnescapeString($oJson.GetTokenValue("[" & $i & "].path"))

		If $sRawPath == "" Then $sRawPath = "/"

		; Check if the cookie domain matches the target session domain
		If StringInStr($sRawDom, $sDomain) Or StringInStr($sDomain, StringTrimLeft($sRawDom, 1)) Then
			; Inject the cookie into the WebView2 manager
			$oManager.AddCookie($sRawName, $sRawValue, $sRawDom, $sRawPath)

			ConsoleWrite(StringFormat("  [%d] %-15s | Domain: %-15s | Val: %s...\n", _
					$i, $sRawName, $sDomain, StringLeft($sRawValue, 10)))
			$iInjected += 1
		EndIf
	Next

	; Apply changes if cookies were injected
	If $iInjected > 0 Then
		$oManager.Reload()
		ShowWebNotification("Session Restored for " & $sDomain, "#2196F3")
	EndIf
EndFunc   ;==>_RestoreSession
;---------------------------------------------------------------------------------------
Func ShowWebNotification($sMessage, $sBgColor = "#4CAF50", $iDuration = 3000) ; Injects a ToolTip
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

	$oManager.ExecuteScript($sJS)
EndFunc   ;==>ShowWebNotification
;---------------------------------------------------------------------------------------
Func WM_SIZE($hWnd, $iMsg, $wParam, $lParam) ; Synchronizes WebView size with the GUI window
	If $wParam = 1 Then Return $GUI_RUNDEFMSG ; 1 = SIZE_MINIMIZED

	Local $iNewWidth = BitAND($lParam, 0xFFFF)
	Local $iNewHeight = BitShift($lParam, 16)

	If IsObj($oManager) Then
		; Make sure the dimensions are positive
		Local $iW = $iNewWidth - 0
		Local $iH = $iNewHeight - 65
		If $iW < 10 Then $iW = 10
		If $iH < 10 Then $iH = 10
		$oManager.Resize($iW, $iH)
	EndIf
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_SIZE
;---------------------------------------------------------------------------------------
Func WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg
	Local Static $hidURL = GUICtrlGetHandle($idURL)
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
Func _ErrFunc($oError) ; User's COM error function. Will be called if COM error occurs
	; Do anything here.
	ConsoleWrite(@ScriptName & " (" & $oError.scriptline & ") : ==> COM Error intercepted !" & @CRLF & _
			@TAB & "err.number is: " & @TAB & @TAB & "0x" & Hex($oError.number) & @CRLF & _
			@TAB & "err.windescription:" & @TAB & $oError.windescription & @CRLF & _
			@TAB & "err.description is: " & @TAB & $oError.description & @CRLF & _
			@TAB & "err.source is: " & @TAB & @TAB & $oError.source & @CRLF & _
			@TAB & "err.helpfile is: " & @TAB & $oError.helpfile & @CRLF & _
			@TAB & "err.helpcontext is: " & @TAB & $oError.helpcontext & @CRLF & _
			@TAB & "err.lastdllerror is: " & @TAB & $oError.lastdllerror & @CRLF & _
			@TAB & "err.scriptline is: " & @TAB & $oError.scriptline & @CRLF & _
			@TAB & "err.retcode is: " & @TAB & "0x" & Hex($oError.retcode) & @CRLF & @CRLF)
EndFunc   ;==>_ErrFunc
;---------------------------------------------------------------------------------------
Func _VersionChecker($sRequired = "1.0.0.0")
	;Local $sRequired = "1.2.0.0"

	; Create a temporary object to find its origin
	Local $oTemp = ObjCreate("NetWebView2.Manager")
	If Not IsObj($oTemp) Then
		MsgBox(16, "Error", "NetWebView2.Manager is not registered!")
		Exit
	EndIf

	; Get the TypeLib path from ObjName (Field 4)
	Local $sTlbPath = ObjName($oTemp, 4)

	; Convert .tlb path to .dll path
	Local $sDllPath = StringTrimRight($sTlbPath, 4) & ".dll"

	; Get the version of the actual DLL
	Local $sCurrent = FileGetVersion($sDllPath)

	ConsoleWrite("+> Found TLB: " & $sTlbPath & @CRLF)
	ConsoleWrite("+> Checking DLL: " & $sDllPath & @CRLF)
	ConsoleWrite("+> Current Version: " & $sCurrent & @CRLF)

	; Compare
	If _VersionCompare($sCurrent, $sRequired) = -1 Then
		MsgBox(16, "Update Required", _
				"NetWebView2Lib.dll is outdated!" & @CRLF & @CRLF & _
				"Path: " & $sDllPath & @CRLF & @CRLF & _
				"Required: " & $sRequired & @CRLF & _
				"Found: " & $sCurrent & @CRLF & @CRLF & _
				"Please rebuild the C# project and re-register.")
		Exit
	EndIf

	$oTemp = 0 ; Cleanup
EndFunc   ;==>_VersionChecker
;---------------------------------------------------------------------------------------
