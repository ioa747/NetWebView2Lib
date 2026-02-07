#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>

; Register exit function to ensure clean WebView2 shutdown
OnAutoItExitRegister("_ExitApp")

; Global objects
Global $oWeb, $oJS
Global $oMyError = ObjEvent("AutoIt.Error", "_ErrFunc") ; COM Error Handler
Global $g_DebugInfo = True
Global $sProfileDirectory = @ScriptDir & "\UserDataFolder"
Global $hGUI

_Example_HTTP_Tracking()

Func _Example_HTTP_Tracking()
	$hGUI = GUICreate("WebView2 HTTP Status Tracker", 1000, 600)

	$oWeb = ObjCreate("NetWebView2.Manager")
	If Not IsObj($oWeb) Then Return MsgBox(16, "Error", "WebView2 Library not registered!")
	ObjEvent($oWeb, "WebEvents_", "IWebViewEvents")

	; Initialize JavaScript Bridge
	$oJS = $oWeb.GetBridge()
	ObjEvent($oJS, "JavaScript_", "IBridgeEvents")

	; 2. Ρύθμιση του HTTP Tracking
    $oWeb.HttpStatusCodeEventsEnabled = True

	; Φιλτράρισμα μόνο για το Main Document
	; Πολύ σημαντικό για να μην κολλάει το GUI από εκατοντάδες αιτήματα (εικόνες, scripts κλπ)
    $oWeb.HttpStatusCodeDocumentOnly = True

	$oWeb.Initialize(($hGUI), $sProfileDirectory, 0, 0, 1000, 600)

	Do
		Sleep(10)
	Until $oWeb.IsReady

	; Δοκιμή με μια σελίδα που δεν υπάρχει για να δούμε το 404
    $oWeb.Navigate("https://google.com/this-page-does-not-exist")
;~ 	$oWeb.Navigate("https://google.com")

	GUISetState(@SW_SHOW)

	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				$oWeb.Cleanup()
				Exit
		EndSwitch
	WEnd
EndFunc   ;==>_Example_HTTP_Tracking

#Region ; === EVENT HANDLERS ===

; Handles native WebView2 events
Func WebEvents_OnMessageReceived($sMsg)
	__DW("+++ [WebEvents]: " & (StringLen($sMsg) > 150 ? StringLeft($sMsg, 150) & "..." : $sMsg) & @CRLF, 0)
	Local $iSplitPos = StringInStr($sMsg, "|")
	Local $sCommand = $iSplitPos ? StringStripWS(StringLeft($sMsg, $iSplitPos - 1), 3) : $sMsg
	Local $sData = $iSplitPos ? StringTrimLeft($sMsg, $iSplitPos) : ""
	Local $aParts

	Switch $sCommand
		Case "INIT_READY"
			$oWeb.ExecuteScript('window.chrome.webview.postMessage(JSON.stringify({ "type": "COM_TEST", "status": "OK" }));')

		Case "WINDOW_RESIZED"
			$aParts = StringSplit($sData, "|")
			If $aParts[0] >= 2 Then
				Local $iW = Int($aParts[1]), $iH = Int($aParts[2])
				; Filter minor resize glitches
				If $iW > 50 And $iH > 50 Then __DW("WINDOW_RESIZED : " & $iW & "x" & $iH & @CRLF)
			EndIf
	EndSwitch
EndFunc   ;==>WebEvents_OnMessageReceived

