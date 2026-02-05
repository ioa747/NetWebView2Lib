#AutoIt3Wrapper_Run_AU3Check=Y
#AutoIt3Wrapper_AU3Check_Stop_OnWarning=y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7

; Example_v2.0.0_AcceleratorKeyPressed.au3
; This example demonstrates how to intercept and block accelerator keys (like F5 and F12)
; using the OnAcceleratorKeyPressed event introduced in version v2.0.0-beta.1

#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>

; Register exit function to ensure clean WebView2 shutdown
OnAutoItExitRegister("_ExitApp")

; Global objects
Global $oWeb, $oJS
Global $oMyError = ObjEvent("AutoIt.Error", "_ErrFunc") ; COM Error Handler
Global $g_DebugInfo = True
Global $g_sProfilePath = @ScriptDir & "\UserDataFolder"
Global $hGUI

_Example_AcceleratorKeyBlocking()

Func _Example_AcceleratorKeyBlocking()
	$hGUI = GUICreate("WebView2 Accelerator Key Blocking (v2.0.0)", 1000, 600)

	$oWeb = ObjCreate("NetWebView2.Manager")
	If Not IsObj($oWeb) Then Return MsgBox(16, "Error", "WebView2 Library not registered!")

	; Register for WebView events (IWebViewEvents)
	ObjEvent($oWeb, "WebEvents_", "IWebViewEvents")

	; Initialize the WebView control
	$oWeb.Initialize(($hGUI), $g_sProfilePath, 0, 0, 1000, 600)

	; Block F5 (116) and F12 (123) AcceleratorKey!
	$oWeb.BlockedVirtualKeys = "116,123"

	Do
		Sleep(10)
	Until $oWeb.IsReady

	; Navigate to a public site to test keys
    $oWeb.Navigate("https://www.google.com")

	GUISetState(@SW_SHOW)

	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				$oWeb.Cleanup()
				Exit
		EndSwitch
	WEnd
EndFunc   ;==>_Example_AcceleratorKeyBlocking

#Region ; === EVENT HANDLERS ===

; Triggered when an accelerator key (like F5, F12, Ctrl+S) is pressed.
; $oArgs is an object implementing IWebView2AcceleratorKeyPressedEventArgs
Func WebEvents_OnAcceleratorKeyPressed($oSender, $hGUI, $oArgs)
	#forceref $oSender, $hGUI
	Switch $oArgs.VirtualKey
		Case 116
			ConsoleWrite("!> [OnAcceleratorKeyPressed] F5 was pressed and blocked pre-emptively." & @CRLF)
		Case 123
			ConsoleWrite("!> [OnAcceleratorKeyPressed] F12 was pressed and blocked pre-emptively." & @CRLF)
		Case Else
			ConsoleWrite("!> [OnAcceleratorKeyPressed] " & $oArgs.VirtualKey & " was pressed." & @CRLF)
	EndSwitch
EndFunc

; Handles general WebView2 messages
Func WebEvents_OnMessageReceived($oSender, $hGUI, $sMsg)
	#forceref $oSender, $hGUI
	ConsoleWrite("->[OnMessageReceived] : " & $sMsg & @CRLF)
	If StringInStr($sMsg, "INIT_READY") Then
		ConsoleWrite("+> [OnMessageReceived] WebView2 is ready." & @CRLF)
	EndIf
EndFunc   ;==>WebEvents_OnMessageReceived

#EndRegion ; === EVENT HANDLERS ===

#Region ; === UTILS ===
Func _ErrFunc($oError) ; Global COM Error Handler
	ConsoleWrite('@@ Line(' & $oError.scriptline & ') : COM Error Number: (0x' & Hex($oError.number, 8) & ') ' & $oError.windescription & @CRLF)
EndFunc   ;==>_ErrFunc

Func _ExitApp()
	If IsObj($oWeb) Then $oWeb.Cleanup()
	$oWeb = 0
	Exit
EndFunc   ;==>_ExitApp
#EndRegion ; === UTILS ===
