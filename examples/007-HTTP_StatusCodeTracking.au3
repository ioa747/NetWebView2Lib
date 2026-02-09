#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include "..\NetWebView2Lib.au3"

; Global objects
Global $oMyError = ObjEvent("AutoIt.Error", "_ErrFunc") ; COM Error Handler

_Example_HTTP_Tracking()

Func _Example_HTTP_Tracking()
	Local $hGUI = GUICreate("WebView2 HTTP Status Tracker", 1000, 600)

	; Initialize WebView2 Manager and register events
	Local $oWebV2M = _NetWebView2_CreateManager("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0", "WebEvents_")
	If @error Then Return SetError(@error, @extended, $oWebV2M)

	; create JavaScript Bridge object
	Local $oJSBridge = _NetWebView2_GetBridge($oWebV2M, "JavaScript_")
	If @error Then Return SetError(@error, @extended, $oWebV2M)

	; initialize browser - put it on the GUI
	Local $sProfileDirectory = @ScriptDir & "\NetWebView2Lib-UserDataFolder"
	_NetWebView2_Initialize($oWebV2M, $hGUI, $sProfileDirectory, 0, 0, 0, 0, True, True, True, 1.2, "0x2B2B2B")

	; Ρύθμιση του HTTP Tracking
	$oWebV2M.HttpStatusCodeEventsEnabled = True

	; Φιλτράρισμα μόνο για το Main Document
	; Πολύ σημαντικό για να μην κολλάει το GUI από εκατοντάδες αιτήματα (εικόνες, scripts κλπ)
	$oWebV2M.HttpStatusCodeDocumentOnly = True


	; Δοκιμή με μια σελίδα που δεν υπάρχει για να δούμε το 404
;~     $oWebV2M.Navigate("https://google.com/this-page-does-not-exist")
	_NetWebView2_Navigate($oWebV2M, "https://google.com/this-page-does-not-exist")
;~ 	$oWebV2M.Navigate("https://google.com")

	GUISetState(@SW_SHOW)

	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				ExitLoop
		EndSwitch
	WEnd

	_NetWebView2_CleanUp($oWebV2M, $oJSBridge)

EndFunc   ;==>_Example_HTTP_Tracking

#Region ; === EVENT HANDLERS ===
; Handles native WebView2 events
Func WebEvents_OnMessageReceived($oWebV2M, $hGUI, $sMsg)
	ConsoleWrite(">>> [WebEvents]: " & (StringLen($sMsg) > 150 ? StringLeft($sMsg, 150) & "..." : $sMsg) & @CRLF)
	Local $iSplitPos = StringInStr($sMsg, "|")
	Local $sCommand = $iSplitPos ? StringStripWS(StringLeft($sMsg, $iSplitPos - 1), 3) : $sMsg
	Local $sData = $iSplitPos ? StringTrimLeft($sMsg, $iSplitPos) : ""
	Local $aParts

	Switch $sCommand
		Case "INIT_READY"
			_NetWebView2_ExecuteScript($oWebV2M, _
					'window.chrome.webview.postMessage(JSON.stringify({ "type": "COM_TEST", "status": "OK" }));', _
					$NETWEBVIEW2_EXECUTEJS_MODE0_FIREANDFORGET)

	EndSwitch
EndFunc   ;==>WebEvents_OnMessageReceived

; Handles custom messages from JavaScript (window.chrome.webview.postMessage)
Func JavaScript_OnMessageReceived($oWebV2M, $hGUI, $sMsg)
	#forceref $oWebV2M
	ConsoleWrite(">>> [JavaScript]: " & (StringLen($sMsg) > 150 ? StringLeft($sMsg, 150) & "..." : $sMsg) & @CRLF)
	Local $sFirstChar = StringLeft($sMsg, 1)

	; 1. JSON Messaging
	If $sFirstChar = "{" Or $sFirstChar = "[" Then
		ConsoleWrite("+>>> : Processing JSON Messaging..." & @CRLF)
		Local $oJson = _NetJson_CreateParser($sMsg)
		If @error Then Return ConsoleWrite("!> Error: Failed to create NetJson object." & @CRLF)

		Local $sJobType = $oJson.GetTokenValue("type")
		Switch $sJobType
			Case "COM_TEST"
				ConsoleWrite("-- COM_TEST Confirmed: " & $oJson.GetTokenValue("status") & @CRLF)
		EndSwitch

	Else
		; 2. Legacy / Native Pipe-Delimited Messaging
		ConsoleWrite("+>>> : Legacy / Native Pipe-Delimited Messaging..." & @CRLF)
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

			Case "ERROR"
				ConsoleWrite("! Status: " & $sData & @CRLF)
		EndSwitch
	EndIf
EndFunc   ;==>JavaScript_OnMessageReceived

; OnWebResourceResponseReceived
Func WebEvents_OnWebResourceResponseReceived($oWebV2M, $hGUI, $iStatusCode, $sReasonPhrase, $sRequestUrl)
	Local $sLog = StringFormat("! [HTTP %d] | %s | URL: %s", $iStatusCode, $sReasonPhrase, $sRequestUrl)
	ConsoleWrite($sLog & @CRLF)

	Local $oGuard = ObjEvent("AutoIt.Error", "_NetWebView2_SilentErrorHandler")
	#forceref $oGuard

	; Management example:
	If $iStatusCode >= 400 Then
		ConsoleWrite("Navigation Issue detected on: " & @CRLF & $sRequestUrl)

		; If it is the main URL and not an iframe/sub-resource
		If $iStatusCode = 404 Then
			; We use a small Ad-hoc HTML for the error
			Local $sErrorHTML = "<html><body style='background:#222;color:#ff4c4c;text-align:center;padding-top:50px;'>" & _
					"<h1>😟 Navigation Error " & $iStatusCode & " 🫢</h1>" & _
					"<p>The requested URL was not found.</p>" & _
					"<button onclick='history.back()'>Go Back</button></body></html>"

			; direct - call without LoadWait (ms matters)
			$oWebV2M.NavigateToString($sErrorHTML)
		EndIf
	EndIf
EndFunc   ;==>WebEvents_OnWebResourceResponseReceived

#EndRegion ; === EVENT HANDLERS ===

