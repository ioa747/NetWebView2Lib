#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Run_AU3Check=Y
#AutoIt3Wrapper_AU3Check_Stop_OnWarning=y

; 022-ConfigurableThrottling.au3

#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include "..\NetWebView2Lib.au3"

Global $iReceivedCount = 0
Global $sCurrentPhase = "No Throttling"

$_g_bNetWebView2_DebugInfo = False

Main()

Func Main()
	Local $oMyError = ObjEvent("AutoIt.Error", __NetWebView2_COMErrFunc)
	#forceref $oMyError

	; Create the UI
	Local $hGUI = GUICreate("WebView2 Throttling Test", 800, 600)
	GUISetState(@SW_SHOW, $hGUI)

	; Initialize WebView2 Manager with throttling disabled (0ms)
	Local $oWebV2M = _NetWebView2_CreateManager("", "", "--disable-gpu", False, 0)
	If @error Then Return MsgBox(16, "Error", "CreateManager failed: " & @error)

	; Initialize JavaScript Bridge
	Local $oJSBridge = _NetWebView2_GetBridge($oWebV2M, "_BridgeEventsHandler_")
	If @error Then Return MsgBox(16, "Error", "GetBridge failed: " & @error)

	Local $sProfileDirectory = @ScriptDir & "\NetWebView2Lib-UserDataFolder"
	_NetWebView2_Initialize($oWebV2M, $hGUI, $sProfileDirectory, 0, 0, 0, 0, True, True, 1.0, "0x2B2B2B", False)
	If @error Then Return MsgBox(16, "Error", "Initialize failed: " & @error)

	; Navigate to our test HTML content
	_NetWebView2_NavigateToString($oWebV2M, GetTestHTML())

	_NetWebView2_ExecuteScript($oWebV2M, "window.chrome.webview.postMessage('READY');")

	; Main Loop
	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				ExitLoop
		EndSwitch
	WEnd

	GUIDelete($hGUI)
	_NetWebView2_CleanUp($oWebV2M, $oJSBridge)
EndFunc   ;==>Main

; MY EVENT HANDLER: Bridge (JavaScript Messages)
Volatile Func _BridgeEventsHandler_OnMessageReceived($oWebV2M, $hGUI, $sMessage)
	ConsoleWrite("$sMessage=" & $sMessage & @CRLF)
	#forceref $hGUI

	; 1. Check Phase Change
	If StringLeft($sMessage, 6) == "PHASE:" Then
		$sCurrentPhase = StringTrimLeft($sMessage, 6)
		$iReceivedCount = 0
		ConsoleWrite("+++ Starting Phase: " & $sCurrentPhase & @CRLF)
		Return
	EndIf

	; 2. Check Test End
	If $sMessage = "TEST_END" Then
		ConsoleWrite(">>> Phase '" & $sCurrentPhase & "' Complete. Received count: " & $iReceivedCount & " / 100." & @CRLF)
		Return
	EndIf

	; 3. Message Count
	If StringLeft($sMessage, 4) == "MSG_" Then
		$iReceivedCount += 1

		; If we are in Phase 1 and we reached 100, we automatically return to Phase 2
		If $iReceivedCount = 100 And $sCurrentPhase = "No Throttling" Then
			ConsoleWrite(">>> Phase 'No Throttling' Complete: All 100/100 messages received successfully!" & @CRLF)
			$oWebV2M.ThrottlingIntervalMs = 20
			ConsoleWrite(">>> Dynamically updated ThrottlingIntervalMs = " & $oWebV2M.ThrottlingIntervalMs & "ms" & @CRLF)
			_NetWebView2_ExecuteScript($oWebV2M, "runThrottledTest();")
		EndIf
	EndIf

EndFunc   ;==>_BridgeEventsHandler_OnMessageReceived

