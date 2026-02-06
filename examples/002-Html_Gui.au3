#AutoIt3Wrapper_UseX64=y
; Html_Gui.au3
#include <Array.au3>
#include <FileConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>

#include "..\NetWebView2Lib.au3"

; Global variables for data management
Global $aMessages[0][3]
Global $sFilePath = @ScriptDir & "\messages.csv"
Global $hGUI, $oBridge, $idBlue, $idRed
Main()
Exit

Func Main()

	_Show_Form()

	; Main Application Loop
	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				_NetWebView2_CleanUp($_g_oWeb, $oBridge)
				ExitLoop

			Case $idBlue
				; Update CSS variables dynamically via JavaScript
				_NetWebView2_ExecuteScript($_g_oWeb, "document.documentElement.style.setProperty('--accent-color', '#4db8ff');")
				_NetWebView2_ExecuteScript($_g_oWeb, "document.documentElement.style.setProperty('--btn-color', '#0078d7');")

			Case $idRed
				; Update CSS variables dynamically via JavaScript
				_NetWebView2_ExecuteScript($_g_oWeb, "document.documentElement.style.setProperty('--accent-color', '#ff4d4d');")
				_NetWebView2_ExecuteScript($_g_oWeb, "document.documentElement.style.setProperty('--btn-color', '#d70000');")
		EndSwitch
	WEnd

EndFunc   ;==>Main

Func _Show_Form()
	; Create GUI with resizing support
	$hGUI = GUICreate("WebView2 Theme Switcher", 500, 480, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPCHILDREN))
	GUISetBkColor(0x1E1E1E)

	$idBlue = GUICtrlCreateLabel("Blue Theme", 10, 10, 100, 30)
	GUICtrlSetFont(-1, 12, Default, $GUI_FONTUNDER, "Segoe UI")
	GUICtrlSetColor(-1, 0x0078D7)

	$idRed = GUICtrlCreateLabel("Red Theme", 120, 10, 100, 30)
	GUICtrlSetFont(-1, 12, Default, $GUI_FONTUNDER, "Segoe UI")
	GUICtrlSetColor(-1, 0xFF0000)

	; Create WebView2 Manager object and register events
	$_g_oWeb = _NetWebView2_CreateManager("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0", "__MyEVENTS_Manager_", "")

	; initialize browser - put it on the GUI
	Local $sProfileDirectory = @TempDir & "\NetWebView2Lib-UserDataFolder"
	_NetWebView2_Initialize($_g_oWeb, $hGUI, $sProfileDirectory, 0, 50, 500, 400, True, False, False, 1.1)

	; Create bridge object and register events
	$oBridge = _NetWebView2_GetBridge($_g_oWeb, "__MyEVENTS_Bridge_")

	$_g_oWeb.IsZoomControlEnabled = False
	$_g_oWeb.IsScrollbarEnabled = False

	; Register the WM_SIZE message to handle window resizing
	GUIRegisterMsg($WM_SIZE, WM_SIZE)

	Local $sHTML = "<html><head><meta charset='UTF-8'><style>:" & __FormCSS() & "</style></head><body>" & __FormHTML() & "</body></html>"
	$_g_oWeb.NavigateToString($sHTML)
	GUISetState(@SW_SHOW, $hGUI)

EndFunc   ;==>_Show_Form

