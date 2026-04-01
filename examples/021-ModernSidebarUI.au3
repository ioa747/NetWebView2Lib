; https:
;----------------------------------------------------------------------------------------
; Title...........: 021-ModernSidebarUI.au3
; Description.....: Injects a high-performance, Chromium-based Sidebar into a Win32 GUI using WebView2.
;                   This method bypasses GDI/Win32 rendering limitations, allowing for full CSS3 animations,
;                   Vector (SVG) icons, and 100% Color Emoji support.
; AutoIt Version..: 3.3.18.0   Author: ioa747           Script Version: 0.1
; Note............: Testet in Windows 11 Pro 25H2
;----------------------------------------------------------------------------------------
#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include "..\NetWebView2Lib.au3"

; 021-ModernSidebarUI.au3

Global $g_idMemo

_Example()

;---------------------------------------------------------------------------------------
Func _Example()
	Local $hGui = GUICreate("Modern Sidebar UI", 550, 410)
	GUISetBkColor(0x252526) ; Dark Background

	$g_idMemo = GUICtrlCreateEdit("", 160, 10, 370, 390, $WS_VSCROLL, 0)
	GUICtrlSetFont(-1, 11, 400, 0, "Courier New")
	GUICtrlSetColor(-1, 0xF0F0F0)
	GUICtrlSetBkColor(-1, 0x333333)

	; We create ONE WebView2 for the entire sidebar
	Local $oWebV2M = _NetWebView2_CreateManager()
	Local $oBridge = _NetWebView2_GetBridge($oWebV2M, "JS_Events_")

	; Initialize on the left side (0, 0, 140, 450)
	_NetWebView2_Initialize($oWebV2M, $hGui, @ScriptDir & "\UserData", 0, 0, 140, 410, True)

	; Constructing the HTML with all the buttons
	Local $sHTML = _GenerateSidebarHTML()
	_NetWebView2_NavigateToString($oWebV2M, $sHTML)

	GUISetState(@SW_SHOW)

	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				ExitLoop
		EndSwitch
	WEnd

	_NetWebView2_CleanUp($oWebV2M, $oBridge)
EndFunc   ;==>_Example
;---------------------------------------------------------------------------------------
Func _GenerateSidebarHTML() ; The function that creates the "Menu"
	Local $sCSS = "body { margin: 0; background: #252526; font-family: 'Segoe UI', sans-serif; overflow: hidden; padding: 10px; }" & _
			".btn { " & _
			"  width: 100%; padding: 12px; margin-bottom: 8px; border: none; border-radius: 6px; " & _
			"  background: #333; color: white; text-align: left; cursor: pointer; font-size: 15px; " & _
			"  transition: 0.2s; display: flex; align-items: center; " & _
			"} " & _
			".btn:hover { background: #444; transform: translateX(5px); } " & _
			".btn span { margin-right: 10px; font-size: 18px; }"

	Local $sHTML = "<html><head><style>" & $sCSS & "</style></head><body>"

	Local $aLabels[7] = ["🏆 Trophy", "🎯 Target", "⚠️ Warning", "😎 Cool", "👉 Select", "🌏 World", "🚧 Work"]

	For $i = 0 To 6
		$sHTML &= "<button class='btn' onclick='window.chrome.webview.postMessage(""BTN_CLICKED:" & $i & """)'>" & _
				"<span>" & StringLeft($aLabels[$i], 2) & "</span>" & StringTrimLeft($aLabels[$i], 2) & "</button>"
	Next

	$sHTML &= "</body></html>"
	Return $sHTML
EndFunc   ;==>_GenerateSidebarHTML
;---------------------------------------------------------------------------------------
Volatile Func JS_Events_OnMessageReceived($oWebV2M, $hGui, $sMessage) ; The Bridge that "catches" clicks
	#forceref $oWebV2M, $hGui
	If StringLeft($sMessage, 12) = "BTN_CLICKED:" Then
		Local $sIndex = StringTrimLeft($sMessage, 12)
		; Here you can call any AutoIt function
		; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		MemoWrite("Index button pressed: " & $sIndex)
	EndIf
EndFunc   ;==>JS_Events_OnMessageReceived
;---------------------------------------------------------------------------------------
Func MemoWrite($sMessage) ; Write a line to the memo control
	GUICtrlSetData($g_idMemo, $sMessage & @CRLF, 1)
EndFunc   ;==>MemoWrite
;---------------------------------------------------------------------------------------