Func GetTestHTML()
	Local $sTxt = ""
	$sTxt &= "<!DOCTYPE html>" & @CRLF
	$sTxt &= "<html lang=""en"">" & @CRLF
	$sTxt &= "<head>" & @CRLF
	$sTxt &= "    <meta charset=""utf-8"">" & @CRLF
	$sTxt &= "    <title>Fixed Throttling Test</title>" & @CRLF
	$sTxt &= "    <style>" & @CRLF
	$sTxt &= "        body { font-family: ""Segoe UI"", sans-serif; background: #1e1e1e; color: #e0e0e0; padding: 30px; text-align: center; }" & @CRLF
	$sTxt &= "        .btn { padding: 12px 24px; font-size: 16px; background: #0078d4; color: white; border: none; border-radius: 4px; cursor: pointer; margin: 10px; }" & @CRLF
	$sTxt &= "        .btn:hover { background: #005a9e; }" & @CRLF
	$sTxt &= "        #status-log { margin-top: 20px; padding: 10px; background: #2d2d2d; border-radius: 4px; display: inline-block; min-width: 300px; }" & @CRLF
	$sTxt &= "    </style>" & @CRLF
	$sTxt &= "</head>" & @CRLF
	$sTxt &= "<body>" & @CRLF
	$sTxt &= "" & @CRLF
	$sTxt &= "    <h1>WebView2 Bridge Message Throttling Test</h1>" & @CRLF
	$sTxt &= "    <button class=""btn"" onclick=""startTest()"">Start Throttling Test</button>" & @CRLF
	$sTxt &= "    <div id=""status-log"">Status: Ready to test</div>" & @CRLF
	$sTxt &= "" & @CRLF
	$sTxt &= "    <script>" & @CRLF
	$sTxt &= "        function safePost(msg) {" & @CRLF
	$sTxt &= "            if (window.chrome && window.chrome.webview && typeof window.chrome.webview.postMessage === ""function"") {" & @CRLF
	$sTxt &= "                window.chrome.webview.postMessage(msg);" & @CRLF
	$sTxt &= "            }" & @CRLF
	$sTxt &= "        }" & @CRLF
	$sTxt &= "" & @CRLF
	$sTxt &= "        // English: Enhanced loop that triggers termination ONLY when done" & @CRLF
	$sTxt &= "        function sendBulkMessages(isThrottled = false) {" & @CRLF
	$sTxt &= "            let i = 1;" & @CRLF
	$sTxt &= "            function sendNext() {" & @CRLF
	$sTxt &= "                if (i <= 100) {" & @CRLF
	$sTxt &= "                    safePost(""MSG_"" + i);" & @CRLF
	$sTxt &= "                    i++;" & @CRLF
	$sTxt &= "                    setTimeout(sendNext, 0);" & @CRLF
	$sTxt &= "                } else {" & @CRLF
	$sTxt &= "                    // English: Loop finished! If we are in Phase 2, send TEST_END safely" & @CRLF
	$sTxt &= "                    if (isThrottled) {" & @CRLF
	$sTxt &= "                        setTimeout(() => {" & @CRLF
	$sTxt &= "                            safePost(""TEST_END"");" & @CRLF
	$sTxt &= "                            document.getElementById(""status-log"").innerText = ""Test Finished!"";" & @CRLF
	$sTxt &= "                        }, 100); // English: 100ms ensures we are way outside the 20ms throttling window" & @CRLF
	$sTxt &= "                    }" & @CRLF
	$sTxt &= "                }" & @CRLF
	$sTxt &= "            }" & @CRLF
	$sTxt &= "            sendNext();" & @CRLF
	$sTxt &= "        }" & @CRLF
	$sTxt &= "" & @CRLF
	$sTxt &= "        function startTest() {" & @CRLF
	$sTxt &= "            document.getElementById(""status-log"").style.color = ""#00ff00"";" & @CRLF
	$sTxt &= "            document.getElementById(""status-log"").innerText = ""Running Phase 1: No Throttling..."";" & @CRLF
	$sTxt &= "            safePost(""PHASE:No Throttling"");" & @CRLF
	$sTxt &= "            setTimeout(() => { sendBulkMessages(false); }, 50);" & @CRLF
	$sTxt &= "        }" & @CRLF
	$sTxt &= "" & @CRLF
	$sTxt &= "        function runThrottledTest() {" & @CRLF
	$sTxt &= "            setTimeout(() => {" & @CRLF
	$sTxt &= "                document.getElementById(""status-log"").innerText = ""Running Phase 2: Throttling Active..."";" & @CRLF
	$sTxt &= "                safePost(""PHASE:Throttling Active"");" & @CRLF
	$sTxt &= "                setTimeout(() => { sendBulkMessages(true); }, 50);" & @CRLF
	$sTxt &= "            }, 500);" & @CRLF
	$sTxt &= "        }" & @CRLF
	$sTxt &= "    </script>" & @CRLF
	$sTxt &= "</body>" & @CRLF
	$sTxt &= "</html>"
	Return $sTxt
EndFunc   ;==>GetTestHTML