; Handles data received from the JavaScript 'postMessage'
Func __MyEVENTS_Bridge_OnMessageReceived($sMessage)
	; Local error handler for COM objects
	Local $oMyError = ObjEvent("AutoIt.Error", __HtmlGUI_ErrFunc)
	#forceref $oMyError

	ConsoleWrite("$sMessage=" & $sMessage & @CRLF)

	; Check for the specific form submission prefix
	If StringLeft($sMessage, 12) = "SUBMIT_FORM:" Then
		; Extract the JSON portion from the message
		Local $sJsonRaw = StringTrimLeft($sMessage, 12)
		Local $oJson = ObjCreate("NetJson.Parser")

		; Parse the raw JSON string
		If $oJson.Parse($sJsonRaw) Then
			; Extract values using their JSON keys
			Local $sName = $oJson.GetTokenValue("name")
			Local $sEmail = $oJson.GetTokenValue("email")
			Local $sMsg = $oJson.GetTokenValue("message")

			If $sName <> "" And $sEmail <> "" Then
				; Add data to global array for internal tracking
				_ArrayAdd($aMessages, $sName & "|" & $sEmail & "|" & $sMsg)

				; Append data to CSV file safely
				Local $hFile = FileOpen($sFilePath,  $FO_APPEND + $FO_CREATEPATH)
				If $hFile <> -1 Then
					; Clean the message string for CSV compatibility (remove line breaks)
					Local $sCleanMsg = StringReplace($sMsg, @CRLF, " ")
					FileWriteLine($hFile, $sName & "," & $sEmail & "," & $sCleanMsg)
					FileClose($hFile)
				EndIf

				ShowWebNotification("Data Saved Successfully!")
			Else
				; Trigger a visual notification inside the WebView
				ShowWebNotification("Please enter valid data", '#d70000')
			EndIf
		EndIf
	EndIf
EndFunc   ;==>__MyEVENTS_Bridge_OnMessageReceived

; Generates the CSS block with dynamic variables
Func __FormCSS()
	Local $sCSS = _
			"root {" & @CRLF & _
			"	--bg-color: #1e1e1e;" & @CRLF & _
			"	--form-bg: #2d2d2d;" & @CRLF & _
			"	--accent-color: #4db8ff;" & @CRLF & _
			"	--btn-color: #0078d7;" & @CRLF & _
			"	--txt-color: #e0e0e0;" & @CRLF & _
			"}" & @CRLF & _
			"body {" & @CRLF & _
			"	background-color: var(--bg-color);" & @CRLF & _
			"	color: var(--txt-color);" & @CRLF & _
			"	font-family: 'Segoe UI', sans-serif;" & @CRLF & _
			"	padding: 20px;" & @CRLF & _
			"	margin: 0;" & @CRLF & _
			"}" & @CRLF & _
			"#contactForm {" & @CRLF & _
			"	max-width: 400px;" & @CRLF & _
			"	background-color: var(--form-bg);" & @CRLF & _
			"	padding: 20px;" & @CRLF & _
			"	border-radius: 8px;" & @CRLF & _
			"	box-shadow: 0 4px 15px rgba(0, 0, 0, 0.5);" & @CRLF & _
			"}" & @CRLF & _
			"label {" & @CRLF & _
			"	display: block;" & @CRLF & _
			"	margin-bottom: 5px;" & @CRLF & _
			"	font-weight: bold;" & @CRLF & _
			"	color: var(--accent-color);" & @CRLF & _
			"}" & @CRLF & _
			"input, textarea {" & @CRLF & _
			"	width: 100%;" & @CRLF & _
			"	padding: 10px;" & @CRLF & _
			"	background-color: #3d3d3d;" & @CRLF & _
			"	border: 1px solid #555;" & @CRLF & _
			"	border-radius: 4px;" & @CRLF & _
			"	color: #fff;" & @CRLF & _
			"	box-sizing: border-box;" & @CRLF & _
			"	margin-bottom: 15px;" & @CRLF & _
			"}" & @CRLF & _
			"button {" & @CRLF & _
			"	background-color: var(--btn-color);" & @CRLF & _
			"	color: white;" & @CRLF & _
			"	border: none;" & @CRLF & _
			"	padding: 12px 20px;" & @CRLF & _
			"	border-radius: 4px;" & @CRLF & _
			"	cursor: pointer;" & @CRLF & _
			"	width: 100%;" & @CRLF & _
			"	font-size: 16px;" & @CRLF & _
			"}" & @CRLF & _
			""
	Return $sCSS
