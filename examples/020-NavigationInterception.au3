#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include "..\NetWebView2Lib.au3"

;~ $_g_bNetWebView2_DebugInfo = False

ConsoleWrite("! MicrosoftEdgeWebview2 : version check: " & _NetWebView2_IsAlreadyInstalled() & ' ERR=' & @error & ' EXT=' & @extended & @CRLF)

; 020-NavigationInterception.au3
; ## Navigation Interception & Cancellation
; Description: Shows how to use the new NavigationStarting event object to
; intercept specific links (e.g., https://) and cancel them,
; redirecting them to the default system browser instead.

_MainGUI()

Func _MainGUI()
	Local $hGUI = GUICreate("WebView2 Navigation Interception", 640, 400, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPCHILDREN))

	; Create and Initialize WebView2
	Local $oWebV2M = _NetWebView2_CreateManager("", "Web_")
	If @error Then
		ConsoleWrite("!> Error: Failed to create $oWebV2M object , error: " & @error & ", extended:" & @extended & @CRLF)
		MsgBox(16, "Error", "Failed to create $oWebV2M object!")
		Exit
	EndIf

	_NetWebView2_Initialize($oWebV2M, $hGUI, @ScriptDir & "\NetWebView2Lib-UserDataFolder", 0, 0, 0, 0, True, True, 1, "0x2B2B2B", False)

	Local $sHtml = '<html><head><style>' & _
			'body { background-color: #1e1e1e; color: white; font-family: Arial; }' & _
			'a { color: #4db8ff; text-decoration: none; }' & _
			'a:hover { color: #ffcc00; text-decoration: underline; }' & _
			'</style></head><body>' & _
			'<h1>Navigation Interception Demo</h1>' & _
			'<p>In this demo, all external links (starting with http) are intercepted.</p>' & _
			'<ul>' & _
			'<li><a href="https://www.google.com">Google (Will open in Default Browser)</a></li>' & _
			'<li><a href="https://www.bing.com">Bing (Will open in Default Browser)</a></li>' & _
			'<li><a href="local_page.html">Local Link (Will stay in WebView)</a></li>' & _
			'</ul>' & _
			'</body></html>'

	_NetWebView2_NavigateToString($oWebV2M, $sHtml)
	GUISetState(@SW_SHOW)

	While 1
		Switch GUIGetMsg()
			Case -3 ;$GUI_EVENT_CLOSE
				ExitLoop
		EndSwitch
	WEnd

	GUIDelete($hGUI)
	_NetWebView2_CleanUp($oWebV2M, $hGUI)
	Exit
EndFunc   ;==>_MainGUI

#Region ; === EVENT HANDLERS ===
Volatile Func Web_OnNavigationStarting($oSender, $hParent, $oArgs)
	#forceref $oSender, $hParent

	Local $sURL = $oArgs.Uri
	ConsoleWrite("-> Navigation Starting to: " & (StringLen($sURL) > 100 ? StringLeft($sURL, 100) & "..." : $sURL) & @CRLF)

	; If URL starts with "http", cancel internal navigation and ShellExecute
	If StringLeft($sURL, 4) = "http" Then
		ConsoleWrite("!!! Intercepting External Link: " & $sURL & @CRLF)
		$oArgs.Cancel = True ; Cancel navigation in WebView2
		ShellExecute($sURL)  ; Open in default browser
	EndIf
EndFunc   ;==>Web_OnNavigationStarting

Volatile Func Web_OnNavigationCompleted($oSender, $hParent, $bSuccess, $iError)
	#forceref $oSender, $hParent, $bSuccess, $iError
	ConsoleWrite(">> Navigation Completed. Success: " & $bSuccess & @CRLF)
EndFunc   ;==>Web_OnNavigationCompleted
#EndRegion ; === EVENT HANDLERS ===
