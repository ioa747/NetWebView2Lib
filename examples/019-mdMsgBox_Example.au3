
_Example1()
;~ _Example2()
;~ _Example3()
;~ _Example4()
;~ _Example5()

Func _Example1()
	; === Caller Script Example ===
	Local $sTitle = "Markdown MsgBox"
	Local $sMarkdown = "" & _
			"# 🎯 Make your Choice" & @CRLF & _
			"This is a **Modern UI** message box." & @CRLF & _
			"* 1️⃣ **Engine:** WebView2" & @CRLF & _
			"* 2️⃣ **Parser:** Marked.js" & @CRLF & _
			"* 3️⃣ **Logic:** AutoIt Bridge"
	Local $sButtons = "1|2|3|~CANCEL"
	Local $sHexText = String(StringToBinary($sMarkdown, 4)) ; Convert to Hex for safe CLI passage

	; Call your compiled EXE
	; We pass Title, Text (Hex), Buttons and a custom Button Color
	Local $iExitCode = RunWait('mdMsgBox.exe /Title:"' & $sTitle & '" /Text:' & $sHexText & ' /Buttons:"' & $sButtons & '" /TopMost:1')

	Switch $iExitCode
		Case 0
			ConsoleWrite("User cancelled or closed the window." & @CRLF)
		Case 1, 2, 3
			ConsoleWrite("User clicked: " & $iExitCode & @CRLF)
		Case 4
			ConsoleWrite("User clicked: CANCEL (Default)" & @CRLF)
	EndSwitch
EndFunc   ;==>_Example1

Func _Example2()
	Local $sIcon = _FA("exclamation-triangle", 0, 0xF1C40F, "beat", 1)
	Local $sMarkdown = "## " & $sIcon & " Warning" & @CRLF & "SQLite3.dll could not be loaded."
	Local $sHexText = StringToBinary($sMarkdown, 4)
	RunWait('mdMsgBox.exe /Title:"Error" /MaxWidth:300 /Text:' & $sHexText & ' /Buttons:~Cancel')
EndFunc   ;==>_Example2

Func _Example3()

	Local $sBack = _FA("circle", 0, 0xD73443, "fade")  ; Flashing red circle (Fade)
	Local $sFront = _FA("exclamation")                 ; White exclamation mark (fixed)
	Local $sIconHeader = _FA_Stack($sBack, $sFront, 1) ; Stacking, 1 = fa-lg for slightly larger
	Local $sText = "## " & $sIconHeader & " Unsaved Data." & @CRLF & _
			"You have **unsaved changes**." & @CRLF & "Do you want to **exit without saving?**"
	Local $sHexText = StringToBinary($sText, 4)
	If RunWait('mdMsgBox.exe /Title:"Warning" /Text:' & $sHexText & ' /Buttons:~NO|YES /BtnDefColor:0x559FF2 /BtnColor:0xD73443') = 2 Then
		ConsoleWrite("...exit without saving" & @CRLF)
	EndIf

EndFunc   ;==>_Example3

Func _Example4()
	;Example Blue gear turning
	Local $sIconHeader = _FA("cog", 0, 0x559FF2, "spin", 2)
	Local $sText = "### " & $sIconHeader & " processing..." & @CRLF & _
			"copy is in progress. Please wait."
	Local $sHexText = StringToBinary($sText, 4)

	Run('mdMsgBox.exe /Title:"copy in progress" /BtnDefColor:0x3EB10D /Text:' & $sHexText & ' /Buttons:~Cancel')

	Sleep(15000)
	WinClose("copy in progress")
EndFunc   ;==>_Example4

Func _Example5()

	; === Caller Script Example ===
	Local $sTitle = "Markdown MsgBox"
	Local $sIconClick = _FA("hand-point-down", 0, 0x559FF2, "bounce", 1)

	Local $sMarkdown = "" & _
			"## 😎  Font Awesome icon library " & @CRLF & _
			"* is a **icon library** with **2,140 free** Icons." & @CRLF & _
			"* https://fontawesome.com/search?ic=free-collection  " & $sIconClick

	Local $sHexText = String(StringToBinary($sMarkdown, 4)) ; Convert to Hex for safe CLI passage

	Local $sBtn1 = _FA("arrow-rotate-right", 0, "", "spin", 1) & "arrow"
	Local $sBtn2 = _FA("floppy-disk", 1, "", "fade", 1) & "floppy"
	Local $sBtn3 = _FA("circle-down", 1, "", "beat", 1) & "down"
	Local $sBtn4 = _FA("clipboard", 1, "", "", 1, "fa-flip") & "clipboard"
	Local $sButtons = StringToBinary($sBtn1 & "|" & $sBtn2 & "|" & $sBtn3 & "|" & $sBtn4, 4)

	; Call your compiled EXE
	Local $iExitCode = RunWait('mdMsgBox.exe /Title:"' & $sTitle & '" /Text:' & $sHexText & ' /Buttons:"' & $sButtons & '" /MaxWidth:500')
	ConsoleWrite("User clicked: " & $iExitCode & @CRLF)
EndFunc   ;==>_Example5

Func _FA($sIconName, $iStyle = 0, $hColor = "", $sEffect = "", $iSize = 0, $sExtra = "")
	; https://docs.fontawesome.com/web/style/animate/
	; $iStyle:  0="fa-solid", 1="fa-regular"
	; $sEffect: "", "spin", "pulse", "beat", "fade", "bounce", "Shake", "beat-fade"
	; $iSize:   0=normal, 1=lg, 2=2x, etc.
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

Func _FA_Stack($sBackHTML, $sFrontHTML, $iStackSize = 0)
	Local $sSizeClass = ($iStackSize = 1 ? " fa-lg" : ($iStackSize > 1 ? " fa-" & $iStackSize & "x" : ""))
	Local $sFinalBack = StringReplace($sBackHTML, "fa-fw", "fa-stack-2x")
	Local $sFinalFront = StringReplace($sFrontHTML, "fa-fw", "fa-stack-1x fa-inverse")
	Return "<span class='fa-stack" & $sSizeClass & "' style='vertical-align: middle; margin-right: 8px;'>" & _
			$sFinalBack & $sFinalFront & _
			"</span>"
EndFunc   ;==>_FA_Stack
