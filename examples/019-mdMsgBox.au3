#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=
#AutoIt3Wrapper_Outfile=mdMsgBox.exe
#AutoIt3Wrapper_Res_Description=Markdown Modern MsgBox (WebView2)
#AutoIt3Wrapper_Res_Fileversion=0.0.0.3
#AutoIt3Wrapper_Res_ProductName=MarkdownMsgBox
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

;~ #AutoIt3Wrapper_UseX64=y

#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include "..\NetWebView2Lib.au3"

;----------------------------------------------------------------------------------------
; Title...........: 019-mdMsgBox.au3
; Description.....: Markdown Modern MsgBox (WebView2)
; AutoIt Version..: 3.3.18.0   Author: ioa747           Script Version: 0.3
; Note............: Testet in Windows 11 Pro 25H2       Date:20/03/2026
; ## The dependencies are in the folder @ScriptDir & "\JS_Lib"
; 🏆 Thanks to https://github.com/markedjs/marked/
; 🏆 Thanks to https://fontawesome.com/search?ic=free-collection
;----------------------------------------------------------------------------------------

$_g_bNetWebView2_DebugInfo = False ; NetWebView2 DebugInfo

DllCall("User32.dll", "bool", "SetProcessDpiAwarenessContext", "int_ptr", -4) ; (-4 = Per Monitor V2)

Global $g_hGUI, $g_hBkColor, $g_hTxtColor, $g_hFootColor, $g_iMaxWidth, $g_iMaxHeight, $g_iLeft, $g_iTop, $g_sTitle, $g_sText, _
		$g_sButtons, $g_sBtnDefColor, $g_sBtnColor, $g_sBtnResult, $g_aBtn, $g_iTimer, $g_iTopMost, $g_hParent, $g_sFile

$g_hGUI = 0
$g_hBkColor = Hex(0x2B2B2B, 6)     ; Dark slate gray
$g_hTxtColor = Hex(0xE0E0E0, 6)    ; Gainsboro
$g_hFootColor = Hex(0x1E1E1E, 6)   ; Black
$g_iMaxWidth = 400
$g_iMaxHeight = 800
$g_iLeft = -1
$g_iTop = -1
$g_sTitle = "Markdown MsgBox"
$g_sText = ""
$g_sButtons = "OK"
$g_sBtnDefColor = Hex(0xD73443, 6) ; Crimson
$g_sBtnColor = Hex(0x559FF2, 6)    ; Cornflower blue
$g_sBtnResult = ""
$g_aBtn = StringSplit($g_sButtons, "|", 1)
$g_iTimer = 0 ; Default: No timer
$g_iTopMost = 0
$g_hParent = 0
$g_sFile = ""

; === Testing ===
;~ $g_sTitle = "Markdown MsgBox"
;~ $g_sText = "" & _
;~ 		"# 🎯 Make your Choice" & @CRLF & _
;~ 		"This is a **Modern UI** message box." & @CRLF & _
;~ 		"* 1️⃣ **Engine:** WebView2" & @CRLF & _
;~ 		"* 2️⃣ **Parser:** Marked.js" & @CRLF & _
;~ 		"* 3️⃣ **Logic:** AutoIt Bridge"
;~ $g_sButtons = "1|2|3|~CANCEL"
;~ $g_aBtn = StringSplit($g_sButtons, "|", 1)


_CmdLine_Parsing()

If FileExists($g_sFile) Then $g_sText = FileRead($g_sFile)

; === Execution ===
Global $g_fDpiScale = _GetNearestWindowsDpi()
Global $oWebV2M
Global $sResult = _MarkdownMsgBox()
ConsoleWrite($sResult & @CRLF)
Exit Int($sResult)

