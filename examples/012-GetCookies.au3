#WIP - this Example is imported from 1.5.0 UDF - and is in "WORK IN PROGRESS" state

#AutoIt3Wrapper_UseX64=y
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <Array.au3>
#include <GuiEdit.au3>
#include <Misc.au3>
#include "..\NetWebView2Lib.au3"

; 012-GetCookies.au3

_VersionChecker("1.2.0.0") ; DLL Version Check

; Global objects handler for COM objects
Global $oWebV2M, $oJSBridge
Global $oMyError = ObjEvent("AutoIt.Error", _ErrFunc)

; Global variables for data management
Global $hGUI, $idURL, $idStatusLabel
Global $g_bURLFullSelected = False
Global $g_bAutoRestoreSession = False

_Example()

Func _Example()
	ConsoleWrite("! MicrosoftEdgeWebview2 : version check: " & _NetWebView2_IsAlreadyInstalled() & ' ERR=' & @error & ' EXT=' & @extended & @CRLF)

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

	; Initialize WebView2 Manager and register events
	$oWebV2M = _NetWebView2_CreateManager("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0", _
	"WebView_", "--mute-audio")
	If @error Then Return SetError(@error, @extended, $oWebV2M)

	; create JavaScript Bridge object
	$oJSBridge = _NetWebView2_GetBridge($oWebV2M, "Bridge_")
	If @error Then Return SetError(@error, @extended, $oWebV2M)

	; initialize browser - put it on the GUI
	Local $sProfileDirectory = @ScriptDir & "\NetWebView2Lib-UserDataFolder"
	_NetWebView2_Initialize($oWebV2M, $hGUI, $sProfileDirectory, 0, 45, 1285, 800, True, True, 1, "0x2B2B2B")

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
					$oWebV2M.ClearBrowserData()
					ShowWebNotification("Browser history & cookies cleared!", "#f44336")
				EndIf

			Case $idBtnSaveSession
				$oWebV2M.GetCookies(GUICtrlRead($idURL))

			Case $idBtnRestoreSession
				$sURL = GUICtrlRead($idURL)
				Local $sDomainOnly = StringRegExpReplace($sURL, "https?://([^/]+).*", "$1")
				_RestoreSession($sDomainOnly)

			Case $idBtnSetZoom
				$oWebV2M.SetZoom(1.5) ; Zoom to 150%
				ShowWebNotification("Zoom: 150%", "#2196F3")

			Case $idBtnResetZoom
				$oWebV2M.ResetZoom() ; Reset to 100%
				ShowWebNotification("Zoom: 100%", "#4CAF50")

			Case $idBtnGoBack
				$oWebV2M.GoBack()

			Case $idBtnGoForward
				$oWebV2M.GoForward()

			Case $idBtnStop
				$oWebV2M.Stop()
				GUICtrlSetData($idStatusLabel, "Stop")

			Case $idReload
				$oWebV2M.Reload()
				GUICtrlSetData($idStatusLabel, "Reload")

			Case $idURL
				_NetWebView2_Navigate($oWebV2M, GUICtrlRead($idURL))
				GUICtrlSetData($idStatusLabel, "Navigate: " & GUICtrlRead($idURL))

		EndSwitch

		If $g_bURLFullSelected Then
			$g_bURLFullSelected = False
			GUICtrlSendMsg($idURL, $EM_SETSEL, 0, -1)
		EndIf

	WEnd

	_NetWebView2_CleanUp($oWebV2M, $oJSBridge)
	ConsoleWrite("--> Application exited cleanly." & @CRLF)

EndFunc   ;==>_Example
;---------------------------------------------------------------------------------------
Func Bridge_OnMessageReceived($oWebV2M, $hGUI, $sMessage)
	#forceref $oWebV2M, $hGUI
	; Handles data received from the JavaScript 'postMessage'
	ConsoleWrite("> [JS MESSAGE]: " & $sMessage & @CRLF)
EndFunc   ;==>Bridge_OnMessageReceived
;---------------------------------------------------------------------------------------
Func WebView_OnMessageReceived($oWebV2M, $hGUI, $sMessage)
	#forceref $oWebV2M, $hGUI
	ConsoleWrite("> [CORE EVENT]: " & $sMessage & @CRLF)
	Local Static $sCurentURL = "", $sLastRestoredDomain = ""
	Local $sDomain

	; Separating messages that have parameters (e.g. TITLE_CHANGED|...)
	Local $aParts = StringSplit($sMessage, "|")
	Local $sCommand = StringStripWS($aParts[1], 3)

	Switch $sCommand
		Case "INIT_READY"
			_NetWebView2_Navigate($oWebV2M, GUICtrlRead($idURL))
			GUISetState(@SW_SHOW, $hGUI)

		Case "NAV_STARTING"
			$sCurentURL = GUICtrlRead($idURL)
			$sDomain = StringRegExpReplace($sCurentURL, "https?://([^/]+).*", "$1")

			If $g_bAutoRestoreSession And $sDomain <> $sLastRestoredDomain Then
				ConsoleWrite(">>> Auto-Restore: Initializing for " & $sDomain & @CRLF)
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
				$oWebV2M.WebViewSetFocus() ; We give focus to the browser
			EndIf

		Case "COOKIES_B64"
			; Ensure we have enough parts (Command|URL|Data)
			If $aParts[0] > 2 Then
				_ProcessCookies($aParts[2], $aParts[3])
			EndIf

		Case "PDF_SUCCESS"
			MsgBox($MB_ICONINFORMATION, "Success", "PDF Report saved successfully!")


		Case "ERROR", "NAV_ERROR"
			Local $sErr = ($aParts[0] > 1) ? $aParts[2] : "Unknown"
			GUICtrlSetData($idStatusLabel, "Status: Error " & $sErr)
			MsgBox(16, "WebView2 Error", $sMessage)
	EndSwitch

EndFunc   ;==>WebView_OnMessageReceived
;---------------------------------------------------------------------------------------
Func _ProcessCookies($sURL, $sBase64)
	Local $oJson = _NetJson_CreateParser()
	If @error Then Return ConsoleWrite("!!! Erorr CreateParser" & @CRLF)

	Local $sDomainOnly = StringRegExpReplace($sURL, "https?://([^/]+).*", "$1")
	Local $sDecodedJson = $oWebV2M.DecodeB64($sBase64)  ; _Base64Decode($sBase64)
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
		ConsoleWrite(">>> Clean session saved (" & $iFoundCount & " cookies) to: " & $sLogFile & @CRLF)
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
	ConsoleWrite(">>> Restoring " & $iTotal & " cookies for " & $sDomain & "..." & @CRLF)

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
			$oWebV2M.AddCookie($sRawName, $sRawValue, $sRawDom, $sRawPath)

			ConsoleWrite(StringFormat("  [%d] %-15s | Domain: %-15s | Val: %s...\n", _
					$i, $sRawName, $sDomain, StringLeft($sRawValue, 10)))
			$iInjected += 1
		EndIf
	Next

	; Apply changes if cookies were injected
	If $iInjected > 0 Then
		$oWebV2M.Reload()
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

	$oWebV2M.ExecuteScript($sJS)
EndFunc   ;==>ShowWebNotification
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
	ConsoleWrite('@@ Line(' & $oError.scriptline & ') : COM Error Number: (0x' & Hex($oError.number, 8) & ') ' & $oError.windescription & @CRLF)
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

	ConsoleWrite("++> Found TLB: " & $sTlbPath & @CRLF)
	ConsoleWrite("++> Checking DLL: " & $sDllPath & @CRLF)
	ConsoleWrite("++> Current Version: " & $sCurrent & @CRLF)

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
