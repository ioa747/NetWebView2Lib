#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Run_AU3Check=Y
#AutoIt3Wrapper_AU3Check_Stop_OnWarning=y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7

; 002-Html_Gui.au3

#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <Array.au3>
#include "..\NetWebView2Lib.au3"

; Global variables for data management
Global $aMessages[0][3]
Global $sFilePath = @ScriptDir & "\messages.csv"
Global $idBlue, $idRed

_Example()

Func _Example()

	Local $oWebV2M, $oBridge
	_Create_Form($oWebV2M, $oBridge)
	If @error Then Return SetError(@error, @extended, '')

	; main Application Loop
	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				ExitLoop

			Case $idBlue
				; Update CSS variables dynamically via JavaScript
				$oWebV2M.ExecuteScript("document.documentElement.style.setProperty('--accent-color', '#4db8ff');")
				$oWebV2M.ExecuteScript("document.documentElement.style.setProperty('--btn-color', '#0078d7');")

			Case $idRed
				; Update CSS variables dynamically via JavaScript
				$oWebV2M.ExecuteScript("document.documentElement.style.setProperty('--accent-color', '#ff4d4d');")
				$oWebV2M.ExecuteScript("document.documentElement.style.setProperty('--btn-color', '#d70000');")
		EndSwitch
	WEnd

	_NetWebView2_CleanUp($oWebV2M, $oBridge)
EndFunc   ;==>_Example

Func _Create_Form(ByRef $oWebV2M, ByRef $oBridge)
	; Create GUI with resizing support
	Local $hGUI = GUICreate("WebView2 Theme Switcher", 450, 460)
	GUISetBkColor(0x1E1E1E)

	$idBlue = GUICtrlCreateLabel("Blue Theme", 10, 10, 100, 30)
	GUICtrlSetFont(-1, 12, Default, $GUI_FONTUNDER, "Segoe UI")
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetColor(-1, 0x0078D7)

	$idRed = GUICtrlCreateLabel("Red Theme", 120, 10, 100, 30)
	GUICtrlSetFont(-1, 12, Default, $GUI_FONTUNDER, "Segoe UI")
	GUICtrlSetResizing(-1, $GUI_DOCKALL)
	GUICtrlSetColor(-1, 0xFF0000)

	; Create WebView2 Manager object and register events
	$oWebV2M = _NetWebView2_CreateManager("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0", "", "")
	If @error Then Return SetError(@error, @extended, '')

	; initialize browser - put it on the GUI
	Local $sProfileDirectory = @ScriptDir & "\NetWebView2Lib-UserDataFolder"
	_NetWebView2_Initialize($oWebV2M, $hGUI, $sProfileDirectory, 0, 30, 450, 430, True, False, False, 1.1)
	If @error Then Return SetError(@error, @extended, '')

	$oWebV2M.IsZoomControlEnabled = False

	; Create bridge object and register events
	$oBridge = _NetWebView2_GetBridge($oWebV2M, "__MyEVENTS_Bridge_")
	#forceref $oBridge

	Local $sHTML = "<html><head><meta charset='UTF-8'><style>:" & __FormCSS() & "</style></head><body>" & __FormHTML() & "</body></html>"
	$oWebV2M.NavigateToString($sHTML)
	GUISetState(@SW_SHOW, $hGUI)
EndFunc   ;==>_Create_Form

; Handles data received from the JavaScript 'postMessage'
Func __MyEVENTS_Bridge_OnMessageReceived($oWebV2M, $hGUI, $sMessage) ; fork from __NetWebView2_JSEvents__OnMessageReceived()
	#forceref $hGUI
	__Example_Log(@ScriptLineNumber, "$sMessage=" & $sMessage)

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
				Local $hFile = FileOpen($sFilePath, 9) ; 1 (Write) + 8 (Create Path)
				If $hFile <> -1 Then
					; Clean the message string for CSV compatibility (remove line breaks)
					Local $sCleanMsg = StringReplace($sMsg, @CRLF, " ")
					FileWriteLine($hFile, $sName & "," & $sEmail & "," & $sCleanMsg)
					FileClose($hFile)
				EndIf

				ShowWebNotification($oWebV2M, "Data Saved Successfully!")
			Else
				; Trigger a visual notification inside the WebView
				ShowWebNotification($oWebV2M, "Please enter valid data", '#d70000')
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
			"	overflow: hidden;" & @CRLF & _ ; <- hidden Scrollbar
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
Func ShowWebNotification($oWebV2M, $sMessage, $sBgColor = "#4CAF50", $iDuration = 3000)
	; Local error handler for COM objects
	Local $oMyError = ObjEvent("AutoIt.Error", __HtmlGUI_ErrFunc)
	#forceref $oMyError

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

; User's COM error function. Will be called if COM error occurs
Func __HtmlGUI_ErrFunc($oError)
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

Func __Example_Log($s_ScriptLineNumber, $sString, $iError = @error, $iExtended = @extended)
	ConsoleWrite(@ScriptName & ' SLN=' & $s_ScriptLineNumber & ' [' & $iError & '/' & $iExtended & '] ::: ' & $sString & @CRLF)
	Return SetError($iError, $iExtended, '')
EndFunc   ;==>__Example_Log