;---------------------------------------------------------------------------------------
Func _CmdLine_Parsing()
	If $CmdLine[0] > 0 Then
		For $i = 1 To $CmdLine[0]
			Local $sCmd = $CmdLine[$i]
			Select
				Case StringInStr($sCmd, "/BkColor:")
					$g_hBkColor = Hex(StringReplace($sCmd, "/BkColor:", ""), 6)
				Case StringInStr($sCmd, "/TxtColor:")
					$g_hTxtColor = Hex(StringReplace($sCmd, "/TxtColor:", ""), 6)
				Case StringInStr($sCmd, "/FootColor:")
					$g_hFootColor = Hex(StringReplace($sCmd, "/FootColor:", ""), 6)
				Case StringInStr($sCmd, "/MaxWidth:")
					$g_iMaxWidth = Int(StringReplace($sCmd, "/MaxWidth:", ""))
				Case StringInStr($sCmd, "/MaxHeight:")
					$g_iMaxHeight = Int(StringReplace($sCmd, "/MaxHeight:", ""))
				Case StringInStr($sCmd, "/Left:")
					$g_iLeft = Int(StringReplace($sCmd, "/Left:", ""))
				Case StringInStr($sCmd, "/Top:")
					$g_iTop = Int(StringReplace($sCmd, "/Top:", ""))
				Case StringInStr($sCmd, "/Title:")
					$g_sTitle = StringReplace($sCmd, "/Title:", "")
				Case StringInStr($sCmd, "/Text:")
					Local $sHex = StringReplace($sCmd, "/Text:", "")
					; If the string starts with 0x, it is Hex, otherwise it is plain text
					If StringLeft($sHex, 2) = "0x" Then
						$g_sText = BinaryToString($sHex, 4)
					Else
						$g_sText = StringRegExpReplace($sHex, '^["'']|["'']$', '')
					EndIf
				Case StringInStr($sCmd, "/Buttons:")
					Local $sHexBtn = StringReplace($sCmd, "/Buttons:", "")
					; If the string starts with 0x, it is Hex, otherwise it is plain text
					If StringLeft($sHexBtn, 2) = "0x" Then
						$g_sButtons = BinaryToString($sHexBtn, 4)
					Else
						$g_sButtons = $sHexBtn
					EndIf
					$g_aBtn = StringSplit($g_sButtons, "|", 1)
				Case StringInStr($sCmd, "/BtnDefColor:")
					$g_sBtnDefColor = Hex(StringReplace($sCmd, "/BtnDefColor:", ""), 6)
				Case StringInStr($sCmd, "/BtnColor:")
					$g_sBtnColor = Hex(StringReplace($sCmd, "/BtnColor:", ""), 6)
				Case StringInStr($sCmd, "/Timer:")
					$g_iTimer = Int(StringReplace($sCmd, "/Timer:", "")) * 1000
				Case StringInStr($sCmd, "/TopMost:")
					$g_iTopMost = (Int(StringReplace($sCmd, "/TopMost:", "")) ? $WS_EX_TOPMOST : 0)
				Case StringInStr($sCmd, "/Parent:")
					$g_hParent = HWnd(StringReplace($sCmd, "/Parent:", ""))
				Case StringInStr($sCmd, "/File:")
					$g_sFile = StringReplace($sCmd, "/File:", "")
					; We remove any extra quotes if the user entered /File:"path"
					$g_sFile = StringRegExpReplace($g_sFile, '^["'']|["'']$', '')
			EndSelect
		Next
	EndIf