; Handles custom messages from JavaScript (window.chrome.webview.postMessage)
Func JavaScript_OnMessageReceived($sMsg)
	__DW(">>> [JavaScript]: " & (StringLen($sMsg) > 150 ? StringLeft($sMsg, 150) & "..." : $sMsg) & @CRLF, 0)
	Local $sFirstChar = StringLeft($sMsg, 1)

	; 1. JSON Messaging
	If $sFirstChar = "{" Or $sFirstChar = "[" Then
		__DW("+> : Processing JSON Messaging..." & @CRLF)
		Local $oJson = ObjCreate("NetJson.Parser")
		If Not IsObj($oJson) Then Return ConsoleWrite("!> Error: Failed to create NetJson object." & @CRLF)

		$oJson.Parse($sMsg)
		Local $sJobType = $oJson.GetTokenValue("type")

		Switch $sJobType
			Case "COM_TEST"
				__DW("- COM_TEST Confirmed: " & $oJson.GetTokenValue("status") & @CRLF)
		EndSwitch

	Else
		; 2. Legacy / Native Pipe-Delimited Messaging
		__DW("+> : Legacy / Native Pipe-Delimited Messaging..." & @CRLF, 0)
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
				__DW("- Status: Legacy COM_TEST: " & $sData & @CRLF)

			Case "ERROR"
				__DW("! Status: " & $sData & @CRLF)
		EndSwitch
	EndIf
EndFunc   ;==>JavaScript_OnMessageReceived

; OnWebResourceResponseReceived
Func WebEvents_OnWebResourceResponseReceived($iStatusCode, $sReasonPhrase, $sRequestUrl)
    Local $sLog = StringFormat("! [HTTP %d] | %s | URL: %s", $iStatusCode, $sReasonPhrase, $sRequestUrl)
    ConsoleWrite($sLog & @CRLF)

    ; Management example:
    If $iStatusCode >= 400 Then
        __DW("Navigation Issue detected on: " & $sRequestUrl)

        ; If it is the main URL and not an iframe/sub-resource
        If $iStatusCode = 404 Then
            ; We use a small Ad-hoc HTML for the error
            Local $sErrorHTML = "<html><body style='background:#222;color:#ff4c4c;text-align:center;padding-top:50px;'>" & _
                                "<h1>😟 Navigation Error " & $iStatusCode & " 🫢</h1>" & _
                                "<p>The requested URL was not found.</p>" & _
                                "<button onclick='history.back()'>Go Back</button></body></html>"

            $oWeb.NavigateToString($sErrorHTML)
        EndIf
    EndIf
EndFunc   ;==>WebEvents_OnWebResourceResponseReceived

#EndRegion ; === EVENT HANDLERS ===

#Region ; === UTILS ===
Func _ErrFunc($oError) ; Global COM Error Handler
	ConsoleWrite('@@ Line(' & $oError.scriptline & ') : COM Error Number: (0x' & Hex($oError.number, 8) & ') ' & $oError.windescription & @CRLF)
EndFunc   ;==>_ErrFunc

; Debug Write utility
Func __DW($sString, $iErrorNoLineNo = 1, $iLine = @ScriptLineNumber, $iError = @error, $iExtended = @extended)
	If Not $g_DebugInfo Then Return SetError($iError, $iExtended, 0)
	Local $iReturn
	If $iErrorNoLineNo = 1 Then
		If $iError Then
			$iReturn = ConsoleWrite("@@(" & $iLine & ") :: @error:" & $iError & ", @extended:" & $iExtended & ", " & $sString)
		Else
			$iReturn = ConsoleWrite("+>(" & $iLine & ") :: " & $sString)
		EndIf
	Else
		$iReturn = ConsoleWrite($sString)
	EndIf
	Return SetError($iError, $iExtended, $iReturn)
EndFunc   ;==>__DW

Func _NetJson_New($sInitialJson = "{}")
	Local $oParser = ObjCreate("NetJson.Parser")
	If Not IsObj($oParser) Then Return SetError(1, 0, 0)
	If $sInitialJson <> "" Then $oParser.Parse($sInitialJson)
	Return $oParser
EndFunc   ;==>_NetJson_New

Func _ExitApp()
	If IsObj($oWeb) Then $oWeb.Cleanup()
	$oWeb = 0
	$oJS = 0
	Exit
EndFunc   ;==>_ExitApp
#EndRegion ; === UTILS ===