EndFunc   ;==>__FormCSS

; Generates the HTML form and JavaScript logic
Func __FormHTML()
	Local $sHTML = _
			"<form id='contactForm'>" & @CRLF & _
			"  <label>Name:</label><input type='text' id='name'>" & @CRLF & _
			"  <label>Email:</label><input type='email' id='mail'>" & @CRLF & _
			"  <label>Message:</label><textarea id='msg'></textarea>" & @CRLF & _
			"  <button type='button' onclick='submitToAutoIt()'>Send Message</button>" & @CRLF & _
			"</form>" & @CRLF & _
			"<script>" & @CRLF & _
			"  function submitToAutoIt() {" & @CRLF & _
			"    const formData = {" & @CRLF & _
			"      name: document.getElementById('name').value," & @CRLF & _
			"      email: document.getElementById('mail').value," & @CRLF & _
			"      message: document.getElementById('msg').value" & @CRLF & _
			"    };" & @CRLF & _
			"    " & @CRLF & _
			"    // postMessage to autoit" & @CRLF & _
			"    window.chrome.webview.postMessage('SUBMIT_FORM:' + JSON.stringify(formData));" & @CRLF & _
			"    " & @CRLF & _
			"    document.getElementById('contactForm').reset();" & @CRLF & _
			"  }" & @CRLF & _
			"</script>"
	Return $sHTML
EndFunc   ;==>__FormHTML

; Injects a temporary notification box into the web page
Func ShowWebNotification($sMessage, $sBgColor = "#4CAF50", $iDuration = 3000)
	; Local error handler for COM objects
	Local $oMyError = ObjEvent("AutoIt.Error", __HtmlGUI_ErrFunc)
	#forceref $oMyError

	; We use a unique ID 'autoit-notification' to find and replace existing alerts
	Local $sJS = _
			"var oldDiv = document.getElementById('autoit-notification');" & @CRLF & _
			"if (oldDiv) { oldDiv.remove(); }" & @CRLF & _
			"var div = document.createElement('div');" & @CRLF & _
			"div.id = 'autoit-notification'; // Assign the ID" & @CRLF & _
			"var div.style = 'position:fixed; top:20px; left:50%; transform:translateX(-50%); padding:15px; background:" & $sBgColor & "; color:white; border-radius:8px; z-index:9999; font-family:sans-serif; box-shadow: 0 4px 6px rgba(0,0,0,0.2); transition: opacity 0.5s; '" & @CRLF & _
			"div.innerText = '" & $sMessage & "';" & @CRLF & _
			"document.body.appendChild(div);" & @CRLF & _
			"setTimeout(() => {" & @CRLF & _
			"	var target = document.getElementById('autoit-notification');" & @CRLF & _
			"	If (target) { " & @CRLF & _
			"		target.style.opacity = '0';" & @CRLF & _
			"		setTimeout(() => target.remove(), 500); " & @CRLF & _
			"	}" & @CRLF & _
			"}, " & $iDuration & ");" & @CRLF & _
			""

	$_g_oWeb.ExecuteScript($sJS)
EndFunc   ;==>ShowWebNotification

; Synchronizes WebView size with the GUI window
Func WM_SIZE($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $wParam
	If $hWnd <> $hGUI Then Return $GUI_RUNDEFMSG ; critical, to respond only to the $hGUI
	If $wParam = 1 Then Return $GUI_RUNDEFMSG ; 1 = SIZE_MINIMIZED
	Local $iW = BitAND($lParam, 0xFFFF), $iH = BitShift($lParam, 16) - 50
	If IsObj($_g_oWeb) Then $_g_oWeb.Resize(($iW < 10 ? 10 : $iW), ($iH < 10 ? 10 : $iH))
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_SIZE

; User's COM error function. Will be called if COM error occurs
Func __HtmlGUI_ErrFunc(ByRef $oError)
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
EndFunc   ;==>__HtmlGUI_ErrFunc