EndFunc   ;==>_CmdLine_Parsing
;---------------------------------------------------------------------------------------
Func _MarkdownMsgBox()

	; Create the GUI Window (Hidden)
	$g_hGUI = GUICreate($g_sTitle, $g_iMaxWidth, $g_iMaxHeight, -1, -1, BitOR($WS_CAPTION, $WS_POPUP, $WS_SYSMENU, $WS_CLIPCHILDREN), $g_iTopMost, $g_hParent)
	GUISetIcon(@ScriptFullPath)
	GUISetBkColor($g_hBkColor)

	GUIRegisterMsg(0x02E0, WM_DPICHANGED) ; 0x02E0 = WM_DPICHANGED

	$oWebV2M = _NetWebView2_CreateManager("", "Web_Events_", "--allow-file-access-from-files --disable-web-security") ; 👈
	_NetWebView2_GetBridge($oWebV2M, "JS_Events_")

	; Initialize WebView2 - Use formatted Hex string for background
	_NetWebView2_Initialize($oWebV2M, $g_hGUI, @ScriptDir & "\UserData", 0, 0, 0, 0, True, True, 1.0, "0x" & $g_hBkColor, False)

	Local $sAssetsFolder = @ScriptDir & "\JS_Lib" ; The folder that has fontawesome\css\all.min.css
	_NetWebView2_SetVirtualHostNameToFolderMapping($oWebV2M, "local.lib", $sAssetsFolder, 0)

	_RenderMarkdown()

	; Register the background emergency timer
	AdlibRegister("_EmergencyShow", 1500)

	; If set a Timer, start the TimeOut
	If $g_iTimer > 0 Then AdlibRegister("_TimeOut", $g_iTimer)

	$g_sBtnResult = ""
	Local $nMsg
	While $g_sBtnResult = ""
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE
				$g_sBtnResult = "0"
		EndSwitch
	WEnd

	; Cleanup
	AdlibUnRegister("_EmergencyShow")
	AdlibUnRegister("_TimeOut")
	GUIDelete($g_hGUI)
	_NetWebView2_CleanUp($oWebV2M, $g_hGUI)

	Return $g_sBtnResult

EndFunc   ;==>_MarkdownMsgBox
;---------------------------------------------------------------------------------------
Volatile Func Web_Events_OnNavigationStarting($oWebV2M, $hGUI, $oArgs)
	#forceref $oWebV2M, $hGUI
	Local $sURL = $oArgs.Uri
	If StringLeft($sURL, 4) = "http" Then
		ShellExecute($sURL)
		$oArgs.Cancel = True ; Cancel navigation in WebView2
	EndIf
EndFunc   ;==>Web_Events_OnNavigationStarting
;---------------------------------------------------------------------------------------
Volatile Func JS_Events_OnMessageReceived($oWebV2M, $hGUI, $sMessage)
	#forceref $oWebV2M

	If StringLeft($sMessage, 7) = "RESIZE|" Then
		AdlibUnRegister("_EmergencyShow")

		Local $aData = StringSplit($sMessage, "|")
		If $aData[0] < 3 Then Return

		; Getting the Scale Factor
		$g_fDpiScale = _GetNearestWindowsDpi()
		ConsoleWrite("$g_fDpiScale=" & $g_fDpiScale & @CRLF)

		Local $iW = Int($aData[2]), $iH = Int($aData[3])

		; Dynamic Constraints based on Scaling
		Local $iMinW = 300 * $g_fDpiScale
		Local $iMaxW = $g_iMaxWidth * $g_fDpiScale
		Local $iMaxH = $g_iMaxHeight * $g_fDpiScale

		If $iW > $iMaxW Then $iW = $iMaxW
		If $iW < $iMinW Then $iW = $iMinW
		If $iH > $iMaxH Then $iH = $iMaxH


		; Add margins (Titlebar etc.)
		Local $iFinalW = $iW + 6
		Local $iFinalH = $iH + 29

		; Download Work Area (Screen without Taskbar)
		Local $tRect = DllStructCreate("int Left;int Top;int Right;int Bottom")
		DllCall("user32.dll", "bool", "SystemParametersInfo", "uint", 48, "uint", 0, "ptr", DllStructGetPtr($tRect), "uint", 0) ; 48 = SPI_GETWORKAREA

		Local $iWA_W = DllStructGetData($tRect, "Right") - DllStructGetData($tRect, "Left")
		Local $iWA_H = DllStructGetData($tRect, "Bottom") - DllStructGetData($tRect, "Top")

		; Position calculation (Center in Work Area)
		Local $iTargetLeft = ($g_iLeft = -1) ? DllStructGetData($tRect, "Left") + ($iWA_W - $iFinalW) / 2 : $g_iLeft
		Local $iTargetTop = ($g_iTop = -1) ? DllStructGetData($tRect, "Top") + ($iWA_H - $iFinalH) / 2 : $g_iTop

		; Resize and Show
		WinMove($hGUI, "", $iTargetLeft, $iTargetTop, $iFinalW, $iFinalH)
		GUISetState(@SW_SHOW, $hGUI)
		Return
	EndIf

	$g_sBtnResult = $sMessage
