#AutoIt3Wrapper_UseX64=y
; Html_Gui.au3
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <Array.au3>

; Global objects
Global $oManager, $oBridge
Global $oEvtManager, $oEvtBridge

; Global error handler for COM objects
Global $oMyError = ObjEvent("AutoIt.Error", "_ErrFunc")

; Global variables for data management
Global $aMessages[0][3]
Global $sFilePath = @ScriptDir & "\messages.csv"
Global $hGUI

Main()

Func Main()
	; Create GUI with resizing support
	$hGUI = GUICreate("WebView2 Theme Switcher", 500, 450, -1, -1, BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPCHILDREN))
	GUISetBkColor(0x1E1E1E)

	Local $idBlue = GUICtrlCreateLabel("Blue Theme", 10, 10, 100, 30)
	GUICtrlSetFont(-1, 12, Default, $GUI_FONTUNDER, "Segoe UI")
	GUICtrlSetColor(-1, 0x0078D7)

	Local $idRed = GUICtrlCreateLabel("Red Theme", 120, 10, 100, 30)
	GUICtrlSetFont(-1, 12, Default, $GUI_FONTUNDER, "Segoe UI")
	GUICtrlSetColor(-1, 0xFF0000)

	; Get the WebView2 Manager object and register events
	$oManager = ObjCreate("NetWebView2.Manager")
	$oEvtManager = ObjEvent($oManager, "Manager_", "IWebViewEvents")

	; ⚠️ Important: Enclose ($hGUI) in parentheses to force "Pass-by-Value".
	; This prevents the COM layer from changing the AutoIt variable type from Ptr to Int64.
	$oManager.Initialize(($hGUI), "", 0, 50, 500, 400)

	; Get the bridge object and register events
	$oBridge = $oManager.GetBridge()
	$oEvtBridge = ObjEvent($oBridge, "Bridge_", "IBridgeEvents")

	; Register the WM_SIZE message to handle window resizing
	GUIRegisterMsg($WM_SIZE, "WM_SIZE")

	;GUISetState(@SW_SHOW)

	; Main Application Loop
	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				$oManager.Cleanup()
				Exit

			Case $idBlue
				; Update CSS variables dynamically via JavaScript
				$oManager.ExecuteScript("document.documentElement.style.setProperty('--accent-color', '#4db8ff');")
				$oManager.ExecuteScript("document.documentElement.style.setProperty('--btn-color', '#0078d7');")

			Case $idRed
				; Update CSS variables dynamically via JavaScript
				$oManager.ExecuteScript("document.documentElement.style.setProperty('--accent-color', '#ff4d4d');")
				$oManager.ExecuteScript("document.documentElement.style.setProperty('--btn-color', '#d70000');")
		EndSwitch
	WEnd

EndFunc   ;==>Main

; Handles data received from the WebView2 Manager
Func Manager_OnMessageReceived($sMessage)
	Local Static $bIsInitialized = False
	If $sMessage = "INIT_READY" And Not $bIsInitialized Then
		$bIsInitialized = True ; We note that we are finished.
		Local $sHTML = "<html><head><meta charset='UTF-8'>" & _FormCSS() & "</head><body>" & _FormHTML() & "</body></html>"
		$oManager.NavigateToString($sHTML)
		GUISetState(@SW_SHOW, $hGUI)
	EndIf
EndFunc   ;==>Manager_OnMessageReceived

; Handles data received from the JavaScript 'postMessage'
Func Bridge_OnMessageReceived($sMessage)
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
				Local $hFile = FileOpen($sFilePath, 9) ; 1 (Write) + 8 (Create Path)
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
EndFunc   ;==>Bridge_OnMessageReceived

; Generates the CSS block with dynamic variables
Func _FormCSS()
	Local $sTxt = "<style>" & @CRLF & _
			":root {" & @CRLF & _
			"  --bg-color: #1e1e1e; --form-bg: #2d2d2d;" & @CRLF & _
			"  --accent-color: #4db8ff; --btn-color: #0078d7; --txt-color: #e0e0e0;" & @CRLF & _
			"}" & @CRLF & _
			"body { background-color: var(--bg-color); color: var(--txt-color); font-family: 'Segoe UI', sans-serif; padding: 20px; margin: 0; }" & @CRLF & _
			"#contactForm { max-width: 400px; background-color: var(--form-bg); padding: 20px; border-radius: 8px; box-shadow: 0 4px 15px rgba(0,0,0,0.5); }" & @CRLF & _
			"label { display: block; margin-bottom: 5px; font-weight: bold; color: var(--accent-color); }" & @CRLF & _
			"input, textarea { width: 100%; padding: 10px; background-color: #3d3d3d; border: 1px solid #555; border-radius: 4px; color: #fff; box-sizing: border-box; margin-bottom: 15px; }" & @CRLF & _
			"button { background-color: var(--btn-color); color: white; border: none; padding: 12px 20px; border-radius: 4px; cursor: pointer; width: 100%; font-size: 16px; }" & @CRLF & _
			"</style>"
	Return $sTxt
EndFunc   ;==>_FormCSS

; Generates the HTML form and JavaScript logic
Func _FormHTML()
	Local $sTxt = "<form id='contactForm'>" & @CRLF & _
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
	Return $sTxt
EndFunc   ;==>_FormHTML

; Injects a temporary notification box into the web page
Func ShowWebNotification($sMessage, $sBgColor = "#4CAF50", $iDuration = 3000)
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

	$oManager.ExecuteScript($sJS)
EndFunc   ;==>ShowWebNotification

; Synchronizes WebView size with the GUI window
Func WM_SIZE($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $wParam
	If $hWnd <> $hGUI Then Return $GUI_RUNDEFMSG ; critical, to respond only to the $hGUI
	If $wParam = 1 Then Return $GUI_RUNDEFMSG ; 1 = SIZE_MINIMIZED
	Local $iW = BitAND($lParam, 0xFFFF), $iH = BitShift($lParam, 16) - 50
	If IsObj($oManager) Then $oManager.Resize(($iW < 10 ? 10 : $iW), ($iH < 10 ? 10 : $iH))
	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_SIZE

; User's COM error function. Will be called if COM error occurs
Func _ErrFunc($oError)
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
EndFunc   ;==>_ErrFunc