EndFunc   ;==>JS_Events_OnMessageReceived
;---------------------------------------------------------------------------------------
Func _EmergencyShow()
	AdlibUnRegister("_EmergencyShow") ; Run only once

	; If window is still hidden (State < 2), show it
	If $g_hGUI And Not BitAND(WinGetState($g_hGUI), 2) Then
		; ConsoleWrite("! Emergency Show Triggered" & @CRLF)
		GUISetState(@SW_SHOW, $g_hGUI)
	EndIf
EndFunc   ;==>_EmergencyShow
;---------------------------------------------------------------------------------------
Func _TimeOut()
	AdlibUnRegister("_TimeOut") ; Stop the timer
	$g_sBtnResult = "0" ; Force exit the loop with 'Cancel' status
EndFunc   ;==>_TimeOut
;---------------------------------------------------------------------------------------
Func _RenderMarkdown()
	Local $sStyle = _CSS()

	; Define the local path for FontAwesome and Marked.js library using the virtual host mapping
	Local $sFA_Link = "<link rel='stylesheet' href='https://local.lib/fontawesome/css/all.min.css'>"
	Local $sMarked_Link = "<script src='https://local.lib/marked/marked.umd.min.js'></script>"

	Local $Txt, $sButtons = "", $sDefaultBtn = ""

	For $i = 1 To $g_aBtn[0]
		Local $isDefault = (StringLeft($g_aBtn[$i], 1) = "~")
		$Txt = ($isDefault ? StringTrimLeft($g_aBtn[$i], 1) : $g_aBtn[$i])

		If $isDefault And $sDefaultBtn = "" Then $sDefaultBtn = $i

		Local $sID = ($isDefault ? "id='default-btn'" : "")
		; Added a space before buttons for better horizontal separation
		$sButtons &= " <button " & $sID & " class='btn focusable-btn btn-" & $i & "' onclick='uiAction(" & $i & ")'>" & $Txt & "</button>"
	Next

	Local $sHTML = "<html><head><meta charset='utf-8'>" & _
			"<base href='https://local.assets/'>" & _
			$sFA_Link & _
			$sMarked_Link & _
			"<style>" & $sStyle & "</style></head><body>" & _
			"<div id='main-container'>" & _
			"  <div id='view'></div>" & _
			"  <div class='footer'>" & $sButtons & "</div>" & _
			"</div>" & _
			"<script>" & @CRLF & _
			"function sendToAutoIt(data) {" & @CRLF & _
			"    if (window.chrome && window.chrome.webview && window.chrome.webview.postMessage) {" & @CRLF & _
			"        window.chrome.webview.postMessage(data.toString());" & @CRLF & _
			"    } else {" & @CRLF & _
			"        setTimeout(() => sendToAutoIt(data), 50);" & @CRLF & _
			"    }" & @CRLF & _
			"}" & @CRLF & _
			@CRLF & _
			"function uiAction(val) { sendToAutoIt(val); }" & @CRLF & _
			@CRLF & _
			"function updateSize() {" & @CRLF & _
			"    const container = document.getElementById('main-container');" & @CRLF & _
			"    const rect = container.getBoundingClientRect();" & @CRLF & _
			"    sendToAutoIt('RESIZE|' + Math.ceil(rect.width) + '|' + Math.ceil(rect.height));" & @CRLF & _
			"    const defBtn = document.getElementById('default-btn');" & @CRLF & _
			"    if(defBtn) defBtn.focus();" & @CRLF & _
			"}" & @CRLF & _
			@CRLF & _
			"window.addEventListener('load', function() {" & @CRLF & _
			"    const view = document.getElementById('view');" & @CRLF & _
			"    if (typeof marked !== 'undefined') {" & @CRLF & _
			"        marked.setOptions({ gfm: true, breaks: true });" & @CRLF & _
			"        view.innerHTML = marked.parse(" & _EscapeForJS($g_sText) & ".replace(/\\n|\\\\n/g, '\n'));" & @CRLF & _
			"    } else {" & @CRLF & _
			"        view.innerText = 'Error: Marked library not found.';" & @CRLF & _
			"    }" & @CRLF & _
			"    updateSize();" & @CRLF & _
			"});" & @CRLF & _
			@CRLF & _
			"window.addEventListener('keydown', function(e) {" & @CRLF & _
			"    const buttons = document.querySelectorAll('.focusable-btn');" & @CRLF & _
			"    if (e.key === 'Tab') {" & @CRLF & _
			"        const firstBtn = buttons[0];" & @CRLF & _
			"        const lastBtn = buttons[buttons.length - 1];" & @CRLF & _
			"        if (e.shiftKey) {" & @CRLF & _
			"            if (document.activeElement === firstBtn) { lastBtn.focus(); e.preventDefault(); }" & @CRLF & _
			"        } else {" & @CRLF & _
			"            if (document.activeElement === lastBtn) { firstBtn.focus(); e.preventDefault(); }" & @CRLF & _
			"        }" & @CRLF & _
			"    }" & @CRLF & _
			"    if (e.key === 'Enter') {" & @CRLF & _
			"        if (document.activeElement.tagName === 'BUTTON') {" & @CRLF & _
			"            document.activeElement.click();" & @CRLF & _
			"        } else {" & @CRLF & _
			"            uiAction('" & $sDefaultBtn & "');" & @CRLF & _
			"        }" & @CRLF & _
			"    }" & @CRLF & _
			"    if (e.key === 'Escape') uiAction('0');" & @CRLF & _
			"});" & @CRLF & _
			"</script></body></html>"

	_NetWebView2_NavigateToString($oWebV2M, $sHTML)
	$oWebV2M.LockWebView()
EndFunc   ;==>_RenderMarkdown
;---------------------------------------------------------------------------------------
Func _CSS()
	Local $hBCol, $sButtons = ""
	For $i = 1 To $g_aBtn[0]
		$hBCol = (StringLeft($g_aBtn[$i], 1) = "~" ? $g_sBtnDefColor : $g_sBtnColor)
		$sButtons &= ".btn-" & $i & " { background: #" & $hBCol & "; color: white; border: none; " & _
				(StringLeft($g_aBtn[$i], 1) = "~" ? " font-weight: bold; " : "") & "}"
	Next

	Local $sStyle = ""
	; Markdown elements
	$sStyle &= "h1, h2, h3, h4, h5, h6 { margin: 0 0 15px 0; color: #ffffff; }" & _
			"ul, ol { margin: 10px 0; padding-left: 25px; }" & _
			"li { margin-bottom: 5px; padding: 0; }" & _
			"#view p { margin-bottom: 10px; padding: 0; }" & _
			"a { color: #4da6ff; text-decoration: none; }" & _
			"blockquote { " & _
			"    border-left: 5px solid #4CAF50; " & _
			"    background-color: #252525; " & _
			"    margin: 1.5em 0; " & _
			"    padding: 10px 20px; " & _
			"    color: #aaaaaa; " & _
			"    font-style: italic; " & _
			"}"

	$sStyle &= "pre, code { " & _
			"font-family: 'Consolas', 'Courier New', monospace; " & _
			"background-color: #1e1e1e; " & _
			"padding: 2px 4px; " & _
			"border-radius: 4px; " & _
			"color: #dcdcdc; " & _
			"white-space: pre-wrap; " & _
			"word-wrap: break-word; " & _
			"}" & _
			"pre { " & _
			"padding: 15px; " & _
			"margin: 10px 0; " & _
			"line-height: 1.5; " & _
			"display: block; " & _
			"overflow-x: hidden; " & _
			"}"


	$sStyle &= "body { " & _
			"font-family: 'Segoe UI', Tahoma, sans-serif; " & _
			"background: #" & $g_hBkColor & "; " & _
			"color: #" & $g_hTxtColor & "; " & _
			"margin: 0; padding: 0; outline: none; " & _
			"display: block; " & _
			"overflow-x: hidden; " & _
			"overflow-y: auto; " & _
			"word-wrap: break-word; " & _
			"overflow-wrap: break-word; " & _
			"}" & _
			"#main-container { " & _
			"width: 100%; " & _
			"display: block; " & _
			"text-align: left; " & _
			"outline: none; " & _
			"box-sizing: border-box; " & _
			"}" & _
			"#view { " & _
			"padding: 20px; " & _
			"min-height: 50px; " & _
			"box-sizing: border-box; " & _
			"}"


	$sStyle &= ".footer { background: #" & $g_hFootColor & "; padding: 12px; text-align: right; " & _
			"border-top: 1px solid #333; width: 100%; box-sizing: border-box; }" & _
			".btn { padding: 8px 16px; margin-left: 6px; border-radius: 3px; cursor: pointer; font-size: 13px; " & _
			"transition: filter 0.2s; outline: none; }" & $sButtons & _
			".btn:hover { filter: brightness(1.2); } .btn:focus { outline: 2px solid #ffffff; outline-offset: 2px; }"

	Return $sStyle
EndFunc   ;==>_CSS
;---------------------------------------------------------------------------------------
Func _EscapeForJS($sText)
	$sText = StringReplace($sText, "\", "\\")
	$sText = StringReplace($sText, "'", "\'")

	$sText = StringReplace($sText, @CRLF & @CRLF, "\\n&nbsp;\\n")
	$sText = StringReplace($sText, "  ", "&nbsp;&nbsp;")

	$sText = StringReplace($sText, @CRLF, "\\n")
	$sText = StringReplace($sText, @CR, "\\n")
	$sText = StringReplace($sText, @LF, "\\n")
	Return "'" & $sText & "'"
EndFunc   ;==>_EscapeForJS
;---------------------------------------------------------------------------------------
Func _GetNearestWindowsDpi()
	Local $hDC = _WinAPI_GetDC(0)
	Local $iLogY = _WinAPI_GetDeviceCaps($hDC, 90) ; LOGPIXELSY
	_WinAPI_ReleaseDC(0, $hDC)

	Local $iCurrentPct = Round(($iLogY / 96) * 100)
	Local $iBestMatch = 100
	Local $iDiff = 9999

	; Table with the official Windows Scaling steps
	Local $aDpiVals[12] = [100, 125, 150, 175, 200, 225, 250, 300, 350, 400, 450, 500]

	For $i = 0 To UBound($aDpiVals) - 1
		If Abs($iCurrentPct - $aDpiVals[$i]) < $iDiff Then
			$iDiff = Abs($iCurrentPct - $aDpiVals[$i])
			$iBestMatch = $aDpiVals[$i]
		EndIf
	Next

	Return $iBestMatch / 100 ; Returns clean factor: 1.0, 1.25, 1.5, 1.75...
EndFunc   ;==>_GetNearestWindowsDpi
;---------------------------------------------------------------------------------------
Func WM_DPICHANGED($hWnd, $iMsg, $wParam, $lParam)
	#forceref $iMsg

	; lParam already has the correct dimensions for the new DPI
	Local $tRect = DllStructCreate("int Left;int Top;int Right;int Bottom", $lParam)
	WinMove($hWnd, "", DllStructGetData($tRect, "Left"), DllStructGetData($tRect, "Top"), _
			DllStructGetData($tRect, "Right") - DllStructGetData($tRect, "Left"), _
			DllStructGetData($tRect, "Bottom") - DllStructGetData($tRect, "Top"))
	$g_fDpiScale = BitAND($wParam, 0xFFFF) / 96
	ConsoleWrite("-$g_fDpiScale=" & $g_fDpiScale & @CRLF)

	Return 0
EndFunc   ;==>WM_DPICHANGED
;---------------------------------------------------------------------------------------



#CS Helper function for client script
	;---------------------------------------------------------------------------------------
	Func _FA($sIconName, $iStyle = 0, $hColor = "", $sEffect = "", $iSize = 0, $sExtra = "")
		; $iStyle:  0="fa-solid", 1="fa-regular"
		; $iSize:   0=normal, 1=lg, 2=2x, etc.
		; $sEffect: "" (none), "spin", "pulse", "beat", "fade"
		; $sExtra:  "fa-rotate-90", "fa-flip-horizontal", "fa-border"

		Local $sPrefix = ($iStyle ? "fa-regular" : "fa-solid")
		Local $sClass = $sPrefix & " fa-fw fa-" & $sIconName

		If $sEffect <> "" Then $sClass &= " fa-" & $sEffect
		If $sExtra <> "" Then $sClass &= " " & $sExtra

		If $iSize > 0 Then
			Local $sSizeSuffix = ($iSize = 1 ? "lg" : $iSize & "x")
			$sClass &= " fa-" & $sSizeSuffix
		EndIf

		Local $sStyleAttr = "margin-right:5px; vertical-align: middle;"
		If $hColor <> "" Then $sStyleAttr &= "color:#" & Hex($hColor, 6) & ";"

		Return "<i class='" & $sClass & "' style='" & $sStyleAttr & "'></i>"
	EndFunc   ;==>_FA
	;---------------------------------------------------------------------------------------
	Func _FA_Stack($sBackHTML, $sFrontHTML, $iStackSize = 0)
		Local $sSizeClass = ($iStackSize = 1 ? " fa-lg" : ($iStackSize > 1 ? " fa-" & $iStackSize & "x" : ""))
		Local $sFinalBack = StringReplace($sBackHTML, "fa-fw", "fa-stack-2x")
		Local $sFinalFront = StringReplace($sFrontHTML, "fa-fw", "fa-stack-1x fa-inverse")
		Return "<span class='fa-stack" & $sSizeClass & "' style='vertical-align: middle; margin-right: 5px;'>" & _
				$sFinalBack & $sFinalFront & _
				"</span>"
	EndFunc   ;==>_FA_Stack
	;---------------------------------------------------------------------------------------
	Func mdMsgBox($sParam, $bWait = True) ; skip the compilation in the examples
		If $bWait Then
			Return ShellExecuteWait(@AutoItExe, '"' & @ScriptDir & '\019-mdMsgBox.au3" ' & $sParam)
		Else
			Return ShellExecute(@AutoItExe, '"' & @ScriptDir & '\019-mdMsgBox.au3" ' & $sParam)
		EndIf
	EndFunc   ;==>mdMsgBox_Exec
	;---------------------------------------------------------------------------------------

    === mdMsgBox parameters with default values ===
	/BkColor:0x2B2B2B   ; (Dark slate gray)
	/TxtColor:0xE0E0E0  ; (Gainsboro)
	/FootColor:0x1E1E1E ; (Black)
	/MaxWidth:400
	/MaxHeight:800
	/Left:-1
	/Top:-1
	/Title:"Markdown MsgBox"
	/Text:""
	/Buttons:"OK"
	/BtnDefColor:0xD73443 ; (Crimson)
	/BtnColor:0x559FF2    ; (Cornflower blue)
	/Timer:0
	/TopMost:0
	/Parent:0
	/File:""

#CE Helper function for client script
